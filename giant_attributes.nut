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
    "airblast vulnerability multiplier" : 0.0,
    "health from packs decreased" : 0.0,
	"cancel falling damage" : 1.0
}

//TODO: replace these with trigger hurt's models
//also need to be precached
::giantModels <-
{
	TF_CLASS_SCOUT = "models/bots/scout_boss/bot_scout_boss.mdl",
	TF_CLASS_SOLDIER = "models/bots/soldier_boss/bot_soldier_boss.mdl",
	TF_CLASS_PYRO = "models/bots/pyro_boss/bot_pyro_boss.mdl",
	TF_CLASS_DEMOMAN = "models/bots/demo_boss/bot_demo_boss.mdl",
	TF_CLASS_HEAVYWEAPONS = "models/bots/heavy_boss/bot_heavy_boss.mdl",
	TF_CLASS_ENGINEER = "models/bots/engineer/bot_engineer.mdl",
	TF_CLASS_MEDIC = "models/bots/medic/bot_medic.mdl",
	TF_CLASS_SNIPER = "models/bots/sniper/bot_sniper.mdl",
	TF_CLASS_SPY = "models/bots/spy/bot_spy.mdl"
}

//these need to be precached
::giantSounds <- {
	TF_CLASS_SCOUT = null,
	TF_CLASS_SOLDIER = "vo/mvm/mght/soldier_mvm_m_autodejectedtie02.mp3",
	TF_CLASS_PYRO = null,
	TF_CLASS_DEMOMAN = null,
	TF_CLASS_HEAVYWEAPONS = "vo/mvm/mght/heavy_mvm_m_battlecry01.mp3",
	TF_CLASS_ENGINEER = null,
	TF_CLASS_MEDIC = null,
	TF_CLASS_SNIPER = null,
	TF_CLASS_SPY = null
}

local giantSoldier = {
    classId                     = TF_CLASS_SOLDIER,
    giantName                   = "Giant Soldier",
    baseHealth                  = 10000.0,
    playerModel                 = giantModels[TF_CLASS_SOLDIER],
    primaryWeaponID             = 205,
    primaryWeaponClassName      = "tf_weapon_rocketlauncher",
    secondaryWeaponID           = null,
    secondaryWeaponClassName    = null,
    meleeWeaponID               = 196,
    meleeWeaponClassName        = "tf_weapon_shovel",
    respawnOverride             = null, //If not null, sets blue respawn time to this number
    playerInfo                  = "-Increased explosion damage and radius.\n-Moves slower than most giants.",
    introSound                  = giantSounds[TF_CLASS_SOLDIER],
    playerAttributes            =
    {
        "move speed bonus"				: 0.43,
        "override footstep sound set"	: 3.0,
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
    classId                     = TF_CLASS_HEAVYWEAPONS,
    giantName                   = "Giant Heavy",
    baseHealth                  = 10000.0,
    playerModel                 = giantModels[TF_CLASS_HEAVYWEAPONS],
    primaryWeaponID             = 202,
    primaryWeaponClassName      = "tf_weapon_minigun",
    secondaryWeaponID           = null,
    secondaryWeaponClassName    = null,
    meleeWeaponID               = 5,
    meleeWeaponClassName        = "tf_weapon_fists",
    respawnOverride             = null, //If not null, sets blue respawn time to this number
    playerInfo                  = "-Minigun deals +60% more damage.\n-Moves slower than any other giant while attacking.",
    introSound                  = giantSounds[TF_CLASS_HEAVYWEAPONS],
    playerAttributes            =
    {
        "move speed bonus"              : 0.5,
        "override footstep sound set"   : 2.0,
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

local giantRapidFireDemo = {
	classId 					= TF_CLASS_DEMOMAN,
	giantName                   = "Giant Rapid Fire Demoman",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_DEMOMAN],
	primaryWeaponID             = 206,
	primaryWeaponClassName      = "tf_weapon_grenadelauncher",
	secondaryWeaponID           = null,
	secondaryWeaponClassName    = null,
	meleeWeaponID               = 1,
	meleeWeaponClassName        = "tf_weapon_bottle",
	respawnOverride             = null,
	playerInfo                  = "-Shoots and reloads grenades rapidly.\n-Moves slower than most giants.",
	introSound                  = giantSounds[TF_CLASS_DEMOMAN],	
	playerAttributes =
	{
		"move speed bonus"            : 0.42,
		"override footstep sound set" : 4.0,
		"damage force increase"       : 2.2
	},
	primaryAttributes =
	{
		"faster reload rate"          : 0.25,
		"fire rate bonus"             : 0.25,
		"clip size upgrade atomic"    : 2.0,
		"maxammo primary increased"   : 5.0,
		"crit mod disabled"           : 0.0
	}
    secondaryAttributes         = null,
    meleeAttributes             = null
}

local giantPyro = {
	classId 					= TF_CLASS_PYRO,
	giantName                   = "Giant Pyro",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_PYRO],
	primaryWeaponID             = 208,
	primaryWeaponClassName      = "tf_weapon_flamethrower",
	secondaryWeaponID           = 39,
	secondaryWeaponClassName    = "tf_weapon_flaregun",
	meleeWeaponID               = 192,
	meleeWeaponClassName        = "tf_weapon_fireaxe",
	respawnOverride             = null,
	playerInfo                  = "-Increased direct flame damage and range.\n-Equipped with a high damage Flare Gun.\n-Reflected projectiles turn into crits.",
	introSound                  = giantSounds[TF_CLASS_PYRO],	
	playerAttributes =
	{
		"move speed bonus"                 : 0.57,
		"override footstep sound set"      : 6.0,
		"damage force increase"            : 2.0,
		"flame life bonus"                 : 1.5
	},
	primaryAttributes =
	{
		"airblast cost decreased"          : 0.0,
		"damage bonus"                     : 1.65,
		"airblast pushback scale"          : 1.75,
		"airblast vertical pushback scale" : 1.75,
		"deflection size multiplier"       : 0.4,
		"crit mod disabled"                : 0.0
	}
    secondaryAttributes = 
	{
		"damage bonus"                     : 4.0
	},
    meleeAttributes             = null
}

local giantRapidFireHuntsman = {
	classId 					= TF_CLASS_SNIPER,
	giantName                   = "Giant Rapid Fire Huntsman",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_PYRO],
	primaryWeaponID             = 56,
	primaryWeaponClassName      = "tf_weapon_compound_bow",
	secondaryWeaponID           = 58,
	secondaryWeaponClassName    = "tf_weapon_jar",
	meleeWeaponID               = 232,
	meleeWeaponClassName        = "tf_weapon_club",
	respawnOverride             = null,
	playerInfo                  = "-Increased arrow damage and reload speed.\n-Carries 5 Jarates at once.\n-Bushwacka doesn't increase damage taken.",
	introSound                  = giantSounds[TF_CLASS_SNIPER],	
	playerAttributes =
	{
		"move speed bonus"                 : 0.5,
		"override footstep sound set"      : 4.0,
		"damage force increase"            : 2.2
	},
	primaryAttributes =
	{
		"faster reload rate"          		: 0.3,
		"aiming movespeed increased"        : 1.3,
		"dmg penalty vs buildings"          : 0.85
	}
    secondaryAttributes = 
	{
		"effect bar recharge rate increased"   	: 0.3,
		"maxammo grenades1 increased"   		: 5.0,
		"deploy time decreased"   				: 0.35,
	},
    meleeAttributes = 
	{
		"dmg taken increased"   	: 1.0
	}
}

local majorLeagueScout = {
	classId 					= TF_CLASS_SCOUT,
	giantName                   = "Major League Scout",
	baseHealth                  = 6000.0
	playerModel                 = giantModels[TF_CLASS_SCOUT],
	primaryWeaponID             = 200,
	primaryWeaponClassName      = "tf_weapon_scattergun",
	secondaryWeaponID           = null,
	secondaryWeaponClassName    = null,
	meleeWeaponID               = 190,
	meleeWeaponClassName        = "tf_weapon_bat",
	respawnOverride             = 0.1,
	playerInfo                  = "-Moves faster than most giants.\n-Captures control points twice as fast.\n-Teammates respawn much faster.\n-Low health compared to most giants.",
	introSound                  = giantSounds[TF_CLASS_SCOUT],	
	playerAttributes =
	{
		"move speed bonus"                 : 0.75,
		"override footstep sound set"      : 5.0,
		"damage force increase"            : 2.2
	},
	primaryAttributes =
	{
		"damage bonus"          		: 1.35
	}
    secondaryAttributes = null,
    meleeAttributes = 
	{
		"melee attack rate bonus"   	: 0.7,
		"deploy time decreased"		   	: 0.35,
		"crit mod disabled"			   	: 0.0
	}
}

::giantProperties[0] <- giantHeavy
::giantProperties[1] <- giantSoldier
::giantProperties[2] <- giantRapidFireDemo
::giantProperties[3] <- giantPyro
::giantProperties[4] <- giantRapidFireHuntsman
::giantProperties[5] <- majorLeagueScout