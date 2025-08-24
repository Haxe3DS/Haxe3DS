<p align="center">
  <a href="https://github.com/NAEL2XD/Haxe3DS">
    <img src="logo.png" alt="Haxe3DS" width="600">
  </a>
</p>

<p align="center">
Ever wanted to make 3DS Homebrew apps without excessive use of middle level language (C/C++)? Well this library is for you!!!
</p>

# How does it work?

This make uses of [reflaxe](https://github.com/SomeRanDev/reflaxe) and [reflaxe.cpp](https://github.com/SomeRanDev/reflaxe.CPP) which can read and compile haxe code to c++ outputted code so that the compiler can understand and compile to 3dsx! This was done with lots of love (and rage) to make this program so i hope i can get some support.

# INSTALLATION:

1. Open up terminal, and type `haxelib git haxe3ds https://github.com/NAEL2XD/Haxe3DS.git`, it will also install other libraries for it to work correctly!
3. Create a new Haxe Project specifically for creating your 3DS Applications, or download `template.zip` in the root of the repo and extract it.
3. Get the build.py, by going to `assets` dir and copying `build.py` and pasting to your project
4. Open up Terminal and type `python build.py -g`
5. (Optional) Set up your configs on 3dsSettings.json
6. For the moment of truth, type `python build.py -c`, assuming you have source/Main.hx
7. If you done everything correctly, it should fully compile code successfully and launch the application (or uses 3dslink/curl to transfer the file).

# Credits:

- [DSHaxe](https://github.com/MochaIcedTea/DSHaxe) for some of the example reflaxe code.
- [reflaxe](https://github.com/SomeRanDev/reflaxe) and [reflaxe.CPP](https://github.com/SomeRanDev/reflaxe.CPP) for making this possible.
- [devkitPro](https://github.com/devkitPro/libctru) for making homebrew amazing (and for [libctru](https://github.com/devkitPro/libctru)).
- [HaxeCompileU](https://github.com/Slushi-Github/hxCompileU) for a really great wii u compiler that i got interested for it.