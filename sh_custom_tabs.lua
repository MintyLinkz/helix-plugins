PLUGIN.name = "Custom TABS"
PLUGIN.author = "Linkz"
PLUGIN.description = "Adds a Workshop Tab & Faction Tab"
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

if CLIENT then
    hook.Add("CreateMenuButtons", "ixWorkshopButton", function(tabs)
        tabs["Workshop"] = function(container)
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(10, 10, 10, 10)

            local button = panel:Add("DButton")
            button:Dock(TOP)
            button:SetTall(50)
            button:DockMargin(0, 0, 0, 10)
            button:SetText("")
            
            local iconMat = Material("icon16/star.png")
            
            button.Paint = function(self, w, h)
                local bgColor = Color(30, 30, 30)
                local borderColor = Color(100, 100, 100)
                local glowColor = Color(70, 150, 255, 100)
            
                if self:IsHovered() then
                    draw.RoundedBox(12, 0, 0, w, h, glowColor)
                    borderColor = Color(70, 150, 255)
                else
                    draw.RoundedBox(12, 0, 0, w, h, bgColor)
                end
            
                surface.SetDrawColor(borderColor)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            
                local circleSize = 32
                local circleX = 15
                local circleY = h / 2 - circleSize / 2
                draw.RoundedBox(circleSize / 2, circleX, circleY, circleSize, circleSize, Color(50, 50, 50))
            
                surface.SetMaterial(iconMat)
                surface.SetDrawColor(Color(200, 200, 200))
                surface.DrawTexturedRect(circleX + 8, circleY + 8, 16, 16)
            
                draw.SimpleText("Open Workshop Page", "DermaDefaultBold", circleX + circleSize + 15, h / 2, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            button.DoClick = function()
                gui.OpenURL("PLACEURLHERE") -- CHANGE ME!!!!!!!!!!!!!!!!!!!!!
            end
        end
    end)

    local ICON_WIDTH, ICON_HEIGHT = 275, 275
    local HEADER_HEIGHT = 30
    local PADDING = 5
    local SPACING = 15
    local MAX_DESC_HEIGHT = 250 -- max height for descriptions, play with this if you have cut off issues.

    local PANEL = {}

    function PANEL:Init()
        self.tiles = {}
    end

    function PANEL:AddTile(tile)
        table.insert(self.tiles, tile)
        tile:SetParent(self)
    end

    function PANEL:PerformLayout()
        local w = self:GetWide()
        local x, y = 0, 0
        local rowHeight = 0
        local row = {}

        local function layoutRow()
            local totalWidth = -SPACING
            for _, child in ipairs(row) do
                totalWidth = totalWidth + child:GetWide() + SPACING
            end

            local startX = math.max((w - totalWidth) / 2, 0)

            for _, child in ipairs(row) do
                child:SetPos(startX, y)
                startX = startX + child:GetWide() + SPACING
                rowHeight = math.max(rowHeight, child:GetTall())
            end

            y = y + rowHeight + SPACING
            rowHeight = 0
            row = {}
        end

        for _, child in ipairs(self.tiles) do
            local cw, ch = child:GetSize()
            if x + cw > w and #row > 0 then
                layoutRow()
                x = 0
            end

            table.insert(row, child)
            x = x + cw + SPACING
            rowHeight = math.max(rowHeight, ch)
        end

        if #row > 0 then
            layoutRow()
        end

        self:SetTall(y)
    end

    vgui.Register("CenteredWrapPanel", PANEL, "DPanel")

-- Change these to what factions you want to show/what order. THESE MUST BE THE SAME AS YOUR FACTION NAMES!
    local factionOrder = {
        "Imperial Cadet", "Stormtrooper", "224th Armored Division", "Imperial Navy",
        "Super Commandos", "Death Trooper", "Praetorian Guard", "High Command"
    }

-- Set the Icons, USE ONLY IMGUR! THESE MUST BE THE SAME AS YOUR FACTION NAMES!
    local factionIcons = {
        ["Imperial Cadet"] = "https://i.imgur.com/Dbpiuw7.png",
        ["Stormtrooper"] = "https://i.imgur.com/aX2lSI1.png",
        ["224th Armored Division"] = "https://i.imgur.com/y3a2026.png",
        ["Imperial Navy"] = "https://i.imgur.com/Dbpiuw7.png",
        ["Super Commandos"] = "https://i.imgur.com/Dbpiuw7.png",
        ["Death Trooper"] = "https://i.imgur.com/WvKwSwn.png",
        ["Praetorian Guard"] = "https://i.imgur.com/khBtXGV.png",
        ["High Command"] = "https://i.imgur.com/Dbpiuw7.png"
    }

    hook.Add("CreateMenuButtons", "ixFactionsMenuButton", function(tabs)
        tabs["Factions"] = function(container)
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(10, 10, 10, 10)

            local scroll = panel:Add("DScrollPanel")
            scroll:Dock(FILL)

            local wrap = scroll:Add("CenteredWrapPanel")
            wrap:Dock(FILL)

            local nameToFaction = {}
            for _, faction in pairs(ix.faction.indices) do
                if faction.name then
                    nameToFaction[faction.name] = faction
                end
            end

            for _, name in ipairs(factionOrder) do
                local faction = nameToFaction[name]
                if faction then
                    local tile = vgui.Create("DPanel")
                    tile:SetWide(ICON_WIDTH + 20)

                    tile.faction = faction
                    tile.descText = faction.description or "No description available."

                    tile.Paint = function(self, w, h)
                        local bgColor = Color(30, 30, 30, 240)
                        local colorHeader = self.faction.color or Color(70, 70, 70)

                        draw.RoundedBox(12, 0, 0, w, h, bgColor)
                        draw.RoundedBoxEx(12, 0, 0, w, HEADER_HEIGHT, colorHeader, true, true, false, false)

                        draw.SimpleText(self.faction.name, "ixMediumFont", 10, 6, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    end

                    local icon = tile:Add("DHTML")
                    icon:SetSize(ICON_WIDTH, ICON_HEIGHT)
                    icon:SetPos(10, HEADER_HEIGHT + PADDING)
                    icon:SetHTML(string.format([[
                        <html><body style="margin:0;padding:0;overflow:hidden;background:transparent;">
                        <img src="%s" style="width:100%%;height:auto;display:block;margin:auto;">
                        </body></html>
                    ]], factionIcons[name]))

                    local desc = tile:Add("DLabel")
                    desc:SetText(tile.descText)
                    desc:SetFont("ixSmallFont")
                    desc:SetColor(Color(220, 220, 220))
                    desc:SetWrap(true)
                    desc:SetWide(ICON_WIDTH)
                    desc:SetPos(10, HEADER_HEIGHT + PADDING + ICON_HEIGHT + PADDING)

                    desc:SizeToContentsY()

                    local descHeight = math.min(desc:GetTall(), MAX_DESC_HEIGHT)
                    desc:SetTall(descHeight)

                    if desc:GetTall() >= MAX_DESC_HEIGHT then
                        desc:SetToolTip(tile.descText)
                    end

                    local totalHeight = HEADER_HEIGHT + PADDING + ICON_HEIGHT + PADDING + desc:GetTall() + PADDING
                    tile:SetTall(totalHeight)

                    wrap:AddTile(tile)
                end
            end
        end
    end)

    vgui.Register("ixFactionMenuPanel", PANEL, "DPanel")
end