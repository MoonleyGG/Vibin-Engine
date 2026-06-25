package vibin.objects;

import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import flixel.FlxG;

/**
 * An enum abstract defining anchor alignments for the Alphabet component.
 */
enum abstract AlphabetAlignment(String) from String to String
{
  var LEFT = "LEFT";
  var MIDDLE = "MIDDLE";
  var RIGHT = "RIGHT";
}

/**
 * A custom abstract that allows the X parameter to accept either a Float number or an AlphabetAlignment.
 */
abstract AlphabetX(Dynamic) from Float from Int from AlphabetAlignment to Dynamic {
  @:from
  static public function fromString(s:String):AlphabetX {
    return cast s;
  }
}

class Alphabet extends FlxSpriteGroup
{
  // -----------------------------------------------------------------
  // TWEAK THESE VALUES FOR QUICK TITLE HEIGHT ADJUSTMENTS:
  // -----------------------------------------------------------------
  public static var titleY1:Float = 200; // Y position when whichOne is 1
  public static var titleY2:Float = 260; // Y position when whichOne is 2
  public static var titleY3:Float = 320;
  // -----------------------------------------------------------------

  public var text:String = "";
  public var spacing:Float = 0; 
  public var isBold:Bool = false;

  // Track any active title text instances created via MakeTitleText
  private static var activeTitles:Array<Alphabet> = [];

  /**
   * Helper factory to create, build, and anchor-align an Alphabet text group.
   * @param text The string to display.
   * @param x Can be a Float number (e.g. 150) or an alignment string ("LEFT", "MIDDLE", "RIGHT").
   * @param y The vertical Y position of the text.
   * @param isBold If true, letters enforce the [LETTER] bold asset variant. Numbers stay normal.
   */
  public static function NewText(text:String, x:AlphabetX, y:Float, isBold:Bool = false):Alphabet
  {
    var alphabet = new Alphabet(text, isBold);
    alphabet.y = y;

    // Check if x is a raw number value
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

  /**
   * Creates a bold, horizontally-centered title line preset at specific row rules.
   * @param text The text string to build out.
   * @param whichOne If 1, sets Y to titleY1. If 2, sets Y to titleY2.
   * @return The generated Alphabet object.
   */
  public static function MakeTitleText(text:String, whichOne:Int):Alphabet
  {
    var targetY:Float = 0;
    if (whichOne == 1) targetY = titleY1;
    if (whichOne == 2) targetY = titleY2;
    if (whichOne == 3) targetY = titleY3;

    // Forces isBold to ALWAYS be true for titles
    var titleObj = Alphabet.NewText(text, "MIDDLE", targetY, true);
    
    // Store it inside our internal tracking list
    activeTitles.push(titleObj);

    // Automatically add it to the active screen state manager context
    if (FlxG.state != null) {
      FlxG.state.add(titleObj);
    }

    return titleObj;
  }

  /**
   * Destroys and safely removes all title text layers currently on screen.
   */
  public static function ClearTitleText():Void
  {
    for (title in activeTitles)
    {
      if (title != null)
      {
        // Safely wipe out graphics memory allocation references
        if (FlxG.state != null) {
          FlxG.state.remove(title);
        }
        title.destroy();
      }
    }
    // Wipe the reference array tracking clear
    activeTitles = [];
  }

  public function new(text:String, isBold:Bool = false)
  {
    super();
    this.isBold = isBold;
    changeText(text);
  }

  /**
   * Clears old child letter sprites and builds a new line utilizing the texture atlas assets.
   */
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