package;

import barkeep.Customer;
import barkeep.Day;
import barkeep.DrinkSystem;
import dialogue.DialogueBox;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.Json;
import ink.runtime.Story;
import openfl.Assets;
import openfl.utils.Function;
import sys.FileSystem;

using StringTools;

class PlayState extends FlxState
{
	inline static var LEFT_CLICK_ACTION:UInt = 0;
	inline static var RIGHT_CLICK_ACTION:UInt = 1;
	inline static var MAX_INGREDIENTS:UInt = 10;

	var inkStory:Story;

	var wantedDrink:DrinkStruct;
	var wantsGin:Bool;
	var curIngredients:Map<String, Int> = [];
	var curStyle:DrinkStyle;
	var curDrinkName:String;
	var curCustName:String;

	var dialogueBox:DialogueBox;

	var day:Day;

	var spriteActions:Map<FlxSprite, Function> = [];

	// LAYERS
	public var background:FlxSprite;
	public var backgroundSprites:FlxSpriteGroup; // background characters, environment, etc
	public var brewingAreaBg:FlxSprite;
	public var midgroundSprites:FlxSpriteGroup; // characters, etc
	public var foregroundSprites:FlxSpriteGroup; // counter, etc
	public var ingredientSprites:Array<FlxSprite> = [];

	var isOnBrewingScreen:Bool = false;

	var brewScreenOverlapSwitch:FlxObject;
	var serveScreenOverlapSwitch:FlxObject;
	var serveCounter:FlxSprite;
	var brewCounter:FlxSprite;

	var customerDefaultPos:{x:Float, y:Float} = {x: FlxG.width / 2, y: FlxG.height / 2.5};

	public var sprites:Map<String, FlxSprite>;

	public var customer:Customer;

	public static var instance:PlayState;

	var tcust = [
		for (i in FileSystem.readDirectory('assets/data/characters'))
			i.replace('.json', '')
	];

	public function new()
	{
		super();
		PlayState.instance = this;
		trace(tcust);
		loadDay('assets/data/test_day.json');
	}

	override public function create()
	{
		super.create();
		FlxG.debugger.drawDebug = true;

		background = new FlxSprite().loadGraphic("assets/images/Bar.png");
		add(background);

		brewingAreaBg = new FlxSprite(FlxG.width, 0).makeGraphic(Std.int(FlxG.width * 2 / 3), FlxG.height);
		add(brewingAreaBg);

		brewScreenOverlapSwitch = new FlxObject(FlxG.width - FlxG.width / 16, 0, FlxG.width / 8, FlxG.height);
		add(brewScreenOverlapSwitch);

		serveScreenOverlapSwitch = new FlxObject(brewScreenOverlapSwitch.x - FlxG.width / 8, 0, FlxG.width / 8, FlxG.height);
		add(serveScreenOverlapSwitch);

		backgroundSprites = new FlxSpriteGroup();
		midgroundSprites = new FlxSpriteGroup();
		foregroundSprites = new FlxSpriteGroup();

		add(background);
		add(midgroundSprites);
		add(foregroundSprites);

		serveCounter = new FlxSprite(0, background.height).loadGraphic("assets/images/Counter.png");
		brewCounter = new FlxSprite(serveCounter.width, background.height).loadGraphic("assets/images/Counter.png");
		foregroundSprites.add(serveCounter);
		foregroundSprites.add(brewCounter);

		createIngredients();

		CharacterSystem.loadCustomerData(tcust);
		customerIndex = -1;
		customer = new Customer(0, customerDefaultPos.y, "Aya");
		nextCustomer();
		customer.walkTo(customerDefaultPos.x, customerDefaultPos.y, 3);
		// SPRITE.screenCenter(X);
		midgroundSprites.add(customer);
	}

	inline function loadDay(file:String)
	{
		return day = cast Json.parse(Assets.getText(file));
	}

	function createIngredients()
	{
		var beer = ing(brewScreenOverlapSwitch.x + brewScreenOverlapSwitch.width, 60, "beer", BEER, true);
		ing(0, 0, "housesake", HOUSE_SAKE);
		ing(0, 0, "greentea", GREEN_TEA);
		ing(0, 0, "simplesyrup", SIMPLE);
		var citrus = ing(beer.x, beer.y + 120 * 1.5, "citrusjuice", CITRUS, true);
		ing(0, 0, "gin", GIN);
		ing(0, 0, "whiskey", WHISKEY);
		ing(0, 0, "soda", SODA);
		var carbwater = ing(citrus.x, citrus.y + 120 * 1.5, "carbwater", CARBONATED_WATER, true);
		ing(0, 0, "mudcherry", MUDDLED_CHERRIES);
		ing(0, 0, "melonliquor", MELON_LIQUEUR);
		ing(0, 0, "dashbitters", DASH_BITTERS);

		var ice = ing(brewCounter.x + brewingAreaBg.width - 120 * 2, FlxG.height - brewCounter.height * 3.5 / 4, "ice", ICE, true);
	}

	function createEquipment() {}

	var I = 0;

	var servingCustomer:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState();
		}

		// if (FlxG.keys.justPressed.N)
		// {
		// 	nextCustomer();
		// }

		if (FlxG.keys.justPressed.C && continueStuff)
		{
			makeDrink(getIngredients());
			if (curDrinkName == wantedDrink.name)
			{
				trace("THANK YOU CORRECT DRINK");
				nextCustomer();
			}
			else
			{
				trace("WRONG DRINK");
				nextCustomer();
			}
		}

		if (!isOnBrewingScreen)
		{
			if (FlxG.mouse.overlaps(brewScreenOverlapSwitch) && continueStuff)
			{
				isOnBrewingScreen = true;
				FlxTween.cancelTweensOf(FlxG.camera);
				FlxTween.tween(FlxG.camera, {"scroll.x": FlxG.width * (2 / 3)}, .45, {ease: FlxEase.expoInOut});
			}
		}
		else
		{
			if (FlxG.mouse.overlaps(serveScreenOverlapSwitch) || !continueStuff)
			{
				isOnBrewingScreen = false;
				FlxTween.cancelTweensOf(FlxG.camera);
				FlxTween.tween(FlxG.camera, {"scroll.x": 0}, .45, {ease: FlxEase.expoInOut});
			}
		}

		handleSpriteActions();
	}

	function addIngredient(name:String)
	{
		if (countIngredients() >= MAX_INGREDIENTS)
			return;

		if (!curIngredients.exists(name))
		{
			curIngredients[name] = 1;
			#if debug
			trace(curIngredients);
			#end
		}
		else
		{
			curIngredients[name]++;
			#if debug
			trace(curIngredients);
			#end
		}
	}

	function removeIngredient(name:String)
	{
		if (!curIngredients.exists(name))
			return;
		curIngredients[name]--;
		if (curIngredients[name] == 0)
			curIngredients.remove(name);
		trace(curIngredients);
	}

	function getIngredients()
	{
		return [
			for (k => v in curIngredients)
				new IngredientObject(k, v)
		];
	}

	function setIngredients(m:Array<IngredientObject>)
	{
		var map:Map<String, Int> = [];
		for (k in m)
		{
			map[k.name] = k.count;
		}

		return curIngredients = map;
	}

	inline function makeIngredientHandler(ing:String)
	{
		return function(c:Int)
		{
			if (c == LEFT_CLICK_ACTION)
			{
				if (Assets.exists("assets/sounds/ingredients/" + ing + ".ogg"))
					FlxG.sound.play("assets/sounds/ingredients/" + ing + ".ogg");
				addIngredient(ing);
			}
			else
				removeIngredient(ing);
		}
	}

	function handleSpriteActions()
	{
		for (k => v in spriteActions)
		{
			if (FlxG.mouse.overlaps(k))
			{
				if (FlxG.mouse.justPressed)
					v(LEFT_CLICK_ACTION);
				else if (FlxG.mouse.justPressedRight)
				{
					v(RIGHT_CLICK_ACTION);
				}
			}
		}
	}

	function countIngredients()
	{
		var sum = 0;
		for (k => v in curIngredients)
		{
			sum += v;
		}
		return sum;
	}

	public function loadDrinkSprite(name:String, sprite:FlxSprite)
	{
		switch (name)
		{
			default:
				sprite.loadGraphic("assets/images/drinks/" + name + ".png");
		}
	}

	public function makeDrink(ingredients:Array<IngredientObject>)
	{
		var drinkExists = true;
		var wrongDrink = true;
		var d = null;
		for (k => v in DrinkSystem.drinks)
		{
			trace(DrinkSystem.drinks);
			if (!wrongDrink)
				break;
			trace("Current Drink: " + k);
			for (i in 0...v.ingredients.length)
			{
				var vI = v.ingredients[i];
				trace("Ingredient " + i + ": " + vI);

				if (ingredientContains(ingredients, vI) && v.style == curStyle)
				{
					wrongDrink = false;
				}
				else if (!ingredientContains(ingredients, vI) || v.style != curStyle)
				{
					trace("SEKUS");
					wrongDrink = true;
					break;
				}
			}
			d = k;
		}

		trace("YOTSUBA");
		if (!wrongDrink)
			trace("SO TRUE");
		return (wrongDrink ? null : curDrinkName = d);

		trace(curDrinkName);

		return null;
	}

	function ingredientContains(array:Array<IngredientObject>, value:IngredientObject)
	{
		for (x in array)
		{
			if (x.name == value.name && x.count == value.count)
				return true;
		}

		return false;
	}

	// ugly function
	inline function ing(x, y, g, i, ?newrow = false)
	{
		var _x = x;
		var _y = y;
		if (!newrow)
		{
			_x = ingredientSprites[ingredientSprites.length - 1].x + 120 * 1.5 + x;
			_y = ingredientSprites[ingredientSprites.length - 1].y + y;
		}
		var s = new FlxSprite().loadGraphic("assets/images/" + g + ".png");
		s.setGraphicSize(120, 120);
		s.updateHitbox();
		s.setPosition(_x, _y);
		foregroundSprites.add(s);
		ingredientSprites.push(s);
		spriteActions[s] = makeIngredientHandler(i);

		return s;
	}

	var customerIndex:Int = 0;
	var customerDialogue:String;

	var shiftDone = false;

	var continueStuff:Bool;

	function nextCustomer()
	{
		if (customerIndex >= day.customers.length - 1)
		{
			shiftDone = true;
			return;
		}

		continueStuff = false;

		customerIndex++;
		if (day.customers[customerIndex].dialogue != null)
		{
			customerDialogue = day.customers[customerIndex].dialogue;
			customer.onWalkEnd = () ->
			{
				if (dialogueBox == null)
				{
					dialogueBox = new DialogueBox(100, FlxG.height - 400, customerDialogue);
					dialogueBox.onEnd = () ->
					{
						continueStuff = true;
					}
					add(dialogueBox);
				}
				else
				{
					dialogueBox.loadFromFile(customerDialogue);
					dialogueBox.restart();
				}
			}
		}
		else
		{
			continueStuff = true;
			customer.onWalkEnd = null;
		}
		curCustName = day.customers[customerIndex].name;
		curDrinkName = "NoDrink";
		curIngredients.clear();
		wantedDrink = DrinkSystem.getDrinkByName(day.customers[customerIndex].drink);
		wantedDrink.style ?? wantedDrink.style = 0;
		if (day.customers[customerIndex].wantsIce)
		{
			curIngredients["Ice"] = 1;
		}
		if (day.customers[customerIndex].wantsOptionalAlcohol)
		{
			curIngredients["Whiskey"] = 1;
		}

		customer.changeCharacter(curCustName);
		customer.x = -customer.width;
		customer.walkTo(customerDefaultPos.x, customerDefaultPos.y, 3);
		trace(curCustName, wantedDrink);
		// customer.x = -customer.width;
	}
}
