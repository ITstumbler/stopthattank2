::ROBOT_PLAYER_MODELS <- {}

//TODO: Replace with proper robot models (dont forget model_indexes as well)
::ROBOT_PLAYER_MODELS[TF_CLASS_SCOUT]           <- "models/bots/human_rigged_bot_models/bot_scout.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_SOLDIER]         <- "models/bots/human_rigged_bot_models/bot_soldier.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_PYRO]            <- "models/bots/human_rigged_bot_models/bot_pyro.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_DEMOMAN]         <- "models/bots/human_rigged_bot_models/bot_demo.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_HEAVYWEAPONS]    <- "models/bots/human_rigged_bot_models/bot_heavy.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_ENGINEER]        <- "models/bots/engineer/bot_engineer.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_MEDIC]           <- "models/bots/human_rigged_bot_models/bot_medic.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_SNIPER]          <- "models/bots/human_rigged_bot_models/bot_sniper.mdl"
::ROBOT_PLAYER_MODELS[TF_CLASS_SPY]             <- "models/bots/human_rigged_bot_models/bot_spy.mdl"

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
        if(player == null) return

        if(player.GetTeam() == TF_TEAM_RED) {
            player.SetCustomModelWithClassAnimations(null)

            //Reset blood - players bleed when shot
            NetProps.SetPropInt(player, "m_bloodColor", 0)

            //Enables romevision for robot disguises (see spy_disguises.nut)
            EntFireByHandle(player, "RunScriptCode", "applyAttributeOnSpawn(`vision opt in flags`, 4, -1)", -1, player, player)
            EntFireByHandle(player, "RunScriptCode", "applyAttributeOnSpawn(`always_transmit_so`, 1, -1)", -1, player, player)

            //Reset "disguise" model
            NetProps.SetPropIntArray(player, "m_nModelIndexOverrides", HUMAN_PLAYER_MODEL_INDEXES[player.GetPlayerClass()], 4);
        }
        else if(player.GetTeam() == TF_TEAM_BLUE) {
            local scope = player.GetScriptScope()
            if(!scope.isGiant) {
                player.SetCustomModelWithClassAnimations(ROBOT_PLAYER_MODELS[player.GetPlayerClass()])
                //Reset "disguise" model
                NetProps.SetPropIntArray(player, "m_nModelIndexOverrides", ROBOT_PLAYER_MODEL_INDEXES[player.GetPlayerClass()], 4);
            }

            //Sets footsteps to Sentry Buster's footsteps - which is then overridden by the level_sounds
            EntFireByHandle(player, "RunScriptCode", "applyAttributeOnSpawn(`override footstep sound set`, 7, -1)", -1, player, player)
            //Robots don't bleed
            NetProps.SetPropInt(player, "m_bloodColor", -1)

            //Disable romevision
            EntFireByHandle(player, "RunScriptCode", "applyAttributeOnSpawn(`vision opt in flags`, 0, -1)", -1, player, player)

            
        }
    }
}
__CollectGameEventCallbacks(blueRobotCallbacks)