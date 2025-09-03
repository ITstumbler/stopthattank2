::ROBOT_PLAYER_MODELS <- {}

//TODO: Replace with proper robot models
::ROBOT_PLAYER_MODELS[TF_CLASS_SCOUT]           <- "models/bots/scout/bot_scout.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_SOLDIER]         <- "models/bots/soldier/bot_soldier.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_PYRO]            <- "models/bots/pyro/bot_pyro.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_DEMOMAN]         <- "models/bots/demo/bot_demo.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_HEAVYWEAPONS]    <- "models/bots/heavy/bot_heavy.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_ENGINEER]        <- "models/bots/engineer/bot_engineer.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_MEDIC]           <- "models/bots/medic/bot_medic.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_SNIPER]          <- "models/bots/sniper/bot_sniper.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_SPY]             <- "models/bots/spy/bot_spy.mdl"

::blueRobotCallbacks <-
{
    Cleanup = function() {
        //Prevent callbacks from stacking
		delete ::blueRobotCallbacks
    }

    function OnGameEvent_scorestats_accumulated_update(_) {
		if (GetRoundState() == 3) {
			Cleanup()
		}
	}

    function OnGameEvent_player_spawn(params) {
        local player = GetPlayerFromUserID(params.userid)

        if(player.GetTeam() == TF_TEAM_RED) {
            player.SetCustomModelWithClassAnimations(null)
            //Reset blood - players bleed when shot
            NetProps.SetPropInt(player, "m_bloodColor", 0)
        }
        else if(player.GetTeam() == TF_TEAM_BLUE) {
            player.SetCustomModelWithClassAnimations(ROBOT_PLAYER_MODELS[player.GetPlayerClass()])

            //Sets footsteps to Sentry Buster's footsteps - which is then overridden by the level_sounds
            EntFireByHandle(player, "RunScriptCode", "applyAttributeOnSpawn(`override footstep sound set`, 7, -1)", -1, player, player)
            //Robots don't bleed
            NetProps.SetPropInt(player, "m_bloodColor", -1)
        }
    }
}
__CollectGameEventCallbacks(blueRobotCallbacks)