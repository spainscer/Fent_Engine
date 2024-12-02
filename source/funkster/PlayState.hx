package funkster;

import flixel.FlxState;

class PlayState extends FlxState {
    public function new()
    {
        var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('game/ui/notes/skin/Default'));
        add(sprite);
        super();
    }
}