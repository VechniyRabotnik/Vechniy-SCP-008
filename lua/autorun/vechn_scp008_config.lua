VECHN_SWEP008_CONFIG = {
    MutationsModels = {
        big = "models/player/zombie_soldier.mdl",
        small = "models/player/skeleton.mdl",
        poison = "models/player/charple.mdl",
        fast = "models/player/zombie_fast.mdl",
        radioactive = "models/player/corpse1.mdl",
    },

    Mutations = {
        "fast",
        "poison",
        "big",
        "small",
        "radioactive"
    },

    MutationChances = {
    fast = 0.2,
    poison = 0.3,
    big = 0.15,
    small = 0.15,
    radioactive = 0.2
    },

    Sounds = {
        Infect = "npc/zombie/zombie_die3.wav",
        Attack = "npc/zombie/zombie_attack2.wav",
        Poison = "npc/zombie/zombie_alert2.wav",
        Roar = "npc/zombie/zombie_attack3.wav"
    },

    DefaultModel = "models/player/zombie_classic.mdl",

    RunSpeed = 300,
    WalkSpeed = 200,

    MeleeDamage = 30
}