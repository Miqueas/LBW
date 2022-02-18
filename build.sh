#!/usr/bin/bash

Dim="\e[0;2m"
Bold="\e[0;1m"
BRed="\e[0;1;31m"
BGreen="\e[0;1;32m"
Clear="\e[0m"

err() { echo -e "$Dim[${BRed}Error$Dim]:$Clear ${Bold}$@$Clear"; }
p() { echo -e "$Dim[${BGreen}Task$Dim]:$Clear ${Bold}$@$Clear"; }

Version=$1
declare Bits

case $Version in
  5.0* | 4* | 3* | 2* | 1* )
    err "this script only works for Lua 5.1+"
    exit 1
    ;;
esac

# Ensures to pass a correct version
if [[ ! $(echo $Version | grep -P "[0-9]\.[0-9]\.[0-9]") ]]; then
  err "version must be in format: v.v.v"
  exit 2
fi

case $MSYSTEM in
  MINGW32 ) Bits="32" ;;
  MINGW64 ) Bits="64" ;;
esac

declare Copyright
declare NSIScriptContent

FSVersion="$(echo $Version | sed 's/\.//g')"
SVersion="$(echo $FSVersion | sed 's/.$//')"
TarFilename="lua-$Version.tar.gz"
TarURL="https://www.lua.org/ftp/$TarFilename"
TarFolder="lua-$Version"
WorkFolder="$TarFolder-$Bits"
ZipFilename="Lua_v${FSVersion}_$Bits-Bits.zip"
NSIBaseScript=$(cat "Base.nsi")
NSIScriptFilename="Lua_v${FSVersion}_$Bits-Bits.nsi"
BinFiles=(
  [lua]="lua$SVersion.exe"
  [luac]="luac$SVersion.exe"
  [dll]="lua$SVersion.dll"
)

# This versions of Lua doesn't provide a Lua compiler in mingw
if [[ $FSVersion == "511" ]] || [[ $FSVersion == "510" ]]; then
  unset BinFiles[luac]
fi

if [[ $FSVersion == "510" ]]; then
  _V=$(echo $Version | sed 's/\..$//')
  p "wget https://www.lua.org/ftp/lua-$_V.tar.gz"
  # wget https://www.lua.org/ftp/lua-$_V.tar.gz
  p "tar -xf lua-$_V.tar.gz"
  # tar -xf lua-$_V.tar.gz
  p "mv lua-$_V/ $WorkFolder/"
  # mv lua-$_V/ $WorkFolder/
else
  p "wget $TarURL"
  # wget $TarURL
  p "tar -xf $TarFilename"
  # tar -xf $TarFilename
  p "mv $TarFolder/ $WorkFolder/"
  # mv $TarFolder/ $WorkFolder/
fi

p "cd $WorkFolder/"
# cd $WorkFolder/
p "make mingw"
# make mingw
p "cp src/*.exe ."
# cp src/*.exe .
p "cp src/*.dll ."
# cp src/*.dll .
p "mv ${BinFiles[lua]:0:3}.exe ${BinFiles[lua]}"
# mv "${BinFiles[lua]:0:3}.exe" ${BinFiles[lua]}

if [[ $FSVersion != "511" ]] || [[ $FSVersion != "510" ]]; then
  p "mv ${BinFiles[luac]:0:4}.exe ${BinFiles[luac]}"
  # mv "${BinFiles[luac]:0:4}.exe" ${BinFiles[luac]}
fi

p "zip $ZipFilename *.exe *.dll"
# zip $ZipFilename *.exe *.dll
p "mv $ZipFilename .."
# mv $ZipFilename ..

NSIScriptContent=$(echo $NSIBaseScript | sed -b "s/\%X\.X\.X\%/$Version/g")
echo $NSIScriptContent > $NSIScriptFilename