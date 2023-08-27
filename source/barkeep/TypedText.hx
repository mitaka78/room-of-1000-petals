package barkeep;

import flixel.addons.text.FlxTypeText;

class TypedText extends FlxTypeText
{
	public var skipCallback:Void->Void;

	public function appendText(Text:String)
	{
		_finalText = text + Text;
		_typing = false;
		_erasing = false;
		paused = false;
		_waiting = false;
		_length = text.length;
	}

	public override function skip():Void
	{
		super.skip();
		if (skipCallback != null)
			skipCallback();
	}
}
