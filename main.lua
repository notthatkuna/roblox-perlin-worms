

local MASTERWAIT = .01 -- changes how much time to wait after each worm segment is created


local function setTwoEndPoints(part, point1, point2)
    local magnitude = (point1 - point2).magnitude
    part.Size = Vector3.new(part.Size.X, part.Size.Y, magnitude)
    part.CFrame = CFrame.new(
        point1:Lerp(point2, 0.5),
        point2 
    )
    return part
end

local R = 0
local switch = 1


local Seed = 1 -- Changes cave generation a lot


print("Seed is: "..Seed)
local Resolution = 3 -- How far away each part will be from eachother, keep it low because higher numbers might break everything and it will look very messy
local NumWorm = 1
local lastPart = nil
while wait() do
    local SIZEOF_BALL = math.random(10,20)
    local IS_WATER_WORM = false
	NumWorm = NumWorm+1
	local sX = math.noise(NumWorm/Resolution+.1,Seed)
	local sY = math.noise(NumWorm/Resolution+sX+.1,Seed)
	local sZ = math.noise(NumWorm/Resolution+sY+.1,Seed)
	local WormCF = CFrame.new(sX*500,sY*500,sZ*500)
    print("Worm "..NumWorm.."'s BALLSIZE variable is "..tostring(SIZEOF_BALL))
	local Dist = (math.noise(NumWorm/Resolution+WormCF.p.magnitude,Seed)+.5)*500

	for i = 1,Dist do
        wait(MASTERWAIT)
        if R == 0 then
            switch = 1
        elseif R == 255 then
            switch = 0
        end
        if switch == 1 then
            R = R + 5
        elseif switch == 0 then
            R = R - 5
        end
		local X,Y,Z = math.noise(WormCF.X/Resolution+.1,Seed),math.noise(WormCF.Y/Resolution+.1,Seed),math.noise(WormCF.Z/Resolution+.1,Seed)
		WormCF = WormCF*CFrame.Angles(X*2,Y*2,Z*2)*CFrame.new(0,0,-Resolution)
		local Part = Instance.new("Part")
        Part.Size = Vector3.new(1,.5,1)
		Part.Anchored = true
		Part.CFrame = CFrame.new(WormCF.p)
		Part.Parent = workspace
        local Connect = Part:Clone()
        Connect.Parent = workspace
        if lastPart then
            setTwoEndPoints(Connect,Part.Position,lastPart.Position)
            Part.Orientation = Connect.Orientation
        end
        Connect.Color = Color3.fromRGB(R,0,0)
        Part.Color = Color3.fromRGB(R,0,0)
        -- Connect.Transparency = 1
        -- Part.Transparency = 1
        local light = Instance.new("PointLight",Part)
        light.Brightness = .5
        light.Range = 15
        lastPart = Part

        workspace.Terrain:FillBall(Part.Position,SIZEOF_BALL,Enum.Material.Air)
	end
    lastPart = nil
end
