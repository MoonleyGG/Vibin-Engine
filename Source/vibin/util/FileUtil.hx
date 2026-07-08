package vibin.util;

import haxe.zip.Entry;
import lime.utils.Bytes;
import openfl.Lib;
import openfl.net.FileFilter;
import haxe.io.Path;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
#if FEATURE_HAXEUI
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.Dialogs.SelectedFileInfo;
import haxe.ui.containers.dialogs.Dialogs.FileDialogExtensionInfo;
#end

using StringTools;

@:nullSafety
class FileUtil
{
  public static final FILE_FILTER_FNFC:FileFilter = new FileFilter("Friday Night Funkin' Chart (.fnfc)", "*.fnfc");
  public static final FILE_FILTER_JSON:FileFilter = new FileFilter("JSON Data File (.json)", "*.json");
  public static final FILE_FILTER_ZIP:FileFilter = new FileFilter("ZIP Archive (.zip)", "*.zip");
  public static final FILE_FILTER_PNG:FileFilter = new FileFilter("PNG Image (.png)", "*.png");
  public static final FILE_FILTER_FNFS:FileFilter = new FileFilter("Friday Night Funkin' Stage (.fnfs)", "*.fnfs");

  #if FEATURE_HAXEUI
  public static final FILE_EXTENSION_INFO_FNFC:FileDialogExtensionInfo = {
    extension: 'fnfc',
    label: 'Friday Night Funkin\' Chart',
  };
  public static final FILE_EXTENSION_INFO_ZIP:FileDialogExtensionInfo = {
    extension: 'zip',
    label: 'ZIP Archive',
  };
  public static final FILE_EXTENSION_INFO_PNG:FileDialogExtensionInfo = {
    extension: 'png',
    label: 'PNG Image',
  };

  public static final FILE_EXTENSION_INFO_FNFS:FileDialogExtensionInfo = {
    extension: 'fnfs',
    label: 'Friday Night Funkin\' Stage',
  };
  #end

  public static var PROTECTED_PATHS(get, never):Array<String>;

  static function get_PROTECTED_PATHS():Array<String>
  {
    final protected:Array<String> = ['', '.', 'assets', 'assets/*', 'backups', 'backups/*', 'manifest', 'manifest/*', 'plugins', 'plugins/*', 'Funkin.exe', 'Funkin', 'icon.ico', 'libvlc.dll', 'libvlccore.dll', 'lime.ndll', 'scores.json'];

    #if sys
    for (i in 0...protected.length)
    {
      protected[i] = #if !linux sys.FileSystem.fullPath #end (Path.join([gameDirectory, protected[i]]));
    }
    #end

    return protected;
  }

  public static final INVALID_CHARS:EReg = ~/[:*?"<>|\n\r\t]/g;

  #if sys
  private static var _gameDirectory:Null<String> = null;
  public static var gameDirectory(get, never):String;

  public static function get_gameDirectory():String
  {
    if (_gameDirectory != null)
    {
      return _gameDirectory;
    }

    return _gameDirectory = sys.FileSystem.fullPath(Path.directory(Sys.programPath()));
  }
  #end

  #if FEATURE_HAXEUI
  public static function browseForBinaryFile(dialogTitle:String, ?typeFilter:Array<FileDialogExtensionInfo>, onSelect:(SelectedFileInfo) -> Void,
      ?onCancel:() -> Void)
  {
    var onComplete = function(button, selectedFiles)
    {
      if (button == DialogButton.OK && selectedFiles.length > 0)
      {
        onSelect(selectedFiles[0]);
      }
      else if (onCancel != null)
      {
        onCancel();
      }
    };

    Dialogs.openFile(onComplete, {
      readContents: true,
      readAsBinary: true,
      multiple: false,
      extensions: typeFilter ?? new Array<FileDialogExtensionInfo>(),
      title: dialogTitle,
    });
  }

  public static function browseForTextFile(dialogTitle:String, ?typeFilter:Array<FileDialogExtensionInfo>, onSelect:(SelectedFileInfo) -> Void,
      ?onCancel:() -> Void):Void
  {
    var onComplete = function(button, selectedFiles)
    {
      if (button == DialogButton.OK && selectedFiles.length > 0)
      {
        onSelect(selectedFiles[0]);
      }
      else if (onCancel != null)
      {
        onCancel();
      }
    };

    Dialogs.openFile(onComplete, {
      readContents: true,
      readAsBinary: false,
      multiple: false,
      extensions: typeFilter ?? new Array<FileDialogExtensionInfo>(),
      title: dialogTitle,
    });
  }
  #end

  public static function browseForDirectory(?typeFilter:Array<FileFilter>, onSelect:(String) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      ?dialogTitle:String):Bool
  {
    #if html5
    trace('WARNING: browseForDirectory not implemented for this platform');

    if (onCancel != null)
    {
      onCancel();
    }

    return false;
    #else
    trace('WARNING: browseForDirectory is not supported by this runtime.');

    if (onCancel != null)
    {
      onCancel();
    }

    return false;
    #end
  }

  public static function browseForMultipleFiles(?typeFilter:Array<FileFilter>, onSelect:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      ?dialogTitle:String):Bool
  {
    #if html5
    trace('WARNING: browseForMultipleFiles not implemented for this platform');

    if (onCancel != null)
    {
      onCancel();
    }

    return false;
    #else
    var file = new FileReference();

    file.addEventListener(Event.SELECT, function(e:Event):Void
    {
      var selectedFile:FileReference = cast e.target;
      if (onSelect != null)
      {
        onSelect([selectedFile.name]);
      }
    });

    file.addEventListener(Event.CANCEL, function(e:Event):Void
    {
      if (onCancel != null)
      {
        onCancel();
      }
    });

    file.browse();
    return true;
    #end
  }

  public static function browseForSaveFile(?typeFilter:Array<FileFilter>, onSelect:(String) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      ?dialogTitle:String):Bool
  {
    #if html5
    trace('WARNING: browseForSaveFile not implemented for this platform');

    if (onCancel != null)
    {
      onCancel();
    }

    return false;
    #else
    var file = new FileReference();

    file.addEventListener(Event.SELECT, function(e:Event):Void
    {
      var selectedFile:FileReference = cast e.target;
      if (onSelect != null)
      {
        onSelect(selectedFile.name);
      }
    });

    file.addEventListener(Event.CANCEL, function(e:Event):Void
    {
      if (onCancel != null)
      {
        onCancel();
      }
    });

    file.save('', defaultPath != null ? Path.withoutDirectory(defaultPath) : 'file.txt');
    return true;
    #end
  }

  public static function saveTextFile(data:String, ?defaultFileName:String, ?onSave:(String) -> Void, ?onCancel:() -> Void):Void
  {
    var file = new FileReference();

    file.addEventListener(Event.SELECT, function(e:Event):Void
    {
      var selectedFile:FileReference = cast e.target;
      if (onSave != null)
      {
        onSave(selectedFile.name);
      }
    });

    file.addEventListener(Event.CANCEL, function(e:Event):Void
    {
      if (onCancel != null)
      {
        onCancel();
      }
    });

    file.save(data, defaultFileName != null ? defaultFileName : 'file.txt');
  }

  public static function saveFile(data:Bytes, ?typeFilter:Array<FileFilter>, ?onSave:(String) -> Void, ?onCancel:() -> Void, ?defaultFileName:String,
      ?dialogTitle:String):Bool
  {
    #if html5
    trace('WARNING: saveFile not implemented for this platform');

    if (onCancel != null)
    {
      onCancel();
    }

    return false;
    #else
    var file = new FileReference();

    file.addEventListener(Event.SELECT, function(e:Event):Void
    {
      var selectedFile:FileReference = cast e.target;
      if (onSave != null)
      {
        onSave(selectedFile.name);
      }
    });

    file.addEventListener(Event.CANCEL, function(e:Event):Void
    {
      if (onCancel != null)
      {
        onCancel();
      }
    });

    file.save(data, defaultFileName != null ? defaultFileName : 'file');
    return true;
    #end
  }


  public static function saveMultipleFiles(resources:Array<Entry>, ?onSaveAll:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      force:Bool = false):Bool
  {
    #if desktop
    var onSelectDir:(String) -> Void = function(targetPath:String):Void
    {
      var paths:Array<String> = new Array<String>();
      for (resource in resources)
      {
        if (resource.data == null)
        {
          trace('WARNING: File ${resource.fileName} has no data or content. Skipping.');
          continue;
        }

        var filePath:String = Path.join([targetPath, resource.fileName]);

        paths.push(filePath);
      }

      if (onSaveAll != null)
      {
        onSaveAll(paths);
      }
    }

    trace('Browsing for directory to save individual files to...');

    #if mac
    defaultPath = null;
    #end

    browseForDirectory(null, onSelectDir, onCancel, defaultPath, 'Choose directory to save all files to...');

    return true;
    #elseif html5
    saveFilesAsZIP(resources, onSaveAll, onCancel, defaultPath, force);

    return true;
    #else
    trace('WARNING: saveMultipleFiles not implemented for this platform');

    if (onCancel != null)
    {
      onCancel();
    }

    return false;
    #end
  }

  public static function saveFilesAsZIP(resources:Array<Entry>, ?onSave:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      force:Bool = false):Bool
  {
    var zipBytes:Bytes = createZIPFromEntries(resources);
    var onSave:(String) -> Void = function(path:String)
    {
      trace('Saved ${resources.length} files to ZIP at "$path"');

      if (onSave != null)
      {
        onSave([path]);
      }
    };

    saveFile(zipBytes, [FILE_FILTER_ZIP], onSave, onCancel, defaultPath, 'Save files as ZIP...');
    return true;
  }

  public static function saveChartAsFNFC(resources:Array<Entry>, ?onSave:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      force:Bool = false):Bool
  {
    var zipBytes:Bytes = createZIPFromEntries(resources);
    var onSave:(String) -> Void = function(path:String)
    {
      trace('Saved FNFC file to "$path"');

      if (onSave != null)
      {
        onSave([path]);
      }
    };
    saveFile(zipBytes, [FILE_FILTER_FNFC], onSave, onCancel, defaultPath, 'Save chart as FNFC...');
    return true;
  }

  public static function saveFilesAsZIPToPath(resources:Array<Entry>, path:String, mode:FileWriteMode = Skip):Bool
  {
    #if sys
    var zipBytes:Bytes = createZIPFromEntries(resources);
    writeBytesToPath(path, zipBytes, mode);
    return true;
    #else
    return false;
    #end
  }

  public static function readStringFromPath(path:String):String
  {
    #if sys
    return sys.io.File.getContent(path);
    #else
    throw 'Direct file reading by path is not supported on this platform.';
    #end
  }

  public static function readBytesFromPath(path:String):Bytes
  {
    #if sys
    return sys.io.File.getBytes(path);
    #else
    throw 'Direct file reading by path is not supported on this platform.';
    #end
  }

  public static function browseFileReference(callback:(FileReference) -> Void):Void
  {
    var file = new FileReference();
    file.addEventListener(Event.SELECT, function(e)
    {
      var selectedFileRef:FileReference = e.target;
      trace('Selected file: ' + selectedFileRef.name);

      selectedFileRef.addEventListener(Event.COMPLETE, function(e)
      {
        var loadedFileRef:FileReference = e.target;
        trace('Loaded file: ' + loadedFileRef.name);

        callback(loadedFileRef);
      });

      selectedFileRef.load();
    });

    file.browse();
  }

  public static function writeFileReference(path:String, data:String, callback:String->Void)
  {
    var file = new FileReference();

    file.addEventListener(Event.COMPLETE, function(e:Event)
    {
      trace('Successfully wrote file: "$path"');
      callback("success");
    });

    file.addEventListener(Event.CANCEL, function(e:Event)
    {
      trace('Cancelled writing file: "$path"');
      callback("info");
    });

    file.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent)
    {
      trace('IO error writing file: "$path"');
      callback("error");
    });

    file.save(data, path);
  }

  public static function readJSONFromPath(path:String):Dynamic
  {
    #if sys
    return haxe.Json.parse(sys.io.File.getContent(path));
    #else
    throw 'Direct file reading by path is not supported on this platform.';
    #end
  }

  public static function writeStringToPath(path:String, data:String, mode:FileWriteMode = Skip):Void
  {
    #if sys
    if (directoryExists(path))
    {
      throw 'Target path is a directory, not a file: "$path"';
    }

    createDirIfNotExists(Path.directory(path));

    switch (mode)
    {
      case Force:
        sys.io.File.saveContent(path, data);
      case Skip:
        if (!pathExists(path))
        {
          sys.io.File.saveContent(path, data);
        }
      case Ask:
        if (pathExists(path))
        {
          throw 'Entry at path already exists: $path';
        }
        else
        {
          sys.io.File.saveContent(path, data);
        }
    }
    #else
    throw 'Direct file writing by path is not supported on this platform.';
    #end
  }

  public static function writeBytesToPath(path:String, data:Bytes, mode:FileWriteMode = Skip):Void
  {
    #if sys
    if (directoryExists(path))
    {
      throw 'Target path is a directory, not a file: "$path"';
    }

    var shouldWrite:Bool = true;
    switch (mode)
    {
      case Force:
        shouldWrite = true;
      case Skip:
        if (!pathExists(path))
        {
          shouldWrite = true;
        }
      case Ask:
        if (pathExists(path))
        {
          throw 'Entry at path already exists: "$path"';
        }
        else
        {
          shouldWrite = true;
        }
    }

    if (shouldWrite)
    {
      createDirIfNotExists(Path.directory(path));
      sys.io.File.saveBytes(path, data);
    }
    #else
    throw 'Direct file writing by path is not supported on this platform.';
    #end
  }

  public static function appendStringToPath(path:String, data:String):Void
  {
    #if sys
    if (!pathExists(path))
    {
      writeStringToPath(path, data, Force);
      return;
    }
    else if (directoryExists(path))
    {
      throw 'Target path is a directory, not a file: "$path"';
    }

    var output:Null<sys.io.FileOutput> = null;
    try
    {
      output = sys.io.File.append(path, false);
      output.writeString(data);
      output.close();
    }
    catch (e:Dynamic)
    {
      if (output != null)
      {
        output.close();
      }

      throw 'Failed to append to file: "$path"';
    }
    #else
    throw 'Direct file writing by path is not supported on this platform.';
    #end
  }


  public static function moveFile(path:String, destination:String):Void
  {
    #if sys
    if (Path.extension(destination) != '')
    {
      destination = Path.directory(destination);
    }

    sys.FileSystem.rename(path, Path.join([destination, Path.withoutDirectory(path)]));
    #else
    throw 'File moving is not supported on this platform.';
    #end
  }

  public static function deleteFile(path:String):Void
  {
    #if sys
    sys.FileSystem.deleteFile(path);
    #else
    throw 'File deletion is not supported on this platform.';
    #end
  }

  public static function getFileSize(path:String):Int
  {
    #if sys
    return sys.FileSystem.stat(path).size;
    #else
    throw 'File size calculation is not supported on this platform.';
    #end
  }

  public static function pathExists(path:String):Bool
  {
    #if sys
    return sys.FileSystem.exists(path);
    #else
    return false;
    #end
  }

  public static function fileExists(path:String):Bool
  {
    #if sys
    return pathExists(path) && !directoryExists(path);
    #else
    throw 'Filesystem check is not supported on this platform.';
    #end
  }

  public static function directoryExists(path:String):Bool
  {
    #if sys
    try
    {
      return sys.FileSystem.isDirectory(path);
    }
    catch (e:Dynamic)
    {
      return false;
    }
    #else
    throw 'Filesystem check is not supported on this platform.';
    #end
  }

  public static function createDirIfNotExists(dir:String):Void
  {
    if (!directoryExists(dir))
    {
      #if sys
      sys.FileSystem.createDirectory(dir);
      #else
      throw 'Directory creation is not supported on this platform.';
      #end
    }
  }

  public static function readDir(path:String):Array<String>
  {
    #if sys
    return sys.FileSystem.readDirectory(path);
    #else
    throw 'Directory reading is not supported on this platform.';
    #end
  }

  public static function moveDir(path:String, destination:String, ?ignore:Array<String>, strict:Bool = true):Void
  {
    #if sys
    if (!directoryExists(path))
    {
      throw 'Path is not a directory: "$path"';
    }

    createDirIfNotExists(destination);
    if (strict)
    {
      var entries:Array<String> = readDir(destination);
      if (entries.length > 0)
      {
        throw 'Destination directory "$destination" is not empty.';
      }
    }

    var stack:Array<String> = [path];
    while (stack.length > 0)
    {
      var currentPath:Null<String> = stack.pop();
      if (currentPath == null) continue;

      var entries:Array<String> = readDir(currentPath);
      for (entry in entries)
      {
        var entryPath:String = Path.join([currentPath, entry]);
        if (ignore != null && ignore.contains(entryPath)) continue;
        if (directoryExists(entryPath))
        {
          stack.push(entryPath);
        }
        else
        {
          moveFile(entryPath, Path.join([destination, entry]));
        }
      }
    }

    if (readDir(path)?.length == 0)
    {
      deleteDir(path);
    }
    #else
    throw 'Directory moving is not supported on this platform.';
    #end
  }

  public static function deleteDir(path:String, recursive:Bool = false, ?ignore:Array<String>):Void
  {
    #if sys
    if (!directoryExists(path))
    {
      throw 'Path is not a valid directory: "$path"';
    }

    if (recursive)
    {
      var stack:Array<String> = [path];
      while (stack.length > 0)
      {
        var currentPath:Null<String> = stack.pop();
        if (currentPath == null) continue;

        var entries:Array<String> = readDir(currentPath);
        for (entry in entries)
        {
          var entryPath:String = Path.join([currentPath, entry]);
          if (ignore != null && ignore.contains(entryPath)) continue;
          if (directoryExists(entryPath))
          {
            stack.push(entryPath);
          }
          else
          {
            deleteFile(entryPath);
          }
        }
      }
    }
    else
    {
      sys.FileSystem.deleteDirectory(path);
    }
    #else
    throw 'Directory deletion is not supported on this platform.';
    #end
  }

  public static function getDirSize(path:String):Int
  {
    #if sys
    if (!directoryExists(path))
    {
      throw 'Path is not a valid directory path: $path';
    }

    var stack:Array<String> = [path];
    var total:Int = 0;
    while (stack.length > 0)
    {
      var currentPath:Null<String> = stack.pop();
      if (currentPath == null) continue;

      for (entry in readDir(currentPath))
      {
        var entryPath:String = Path.join([currentPath, entry]);
        if (directoryExists(entryPath))
        {
          stack.push(entryPath);
        }
        else
        {
          total += getFileSize(entryPath);
        }
      }
    }

    return total;
    #else
    throw 'Directory size calculation not supported on this platform.';
    #end
  }

  static var tempDir:Null<String> = null;
  static final TEMP_ENV_VARS:Array<String> = ['TEMP', 'TMPDIR', 'TEMPDIR', 'TMP'];

  public static function getTempDir():Null<String>
  {
    if (tempDir != null) return tempDir;
    #if sys
    #if windows
    var path:Null<String> = null;
    for (envName in TEMP_ENV_VARS)
    {
      path = Sys.getEnv(envName);
      if (path == '') path = null;
      if (path != null) break;
    }
    tempDir = Path.join([path ?? '', 'funkin/']);
    return tempDir;
    #elseif android
    tempDir = Path.addTrailingSlash(extension.androidtools.content.Context.getCacheDir());
    return tempDir;
    #else
    tempDir = '/tmp/funkin/';
    return tempDir;
    #end
    #else
    return null;
    #end
  }

  public static function rename(path:String, newName:String, keepExtension:Bool = true):Void
  {
    #if sys
    if (!pathExists(path))
    {
      throw 'Path does not exist: "$path"';
    }

    final isDirectory:Bool = directoryExists(path);
    newName = Path.withoutDirectory(newName);
    if (isDirectory)
    {
      newName = Path.withoutExtension(newName);
    }
    else if (keepExtension)
    {
      newName = Path.withExtension(newName, Path.extension(path));
    }

    newName = Path.join([Path.directory(path), newName]);
    if (newName == path)
    {
      return;
    }

    if (pathExists(newName))
    {
      throw 'Destination path already exists: "$newName"';
    }

    sys.FileSystem.rename(path, newName);
    #else
    throw 'File renaming by path is not supported on this platform.';
    #end
  }

  public static function createZIPFromEntries(entries:Array<Entry>):Bytes
  {
    var o:haxe.io.BytesOutput = new haxe.io.BytesOutput();
    var zipWriter:haxe.zip.Writer = new haxe.zip.Writer(o);
    var entryList = new haxe.ds.List<Entry>();
    for (entry in entries)
    {
      entryList.add(entry);
    }
    zipWriter.write(entryList);
    return o.getBytes();
  }

  public static function readZIPFromBytes(input:Bytes):Array<Entry>
  {
    var bytesInput = new haxe.io.BytesInput(input);
    var zippedEntries = haxe.zip.Reader.readZip(bytesInput);
    var results:Array<Entry> = new Array<Entry>();
    for (entry in zippedEntries)
    {
      if (entry.compressed)
      {
        entry.data = haxe.zip.Reader.unzip(entry);
      }

      results.push(entry);
    }

    return results;
  }

  public static function mapZIPEntriesByName(input:Array<Entry>):Map<String, Entry>
  {
    var results:Map<String, Entry> = new Map<String, Entry>();
    for (entry in input)
    {
      results.set(entry.fileName, entry);
    }

    return results;
  }

  public static function makeZIPEntry(name:String, content:String):Entry
  {
    var data:Bytes = haxe.io.Bytes.ofString(content, UTF8);
    return makeZIPEntryFromBytes(name, data);
  }

  public static function makeZIPEntryFromBytes(name:String, data:haxe.io.Bytes):Entry
  {
    return {
      fileName: name,
      fileSize: data.length,
      data: data,
      dataSize: data.length,
      compressed: false,
      fileTime: Date.now(),
      crc32: null,
      extraFields: null,
    };
  }

  public static function openFolder(pathFolder:String, createIfNotExists:Bool = true):Void
  {
    #if sys
    pathFolder = pathFolder.trim();
    if (createIfNotExists)
    {
      createDirIfNotExists(pathFolder);
    }
    else if (!directoryExists(pathFolder))
    {
      throw 'Path is not a directory: "$pathFolder"';
    }

    #if windows
    Sys.command('explorer', [pathFolder.replace('/', '\\')]);
    #elseif mac
    Sys.command('open', [pathFolder]);
    #elseif linux
    var exitCode = Sys.command("xdg-open", [pathFolder]);
    if (exitCode == 0) return;
    var fileManagers:Array<String> = ["dolphin", "nautilus", "nemo", "thunar", "caja", "konqueror", "spacefm", "pcmanfm"];

    for (fm in fileManagers)
    {
      if (Sys.command("which", [fm]) == 0)
      {
        exitCode = Sys.command(fm, [pathFolder]);
        if (exitCode == 0) return;
      }
    }

    trace('No compatible file manager found for Linux.');
    #end
    #else
    throw 'External folder open is not supported on this platform.';
    #end
  }

  public static function openSelectFile(path:String):Void
  {
    #if sys
    path = path.trim();
    if (!pathExists(path))
    {
      throw 'Path does not exist: "$path"';
    }

    #if windows
    Sys.command('explorer', ['/select,', path.replace('/', '\\')]);
    #elseif mac
    Sys.command('open', ['-R', path]);
    #elseif linux
    trace('File selection not reliably supported on Linux, opening parent folder instead.');
    path = Path.directory(path);
    openFolder(path);
    #end
    #else
    throw 'External file selection is not supported on this platform.';
    #end
  }

  private static function convertTypeFilter(?typeFilter:Array<FileFilter>):Null<String>
  {
    var filter:Null<String> = null;
    if (typeFilter != null)
    {
      var filters:Array<String> = new Array<String>();
      for (type in typeFilter)
      {
        filters.push(type.extension.replace('*.', '').replace(';', ','));
      }

      filter = filters.join(';');
    }

    return filter;
  }
}

@:nullSafety
class FileUtilSandboxed
{
  public static function sanitizePath(path:String):String
  {
    path = (path ?? '').trim();
    if (path == '')
    {
      #if sys
      return FileUtil.gameDirectory;
      #else
      return '';
      #end
    }

    if (path.contains(':'))
    {
      path = path.substring(path.lastIndexOf(':') + 1);
    }

    path = path.replace('\\', '/');
    while (path.contains('//'))
    {
      path = path.replace('//', '/');
    }

    final parts:Array<String> = FileUtil.INVALID_CHARS.replace(path, '').split('/');
    final sanitized:Array<String> = new Array<String>();
    for (part in parts)
    {
      switch (part)
      {
        case '.' | '':
          continue;
        case '..':
          sanitized.pop();
        default:
          sanitized.push(part.trim());
      }
    }

    if (sanitized.length == 0)
    {
      #if sys
      return FileUtil.gameDirectory;
      #else
      return '';
      #end
    }

    #if sys
    #if linux
    var realPath:Null<String> = null;
    var unresolvedSegments:Array<String> = [];
    while (realPath == null && sanitized.length > 0)
    {
      realPath = sys.FileSystem.fullPath(Path.join([FileUtil.gameDirectory].concat(sanitized)));
      if (realPath == null) unresolvedSegments.unshift(sanitized.pop() ?? continue);
    }

    if (unresolvedSegments.length > 0)
    {
      if (realPath != null) unresolvedSegments.unshift(realPath);
      realPath = Path.join(unresolvedSegments);
    }
    #else
    final realPath:Null<String> = sys.FileSystem.fullPath(Path.join([FileUtil.gameDirectory].concat(sanitized)));
    #end

    if (realPath == null || !realPath.startsWith(FileUtil.gameDirectory))
    {
      return FileUtil.gameDirectory;
    }

    return realPath;
    #else
    return sanitized.join('/');
    #end
  }

  public static function isProtected(path:String, sanitizeFirst:Bool = true):Bool
  {
    if (sanitizeFirst) path = sanitizePath(path);
    @:privateAccess for (protected in FileUtil.PROTECTED_PATHS)
    {
      if (path == protected || (protected.contains('*') && path.startsWith(protected.substring(0, protected.indexOf('*')))))
      {
        return true;
      }
    }

    return false;
  }

  public static final FILE_FILTER_FNFC:FileFilter = FileUtil.FILE_FILTER_FNFC;
  public static final FILE_FILTER_JSON:FileFilter = FileUtil.FILE_FILTER_JSON;
  public static final FILE_FILTER_ZIP:FileFilter = FileUtil.FILE_FILTER_ZIP;
  public static final FILE_FILTER_PNG:FileFilter = FileUtil.FILE_FILTER_PNG;

  #if FEATURE_HAXEUI
  public static final FILE_EXTENSION_INFO_FNFC:FileDialogExtensionInfo = FileUtil.FILE_EXTENSION_INFO_FNFC;
  public static final FILE_EXTENSION_INFO_ZIP:FileDialogExtensionInfo = FileUtil.FILE_EXTENSION_INFO_ZIP;
  public static final FILE_EXTENSION_INFO_PNG:FileDialogExtensionInfo = FileUtil.FILE_EXTENSION_INFO_PNG;

  public static function browseForBinaryFile(dialogTitle:String, ?typeFilter:Array<FileDialogExtensionInfo>, onSelect:(SelectedFileInfo) -> Void,
      ?onCancel:() -> Void)
  {
    FileUtil.browseForBinaryFile(dialogTitle, typeFilter, onSelect, onCancel);
  }

  public static function browseForTextFile(dialogTitle:String, ?typeFilter:Array<FileDialogExtensionInfo>, onSelect:(SelectedFileInfo) -> Void,
      ?onCancel:() -> Void):Void
  {
    FileUtil.browseForTextFile(dialogTitle, typeFilter, onSelect, onCancel);
  }
  #end

  public static function browseForDirectory(?typeFilter:Array<FileFilter>, onSelect:(String) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      ?dialogTitle:String):Bool
  {
    return FileUtil.browseForDirectory(typeFilter, onSelect, onCancel, defaultPath, dialogTitle);
  }

  public static function browseForMultipleFiles(?typeFilter:Array<FileFilter>, onSelect:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      ?dialogTitle:String):Bool
  {
    return FileUtil.browseForMultipleFiles(typeFilter, onSelect, onCancel, defaultPath, dialogTitle);
  }

  public static function browseForSaveFile(?typeFilter:Array<FileFilter>, onSelect:(String) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      ?dialogTitle:String):Bool
  {
    return FileUtil.browseForSaveFile(typeFilter, onSelect, onCancel, defaultPath, dialogTitle);
  }

  public static function saveFile(data:Bytes, ?typeFilter:Array<FileFilter>, ?onSave:(String) -> Void, ?onCancel:() -> Void, ?defaultFileName:String,
      ?dialogTitle:String):Bool
  {
    return FileUtil.saveFile(data, typeFilter, onSave, onCancel, defaultFileName, dialogTitle);
  }

  public static function saveMultipleFiles(resources:Array<Entry>, ?onSaveAll:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      force:Bool = false):Bool
  {
    return FileUtil.saveMultipleFiles(resources, onSaveAll, onCancel, defaultPath, force);
  }

  public static function saveFilesAsZIP(resources:Array<Entry>, ?onSave:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      force:Bool = false):Bool
  {
    return FileUtil.saveFilesAsZIP(resources, onSave, onCancel, defaultPath, force);
  }

  public static function saveChartAsFNFC(resources:Array<Entry>, ?onSave:(Array<String>) -> Void, ?onCancel:() -> Void, ?defaultPath:String,
      force:Bool = false):Bool
  {
    return FileUtil.saveChartAsFNFC(resources, onSave, onCancel, defaultPath, force);
  }

  public static function saveFilesAsZIPToPath(resources:Array<Entry>, path:String, mode:FileWriteMode = Skip):Bool
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot write to protected path: $path';
    return FileUtil.saveFilesAsZIPToPath(resources, path, mode);
  }

  public static function readStringFromPath(path:String):String
  {
    return FileUtil.readStringFromPath(sanitizePath(path));
  }

  public static function readBytesFromPath(path:String):Bytes
  {
    return FileUtil.readBytesFromPath(sanitizePath(path));
  }

  public static function browseFileReference(callback:(FileReference) -> Void):Void
  {
    FileUtil.browseFileReference(callback);
  }

  public static function writeFileReference(path:String, data:String, callback:String->Void):Void
  {
    FileUtil.writeFileReference(path, data, callback);
  }

  public static function readJSONFromPath(path:String):Dynamic
  {
    return FileUtil.readJSONFromPath(sanitizePath(path));
  }

  public static function writeStringToPath(path:String, data:String, mode:FileWriteMode = Skip):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot write to protected path: $path';
    FileUtil.writeStringToPath(path, data, mode);
  }

  public static function writeBytesToPath(path:String, data:Bytes, mode:FileWriteMode = Skip):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot write to protected path: $path';
    FileUtil.writeBytesToPath(path, data, mode);
  }

  public static function appendStringToPath(path:String, data:String):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot write to protected path: $path';
    FileUtil.appendStringToPath(path, data);
  }

  public static function moveFile(path:String, destination:String):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot move protected path: $path';
    if (isProtected(destination = sanitizePath(destination), false)) throw 'Cannot move to protected path: $destination';
    FileUtil.moveFile(path, destination);
  }

  public static function deleteFile(path:String):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot delete protected path: $path';
    FileUtil.deleteFile(path);
  }

  public static function getFileSize(path:String):Int
  {
    return FileUtil.getFileSize(sanitizePath(path));
  }

  public static function pathExists(path:String):Bool
  {
    return FileUtil.pathExists(sanitizePath(path));
  }

  public static function fileExists(path:String):Bool
  {
    return FileUtil.fileExists(sanitizePath(path));
  }

  public static function directoryExists(path:String):Bool
  {
    return FileUtil.directoryExists(sanitizePath(path));
  }

  public static function createDirIfNotExists(dir:String):Void
  {
    FileUtil.createDirIfNotExists(sanitizePath(dir));
  }

  public static function readDir(path:String):Array<String>
  {
    return FileUtil.readDir(sanitizePath(path));
  }

  public static function moveDir(path:String, destination:String, ?ignore:Array<String>, strict:Bool = true):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot move protected path: "$path"';
    if (isProtected(destination = sanitizePath(destination), false)) throw 'Cannot move to protected path: "$destination"';
    FileUtil.moveDir(path, destination, ignore, strict);
  }

  public static function deleteDir(path:String, recursive:Bool = false, ?ignore:Array<String>):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot delete protected path: "$path"';
    FileUtil.deleteDir(path, recursive, ignore);
  }

  public static function getDirSize(path:String):Int
  {
    return FileUtil.getDirSize(sanitizePath(path));
  }

  public static function getTempDir():Null<String>
  {
    return FileUtil.getTempDir();
  }

  public static function rename(path:String, newName:String, keepExtension:Bool = true):Void
  {
    if (isProtected(path = sanitizePath(path), false)) throw 'Cannot rename protected path: "$path"';
    FileUtil.rename(path, sanitizePath(newName), keepExtension);
  }

  public static function createZIPFromEntries(entries:Array<Entry>):Bytes
  {
    return FileUtil.createZIPFromEntries(entries);
  }

  public static function readZIPFromBytes(input:Bytes):Array<Entry>
  {
    return FileUtil.readZIPFromBytes(input);
  }

  public static function mapZIPEntriesByName(input:Array<Entry>):Map<String, Entry>
  {
    return FileUtil.mapZIPEntriesByName(input);
  }

  public static function makeZIPEntry(name:String, content:String):Entry
  {
    return FileUtil.makeZIPEntry(name, content);
  }

  public static function makeZIPEntryFromBytes(name:String, data:haxe.io.Bytes):Entry
  {
    return FileUtil.makeZIPEntryFromBytes(name, data);
  }

  public static function openFolder(pathFolder:String, createIfNotExists:Bool = true):Void
  {
    FileUtil.openFolder(sanitizePath(pathFolder), createIfNotExists);
  }

  public static function openSelectFile(path:String):Void
  {
    FileUtil.openSelectFile(sanitizePath(path));
  }
}

enum FileWriteMode
{
  Force;

  Ask;

  Skip;
}
