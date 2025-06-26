local PLUGIN = PLUGIN

PLUGIN.name = "Removes Stuff"
PLUGIN.author = "Linkz"
PLUGIN.descripton = "Removes Default Hands/Keys/Ammo HUD, could add more."
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

function PLUGIN:PostPlayerLoadout(client)
    timer.Simple(0, function()
        if (IsValid(client)) then
            client:StripWeapon("ix_hands")
            client:StripWeapon("ix_keys")
        end
    end)
end

function PLUGIN:CanDrawAmmoHUD(weapon)
    return false
end

function PLUGIN:CanCreateCharacterInfo(suppress)
	suppress.attributes = true -- Hides the attributes panel from the character info tab
end