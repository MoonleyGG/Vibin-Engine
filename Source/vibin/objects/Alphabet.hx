package vibin.objects;

import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import flixel.FlxG;

enum abstract AlphabetAlignment(String) from String to String
{
  var LEFT = "LEFT";
  var MIDDLE = "MIDDLE";
  var RIGHT = "RIGHT";
}

abstract AlphabetX(Dynamic) from Float from Int from AlphabetAlignment to Dynamic {
  @:from
  static public function fromString(s:String):AlphabetX {
    return cast s;
  }
}

class Alphabet extends FlxSpriteGroup
{
  public static var titleY1:Float = 200;
  public static var titleY2:Float = 260;
  public static var titleY3:Float = 320;

  public var text:String = "";
  public var spacing:Float = 0; 
  public var isBold:Bool = false;

  private static var activeTitles:Array<Alphabet> = [];

  public static function NewText(text:String, x:AlphabetX, y:Float, isBold:Bool = false):Alphabet
  {
    var alphabet = new Alphabet(text, isBold);
    alphabet.y = y;

    if (Std.isOfType(x, Float) || Std.isOfType(x, Int))
    {
      alphabet.x = cast(x, Float);
    }
    else
    {
      var align:AlphabetAlignment = cast(x, String);
      var screenCenterX:Float = FlxG.width / 2;

      switch (align)
      {
        case MIDDLE:
          alphabet.x = screenCenterX - (alphabet.width / 2);

        case RIGHT:
          alphabet.x = FlxG.width - alphabet.width;

        case LEFT | _:
          alphabet.x = 0;
      }
    }

    return alphabet;
  }

  public static function MakeTitleText(text:String, whichOne:Int):Alphabet
  {
    var targetY:Float = 0;
    if (whichOne == 1) targetY = titleY1;
    if (whichOne == 2) targetY = titleY2;
    if (whichOne == 3) targetY = titleY3;

    var titleObj = Alphabet.NewText(text, "MIDDLE", targetY, true);
    
    activeTitles.push(titleObj);

    if (FlxG.state != null) {
      FlxG.state.add(titleObj);
    }

    return titleObj;
  }

  public static function ClearTitleText():Void
  {
    for (title in activeTitles)
    {
      if (title != null)
      {
        if (FlxG.state != null) {
          FlxG.state.remove(title);
        }
        title.destroy();
      }
    }
    activeTitles = [];
  }

  public function new(text:String, isBold:Bool = false)
  {
    super();
    this.isBold = isBold;
    changeText(text);
  }

  public function changeText(newText:String):Void
  {
    this.text = newText;
    clear();

    var tex = FlxAtlasFrames.fromSparrow('assets/images/alphabet/alphabet.png', 'assets/images/alphabet/alphabet.xml');
    var curX:Float = 0;

    for (i in 0...newText.length)
    {
      var char = newText.charAt(i);

      if (char == " ")
      {
        curX += 40; 
        continue;
      }

      var characterSprite = new FlxSprite(curX, 0);
      characterSprite.frames = tex;

      characterSprite.antialiasing = true;

      if (char >= "0" && char <= "9")
      {
        var frameName = char + "0000";
        var graphFrame = tex.getByName(frameName);
        
        if (graphFrame != null)
          characterSprite.frame = graphFrame;
        else
          continue;
      }
      else
      {
        var prefix = getAnimPrefix(char);
        if (prefix == null) continue;

        characterSprite.animation.addByPrefix('idle', prefix, 24, true);
        characterSprite.animation.play('idle');
      }
      
      characterSprite.updateHitbox();
      add(characterSprite);

      curX += characterSprite.width + spacing;
    }
  }

  private function getAnimPrefix(char:String):Null<String>
  {
    if (char == "#") return "hashtag";
    if (char == "%") return "%";
    if (char == "$") return "dollarsign";

    var isLetter:Bool = (char >= "a" && char <= "z") || (char >= "A" && char <= "Z");

    if (isLetter)
    {
      if (isBold) return char.toUpperCase() + " bold";

      if (char >= "A" && char <= "Z")
        return char + " capital";
      else
        return char + " lowercase";
    }

    return null;
  }
}