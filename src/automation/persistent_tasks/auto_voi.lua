local automation_struct = require("@src/automation/struct");
local autofarm_util = require("@src/utility/deepwoken/autofarm_utilitys");
local struct;

local auto_voi = {
    playerCheck = function(mag, custom)
        for _, player in services.Players:GetPlayers() do
            if not player.Character then continue end
            if player == local_player.instance then continue end

            local hrp = player.Character:FindFirstChild("HumanoidRootPart");
            if not hrp then continue end

            local dist = ((custom or local_player.root_part.Position) - hrp.Position).Magnitude;
            if dist <= mag then
                return true;
            end
        end
        return false;
    end,

    mobsCheck = function(mag, custom)
        for _, mob in workspace.Live:GetChildren() do
            if not mob:FindFirstChild("HumanoidRootPart") then continue; end;

            local dist = ((custom or local_player.root_part.Position) - mob:GetPivot().Position).Magnitude;
            if dist <= mag then
                return true;
            end
        end
        return false;
    end,

    serverHop = function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, "any", true);
    end,

    tempTween = function(cf, speed)
        Tween.new(cf, true, speed or 150).wait();
    end,

    player_safe_tween = function(self, cf, speed)
        if self.playerCheck(200) then
            self.serverHop();
            while task.wait() do end
        end

        local x, _, z = select(1, cf:GetComponents());
        self.tempTween(CFrame.new(x, -1050, z), speed);
        self.tempTween(cf, speed);

        if self.playerCheck(200, cf.Position) then
            self.serverHop();
            while task.wait() do end
        end

        local root = local_player.root_part;
        if not root then return end

        root.CFrame = cf;
        root.AssemblyLinearVelocity = Vector3.zero;
    end,

    autoM1 = function(toggle)
        if not toggle then
            aztup.features.m1_hold.held = false;
            aztup.flags.no_aerials = false;
            return;
        end

        aztup.features.m1_hold.held = true;
        --//aztup.flags.no_aerials = true;
    end,

    healthCheck = function(percent)
        return local_player.humanoid and local_player.humanoid.Health <= (local_player.humanoid.MaxHealth * percent);
    end
};

function auto_voi:generic_humanoid_fight(name, flag)
    repeat task.wait() until local_player.character;
    task.wait(2.5);

    repeat task.wait() until workspace.Live:FindFirstChild(name);
    repeat task.wait() until workspace.Live:FindFirstChild(name) and workspace.Live:FindFirstChild(name):FindFirstChild("HumanoidRootPart");

    aztup.flags.atb_x_offset = 4
    aztup.flags.atb_y_offset = -7
    aztup.flags.atb_z_offset = 0
    aztup_toggles.attach_to_back:SetValue(true);
    aztup.features.attach_to_back.target = workspace.Live:FindFirstChild(name);
    aztup.features.attach_to_back.state = "attaching";
    aztup.flags.atb_rotate = true;
    aztup_toggles.noclip:SetValue(true);

    aztup_toggles.mob_ai_breaker:SetValue(true);
    aztup_options.breaker_type.Value = "Aggressive"
    workspace.Live:FindFirstChild(name):WaitForChild("HumanoidRootPart");

    while task.wait() and not workspace:FindFirstChild("DungeonExit") do
        pcall(function()
            if not EffectReplicator:FindEffect("Equipped") then
                local_player.character.CharacterHandler.Requests.DrawWeapon:FireServer(true);
            end;
        end);

        self:autoM1(true);
    end;

    self:autoM1(false);

    persistent_data:set(flag, true);
    Tween.new(workspace:FindFirstChild("DungeonExit").CFrame, false, 150);
end;

function auto_voi:rat_king()
    if game.PlaceId == 86761619761103 then
        repeat 
            task.spawn(function()
                local_player.instance:RequestStreamAroundAsync(Vector3.new(-2829.87646, 56.4980431, -3300.2854));
            end);
            task.wait(0.1) 
        until workspace:FindFirstChild("GoldenRatBoundary");

        local boundary = workspace:FindFirstChild("GoldenRatBoundary");
        while task.wait() do
            xpcall(function() 
                local_player.root_part.AssemblyLinearVelocity = Vector3.zero;
                local_player.root_part.CFrame = boundary.CFrame;
                firetouchinterest(boundary, local_player.root_part, 1);
                firetouchinterest(boundary, local_player.root_part, 0);
            end, warn);
        end;
    else    
        self:generic_humanoid_fight(".ratking1", "done_rat_king");
    end;
end;

function auto_voi:enmity()
    if game.PlaceId == 86761619761103 then
        require("@src/features/buttons/teleports/depths")();
    elseif game.PlaceId == 8668476218 then
        aztup.flags.atb_x_offset = 0
        aztup.flags.atb_y_offset = 6
        aztup.flags.atb_z_offset = 0
        aztup_toggles.attach_to_back:SetValue(true);
        aztup.features.attach_to_back.target = workspace.Live:WaitForChild(".enmity_true1");
        aztup.features.attach_to_back.state = "attaching";
        aztup.flags.atb_rotate = true;
        if not aztup.flags.m1_hold then
            aztup_toggles.m1_hold:SetValue(true);
        end;

aztup_toggles.mob_ai_breaker:SetValue(true);
aztup_options.breaker_type.Value = "Aggressive"
            local_player.character.CharacterHandler.Requests.DrawWeapon:FireServer(true);

            while task.wait() do
            aztup.features.m1_hold.held = not general:playing_ap_anims(workspace.Live[".enmity_true1"]);
            aztup.flags.atb_x_offset = 0
            aztup.flags.atb_z_offset = 0
            if general:playing_ap_anims(workspace.Live[".enmity_true1"]) then
                aztup.flags.atb_x_offset = 0
                aztup.flags.atb_y_offset = general:playing_ap_anims(workspace.Live[".enmity_true1"], {
                    "112050896536834"
                }) and math.random(150, 200) or general:playing_ap_anims(workspace.Live[".enmity_true1"], {
                    "92111402678314"
                }) and -20000 or 200;
                aztup.flags.atb_z_offset = 0;
            else
                aztup.flags.atb_y_offset = 6
            end;

                aztup.flags.atb_prevent_voiding = false;
            aztup.features.attach_to_back.target = workspace.Live[".enmity_true1"];
            aztup.features.attach_to_back.state = "attaching";

                pcall(function() 
                    aztup.automation.requesting_mob_ai_breaker_stop = true;
                for _, enforcer in workspace.Live:GetChildren() do
                    if not enforcer.Name:match("enmity_enforcer") then continue; end
                    if enforcer.Humanoid.Health <= 0 then return; end
                    aztup.automation.requesting_mob_ai_breaker_stop = false;
                        aztup.flags.atb_z_offset = 0
                    aztup.flags.atb_x_offset = 0
                    aztup.features.attach_to_back.target = enforcer;
                    break;
                end;
            end);
        end;
    else
        Logger:long_notify("You will have to manually reach enmity :3")
    end;
end;

function auto_voi:shogun()
    if game.PlaceId == 86761619761103 then
        repeat 
            task.spawn(function()
                local_player.instance:RequestStreamAroundAsync(Vector3.new(-8983.13, 560.461121, -4054.68));
            end);
            task.wait(0.1) 
        until workspace:FindFirstChild("ShogunBoundary");

        local boundary = workspace:FindFirstChild("ShogunBoundary");
        while task.wait() do
            xpcall(function() 
                local_player.root_part.AssemblyLinearVelocity = Vector3.zero;
                local_player.root_part.CFrame = boundary.CFrame;
                firetouchinterest(boundary, local_player.root_part, 1);
                firetouchinterest(boundary, local_player.root_part, 0);
            end, warn);
        end;
    else    
        self:generic_humanoid_fight(".shogun1", "done_shogun");
    end;
end;

local state_machine = StateMachine.create({
    initial = "idle",
    events = {
        { name = "start",    from = "idle", to = "_check_area" },
        { name = "shogun",    from = "_check_area", to = "_do_shogun" },
        { name = "rat_king",    from = "_check_area", to = "_do_rat_king" },
        { name = "do_enmity", from = "_check_area", to = "_do_enmity" },
        { name = "do_complete", from = "_check_area", to = "_do_complete" },

        { name = "skip",     from = "_check_area", to = "idle" },
    },
    callbacks = {
        onenter_check_area = function(self)
            aztup.flags.block_input = true;
            aztup_options.blocked_safe_input_user_moves.Value.M1s = true;
            aztup_options.bi_punishable_type.Value = "Always";
            if not persistent_data:get("done_shogun", false) then
                self:shogun();
            elseif not persistent_data:get("done_rat_king", false) then
                self:rat_king();
            else
                if not persistent_data:get("level_up_warn", false) then
                    local_player.instance:Kick("You need to level up before you can continue.");
                    persistent_data:set("level_up_warn", true);
                elseif not persistent_data:get("confirmed_leveled_up", false) then
                    Library:Notify("Please click this button when you have leveled up and finished.", 9e9)
                    local button = Instance.new("TextButton", services.CoreGui.RobloxGui);
                    button.Size = UDim2.fromOffset(200, 50)
                    button.Position = UDim2.fromScale(0.1, 0.5)
                    button.AnchorPoint = Vector2.new(0.5, 0.5)

                    button.BackgroundTransparency = 0.5
                    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.Text = "I have leveled up."
                    button.Activated:Wait();
                    persistent_data:set("confirmed_leveled_up", true);
                    server_utility:rejoin(local_player.instance:GetAttribute("DataSlot") or "A");
                else
                    self:enmity();
                end;
                --self:do_enmity();   
            end;
        end,

        shogun = function(self)
            auto_voi:shogun();
        end,

        rat_king = function(self)            
            auto_voi:rat_king();
        end,

        enmity = function(self)
            auto_voi:enmity();
        end,

        onenter_complete = function(self)
            aztup.automation:set("auto_voi", false);
            Logger:long_notify_sound("Successfully finished voi.")

            if true then return; end
        end,
    }
});

struct = automation_struct:construct({
    persistent_data_store = "auto_voi_store",
    persistent_data_flag  = "auto_voi",
    id = "auto_voi",

    state_machine = state_machine,

    features = {
        "no_fall",
        "no_fire",
        "m1_hold",
        "no_stun",
        "fast_swing",
        "auto_equip_weapon"
    },

    not_allowed = function()
        return false;
    end,

    character_creator_handler_used = false,
    character_creator_handler_opts = {}
});

-- Auto progression thingy
struct.logic = auto_voi;

return struct;
