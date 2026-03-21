import haxe.io.Eof;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef H3DSP_Optimization = {
	var gFlag:Bool;
	var o2Flag:Bool;
}

typedef H3DSP_LinkOptions = {
	var ip:String;
	var link3dsToConsole:Bool;
	var openEmuIfTransferFailed:Bool;
}

typedef H3DSP_Settings = {
	var deleteTempFiles:Bool;
	var compileAsCIA:Bool;
	var defines:Array<String>;
	var libraries:Array<String>;
	var linkOptions:H3DSP_LinkOptions;
	var optimizations:H3DSP_Optimization;
}

typedef H3DSP_Metadata = {
	var title:String;
	var description:String;
	var author:String;
}

typedef Haxe3DSProject = {
	var settings:H3DSP_Settings;
	var metadata:H3DSP_Metadata;
}

class Haxe3DS_Tool {
	static var cwd = "";
	static var HXML_TEMP = "-cp source
-main Main

# libs
-lib hxcpp
{1}

# defines
{2}
-D loop_unroll_max_cost=0
-D nx
-D HAXE_OUTPUT_PART=HAXE3DS
-D HXCPP_SINGLE_THREADED_APP
-D HXCPP_STACK_TRACE
-D HXCPP_STACK_LINE
-D static_link
-D message.reporting=pretty
-cpp export";

	static function readConfig():Haxe3DSProject {
		if (FileSystem.exists("3dsSettings.json")) {
			return Json.parse(File.getContent("3dsSettings.json"));
		}

		throw 'Please generate it by calling "haxelib run haxe3ds -g" to generate a Config File.';
	}

	inline static function execute(cmd:String):Bool {
		trace('$ $cmd');
		return Sys.command(cmd) == 0;
	}

	static function toDKPPath(pathString:String):String {
		var env = Sys.getEnv("DEVKITPRO");
		if (env != null) {
			return pathString.replace("[DKP_PATH]", env);
		}

		return pathString.replace("[DKP_PATH]", Sys.systemName() == "Windows" ? "C:/devkitpro" : "/opt/devkitpro");
	}

	static function askForInput(warning:String):Bool {
		try {
			trace('/!\\ $warning /!\\\n\t[Y] = YES\t\t[N] = NO');
			Sys.print("> \x1b[36;1m");
			var out = Sys.stdin().readLine().toLowerCase().charAt(0) == "y";
			Sys.print("\x1b[37;1m");
			return out;
		} catch(_:Eof) { // happens only to throw eof?
			trace("\n\x1b[37;1mNo, don't input an EOF. :(");
			return askForInput(warning);
		}
	}

	static function makeDirs(directory:String) {
		var dirs = directory.split("/");
		var path = "";
		for (dir in dirs) {
			path += '$dir/';

			try {
				FileSystem.createDirectory(path);
			} catch(_) {
				continue;
			}
		}
	}

	static function recursiveCopyFiles(fromDir:String, toDir:String) {
		if (!FileSystem.exists(fromDir)) {
			return;
		}

		makeDirs('$toDir/');
		for (list in FileSystem.readDirectory(fromDir)) {
			var path = '$fromDir/$list';
			if (FileSystem.isDirectory(path)) {
				recursiveCopyFiles(path, '$toDir/$list');
			} else {
				File.saveBytes('$toDir/$list', File.getBytes(path));
			}
		}
	}

	static function recursiveRMTree(dir:String) {
		for (list in FileSystem.readDirectory(dir)) {
			var path = '$dir/$list';
			if (FileSystem.isDirectory(path)) {
				recursiveRMTree(path);
			} else {
				FileSystem.deleteFile(path);
			}
		}

		FileSystem.deleteDirectory(dir);
	}

	static function incrementFile(file:String) {
		try {
			File.saveContent(file, '${Std.parseInt(File.getContent(file)) + 1}');
		} catch(_) {
			File.saveContent(file, "1");
		}
	}

	inline static function deleteFileIfExist(file:String) {
		if (FileSystem.exists(file)) {
			FileSystem.deleteFile(file);
		}
	}

	inline static function CACIAAsStr(project:Haxe3DSProject):String {
		return project.settings.compileAsCIA ? "cia" : "3dsx";
	}

	static function fileHandler(p:Haxe3DSProject = null) {
		if (p == null) {
			p = readConfig();
		}

		if (!FileSystem.exists('buildFiles/output.${CACIAAsStr(p)}')) {
			trace("Application needs to be built first");
			return;
		}

		var ip = p.settings.linkOptions.ip;
		function validateIP():Bool {
			var dots = ip.split(".");
			if (dots.length != 4) {
				return false;
			}

			for (number in dots) {
				try {
					var num = Std.parseInt(number);
					if (num == null || !(-1 < num && num < 256)) {
						return false;
					}
				} catch(_) {
					return false;
				}
			}

			return !ip.contains("-");
		}

		var make = CACIAAsStr(p);
		var cmdToExecute = '${Sys.systemName() == "Windows" ? "" : "flatpak run org.azahar_emu.Azahar ./"}buildFiles/output.$make';
		if (validateIP()) {
			if (make == "3dsx") {
				if (!execute('${toDKPPath("[DKP_PATH]/tools/bin/3dslink")} -a $ip ${p.settings.linkOptions.link3dsToConsole ? "-s" : ""} buildFiles/output.3dsx') && p.settings.linkOptions.openEmuIfTransferFailed) {
					execute(cmdToExecute);
				}
			} else {
				execute('curl --upload-file output.$make "ftp://$ip:5000/cia/"');
			}
		} else {
			execute(cmdToExecute);
		}
	}

	static function main() {
		haxe.Log.trace = (v, ?infos) -> Sys.println(v);

		Sys.print('\x1b[33;1m
██    ██   ██████   ██    ██  ████████   ██████   ███████    ██████
██    ██  ██    ██  ██    ██  ██    ██  ██    ██  ██   ███  ██    ██
██    ██  ██    ██   ██  ██   ██              ██  ██    ██  ██
████████  ████████    ████    ██████      █████   ██    ██   ██████
██    ██  ██    ██   ██  ██   ██              ██  ██    ██        ██
██    ██  ██    ██  ██    ██  ██    ██  ██    ██  ██   ███  ██    ██
██    ██  ██    ██  ██    ██  ████████   ██████   ███████    ██████\x1b[37;1m
============================ By Nael2xd ============================
');

		var args = Sys.args();
		if (args.length == 1) {
			trace("
\tArgs (haxelib run haxe3ds [arg]):
\t\t[-g]: Generates a New JSON for Haxe3DS format.
\t\t[-c]: Compiles to a compatible working 3DS application.
\t\t[-e]: Calls arm-none-eabi-addr2line for Error Lookup.
\t\t[-s]: Wrapper for Sending or Launching the built application.
			");
			return;
		}

		{
			var path = args[args.length - 1];
			Sys.setCwd(path);
			args.remove(path);
		}

		cwd = Sys.getCwd().replace("\\", "/");
		cwd = cwd.substr(0, cwd.length - 1);
		switch args.shift() {
			case "-g":
				if (FileSystem.exists('3dsSettings.json') && !askForInput("3dsSettings.json EXISTS! Are you really sure you want to overwrite it?")) {
					return;
				}

				var out:Haxe3DSProject = {
					settings: {
						deleteTempFiles: false,
						compileAsCIA: false,
						defines: [],
						libraries: ["haxe3ds"],
						linkOptions: {
							ip: "",
							openEmuIfTransferFailed: false,
							link3dsToConsole: true
						},
						optimizations: {
							gFlag: false,
							o2Flag: false
						}
					},
					metadata: {
						title: "Haxe3DS",
						description: "Made with <3 using Haxe!",
						author: "Author"
					}
				};

				File.saveContent('3dsSettings.json', Json.stringify(out, null, "\t"));
				trace("Generated 3DS Settings Config!");

			case "-c":
				function sanityCheck(info:String, func:()->Bool, ngText:String = "") {
					var out = Sys.stdout();
					Sys.print('\x1b[35;1m> $info...\x1b[37;1m');
					if (func()) {
						out.writeString("\x1b[32;1m OK. \x1b[37;1m \n");
					} else {
						out.writeString('\x1b[31;1m NG. $ngText \x1b[37;1m \n');
						Sys.exit(1);
					}
				}

				sanityCheck("Checking for Existing Custom JSON", () -> {
					FileSystem.exists("3dsSettings.json");
				}, 'Please generate it by calling "haxelib run haxe3ds -g" to generate a Config File.');
	
				sanityCheck("Checking for Custom HXCPP", () -> {
					FileSystem.exists(".haxelib/hxcpp/git/toolchain/haxe3ds-setup.xml");
				}, 'Please install it by using "haxelib git hxcpp https://github.com/Haxe3DS/hxcpp"');

				var project:Haxe3DSProject = null;
				sanityCheck("Loading the Project", () -> {
					try {
						project = readConfig();
						return true;
					} catch(_) {
						return false;
					}
				}, 'JSON is not Formatted Correctly!');

				sanityCheck("Checking if Project is Updated", () -> {
					project.settings.optimizations != null;
				}, 'This uses the Old Config, Please Update it using "haxelib run haxe3ds -g"');

				var goodHaxeLibs:Array<String> = [];
				var attributes:Map<String, Array<String>> = [
					"[HAXE3DS_FLAGS]" => [
						'-lHAXE3DS',
						'-I"$cwd/export/include"',
						'-L"[DKP_PATH]/portlibs/3ds/lib"',
						'-I"[DKP_PATH]/portlibs/3ds/include"',
						'-lz'
					]
				];

				{
					final mapper:Map<String, Bool> = [
						"-O2" => project.settings.optimizations.o2Flag,
						"-g"  => project.settings.optimizations.gFlag,
					];

					for (string => enabled in mapper.keyValueIterator()) {
						if (enabled) {
							attributes["[HAXE3DS_FLAGS]"].push(string);
						}
					}
				}

				for (i => lib in project.settings.libraries) {
					project.settings.libraries[i] = lib.toLowerCase();
				}

				// add haxe3ds library is missing, or else it can't copy the makefile
				if (!project.settings.libraries.contains("haxe3ds")) {
					project.settings.libraries.insert(0, "haxe3ds");
				}

				sanityCheck('Parsing all ${project.settings.libraries.length} libraries', () -> {
					for (lib in project.settings.libraries) {
						var path = '.haxelib/$lib';
						if (!FileSystem.exists(path)) {
							trace('SKIPPING LIBRARY "$lib", Library does not exist.');
							continue;
						}

						path += '/${File.getContent('$path/.current')}';
						if (FileSystem.exists('$path/haxe3ds.json')) {
							var haxe3ds_lib = null;
							try {
								haxe3ds_lib = Json.parse(File.getContent('$path/haxe3ds.json'));
							} catch(_) {}

							if (haxe3ds_lib != null) {
								for (key in attributes.keys()) {
									var data:Null<Array<String>> = Reflect.getProperty(haxe3ds_lib, key);
									if (data == null) {
										continue;
									}

									attributes[key] = attributes[key].concat(data);
								}
							}
						}

						if (lib == "haxe3ds") {
							try {
								File.saveContent('$haxe3ds_romfspath/version', Json.parse(File.getContent('$path/haxelib.json')).version);
							} catch(_) {
								File.saveContent('$haxe3ds_romfspath/version', "?");
							}
						}

						recursiveCopyFiles('$path/assets', "export");
						goodHaxeLibs.push(lib);
					}

					return true;
				}, "What??");

				final haxe3ds_romfspath = "assets/romfs/haxe3ds";
				for (directories in ["export", haxe3ds_romfspath, "buildFiles"]) {
					makeDirs(directories);
				}
				File.saveContent('$haxe3ds_romfspath/buildDate', Date.now().toString());
				incrementFile('$haxe3ds_romfspath/build');
				recursiveCopyFiles("assets", "export");

				HXML_TEMP = HXML_TEMP.replace("{1}", [for (lib in goodHaxeLibs) '-lib $lib\n-D ${lib.toUpperCase()}'].join("\n"));
				HXML_TEMP = HXML_TEMP.replace("{2}", project.settings.compileAsCIA ? "-D IS_CIA" : "-D IS_3DSX");
				for (define in project.settings.defines) {
					HXML_TEMP += '$define\n';
					attributes["[HAXE3DS_FLAGS]"].push(define);
				}
				File.saveContent("build.hxml", HXML_TEMP);

				sanityCheck("Updating haxe3ds toolchain for compiler use", () -> {
					try {
						var toolchainPath = '.haxelib/hxcpp/${File.getContent(".haxelib/hxcpp/.current")}/toolchain';
						var xmlContent = File.getContent('$toolchainPath/haxe3ds-setup.xml');

						for (key => flags in attributes.keyValueIterator()) {
							var values = "";
							for (flag in flags) {
								flag = flag.replace("\\", "/").trim();
								values += '<flag value=\'$flag\'/>\n';
							}
							xmlContent = xmlContent.replace(key, values);
						}
						xmlContent = toDKPPath(xmlContent);

						final linuxpath = '$toolchainPath/linux-toolchain.xml';
						if (xmlContent != toDKPPath(File.getContent(linuxpath))) {
							File.saveContent(linuxpath, xmlContent);
							//trace("doesn't match");
						} else {
							//trace("matches");
						}

						return true;
					} catch(error) {
						trace(error);
						return false;
					}
				}, "Something went wrong!");

				sanityCheck("Finishing touches before compiling application", () -> {
					for (appInfo in ["export/resources/AppInfo", "export/Makefile"]) {
						if (FileSystem.exists(appInfo)) {
							var savedData = File.getContent(appInfo);
							for (data in Reflect.fields(project.metadata)) {
								savedData = savedData.replace('[${data.toUpperCase()}_JSON]', Reflect.getProperty(project.metadata, data));
							}

							if (appInfo == "export/Makefile") {
								for (key => flags in attributes.keyValueIterator()) {
									savedData = savedData.replace(key, flags.join(" "));
								}
								savedData = savedData.replace("[HAXE3DS_3DSLINK]", project.settings.linkOptions.link3dsToConsole ? "-DHAXE3DS_LINKTO3DS" : "");
							}
							File.saveContent(appInfo, toDKPPath(savedData));
						} else if (appInfo == "export/Makefile") {
							return false;
						}
					}

					return true;
				}, "Makefile is not found");

				trace("Initial Setup Complete! Compiling Library");
				sanityCheck("Compiling using the custom HXML file", () -> execute("haxe build.hxml"), "Failed to compile!");
				Sys.setCwd('export');

				var make = project.settings.compileAsCIA ? "cia" : "";
				sanityCheck("Finally Compiling to Working Application", () -> execute('make clean && make $make'), "Failed to compile!");

				recursiveCopyFiles("output", "../buildFiles");
				Sys.setCwd("..");

				if (project.settings.deleteTempFiles) {
					recursiveRMTree("export");
					deleteFileIfExist("build.hxml");
					deleteFileIfExist("buildFiles/output.smdh");
				} else {
					recursiveRMTree("export/output");
				}

				trace("Successfully Compiled!");
				fileHandler(project);

			case "-s":
				fileHandler();

			case "-e":
				execute(
					toDKPPath(
						'[DKP_PATH]/devkitARM/bin/arm-none-eabi-addr2line -i -p -s -f -C -r -a -e buildFiles/output.elf ${args.join(" ")}'
					)
				);
		}
	}
}