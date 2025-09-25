AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Anti-008"
ENT.Author = "VechniyRabotnik"
ENT.Spawnable = true
ENT.Category = "Vechniy SCP"

function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box003b.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys and phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    activator:SetNWBool("HasProtection", true)
    activator:SetModel("models/player/gasmask.mdl")
end