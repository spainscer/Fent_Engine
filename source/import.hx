#if !macro
//Discord API
#if DISCORD_SUPPORT
import funkster.backend.system.Discord;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import Paths;
// import funkster.backend.util.Controls;
// import funkster.backend.util.CoolUtil;
// import funkster.menus.MusicBeatState;
// import funkster.menus.submenus.MusicBeatSubstate;
// import funkster.backend.Options;
// import funkster.backend.util.Conductor;
// import funkster.objects.stages.BaseStage;
// import funkster.backend.Difficulty;
// import funkster.backend.languages.Language;

// import funkster.objects.Alphabet;
// import funkster.objects.BGSprite;

import funkster.PlayState;
//import states.LoadingState;

// #if flxanimate
// import flxanimate.*;
// import flxanimate.PsychFlxAnimate as FlxAnimate;
// #end

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;
#end