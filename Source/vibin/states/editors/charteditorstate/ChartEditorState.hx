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
    public var keyCount:String = "4";

    private var activeField:Int = 0;
    private var playerField:TextField;
    private var opponentField:TextField;
    private var bpmField:TextField;
    private var keyCountField:TextField;

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

        playerField = createTextField(20, 20, 760, 42, labelFormat);
        opponentField = createTextField(20, 80, 760, 42, labelFormat);
        bpmField = createTextField(20, 140, 760, 42, labelFormat);
        keyCountField = createTextField(20, 200, 760, 42, labelFormat);

        FlxG.stage.addChild(playerField);
        FlxG.stage.addChild(opponentField);
        FlxG.stage.addChild(bpmField);
        FlxG.stage.addChild(keyCountField);

        // Position it right in the center of the FlxG game dimensions
        var fieldWidth:Float = 800;
        var fieldHeight:Float = 100;
        var centerX:Float = (FlxG.width - fieldWidth) / 2;
        var centerY:Float = (FlxG.height - fieldHeight) / 2;
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
        keyCountField.text = "Key Count: " + keyCount + (activeField == 3 ? " <" : "");
    }

private function keyboardDown(event:KeyboardEvent):Void
{
    switch (event.keyCode)
    {
        case Keyboard.TAB:
            activeField = (activeField + 1) % 4;
            event.preventDefault();

        case Keyboard.BACKSPACE:
            switch (activeField)
            {
                case 0:
                    if (player.length > 0)
                        player = player.substring(0, player.length - 1);

                case 1:
                    if (opponent.length > 0)
                        opponent = opponent.substring(0, opponent.length - 1);

                case 2:
                    if (bpmText.length > 0)
                        bpmText = bpmText.substring(0, bpmText.length - 1);

                case 3:
                    if (keyCount.length > 0)
                        keyCount = keyCount.substring(0, keyCount.length - 1);
            }

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

                switch (activeField)
                {
                    case 0:
                        player += char;

                    case 1:
                        opponent += char;

                    case 2:
                        if (~/^[0-9]$/.match(char))
                            bpmText += char;

                    case 3:
                        if (~/^[0-9]$/.match(char))
                            keyCount += char;
                }
            }
    }

    refreshFields();
}

private function exportMetadata():Void
{
    var bpmValue:Int = bpmText.length > 0 ? Std.parseInt(bpmText) : 100;
    if (bpmValue <= 0)
        bpmValue = 100;

    var keyCountValue:Int = keyCount.length > 0 ? Std.parseInt(keyCount) : 4;
    if (keyCountValue <= 0)
        keyCountValue = 4;

    var xmlContent =
        '<metadata>\n' +
        '\t<player>' + player + '</player>\n' +
        '\t<opponent>' + opponent + '</opponent>\n' +
        '\t<bpm>' + bpmValue + '</bpm>\n' +
        '\t<keyCount>' + keyCountValue + '</keyCount>\n' +
        '</metadata>';

    FileUtil.saveTextFile(xmlContent, "metadata.xml",
        function(savedName:String):Void
        {
            trace("Exported metadata to " + savedName);
        },
        function():Void
        {
            trace("Metadata save canceled.");
        });
}

    private function cleanupStage():Void
    {
        if (FlxG.stage != null)
        {
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardDown);
        }
    }

    override public function destroy():Void
    {
        cleanupStage();
        super.destroy();
    }
}