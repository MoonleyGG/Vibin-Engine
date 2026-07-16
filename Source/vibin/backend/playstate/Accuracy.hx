package vibin.backend.playstate;

class Accuracy {
    public var accuracy:Int = 0;
    public var accuracyPercent:Float = 0; // make sure to always round this down

    /*
    * basically it does it does the Accuracy variable / total song notes
    * so say i get 200 sicks 50 goods it returns 250 and ofc there is 250 total song notes
    * so it does 250 / 250 = 1 then times it by 100 to get the total Accuracy
    */
    public var ratings:Map<String, Int> = [
        "sick" => 1,
        "good" => 1,
        "bad" => 0,
        "shit" => 0,
        "miss" => -1
    ];

    public function new() {}

    public function calculate(totalNotes:Int):Float
    {
        if (totalNotes <= 0)
            return 0;

        accuracyPercent = Math.max(0, Math.min(1, accuracy / totalNotes)) * 100;
        return Math.floor(accuracyPercent * 100) / 100;
    }
}