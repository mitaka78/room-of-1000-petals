package;

import barkeep.Customer.CharacterSystem;
import barkeep.DrinkSystem;
import flixel.FlxG;
import flixel.FlxState;

class InitState extends FlxState
{
	public function new()
	{
		super();
	}

	override function create()
	{
		DrinkSystem.init();
		FlxG.switchState(new PlayState());
	}
}
