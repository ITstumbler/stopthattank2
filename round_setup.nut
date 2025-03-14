//Allows us to reference constants by name so no need to remember the cringe out-of-order class ID e.g. TF_CLASS_SNIPER = 2
::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
    foreach (a,b in Constants)
        foreach (k,v in b)
            ROOT[k] <- v != null ? v : 0;
}

//Balance-sensitive parameters
::TANK_SPEED                        <- 75           //The speed at which the tank goes. The fake_train in the map must be set to the same speed
::BASE_TANK_HEALTH                  <- 12000        //Base tank health, will be increased or decreased if the amount of players on red is more or less than BASE_TANK_PLAYER_COUNT. Can be overriden using overrideBaseTankHealth(health)
::BASE_TANK_PLAYER_COUNT            <- 12           //If there are this many players on red team, the tank will use BASE_TANK_HEALTH. Scaled linearly if there are more or less players on red team
::POST_SETUP_LENGTH                 <- 5            //Time between setup ending and tank spawning
::INTERMISSION_LENGTH               <- 15           //Time between tank dying and giant spawning   
::BOMB_MISSION_LENGTH               <- 150          //Time blu has to deploy the bomb the moment their giant can move, in seconds (like everything else)
::TOP_PLAYERS_ELIGIBLE_FOR_GIANT    <- 5            //Pick from the first x top performing players in scoreboard to be giant
::GIANT_TYPES_AMOUNT                <- 2            //Pick first x giant templates to choose from
::GIANT_SCALE                       <- 1.75         //Giant players will be scaled by this much
::INTERMISSION_ROLLBACK_SPEED       <- 400          //HUD tank rolls back during intermission - this determines its speed
::BOMB_CARRIER_CONDS                <- {            //Conditions to apply to non-giant players carrying the bomb. Value determines duration (-1: infinite)
                                        [TF_COND_OFFENSEBUFF]               = -1,
                                        [TF_COND_DEFENSEBUFF_NO_CRIT_BLOCK] = -1,
                                        [TF_COND_HALLOWEEN_QUICK_HEAL]      = 3
                                       }
::BOMB_CARRIER_ATTRIBUTES           <- {            //Attributes to apply to non-giant players carrying the bomb
                                        "move speed penalty": 0.8,
                                        "self dmg push force decreased": 0.01
                                       }
::MINIMUM_PLAYERS_FOR_BOMB_BUFFS    <- 5            //If there are less than this many players on red, do not apply any conds
::BOMB_CARRIER_TEMP_CONDS_DELAY     <- 10           //Temporary conds will be blocked if a player recently dropped the bomb, this is the delay (seconds) that allows said player to get temp conds again
::BASE_GIANT_HEALING                <- 1            //Multiply ALL healing received by giant players by this much if player count is at BASE_GIANT_PLAYER_COUNT. Increased or decreased linearly if the amount of players on red is higher or lower than that.
::BASE_GIANT_PLAYER_COUNT           <- 12           //If there are this many players on red team, all giants have their base hp and all healing received is multiplied by BASE_GIANT_HEALING. Increased or decreased linearly if the amount of players on red is higher or lower than that. 
::RED_TANK_RESPAWN_TIME             <- 0.1          //Sets red's respawn time, in seconds, while tank is active 
::BLUE_TANK_RESPAWN_TIME            <- 3            //Sets blu's respawn time, in seconds, while tank is active 
::RED_INTERMISSION_RESPAWN_TIME     <- 0.1          //Sets red's respawn time, in seconds, during intermission
::BLUE_INTERMISSION_RESPAWN_TIME    <- 0.1          //Sets blu's respawn time, in seconds, during intermission 
::RED_GIANT_RESPAWN_TIME            <- 3            //Sets red's respawn time, in seconds, while giant is active 
::BLUE_GIANT_RESPAWN_TIME           <- 9            //Sets blu's respawn time, in seconds, while giant is active. Overriden by respawnOverride in giant_attributes.nut if set. 
::RED_POST_GIANT_RESPAWN_TIME       <- 3            //Sets red's respawn time, in seconds, after giant is dead 
::BLUE_POST_GIANT_RESPAWN_TIME      <- 0.1          //Sets blu's respawn time, in seconds, after giant is dead 
::SMALL_CASH_DROP_AMOUNT            <- 7            //Amount of small cash dropped by the tank when it dies. Size is purely cosmetic
::MEDIUM_CASH_DROP_AMOUNT           <- 4            //Amount of medium cash dropped by the tank when it dies. Size is purely cosmetic
::LARGE_CASH_DROP_AMOUNT            <- 2            //Amount of large cash dropped by the tank when it dies. Size is purely cosmetic
::CASH_CONDS                        <- {            //Conditions to apply to red players when they pick up cash. Value determines duration (-1: infinite)
                                        [TF_COND_OFFENSEBUFF]               = 5,
                                        [TF_COND_CRITBOOSTED_CTF_CAPTURE]   = 5, //If you remove this, be sure to also change the cond in filter_cash_eligible
                                        [TF_COND_HALLOWEEN_QUICK_HEAL]      = 3
                                       }
::PROJECTILE_SHIELD_LENGTH          <- 10           //In seconds, the length red medics get projectile shield for when picking up cash

//Find map entities
::startingPathTrack <- Entities.FindByName(null, "tank_path_1")
::trainWatcherDummy <- Entities.FindByName(null, "fake_train")
::redWin <- Entities.FindByName(null, "Red_Win")
::tankHologram <- Entities.FindByName(null, "tank_hologram")
::filterBoss <- Entities.FindByName(null, "tank_hologram")
::gamerules <- Entities.FindByClassname(null, "tf_gamerules")
::playerManager <- Entities.FindByClassname(null, "tf_player_manager")
::bombFlag <- Entities.FindByClassname(null, "item_teamflag")
::roundTimer <- Entities.FindByClassname(null, "team_round_timer")

::rejectGiantHudHint <- SpawnEntityFromTable("env_hudhint", {
    targetname = "reject_giant_hud_hint",
    message = "%+attack3% reject becoming giant"
})

//Keep track of some things
::tank <- null
::bombSpawnOrigin <- startingPathTrack.GetOrigin()
::chosenGiantThisRound <- RandomInt(0, GIANT_TYPES_AMOUNT - 1)
::isTankMissionHappening <- false       //Tracks whether or not tank is active
::isIntermissionHappening <- false      //28s break between tank dying and giant mode starting. This variable marks that phase
::isBombMissionHappening <- false       //Bomb is OUT and READY TO DEPLOY BY PLAYERS

//Misc.
::MaxPlayers <- MaxClients().tointeger()
::MaxWeapons <- 8

IncludeScript("stopthattank2/intermission.nut")
IncludeScript("stopthattank2/bomb_deploy.nut")
IncludeScript("stopthattank2/bomb.nut")
IncludeScript("stopthattank2/tank_functions_callbacks.nut")
IncludeScript("stopthattank2/crit_cash.nut")
IncludeScript("stopthattank2/giant_mode.nut")
IncludeScript("stopthattank2/giant_attributes.nut")

::debugPrint <- function(msg)
{
    ClientPrint(null,3,msg)
}

//Set team names
Convars.SetValue("mp_tournament_redteamname", "HUMANS")
Convars.SetValue("mp_tournament_blueteamname", "ROBOTS")

//Precache garbage
//Precache announcer sounds
PrecacheSound("vo/announcer_begins_60sec.mp3")
PrecacheSound("vo/announcer_begins_30sec.mp3")
PrecacheSound("vo/announcer_begins_10sec.mp3")
PrecacheSound("vo/announcer_begins_5sec.mp3")
PrecacheSound("vo/announcer_begins_4sec.mp3")
PrecacheSound("vo/announcer_begins_3sec.mp3")
PrecacheSound("vo/announcer_begins_2sec.mp3")
PrecacheSound("vo/announcer_begins_1sec.mp3")

PrecacheSound("vo/announcer_ends_60sec.mp3")
PrecacheSound("vo/announcer_ends_30sec.mp3")
PrecacheSound("vo/announcer_ends_10sec.mp3")
PrecacheSound("vo/announcer_ends_5sec.mp3")
PrecacheSound("vo/announcer_ends_4sec.mp3")
PrecacheSound("vo/announcer_ends_3sec.mp3")
PrecacheSound("vo/announcer_ends_2sec.mp3")
PrecacheSound("vo/announcer_ends_1sec.mp3")

//Function for mapmakers to override base tank health
::overrideBaseTankHealth <- function(health_input)
{
    BASE_TANK_HEALTH = health_input
}

//Timer finishes 3 times, so we have to know which function we need to call
::callTimerFunction <- function()
{
    debugPrint("CALL TIMER FUNCTION IS CALLED")
    if(!isIntermissionHappening && !isBombMissionHappening)
    {
        spawnTank()
        debugPrint("\x05Call timer: \x01Spawning tank")
    }
    else if(isIntermissionHappening && !isBombMissionHappening)
    {
        startGiantMode()
        debugPrint("\x05Call timer: \x01Starting giant mode")
    }
    else if(isBombMissionHappening)
    {
        redWin.AcceptInput("RoundWin", null, null, null)
        debugPrint("\x05Call timer: \x01Winning red")
        // isIntermissionHappening = false
        // isBombMissionHappening = false
    }
}

//Handles countdown sounds (e.g. mission ends in 10 seconds!)
::playCountdownSound <- function(secondsRemaining)
{
    //If bomb mission hasnt started yet, all countdown sounds should be mission begins in x seconds
    local prefix = isBombMissionHappening == false ? "vo/announcer_begins_" : "vo/announcer_ends_"
    gamerules.AcceptInput("PlayVO", prefix + secondsRemaining.tostring() + "sec.mp3", null, null)
}

::playSoundEx <- function(soundname)
{
    EmitSoundEx({
        sound_name = soundname,
        channel = 6,
        origin = (0,0,0),
        filter_type = RECIPIENT_FILTER_GLOBAL
    })
    EmitSoundEx({
        sound_name = soundname,
        channel = 6,
        origin = (0,0,0),
        filter_type = RECIPIENT_FILTER_GLOBAL
    })
}

::roundCallbacks <-
{
    Cleanup = function() {
        //Reset HUD type
        NetProps.SetPropInt(gamerules, "m_nHudType", 3)
        NetProps.SetPropBool(gamerules, "m_bPlayingHybrid_CTF_CP", false)

        //Reset round states
        isIntermissionHappening = false
        isBombMissionHappening = false

        //Reroll chosen giant type
        chosenGiantThisRound = RandomInt(0, GIANT_TYPES_AMOUNT - 1)

        //Prevent callbacks from stacking
		delete ::roundCallbacks
    }

    OnGameEvent_scorestats_accumulated_update = function(_) {
		if (GetRoundState() == 3) {
			Cleanup()
		} 
	}

    OnGameEvent_player_spawn = function(params) {
        local player = GetPlayerFromUserID(params.userid)

        //This is a chore that has to be done so that vscript doesn't break randomly
        if (params.team == 0) player.ValidateScriptScope()

        if (!("isGiant" in player.GetScriptScope())) {
            debugPrint("Spawned player is not giant")
            return
        }
        debugPrint("Spawned player IS giant")
        //Make sure it doesnt fire when giant first spawns
        if (isIntermissionHappening || isBombMissionHappening) return
        //After humiliation player health needs to be reset manually
        debugPrint("Giant privileges removed on spawn")
        player.Regenerate(true)
        player.SetCustomModelWithClassAnimations("")

        //Stop being giant
        delete scope.isGiant
    }

    OnGameEvent_mvm_tank_destroyed_by_players = function(params) {
        debugPrint("Intermission stuff happening now")
        startIntermission() //Find in intermission.nut

        //Delay the crit cash function to ensure that it happens after the cash entities spawn
        EntFire("gamerules", "CallScriptFunction", "spawnCritCash()", -1) //Find in crit_cash.nut

        //Mapmaker decides what else needs to happen using boss_dead_relay
    }

    OnGameEvent_player_death = function(params) {
        local player = GetPlayerFromUserID(params.userid)
        local scope = player.GetScriptScope()
        if (!("isGiant" in player.GetScriptScope())) return
        handleGiantDeath()
    }

    OnGameEvent_player_disconnect = function(params) {
        //For now, this only checks for when a jerk disconnects during intermission
        if(!isIntermissionHappening) return

        local player = GetPlayerFromUserID(params.userid)
        local scope = player.GetScriptScope()

        //If they were top 5, also remove them from the list
        //The player that rejected might not be in top 5 because top 5 all rejected already
        if(params.userid in eligibleGiantPlayers)
        {
            if(params.userid in eligibleGiantPlayers) delete eligibleGiantPlayers[params.userid]
        }

        //Player disconnected when they were prompted to be giant, so toss it to someone else
        if ("isBecomingGiant" in scope) {
            pickRandomPlayerToBeGiant(eligibleGiantPlayers)
            delete scope.isBecomingGiant
        }
        
    }
}

debugPrint("Script is hopefully up and running")
__CollectGameEventCallbacks(roundCallbacks)