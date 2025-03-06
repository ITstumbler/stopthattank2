//Balance-sensitive parameters
::TANK_SPEED <- 75
::INTERMISSION_LENGTH <- 5
::TOP_PLAYERS_ELIGIBLE_FOR_GIANT <- 5
::GIANT_TYPES_AMOUNT <- 2
::GIANT_SCALE <- 1.75
::INTERMISSION_ROLLBACK_SPEED <- 400 //HUD tank rolls back during intermission - this determines its speed

//Allows us to reference constants by name so no need to remember the cringe out-of-order class ID e.g. TF_CLASS_SNIPER = 2
::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
    foreach (a,b in Constants)
        foreach (k,v in b)
            ROOT[k] <- v != null ? v : 0;
}

//Find map entities
::startingPathTrack <- Entities.FindByName(null, "tank_path_1")
::trainWatcherDummy <- Entities.FindByName(null, "fake_train")
::gamerules <- Entities.FindByClassname(null, "tf_gamerules")
::playerManager <- Entities.FindByClassname(null, "tf_player_manager")
::bombFlag <- Entities.FindByClassname(null, "item_teamflag")

::rejectGiantHudHint <- SpawnEntityFromTable("env_hudhint", {
    targetname = "reject_giant_hud_hint",
    message = "%+attack3% reject becoming giant"
})

//Keep track of some things
::tank <- null
::bombSpawnOrigin <- startingPathTrack.GetOrigin()
::isIntermissionHappening <- false
::chosenGiantThisRound <- RandomInt(0, GIANT_TYPES_AMOUNT - 1)

//Misc.
::MaxPlayers <- MaxClients().tointeger()
::MaxWeapons <- 8

IncludeScript("stopthattank2/intermission.nut")
IncludeScript("stopthattank2/bomb_deploy.nut")
IncludeScript("stopthattank2/tank_functions_callbacks.nut")
IncludeScript("stopthattank2/giant_mode.nut")
IncludeScript("stopthattank2/giant_attributes.nut")



::debugPrint <- function(msg)
{
    ClientPrint(null,3,msg)
}

::roundCallbacks <-
{
    Cleanup = function() {
        //Reset HUD type
        NetProps.SetPropInt(gamerules, "m_nHudType", 3)
        NetProps.SetPropBool(gamerules, "m_bPlayingHybrid_CTF_CP", false)

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

    OnGameEvent_mvm_tank_destroyed_by_players = function(params) {
        debugPrint("Intermission stuff happening now")
        startIntermission()
        //Mapmaker decides what else needs to happen using boss_dead_relay
    }

    OnGameEvent_player_death = function(params) {
        debugPrint("Someone died (debug)")
    }

    OnGameEvent_player_disconnect = function(params) {
        //For now, this only checks for when a jerk disconnects during intermission
        if(!isIntermissionHappening) return

        local player = PlayerInstanceFromIndex(params.userid)
        player.ValidateScriptScope()
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