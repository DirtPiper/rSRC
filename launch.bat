@ECHO OFF

:begin
set /p input="rSRC> "

for %%i in (%input%) do (
  IF "%%i"=="map" ( GOTO map )
  IF "%%i"=="listmaps" ( GOTO listmaps )
  IF "%%i"=="mkmap" ( GOTO mkmap )
  IF "%%i"=="edit" ( GOTO edit )
  IF "%%i"=="connect" ( GOTO connect )
)

IF "%input%"=="help" (
ECHO Welcome to the rSRC terminal! Here's some commands to get you started:
ECHO.
ECHO help			displays this information
ECHO.
ECHO map mapname		starts rSRC and automatically loads the specified map
ECHO.
ECHO listmaps		displays all maps in the map directory
ECHO.
ECHO mkmap mapname		creates a new, empty map with the specified name
ECHO.
ECHO edit mapname		opens a map specifically for editing and automatically 
ECHO 			loads the rSRC developer toolkit
ECHO.
ECHO connect ip port		connects to an rSRC server being hosted at 
ECHO 			that address on that port 
ECHO.
ECHO exit			exits the terminal
ECHO.
ECHO.
GOTO begin
)

IF "%input%"=="exit" (
EXIT
)

ECHO Unknown command!
GOTO begin

:map
ECHO Starting rSRC...
RobloxApp.exe -script print("dofile('rbxasset://rSRC_modules/main.lua')") -script print("game:Load('rbxasset://rSRC_maps/%input:~4%.rbxl')") 
GOTO begin


:listmaps
for %%a in ("content\rSRC_maps\*") do @echo %%~na
GOTO begin

:mkmap
ECHO Making map...
ECHO ^<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation=" http://www.roblox.com/roblox.xsd" version="4"^> ^</roblox^> >>content/rSRC_maps/%input:~6%.rbxl
ECHO Made %input:~5%.rbxl!
GOTO begin


:edit
ECHO Starting rSRC editor...
RobloxApp.exe content/rSRC_maps/%input:~5%.rbxl
GOTO begin




:connect
ECHO Sorry, networking hasn't been done yet!
GOTO begin
