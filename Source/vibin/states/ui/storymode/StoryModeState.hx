package vibin.states.ui.storymode;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import util.fileUtils.TxtSplitter;

class StoryModeState extends MusicUIBeatState {
    override function create() {
        SoundUtil.playMusic("mainmenu", 1, true, true);
    }
}