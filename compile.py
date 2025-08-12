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
        "makeAs": "cia"
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
        
        os.system("cls")
        if not os.path.exists("3dsSettings.json"):
            print("3dsSettings.json doesn't exist!! Consider generating the Json!")
            sys.exit(1)

        with open("3dsSettings.json", "r") as f:
            jsonStruct = json.load(f)

        if not os.path.exists("build.hxml"):
            with open("build.hxml", "w") as f:
                f.write("""-cp source
-main Main

-lib reflaxe.cpp

-D cpp-output=output
-D mainClass=Main
-D cxx-no-null-warnings
-D keep-unused-locals
-D keep-useless-exprs
-D cxx_callstack""")
                
        if jsonStruct["settings"]["deleteTempFiles"] == True and os.path.exists("output"):
            shutil.rmtree("output")

        if os.system("haxe build.hxml") != 0:
            print("Error! Stopping...")
            sys.exit(1)

        blockedStuff = [
            "throw haxe::Exception"
        ]

        print("Revamping files to make it compatible with C++...")
        os.system('xcopy /E "./assets" "./output" /Y ')
        for files in glob.glob("output/src/**"):
            # skip files starting with "haxe_"
            if files.split("\\")[1].startswith("haxe_"):
                continue

            f = open(files, "r")
            c = f.read().splitlines()
            f.close()

            shouldSkip = False
            for ln in range(len(c)):
                for bl in blockedStuff:
                    if bl in c[ln]:
                        shouldSkip = True
                        break
                if not shouldSkip:
                    c[ln] = c[ln].replace("std::nullopt", "NULL")

            with open(files, "w") as f:
                f.write('\n'.join(c))

        for file in ["Makefile", "resources/AppInfo"]:
            c = open(f"output/{file}", "r").read()
            c = c.replace("[TITLE_JSON]",       jsonStruct["metadata"]["title"])
            c = c.replace("[DESCRIPTION_JSON]", jsonStruct["metadata"]["description"])
            c = c.replace("[AUTHOR_JSON]",      jsonStruct["metadata"]["author"])

            with open(f"output/{file}", "w") as f:
                f.write(c)

        print("Done!")

        make = jsonStruct["settings"]["makeAs"]
        if os.system(f"cd output & make {make}") != 0:
            print("Failed to compile!")
            sys.exit(1)

        print(f"Successfully Compiled in {round(time.time() - oldTime, 5)} seconds!!")
        ip:str = jsonStruct["settings"]["3dsIP"]
        if len(ip) > 7 and len(ip.split(".")) == 4:
            if make == "3dsx":
                os.system(f"cd output/output & 3dslink -a {ip} output.3dsx")
            else:
                os.system(f"curl --upload-file output/output/output.{make} \"ftp://{ip}:5000/cia/\"")
        else:
            os.system(f"cd output/output & output.3dsx")

        sys.exit(0)