--[[ 
	This is an early consolidated build of rSRC, made so that all needed code for rSRC is together in one place. ENTER THIS HELLHOLE
	AT YOUR OWN RISK.

	REQUIREMENTS:
		This Script
		RayCasting module (should specify that it is compatible with rSRC)
		Model parented to Workspace named 'Brushes' containing all parts you want the player to be able to walk on
		Model parented to Workspace named 'rSRC_Modules' containing valid rSRC_Modules (there will be a template or tutorial available)
		'Play' Hopperbin parented to StarterPack containting ConnectionScript, ControlScript, and WeaponScript

	rSRC DOES NOT WORK WITH MULTIPLAYER. THIS IS INTENDED PURELY FOR SINGLEPLAYER GAMES MADE WITH THE DECEMBER 17
	2008 CLIENT.

	rSRC alpha v0.4.3

	What has been done so far:

		Raycasting
		Collision-hulls
		Movement
		Airstrafing & Bunnyhopping
		Viewmodels (currently being redone)
		Brush-based maps
		Raycasting optimization
		Weapons
		Basic lighting changes and triggers
		Support for modular weapons (being redone as rSRC_Modules)
		basic rSRC_Modules - keybound actions only so far
		
	To do:	
	
		Player Models w/ animation
		Respawn system
--]]

while game.Workspace.RayCasting.loaded.Value == false do  --Waits for the RayCasting module to be loaded before starting rSRC
	wait()
end

rSRC_Modules = script.Parent.rSRC_Modules:GetChildren()
keybinds = {["q"] = nil, ["e"] = nil, ["r"] = nil, ["t"] = nil, ["y"] = nil, ["u"] = nil, ["p"] = nil, ["f"] = nil, ["g"] = nil, ["h"] = nil, ["j"] = nil, ["k"] = nil, ["l"] = nil, ["z"] = nil, ["x"] = nil, ["c"] = nil, ["v"] = nil, ["b"] = nil, ["n"] = nil, ["m"] = nil, }
weapons = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}

Hull = nil								--The player's collision hull
Humanoid = nil						--The player's Humanoid
movePos = nil							--A bodymover used when airstrafing
moveVel = nil							--A bodymover used when airstrafing
camera = game.Workspace.CurrentCamera 	--The current camera (might have to move to a localscript for multiplayer)
moveInputSumforward = 0				--Forward/Backward movement
moveInputSumside = 0					--Left/Right movement
moveValue = Vector3.new(0,0,0)			--The current input value
movementVelocityForce = 300000			--The amount of force applied when airstrafing
airAccelerate = 300						--Acceleration on the player when airstrafing
airMaxSpeed = 5						--Maximum velocity when airstrafing
isInAir = nil							--Are we airborne?
canJump = nil							--Can we jump?
HullMade = false						--Has a Hull been generated?
fp1 = Instance.new("Message")			--These messages are used for the zoomout warning
fp2 = Instance.new("Message")
fp3 = Instance.new("Message")
fp4 = Instance.new("Message")
fp5 = Instance.new("Message")
fp6 = Instance.new("Message")
fp7 = Instance.new("Message")
Button1Down = nil
KeyPressed = nil
MouseCFrame = nil
MouseTarget = nil

function makeHull(player)							--Give the player a collision hull
	Container = Instance.new("Model")				--Container model for the Hull
	Container.Name = player.Name					--Needed for the Player to be able to control the Hull
	Container.Controller = "Player"
	Hull = Instance.new("Part", Container)				--BodyHull
	Hull.Size = Vector3.new(3, 7.2, 3)
	Hull.BottomSurface = "Smooth"
	Hull.TopSurface = "Smooth"
	Hull.Friction = 0
	Hull.Elasticity = 0
	bg = Instance.new("BodyGyro", Hull)				--BodyMovers used later on  for moving the Player around
	bv = Instance.new("BodyVelocity", Hull)
	movePos = Instance.new("BodyPosition", Hull)
	movePos.Name = "MovePos"
	moveVel = Instance.new("BodyVelocity", Hull)
	moveVel.Name = "MoveVel"
	Humanoid = Instance.new("Humanoid", Container)
	canJump = Instance.new("BoolValue", Humanoid)		--BoolValues used when the Player jumps
	canJump.Name = "canJump"
	isInAir = Instance.new("BoolValue", Humanoid)
	isInAir.Name = "isInAir"
	head = Instance.new("Part", Container)				--The Player's head
	head.CFrame = CFrame.new(Hull.CFrame.p)
	head.Name = "Head"
	--head.Transparency = 1
	head.Size = Vector3.new(1, 1.2, 1)
	head.Elasticity = 0
	srcGrav = Instance.new("BodyForce", Hull)			--Emulates the gravity of the Source Engine
	srcGrav.Name = "SrcGrav"
	srcGrav.force = Vector3.new(0, 7840.64, 0)
	Container.Parent = game.Workspace
	neck = Instance.new("Weld", head)				--Attaches the Head to the BodyHull
	neck.Part0 = head
	neck.Part1 = Hull
	neck.C0 = CFrame.new(0, -2.8, 0)
	Hull.CFrame = CFrame.new(player.Character.Torso.Position)
	Humanoid.Health = Humanoid.MaxHealth
	Hull.Name = "Torso"
	camera.CameraSubject = Humanoid
	player.Character = Container						--Replaces the Player's default character with the Hull
	Humanoid.Health = Humanoid.MaxHealth
	HullMade = true
	Button1Down = player.Backpack.Button1Down
	KeyPressed = player.Backpack.KeyPressed
	MouseCFrame = player.Backpack.MouseCFrame
	MouseTarget = player.Backpack.MouseTarget
end

local h = game.Workspace:GetChildren()				--This does something. Don't fuck with it.
for i=1, #h do
	if h[i].className == "Camera" then
		if h[i].CameraSubject == Humanoid then
			camera = h[i]
		end
	end
end

function dot3d(a, b) --returns the dot product of two vectors
	return a.x * b.x + a.y * b.y + a.z * b.z;
end

function getYaw() --returns left/right rotation of the camera
	return camera.CoordinateFrame*CFrame.fromEulerAnglesXYZ(-getPitch(),0,0)
end


function getPitch() --returns up/down rotation of the camera
	return math.pi/2 - math.acos(dot3d(camera.CoordinateFrame.lookVector, Vector3.new(0,1,0)))
end 

function cFrameAngles(x, y, z) --returns a CFrame based on angles in radians
	return CFrame.new(0, 0, 0, math.cos(y) * math.cos(z), -1 * math.cos(y)*math.sin(z), math.sin(y), math.cos(z) * math.sin(x) * math.sin(y) + math.cos(x) * math.sin(z), math.cos(x) * math.cos(z) - math.sin(x) * math.sin(y) * math.sin(z), -1 * math.cos(z) * math.sin(x), math.sin(x) * math.sin(z) - math.cos(x) * math.cos(z) * math.sin(y), math.cos(z) * math.sin(x) + math.cos(x) * math.sin(y) * math.sin(z), math.cos(x) * math.cos(y))
end 

function getMovementVelocity(prevVelocity, accelerate, maxVelocity) --The velocity of the Hull while airstrafing
	local accelForward = camera.CoordinateFrame.lookVector * moveInputSumforward
	local accelSide = (getYaw() * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)).lookVector * moveInputSumside;
	local accelDir = (accelForward+accelSide).unit;
	if moveInputSumforward == 0 and moveInputSumside == 0 then --avoids divide 0 errors
		accelDir = Vector3.new(0,0,0);
		moveValue = Vector3.new(0, 0, 0)
	end
	
	local projVel =  dot3d(prevVelocity, accelDir);
	dt = updateDT
	local accelVel = accelerate * dt;
	
	if (projVel + accelVel > maxVelocity) then
		accelVel = math.max(maxVelocity - projVel, 0);
	end
	
	return prevVelocity + accelDir * accelVel;
end

function getMovementVelocityAirForce() --The force applied to the Hull while airstrafing
	local accelForward = camera.CoordinateFrame.lookVector * moveInputSumforward
	local accelSide = (getYaw() * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)).lookVector * moveInputSumside
	local accelDir = (accelForward+accelSide).unit
	if moveInputSumforward == 0 and moveInputSumside == 0 then
		accelDir = Vector3.new(0,0,0);
		moveValue = Vector3.new(0, 0, 0)
	end
	
	local xp = math.abs(accelDir.x)
	local zp = math.abs(accelDir.z)

	return Vector3.new(movementVelocityForce*xp,0,movementVelocityForce*zp)
end

function updateMoveInputSum()  --Front/Back and Left/Right movement.
	moveInputSumforward = -moveValue.z
	moveInputSumside = -moveValue.x
end

function avg(v) --For finding the average of a Vector3. I don't think I actually used it here.
	return (math.abs(v.x) + math.abs(v.y) + math.abs(v.z))/3
end

function setDeltaTime() --seconds
	local UpdateTime = tick() 
	if prevUpdateTime ~= nil then
		updateDT = (UpdateTime - prevUpdateTime)
	else
		updateDT = 1/60
	end
	prevUpdateTime = UpdateTime
end

function onStep()
		if(HullMade) then
			cameraLook = getYaw().lookVector	--The left/right rotation of the camera
			setDeltaTime()
			movementPosition = Hull.MovePos
			movementVelocity = Hull.MoveVel
			collider = Hull
			moveValue = getYaw():vectorToObjectSpace(Humanoid.WalkDirection) --This converts the WalkDirection from World Coords to Object Coords
			updateMoveInputSum()
			if (camera.CoordinateFrame.p - camera.Focus.p).magnitude > 2.4 then
				fp1.Text = "Camera too far out!"
				fp2.Text = "Camera too far out!"
				fp3.Text = "Camera too far out!"
				fp4.Text = "Camera too far out!"
				fp5.Text = "Camera too far out!"
				fp6.Text = "Camera too far out!"
				fp7.Text = "Camera too far out!"
			else
				fp1.Text = ""
				fp2.Text = ""
				fp3.Text = ""
				fp4.Text = ""
				fp5.Text = ""
				fp6.Text = ""
				fp7.Text = ""
			end
			local adjustedMoveValue = moveValue
			local ray1 = Ray.new(Hull.Position + Vector3.new(0, 0, 0), Vector3.new(0,-3.9,0)) --These rays test to see if the Hull is on the ground
 			local hit1 = ray1.Hit
			local ray2 = Ray.new(Hull.Position + Vector3.new(1.5, 0, 1.5), Vector3.new(0,-3.9,0))
 			local hit2 = ray2.Hit
			local ray3 = Ray.new(Hull.Position + Vector3.new(-1.5, 0, 1.5), Vector3.new(0,-3.9,0))
 			local hit3 = ray3.Hit
			local ray4 = Ray.new(Hull.Position + Vector3.new(-1.5, 0, -1.5), Vector3.new(0,-3.9,0))
 			local hit4 = ray4.Hit
			local ray5 = Ray.new(Hull.Position + Vector3.new(1.5, 0, -1.5), Vector3.new(0,-3.9,0))
 			local hit5 = ray5.Hit
			if hit1 ~= nil or hit2 ~= nil or hit3 ~= nil or hit4 ~= nil or hit5 ~= nil then --Is it on the ground?
				if isInAir.Value == true then
					Hull.Velocity = Vector3.new(Hull.Velocity.x, 0, Hull.Velocity.z) --Prevents the Hull from bouncing
				end
				canJump.Value = true --Tells the jump script that we can jump
				moveValue = getYaw():vectorToObjectSpace(Humanoid.WalkDirection)
				if isInAir.Value == false then
					movementVelocity.velocity = Vector3.new(Humanoid.WalkDirection.x * Humanoid.WalkSpeed, movementVelocity.velocity.y, Humanoid.WalkDirection.z * Humanoid.WalkSpeed) --Movement on the ground
					movementVelocity.maxForce = Vector3.new(40000, 0, 40000)
				end
				isInAir.Value = false --Grounded!
			end
			if hit1 == nil and hit2 == nil and hit3 == nil and hit4 == nil and hit5 == nil then --Is it in the air?
				isInAir.Value = true --Not grounded!
				canJump.Value = false --Tells the jump script not to allow jumping
				movementPosition.maxForce = Vector3.new()
				movementVelocity.velocity = getMovementVelocity(Hull.Velocity, airAccelerate, airMaxSpeed) --Controls while airborne
				movementVelocity.maxForce = getMovementVelocityAirForce()
			end
			if Humanoid.Jump == true and canJump.Value == true then
				Hull.BodyVelocity.maxForce = Vector3.new(0, 4e+004, 0)
				Hull.BodyVelocity.velocity = Vector3.new(Hull.BodyVelocity.velocity.x, 20, Hull.BodyVelocity.velocity.z)
				canJump.Value = false
				Humanoid.Jump = false
				isInAir.Value = true
				wait(.1)
				Hull.BodyVelocity.maxForce = Vector3.new(0, 0, 0)
				Hull.BodyVelocity.velocity = Vector3.new(Hull.BodyVelocity.velocity.x, 0, Hull.BodyVelocity.velocity.z)
			elseif Humanoid.Jump == true and canJump.Value == false then
				Humanoid.Jump = false
			end
		end
end

function init_modules()
	for i, v in pairs(rSRC_Modules) do
		print(i, v.Name)
		if string.sub(v.Name, 1, 3) == "ACT" then
			keybinds[v.KEYBIND.Value] = v
		end
	end
end

function onKeyPressed(key)
	if keybinds[key] ~= nil then
		keybinds[key].FIRED.Value = true
		keybinds[key].FIRED.Value = false
	end
end

function respawn(player)
	if player.Character:FindFirstChild("Torso") ~= nil then
		makeHull(player)
	end
end

function onPlayerAdded(player)
	makeHull(player)
	player.Changed:connect(function (property) respawn(player) end)
end 

wait()
numPlay = game.Players:GetChildren()
for i = 1, #numPlay do
	onPlayerAdded(numPlay[i])
end

init_modules()
game.Players.PlayerAdded:connect(onPlayerAdded)
game["Run Service"].Stepped:connect(onStep)
KeyPressed.Changed:connect(onKeyPressed)