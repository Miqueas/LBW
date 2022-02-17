# Lua builds for Windows

This repo contains a set of Lua builds for Windows. You can found them in the "Releases" page in two formats:

  * .zip file: portable, just the Lua interpreter, compiler and .dll
  * .exe file: NSIS-based installer, contains the above and allows to add it to PATH

## About the installers

These .exe files provided here installs Lua in different base path depending of the permissions: if you run it with administrator rights, default path will be `C:\Program Files\Lua<Version>`, but if you run it as a normal user, default path will be `C:\Users\<YourUser>\AppData\Local\Lua<Version>`.

## Multiple lua installations

You can have, by example, Lua 5.1.x and Lua 5.3.x installed, and use it like (if you have them in `PATH`:

```
lua51 my_script.lua
lua53 my_script.lua
```

But with minor versions isn't possible (i.e., Lua 5.2.1 and Lua 5.2.3), the installer will just replace the files.

## Building

If you wanna try build an installer or something, you'll need [NSIS](http://nsis.sourceforge.io/), [MSYS](https://www.msys2.org/) (or a MinGW toolchain, idk I made it in MSYS) and with MSYS you'll need GCC, Make and Tar. Then:

```
wget <url-to-your-lua-version>
tar -xf <lua.tar.gz>
cd <lua-folder>
make mingw
cp src/*.exe .
cp src/*.dll .
mv lua.exe lua<version>.exe
# if luac.exe exists:
mv luac.exe luac<version>.exe
```

Now, to make the installer, take any .nsi file, and edit this lines:

  * __4__: the `OutFile` command tells the compiler the filename where to build the installer, the format I use is: `Lua_v<Version>_x<Arch>-Bits.exe`. For the Arch I just put if it's 64 or 32 bits :+1:
  * __6__: the `Name` is just a label in the titlebar, change it to whatever you want (I just put `Lua <Version>`)
  * __11__: the "product version", is just a thing that you can show in "File" > "Properties" > "Details"
  * __37__: change the path in `LicenseData` to the path of the folder where it's the `COPYRIGHT` file
  * __42__: in `DirText` change the Lua version
  * __62__ and __66__: in `StrCpy` change the installation path (you may want to change only the part after the `\`)
  * __81__ and __82__: do the same as in line __37__
  * __83__: `icon.ico` file must be in the same folder as the .nsi file
  * __96__ and __104__: change the Lua version (at the end of the line)
  * __121__: change the Lua version

and that's it, if you did it well, the .nsi script will compile using the `makensis` tool.