package util.fileUtils;

import sys.FileSystem;
import sys.io.File;

/**
 * rather simple txt splitting system
 */

/**
 * we do use a custom txt called vibintxt. its just a normal txt but more orginized so they are seperated
 */
class TxtSplitter {
    public static function SplitTxt(path:String):Array<String> {
        var fullPath:String = path;

        if (!fullPath.startsWith("assets/data/")) {
            fullPath = "assets/data/" + fullPath;
        }

        if (!fullPath.endsWith(".vibintxt")) {
            fullPath += ".vibintxt";
        }

        if (!FileSystem.exists(fullPath)) {
            return [];
        }

        var rawText:String = File.getContent(fullPath);
        var lines:Array<String> = rawText.split("\n");
        var result:Array<String> = [];

        for (line in lines) {
            var trimmed:String = line.trim();
            if (trimmed.length > 0) {
                result.push(trimmed);
            }
        }

        return result;
    }
}