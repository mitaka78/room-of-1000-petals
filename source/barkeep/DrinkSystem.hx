package barkeep;

import flixel.tweens.FlxTween;
import haxe.Json;
import haxe.ds.Vector;
import openfl.Assets;
import sys.FileSystem;

using StringTools;

enum abstract Ingredient(String) from String to String
{
	var BEER = "Beer";
	var HOUSE_SAKE = "Sake";
	var GREEN_TEA = "GTea";
	var SIMPLE = "Simple"; // Simply Syrup
	var CITRUS = "Citrus";
	var GIN = "Gin";
	var WHISKEY = "Whiskey";
	var SODA = "Soda";
	var CARBONATED_WATER = "CarbWater";
	var MUDDLED_CHERRIES = "MudCherry";
	var MELON_LIQUEUR = "MelonLiq";
	var DASH_BITTERS = "DashBitters";
	var ICE = "Ice";
}

enum abstract DrinkStyle(UInt) from UInt to UInt
{
	var AS_IS = 0;
	var SHAKEN = 1;
	var STIRRED = 2;
}

@:structInit
abstract IngredientObject(Vector<Dynamic>) from Dynamic to Dynamic
{
	public var name(get, set):Ingredient;
	public var count(get, set):Int;

	public inline function new(name:Ingredient, ?count:UInt = 1)
	{
		this = new Vector<Dynamic>(2);
		this.set(0, name);
		this.set(1, count);
	}

	public inline function get_name()
		return this.get(0);

	public inline function set_name(Name:Ingredient)
		return this.set(0, Name);

	public inline function get_count()
		return this.get(1);

	public inline function set_count(Count:Int)
		return this.set(1, Count);
}

typedef DrinkStruct =
{
	var name:String;
	var description:String;
	var ingredients:Array<IngredientObject>;
	var ?style:DrinkStyle;
	var ?tags:Array<String>;
	var ?houseDrink:Bool; // If it's a house drink, it only has 1 ingredient and can have any number of it
}

class DrinkSystem
{
	public static var drinks:Map<String, DrinkStruct> = [];

	public static function init()
	{
		var files = FileSystem.readDirectory("assets/drinks/");
		for (f in files)
		{
			var json = Json.parse(Assets.getText("assets/drinks/" + f));
			var ingredients:Array<IngredientObject> = [];
			for (i in 0...json.ingredients.length)
			{
				var spl = json.ingredients[i].split(':');
				ingredients.push(new IngredientObject(spl[0], Std.parseInt(spl[1])));
			}
			drinks[json.name] = {
				name: json.name,
				description: json.description,
				ingredients: ingredients,
				tags: json.tags,
				style: json.style,
				houseDrink: json.houseDrink,
			};

			#if debug
			trace(drinks);
			#end
		}
	}

	public static inline function getDrinkByName(name:String)
	{
		return drinks[name];
	}
}
