PLUGIN.name = "Force Fallover"
PLUGIN.author = "Linkz"
PLUGIN.description = "Allows staff to force a player into the fallover state."
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

ix.command.Add("ForceFallover", {
    description = "Force a player into a fallover ragdoll state.",
    arguments = {
        ix.type.player,
        bit.bor(ix.type.number, ix.type.optional)
    },
    adminOnly = true,

    OnRun = function(self, client, target, duration)
        if (!IsValid(target) or !target:GetCharacter()) then
            return "Invalid target player."
        end

        if (target.ixRagdoll) then
            return target:Name() .. " is already ragdolled."
        end

        duration = duration or 10 -- default to 10 seconds if not specified

        target:SetRagdolled(true, duration)

        client:Notify("You have forced " .. target:Name() .. " to fall over for " .. duration .. " seconds.")
        target:Notify("You have been forced into a fallover state by staff.")
    end
})