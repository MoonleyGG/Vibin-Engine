package vibin.systems.playstate;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import vibin.objects.playstate.Note;
import vibin.objects.playstate.StrumNote;
import vibin.states.playstate.PlayState;

class InputSystem
{
    // ms windows used to judge a hit, from tightest to loosest.
    // Anything further away than badWindow can't be hit at all.
    public static var sickWindow:Float = 45;
    public static var goodWindow:Float = 90;
    public static var badWindow:Float = 135;

    // how much player health drains each time a CPU/opponent strumline lands a hit
    public static var opponentDrain:Float = 0.02;

    // ms the bot strumline "reacts" ahead of the note's exact strumTime.
    // Was set to 30 to compensate for what turned out to be a real
    // position/alignment bug rather than a genuine timing issue - now that
    // that's fixed, this should need little to no adjustment. Nudge it if
    // it still feels off after testing.
    public static var botHitOffset:Float = 0;

    // alternate keybinds per column direction
    public static var keyBinds:Map<String, Array<FlxKey>> = [
        "left"  => [FlxKey.LEFT, FlxKey.A],
        "down"  => [FlxKey.DOWN, FlxKey.S],
        "up"    => [FlxKey.UP, FlxKey.W],
        "right" => [FlxKey.RIGHT, FlxKey.D]
    ];

    // notes currently being held down as a sustain, keyed by "strumline:column"
    static var heldNotes:Map<String, Note> = new Map();

    /**
     * Call once per frame from PlayState.update(), after note positions
     * have been refreshed for this frame. songPos is the current song
     * time in ms (same clock strumTime is measured against).
     */
    public static function update(state:PlayState, songPos:Float):Void
    {
        handleBotStrumlines(state, songPos);
        handlePlayerKeys(state, songPos);
        handleHolds(state, songPos);
        sweepMisses(state, songPos);
    }

    /**
     * Clears held-note state. Call from PlayState.create() so a fresh
     * song doesn't inherit stale holds from a previous attempt.
     */
    public static function reset():Void
    {
        heldNotes = new Map();
    }

    // ---- CPU-controlled strumlines (anything that isn't the player) just auto-hit on time ----
    static function handleBotStrumlines(state:PlayState, songPos:Float):Void
    {
        for (strumIndex in 0...state.strumlines)
        {
            if (strumIndex == state.playerStrumlineIndex)
                continue;

            for (note in state.notes.copy())
            {
                if (note.strumlineIndex != strumIndex || note.wasHit || note.tooLate)
                    continue;

                if (songPos + botHitOffset < note.strumTime)
                    continue;

                note.wasHit = true;
                state.health -= opponentDrain;

                if (!note.isSustain)
                {
                    playAnim(state, strumIndex, note.columnIndex, "hit");
                    removeNote(state, note);
                }
                else
                {
                    beginHold(state, strumIndex, note.columnIndex);
                    note.hideHead();
                    // fully bot-controlled holds never get released early -
                    // handleHolds() below will end this one cleanly at sustainEnd
                    heldNotes.set(strumIndex + ":" + note.columnIndex, note);
                }
            }
        }
    }

    // ---- player input ----
    static function handlePlayerKeys(state:PlayState, songPos:Float):Void
    {
        for (columnIndex in 0...state.keyCount)
        {
            var direction = state.keyDirections[columnIndex % state.keyDirections.length].toLowerCase();
            var binds = keyBinds.exists(direction) ? keyBinds.get(direction) : [];

            if (binds.length == 0 || !FlxG.keys.anyJustPressed(binds))
                continue;

            var closest = findClosestHittableNote(state, songPos, state.playerStrumlineIndex, columnIndex);

            if (closest != null)
                registerHit(state, closest, songPos);
            // else: ghost tap (pressed with nothing in range) - no penalty for now
        }
    }

    static function findClosestHittableNote(state:PlayState, songPos:Float, strumIndex:Int, columnIndex:Int):Note
    {
        var closest:Note = null;
        var closestDiff:Float = badWindow + 1;

        for (note in state.notes)
        {
            if (note.strumlineIndex != strumIndex || note.columnIndex != columnIndex)
                continue;

            if (note.wasHit || note.tooLate)
                continue;

            var diff = Math.abs(songPos - note.strumTime);

            if (diff <= badWindow && diff < closestDiff)
            {
                closest = note;
                closestDiff = diff;
            }
        }

        return closest;
    }

    static function registerHit(state:PlayState, note:Note, songPos:Float):Void
    {
        note.wasHit = true;

        var diff = Math.abs(songPos - note.strumTime);
        var judgement = diff <= sickWindow ? "sick" : (diff <= goodWindow ? "good" : "bad");

        applyJudgement(state, judgement);

        if (note.isSustain)
        {
            beginHold(state, note.strumlineIndex, note.columnIndex);
            note.hideHead();
            heldNotes.set(note.strumlineIndex + ":" + note.columnIndex, note);
        }
        else
        {
            playAnim(state, note.strumlineIndex, note.columnIndex, "hit");
            removeNote(state, note);
        }
    }

    // ---- holding sustains down ----
    static function handleHolds(state:PlayState, songPos:Float):Void
    {
        for (key in heldNotes.keys())
        {
            var note = heldNotes.get(key);

            var direction = state.keyDirections[note.columnIndex % state.keyDirections.length].toLowerCase();
            var binds = keyBinds.exists(direction) ? keyBinds.get(direction) : [];
            var isBotNote = note.strumlineIndex != state.playerStrumlineIndex;
            var stillHeld = isBotNote || (binds.length > 0 && FlxG.keys.anyPressed(binds));

            if (songPos >= note.sustainEnd)
            {
                // held all the way through - full credit
                if (!isBotNote)
                    applyJudgement(state, "sick");

                endHold(state, note.strumlineIndex, note.columnIndex, true);
                removeNote(state, note);
                heldNotes.remove(key);
                continue;
            }

            if (!stillHeld)
            {
                // released early - the rest of the hold is lost
                applyMiss(state);
                endHold(state, note.strumlineIndex, note.columnIndex, false);
                removeNote(state, note);
                heldNotes.remove(key);
            }
        }
    }

    // ---- notes that scrolled past the player without ever being hit ----
    static function sweepMisses(state:PlayState, songPos:Float):Void
    {
        for (note in state.notes.copy())
        {
            if (note.strumlineIndex != state.playerStrumlineIndex)
                continue;

            if (note.wasHit || note.tooLate)
                continue;

            if (songPos - note.strumTime > badWindow)
            {
                note.tooLate = true;
                applyMiss(state);
                playAnim(state, note.strumlineIndex, note.columnIndex, "miss");
                removeNote(state, note);
            }
        }
    }

    // ---- shared helpers ----
    static function applyJudgement(state:PlayState, judgement:String):Void
    {
        var change = state.accuracyTracker.ratings.exists(judgement) ? state.accuracyTracker.ratings.get(judgement) : 0;
        state.accuracyTracker.accuracy += change;

        switch (judgement)
        {
            case "sick":
                state.score += 350;
                state.health += 0.023;
            case "good":
                state.score += 200;
                state.health += 0.023;
            case "bad":
                state.score += 100;
                state.health += 0.01;
            default:
        }
    }

    static function applyMiss(state:PlayState):Void
    {
        state.misses++;
        state.accuracyTracker.accuracy += state.accuracyTracker.ratings.get("miss");
        state.health -= 0.05;
        state.score -= 10;
    }

    static function beginHold(state:PlayState, strumIndex:Int, columnIndex:Int):Void
    {
        var strumNote = getStrumNote(state, strumIndex, columnIndex);

        if (strumNote != null)
            strumNote.PlayHoldAnimation();
    }

    static function endHold(state:PlayState, strumIndex:Int, columnIndex:Int, success:Bool):Void
    {
        var strumNote = getStrumNote(state, strumIndex, columnIndex);

        if (strumNote != null)
            strumNote.StopHoldAnimation(success);
    }

    static function playAnim(state:PlayState, strumIndex:Int, columnIndex:Int, anim:String):Void
    {
        var strumNote = getStrumNote(state, strumIndex, columnIndex);

        if (strumNote != null)
            strumNote.PlayAnimation(anim);
    }

    static function getStrumNote(state:PlayState, strumIndex:Int, columnIndex:Int):StrumNote
    {
        if (strumIndex < 0 || strumIndex >= state.StrumlineNotes.length)
            return null;

        var line = state.StrumlineNotes[strumIndex];

        if (columnIndex < 0 || columnIndex >= line.length)
            return null;

        return line[columnIndex];
    }

    static function removeNote(state:PlayState, note:Note):Void
    {
        note.visible = false;
        note.kill();
        state.notes.remove(note);
    }
}
