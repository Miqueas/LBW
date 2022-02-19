# Lua builds for Windows

This repo contains a set of Lua builds for Windows. You can found them in the "Releases" page in two formats:

  * .zip file: portable, just the Lua interpreter, compiler and .dll
  * .exe file: NSIS-based installer, contains the above and allows to add it to PATH

## About the installers

These .exe files provided here installs Lua in different base path depending of the permissions: if you run it with administrator rights, default path will be `C:\Program Files\Lua<Version>`, but if you run it as a normal user, default path will be `C:\Users\<YourUser>\AppData\Local\Lua<Version>`.

## Multiple lua installations

You can have, by example, Lua 5.1.x and Lua 5.3.x installed, and use it like (if you have them in `PATH`):

```
lua51 my_script.lua
lua53 my_script.lua
```

But with minor versions isn't possible (i.e., Lua 5.2.1 and Lua 5.2.3), the installer will just replace the files.

## Pending

 - LuaJIT
 - Moonjit