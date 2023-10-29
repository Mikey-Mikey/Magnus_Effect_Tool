TOOL.Category = "Construction"
TOOL.Name = "#tool.magnus_tool.name"
TOOL.AddToMenu = true
TOOL.ClientConVar["strength"] = 1.0

TOOL.Information = {
    { name = "left" },
    { name = "right" }
}

if CLIENT then
    language.Add("tool.magnus_tool.left", "Apply/Update Magnus Effect")
    language.Add("tool.magnus_tool.right", "Remove Magnus Effect")
    language.Add("tool.magnus_tool.desc", "Apply the magnus effect to entities!")
    language.Add("tool.magnus_tool.name", "Magnus Tool")
end

local function CleanTable(tbl)
    for i = #tbl, 1, -1 do
        if not tbl[i] or not IsValid(tbl[i]) then
            table.remove(tbl, i)
        end
    end
end

function TOOL:Deploy()
    print("deploy")
end

function TOOL:LeftClick(tr)
    if tr.Entity:IsValid() or (CPPI and tr.Entity:IsValid() and tr.Entity:GetCPPIOwner() == self:GetOwner()) then
        local ent = tr.Entity
        if SERVER then
            ent.using_magnus = true
            ent.magnus_strength = self:GetClientNumber("strength")
            if not self:GetOwner().magnus_ents then
                self:GetOwner().magnus_ents = {}
            end
            self:GetOwner().magnus_ents[#self:GetOwner().magnus_ents + 1] = ent
        end
        return true
    end
    return false
end

function TOOL:RightClick(tr)
    if tr.Entity:IsValid() or (CPPI and tr.Entity:IsValid() and tr.Entity:GetCPPIOwner() == self:GetOwner()) then
        local ent = tr.Entity
        if SERVER then
            ent.using_magnus = false
        end
        return true
    end
    return false
end

function TOOL.BuildCPanel(panel)
    panel:NumSlider("Strength", "magnus_tool_strength", 0, 100)
end

hook.Add("Think", "magnus_tool_physics", function()
    for k, ply in ipairs(player.GetHumans()) do
        if ply.magnus_ents then
            CleanTable(ply.magnus_ents) -- This clears the magnus table of invalid entities
            for i, ent in ipairs(ply.magnus_ents) do
                if not ent.using_magnus then continue end
                local phys = ent:GetPhysicsObject()
                local force = phys:LocalToWorldVector(phys:GetAngleVelocity()):Cross(phys:GetVelocity()) * ent.magnus_strength * 0.001 * FrameTime()
                phys:ApplyForceCenter(force * phys:GetMass())
            end
        end
    end
end)