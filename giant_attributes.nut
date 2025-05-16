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
::giantModels <- {}

::giantModels[TF_CLASS_SCOUT] 			<- "models/bots/scout_boss/bot_scout_boss.mdl"
::giantModels[TF_CLASS_SOLDIER] 		<- "models/bots/soldier_boss/bot_soldier_boss.mdl"
::giantModels[TF_CLASS_PYRO] 			<- "models/bots/pyro_boss/bot_pyro_boss.mdl"
::giantModels[TF_CLASS_DEMOMAN] 		<- "models/bots/demo_boss/bot_demo_boss.mdl"
::giantModels[TF_CLASS_HEAVYWEAPONS] 	<- "models/bots/heavy_boss/bot_heavy_boss.mdl"
::giantModels[TF_CLASS_ENGINEER] 		<- "models/bots/engineer/bot_engineer.mdl"
::giantModels[TF_CLASS_MEDIC] 			<- "models/bots/medic/bot_medic.mdl"
::giantModels[TF_CLASS_SNIPER] 			<- "models/bots/sniper/bot_sniper.mdl"
::giantModels[TF_CLASS_SPY]		 		<- "models/bots/spy/bot_spy.mdl"

//these need to be precached
::giantSounds <- {}
::giantSounds[TF_CLASS_SCOUT] <- null
::giantSounds[TF_CLASS_SOLDIER] <- "vo/mvm/mght/soldier_mvm_m_autodejectedtie02.mp3"
::giantSounds[TF_CLASS_PYRO] <- null
::giantSounds[TF_CLASS_DEMOMAN] <- null
::giantSounds[TF_CLASS_HEAVYWEAPONS] <- "vo/mvm/mght/heavy_mvm_m_battlecry01.mp3"
::giantSounds[TF_CLASS_ENGINEER] <- null
::giantSounds[TF_CLASS_MEDIC] <- null
::giantSounds[TF_CLASS_SNIPER] <- null
::giantSounds[TF_CLASS_SPY] <- null


local giantSoldier = { //TODO: Use giant attack sounds
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
	conds						= null,
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

local giantHeavy = { //TODO: Custom minigun spin sounds
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
	conds						= null, //If not null, list of conds to permanently apply to the giant
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

local giantRapidFireDemo = { //TODO: Use giant attack sounds
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
	conds						= null,
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

local giantPyro = { //TODO: Use giant attack sounds
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
	conds						= null,
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

local giantRapidFireHuntsman = { //TODO: make this guy spawn with 5 jarates
	classId 					= TF_CLASS_SNIPER,
	giantName                   = "Giant Rapid Fire Huntsman",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_SNIPER],
	primaryWeaponID             = 56,
	primaryWeaponClassName      = "tf_weapon_compound_bow",
	secondaryWeaponID           = 58,
	secondaryWeaponClassName    = "tf_weapon_jar",
	meleeWeaponID               = 232,
	meleeWeaponClassName        = "tf_weapon_club",
	respawnOverride             = null,
	conds						= null,
	playerInfo                  = "-Increased arrow damage and reload speed.\n-Can recharge and store up to 5 Jarates at once.\n-Bushwacka doesn't increase damage taken.",
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
	conds						= null,
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

local giantDemoknight = {
	classId 					= TF_CLASS_DEMOMAN,
	giantName                   = "Giant Demoknight",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_DEMOMAN],
	primaryWeaponID             = null,
	primaryWeaponClassName      = null,
	secondaryWeaponID           = 131,
	secondaryWeaponClassName    = "tf_wearable_demoshield",
	meleeWeaponID               = 132,
	meleeWeaponClassName        = "tf_weapon_sword",
	respawnOverride             = null,
	conds						= null,
	playerInfo                  = "-Gains crits and health on every kill.\n-Full turning control while charging.\n-Melee damage and range increased.\n-Resistant to explosive and fire damage.",
	introSound                  = giantSounds[TF_CLASS_DEMOMAN],	
	playerAttributes =
	{
		"move speed bonus"                 : 0.5,
		"override footstep sound set"      : 4.0,
		"damage force increase"            : 2.0
	},
	primaryAttributes = null,
    secondaryAttributes = 
	{
		"charge recharge rate increased"   	: 1.25,
		"full charge turn control"	   		: 50.0,
		"charge impact damage increased"	: 2.0
	},
    meleeAttributes = 
	{
		"melee attack rate bonus"   	: 0.8,
		"melee range multiplier"	   	: 1.5,
		"critboost on kill"			   	: 3.0,
		"damage bonus"			   		: 2.4,
		"charge time increased"			: 0.5,
		"heal on kill"					: 200.0,
		"decapitate type"				: 0.0,
		"max health additive penalty"	: 0.0
	}
}

local giant10ShotBazookaSoldier = {
	classId 					= TF_CLASS_SOLDIER,
	giantName                   = "Giant 10-shot Bazooka Soldier",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_SOLDIER],
	primaryWeaponID             = 730,
	primaryWeaponClassName      = "tf_weapon_rocketlauncher",
	secondaryWeaponID           = null,
	secondaryWeaponClassName    = null,
	meleeWeaponID               = 196,
	meleeWeaponClassName        = "tf_weapon_shovel",
	respawnOverride             = null,
	conds						= null,
	playerInfo                  = "-Loads up to 10 rockets rapidly.\n-Cannot overload.\n-6 degrees in random projectile deviation.",
	introSound                  = giantSounds[TF_CLASS_SOLDIER],	
	playerAttributes =
	{
		"move speed bonus"                 : 0.42,
		"override footstep sound set"      : 3.0,
		"damage force increase"            : 2.2
	},
	primaryAttributes = 
	{
		"crit mod disabled"   				: 0.0,
		"clip size upgrade atomic"	   		: 7.0,
		"damage penalty"					: 0.6,
		"projectile spread angle penalty"	: 6.0,
		"faster reload rate"				: 0.2,
		"fire rate bonus"					: 0.2,
		"can overload"						: 0.0,
		"maxammo primary increased"			: 5.0,
		"blast radius decreased"			: 1.0,
		"blast dmg to self increased"		: 0.65
	},
    secondaryAttributes = null,	
    meleeAttributes = null
}

local giantShotgunHeavy = {
	classId 					= TF_CLASS_HEAVYWEAPONS,
	giantName                   = "Giant Shotgun Heavy",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_HEAVYWEAPONS],
	primaryWeaponID             = null,
	primaryWeaponClassName      = null,
	secondaryWeaponID           = 199,
	secondaryWeaponClassName    = "tf_weapon_shotgun_hwg",
	meleeWeaponID               = 43,
	meleeWeaponClassName        = "tf_weapon_fists",
	respawnOverride             = null,
	conds						= null,
	playerInfo                  = "-Can one-shot almost every enemy in close range.\n-Melee weapon gives crits for 7s on kill.\n-Weak at longer ranges.",
	introSound                  = giantSounds[TF_CLASS_HEAVYWEAPONS],	
	playerAttributes =
	{
		"move speed bonus"                 : 0.61,
		"override footstep sound set"      : 2.0,
		"damage force increase"            : 2.2
	},
	primaryAttributes = null,
    secondaryAttributes = 
	{
		"fire rate penalty"   				: 2.3,
		"bullets per shot bonus"   			: 10.0,
		"damage penalty"	   				: 0.5,
		"faster reload rate"   				: 0.1,
		"crit mod disabled"   				: 0.0
	},	
    meleeAttributes = 
	{
		"critboost on kill"   				: 7.0,
		"melee range multiplier"   			: 1.5,
		"melee attack rate bonus"   		: 0.65,
		"deploy time decreased"   			: 0.35,
		"crit mod disabled"   				: 0.0
	}
}

local sirNukesalot = { //TODO: Use giant attack sounds
	classId 					= TF_CLASS_DEMOMAN,
	giantName                   = "Sir Nukesalot",
	baseHealth                  = 10000.0
	playerModel                 = giantModels[TF_CLASS_DEMOMAN],
	primaryWeaponID             = 996,
	primaryWeaponClassName      = "tf_weapon_cannon",
	secondaryWeaponID           = null,
	secondaryWeaponClassName    = null,
	meleeWeaponID               = 1,
	meleeWeaponClassName        = "tf_weapon_bottle",
	respawnOverride             = null,
	conds						= [44],
	playerInfo                  = "-Can clear large groups of enemies with a single shot.\n-Explosions can be used as a smoke screen for your team.\n-Vulnerable in close range combat.",
	introSound                  = giantSounds[TF_CLASS_DEMOMAN],	
	playerAttributes =
	{
		"move speed bonus"            : 0.43,
		"override footstep sound set" : 4.0,
		"damage force increase"       : 2.2
	},
	primaryAttributes =
	{
		"grenade launcher mortar mode"          : 0.0,
		"Projectile speed increased"            : 0.8,
		"Reload time increased"    				: 1.8,
		"fire rate penalty"   					: 2.0,
		"clip size penalty"           			: 0.25,
		"damage bonus"           				: 100.0,
		"damage causes airblast"           		: 1.0,
		"blast radius increased"           		: 2.0,
		"use large smoke explosion"           	: 1.0
	}
    secondaryAttributes         = null,
    meleeAttributes             = null
}
//Remember to update GIANT_TYPES_AMOUNT in round_setup.nut
::giantProperties[0] <- giantHeavy
::giantProperties[1] <- giantSoldier
::giantProperties[2] <- giantRapidFireDemo
::giantProperties[3] <- giantPyro
::giantProperties[4] <- giantRapidFireHuntsman
::giantProperties[5] <- majorLeagueScout
::giantProperties[6] <- giantDemoknight
::giantProperties[7] <- giant10ShotBazookaSoldier
::giantProperties[8] <- giantShotgunHeavy
::giantProperties[9] <- sirNukesalot