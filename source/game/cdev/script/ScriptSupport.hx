package game.cdev.script;

import flixel.graphics.tile.FlxGraphicsShader;
import flixel.FlxCamera;
import openfl.filters.ShaderFilter;
import openfl.display.GraphicsShader;
import meta.states.MusicBeatState;
import sys.FileSystem;
import game.cdev.CDevMods.CDEV_FlxAxes;
import flixel.addons.display.FlxBackdrop;
import game.cdev.CDevMods.CDEV_BlendMode;
import openfl.display.BlendMode;
import game.cdev.CDevMods.CDEV_FlxTextBorderStyle;
import game.cdev.CDevMods.CDEV_FlxTextAlign;
import game.cdev.CDevMods.CDEV_FlxColor;
import meta.modding.ModPaths;
import lime.app.Application;
import game.CoolUtil;
import game.objects.BackgroundGirls;
import game.objects.BackgroundDancer;
import game.objects.Boyfriend;
import game.Conductor;
import game.objects.Note;
import game.objects.Character;
import game.Paths;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.util.FlxAxes;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import haxe.Json;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;
import lime.utils.Assets;
import flixel.system.FlxAssets;
import flixel.math.FlxMath;
import openfl.display.BitmapData;
import meta.states.PlayState;
import hscript.Expr;
import flixel.FlxG;
import flixel.FlxSprite;
import game.cdev.script.CDevScript.CDevModScript;

using StringTools;

class ScriptSupport
{
	public static var scripts:Array<CDevModScript> = [];
	public static var typedScripts:Array<CDevScript> = [];
	public static var currentMod:String = "FNF Test Mod";
	public static var playStated:PlayState = null;

	public static function parseSongConfig()
	{
		var songConf = SongConfScript.parse(currentMod, PlayState.SONG.song.toLowerCase());

		scripts = songConf.scripts;
		trace(songConf.scripts);
	}

	public static function setScriptDefaultVars(script:CDevScript, mod:String, ?song:String)
	{
		var curState:Dynamic = FlxG.state;
		playStated = curState;

		var superVar = {};
		if (Std.isOfType(script, HScript))
		{
			var hscript:HScript = cast script;
			for (k => v in hscript.hscript.variables)
			{
				Reflect.setField(superVar, k, v);
			}
		}
		script.setVariable("super", superVar);
		script.setVariable("mod", mod);
		script.setVariable("PlayState", playStated);
		script.setVariable("import", function(className:String)
		{
			var splitClassName = [for (e in className.split(".")) e.trim()];
			var realClassName = splitClassName.join(".");
			var cl = Type.resolveClass(realClassName);
			var en = Type.resolveEnum(realClassName);
			if (cl == null && en == null)
			{
				trace('Class / Enum at $realClassName does not exist.');
			}
			else
			{
				if (en != null)
				{
					var enumThingy = {};
					for (c in en.getConstructors())
					{
						Reflect.setField(enumThingy, c, en.createByName(c));
					}
					script.setVariable(splitClassName[splitClassName.length - 1], enumThingy);
				}
				else
				{
					// CLASS!!!!
					script.setVariable(splitClassName[splitClassName.length - 1], cl);
				}
			}
		});

		if (playStated != null)
		{
			script.setVariable("public", playStated.vars);
		}
		else
		{
			script.setVariable("public", {});
		}
		script.setVariable("trace", function(text)
		{
			try
			{
				script.trace(text);
			}
			catch (e)
			{
				trace(e);
			}
		});
		script.setVariable("controls", playStated.controls);
		script.setVariable("add", function(obj)
		{
			playStated.add(obj);
		});
		script.setVariable("remove", function(obj)
		{
			playStated.remove(obj);
		});
		script.setVariable("insert", function(pos, obj)
		{
			playStated.insert(pos, obj);
		});
		script.setVariable("PlayState", PlayState);
		script.setVariable("FlxSprite", FlxSprite);
		script.setVariable("BitmapData", BitmapData);
		script.setVariable("FlxG", FlxG);
		script.setVariable("Paths", new ModPaths(mod));
		script.setVariable("Std", Std);
		script.setVariable("Math", Math);
		script.setVariable("FlxMath", FlxMath);
		script.setVariable("FlxAssets", FlxAssets);
		script.setVariable("Assets", Assets);
		script.setVariable("PlayState_Config", PlayStateConfig);
		script.setVariable("ScriptSupport", ScriptSupport);
		script.setVariable("Note", Note);
		script.setVariable("Character", Character);
		script.setVariable("Conductor", Conductor);
		script.setVariable("StringTools", StringTools);
		script.setVariable("FlxSound", FlxSound);
		script.setVariable("FlxEase", FlxEase);
		script.setVariable("FlxTween", FlxTween);
		script.setVariable("FlxColor", CDEV_FlxColor);
		script.setVariable("BlendMode", CDEV_BlendMode);
		script.setVariable("FlxBackdrop", FlxBackdrop);
		script.setVariable("Boyfriend", Boyfriend);
		script.setVariable("FlxTypedGroup", FlxTypedGroup);
		script.setVariable("BackgroundDancer", BackgroundDancer);
		script.setVariable("BackgroundGirls", BackgroundGirls);
		script.setVariable("FlxTimer", FlxTimer);
		script.setVariable("Json", Json);
		script.setVariable("CoolUtil", CoolUtil);
		script.setVariable("FlxTypeText", FlxTypeText);
		script.setVariable("FlxText", FlxText);
		script.setVariable("FlxTextAlign", CDEV_FlxTextAlign);
		script.setVariable("FlxTextBorderStyle", CDEV_FlxTextBorderStyle);
		script.setVariable("FlxAxes", CDEV_FlxAxes);
		script.setVariable("Rectangle", Rectangle);
		script.setVariable("Point", Point);
		script.setVariable("Window", Application.current.window);
		script.setVariable("CDevConfig", CDevConfig.saveData); //i can't let the players access the entire CDevConfig class.
		script.setVariable("GraphicsShader", GraphicsShader);
		script.setVariable("FlxGraphicsShader", FlxGraphicsShader);
		script.setVariable("ShaderFilter", ShaderFilter);
		script.setVariable("FlxCamera", FlxCamera);

		// oh god
		/*script.setVariable("importScript", function(scriptname)
		{
			var scriptfile:String = scriptname;
			if (scriptfile.endsWith(".hx")) // no need to add .hx ext
				scriptfile = scriptfile.substr(0, scriptfile.length-3);

			trace("\n\n" + script.fileName + ".hx is trying to import " + scriptname);

			var scriptPath = Paths.mods(mod + "/data/charts/" + PlayState.SONG.song + '/$scriptname.hx');
			trace("script path: " + scriptPath);
			if (FileSystem.exists(scriptPath))
			{
				trace("script exists, adding variable to " + script.fileName);
				var cdev:CDevScript = CDevScript.create(scriptPath);
				cdev.loadFile(scriptPath);
				setScriptDefaultVars(cdev, mod, PlayState.SONG.song);
				script.setVariable(scriptname, new CDevCustomScript(cdev));
			}
			else
			{
				script.trace("Script with name: \"" + scriptname + ".hx\" does not exist.");
			}
		});*/

		script.mod = mod;
		//trace('initfinished');
	}

	public static function getExprFromPath(path:String, critical:Bool = false, ea:CDevScript):hscript.Expr
	{
		var parser = new hscript.Parser();
		parser.allowTypes = true;
		var ast:Expr = null;
		try
		{
			#if sys
			ast = parser.parseString(sys.io.File.getContent(path));
			#else
			trace("No sys support detected.");
			#end
		}
		catch (ex)
		{
			trace(ex);
			var ext = Std.string(ex);
			var line = parser.line;
			var gay:String = 'An error occured while parsing the file located at "$path".\r\n$ext at $line';
			if (!openfl.Lib.application.window.fullscreen)
				openfl.Lib.application.window.alert(gay);
			trace(gay);
			ea.error = true;
		}
		return ast;
	}
}
