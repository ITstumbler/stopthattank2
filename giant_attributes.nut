::GivePlayerWeapon <- function(player, className, itemID, itemSlotToDestroy=0)
{
    //Setting itemID to null means that we dont want players to have anything in that slot
    if(itemID == null)
    {
        // remove existing weapon in same slot
        for (local i = 0; i < MaxWeapons; i++)
        {
            local heldWeapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
            if (heldWeapon == null)
                continue
            if (heldWeapon.GetSlot() != itemSlotToDestroy)
                continue
            heldWeapon.Destroy()
            NetProps.SetPropEntityArray(player, "m_hMyWeapons", null, i)
            break
        }
        return
    }
    
    local weapon = Entities.CreateByClassname(className)
    NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID)
    NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
    NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
    weapon.SetTeam(player.GetTeam())
    weapon.DispatchSpawn()

    // remove existing weapon in same slot
    for (local i = 0; i < MaxWeapons; i++)
    {
        local heldWeapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (heldWeapon == null)
            continue
        if (heldWeapon.GetSlot() != weapon.GetSlot())
            continue
        heldWeapon.Destroy()
        NetProps.SetPropEntityArray(player, "m_hMyWeapons", null, i)
        break
    }
    
    player.Weapon_Equip(weapon)
    player.Weapon_Switch(weapon)

    return weapon
}

//Remember to assign each giant an ID at the bottom!!
//Also adjust GIANT_TYPES_AMOUNT in round_setup.nut because im too lazy to change the code to calc len
::giantProperties <- {}

//max health additive bonus needs to be used to apply max hp, which stacks with the base hp
::baseClassHealth <- {}
::baseClassHealth[TF_CLASS_SCOUT] <- 125
::baseClassHealth[TF_CLASS_SOLDIER] <- 200
::baseClassHealth[TF_CLASS_PYRO] <- 175
::baseClassHealth[TF_CLASS_DEMOMAN] <- 175
::baseClassHealth[TF_CLASS_HEAVYWEAPONS] <- 300
::baseClassHealth[TF_CLASS_ENGINEER] <- 125
::baseClassHealth[TF_CLASS_MEDIC] <- 150
::baseClassHealth[TF_CLASS_SNIPER] <- 125
::baseClassHealth[TF_CLASS_SPY] <- 125

//Apply these attributes to ALL giants
::globalGiantAttributes <-
{
    "airblast vulnerability multiplier": 0.0,
    "health from packs decreased": 0.0
}

local giantSoldier = {
    classId                     = TF_CLASS_SOLDIER
    baseHealth                  = 10000.0,
    playerModel                 = "models/bots/soldier_boss/bot_soldier_boss.mdl",
    primaryWeaponID             = 205,
    primaryWeaponClassName      = "tf_weapon_rocketlauncher",
    secondaryWeaponID           = null,
    secondaryWeaponClassName    = null,
    meleeWeaponID               = 196,
    meleeWeaponClassName        = "tf_weapon_shovel",
    giantName                   = "Giant Soldier",
    playerInfo                  = "-Increased explosion damage and radius.\n-Moves slower than most giants.",
    playerAttributes            =
    {
        "move speed bonus"				: 0.43,
        "override footstep sound set"	: 3.0,
        "cancel falling damage"			: 1.0,
        "damage force increase"			: 2.2
    },
    primaryAttributes           =
    {
        "damage bonus"					: 1.75,
        "blast radius increased"		: 1.2,
        "crit mod disabled"			    : 0.0
    },
    secondaryAttributes         = null,
    meleeAttributes             = null
}

local giantHeavy = {
    classId                     = TF_CLASS_HEAVYWEAPONS
    baseHealth                  = 10000.0,
    playerModel                 = "models/bots/heavy_boss/bot_heavy_boss.mdl",
    primaryWeaponID             = 202,
    primaryWeaponClassName      = "tf_weapon_minigun",
    secondaryWeaponID           = null,
    secondaryWeaponClassName    = null,
    meleeWeaponID               = 5,
    meleeWeaponClassName        = "tf_weapon_fists",
    giantName                   = "Giant Heavy",
    playerInfo                  = "-Minigun deals +60% more damage.\n-Moves slower than any other giant while attacking.",
    playerAttributes            =
    {
        "move speed bonus"              : 0.5,
        "override footstep sound set"   : 2.0,
        "cancel falling damage"         : 1.0,
        "damage force increase"         : 2.2
    },
    primaryAttributes           =
    {
        "damage bonus"                  : 1.6,
        "minigun no spin sounds"		: 1.0,
        "crit mod disabled"				: 0.0,
        "aiming movespeed increased"	: 1.3,
        "dmg penalty vs buildings"		: 9999
    },
    secondaryAttributes         = null,
    meleeAttributes             = null
}

::giantProperties[0] <- giantHeavy
::giantProperties[1] <- giantSoldier