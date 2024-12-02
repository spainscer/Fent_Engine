package;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.graphics.frames.FlxAtlasFrames;

import openfl.display.BitmapData;
import openfl.system.System;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetType;
import openfl.media.Sound;

import lime.utils.Assets;
import haxe.Json;

@:access(openfl.display.BitmapData)
class Paths {
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
    inline public static var VIDEO_EXT = "mp4";

    // Tracked assets
    public static var localTrackedAssets:Array<String> = [];
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];
    static public var currentLevel:String;

    /**
     * Clears unused memory for non-local assets.
     */
    public static function clearUnusedMemory() {
        for (key in currentTrackedAssets.keys()) {
            if (!localTrackedAssets.contains(key)) {
                destroyGraphic(currentTrackedAssets.get(key));
                currentTrackedAssets.remove(key);
            }
        }
        System.gc();
    }

    /**
     * Clears all stored memory.
     */
    @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
    public static function clearStoredMemory() {
        for (key in FlxG.bitmap._cache.keys()) {
            if (!currentTrackedAssets.exists(key)) {
                destroyGraphic(FlxG.bitmap.get(key));
            }
        }

        for (key => asset in currentTrackedSounds) {
            if (!localTrackedAssets.contains(key)) {
                Assets.cache.clear(key);
                currentTrackedSounds.remove(key);
            }
        }

        localTrackedAssets = [];
        #if !html5 openfl.Assets.cache.clear("songs"); #end
    }

    /**
     * Frees GPU memory used by a graphic.
     */
    inline static function destroyGraphic(graphic:FlxGraphic) {
        if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null) {
            graphic.bitmap.__texture.dispose();
        }
        FlxG.bitmap.remove(graphic);
    }

    /**
     * Sets the current level.
     */
    static public function setCurrentLevel(name:String) {
        currentLevel = name.toLowerCase();
    }

    /**
     * Resolves the full path of a file based on its type and folder.
     */
    public static function getPath(file:String, ?type:AssetType = TEXT, ?parentFolder:String = null):String {
        if (parentFolder != null) {
            return getFolderPath(file, parentFolder);
        }
        if (currentLevel != null && currentLevel != 'shared') {
            var levelPath = getFolderPath(file, currentLevel);
            if (OpenFlAssets.exists(levelPath, type)) {
                return levelPath;
            }
        }
        return getSharedPath(file);
    }

    inline static public function getFolderPath(file:String, folder:String = "shared"):String {
        return 'assets/$folder/$file';
    }

    inline static public function getSharedPath(file:String = ''):String {
        return 'assets/shared/$file';
    }

    // Specific file type resolvers
    inline static public function txt(key:String, ?folder:String):String {
        return getPath('data/$key.txt', TEXT, folder);
    }

    inline static public function json(key:String, ?folder:String):String {
        return getPath('data/$key.json', TEXT, folder);
    }

    inline static public function video(key:String):String {
        return 'assets/videos/$key.$VIDEO_EXT';
    }

    /**
     * Retrieves a sound asset.
     */
    inline static public function sound(key:String, ?modsAllowed:Bool = true):Sound {
        return returnSound('sounds/$key', modsAllowed);
    }

    inline static public function music(key:String, ?modsAllowed:Bool = true):Sound {
        return returnSound('music/$key', modsAllowed);
    }

    /**
     * Retrieves an image asset.
     */
    static public function image(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxGraphic {
        key = Language.getFileTranslation('images/$key') + '.png';
        if (currentTrackedAssets.exists(key)) {
            localTrackedAssets.push(key);
            return currentTrackedAssets.get(key);
        }
        return cacheBitmap(key, parentFolder, null, allowGPU);
    }

    /**
     * Caches a bitmap.
     */
    public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic {
        if (bitmap == null) {
            var file = getPath(key, IMAGE, parentFolder);
            if (OpenFlAssets.exists(file, IMAGE)) {
                bitmap = OpenFlAssets.getBitmapData(file);
            } else {
                trace('Bitmap not found: $file');
                return null;
            }
        }

        if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap.image != null) {
            prepareGPUCache(bitmap);
        }

        var graphic = FlxGraphic.fromBitmapData(bitmap, false, key);
        graphic.persist = true;
        graphic.destroyOnNoUse = false;
        currentTrackedAssets.set(key, graphic);
        localTrackedAssets.push(key);
        return graphic;
    }

    /**
     * Prepares GPU cache for a bitmap.
     */
    private static function prepareGPUCache(bitmap:BitmapData) {
        bitmap.lock();
        if (bitmap.__texture == null) {
            bitmap.image.premultiplied = true;
            bitmap.getTexture(FlxG.stage.context3D);
        }
        bitmap.disposeImage();
        bitmap.image = null;
    }

    /**
     * Retrieves a sound, caching if necessary.
     */
    public static function returnSound(key:String, ?path:String, ?modsAllowed:Bool = true):Sound {
        var file = getPath(Language.getFileTranslation(key) + '.$SOUND_EXT', SOUND, path);
        if (!currentTrackedSounds.exists(file)) {
            #if sys
            if (FileSystem.exists(file)) {
                currentTrackedSounds.set(file, Sound.fromFile(file));
            }
            #else
            if (OpenFlAssets.exists(file, SOUND)) {
                currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
            } else {
                trace('Sound not found: $key');
                return FlxAssets.getSound('flixel/sounds/beep');
            }
            #end
        }
        localTrackedAssets.push(file);
        return currentTrackedSounds.get(file);
    }
}