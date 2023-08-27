package barkeep;

import barkeep.Customer;
import haxe.Json;
import openfl.Assets;
import sys.FileSystem;

typedef Day =
{
	var dayNumber:Int;
	var dayName:String;
	var customers:Array<CustomerData>;
}
