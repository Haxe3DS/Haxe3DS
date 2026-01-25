# there's a lot of type hints, i just like them

import os
import sys
import json
import shutil
import warnings
from typing import Any

jsonStruct:dict[str, dict[str, Any]] = {
	"settings": {
		"deleteTempFiles": True,
		"compileAsCIA": False,
		"debugMode": False,
		"libraries": ["haxe3ds"],
		"3dslink": {
			"ip": "",
			"link3dsToConsole": False,
			"openEmuIfTransferFailed": True
		}
	},
	"metadata": {
		"title": "Haxe3DS",
		"description": "Made with <3 using Haxe!",
		"author": "Author"
	}
}

HXML_TEMP:str = """-cp source
-main Main

-lib hxcpp
{}

-D nx
-D HAXE3DS
-D HAXE_OUTPUT_PART=HAXE3DS
-D HXCPP_SINGLE_THREADED_APP
-D HXCPP_STACK_TRACE
-D HXCPP_STACK_LINE
-D HXCPP_GC_GENERATIONAL
-D HXCPP_CPP17
-D static_link
-cpp export"""

class HaxeLibraryMissing(Warning):
	pass

class ProjectJSONMissing(Warning):
	pass

def execute(shell:str) -> int:
	print(f'$ {shell}')
	return os.system(shell)

def read(file:str) -> str:
	if not os.path.exists(file):
		return ""

	with open(file, "r", encoding="utf-8") as f:
		return f.read()

def write(file:str, c:Any):
	with open(file, "w", encoding="utf-8") as f:
		f.write('\n'.join(c) if isinstance(c, list) else str(c))

LPJCalled:bool = False
def loadProjectJSON() -> dict[str, dict[str, Any]]:
	global LPJCalled
	if LPJCalled:
		return jsonStruct

	LPJCalled = True
	if not os.path.exists("3dsSettings.json"):
		warnings.warn("3dsSettings.json not found in project! Using default settings.", ProjectJSONMissing)
	else:
		return json.loads(read("3dsSettings.json"))

	return jsonStruct

# 3dslink only supports ipv4 (xxx.xxx.xxx.xxx) so i tried doing this what jankiness calls it, this function
# yeah there's ipaddress but i have no idea if it has better support but whatever.
def isIPValid(string:str) -> bool:
	dots:list[str] = string.split(".")
	if len(dots) != 4: # x.x.x.x is valid, x.x.x. is also valid x.x.x isn't
		return False

	for numbers in dots:
		try:
			number:int = int(numbers)
			if not (-1 < number < 256): # x.x.x.x is valid, x.x.x. and x.x.x is not valid
				raise IndexError
		except (ValueError, IndexError):
			return False

	return "-" not in string

def executableFileHandler(make:str):
	if not os.getcwd().replace("\\", "/").endswith("buildFiles"):
		if not os.path.exists(f"buildFiles/output.{CACiaAsStr()}"):
			print("Exiting... Application needs to be built first!")
			exit(1)
		os.chdir("buildFiles")

	ip:str = jsonStruct["settings"]["3dslink"]["ip"].strip()
	ipValid:bool = isIPValid(ip)

	cmdToRun:str = f'{"" if sys.platform.startswith("win") else f"flatpak run org.azahar_emu.Azahar ./"}output.{make}'
	if ipValid:
		if make == "3dsx":
			if execute(f'{dkpPathReplace("[DKP_PATH]/tools/bin/3dslink")} -a {ip} {"-s" if jsonStruct["settings"]["3dslink"]["link3dsToConsole"] else ""} output.3dsx') != 0 and jsonStruct["settings"]["3dslink"]["openEmuIfTransferFailed"]:
				execute(cmdToRun)
		else:
			execute(f"curl --upload-file output.{make} \"ftp://{ip}:5000/cia/\"")
	else:
		execute(cmdToRun)

def dkpPathReplace(x:str) -> str:
	return x.replace("[DKP_PATH]", f"C:/devkitpro" if sys.platform.startswith("win") else "/opt/devkitpro")

def CACiaAsStr() -> str:
	return "cia" if jsonStruct["settings"]["compileAsCIA"] else "3dsx"

if __name__ == "__main__":
	if len(sys.argv) == 1:
		print(f"""usage: python {sys.argv[0]} [arg]

Arguments:
\t[-g]: Generates a Haxe3DS Project JSON and makes a new haxelib repo for Haxe Libraries.
\t[-c]: Starts compiling to a working 3DS Application.
\t[-e]: Helper argument to search exceptions
\t[-s]: Helper argument to handle compiled .cia/.3dsx file.""")
		exit(0)

	match sys.argv[1]:
		case "-g":
			if os.path.exists("3dsSettings.json"):
				if input("3dsSettings.json exists in the project, Are you sure to overwrite it? [y/n]: ").lower() != "y":
					exit(0)

			print("Generating 3dsSettings.json...")
			write("3dsSettings.json", json.dumps(jsonStruct, indent=4))

			if not os.path.exists(".haxelib"):
				execute("haxelib newrepo")

			print("Done!")

		case "-c":
			print("Preparing things, stay tight!")
			if not os.path.exists(".haxelib/hxcpp"):
				raise FileNotFoundError("Could not find fork of HXCPP! Please install it in https://github.com/Haxe3DS/hxcpp")
			
			jsonStruct = loadProjectJSON()
			for dirs in ["export", "assets/romfs/.haxe3ds", "buildFiles"]:
				os.makedirs(dirs, exist_ok=True)
			shutil.copytree("assets", "export", dirs_exist_ok=True)

			infoDir:str = "assets/romfs/.haxe3ds"
			if not os.path.exists(f"{infoDir}/.build"):
				write(f"{infoDir}/.build", 1)
			else:
				try:
					write(f"{infoDir}/.build", int(read(f"{infoDir}/.build")) + 1)
				except ValueError:
					write(f"{infoDir}/.build", 1)

			goodHaxeLibs:list[str] = []
			attributes:dict[str, list[str]] = {
				"[HAXE3DS_FLAGS]": [
					f'-I"{os.getcwd().replace("\\", "/")}/export/include"',
					'-L[DKP_PATH]/portlibs/3ds/lib',
					'-I[DKP_PATH]/portlibs/3ds/include',
					'-lHAXE3DS',
					'-lmbedtls',
					'-lmbedx509',
					'-lmbedcrypto',
					'-lz'
				]
			}

			for libs in jsonStruct["settings"]["libraries"]:
				libs:str = libs.lower()

				path:str = f".haxelib/{libs}"
				if not os.path.exists(path):
					warnings.warn(f'Skipping library "{libs}" because it hasn\'t been installed.', HaxeLibraryMissing)
					continue

				path += f'/{read(f"{path}/.current")}'
				if os.path.exists(f"{path}/haxe3ds.json"):
					hx3dsLib:dict = json.loads(read(f"{path}/haxe3ds.json"))
					for key in attributes.keys():
						if key in hx3dsLib:
							attributes[key] += hx3dsLib[key]

				if libs == "haxe3ds":
					try:
						write(f"{infoDir}/.version", json.loads(read(f"{path}/haxelib.json"))["version"])
					except:
						write(f"{infoDir}/.version", "?")

				if os.path.exists(f"{path}/assets"):
					shutil.copytree(f"{path}/assets", "export", dirs_exist_ok=True)

				goodHaxeLibs.append(libs)
			
			HXML_TEMP = HXML_TEMP.format("\n".join([f"-lib {LIB}\n-D {LIB.upper()}" for LIB in goodHaxeLibs]))
			if jsonStruct["settings"]["debugMode"]:
				HXML_TEMP += "\n-D HXCPP_DEBUGGER"
			write("build.hxml", HXML_TEMP)

			toolchainPath:str = f'.haxelib/hxcpp/{read(".haxelib/hxcpp/.current")}/toolchain'
			xmlFile:str = read(f'{toolchainPath}/haxe3ds-setup.xml')
			if len(xmlFile) == 0:
				raise FileNotFoundError(f"XML Missing, How did you even delete it?\n\tPath read from: {toolchainPath}/haxe3ds-setup.xml")

			for key, flags in attributes.items():
				xmlFile = xmlFile.replace(key, "\n".join([f"<flag value='{flag.strip().replace("\\", "/")}'/>" for flag in flags]))
			xmlFile = dkpPathReplace(xmlFile)

			if xmlFile != read(f'{toolchainPath}/linux-toolchain.xml'):
				write(f"{toolchainPath}/linux-toolchain.xml", xmlFile)

			for appInfo in ["export/resources/AppInfo", "export/Makefile"]:
				if os.path.exists(appInfo):
					savedData:str = read(appInfo)
					for key, data in jsonStruct["metadata"].items():
						savedData = savedData.replace(f"[{str(key).upper()}_JSON]", data)

					if appInfo == "export/Makefile":
						for key, flags in attributes.items():
							savedData = savedData.replace(key, " ".join(flags))
						savedData = savedData.replace("[HAXE3DS_3DSLINK]", "-DHAXE3DS_LINKTO3DS" if jsonStruct["settings"]["3dslink"]["link3dsToConsole"] else "")
					write(appInfo, dkpPathReplace(savedData))
				elif appInfo == "export/Makefile":
					raise FileNotFoundError("Makefile not found! Exiting.")

			print("Initial Setup Complete! Compiling Library...")
			if execute("haxe build.hxml") != 0:
				print("Failed to compile!")
				exit(1)

			print("Compiling to working application...")
			os.chdir("export")

			make:str = CACiaAsStr()
			if execute(f"make clean && make {"" if make == "3dsx" else make}") != 0:
				print("Failed to Compile!")
				exit(1)

			shutil.copytree("output", "../buildFiles", dirs_exist_ok=True)
			os.chdir("..")

			if jsonStruct["settings"]["deleteTempFiles"]:
				shutil.rmtree("export")
			else:
				shutil.rmtree("export/output")

			print("Successfully Compiled!")
			executableFileHandler(make)

		case "-e":
			# some people don't have that set to path, oh well.
			exit(execute(dkpPathReplace(f'[DKP_PATH]/devkitARM/bin/arm-none-eabi-addr2line -i -p -s -f -C -r -e buildFiles/output.elf -a {" ".join(sys.argv[2:])}')))

		case "-s":
			jsonStruct = loadProjectJSON()
			executableFileHandler(CACiaAsStr())