# Haxe3DS - Now in a library!!!

Ever wanted to make 3DS Homebrew apps? Well i guess this library is for you!!!

This make uses of [reflaxe](https://github.com/SomeRanDev/reflaxe) and [reflaxe.cpp](https://github.com/SomeRanDev/reflaxe.CPP) and thanks to them so i don't write a whole library for it.

# INSTALLATION:

1. Open up terminal, and type `haxelib git haxe3ds https://github.com/NAEL2XD/Haxe3DS.git`, it will also install other libraries for it to work correctly!
2. Go to this repo: https://github.com/NAEL2XD/Haxe3DS-Setup
3. Either download the .exe (compile.py is the source)
4. Create a new Haxe Project specifically for creating your 3DS Applications, or download `template.zip` in the root of the repo and extract it.
5. Place your downloaded exe (or py) to one of your newly made haxe projects.
6. Open up Terminal and type `build -g` (`python compile.py -g`)
7. (Optional) Set up your configs on 3dsSettings.json
8. For the moment of truth, type `build -c` (`python compile.py -c` if using python version), assuming you have source/Main.hx
9. If you done everything correctly, it should fully compile code successfully.

# Credits:

3DS Compiler was inspired by [HaxeCompileU](https://github.com/Slushi-Github/hxCompileU) so i had to make it my own to make it work for 3DS.

[devkitPro](https://devkitpro.org/) for [libctru](https://github.com/devkitPro/libctru) (MAN Y'ALL ARE GOATS)
