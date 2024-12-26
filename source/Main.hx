package;

import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import funkster.PlayState;

#if linux
import lime.graphics.Image;
#end

#if desktop
import funkster.backend.util.ALSoftConfig; // Prevent DCE removal
#end

#if DISCORD_SUPPORT
import funkster.backend.system.Discord;
#end

#if CRASH_HANDLER_SUPPORT
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

class Main extends Sprite {
    var game = {
        width: 1280,
        height: 720,
        initialState: PlayState,
        zoom: -1.0,
        framerate: 60,
        skipSplash: true,
        startFullscreen: false
    };

    //public static var fpsVar: FPSCounter;

    public static function main(): Void {
    Lib.current.addChild(new Main());
  }

    public function new() {
    super();
        stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init);

        #if VIDEO_SUPPORT
        hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
        #end
    }

    private function init(e: Event = null): Void {
      removeEventListener(Event.ADDED_TO_STAGE, init);
    setupGame();
  }

    private function setupGame(): Void {
        adjustGameDimensions();
        initializeGameSystems();

        addChild(new FlxGame(
            game.width, 
            game.height, 
            game.initialState, 
            #if (flixel < "5.0.0") game.zoom, #end 
            game.framerate, 
            game.framerate, 
            game.skipSplash, 
            game.startFullscreen
        ));

        setupAdditionalFeatures();
    }

    private function adjustGameDimensions(): Void {
        var stageWidth = Lib.current.stage.stageWidth;
        var stageHeight = Lib.current.stage.stageHeight;

        if (game.zoom == -1.0) {
            var ratioX = stageWidth / game.width;
            var ratioY = stageHeight / game.height;
            game.zoom = Math.min(ratioX, ratioY);
            game.width = Math.ceil(stageWidth / game.zoom);
            game.height = Math.ceil(stageHeight / game.zoom);
        }
    }

    private function initializeGameSystems(): Void {
        FlxG.save.bind('fent', CoolUtil.getSavePath());
        //Highscore.load();
        Controls.instance = new Controls();
       // ClientPrefs.loadDefaultKeys();
    }

    private function setupAdditionalFeatures(): Void {
        // #if !mobile
        // setupDesktopFeatures();
        // #end

        #if linux
        Lib.current.stage.window.setIcon(Image.fromFile("icon.png"));
        #end

        #if html5
        FlxG.autoPause = false;
        FlxG.mouse.visible = false;
        #end

        configureFlxG();

        #if DISCORD_SUPPORT
        DiscordClient.prepare();
        #end

        FlxG.signals.gameResized.add(handleGameResize);

        #if CRASH_HANDLER_SUPPORT
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
        #end
    }

    // private function setupDesktopFeatures(): Void {
    //     fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
    //     addChild(fpsVar);
    //     Lib.current.stage.align = "tl";
    //     Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
    //     if (fpsVar != null) {
    //         fpsVar.visible = ClientPrefs.data.showFPS;
    //     }
    // }

    private function configureFlxG(): Void {
        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 60;
        FlxG.keys.preventDefaultKeys = [TAB];
    }

    private function handleGameResize(w, h): Void {
        if (FlxG.cameras != null) {
            for (cam in FlxG.cameras.list) {
                if (cam != null && cam.filters != null) {
                    resetSpriteCache(cam.flashSprite);
                }
            }
        }
        if (FlxG.game != null) {
            resetSpriteCache(FlxG.game);
        }
    }

    static function resetSpriteCache(sprite: Sprite): Void {
        @:privateAccess {
            sprite.__cacheBitmap = null;
            sprite.__cacheBitmapData = null;
        }
    }

  // Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER_SUPPORT
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "FentEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
    errMsg += "\nPlease report this error to the GitHub page: https://github.com/spainscer/Fent_Engine/issues\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_SUPPORT
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}