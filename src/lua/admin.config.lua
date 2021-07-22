do
    local function GetKeyName(KeyCode)
        local Stringed = Services.UserInputService.GetStringForKeyCode(Services.UserInputService, KeyCode);
        local IsEnum = Stringed == ""
        return not IsEnum and Stringed or split(tostring(KeyCode), ".")[3], IsEnum
    end

    LoadConfig = function()
        local Script = ConfigUILib.NewPage("Script");
        local Settings = Script.NewSection("Settings");
    
        local CurrentConf = GetConfig();

        Settings.Keybind("Chat Prefix", Prefix, function(KeyCode)
            local Key = GetKeyName(KeyCode);
            if (not match(Key, "%A") or #Key > 1) then
                Utils.Notify(nil, "Prefix", "Prefix must be a 1 character symbol.");
                return
            end
            Prefix = Key
            Utils.Notify(nil, nil, "");
        end)
    
        Settings.Keybind("CMDBar Prefix", GetKeyName(CommandBarPrefix), function(KeyCode1, KeyCode2)
            CommandBarPrefix = KeyCode1
            Utils.Notify(nil, nil, "");
        end)
    
        local ToggleSave;
        ToggleSave = Settings.Toggle("Save Prefix's", false, function(Callback)
            SetConfig({["Prefix"]=Prefix,["CommandBarPrefix"]=split(tostring(CommandBarPrefix), ".")[3]});
            wait(.5);
            ToggleSave();
            Utils.Notify(nil, nil, "");
        end)
    
        local Misc = Script.NewSection("Misc");

        Misc.Toggle("Chat Prediction", CurrentConf.ChatPrediction or false, function(Callback)
            local ChatBar = ToggleChatPrediction();
            if (Callback) then
                ChatBar.CaptureFocus(ChatBar);
                wait();
                ChatBar.Text = Prefix
            end
            SetConfig({ChatPrediction=Callback});
            Utils.Notify(nil, nil, format("ChatPrediction %s", Callback and "enabled" or "disabled"));
        end)

        Misc.Toggle("Anti Kick", AntiKick, function(Callback)
            AntiKick = Callback
            Utils.Notify(nil, nil, format("AntiKick %s", AntiKick and "enabled" or "disabled"));
        end)

        Misc.Toggle("Anti Teleport", AntiTeleport, function(Callback)
            AntiTeleport = Callback
            Utils.Notify(nil, nil, format("AntiTeleport %s", AntiTeleport and "enabled" or "disabled"));
        end)

        Misc.Toggle("wide cmdbar", WideBar, function(Callback)
            WideBar = Callback
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween -110
                })
            end
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Size = UDim2.new(0, WideBar and 400 or 200, 0, 35) -- tween -110
            })
            Utils.Notify(nil, nil, format("widebar %s", WideBar and "enabled" or "disabled"));
        end)

        Misc.Toggle("draggable cmdbar", Draggable, function(Callback)
            Draggable = Callback
            CommandBarOpen = true
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Position = UDim2.new(0, Mouse.X, 0, Mouse.Y + 36);
            })
            Utils.Draggable(CommandBar);
            local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
            local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone);
            CommandBar.Input.Text = ""
            if (not Callback) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween 5
                })
            end
            Utils.Notify(nil, nil, format("draggable command bar %s", Draggable and "enabled" or "disabled"));
        end)

        local OldFireTouchInterest = firetouchinterest
        Misc.Toggle("cframe touchinterest", firetouchinterest == nil, function(Callback)
            firetouchinterest = Callback and function(part1, part2, toggle)
                if (part1 and part2) then
                    if (toggle == 0) then
                        touched[1] = part1.CFrame
                        part1.CFrame = part2.CFrame
                    else
                        part1.CFrame = touched[1]
                        touched[1] = nil
                    end
                end
            end or OldFireTouchInterest
        end)

        local PluginsPage = ConfigUILib.NewPage("Plugins")
        
        local CurrentPlugins = PluginsPage.NewSection("Current Plugins");
        local PluginSettings = PluginsPage.NewSection("Plugin Settings");
    
        local CurrentPluginConf = GetPluginConfig();
    
        CurrentPlugins.ScrollingFrame("plugins", function(Option, Enabled)
            CurrentPluginConf = GetPluginConfig();
            for i = 1, #Plugins do
                local Plugin = Plugins[i]
                if (Plugin[1] == Option) then
                    local DisabledPlugins = CurrentPluginConf.DisabledPlugins
                    local PluginName = Plugin[2]().Name
                    if (Enabled) then
                        DisabledPlugins[PluginName] = nil
                        SetPluginConfig({DisabledPlugins=DisabledPlugins});
                        Utils.Notify(nil, "Plugin Enabled", format("plugin %s successfully enabled", PluginName));
                    else
                        DisabledPlugins[PluginName] = true
                        SetPluginConfig({DisabledPlugins=DisabledPlugins});
                        Utils.Notify(nil, "Plugin Disabled", format("plugin %s successfully disabled", PluginName));
                    end
                end
            end
        end, map(Plugins, function(Key, Plugin)
            return not PluginConf.DisabledPlugins[Plugin[2]().Name], Plugin[1]
        end));
    
        PluginSettings.Toggle("Plugins Enabled", CurrentPluginConf.PluginsEnabled, function(Callback)
            SetPluginConfig({PluginsEnabled = Callback});
        end)

        PluginSettings.Toggle("Plugins Debug", CurrentPluginConf.PluginDebug, function(Callback)
            SetPluginConfig({PluginDebug = Callback});
        end)
    
    
        -- NewPlugins.Toggle("show health", nil, function(Callback)
        --     print(Callback);
        -- end)
        
        -- NewPlugins.Toggle("not show health", nil, function(Callback)
        --     print(Callback);
        -- end)
        
        -- NewPlugins.ScrollingFrame("plugins", function(Option, Enabled)
        --     print(Option, Enabled);
        -- end, {
        --     ["lol.lua"] = true;
        --     ["stdio.h"] = false;
        --     ["a.lua"] = false;
        --     af = true;
        --     bsrd = false;
        --     egsgf = false;
        --     gewg = false;
        --     dsgkw = false;
        -- })
        
        -- NewPlugins.Keybind("test", function(Callback)
        --     print(Callback)
        -- end)
    end
end