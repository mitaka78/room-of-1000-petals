package dialogue;

import Type.ValueType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import haxe.Json;
import ink.runtime.Path;
import ink.runtime.Story;
import lime.utils.Assets;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	public var story:Story;

	public var box:FlxSprite;
	public var nameText:FlxText;
	public var dialogueText:FlxTypeText;

	// public var choiceButtons:Array<ChoiceButton>

	public function new(?x:Float, ?y:Float, ?file:String)
	{
		super(x, y);
		if (file != null)
		{
			loadFromFile(file);
		}

		makeSprites();
		var s = story.Continue();
		dialogueText.resetText(s);
		dialogueText.start(1 / 12);
		finishedTalking = false;
	}

	function makeSprites()
	{
		box = new FlxSprite(0, 0).makeGraphic(300, 200, FlxColor.GRAY);
		dialogueText = new FlxTypeText(18, 18, Std.int(box.width - 18), '', 14);
		add(box);
		add(dialogueText);
		dialogueText.completeCallback = () ->
		{
			finishedTalking = true;
		}
	}

	var finishedTalking:Bool = false;
	var ended = false;

	public var onEnd:Void->Void;

	override function update(elapsed:Float)
	{
		if (!ended)
		{
			dialogue();
		}
		super.update(elapsed);
	}

	public function dialogue()
	{
		var E = FlxG.keys.justPressed.ENTER;

		if (E)
		{
			trace("Epressed");
			if (!finishedTalking)
			{
				dialogueText.skip();
				finishedTalking = true;
			}
			else
			{
				trace("diddn'finish talking");
				if (story.canContinue)
				{
					var s = story.Continue();
					trace("Go...whatever\n", s);
					dialogueText.resetText(s);
					dialogueText.start(1 / 12);
					finishedTalking = false;
				}
				else if (!story.canContinue && story.currentChoices.length == 0)
				{
					if (onEnd != null)
						onEnd();
					ended = true;
				}
			}
		}

		if (ended)
		{
			box.kill();
			dialogueText.kill();
			// nameText.kill();
		}
	}

	public function loadFromFile(file:String)
	{
		story = new Story(Assets.getText(file));
	}

	public function restart()
	{
		trace("DialogueBox:REstart");
		ended = false;
		box.revive();
		dialogueText.revive();
		dialogueText.text = "";
		dialogueText.resetText(story.Continue());
		dialogueText.start(1 / 12);
		finishedTalking = false;
	}

	// im so sorry for the fuckery inside these functions

	public function correctDrink()
	{
		var exists = true;

		try
		{
			story.ContentAtPath(Path.createFromString("incorrect_drink"));
		}
		catch (e)
		{
			exists = false;
		}

		if (exists)
		{
			story.ChoosePathString("correct_drink");
			restart();
		}
		else
		{
			onEnd();
		}
	}

	public function incorrectDrink()
	{
		var exists = true;

		try
		{
			story.ContentAtPath(Path.createFromString("incorrect_drink"));
		}
		catch (e)
		{
			exists = false;
		}

		if (exists)
		{
			story.ChoosePathString("incorrect_drink");
			restart();
		}
		else
		{
			onEnd();
		}
	}
}
