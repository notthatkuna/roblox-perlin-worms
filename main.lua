local function ScaleModel(model, scale)
	-- Taken from https://devforum.roblox.com/t/is-this-the-best-way-to-scale-a-model/166021

	local primary = model.PrimaryPart
	local primaryCf = primary.CFrame

	for _,v in pairs(model:GetDescendants()) do
		if (v:IsA("BasePart")) then
			v.Size = (v.Size * scale)
			if (v ~= primary) then
				v.CFrame = (primaryCf + (primaryCf:inverse() * v.Position * scale))
			end
		end
	end

	return model

end
spawn(function()
	while wait(10) do
		for _,v in pairs(workspace:GetDescendants()) do
			if v.Name == "DELETE" then v:Destroy() end
		end
	end
end)

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

local SIZEOF_BALL2
local R = 0
local switch = 1


local Seed = math.random(1,1616) -- Changes cave generation a lot


print("Seed is: "..Seed)
local Resolution = math.random(1,50) -- How far away each part will be from eachother, keep it low because higher numbers might break everything and it will look very messy
local NumWorm = 1
local lastPart = nil
local br = false
while true do
	wait(2)
    local SIZEOF_BALL = math.random(10,20)
    local IS_WATER_WORM = false
	NumWorm = NumWorm+1
	local sX = math.noise(NumWorm/Resolution+math.random(1,9),Seed)
	local sY = math.noise(NumWorm/Resolution+sX+math.random(1,9),Seed)
	local sZ = math.noise(NumWorm/Resolution+sY+math.random(1,9),Seed)
	print(sX*500,sY*500,sZ*500)
	local WormCF = CFrame.new(sX*500,sY*500,sZ*500)
    print("Worm "..NumWorm.."'s BALLSIZE variable is "..tostring(SIZEOF_BALL))
	local Dist = (math.noise(NumWorm/Resolution+WormCF.p.magnitude,Seed)+.5)*500
	local L_COUNTER = 0
	for i = 1,Dist do
		
		if br then
			br = false
			break
		end
		
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
		Part.Name = "DELETE"
		local Connect = Part:Clone()
		Connect.Name = "DELETE"
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
		light.Name = "DELETE"
        light.Brightness = 1
		light.Range = 30
		
		-- Check if there is still terrain surrounding the part
		local r3 = Region3.new(Part.Position - Vector3.new(SIZEOF_BALL,SIZEOF_BALL,SIZEOF_BALL), Part.Position + Vector3.new(SIZEOF_BALL,SIZEOF_BALL,SIZEOF_BALL))
		r3 = r3:ExpandToGrid(4)
		local material, occupancy = game.Workspace.Terrain:ReadVoxels(r3, 4)

		local size = material.Size -- Same as occupancies.Size
		
		local no_air = 0
		for x = 1, size.X, 1 do
			for y = 1, size.Y, 1 do
				for z = 1, size.Z, 1 do
					if material[x][y][z] ~= Enum.Material.Air then no_air = no_air + 1 end
				end
			end
		end
		
		if no_air == 0 then
			L_COUNTER = L_COUNTER + 1
			
		end
		if L_COUNTER <= 2 then
			wait(.1)
			if lastPart then
				local p2 = Instance.new("Part", workspace)
				p2.Name = "DELETE"
				p2.Anchored = true
				p2.Size = Part.Size + Vector3.new(10,10,10)
				p2.Position = lastPart.Position

				local ts = game:GetService("TweenService")
				local tween = ts:Create(p2, TweenInfo.new(1), {CFrame = Part.CFrame})
				tween:Play()
				local comp = false
				tween.Completed:Connect(function()
					comp = true
				end)
				spawn(function()
					while not comp do
						wait()
						SIZEOF_BALL2 = math.random(7,25)
						workspace.Terrain:FillBall(p2.Position,SIZEOF_BALL2,Enum.Material.Air)
						
					end
				end)
				spawn(function()
					while not comp do
						wait(Resolution/10)
						print("Allocating lighting and extra effects for worm "..tostring(NumWorm))
						local p2c = p2:Clone()
						p2c.Name = "LIGHTPARTT"
						p2c.Parent = workspace
						p2c.Transparency = .9
						p2c.Size = p2c.Size - Vector3.new(5,5,5)
						local light = Instance.new("PointLight",p2c)
						print("Instanciated light")
						light.Brightness = Resolution/100
						print("Set brightness to "..light.Brightness)
						light.Range = 40
						print("Set range to "..light.Range)
						local r3 = Region3.new(Part.Position - Vector3.new(SIZEOF_BALL,SIZEOF_BALL,SIZEOF_BALL), Part.Position + Vector3.new(SIZEOF_BALL,SIZEOF_BALL,SIZEOF_BALL))
						r3 = r3:ExpandToGrid(4)
						local material2, occupancy2 = game.Workspace.Terrain:ReadVoxels(r3, 4)

						local size2 = material.Size -- Same as occupancies.Size

						local no_air2 = 0
						for x = 1, size2.X, 1 do
							for y = 1, size2.Y, 1 do
								for z = 1, size2.Z, 1 do
									if material2[x][y][z] ~= Enum.Material.Air then no_air2 = no_air2 + 1 end
								end
							end
						end

						if no_air2 >= 20 then
							print("Over 20 non-air voxels for mineshaft block")
							local ch
							if Resolution <= 9 then ch = Resolution else ch = Resolution end
							if math.random(0,100) <= ch then
								print("chance of miensahft block fulfilled")
								local unc = workspace.un:Clone()
								print("Cloned mineshaft block")
								unc.Parent = workspace
								unc.CFrame = Connect.CFrame
								unc.Size = Vector3.new(SIZEOF_BALL2+20,SIZEOF_BALL2+20,SIZEOF_BALL2+20)
								print("Socketed mineshaft block")
								print("Allocation complete for this step")
							end
						end
						
					end
				end)
			end
	        


	        if (Connect.Orientation.Z > -20 and Connect.Orientation.Z < 20) and Part.Position.Y < workspace.TOP.Position.Y and Part.Position.Y > workspace.BOTTOM.Position.Y and IS_WATER_WORM then
	            workspace.Terrain:FillBall(Part.Position,SIZEOF_BALL,Enum.Material.Water)
	        else
	            workspace.Terrain:FillBall(Part.Position,SIZEOF_BALL,Enum.Material.Air)
			end
			lastPart = Part
		elseif L_COUNTER >= 3 then
			lastPart = nil
			L_COUNTER = 0
			sX,sY,sZ = 0,0,0
			
			br= true
		end
	end
	lastPart = nil
	L_COUNTER = 0
end
