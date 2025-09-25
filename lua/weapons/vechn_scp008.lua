AddCSLuaFile("autorun/vechn_scp008_config.lua")
include("autorun/vechn_scp008_config.lua")

SWEP.PrintName = "SCP 008"
SWEP.Author = "VechniyRabotnik"
SWEP.Instructions = ""
SWEP.Spawnable = true
SWEP.Category = "Vechniy SCP"

SWEP.ViewModel = "" 
SWEP.WorldModel = "" 

SWEP.ViewModelFOV = 0
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local mutations = VECHN_SWEP008_CONFIG.Mutations
local sounds = VECHN_SWEP008_CONFIG.Sounds

local nextMeleeTime = 0
local nextFireTime = 0

function SWEP:Initialize()
    self:SetHoldType("fist")
end

local function ApplyMutation(ply, mutation)
    ply:StripWeapons()
    ply:SetRunSpeed(VECHN_SWEP008_CONFIG.RunSpeed)
    ply:SetWalkSpeed(VECHN_SWEP008_CONFIG.WalkSpeed)
    ply:SetModel(VECHN_SWEP008_CONFIG.DefaultModel)
    ply:SetHealth(1000)
    timer.Remove("PoisonDamage_"..ply:EntIndex())
    timer.Remove("RadEffect_"..ply:EntIndex())

    if mutation == "fast" then
        ply:SetRunSpeed(VECHN_SWEP008_CONFIG.RunSpeed + 200)
        ply:SetWalkSpeed(VECHN_SWEP008_CONFIG.WalkSpeed + 100)
        ply:EmitSound(sounds.Roar)

    elseif mutation == "poison" then
        timer.Create("PoisonDamage_"..ply:EntIndex(), 1, 5, function()
            if IsValid(ply) then
                ply:TakeDamage(3)
            end
        end)
        ply:EmitSound(sounds.Poison)

    elseif mutation == "big" then
        local model = VECHN_SWEP008_CONFIG.MutationsModels.big
        if model then ply:SetModel(model) end
        ply:SetHealth(2000)
        ply:EmitSound(sounds.Roar)

    elseif mutation == "small" then
        local model = VECHN_SWEP008_CONFIG.MutationsModels.small
        if model then ply:SetModel(model) end
        ply:SetHealth(800)
        ply:EmitSound(sounds.Roar)

    elseif mutation == "radioactive" then
        local model = VECHN_SWEP008_CONFIG.MutationsModels.radioactive
        if model then ply:SetModel(model) end
        timer.Create("RadEffect_"..ply:EntIndex(), 2, 0, function()
            if IsValid(ply) and math.random() < 0.1 then
                ply:EmitSound(sounds.Roar)
            end
        end)
        ply:EmitSound(sounds.Roar)
    end
end

local function RemoveMutation(ply)
    ply:SetRunSpeed(VECHN_SWEP008_CONFIG.RunSpeed)
    ply:SetWalkSpeed(VECHN_SWEP008_CONFIG.WalkSpeed)
    ply:SetModel(VECHN_SWEP008_CONFIG.DefaultModel)
    ply:SetHealth(1000)
    timer.Remove("PoisonDamage_"..ply:EntIndex())
    timer.Remove("RadEffect_"..ply:EntIndex())
end

local function GetWeightedRandomMutation()
    local chances = VECHN_SWEP008_CONFIG.MutationChances
    local total = 0
    for _, chance in pairs(chances) do total = total + chance end
    local rand = math.random() * total
    local cumulative = 0
    for mutation, chance in pairs(chances) do
        cumulative = cumulative + chance
        if rand <= cumulative then return mutation end
    end
    return mutations[math.random(#mutations)]
end

local function IsInfected(ply)
    return ply:GetNWBool("Infected", false)
end

local function InfectTarget(attacker, target)
    if not IsValid(target) or not target:IsPlayer() then return end
    if target:GetNWBool("Infected", false) then return end
    target:SetNWBool("Infected", true)
    local mutation = GetWeightedRandomMutation()
    target:SetNWString("MutationType", mutation)
    target:SetNWEntity("Infecter", attacker)
    target:EmitSound(sounds.Infect)
    ApplyMutation(target, mutation)
end
/*
hook.Add("HUDPaint", "DisplayInfectedCount", function()
    local count = 0
    local infectors = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetNWBool("Infected", false) and ply:Alive() then
            count = count + 1
            local infector = ply:GetNWEntity("Infecter")
            if IsValid(infector) then
                local nick = infector:Nick()
                infectors[nick] = (infectors[nick] or 0) + 1
            end
        end
    end
    draw.SimpleText("Заражено: " .. count, "DermaDefaultBold", ScrW() - 150, 10, Color(255,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    local y = 30
    for nick, num in pairs(infectors) do
        draw.SimpleText(nick .. ": " .. num, "DermaDefault", ScrW() - 150, y, Color(255,255,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        y = y + 15
    end
end) */

function SWEP:PrimaryAttack()
    if CLIENT then return end
    if CurTime() < nextMeleeTime then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local dmg = VECHN_SWEP008_CONFIG.MeleeDamage
    local trace = util.TraceLine({start=owner:GetShootPos(), endpos=owner:GetShootPos()+owner:GetAimVector()*75, filter=owner})
    if trace.Hit and IsValid(trace.Entity) and trace.Entity:IsPlayer() then
        trace.Entity:TakeDamage(dmg, owner, self)
    end
    owner:EmitSound("npc/zombie/zombie_attack2.wav")
    nextMeleeTime = CurTime() + 0.5
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    if CurTime() < nextFireTime then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local trace = util.TraceLine({start=owner:GetShootPos(), endpos=owner:GetShootPos()+owner:GetAimVector()*75, filter=owner})
    if trace.Hit and IsValid(trace.Entity) and trace.Entity:IsPlayer() then
        local target = trace.Entity
        if not target:GetNWBool("Infected", false) then
            InfectTarget(owner, target)
        end
    end
    owner:EmitSound(sounds.Infect)
    nextFireTime = CurTime() + 5
end

hook.Add("PlayerSpawn", "ApplyMutationOnSpawn", function(ply)
    if ply:GetNWBool("Infected", false) then
        local mutation = ply:GetNWString("MutationType")
        ApplyMutation(ply, mutation)
    else
        RemoveMutation(ply)
    end
end)

hook.Add("PlayerDeath", "ClearInfectionOnDeath", function(victim)
    if IsValid(victim) then
        victim:SetNWBool("Infected", false)
        victim:SetNWString("MutationType", "")
        victim:SetNWEntity("Infecter", NULL)
        RemoveMutation(victim)
    end
end)

concommand.Add("vechn_exit008", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if ply:GetNWBool("HasProtection", false) then
        ply:SetNWBool("HasProtection", false)
        ply:SetModel("models/player/Group01/male_06.mdl")
        --ply:ChatPrint("Защита снята.")
    else
        --ply:ChatPrint("У вас нет защиты.")
    end
end)