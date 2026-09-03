package vibin.states.ui.mainmenu;

import vibin.backend.backendStates.MusicUIBeatState;
import util.fileUtils.TxtSplitter;

class MainMenuState extends MusicUIBeatState {
    var MenuButtons:Array<String> = [];

    override function create() {
        super.create();

        DiscordRPC.changePresence("In the Menus", "Main Menu");

        MenuButtons = TxtSplitter.SplitTxt("menus/ui/mainmenu/MainMenuButtons");

        trace(MenuButtons);
    }
}