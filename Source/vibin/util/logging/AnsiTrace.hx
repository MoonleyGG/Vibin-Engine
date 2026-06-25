package vibin.util.logging;

#if (sys && FEATURE_DEBUG_FILE_LOGGING)
import vibin.util.DateUtil;
import vibin.util.FileUtil;
import flixel.math.FlxMath;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.FileOutput;
import sys.io.File;
#end

using tools.AnsiUtil;
using StringTools;

/**
 * Class that helps with some Ansi related logging functionality like some terminal color checking
 */
@:nullSafety
class AnsiTrace
{
  private static final HEADER_REGEX = ~/^\s*\[(.*?)\]\s*(.*)$/;

  #if (sys && FEATURE_DEBUG_FILE_LOGGING)
  private static final logFilePath:String = 'logs/log-${DateUtil.generateTimestamp()}.txt';
  private static var logFile:Null<FileOutput> = null;
  private static var logFileClosed:Bool = false;
  #end

  /**
   * Output a message to the log.
   * Called when using `trace()`, and modified from the default to support ANSI colors.
   * @param v The value to print.
   */
  public static function trace(v:Dynamic, ?info:haxe.PosInfos)
  {
    #if (sys && FEATURE_DEBUG_FILE_LOGGING)
    @:nullSafety(Off)
    var logStr:String = haxe.Log.formatOutput(v, info) + "\n";
    #end

    var str:String = formatOutput(v, info);
    #if FEATURE_DEBUG_TRACY
    cpp.vm.tracy.TracyProfiler.message(str, flixel.util.FlxColor.WHITE);
    #end
    #if js
    if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null) (untyped console).log(str);
    #elseif lua
    untyped __define_feature__("use._hx_print", _hx_print(str));
    #elseif sys
    #if FEATURE_DEBUG_FILE_LOGGING
    if (logFile == null && !logFileClosed)
    {
      try
      {
        FileUtil.createDirIfNotExists(Path.directory(logFilePath));
        if (FileSystem.exists(logFilePath)) FileSystem.deleteFile(logFilePath);
      }
      catch (_)
      {
        logFileClosed = true;
      }

      if (!logFileClosed) logFile = File.write(logFilePath);

      lime.app.Application.current.onExit.add((_) ->
      {
        if (logFile != null && !logFileClosed) logFile.close();
        logFileClosed = true;
      }, true, FlxMath.MIN_VALUE_INT);
    }
    if (logFile != null && !logFileClosed) logFile.writeString(logStr);
    #end
    Sys.println(str);
    #else
    throw new haxe.exceptions.NotImplementedException()
    #end
  }

  /**
   * Returns our terminals support for color output
   */
  public static var colorSupported:Bool = #if sys (Sys.getEnv("TERM")?.startsWith('xterm')
    || Sys.getEnv("ANSICON") != null) #else false #end;

  /**
   * Format the output to use ANSI colors.
   * Edited from the standard `trace()` implementation.
   */
  static function formatOutput(v:Dynamic, ?infos:haxe.PosInfos):String
  {
    var str:String = Std.string(v);
    if (infos == null) return str;

    if (AnsiUtil.isColorCodesSupported())
    {
      var dirs:Array<String> = infos.fileName.split("/");
      dirs[dirs.length - 1] = dirs[dirs.length - 1].bold();

      // rejoin the dirs
      infos.fileName = dirs.join("/");
    }

    var pstr:String = infos.fileName + ":" + '${infos.lineNumber}'.bold();
    if (infos.customParams != null) for (v in infos.customParams)
      str += ", " + Std.string(v);

    var header:String = "";
    var body:String = str;

    if (HEADER_REGEX.match(str))
    {
      header = ' ${HEADER_REGEX.matched(1)} ';
      body = HEADER_REGEX.matched(2);
    }

    if (header.ltrim() != '') str = header.bg_white().bold() + ' ${body}';
    return pstr + ": " + str;
  }

  /**
   * Print color pixel art of BF in ANSI format.
   */
  public static function traceBF()
  {
    #if (sys)
    if (AnsiUtil.isColorCodesSupported())
    {
      for (line in ansiBF)
        Sys.stdout().writeString(line + "\n");
      Sys.stdout().flush();
    }
    #end
  }

  /**
   * Color pixel art of BF in ANSI format.
   * Generated using https://dom111.github.io/image-to-ansi/
   */
  public static var ansiBF:Array<String> = ["
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣤⣤⣤⣤⣤⣿⣿⣿⣿⣧⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⣀⣀⣰⣶⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣤⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠛⠛⠛⠛⠛⢻⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⣀⣀⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠸⢿⣿⣿⣷⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⠉⠉⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣤⣼⣿⣿⣿⣿⣿⣿⠛⠛⠛⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠛⣿⣿⣿⣧⡄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⣀⣶⣾⣿⣿⣿⣿⠿⠏⠉⠉⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠉⣿⣿⣿⣇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣿⣿⣿⣿⣿⣿⠛⠛⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠛⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⣸⣿⣿⣿⣿⣿⡿⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢿⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣾⣿⣿⣿⣿⣿⣿⣷⣶⡆⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⢹⣿⣿⣶⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣿⣿⣿⣇⠛⣿⣿⣿⣿⣿⣿⣤⣄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⢻⣿⣿⣤⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢹⣿⣿⣿⠄⣿⣿⣿⡿⢿⣿⣿⣿⣶⣆⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠸⢿⣿⣿⡆⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⢻⣿⣿⣤⠛⣿⣿⣧⡜⠛⣿⣿⣿⣿⣧⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣧⡄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⢀⣀⣀⣀⣀⡸⢿⣿⣿⣀⣿⣿⣿⡇⠄⠄⠄⠸⠿⠿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣀⣿⡇⠄⠄⠄⣿⣿⣿⣇⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⢰⣾⣿⣿⣿⣿⣷⣾⣿⣿⣿⠉⣿⣿⣷⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣴⣿⣿⠁⠄⠄⠄⠉⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⢠⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣴⣾⣿⠛⠄⠄⠄⠄⠄⠄⠛⣿⣿⣿⣧⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⢸⣿⣿⣿⠉⠉⠉⠉⠹⠿⠿⠿⣿⣿⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣀⣾⣿⡿⠉⠄⠄⠄⠄⠄⠄⠄⠄⢿⣿⣿⣿⣀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⣼⣿⣿⠟⠄⠄⠄⠄⠄⠄⠄⠄⠈⠛⠛⠛⠛⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣤⣿⣿⡟⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⢻⣿⣿⣿⣤⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣿⣿⣿⡟⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⣶⣿⣿⡏⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢰⣿⣿⡏⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⢹⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣼⣿⣿⠛⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⣶⣿⣿⡏⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣰⣾⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⣤⣿⣿⡟⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣤⣤⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣤⣿⣿⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠸⠿⢿⣿⣿⣀⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⣿⣿⣿⣿⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⠄⣀⣀⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⢰⣿⣿⣿⠁⠄⢰⣶⣶⣶⣶⣶⣶⡄⠄⠄⠄⠄⠄⠈⣿⣿⣿⣷⣶⡆⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢰⣾⣿⣿⣿⣿⣿⣿⣿⡄⠄⣶⡆⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣶⣿⣿⣷⠄⠄⠄⠄⠄⠄⢰⣶⣶⡆⠄
⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠛⣿⣿⣿⣿⣤⣤⠄⠄⠄⠄⠄⠄⠄⠄⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⣿⣧⡄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣿⣿⣿⣿⣤⠄⣤⣼⣿⣿⣿⣿⣿⡇⠄
⠄⢸⣿⣿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⢀⣀⡀⠉⠹⠿⢿⣿⣿⣶⣶⣆⣀⣀⠄⠄⣰⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⢿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⡇⠄
⠄⠘⠛⠛⠛⠛⠛⠃⠄⠄⣿⣿⣿⡇⠄⠄⠄⠄⠄⢠⣤⣿⣿⣿⡄⠄⠄⠘⣿⣿⣿⣿⣿⣿⣿⣤⣤⣿⣿⣿⣿⠋⣿⣿⣿⣿⣿⣿⣿⣤⣼⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⡟⢻⣿⣿⣿⣿⣿⣿⡟⠛⢻⣿⣿⡇⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⣀⣿⣿⣿⠇⠄⢀⣀⣀⣿⣿⣿⣿⣿⣿⡇⠄⠄⠄⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠄⠄⠄⣿⣿⡿⠿⣿⣿⣿⣿⣿⣿⠄⠄⠄⢀⣀⣀⣀⠄⠄⠄⠄⠄⢸⣿⣿⡇⠘⢿⣿⣿⡿⠿⠄⠄⢸⣿⣿⣿⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⣿⣿⣿⡇⢰⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡆⠄⠄⠄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠄⠄⠄⠉⠉⠁⠄⠉⣿⣿⣿⣿⣿⠄⠄⣶⣾⣿⣿⣿⣶⣶⠄⠄⠄⢸⣿⣿⡇⠄⢸⣿⣿⣶⣶⣶⣶⣾⣿⣿⣿⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⢣⣤⣿⣿⣿⣿⡇⠄⠄⠄⠙⠛⠛⠛⠛⠛⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣿⣿⡟⢻⣿⣿⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡄⠄⣿⣿⡇⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⢰⣿⣿⣿⣿⣿⡿⠿⠉⣁⣶⣾⣿⣿⣿⣿⢿⣷⣶⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣀⣀⣀⣰⣶⣾⠿⠿⠁⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣆⣿⣿⣷⣶⣾⣿⣿⣿⠿⠿⠿⠿⠿⠉⠉⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣿⡟⠛⠃⠄⠄⣿⣿⣿⣿⣿⠛⠛⢸⣿⣿⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣿⣿⣿⣿⣿⡟⠄⠄⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠿⠿⠄⠄⠄⠄⠄⠄⣿⣿⣿⡇⠄⠄⠄⠸⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠃⠄⠄⠄⠄⣀⣸⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠄⠄⠸⢿⣿⣿⣿⣿⡿⢿⣿⣿⠿⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣿⣿⣿⣷⣶⠄⠄⠄⠄⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠄⠄⠄⠄⠄⢰⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⡏⠉⠉⠄⠄⠄⠄⠄⠈⠉⣿⣿⣿⡇⠈⠉⠉⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢻⣿⣿⣿⣿⣿⣧⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠛⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠛⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠹⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⠉⠉⠉⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠛⠛⠛⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠛⠛⠛⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
"];
}
