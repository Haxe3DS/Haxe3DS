import json
import sys
import os
import shutil
import glob
import time
import subprocess
import threading

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
  -c      Compiles to 3DS with 3dsSettings.json provided
  -e      Helper function to search exception""")
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

        def read(file):
            c = ""
            with open(file, "r", encoding="utf-8") as f:
                c = f.read()
            return c
        
        def write(file, c):
            with open(file, "w", encoding="utf-8") as f:
                f.write('\n'.join(c) if type(c) == list else c)

        jsonStruct = json.loads(read("3dsSettings.json"))
        c = """-cp source
        -main Main
        -lib reflaxe.cpp
        """
        for libs in jsonStruct["settings"]["libraries"]:
            c += f"-lib {libs}\n"

        c += """
-D cpp-output=output
-D mainClass=Main
-D cxx-no-null-warnings
-D keep-unused-locals
-D keep-useless-exprs
-D cxx_callstack
-D cxx_inline_trace_disabled"""
        write("build.hxml", c)
                
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
            ["* _gthis", "deleteline"], # Known to throw Exceptions
            ["_gthis",   "this"],       # Known to throw Exceptions
            ["AnonStruct0::make();","Dynamic();"],        # Compiler failures
            ["HCXX_LINE",        "deleteline"], # Decreasing size
            ["HCXX_STACK_METHOD","deleteline"], # Decreasing size
            #["	",       "deletechar"],
            #["    ",     "deletechar"]
        ]

        print("Revamping files to make it compatible with C++...")
        shutil.copytree("assets/", "output/", dirs_exist_ok=True)
        for files in glob.glob("output/src/**"):
            # skip files starting with "haxe_"
            if "haxe_" in files:
                continue

            c = read(files).splitlines()
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

            write(files, c)

        if os.path.exists("output/include/dynamic/"):
            stuff2rem = ["haxe3ds_services_HID", "HxArray"]
            for hxfile in glob.glob("source/**.hx", recursive=True):
                c = read(hxfile)
                d = hxfile.split("\\")
                if "@:noDynGen" in c:
                    stuff2rem.append(d[len(d)-1][:-3])

            for file in stuff2rem:
                p = f"output/include/dynamic/Dynamic_{file}.h"
                if os.path.exists(p):
                    os.remove(p)

                p = p.replace("dynamic/Dynamic_", "")
                if os.path.exists(p):
                    c = read(p).splitlines()

                    for i, har in enumerate(c):
                        if har.startswith('#include "dynamic/'):
                            try:
                                while True:
                                    del c[i]
                            except IndexError:
                                break

                    write(p, c)

        for file in ["Makefile", "resources/AppInfo"]:
            c = read(f"output/{file}")
            c = c.replace("[TITLE_JSON]",       jsonStruct["metadata"]["title"])
            c = c.replace("[DESCRIPTION_JSON]", jsonStruct["metadata"]["description"])
            c = c.replace("[AUTHOR_JSON]",      jsonStruct["metadata"]["author"])
            write(f"output/{file}", c)

        # assets from installed libs
        for lib in jsonStruct["settings"]["libraries"]:
            f = open(f".haxelib/{lib}/.current").read()
            if os.path.exists(f".haxelib/{lib}/{f}/assets"):
                shutil.copytree(f".haxelib/{lib}/{f}/assets", "output", dirs_exist_ok=True)

        finished = False
        tries = 1
        def thr():
            estimate = 0
            for i in ["src", "include"]: estimate += len(glob.glob(f"{i}/**"))
            estimate = round(estimate / 1.19, 5)
            while not finished: print(f"Compile Status: OK, Time: {round(time.time() - oldTime, 5)} (Estimate: {estimate}), Tries: {tries}", end='\r')
            print(" " * (os.get_terminal_size().columns - 2), end='\r')

        print("\nDone! Compiling...")
        make = jsonStruct["settings"]["makeAs"]
        os.chdir("output")
        threading.Thread(target=thr).start()

        while True:
            process = subprocess.Popen(f"make {make}", stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            _, stderr = process.communicate()

            if process.returncode == 0:
                break
            else:
                redo = False
                for ln in stderr.splitlines():
                    if ": error: " in ln:
                        l = ln.split(":")
                        l[1] = f"{l[0]}:{l[1]}"
                        lc = int(l[2])-1
                        c = read(l[1]).splitlines()
                        cc = c.copy()

                        exp = "error: expected ';' before" in ln
                        if "error: cannot convert 'const std::nullopt_t' to " in ln:
                            c[lc] = c[lc].replace("std::nullopt", "NULL")
                        elif "error: expected ',' or ';' before" in ln or exp:
                            if not exp: lc -= 1
                            c[lc] += ";"

                        if c != cc:
                            redo = True
                            write(l[1], c)
                            print(f"Error ({ln}) is fixed. Recompiling...")
                    
                if not redo:
                    finished = True
                    print(f"Compile Failure: STDERR:\n{stderr}")
                    exit(1)

                tries += 1

        finished = True
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

    elif "-e" in arg:
        a = ""
        for x in sys.argv:
            if x.startswith("0x"):
                a += f"{x} "

        sys.exit(os.system(f"arm-none-eabi-addr2line -i -p -s -f -C -r -e output/output/output.elf -a {a}"))