package barkeep;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import haxe.Json;
import openfl.Assets;
import sys.FileSystem;

using StringTools;

typedef CustomerData =
{
	var name:String;
	var drink:String;
	var ?wantsIce:Bool;
	var ?wantsOptionalAlcohol:Bool;
};

typedef CharacterData =
{
	var name:String;
	var folder:String;
	var ?default_sprite:String;
	var sprites:Map<String, String>; // The default one to be shown has to have the name "default"
	// the sprites data in json is actually in a format of Array<{name:String, file:String}>
	var ?scale:Array<Float>;
	var ?walkFrequency:Float;
	var ?walkTime:Float;
}

class Customer extends FlxSprite
{
	public var data:CharacterData;
	public var walkingIn:Bool;

	public function new(?x:Float, ?y:Float, name:String)
	{
		super(x, y);
		this.data = CharacterSystem.customerData[name];
		if (data.scale != null && data.scale.length > 1)
			this.scale.set(data.scale[0], data.scale[1]);
		antialiasing = true;
		changeSpriteState(data.default_sprite ?? "neutral");
	}

	public function changeSpriteState(name:String)
	{
		// TEMP, until images are stitched or whatever
		if (data == null || data.sprites == null)
			throw 'Error! Character data for ${name} may be null or character sprite data may be null';
		var f = data.folder + (data.sprites[name] ?? '/.'); // if data.sprites[name] is null, f basically becomes an invalid path
		if (f.endsWith('/.'))
		{
			trace(name);
		};
		if (FileSystem.exists(f))
		{
			loadGraphic(f);
		}
	}

	public function changeCharacter(name:String)
	{
		this.data = CharacterSystem.customerData[name];
		if (data.scale != null && data.scale.length > 1)
			this.scale.set(data.scale[0], data.scale[1]);
		antialiasing = true;
		changeSpriteState(data.default_sprite ?? "neutral");
	}

	var walking:Bool;

	public function walkTo(x:Float, y:Float, t:Float, ?WalkingIn:Bool = true)
	{
		walking = true;
		walkingIn = WalkingIn;

		FlxTween.tween(this, {x: x}, t, {
			onComplete: _ ->
			{
				walking = false;
				FlxTween.tween(this, {y: y}, .03);
			}
		});
	}

	var totalElapsed:Float;
	var freqBase = 360 / Math.PI;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (walking)
		{
			totalElapsed += elapsed;
			y -= (Math.sin(totalElapsed * freqBase * data.walkFrequency) * 3);
		}
		else
		{
			totalElapsed = 0;
		}
	}
}

class CharacterSystem
{
	public static var customerData:Map<String, CharacterData> = [];

	public static function loadCustomerData(List:Array<String>)
	{
		var folder = "assets/data/characters/";
		var list = [];

		for (i in 0...List.length)
		{
			list[i] = folder + List[i] + '.json';
		};

		trace(list);

		for (f in list)
		{
			var data:
				{
					name:String,
					folder:Null<String>,
					default_sprite:String,
					sprites:Array<{name:String, file:String}>,
					scale:Null<Array<Float>>,
					walkFrequency:Null<Float>,
					walkTime:Null<Float>
				} = cast Json.parse(Assets.getText(f));
			trace(data);
			var sprites:Map<String, String> = [];
			for (i in 0...data.sprites.length)
			{
				sprites[data.sprites[i].name] = data.sprites[i].file;
			}

			if (!data.folder.endsWith('/'))
			{
				data.folder += '/';
			}

			trace("WXWXWXW", data.name);

			customerData[data.name] = {
				name: data.name,
				default_sprite: data.default_sprite,
				folder: data.folder,
				sprites: sprites,
				scale: data.scale,
				walkFrequency: data.walkFrequency ?? .2,
				walkTime: data.walkTime ?? 3.0
			};
		}

		#if debug
		// trace(customerData);
		#end
	}
}
