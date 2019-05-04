playbin = game:GetObjects("rbxasset://rSRC_modules/playbin.rbxm")
playbin[1].Parent = game.StarterPack
playbin[2].Parent = game.StarterPack
playbin[3].Parent = game.StarterPack
playbin[4].Parent = game.StarterPack
playbin[5].Parent = game.StarterPack
playbin[6].Parent = game.StarterPack
rSRC_modules = game:GetObjects("rbxasset://rSRC_modules/modules.rbxm")
rSRC_modules[1].Parent = Workspace
rSRC_main = game:GetObjects("rbxasset://rSRC_modules/rSRC_merged.rbxm")
rSRC = rSRC_main[1]
rSRC.Parent = nil
player = game.Players:CreateLocalPlayer(0)
player:LoadCharacter()
rserv = game:GetService("RunService")
rserv:Run()
fixed = false
count = 0

function counter(int)
	if int == 5 then
		rSRC.Parent = Workspace
	end
end

Workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
rserv.Stepped:connect(function(a) counter(count) count = count + 1 end)