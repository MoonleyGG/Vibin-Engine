package vibin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import vibin.backend.MusicBeatState; 
import vibin.util.SoundUtil;
import vibin.objects.Alphabet;
import flxanimate.FlxAnimate;
import flixel.util.FlxColor;

// the paths
import vibin.backend.Paths.*;

class MainMenuState extends MusicBeatState
{
    override public function create():Void
        {
            SoundUtil.PlayMusic("freakyMenu", true, true);
            super.create(); 
        }
        
        override function update(elapsed:Float)
            {
                super.update(elapsed);
            }
        }