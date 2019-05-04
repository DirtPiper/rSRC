--[[
	COMPATIBLE WITH rSRC
	Originally made by RADIOAKTIIVINEN, altered slightly by DirtPiper to function in 2008.
	to use: In any script, instantiate a RayCast like so: 'ray = RayCast(Vector3 Start, Vector3 Direction, Int Maximum, Int Minimum)' 
	ray.Hit is the part that the ray hits (if any) and ray.Pos is the position that the ray hit the part.
	
	if your script uses raycasting and is not working consistently, try adding the following loop to the beginning:
	
	while game.Workspace.RayCasting.loaded.Value == false do
		wait()
	end

	It also semi-supports modern raycasting API, but will require some minor tweaking:
	
		local ray = Ray.new(Vector3 Start, Vector3 End)
		local hit, pos, normal, mat = Workspace:FindPartOnRay(ray, ignore, true, false)

	won't work, you have to change "Workspace:FindPartOnRay()" to "unpack(WorkspaceFindPartOnRay())".
	luckily this can be done simply by pressing ctrl+H to find and replace anything that needs to be patched.

	The current version will not actually return the normal, does not actually ignore things specified in "ignore", and always returns the material "Plastic".

	So, to use like modern Raycasting you must do

		local ray = Ray.new(Vector3 Start, Vector3 End)
		local hit, pos, normal, mat = unpack(WorkspaceFindPartOnRay(ray))

	Enjoy!

	In order to optimize rSRC, any parts that you want to be raycastable must be in a model in Workspace names "Brushes".
]]

local parts={}
local Accuracy=.2
_G.Ray = {}


function rootfindbricks(t,model)
if model.className=="Model" or model.className=="Workspace" then
model.ChildAdded:connect(function(np) rootfindbricks(t,np) end)
for i,v in pairs(model:GetChildren()) do
rootfindbricks(t,v)
end
elseif model.className == "Part" then
t[#t+1]=model
end
end

function _G.GetParts()
local ta={}
rootfindbricks(ta,game.Workspace.Brushes)
return ta
end

function _G.CleanTable(ta)
for i,v in pairs(ta) do
if v.Parent==nil then
ta[i]=nil
end
end
end

function _G.WorkspaceFindPartOnRay(ray)
	return _G.WorkspaceFindPartOnRay(ray, nil, false, false)
end

function _G.WorkspaceFindPartOnRay(ray, ignore)
	return _G.WorkspaceFindPartOnRay(ray, ignore, false, false)
end

function _G.WorkspaceFindPartOnRay(ray, ignore, a)
	return _G.WorkspaceFindPartOnRay(ray, ignore, a, false)
end

function _G.WorkspaceFindPartOnRay(ray, ignore, a, b)
	return {ray.Hit, ray.Pos, Vector3.new(0, 0, 0), "Plastic"}
end

function _G.Ray.new(Start, Dir)
	return _G.RayCast(Start, Dir, 1, 0)
end

function _G.RayCast(Start,Dir,MaxRange,MinRange) 

local Pos=Start+(Dir*MaxRange)
local HitPart=nil

for i,v in pairs(parts) do

if v.Parent~=nil then
local smd=v.Size.magnitude/2+Accuracy
local tm=(v.Position-Start).magnitude
local dc=(v.Position-Start)*Dir
if tm-smd<=(Pos-Start).magnitude and math.min(((tm*Dir)-v.Position+Start).magnitude*0.7,tm)<=smd then
if tm-smd<=MaxRange and (v:GetMass()>5 or tm>=MinRange) and (v.CanCollide==true or v.Parent:FindFirstChild("Humanoid")~=nil) and v.Name ~= "Hull" then
local Convert=v.CFrame:pointToObjectSpace(Start) ---UR MOM
local RConvert=nil
local DirC=v.CFrame:pointToObjectSpace(v.Position+Dir)
local MDirC=Vector3.new(math.abs(DirC.x),math.abs(DirC.y),math.abs(DirC.z))
local Result=false
local Temp=Convert
local Size=v.Size
local TempA=nil
local DSize=Size/2
local MCon=Vector3.new(math.abs(Convert.x),math.abs(Convert.y),math.abs(Convert.z))
local TCS=(MCon-DSize)/MDirC

Temp=Convert+TCS.x*DirC
TempA=Temp/DSize
if MCon.x>=DSize.x and math.abs(TempA.x)<=1.2 and math.abs(TempA.y)<=1.2 and math.abs(TempA.z)<=1.2 then
Result=true
else
Temp=Convert+TCS.y*DirC
TempA=Temp/DSize
if MCon.y>=DSize.y and math.abs(TempA.x)<=1.2 and math.abs(TempA.y)<=1.2 and math.abs(TempA.z)<=1.2 then
Result=true
else
Temp=Convert+TCS.z*DirC ----NO U
TempA=Temp/DSize
if MCon.z>=DSize.z and math.abs(TempA.x)<=1.2 and math.abs(TempA.y)<=1.2 and math.abs(TempA.z)<=1.2 then
Result=true
end
end
end

if Result==true then
RConvert=v.CFrame:pointToWorldSpace(Temp)
if (Start-Pos).magnitude>=(Start-RConvert).magnitude then
Pos=RConvert
HitPart=v
end

end
end
end
end
end
return {Hit=HitPart,Pos=Pos} ----ORLY


end

parts = GetParts()
script.loaded.Value = true


----MADE BY RADIOAKTIIVINEN
----Returns a table with 2 parts. 
----EXAMPLE:
----local result=RayCast(Gun.Handle,(Gun.Handle.Position.mouse.hit.p).unit,500)
----if result.Hit~=nil then result.Hit:remove() end       REMOVES THE PART HIT IF IT DID HIT SOMETHING
----print(result.Pos)   PRINTS THE POSITION WHERE THE BULLET DID HIT SOMETHING
----
----PWEES CREDIT IF YOU USE THIS IN YOUR WORK OR I OMNOMNOM j00


