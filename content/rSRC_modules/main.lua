playbin = game:GetObjects("rbxasset://rSRC_modules/playbin.rbxm")
playbin[1].Parent = game.StarterPack
playbin[2].Parent = game.StarterPack
playbin[3].Parent = game.StarterPack
playbin[4].Parent = game.StarterPack
playbin[5].Parent = game.StarterPack
playbin[6].Parent = game.StarterPack
raycast = game:GetObjects("rbxasset://rSRC_modules/raycasting.rbxm")
raycast[1].Parent = Workspace
rSRC_main = game:GetObjects("rbxasset://rSRC_modules/rSRC.rbxm")
rSRC_main[1].Parent = Workspace

game.Players:CreateLocalPlayer(0)
game.Players.Player:LoadCharacter()


