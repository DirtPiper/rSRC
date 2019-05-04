@ECHO OFF

set /p map="map "

ECHO Starting rSRC...

RobloxApp.exe -script print("dofile('rbxasset://rSRC_modules/main.lua')") -script print("game:Load('rbxasset://rSRC_maps/%map%.rbxl')") 