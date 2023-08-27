package dialogue;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import ink.runtime.Story;
import lime.utils.Assets;

class DialogueBox extends FlxSpriteGroup
{
	// Story object
	public var s:Story;

	// Sprites
	public var box:FlxSprite;
	public var nameText:FlxText;
	public var dialogueText:FlxTypeText;
	// FlxSpriteGroup doesn't support adding of anything that isn't FlxSprite or extends off of it
	// So we need to store choiceButtons in an array instead of a group
	// And add the choice sprites directly on without having a 'choice layer'
	// Won't cause issues for the most part.
	public var choiceButtons:Array<ChoiceButton>;

	public function new(?x:Float, ?y:Float, ?file:String)
	{
		super(x, y);
		if (file != null)
			loadFromFile(file);
		choiceButtons = [];
		createSprites();
		// 0 X
		// 1 Y
		// 2 XY
		bindExtFunctionsToInkEngine();
	}

	function bindExtFunctionsToInkEngine()
	{
		s.BindExternalFunction3("addSprite", (tag:String, file:String, layer:String) ->
		{
			layer ?? layer = "midground";
			var sprite = new FlxSprite(0, 0, file);
			PlayState.instance.sprites[tag] = sprite;
			switch (layer.toLowerCase())
			{
				case 'background', 'bg':
					PlayState.instance.backgroundSprites.add(sprite);
				case 'midground', 'mg':
					PlayState.instance.midgroundSprites.add(sprite);
				case 'foreground', 'fg':
					PlayState.instance.foregroundSprites.add(sprite);
				case 'front':
					PlayState.instance.add(sprite);
			}

			return true;
		});

		s.BindExternalFunction1("removeSprite", (tag:String) ->
		{
			var sprite = PlayState.instance.sprites[tag];
			// im lazy
			PlayState.instance.backgroundSprites.remove(sprite);
			PlayState.instance.midgroundSprites.remove(sprite);
			PlayState.instance.foregroundSprites.remove(sprite);
			PlayState.instance.remove(sprite);
			return true;
		});

		s.BindExternalFunction3("moveSprite", (tag:String, x:Float, y:Float) ->
		{
			var sprites = PlayState.instance.sprites;
			if (sprites.exists(tag) && sprites[tag] != null)
			{
				sprites[tag].setPosition(x, y);
				return true;
			}
			return false;
		});

		s.BindExternalFunction2("centerSprite", (tag:String, axes:Int) ->
		{
			var sprites = PlayState.instance.sprites;
			if (sprites.exists(tag) && sprites[tag] != null)
			{
				var sprite = sprites[tag];
				switch (axes)
				{
					case 0:
						sprite.screenCenter(X);
					case 1:
						sprite.screenCenter(Y);
					case 2:
						sprite.screenCenter(XY);
				}

				return true;
			}
			return false;
		});

		s.BindExternalFunction1("changeCustomerSprite", (name:String) ->
		{
			if (PlayState.instance.customer != null)
			{
				PlayState.instance.customer.changeSpriteState(name ?? "default");
				return true;
			}

			return false;
		});
	}

	public inline function loadFromFile(file:String)
	{
		return loadFromText(Assets.getText(file));
	}

	public inline function loadFromText(text:String)
	{
		s = new Story(text);
		return this;
	}

	var currentName:String;

	var cIndex:Int = 0;

	public function dialogue()
	{
		var E = FlxG.keys.justPressed.ENTER;
		var U = FlxG.keys.anyJustPressed([W, UP]);
		var D = FlxG.keys.anyJustPressed([S, DOWN]);

		if (s.canContinue)
		{
			if (E)
			{
				s.Continue();
				trace(s.currentText);
			}
		}
		else
		{
			if (s.currentChoices.length > 0)
			{
				if (U)
				{
					cIndex++;
					if (cIndex >= s.currentChoices.length)
						cIndex = 0;
				}
				else if (D)
				{
					cIndex--;
					if (cIndex < 0)
						cIndex = s.currentChoices.length - 1;
				}

				if (E)
				{
					trace("chosechoice:", s.currentChoices[cIndex].text);
					s.ChooseChoiceIndex(cIndex);
				}
			}
		}
	}

	function createSprites()
	{
		box = new FlxSprite().makeGraphic(Std.int(FlxG.width / 3), 240, FlxColor.GRAY);
		box.screenCenter(X);
		box.x -= box.width / 2;
		box.y = FlxG.height - 300;

		dialogueText = new FlxTypeText(20, 20, Std.int(dialogueText.width - 14), "", 14);

		add(box);
		add(dialogueText);
	}
}

class ChoiceButton extends FlxSpriteGroup
{
	public var box:FlxSprite;
	public var choiceText:FlxText;

	public function new(?x:Float, ?y:Float)
	{
		super(x, y);
	}
}
