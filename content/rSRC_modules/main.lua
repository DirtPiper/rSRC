playbin = game:GetObjects("rbxasset://rSRC_modules/playbin.rbxm")
playbin[1].Parent = game.StarterPack
playbin[2].Parent = game.StarterPack
playbin[3].Parent = game.StarterPack
playbin[4].Parent = game.StarterPack
playbin[5].Parent = game.StarterPack
playbin[6].Parent = game.StarterPack
raycast = game:GetObjects("rbxasset://rSRC_modules/raycasting.rbxm")
raycast[1].Parent = Workspace
rSRC_modules = game:GetObjects("rbxasset://rSRC_modules/modules.rbxm")
rSRC_modules[1].Parent = Workspace
rSRC_main = game:GetObjects("rbxasset://rSRC_modules/rSRC.rbxm")
rSRC_main[1].Parent = Workspace

rserv = game:GetService("RunService")
rserv:Run()
player = game.Players:CreateLocalPlayer(0)
player:LoadCharacter()


