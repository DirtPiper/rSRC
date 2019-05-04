playbin = game:GetObjects("rbxasset://rSRC_modules/playbin.rbxm") --the 'Play' hopperbin which is used to collect keyboard inputs
playbin[1].Parent = game.StarterPack
playbin[2].Parent = game.StarterPack
playbin[3].Parent = game.StarterPack
playbin[4].Parent = game.StarterPack
playbin[5].Parent = game.StarterPack
playbin[6].Parent = game.StarterPack
rSRC_modules = game:GetObjects("rbxasset://rSRC_modules/modules.rbxm") --rSRC modules (weapons, actions, etc.)
rSRC_modules[1].Parent = Workspace
rSRC_main = game:GetObjects("rbxasset://rSRC_modules/rSRC_merged.rbxm") --rSRC itself (contains the Raycasting module)
rSRC = rSRC_main[1]
rSRC.Parent = nil
player = game.Players:CreateLocalPlayer(0)
rserv = game:GetService("RunService")
rserv:Run()
fixed = false
count = 0
function counter(int) --Need to manually wait until the game has gone through 5 heartbeats, because wait() will crash the game when executed at this level
	if int == 5 then
		rSRC.Parent = Workspace	--This actually executes the rSRC script, nothing else will work
		player:LoadCharacter() --This is done after runtime to ensure the character loads on a spawn point
	end
end
rserv.Stepped:connect(function(a) counter(count) count = count + 1 end)
