package vibin.states.editors.charteditorstate;

import flixel.FlxG;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign; // Added for centering text alignment
import vibin.backend.MusicBeatState;
import vibin.util.FileUtil;

class ChartEditorState extends MusicBeatState
{
    public var song:String = "bopeebo";
    public var player:String = "Boyfriend";
    public var opponent:String = "Dad";
    public var bpmText:String = "100";
    
    // The customizable link variable
    public var guideLink:String = "https://example.com/your-guide"; 

    private var activeField:Int = 0;
    private var playerField:TextField;
    private var opponentField:TextField;
    private var bpmField:TextField;
    private var infoText:TextField;
    
    // The new link text field
    private var linkField:TextField; 

    override public function create():Void
    {
        super.create();

        createUiFields();
        refreshFields();

        if (FlxG.stage != null)
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardDown);
    }

    private function createUiFields():Void
    {
        var labelFormat = new TextFormat("_sans", 24, 0xFFFFFF, false);
        var infoFormat = new TextFormat("_sans", 18, 0xCCCCCC, false);

        playerField = createTextField(20, 20, 760, 42, labelFormat);
        opponentField = createTextField(20, 80, 760, 42, labelFormat);
        bpmField = createTextField(20, 140, 760, 42, labelFormat);
        infoText = createTextField(20, 200, 760, 120, infoFormat);
        infoText.multiline = true;
        infoText.wordWrap = true;
        infoText.selectable = false;

        FlxG.stage.addChild(playerField);
        FlxG.stage.addChild(opponentField);
        FlxG.stage.addChild(bpmField);
        FlxG.stage.addChild(infoText);

        // --- NEW: Creating the Big Clickable Link in the Center ---
        
        // Define format: Size 32, White (0xFFFFFF), Centered alignment
        var linkFormat = new TextFormat("_sans", 32, 0xFFFFFF, true);
        linkFormat.align = TextFormatAlign.CENTER;

        // Position it right in the center of the FlxG game dimensions
        var fieldWidth:Float = 800;
        var fieldHeight:Float = 100;
        var centerX:Float = (FlxG.width - fieldWidth) / 2;
        var centerY:Float = (FlxG.height - fieldHeight) / 2;

        linkField = new TextField();
        linkField.defaultTextFormat = linkFormat;
        linkField.x = centerX;
        linkField.y = centerY;
        linkField.width = fieldWidth;
        linkField.height = fieldHeight;
        linkField.multiline = true;
        linkField.wordWrap = true;
        linkField.selectable = false;
        
        // These two properties are crucial for making links clickable in OpenFL
        linkField.mouseEnabled = true; 
        
        // Set up the text using basic HTML anchor tags wrapped around your link variable
        linkField.htmlText = "chart editor isnt available yet, use this guide + converter:<br><a href='" + guideLink + "'><u>" + guideLink + "</u></a>";

        FlxG.stage.addChild(linkField);
        // -----------------------------------------------------------
    }

    private function createTextField(x:Float, y:Float, width:Float, height:Float, format:TextFormat):TextField
    {
        var field = new TextField();
        field.defaultTextFormat = format;
        field.x = x;
        field.y = y;
        field.width = width;
        field.height = height;
        field.background = true;
        field.backgroundColor = 0x223344;
        field.border = true;
        field.borderColor = 0x667788;
        field.selectable = false;
        field.mouseEnabled = false;
        return field;
    }

    private function refreshFields():Void
    {
        playerField.text = "Player: " + player + (activeField == 0 ? " <" : "");
        opponentField.text = "Opponent: " + opponent + (activeField == 1 ? " <" : "");
        bpmField.text = "BPM: " + bpmText + (activeField == 2 ? " <" : "");
        infoText.text = "TAB = switch field\nBACKSPACE = delete char\nENTER = save metadata.xml\nESC = return to play state";
        
        // Updates the link text dynamically if guideLink ever changes mid-state
        if (linkField != null) {
            linkField.htmlText = "chart editor isnt available yet, use this guide + converter:<br><a href='" + guideLink + "'><u>" + guideLink + "</u></a>";
        }
    }

    private function keyboardDown(event:KeyboardEvent):Void
    {
        switch (event.keyCode)
        {
            case Keyboard.TAB:
                activeField = (activeField + 1) % 3;
                event.preventDefault();
            case Keyboard.BACKSPACE:
                if (activeField == 0 && player.length > 0) player = player.substring(0, player.length - 1);
                else if (activeField == 1 && opponent.length > 0) opponent = opponent.substring(0, opponent.length - 1);
                else if (activeField == 2 && bpmText.length > 0) bpmText = bpmText.substring(0, bpmText.length - 1);
                event.preventDefault();
            case Keyboard.ENTER:
                exportMetadata();
                event.preventDefault();
            case Keyboard.ESCAPE:
                cleanupStage();
                FlxG.switchState(new vibin.states.playstate.PlayState());
                event.preventDefault();
            default:
                if (event.charCode > 0)
                {
                    var char = String.fromCharCode(event.charCode);
                    if (activeField == 0) player += char;
                    else if (activeField == 1) opponent += char;
                    else if (activeField == 2 && ~/^[0-9]$/.match(char)) bpmText += char;
                }
        }

        refreshFields();
    }

    private function exportMetadata():Void
    {
        var bpmValue:Int = bpmText.length > 0 ? Std.parseInt(bpmText) : 100;
        if (bpmValue <= 0) bpmValue = 100;

        var xmlContent = '<metadata>\n\t<player>' + player + '</player>\n\t<opponent>' + opponent + '</opponent>\n\t<bpm>' + bpmValue + '</bpm>\n</metadata>';

        FileUtil.saveTextFile(xmlContent, 'metadata.xml', function(savedName:String):Void
        {
            trace('Exported metadata to ' + savedName);
        }, function():Void
        {
            trace('Metadata save canceled.');
        });
    }

    private function cleanupStage():Void
    {
        if (FlxG.stage != null)
        {
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardDown);
            if (linkField != null && FlxG.stage.contains(linkField))
                FlxG.stage.removeChild(linkField);
        }
    }

    override public function destroy():Void
    {
        cleanupStage();
        super.destroy();
    }
}