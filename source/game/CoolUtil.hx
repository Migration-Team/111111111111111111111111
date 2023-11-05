package game;

import lime.utils.Assets;
import flixel.FlxG;

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = ['easy', 'normal', 'hard']; //dumb
	public static var songDifficulties:Array<String> = [];
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var diffFormat:Array<String> = ['-easy', '', '-hard'];

	public static function difficultyString():String
	{
		return difficultyArray[meta.states.PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	
	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
}
