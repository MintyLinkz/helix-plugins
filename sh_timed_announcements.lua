PLUGIN.name = "Timed Announcements"
PLUGIN.author = "Linkz"
PLUGIN.description = "Timed Announcement menu where you can set custom times/messages."
PLUGIN.license = [[
Copyright (c) 2025 Linkz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]

ix.announcements = ix.announcements or {}
ix.announcements.list = ix.announcements.list or {}

ix.config.Add("announcementInterval", 300, "Interval (in seconds) between announcements.", nil, {
    data = {min = 30, max = 3600},
    category = "Server"
})

if SERVER then
    util.AddNetworkString("ixAnnouncementsData")
    util.AddNetworkString("ixAnnouncementsUpdate")

    local function SendAnnouncement(data)
        for _, ply in ipairs(player.GetAll()) do
            ix.util.Notify("CHANGEME: " .. data.text, ply, data.duration or 10, Schema.color or color_white) -- CHANGE ME TO WHATEVERT YOU WANT!!!!
        end
    end

    function ix.announcements.StartTimer()
        timer.Remove("ixAnnouncementTimer")

        local interval = ix.config.Get("announcementInterval", 300)
        timer.Create("ixAnnouncementTimer", interval, 0, function()
            if #ix.announcements.list > 0 then
                SendAnnouncement(table.Random(ix.announcements.list))
            end
        end)
    end

    function ix.announcements.Save()
        file.Write("helix/announcements.txt", util.TableToJSON(ix.announcements.list, true))
    end

    function ix.announcements.Load()
        if file.Exists("helix/announcements.txt", "DATA") then
            local raw = util.JSONToTable(file.Read("helix/announcements.txt", "DATA")) or {}
            ix.announcements.list = {}

            for _, v in ipairs(raw) do
                if isstring(v) then
                    table.insert(ix.announcements.list, {text = v, duration = 10})
                elseif istable(v) then
                    table.insert(ix.announcements.list, {
                        text = v.text or "Missing text",
                        duration = tonumber(v.duration) or 10
                    })
                end
            end
        end
    end

    function PLUGIN:InitializedPlugins()
        ix.announcements.Load()
        ix.announcements.StartTimer()
    end

    function PLUGIN:OnConfigChanged(key, _, _)
        if key == "announcementInterval" then
            ix.announcements.StartTimer()
        end
    end

    net.Receive("ixAnnouncementsUpdate", function(_, client)
        if not client:IsAdmin() then return end

        local newList = net.ReadTable()
        ix.announcements.list = newList
        ix.announcements.Save()

        client:Notify("Announcement list updated.")

        net.Start("ixAnnouncementsData")
            net.WriteTable(ix.announcements.list)
        net.Send(client)
    end)
end

if CLIENT then
    net.Receive("ixAnnouncementsData", function()
        local messages = net.ReadTable()

        if IsValid(ix.announcementMenu) then ix.announcementMenu:Remove() end

        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 500)
        frame:Center()
        frame:SetTitle("CHANGEME - Announcements") -- Edior Title, change to whatever you want
        frame:MakePopup()
        ix.announcementMenu = frame

        local list = vgui.Create("DListView", frame)
        list:Dock(TOP)
        list:SetTall(200)
        list:AddColumn("Message")
        list:AddColumn("Duration")

        for _, v in ipairs(messages) do
            list:AddLine(v.text, v.duration)
        end

        local entry = vgui.Create("DTextEntry", frame)
        entry:Dock(TOP)
        entry:SetPlaceholderText("New announcement text...")

        local durationEntry = vgui.Create("DNumberWang", frame)
        durationEntry:Dock(TOP)
        durationEntry:SetMin(1)
        durationEntry:SetMax(60)
        durationEntry:SetValue(10)
        durationEntry:SetTooltip("Popup duration in seconds")

        local addBtn = vgui.Create("DButton", frame)
        addBtn:Dock(TOP)
        addBtn:SetText("Add Announcement")
        addBtn.DoClick = function()
            local text = entry:GetText()
            local dur = tonumber(durationEntry:GetValue()) or 10

            if text ~= "" then
                list:AddLine(text, dur)
                entry:SetText("")
                durationEntry:SetValue(10)
            end
        end

        local removeBtn = vgui.Create("DButton", frame)
        removeBtn:Dock(TOP)
        removeBtn:SetText("Remove Selected")
        removeBtn.DoClick = function()
            for _, line in ipairs(list:GetSelected()) do
                list:RemoveLine(line:GetID())
            end
        end

        local testBtn = vgui.Create("DButton", frame)
        testBtn:Dock(TOP)
        testBtn:SetText("Test Selected Announcement")
        testBtn.DoClick = function()
            local selected = list:GetSelectedLine()
            if selected then
                local line = list:GetLine(selected)
                local text = line:GetColumnText(1)
                local dur = tonumber(line:GetColumnText(2)) or 10
                ix.util.Notify("CHANGEME: " .. text, nil, dur, Schema.color or color_white) -- CHANGE ME TO WHATEVERT YOU WANT!!!!
            else
                LocalPlayer():Notify("No announcement selected.")
            end
        end

        local saveBtn = vgui.Create("DButton", frame)
        saveBtn:Dock(TOP)
        saveBtn:SetText("Save Announcements")
        saveBtn.DoClick = function()
            local newList = {}
            for _, line in ipairs(list:GetLines()) do
                table.insert(newList, {
                    text = line:GetColumnText(1),
                    duration = tonumber(line:GetColumnText(2)) or 10
                })
            end
            net.Start("ixAnnouncementsUpdate")
                net.WriteTable(newList)
            net.SendToServer()
        end
    end)
end

ix.command.Add("announcementmenu", {
    description = "Opens the announcement configuration menu to edit timed server popups.",
    adminOnly = true,
    OnRun = function(self, client)
        if SERVER then
            net.Start("ixAnnouncementsData")
                net.WriteTable(ix.announcements.list)
            net.Send(client)
        end
    end
})
