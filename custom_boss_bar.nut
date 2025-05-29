//=========================================================================
//Copyright LizardOfOz.
//=========================================================================

BOSS_BAR_UPDATE_PERIOD <- -1;   //Boss bar update period (in seconds). Set to -1 to update every tick (~0.015s).
                                 //Needs to be less than 1 second for the health number to display correctly.
BOSS_BAR_HIDE_ON_DEATH <- true;
BOSS_BAR_CHANGE_SPEED <- 500;     //The speed of animation in health points at which the bar moves when taking damage.

//====================================
//Don't edit past this line
//====================================

Convars.SetValue("tf_rd_points_per_approach", BOSS_BAR_CHANGE_SPEED + "");
SetPropInt <- ::NetProps.SetPropInt.bindenv(::NetProps);
pd_logic <- Entities.FindByClassname(null, "tf_logic_player_destruction");
::bossEntity <- null;
isHudVisible <- false;

enum leaderboard
{
    tank                = "../hud/leaderboard_class_tank",
    special_blimp       = "../hud/leaderboard_class_special_blimp",
    teleporter          = "../hud/leaderboard_class_teleporter",
    sentry_buster       = "../hud/leaderboard_class_sentry_buster",
    demo                = "../hud/leaderboard_class_demo",
    demo_bomber         = "../hud/leaderboard_class_demo_bomber",
    demo_burst          = "../hud/leaderboard_class_demo_burst",
    demo_glock          = "../hud/leaderboard_class_demo_glock",
    demoknight          = "../hud/leaderboard_class_demoknight",
    demoknight_samurai  = "../hud/leaderboard_class_demoknight_samurai",
    engineer            = "../hud/leaderboard_class_engineer",
    engineer_pomson     = "../hud/leaderboard_class_engineer_pomson",
    engineer_widowmaker = "../hud/leaderboard_class_engineer_widowmaker",
    heavy               = "../hud/leaderboard_class_heavy",
    heavy_champ         = "../hud/leaderboard_class_heavy_champ",
    heavy_chief         = "../hud/leaderboard_class_heavy_chief",
    heavy_deflector     = "../hud/leaderboard_class_heavy_deflector",
    heavy_deflector_push  = "../hud/leaderboard_class_heavy_deflector_push",
    heavy_gru           = "../hud/leaderboard_class_heavy_gru",
    heavy_heater        = "../hud/leaderboard_class_heavy_heater",
    heavy_mittens       = "../hud/leaderboard_class_heavy_mittens",
    heavy_shotgun       = "../hud/leaderboard_class_heavy_shotgun",
    heavy_steelfist     = "../hud/leaderboard_class_heavy_steelfist",
    heavy_urgent        = "../hud/leaderboard_class_heavy_urgent",
    heavy_brassbeast    = "../hud/leaderboard_class_heavy_brassbeast",
    heavy_natascha_slow = "../hud/leaderboard_class_heavy_natascha_slow",
    medic               = "../hud/leaderboard_class_medic",
    medic_crossbow      = "../hud/leaderboard_class_medic_crossbow",
    medic_syringe       = "../hud/leaderboard_class_medic_syringe",
    pyro                = "../hud/leaderboard_class_pyro",
    pyro_manmelter      = "../hud/leaderboard_class_pyro_manmelter",
    pyro_flare          = "../hud/leaderboard_class_pyro_flare",
    scout               = "../hud/leaderboard_class_scout",
    scout_bat           = "../hud/leaderboard_class_scout_bat",
    scout_bonk          = "../hud/leaderboard_class_scout_bonk",
    scout_fan           = "../hud/leaderboard_class_scout_fan",
    scout_giant_fast    = "../hud/leaderboard_class_scout_giant_fast",
    scout_jumping       = "../hud/leaderboard_class_scout_jumping",
    scout_shortstop     = "../hud/leaderboard_class_scout_shortstop",
    scout_stun          = "../hud/leaderboard_class_scout_stun",
    scout_stun_armored  = "../hud/leaderboard_class_scout_stun_armored",
    scout_capper        = "../hud/leaderboard_class_scout_pistol_moon",
    scout_pbpp          = "../hud/leaderboard_class_scout_pocketpistol_heal_lite",
    sniper              = "../hud/leaderboard_class_sniper",
    sniper_bow          = "../hud/leaderboard_class_sniper_bow",
    sniper_bow_multi    = "../hud/leaderboard_class_sniper_bow_multi",
    sniper_jarate       = "../hud/leaderboard_class_sniper_jarate",
    sniper_sydneysleeper    = "../hud/leaderboard_class_sniper_sydneysleeper",
    sniper_smg          = "../hud/leaderboard_class_sniper_smg",
    soldier             = "../hud/leaderboard_class_soldier",
    soldier_backup      = "../hud/leaderboard_class_soldier_backup",
    soldier_barrage     = "../hud/leaderboard_class_soldier_barrage",
    soldier_blackbox    = "../hud/leaderboard_class_soldier_blackbox",
    soldier_buff        = "../hud/leaderboard_class_soldier_buff",
    soldier_burstfire   = "../hud/leaderboard_class_soldier_burstfire",
    soldier_conch       = "../hud/leaderboard_class_soldier_conch",
    soldier_crit        = "../hud/leaderboard_class_soldier_crit",
    soldier_libertylauncher = "../hud/leaderboard_class_soldier_libertylauncher",
    soldier_major_crits = "../hud/leaderboard_class_soldier_major_crits",
    soldier_sergeant_crits  = "../hud/leaderboard_class_soldier_sergeant_crits",
    soldier_spammer     = "../hud/leaderboard_class_soldier_spammer",
    soldier_bison       = "../hud/leaderboard_class_soldier_bison",
    soldier_cowmangler  = "../hud/leaderboard_class_soldier_cowmangler",
    spy                 = "../hud/leaderboard_class_spy",
}

function SpawnBossBar()
{
    if (pd_logic != null)
        return;
    pd_logic = SpawnEntityFromTable("tf_logic_player_destruction", {
        blue_respawn_time = 0,
        finale_length = 999999,
        flag_reset_delay = 0,
        heal_distance = 0,
        min_points = 255,
        points_per_player = 0,
        red_respawn_time = 0,
        targetname = "pd_logic",
        res_file = "resource/ui/custom_boss_bar.res"
    });
    SetPropInt(pd_logic, "m_nBlueScore", 0);
    SetPropInt(pd_logic, "m_nRedScore", 0);
    SetPropInt(pd_logic, "m_nBlueTargetPoints", 0);
    SetPropInt(pd_logic, "m_nRedTargetPoints", 0);
    SetPropInt(pd_logic, "m_nMaxPoints", 255);
    EntFireByHandle(pd_logic, "SetPointsOnPlayerDeath", "0", -1, null, null);
    EntFireByHandle(pd_logic, "SetPointsOnPlayerDeath", "0", 0.1, null, null);
    EntFireByHandle(pd_logic, "SetPointsOnPlayerDeath", "0", 1, null, null);
    EntFireByHandle(pd_logic, "EnableMaxScoreUpdating", "", -1, null, null);
    EntFireByHandle(pd_logic, "DisableMaxScoreUpdating", "", 5, null, null);
}
SpawnBossBar();

::UpdateBossBarLeaderboardIcon <- function(icon)
{
    EntFire("pd_logic", "setcountdownimage", icon, 0, null);
}

function SetBossBarValue(currentHP, maxHP, AllowBoss)
{
    if (currentHP > maxHP)
        maxHP = currentHP;
    if (currentHP > 1)
        currentHP++;

	if(AllowBoss)
	{
        local barValue = floor(clamp(255.0 * bossEntity.GetHealth() / bossEntity.GetMaxHealth(), 1, 255));
		SetPropInt(pd_logic, "m_nBlueScore", currentHP);
		SetPropInt(pd_logic, "m_nBlueTargetPoints", barValue);
		EntFireByHandle(pd_logic, "setcountdowntimer", currentHP + "", 0, null, null);
	}

    if (floor(currentHP) <= 0 || floor(maxHP) <= 0)
    {
		SetPropInt(pd_logic, "m_nBlueScore", 0);
		SetPropInt(pd_logic, "m_nBlueTargetPoints", 0);
        isHudVisible = false;
		bossEntity = null;
    }
    else if (!isHudVisible)
    {
        isHudVisible = true;
    }
}

function Think()
{
    if (!bossEntity || !bossEntity.IsValid()
        || bossEntity.GetMaxHealth() <= 0
        || (BOSS_BAR_HIDE_ON_DEATH && NetProps.GetPropInt(bossEntity, "m_lifeState") != 0))
    {
        if (isHudVisible)
		{
            SetBossBarValue(0, 0, false);
			EntFireByHandle(pd_logic, "setcountdowntimer", 0 + "", 0, null, null);
		}
        return BOSS_BAR_UPDATE_PERIOD;
    }
	else
	{
		local AllowBoss = true
        if(bossEntity == null) AllowBoss = false
        debugPrint("allow boss? " + AllowBoss)
		SetBossBarValue(bossEntity.GetHealth(), bossEntity.GetMaxHealth(), AllowBoss);
		return BOSS_BAR_UPDATE_PERIOD;
	}
}

::SetBossEntity <- function(newBossEntity)
{
    bossEntity = newBossEntity;
}

/*
This is how we make CompilePal include custom files.
PrecacheModel("resource/ui/custom_boss_bar.res");
PrecacheModel("materials/hud/custom_boss_bar.vmt");
PrecacheModel("materials/hud/custom_boss_bar.vtf");
PrecacheModel("materials/hud/custom_boss_bar_surround.vmt");
PrecacheModel("materials/hud/custom_boss_bar_surround.vtf");
*/