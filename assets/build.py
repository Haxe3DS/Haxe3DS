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
        "deleteTempFiles": True,
        "makeAs": "3dsx",
        "libraries": ["haxe3ds"],
        "3dslink": {
            "ip": "0.0.0.0",
            "debugMode": False,
            "openEmuIfTransferFailed": False
        }
    },
    "metadata": {
        "title": "Haxe3DS",
        "description": "Made with <3 using Haxe!",
        "author": "Author"
    }
}

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("""usage: Hx3DSCompiler [-g] [-c] [-e]

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

    elif "-c" in arg:
        oldTime = time.time()
        
        if not os.path.exists("3dsSettings.json"):
            print("3dsSettings.json doesn't exist!! Consider generating the Json!")
            sys.exit(1)

        def read(file:str) -> str:
            c = ""
            with open(file, "r", encoding="utf-8") as f:
                c = f.read()
                f.close()
            return c
        
        def write(file, c):
            with open(file, "w", encoding="utf-8") as f:
                f.write('\n'.join(c) if type(c) == list else c)
                f.close()

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
            ["_gthis",   "this"]        # Known to throw Exceptions
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
                ln += 1

            write(files, c)

        serverMode = "-s" if jsonStruct["settings"]["3dslink"]["debugMode"] else ""
        if serverMode == "-s":
            lol = read('output/src/_main_.cpp')
            l = lol.index("_Main::Main_Fields_::main();")-1
            dictation = list(lol)
            dictation[0] = "#include <3ds.h>\n#include <malloc.h> /"
            dictation[l] = 'u8* buf = (u8 *)memalign(0x20000, 0x1000);\nif (R_FAILED(socInit((u32 *)buf, 0x20000))) svcBreak(USERBREAK_PANIC);\nlink3dsStdio();'
            dictation[l+28] = ';socExit();\nfree(buf);'
            write("output/src/_main_.cpp", ''.join(dictation))
            print("d")

        # assets from installed libs
        for lib in jsonStruct["settings"]["libraries"]:
            f = read(f".haxelib/{lib}/.current")
            if os.path.exists(f".haxelib/{lib}/{f}/assets"):
                shutil.copytree(f".haxelib/{lib}/{f}/assets", "output", dirs_exist_ok=True)

        for file in ["Makefile", "resources/AppInfo"]:
            c = read(f"output/{file}")
            c = c.replace("[TITLE_JSON]",       jsonStruct["metadata"]["title"])
            c = c.replace("[DESCRIPTION_JSON]", jsonStruct["metadata"]["description"])
            c = c.replace("[AUTHOR_JSON]",      jsonStruct["metadata"]["author"])
            write(f"output/{file}", c)

        finished = False
        tries = 1
        def thr():
            estimate = 0
            for i in ["src", "include"]: estimate += len(glob.glob(f"{i}/**", recursive=True))
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

            fc:dict = {}
            cc = []
            def create(ln:str) -> tuple:
                global cc
                lc = 0
                l = []
                try:
                    l = ln.split(":")
                    l[1] = f"{l[0]}:{l[1]}"
                    lc = int(l[2])-1
                    if l[1] not in fc:
                        v = read(l[1]).splitlines()
                        fc[l[1]] = [v, v.copy()]
                except ValueError:
                    return None, None
                
                return lc, l
                
            try:
                for ln in stderr.splitlines():
                    if any(x in ln for x in ["/devkitPro/libctru/", "/arm-none-eabi/include/"]): # dangerous, so i added a check
                        continue

                    if ": error: " in ln:
                        lc, l = create(ln)
                        exp = "expected ';' before" in ln
                        lnk = fc[l[1]][0]

                        if "cannot convert 'const std::nullopt_t' to " in ln:
                            lnk[lc] = lnk[lc].replace("std::nullopt", "NULL")
                        elif "expected ',' or ';' before" in ln or exp:
                            if not exp: lc -= 1
                            lnk[lc] += ";"
                        elif "no matching function for call to" in ln:
                            lnk[lc] = lnk[lc].replace(";", "(nullptr);")
                        elif "conversion from '" in ln:
                            lol = lnk[lc]
                            name = lol[lol.rfind(" ")+1:lol.find(";")]
                            lnk[lc] = lnk[lc].replace(name, f'std::dynamic_pointer_cast{lol[lol.find("<"):lol.rfind(">")+1]}({name})')
                        elif "' is not a member of '" in ln:
                            print("got!")
                            nameof = ln[ln.find("r: '")+4:ln.rfind("' is")]
                            count = len(lnk)
                            num = lc
                            while lc < count:
                                if f" {nameof} {{" in lnk[lc]:
                                    stack = []
                                    def app():
                                        global stack
                                        stack.append(lnk[lc])
                                        del lnk[lc]

                                    while lnk[lc] != "};": #class end
                                        app()
                                    app()

                                    lc = num
                                    while not lnk[lc].startswith("namespace"):
                                        lc -= 1

                                    lnk[lc] += f'\n{"\n".join(stack)}'
                                    break
                                
                                lc += 1

                    elif ": note: " in ln:
                        lc, l = create(ln)
                        hFile = l[1].replace(".cpp", ".h").replace("src", "include")
                        lnk = fc[l[1]][0]

                        if "note: candidate 1: 'template<class Dyn1, class Dyn2>" in ln:
                            bartSimpson = read(hFile)
                            for i in [f"Dyn{x}" for x in range(10)]:
                                bartSimpson = bartSimpson.replace(i, "haxe::Dynamic")
                            fc[l[1]][0] = bartSimpson.split("\n")
                            del fc[l[1]][0][lc-1]
            except ValueError: # Linker Error
                pass

            redo = False
            for i in fc.keys():
                if fc[i][0] != fc[i][1]:
                    write(i, fc[i][0])
                    print(f"Error ({i}) is fixed. Recompiling...")
                    redo = True
            
            if not redo:
                finished = True
                print(f"Compile Failure: STDERR:\n{stderr}")
                exit(1)
            tries += 1

        finished = True
        os.chdir("output")
        print(f"Successfully Compiled in {round(time.time() - oldTime, 5)} seconds!!")
        ip:str = jsonStruct["settings"]["3dslink"]["ip"]
        if len(ip) > 7 and len(ip.split(".")) == 4:
            if make == "3dsx":
                if os.system(f"3dslink -a {ip} {serverMode} output.3dsx") != 0 and jsonStruct["settings"]["3dslink"]["openEmuIfTransferFailed"]:
                    os.system("output.3dsx")
            else:
                os.system(f"curl --upload-file output.{make} \"ftp://{ip}:5000/cia/\"")
        else:
            os.system("output.3dsx")

    elif "-e" in arg:
        a = ""
        for x in sys.argv:
            if x.startswith("0x"):
                a += f"{x} "
        sys.exit(os.system(f"arm-none-eabi-addr2line -i -p -s -f -C -r -e output/output/output.elf -a {a}"))
    
    sys.exit(0)