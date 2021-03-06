local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Typing = false

getgenv().SilentAimEnabled = true
getgenv().DisableKey = Enum.KeyCode.Q

local function GetClosestPlayer()
	local Target = nil
	local MaximumDistance = math.huge

	delay(20, function()
		MaximumDistance = math.huge
	end)

	for _, v in pairs(Players:GetPlayers()) do
		if v.Name ~= LocalPlayer.Name then
			if v.Team ~= LocalPlayer.Team then
				if v.Character ~= nil then
					if v.Character.HumanoidRootPart ~= nil then
						if v.Character.Humanoid ~= nil then
							if v.Character.Humanoid.Health ~= 0 then
								local Vector = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
								local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude

								if Distance < MaximumDistance then
									Target = v
									MaximumDistance = Distance
								end
							end
						end
					end
				end
			end
		end
	end

	return Target
end

UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

UserInputService.InputBegan:Connect(function(Input)
	if Input.KeyCode == getgenv().DisableKey and Typing == false then
		getgenv().SilentAimEnabled = not getgenv().SilentAimEnabled
	end
end)

local OldNameCall = nil

OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
	local NameCallMethod = getnamecallmethod()
	local Arguments = {...}

	if tostring(Self) == "HitPart" and tostring(NameCallMethod) == "FireServer" then	
		if getgenv().SilentAimEnabled == true then
			Arguments[1] = GetClosestPlayer().Character.Head
			Arguments[2] = GetClosestPlayer().Character.Head.Position
			Arguments[13] = true
		end

		return Self.FireServer(Self, unpack(Arguments))
	end

	return OldNameCall(Self, ...)
end)
