#!/usr/bin/bash

Dim="\e[0;2m"
Bold="\e[0;1m"
BRed="\e[0;1;31m"
BBlue="\e[0;1;34m"
BGreen="\e[0;1;32m"
Clear="\e[0m"

err() { echo -e "$Dim[${BRed}Error$Dim]:$Clear ${Bold}$@$Clear"; }
t() { echo -e "$Dim[${BGreen}Task$Dim]:$Clear ${Bold}$@$Clear"; }
i() { echo -e "$Dim[${BBlue}Info$Dim]:$Clear ${Bold}$@$Clear"; }

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
NSIBaseScript="Base.nsi"
NSIScriptFilename="Lua_v${FSVersion}_$Bits-Bits.nsi"
declare -A BinFiles=(
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
  t "wget https://www.lua.org/ftp/lua-$_V.tar.gz"
  wget https://www.lua.org/ftp/lua-$_V.tar.gz
  t "tar -xf lua-$_V.tar.gz"
  tar -xf lua-$_V.tar.gz
  t "mv lua-$_V/ $WorkFolder/"
  mv lua-$_V/ $WorkFolder/
else
  t "wget $TarURL"
  wget $TarURL
  t "tar -xf $TarFilename"
  tar -xf $TarFilename
  t "mv $TarFolder/ $WorkFolder/"
  mv $TarFolder/ $WorkFolder/
fi

t "cd $WorkFolder/"
cd $WorkFolder/
t "make mingw"
make mingw
t "cp src/*.exe ."
cp src/*.exe .
t "cp src/*.dll ."
cp src/*.dll .
t "mv ${BinFiles[lua]:0:3}.exe ${BinFiles[lua]}"
mv "${BinFiles[lua]:0:3}.exe" ${BinFiles[lua]}

if [[ $FSVersion != "511" ]] && [[ $FSVersion != "510" ]]; then
  t "mv ${BinFiles[luac]:0:4}.exe ${BinFiles[luac]}"
  mv "${BinFiles[luac]:0:4}.exe" ${BinFiles[luac]}
fi

t "zip $ZipFilename *.exe *.dll"
zip $ZipFilename *.exe *.dll
t "mv $ZipFilename .."
mv $ZipFilename ..
t "cd .."
cd ..

# ----------------------------
# Installer specific commands

# The sed script used to write the NSIS script installer for the
# given Lua version
SedScript="s/\%X\.X\.X\%/$Version/g;
s/\%AA\%/$Bits/g;
s/\%FSV\%/$FSVersion/g;
s/\%SV\%/$SVersion/g;"

LuacSupportMsg="; This version of Lua doesn't provide a 'luac' binary"
LuacFile="File \"$WorkFolder\\\\${BinFiles[luac]}\""
LuacDel="Delete \"\$INSTDIR\\\\${BinFiles[luac]}\""

if [[ $FSVersion == "511" ]] || [[ $FSVersion == "510" ]]; then
  SedScript+=" s/\%LUAC_INST_FILE\%/$LuacSupportMsg/g;"
  SedScript+=" s/\%LUAC_DEL_FILE\%/$LuacSupportMsg/g;"
else
  SedScript+=" s/\%LUAC_INST_FILE\%/$LuacFile/g;"
  SedScript+=" s/\%LUAC_DEL_FILE\%/$LuacDel/g;"
fi

LegalCopy=$(grep -Px "Copyright \(C\) [0-9]{0,4}\-[0-9]{0,4} Lua\.org\, PUC-Rio\." LuaLicense)
SedScript+=" s/\%LEGAL\_COPY\%/$LegalCopy/g;"

case $Bits in
  32 ) SedScript+=" s/\%PROGRAM\_FILES\%/\$PROGRAMFILES/g" ;;
  64 ) SedScript+=" s/\%PROGRAM\_FILES\%/\$PROGRAMFILES64/g" ;;
esac

i "created sed script"
echo $SedScript > SedScript
i "created NSIS script for Lua $Version"
sed -f "SedScript" $NSIBaseScript > $NSIScriptFilename
t "makensis $NSIScriptFilename"
makensis $NSIScriptFilename
