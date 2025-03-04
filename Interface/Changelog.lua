---@type GL
local _, GL = ...;

GL.AceGUI = GL.AceGUI or LibStub("AceGUI-3.0");

local AceGUI = GL.AceGUI;
local Settings = GL.Settings; ---@type Settings

---@class ChangelogInterface
GL.Interface.Changelog = {
    isVisible = false,

    History = {
        {
            version = "4.3.1",
            date = "May 29th, 2022",
            Changes = {
                "Having issues with players misspelling their character names on |c00a79effsoftres.it|r? Gargul now automatically attempts to \"fix\" typos in character names when importing soft-reserves",
                "When using soft-reserves, a player can now whisper |c00a79eff!sr|r to the master looter to double check his soft-reserves",
                "You can now set a default raid warning / group message that shows when you roll off items. Want to let players know how to roll for MS or OS? Easy: open Gargul using |c00a79eff/gl|r and go to |c00a79effMaster Looting|r to set your message!"
            },
        },
        {
            version = "4.3.0",
            date = "May 10th, 2022",
            Changes = {
                "Do you want to reward regulars? Give something extra to players reserving the same item(s) multiple times in a row? Awesome, that's what boosted rolls are for! Open Gargul using |c00a79eff/gl|r and go to |c00a79effBoosted Rolls|r to get started!",
            },
        },
        {
            version = "4.1.8",
            date = "April 15th, 2022",
            Changes = {
                "Gargul can now announce loot and money traded in chat for full transparency",
            },
        },
        {
            version = "4.1.3",
            date = "February 7th, 2022",
            Changes = {
                "Completely revamped the PackMule auto looter, go check out PackMule at |c00a79eff/gl pm|r!",
            },
        },
        {
            version = "4.1.2",
            date = "January 26th, 2022",
            Changes = {
                "Gargul now supports the raid roster tool of the raid-helper discord bot. Make your roster and auto-invite, sort groups and more using |c00a79eff/gl gr|r!",
            },
        },
        {
            version = "4.1.1",
            date = "January 24th, 2022",
            Changes = {
                string.format(
                    "You can now award an item to a random player by not selecting a player and clicking the award button in the award window (|c00a79eff%s|r)",
                    GL.Settings:get("ShortcutKeys.award")
                ),
                "Hovering over a player's roll in the roll tracking window will now show you all the items they've won today",
            },
        },
        {
            version = "4.1.0",
            date = "January 15th, 2022",
            Changes = {
                "Gargul now supports custom roll ranges! Don't want to use |c00a79eff/rnd|r for main spec or |c00a79eff/rnd 99|r for off spec? Not a problem: you can now define your own roll types! Open Gargul using |c00a79eff/gl|r and go to |c00a79effRoll Tracking|r to set up your rolls!",
            },
        },
        {
            version = "4.0.0",
            date = "December 12th, 2021",
            Changes = {
                "Added automatic |c00a79effsoftres.it|r data sharing. When a player enters your raid or when you import soft-reserves it's automatically shared",
                "Added the same sharing feature for |c00a79effTMB|r but it's disabled by default. Open Gargul using |c00a79eff/gl|r and go to |c00a79effTMB|r to enable!",
            },
        },
        {
            version = "3.6.0",
            date = "November 14th, 2021",
            Changes = {
                "Loot priorities can now be shared with the raid, type |c00a79eff/gl lo|r to get started!",
            },
        },
        {
            version = "3.5.3",
            date = "November 10th, 2021",
            Changes = {
                "Gargul will now show for how long soulbound items can still be traded within the two hour trade window, forgetting to roll out items is now a thing of the past!",
            },
        },
        {
            version = "3.5.0",
            date = "October 30th, 2021",
            Changes = {
                "Gargul now automatically adds all awarded items to the trade window when trading with the winner, making master looting as you go easier than ever!",
            },
        }
    }
};
local Changelog = GL.Interface.Changelog; ---@type ChangelogInterface

--- Report version changes if needed
---
---@return void
function Changelog:reportChanges()
    GL:debug("Changelog:reportChanges");

    if (not GL.Version.firstBoot -- This is not this version's first boot, no need to report
        or not GL.Settings:get("changeLog", true) -- The user is not interested in the changelog
    ) then
        return;
    end

    local latestVersionChangesShown = GL.DB.LoadDetails.latestVersionChangesShown or 0;
    local latestChangelogVersion = self.History[1].version;

    -- There are no changes to display between this version and the last, skip!
    if (not GL.Version:leftIsOlderThanRight(latestVersionChangesShown, latestChangelogVersion)) then
        return;
    end

    -- Make sure we store the latest changelog shown for future reference
    GL.DB.LoadDetails.latestVersionChangesShown = latestChangelogVersion;

    self:draw();
end

--- Draw the changelog window
---
---@return void
function Changelog:draw()
    GL:debug("Changelog:draw");

    -- The changelog is already visible
    if (self.isVisible) then
        return;
    end

    self.isVisible = true;

    -- Create a container/parent frame
    local Window = AceGUI:Create("Frame");
    Window:SetTitle("Gargul v" .. GL.version);
    Window:SetLayout("Flow");
    Window:SetWidth(400);
    Window:SetHeight(500);
    Window:EnableResize(false);
    Window.statustext:GetParent():Hide(); -- Hide the statustext bar
    Window:SetCallback("OnClose", function()
        self:close();
    end);
    GL.Interface:setItem(self, "Window", Window);

    Window:SetPoint(GL.Interface:getPosition("Changelog"));

    local ScrollFrameHolder = GL.AceGUI:Create("ScrollFrame");
    ScrollFrameHolder:SetLayout("Fill");
    ScrollFrameHolder:SetWidth(400);
    ScrollFrameHolder:SetHeight(428);
    Window:AddChild(ScrollFrameHolder);

    local ScrollFrame = GL.AceGUI:Create("ScrollFrame");
    ScrollFrame:SetLayout("Flow");
    ScrollFrameHolder:AddChild(ScrollFrame);

    local HorizontalSpacer;

    local MoreInfoLabel = GL.AceGUI:Create("Label");
    MoreInfoLabel:SetText("|c00a79effDon't want to miss anything Gargul?|r");
    MoreInfoLabel:SetFontObject(_G["GameFontNormal"]);
    MoreInfoLabel:SetFullWidth(true);
    ScrollFrame:AddChild(MoreInfoLabel);

    local DiscordBox = GL.AceGUI:Create("EditBox");
    DiscordBox:DisableButton(true);
    DiscordBox:SetHeight(20);
    DiscordBox:SetFullWidth(true);
    DiscordBox:SetText("https://discord.gg/D3mDhYPVzf");
    ScrollFrame:AddChild(DiscordBox);

    for _, LogEntry in pairs(self.History) do
        -- Add some whitespace between this and the previous entry
        if (not firstEntry) then
            HorizontalSpacer = GL.AceGUI:Create("SimpleGroup");
            HorizontalSpacer:SetLayout("FILL");
            HorizontalSpacer:SetFullWidth(true);
            HorizontalSpacer:SetHeight(16);
            ScrollFrame:AddChild(HorizontalSpacer);
        end

        -- Version label
        local VersionLabel = AceGUI:Create("Label");
        VersionLabel:SetText(string.format("|c00a79effv%s - |r%s", LogEntry.version, LogEntry.date));
        VersionLabel:SetFontObject(_G["GameFontNormal"]);
        VersionLabel:SetHeight(10);
        VersionLabel:SetFullWidth(true);
        ScrollFrame:AddChild(VersionLabel);

        local firstChange = true;
        for _, change in pairs(LogEntry.Changes) do
            if (not firstChange) then
                HorizontalSpacer = GL.AceGUI:Create("SimpleGroup");
                HorizontalSpacer:SetLayout("FILL");
                HorizontalSpacer:SetFullWidth(true);
                HorizontalSpacer:SetHeight(6);
                ScrollFrame:AddChild(HorizontalSpacer);
            end

            -- Changes
            local ChangeLabel = AceGUI:Create("Label");
            ChangeLabel:SetText(string.format("|c00a79eff-|r|c00FFF569 %s|r", change));
            ChangeLabel:SetFontObject(_G["GameFontNormal"]);
            ChangeLabel:SetHeight(20);
            ChangeLabel:SetFullWidth(true);
            ScrollFrame:AddChild(ChangeLabel);

            firstChange = false;
        end
    end

    local Checkbox = AceGUI:Create("CheckBox");
    Checkbox:SetValue(GL.Settings:get("changeLog"));
    Checkbox:SetLabel("Enable changelog");
    Checkbox:SetDescription("");
    Checkbox:SetWidth(130);
    Checkbox:SetCallback("OnValueChanged", function()
        GL.Settings:set("changeLog", Checkbox:GetValue());
    end);
    Window:AddChild(Checkbox);
end

--- Store the changelog window's position for future reference
---
---@return void
function Changelog:close()
    GL:debug("Changelog:close");

    local Window = GL.Interface:getItem(self, "Window");

    if (not self.isVisible
        or not Window
    ) then
        return;
    end

    -- Store the frame's last position for future play sessions
    local point, _, relativePoint, offsetX, offsetY = Window:GetPoint();
    Settings:set("UI.Changelog.Position.point", point);
    Settings:set("UI.Changelog.Position.relativePoint", relativePoint);
    Settings:set("UI.Changelog.Position.offsetX", offsetX);
    Settings:set("UI.Changelog.Position.offsetY", offsetY);

    -- Clear the frame and its widgets
    AceGUI:Release(Window);
    self.isVisible = false;
end

GL:debug("Changelog.lua");