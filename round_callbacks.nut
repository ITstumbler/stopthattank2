::roundCallbacks <-
{
    function Cleanup() {
        //Reset HUD type
        NetProps.SetPropInt(gamerules, "m_nHudType", 3)
        NetProps.SetPropBool(gamerules, "m_bPlayingHybrid_CTF_CP", false)

        //Reset round state
		setSTTRoundState(STATE_SETUP)

        //Reroll chosen giant type
        chosenGiantThisRound = RandomInt(0, GIANT_TYPES_AMOUNT - 1)
        if(DEBUG_FORCE_GIANT_TYPE != null) chosenGiantThisRound = DEBUG_FORCE_GIANT_TYPE
        updateGameTexts()

        //Cleanup timer countdown think so it doesn't stack
        AddThinkToEnt(roundTimer, null)

        //Reset overtime availability
        SetOvertimeAllowedForCTF(false)
        
        //Flush out reanim list
        reanimTable.clear()
        addReanimatorThink()
		
		//Stop keeping track of who the giant is because they dont exist anymore
		giantPlayer = null

        //Reset all variables
        for (local i = 1; i <= MaxPlayers ; i++)
        {
            local player = PlayerInstanceFromIndex(i)
            if (player == null) continue
            local scope = player.GetScriptScope()
            scope.isBecomingGiant = false
            scope.hasHiddenGiantHud = false
            scope.isCarryingBombInAlarmZone = false
            scope.lastResponseTime = 0
            scope.reanimCount = 0
        }
		
		//Prevent callbacks from stacking
		delete ::roundCallbacks
    }

    function OnGameEvent_scorestats_accumulated_update(_) {
		if (GetRoundState() == 3) {
			Cleanup()
		}
	}

    function OnGameEvent_player_hurt(params) {
		local player = GetPlayerFromUserID(params.userid)
		local attacker = GetPlayerFromUserID(params.attacker)

        local weapon = null

        if("weaponid" in params) {
            weapon = params.weaponid
        }
        // debugPrint("Weapon id: " + weapon)

        if(player == giantPlayer && weapon == 7 && params.damageamount == 750) {
            // Thanks oz
            debugPrint("Spy backstab!!")

            for (local i = 0; i < MaxWeapons; i++)
            {
                local weaponIterate = NetProps.GetPropEntityArray(attacker, "m_hMyWeapons", i)
                if (weaponIterate == null) continue
                if (weaponIterate.GetClassname() != "tf_weapon_knife") continue
                
                weapon = weaponIterate
                break
            }

            NetProps.SetPropFloat(weapon, "m_flNextPrimaryAttack", Time() + 2.0);
            NetProps.SetPropFloat(attacker, "m_flNextAttack", Time() + 2.0);
            NetProps.SetPropFloat(attacker, "m_flStealthNextTraitTime", Time() + 2.0);
            EmitSoundOn("Player.Spy_Shield_Break", player);
            EmitSoundOn("Player.Spy_Shield_Break", player);

            EntFireByHandle(player, "RunScriptCode", "EmitSoundOn(`Spy.LaughEvil01`, player)", 0.2, player, player)
            EntFireByHandle(player, "RunScriptCode", "EmitSoundOn(`Spy.LaughEvil01`, player)", 0.2, player, player)

            ClientPrint(player, 4, "YOU'VE BEEN BACKSTABBED!!")
        }
        
        //Flash giants when shot during invuln phase
        if (player.GetCustomAttribute("dmg taken increased", 1) == 0.001) {
            player.AddCondEx(TF_COND_INVULNERABLE, 0.5, null)
        }
	}

    function OnGameEvent_player_spawn(params) {
        local player = GetPlayerFromUserID(params.userid)
        local scope = player.GetScriptScope()

		//initial setup
        if (params.team == 0) {
			//This is a chore that has to be done to ensure the scope exists
			player.ValidateScriptScope()

			scope = player.GetScriptScope()
			scope.isGiant <- false
			scope.isBecomingGiant <- false
            scope.isCarryingBombInAlarmZone <- false
            scope.thinkFunctions <- {}
            scope.reanimCount <- 0 //The amount of times a player has been revived; each reanimation increases the hp cost by 10
            scope.isReviving <- false
            scope.projShield <- null
            scope.hasHiddenGiantHud <- false
            scope.lastResponseTime <- 0 //Used for red spies disguised as blue spies - see robot_voicelines.nut
            scope.isDeploying <- false

            AddThinkToEnt(player, "playerThink")
		}

        //Reset status
        scope.isCarryingBombInAlarmZone = false

        //Reset thinks
        scope.thinkFunctions.clear()

        //Blu medics with stock medi gun: add a think to make bomb carriers compatible with uber
        //Find this function in bomb_ubers.nut
        if(params.team == TF_TEAM_BLUE && player.GetPlayerClass() == TF_CLASS_MEDIC && !scope.isGiant) addBombUberThink(player)
        
        //Spies from both teams need a think to add/remove robo footsteps on disguise
        //Find this function in spy_disguises.nut
        if(player.GetPlayerClass() == TF_CLASS_SPY) {
            addSpyDisguiseThink(player, params.team)
            EntFireByHandle(player, "RunScriptCode", "applyAttributeOnSpawn(`armor piercing`, 75, -1)", -1, player, player)
        }

        //Red players should say something a few seconds after spawning
        if(params.team == TF_TEAM_RED) EntFireByHandle(player, "RunScriptCode", "handleSpawnResponse(activator)", 4, player, player)

        //Lets players about to become giant reject if they die during intermission
        if(getSTTRoundState() == STATE_INTERMISSION && scope.isBecomingGiant && !(player.entindex() in playersThatHaveRejectedGiant))
			promptGiant(player.entindex())

        //Giant engineer: if a teleporter exit is active, teleport all newly spawned blu players
        if(giantEngineerTeleExitOrigin != null && params.team == TF_TEAM_BLUE)
        {
            local playerTeleportOrigin = giantEngineerTeleExitOrigin
            playerTeleportOrigin.z = giantEngineerTeleExitOrigin.z + 18

            player.Teleport(true, playerTeleportOrigin, true, giantEngineerTeleExitAngle, false, Vector())
            player.AddCondEx(TF_COND_INVULNERABLE_CARD_EFFECT, 1, giantPlayer)
            EmitSoundEx({
                sound_name = "mvm/mvm_tele_deliver.wav",
                origin = playerTeleportOrigin
            })
        }

        //If spawned player had a reanimator on the field, kill it
        if(params.userid in reanimTable) {
            reanimTable[params.userid].Kill()
            delete reanimTable[params.userid]
        }

        local spawnedPlayerName = Convars.GetClientConvarValue("name", player.GetEntityIndex())

        //Set of checks for when a blu jerk swaps to red team when prompted to be giant
        if(getSTTRoundState() == STATE_INTERMISSION && params.team == TF_TEAM_RED) {
            debugPrint("\x0788BB88Someone spawned on red during intermission")

            removeInvalidatedPlayer(player)
			return
        }

        if (!scope.isGiant) {
            debugPrint("\x01Spawned player \x0799CCFF" + spawnedPlayerName + " \x01is not giant")
            //If giant player is active, any blu player spawning in will be banned from picking up the bomb
            if(getSTTRoundState() == STATE_BOMB && !isBombGiantDead && params.team == TF_TEAM_BLUE) {
                EntFireByHandle(player, "RunScriptCode", "applyAttributeOnSpawn(`cannot pick up intelligence`, 1, -1)", 0.1, player, player)
                debugPrint("Newly spawned blu player has been banned from picking up the bomb")
            }
            return
        }

        debugPrint("\x01Spawned player \x0799CCFF" + spawnedPlayerName + " \x01is \x05GIANT")
        //Make sure it doesnt fire when giant first spawns
        if (getSTTRoundState() == STATE_INTERMISSION || getSTTRoundState() == STATE_BOMB) {
            debugPrint("\x04First giant spawn. Do not wipe giant privileges")
            return
        }
        //After humiliation player model needs to be reset manually
        debugPrint("\x01Giant privileges removed on spawn for player \x0799CCFF" + spawnedPlayerName)
        
        //Stop being giant
        scope.isGiant = false
    }

    function OnGameEvent_mvm_tank_destroyed_by_players(params) {
        debugPrint("Intermission stuff happening now")
        startIntermission() //Find in intermission.nut

        //Delay the crit cash function to ensure that it happens after the cash entities spawn
        EntFire("gamerules", "CallScriptFunction", "spawnCritCash", -1) //Find in crit_cash.
        
        handleTankDestructionAnimation() //Find in tank_functions_callbacks.nut

        //Mapmaker decides what else needs to happen using boss_dead_relay

        //Red mercs celebrate with voicelines
        globalSpeakResponseConcept("ConceptMvMTankDead:1", "TLK_MVM_TANK_DEAD")
    }

    function OnGameEvent_object_destroyed(params) {
        if(giantPlayer.GetPlayerClass() != TF_CLASS_ENGINEER) return

        local owner = GetPlayerFromUserID(params.userid)

        //Only execute for giant engis
        if(owner != giantPlayer) return

        //Don't interfere with the function that destroys all giant engineer buildings on death
        if(isBombGiantDead) return

        //Check if destroyed object was a teleporter entrance
        if(params.objecttype != 1) return

        local tele = EntIndexToHScript(params.index)

        //Check if entrance or exit was destroyed
        if(tele.GetName() == "indestructible_tele_entrance") return
            
        stopTeleExit()
    }

    function OnGameEvent_object_detonated(params) {
        if(giantPlayer != null && giantPlayer.GetPlayerClass() != TF_CLASS_ENGINEER) return

        local detonator = GetPlayerFromUserID(params.userid)

        //Only execute for giant engis
        if(detonator != giantPlayer) return

        //Don't interfere with the function that destroys all giant engineer buildings on death
        if(isBombGiantDead) return

        //Check if detonated object was a teleporter
        if(params.objecttype != 1) return

        local tele = EntIndexToHScript(params.index)

        //Check if entrance or exit was destroyed
        if(tele.GetName() != "indestructible_tele_entrance")
        {
            stopTeleExit()
        }
        else
        {
            //UNDO YOU MAY NOT BUILD TELE ENTRANCES
            createIndestructibleTeleEntrance(detonator)
            ClientPrint(detonator, 4, "You may not build teleporter entrances as Giant Engineer; just build an exit")
        }
        
    }

    function OnGameEvent_player_death(params) {
        local player = GetPlayerFromUserID(params.userid)
        local killer = GetPlayerFromUserID(params.attacker)
        local scope = player.GetScriptScope()

        //If a red player dies, create reanimators for them
        //CURRENTLY DISABLED because a lot of reanimator aspects are beyond the reach of vscript
        if(player.GetTeam() == TF_TEAM_RED && RED_REANIMATORS) {
            spawnReanim(player, params.userid) //Find in reanimators.nut
        }

        //If a giant killed a red player, have red heavies scream METAL GIANT IS KILLING US
        if(killer != null && killer == giantPlayer) {
            if(player.GetTeam() == TF_TEAM_RED) {
                globalSpeakResponseConcept("ConceptMvMGiantKilledTeammate:1", "TLK_MVM_GIANT_KILLED_TEAMMATE")
            }
        }

        //Below handles giant death events
        if (!scope.isGiant) return
        handleGiantDeath() //Global events
        if(killer != player && killer != null && killer.IsPlayer() && killer.IsAlive()) { //Only say something for non suicide player kills
            speakGiantKillResponse(killer) //Have the killer say something cool, find in giant_kill_responses.nut
        }
        playSoundEx("mvm/sentrybuster/mvm_sentrybuster_explode.wav")

        //TODO: Print "Blue giant defeated!"

        local deadPlayerName = Convars.GetClientConvarValue("name", player.GetEntityIndex())
        debugPrint("\x01Giant privileges removed on death for player \x0799CCFF" + deadPlayerName)

        player.SetIsMiniBoss(false)

        //Stop being giant
        scope.isGiant = false
    }

    //Whenever a revive starts: force players to remain dead and unable to respawn
    function OnGameEvent_revive_player_notify(params) {
        local player = EntIndexToHScript(params.entindex)
        local scope = player.GetScriptScope()
        scope.isReviving = true
    }

    //Whenever a revive stops: they may revive is ok
    function OnGameEvent_revive_player_stopped(params) {
        local player = EntIndexToHScript(params.entindex)
        local scope = player.GetScriptScope()
        scope.isReviving = false
    }

    // OnGameEvent_revive_player_complete = function(params) {
    //     debugPrint("\x074444FFRevive player complete event!")
    // }

    function OnGameEvent_player_disconnect(params) {
		local player = GetPlayerFromUserID(params.userid)
		local scope = player.GetScriptScope()

        //Disconnected while you have a reanim up? Forget about it
        if(params.userid in reanimTable) {
            delete reanimTable[userid]
        }

        //Set of checks for when a jerk disconnects during intermission
        if(getSTTRoundState() == STATE_INTERMISSION) {
            debugPrint("\x0788BB88Some jerk disconnected during intermission")

            removeInvalidatedPlayer(player)
            return
        }
        else if(getSTTRoundState() == STATE_BOMB) {
			//Failsafe for when a jerk disconnects while giant
            if (scope.isGiant) {
                debugPrint("\x0788BB88Some jerk disconnected while carrying the bomb as a giant. Failsafe triggered.")
                handleGiantDeath()
            }
        }

    }
}

__CollectGameEventCallbacks(roundCallbacks)