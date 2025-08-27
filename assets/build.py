import json
import sys
import os
import shutil
import glob
import time

jsonStruct = {
    "settings": {
        "3dsIP": "0.0.0.0",
        "deleteTempFiles": False,
        "makeAs": "cia",
        "libraries": ["haxe3ds"]
    },
    "metadata": {
        "title": "Haxe3DS",
        "description": "Made with <3 using Haxe!",
        "author": "Author"
    }
}

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("""usage: Hx3DSCompiler [-g] [-c]

options:
  -g      Generates a Struct JSON and saves it to the current CWD.
  -c      Compiles to 3DS with 3dsSettings.json provided""")
        sys.exit(0)

    arg = sys.argv[1]
    if "-g" in arg:
        print("DOING: Generating JSON")
        with open("3dsSettings.json", "w") as f:
            f.write(json.dumps(jsonStruct, indent=4))
        print("Done!")
        sys.exit(0)

    elif "-c" in arg:
        oldTime = time.time()
        
        if not os.path.exists("3dsSettings.json"):
            print("3dsSettings.json doesn't exist!! Consider generating the Json!")
            sys.exit(1)

        with open("3dsSettings.json", "r") as f:
            jsonStruct = json.load(f)

        with open("build.hxml", "w") as f:
            f.write(f"""-cp source
-main Main

-lib reflaxe.cpp
""")
            for libs in jsonStruct["settings"]["libraries"]:
                f.write(f"-lib {libs}\n")

            f.write("""
-D cpp-output=output
-D mainClass=Main
-D cxx-no-null-warnings
-D keep-unused-locals
-D keep-useless-exprs
-D cxx_callstack
-D cxx_inline_trace_disabled""")
                
        if jsonStruct["settings"]["deleteTempFiles"] == True and os.path.exists("output"):
            shutil.rmtree("output")

        if os.system("haxe build.hxml") != 0:
            print("Error! Stopping...")
            sys.exit(1)

        blockedStuff = [
            "throw haxe::Exception",
            "haxe::Log::trace"
        ]

        replacers = [
            #["std::nullopt", "NULL"],          # Compiler failures
            ["* _gthis",         "deleteline"], # Known to throw Exceptions
            ["_gthis",           "this"],       # Known to throw Exceptions
            ["HCXX_LINE",        "deleteline"], # Decreasing size
            ["HCXX_STACK_METHOD","deleteline"], # Decreasing size
            ["	",               "deletechar"],
            ["    ",             "deletechar"]
        ]

        print("Revamping files to make it compatible with C++...")
        shutil.copytree("assets/", "output/", dirs_exist_ok=True)
        for files in glob.glob("output/src/**"):
            # skip files starting with "haxe_"
            if "haxe_" in files:
                continue

            print(files.split("\\")[1])
            f = open(files, "r", encoding="utf-8")
            c = f.read().splitlines()
            f.close()

            c[0] = "// Generated using reflaxe, reflaxe.CPP and Haxe3DS Compiler\n" + c[0]

            ln = 0
            for _ in range(len(c)):
                shouldSkip = False
                for bl in blockedStuff:
                    if bl in c[ln]:
                        shouldSkip = True
                        break
                if not shouldSkip:
                    for repl in replacers:
                        if repl[0] in c[ln]:
                            if repl[1].startswith("deleteline"):
                                c[ln] = ""
                            elif repl[1].startswith("deletechar"):
                                c[ln] = c[ln].replace(repl[0], "")
                            c[ln] = c[ln].replace(repl[0], repl[1])
                            continue
                if len(c[ln]) != 0:
                    ln += 1
                else:
                    del c[ln]

            with open(files, "w", encoding="utf-8") as f:
                f.write('\n'.join(c))

        for file in ["Makefile", "resources/AppInfo"]:
            c = open(f"output/{file}", "r").read()
            c = c.replace("[TITLE_JSON]",       jsonStruct["metadata"]["title"])
            c = c.replace("[DESCRIPTION_JSON]", jsonStruct["metadata"]["description"])
            c = c.replace("[AUTHOR_JSON]",      jsonStruct["metadata"]["author"])

            with open(f"output/{file}", "w") as f:
                f.write(c)

        # assets from installed libs
        for lib in jsonStruct["settings"]["libraries"]:
            f = open(f".haxelib/{lib}/.current").read()
            if os.path.exists(f".haxelib/{lib}/{f}/assets"):
                shutil.copytree(f".haxelib/{lib}/{f}/assets", "output", dirs_exist_ok=True)

        print("\nDone! Compiling...")

        make = jsonStruct["settings"]["makeAs"]
        os.chdir("output")
        if os.system(f"make {make}") != 0:
            print("Failed to compile!")
            sys.exit(1)

        os.chdir("output")
        print(f"Successfully Compiled in {round(time.time() - oldTime, 5)} seconds!!")
        ip:str = jsonStruct["settings"]["3dsIP"]
        if len(ip) > 7 and len(ip.split(".")) == 4:
            if make == "3dsx":
                os.system(f"3dslink -a {ip} output.3dsx")
            else:
                os.system(f"curl --upload-file output.{make} \"ftp://{ip}:5000/cia/\"")
        else:
            os.system(f"output.3dsx")

        sys.exit(0)