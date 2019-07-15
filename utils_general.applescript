// ******************************************
//  Dev:  marius-joe
// ******************************************
//  Mac JavaScript (JXA) Utils
//  v1.2.2
// ******************************************



// Helper - v1.1
// works only up to MacOS High Sierra
function send_iMsg(msg, iMessageAddress) {
    var Messages = Application('Messages')
    var myBuddy = Messages.buddies.whose({handle:{_equals: iMessageAddress}})[0]
    Messages.send(msg, {to: myBuddy})
}


// Helper - v1.0
function clear_message_history() {
    Messages.delete (chats[1])
    Messages.reopen()
    Messages.activate()
    setTimeout(SystemEvents.keyCode(36), 100) // Press Enter
}


// Helper - v1.0
function minimizeWindows(appName) {
	var app = Application(appName)
    var i, len
    len = app.windows.length	// for of still isn't available
    for (i = 0; i < len; ++i) {
        app.windows[i].minimized = true
    }
}

// Helper - v1.0
// quote a string
function qt(str) {
    return "'" + str.replace("'", "'\\''") + "'"
}


// Helper Bundle - v1.1
//   Call example:
//   const inTerminal = false
//   const C_Path_Python_Packs = "/Users/Marius/python_packs"
//   var program = "/usr/local/bin/python3"
//   var path_File = C_Path_Python_Packs + "/ip_check.py"
//   var file_Args = C_Path_Python_Packs + "/ip_check/"
//   var result = run_Script(program, path_File, file_Args, inTerminal)
// ----------------------------------------------------
function run_Script(interpreter, path_Script, script_Args, runInTerminal=true) {
	var cmd = interpreter + " " + qt(path_Script) + " " + qt(script_Args)
	
	if (runInTerminal) {
		var Terminal = Application('Terminal')
		// you need an open Terminal window
		Terminal.activate()
		var targetWindow = Terminal.windows[0]
		Terminal.doScript(no_echo(cmd), {in: targetWindow})
		var result = "terminal_run"
	} else {
		var result = app.doShellScript(cmd)	
	}
	return result
}

// Helper - v1.0
function no_echo(cmd) {
	return 'stty -echo\n' + cmd + '\nstty echo'
}
// ----------------------------------------------------


// Helper - v1.1
// Advanced Alternative to app.activate() which throws an error when the app is not already running in background
function get_appInstance(path_app) {
    ObjC.import('AppKit')
    var url_app = $.NSURL.fileURLWithPath($(path_app).stringByExpandingTildeInPath)
    var options = []  // can be used for run arguments
    $.NSWorkspace.sharedWorkspace.launchApplicationAtURLOptionsConfigurationError({
      launchApplicationAtURL: url_app,
      options: [], // or $()
      configuration: $.NSDictionary,
      error: null
    })
    // NSWorkspaceLaunchWithoutActivation |
    // NSWorkspaceLaunchAndHide |
    // NSWorkspaceLaunchNewInstance
    // NSWorkspaceLaunchAsync
}


// Helper - v1.0
// Simple alternative to app.activate()
function start_app(app) {
    if (!app.running()) {
        ObjC.import('AppKit')
        $.NSWorkspace.sharedWorkspace.launchApplication(app)
        while (!app.running()) {
            delay(0.3)
        }
    }
}

// Helper - v1.0
function restart_app(app) {    
    var app = Application(app)
	if (app.running()) {
        app.quit()
        while (app.running()) {
            delay(0.3)
        }
	}
	start_app(app)
}


// Helper - v1.1
// 3x faster than 'System Events'
function get_list_folderContent(strPath) {
	var file_manager = $.NSFileManager.defaultManager
	return ObjC.unwrap(file_manager.contentsOfDirectoryAtPathError($(strPath).stringByExpandingTildeInPath, null)).map(ObjC.unwrap)
}


// Helper - v1.0
function posixPath_currentWindow() {
	var currentFinderWin = Application('Finder').finderWindows[0]
	return $.NSURL.alloc.initWithString(currentFinderWin.target.url()).fileSystemRepresentation
}


// Helper - v1.0
function is_folder_exist(path_folder) {
    defFileManager = $.NSFileManager.defaultManager
    ref = Ref()
    return defFileManager.fileExistsAtPathIsDirectory(
        $(path_folder)
        .stringByStandardizingPath, ref
    ) && ref[0] === 1;
}
 
// Helper - v1.0
function is_file_exist(path_file) {
    var error = $()
    defFileManager = $.NSFileManager.defaultManager
    return defFileManager.attributesOfItemAtPathError(
        $(path_file)
        .stringByStandardizingPath,
        error
    )
    error.code === undefined
}


// Helper - v1.0
function get_current_dir() {
    return ObjC.unwrap($.NSFileManager.defaultManager.currentDirectoryPath)
}


// Helper - v1.0
function set_current_dir(path) {
    $.NSFileManager.defaultManager.changeCurrentDirectoryPath(
        $(path)
        .stringByStandardizingPath
    )
}        
      

// Helper - v1.0
// destination has to be always the full path + filename, for folders a new folder will be created
function move(path_source, path_dest) {
    ObjC.import('Cocoa')
    var error = $()
    var file_manager = $.NSFileManager.defaultManager
    var fileMoved = file_manager.moveItemAtPathToPathError($(path_source),$(path_dest), error)
    if (!fileMoved) {
        // do things depending on error.code
    }
}


// Helper - v1.0
function readFile(path_file) {
    return app.read(Path(path_file))
}


// Helper - v1.0
function getListFromFile(path_file, delim) {
    return app.read(Path(path_file), {usingDelimiter: delim})
}


// Helper - v1.1
function writeToFile(path_file, text, overwrite) {
    try {
        var file = app.openForAccess(Path(path_file), {writePermission: true})
        if (overwrite) {
            app.setEof(file, {to: 0})
        }
        app.write(text, {to: file, startingAt: app.getEof(file)})
        app.closeAccess(file)
        // writing was successful
        return true
    }
    catch (error) {
        try {
            app.closeAccess(file)
        }
        catch(error) {
            // closing failed
            console.log(`Couldn't close file: ${error}`)
        }
        // writing was not successful
        return false
    }
}


// Helper - v1.2
function printDialog(msg) {
	var current_app = Application.currentApplication()
	current_app.includeStandardAdditions = true
    current_app.displayDialog(msg, {withIcon: "caution"})
}
