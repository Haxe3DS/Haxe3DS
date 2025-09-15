<p align="center">
  <a href="https://github.com/NAEL2XD/Haxe3DS">
    <img src="logo.png" alt="Haxe3DS" width="600">
  </a>
</p>

<p align="center">
Ever wanted to make 3DS Homebrew apps without excessive use of middle level language (C/C++)? Well this library is for you!!!
</p>

Also a revival of the deleted repo named ***3DSHaxe*** by [MochaIcedTea](https://github.com/MochaIcedTea), now continued with more stuff coming it's way! If i do it.

## News! This library now has a discord server!

Join for some fun and learn more about Haxe3DS today! https://discord.gg/9w73WaXm64

# How does it work?

This make uses of [reflaxe](https://github.com/SomeRanDev/reflaxe) and [reflaxe.cpp](https://github.com/SomeRanDev/reflaxe.CPP) which can read and compile haxe code to c++ outputted code so that the compiler can understand and compile to 3dsx! This was done with lots of love (and rage) to make this program so i hope i can get some support.

Note: Tested **ONLY** on Haxe 4.3.2, I'm not planning to support Haxe 5+

# INSTALLATION:

Section I: Installing devkitPro first (needed for 3ds compiling):

1. Go to the official devkitPro site: https://devkitpro.org/wiki/Getting_Started
2. In the setup section, choose your following system and install devkitPro
3. (Optional if non windows gui) Check "3DS" for developement and install it.
4. Assuming you have msys2 installed from devkitPro, open a new cmd and input the following: `(dkp-)pacman -S 3ds-dev 3ds-portlibs` (the "dkp-" is for macos or linux only)

Section II: Project Setup & Compiling:

1. Open up terminal, and type `haxelib git haxe3ds https://github.com/NAEL2XD/Haxe3DS.git` and `haxelib git reflaxe.cpp https://github.com/NAEL2XD/reflaxe.CPP`, it will also install other libraries for it to work correctly!
2. Create a new Haxe Project specifically for creating your 3DS Applications, or download `template.zip` in the root of the repo and extract it.
3. Get the build.py, by going to `assets` dir and copying `build.py` and pasting to your project
4. Open up Terminal and type `python build.py -g`
5. (Optional) Set up your configs on 3dsSettings.json
6. For the moment of truth, type `python build.py -c`, assuming you have source/Main.hx
7. If you done everything correctly, it should fully compile code successfully and launch the application (or uses 3dslink/curl to transfer the file).

# Additional libraries:

- [CitroEngine](https://github.com/NAEL2XD/CitroEngine) - Make 3DS GUI Games easily.

# Credits:

- [DSHaxe](https://github.com/MochaIcedTea/DSHaxe) for some of the example reflaxe code.
- [reflaxe](https://github.com/SomeRanDev/reflaxe) and [reflaxe.CPP](https://github.com/SomeRanDev/reflaxe.CPP) for making this possible.
- [devkitPro](https://github.com/devkitPro/libctru) for making homebrew amazing (and for [libctru](https://github.com/devkitPro/libctru)).
- [HaxeCompileU](https://github.com/Slushi-Github/hxCompileU) for a really great wii u compiler that i got interested for it.
- [3DBrew](https://www.3dbrew.org/) for the amount of documentations done to this system!
- [Nintendo Homebrew](https://discord.gg/nintendohomebrew) for helping me with `FS.mountSaveData` and `FS.flushAndCommit`. Y'all are amazing <3