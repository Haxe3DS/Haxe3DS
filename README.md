<p align="center">
  <a href="https://github.com/NAEL2XD/Haxe3DS">
    <img src="logo.png" alt="Haxe3DS" width="500">
  </a>
</p>

<small>Logo by *[avie](https://github.com/h3ath3rr)*</small>

Transpile and then Compile Haxe Code to 3DS Applications (3DSX or CIA) with easy documentation and some nifty useful tools (and too many services).

The goal is to implement every single libctru functions to here and make as fewer functions and as more documentive to make homebrew applications easier, some will be in separate functions, because libctru are just pure lazy slog 🐌

# How does it work?

This makes use of [reflaxe](https://github.com/SomeRanDev/reflaxe) && [reflaxe.CPP](https://github.com/SomeRanDev/reflaxe.CPP) which can *Read* and *Transpile* Haxe Code to C++ Code so that the G++ Compiler can Understand and Compile to 3DSX or CIA! This was done with lots of love (and rage) to make this library so I hope I can get some support.

By the way, It's supposed to *make* Homebrew Applications Easier, i'm not implementing all of them in the header file and just call it a day.

Note: This is **ONLY** tested on 4.3.2 and you can try testing if it works on 5.0.0 but it's solely absent for now.

# INSTALLATION:

[See this to install Haxe3DS Properly.](https://github.com/NAEL2XD/Haxe3DS/wiki/Haxe3DS-Installation)

# Additional libraries:

- [CitroEngine](https://github.com/NAEL2XD/CitroEngine) - A library to make 3DS GUI Games, and is based on [HaxeFlixel](https://haxeflixel.com/) (and also uses [Citro2D](https://github.com/devkitPro/citro2d) && [Citro3D](https://github.com/devkitPro/citro3d)).

# Credits:

- [avie](https://github.com/h3ath3rr) for the logo, thank you! <3 <3
- [DSHaxe](https://github.com/MochaIcedTea/DSHaxe) for some of the example reflaxe code.
- [reflaxe](https://github.com/SomeRanDev/reflaxe) and [reflaxe.CPP](https://github.com/SomeRanDev/reflaxe.CPP) for making this possible.
- [devkitPro](https://github.com/devkitPro/libctru) for making homebrew amazing (and for [libctru](https://github.com/devkitPro/libctru)).
- [HaxeCompileU](https://github.com/Slushi-Github/hxCompileU) for a really great wii u compiler that i got interested for it.
- [3DBrew](https://www.3dbrew.org/) for the amount of documentation done to this system!
- [Nintendo Homebrew](https://discord.gg/nintendohomebrew) for helping me with `FS.mountSaveData` and `FS.flushAndCommit`. Y'all are amazing <3