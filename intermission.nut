::eligibleGiantPlayers <- {}
::playerScoreTable <- {}
::playersThatHaveRejectedGiant <- {}

function root::setBombSpawnOrigin(ent_name)
{
    local entToFind = Entities.FindByName(null, ent_name)
    bombSpawnOrigin = entToFind.GetOrigin()
}

function root::startIntermission()
{
    //Anything else the mapmaker wants to happen when tank dies is handled by this guy
    EntFire("boss_dead_relay", "trigger")

    //Wake up round timer, count down the intermission time now
    roundTimer.AcceptInput("Enable", null, null, null)
    roundTimer.AcceptInput("SetTime", INTERMISSION_LENGTH.tostring(), null, null)
    roundTimer.GetScriptScope().currentRoundTime <- INTERMISSION_LENGTH
    AddThinkToEnt(roundTimer, "countdownThink")

    //Impending teleportation! Show a particle that indicates where a giant will teleport to
    EntityOutputs.AddOutput(roundTimer, "On3SecRemain", "gamerules", "CallScriptFunction", "displayGiantTeleportParticle", -1, 1) //Find in giant_mode.nut

    //Roll back hud train to nearest cp
    EntFire("gamerules", "CallScriptFunction", "rollbackTrainWatcherDummy", 0.1)

    //Push players away from giant spawn point shortly before the giant comes in
    EntFire("gamerules", "CallScriptFunction", "pushPlayersNearGiantSpawnPoint", INTERMISSION_LENGTH - 0.4)
    
    //Update team respawn times
    gamerules.AcceptInput("SetRedTeamRespawnWaveTime", RED_INTERMISSION_RESPAWN_TIME.tostring(), null, null)
    gamerules.AcceptInput("SetBlueTeamRespawnWaveTime", BLUE_INTERMISSION_RESPAWN_TIME.tostring(), null, null)
    
    //Tell path tracks to stop the hud train,
    //and timer to execute the proper function OnFinished 
    setSTTRoundState(STATE_INTERMISSION)

    //Decide on which player gets giant privileges
    eligibleGiantPlayers.clear()
    playerScoreTable.clear()
    playersThatHaveRejectedGiant.clear()
    debugPrint("\x01There are \x04" + playersThatHaveRejectedGiant.len() + " \x01players that have rejected")
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_BLUE) continue
        local playerScore = NetProps.GetPropIntArray(playerManager, "m_iTotalScore", i)
        playerScoreTable[i] <- playerScore
    }

    //No blue players? Abandon everything return
    if(playerScoreTable.len() == 0)
    {
        debugPrint("\x07CC7777There are no blue players! Here have the bomb")
        isBombGiantDead = true
        //Enable the bomb and teleport it to the most recent CP
        bombFlag.AcceptInput("Enable", null, null, null)
        bombFlag.SetAbsOrigin(bombSpawnOrigin)
        return
    }

    debugPrint("\x01There are \x05" + playerScoreTable.len() + " \x01scoring players")

    local playerScoreArrayTop = playerScoreTable.values()
    playerScoreArrayTop = playerScoreArrayTop.sort()
    playerScoreArrayTop = playerScoreArrayTop.reverse()
    playerScoreArrayTop = playerScoreArrayTop.slice(0,playerScoreArrayTop.len() < TOP_PLAYERS_ELIGIBLE_FOR_GIANT ?
                            playerScoreArrayTop.len() : TOP_PLAYERS_ELIGIBLE_FOR_GIANT)

    debugPrint("\x01There are \x05" + playerScoreArrayTop.len() + " \x01top scoring players")

    foreach (playerIndex, score in playerScoreTable)
    {
        local eligiblePlayerName = Convars.GetClientConvarValue("name", playerIndex)

        debugPrint("\x01Iterating through \x0799CCFF" + eligiblePlayerName)

        if(playerScoreArrayTop.find(score) != null)
        {
            debugPrint("\x01We found an eligible player: \x0799CCFF" + eligiblePlayerName)
            eligibleGiantPlayers[playerIndex] <- null
        }
    }

    //2s delay, then go do start prompting giant stuff
    EntFire("gamerules", "CallScriptFunction", "startGiantPickingProcess", 2)
}

function root::startGiantPickingProcess()
{
    local giantPlayerIndex = pickRandomPlayerToBeGiant(eligibleGiantPlayers)

    if(giantPlayerIndex == -1) {
        debugPrint("\x07444444We're out of eligible giant players!")
        return
    }

    local giantPlayer = PlayerInstanceFromIndex(giantPlayerIndex)

    local giantPlayerName = Convars.GetClientConvarValue("name", giantPlayer.GetEntityIndex())

    for (local i = 1; i <= MaxPlayers ; i++)
    {
        if (i == giantPlayerIndex) continue //We don't need to tell the giant themself

        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
		if (player.GetTeam() == TF_TEAM_RED) {
			//Yell at everyone on red about incoming giant robot. They don't get details
			ClientPrint(player, 3, "============================")
			ClientPrint(player, 3, "\x01WARNING: \x07FF3F3FGIANT ROBOT INCOMING")
			ClientPrint(player, 3, "============================")
		}
		else if(player.GetTeam() == TF_TEAM_BLUE) {
			//Tell everyone else on blu about who's becoming what giant
			player.SetScriptOverlayMaterial("hud/stopthattank2/g_r_" + giantProperties[chosenGiantThisRound].hudHintName)
			EntFireByHandle(player, "RunScriptCode", "AddGiantHideHudThink(activator)", 3, player, player)
		}
    }
}

function root::pickRandomPlayerToBeGiant(eligibleTable)
{
    local randomGiantPlayerIndex = -1
    if(eligibleTable.len() > 0)
    {
        randomGiantPlayerIndex = eligibleTable.keys()[RandomInt(0, eligibleTable.len() - 1)]
        debugPrint("\x01Prompting player \x0799CCFF" + Convars.GetClientConvarValue("name", randomGiantPlayerIndex) + " \x01to be giant")
        promptGiant(randomGiantPlayerIndex)
    }
    else
    {
        local successfullyPickedAPlayer = false
        debugPrint("All of the top performers rejected, sequentially choosing next player")
        //ALL top performers reject? Just pick sequentially because it's a rare edge case
        for (local i = 1; i <= MaxPlayers ; i++)
        {
            local player = PlayerInstanceFromIndex(i)
            if (player == null) continue
            if (player.GetTeam() != TF_TEAM_BLUE) continue
            //Player has rejected before, dont ask them again
            if (i in playersThatHaveRejectedGiant) {
                debugPrint("\x01Player \x0799CCFF" + Convars.GetClientConvarValue("name", i) + " \x01has already rejected before, not asking again")
                continue
            }
            promptGiant(i)
            successfullyPickedAPlayer = true
            break
        }
        //EVERYONE rejects? Screw you, random pleb, you're a giant now.
        if(successfullyPickedAPlayer) return
        debugPrint("EVERYONE rejected. Next pleb is becoming a giant willy nilly")
        for (local i = 1; i <= MaxPlayers ; i++)
        {
            local player = PlayerInstanceFromIndex(i)
            if (player == null) continue
            if (player.GetTeam() != TF_TEAM_BLUE) continue
            local scope = player.GetScriptScope()
            scope.isBecomingGiant = true
            ClientPrint(player, 3, "\x05Everyone on your team rejected. You have been chosen to become the next giant.")
            player.SetScriptOverlayMaterial("hud/stopthattank2/g_b_" + giantProperties[chosenGiantThisRound].hudHintName)

            break
        }
    }

    return randomGiantPlayerIndex
}

//Separated so that the rollback is delayed sufficiently enough so that crit cash func can do its job properly
function root::rollbackTrainWatcherDummy()
{
    trainWatcherDummy.KeyValueFromInt("startspeed", INTERMISSION_ROLLBACK_SPEED)
    trainWatcherDummy.AcceptInput("SetSpeedDir", "-1", null, null)
}

function root::stopTrainWatcherDummy()
{
    if(getSTTRoundState() == STATE_INTERMISSION) {
        debugPrint("Attempting to stop train dummy")
        setSpeedTank(0, true)
    }
}

function root::promptGiant(playerIndex)
{
    local player = PlayerInstanceFromIndex(playerIndex)

    local playerName = Convars.GetClientConvarValue("name", player.GetEntityIndex())

    // debugPrint("\x01Prompting \x0799CCFF" + playerName + " \x01to be giant")
    
    // ClientPrint(player, 3, "\x0799CCFF============================")
    // ClientPrint(player, 3, "\x01You are about to become a \x0799CCFFGIANT\x01!")
    // ClientPrint(player, 3, "\x01You will become a: \x0799CCFF" + giantProperties[chosenGiantThisRound].giantName)
    // ClientPrint(player, 3, "\x04" + giantProperties[chosenGiantThisRound].playerInfo)
    // ClientPrint(player, 3, "\x0799CCFF============================")
    player.SetScriptOverlayMaterial("hud/stopthattank2/g_b_" + giantProperties[chosenGiantThisRound].hudHintName)
    EntFireByHandle(rejectGiantHudHint, "ShowHudHint", null, 0, player, player)
    EntFireByHandle(player, "RunScriptCode", "AddGiantHideHudThink(activator, 7)", 3, player, player)

    local scope = player.GetScriptScope()
    scope.isBecomingGiant = true
    
    scope.promptGiantThink <- function() {
        //Cleanup on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            delete thinkFunctions.promptGiantThink
        }
        local buttons = NetProps.GetPropInt(self, "m_nButtons")

        //ATTACK3 will be used to reject giant prompt as it is not used in pvp
        if(buttons & IN_ATTACK3)
        {
            EntFireByHandle(rejectGiantHudHint, "HideHudHint", null, 0, self, self)

            //Theyre no longer willing, so they get the receiving hud instead
            if(!hasHiddenGiantHud) {
                player.SetScriptOverlayMaterial("hud/stopthattank2/g_r_" + giantProperties[chosenGiantThisRound].hudHintName)
            }
            
            debugPrint("\x04Current candidate has rejected to become a giant!")
            //Player didn't want to be giant; remember that so that we don't pick them again
            playersThatHaveRejectedGiant[playerIndex] <- null
            if(playerIndex in eligibleGiantPlayers) delete eligibleGiantPlayers[playerIndex]
            
            isBecomingGiant = false

            //Pick another pleb to be giant
            pickRandomPlayerToBeGiant(eligibleGiantPlayers)
            
            //Think cleanup
            delete thinkFunctions.promptGiantThink
        }
    }
    scope.thinkFunctions.promptGiantThink <- scope.promptGiantThink
}

//Lets players hide giant info hud by pressing reload
//Only after at least 3s of the info hud being visible on screen
function root::AddGiantHideHudThink(player, delay=0)
{
    local scope = player.GetScriptScope()
    if(scope.hasHiddenGiantHud) return //Player has already hidden the giant info HUD, don't bother

    EntFireByHandle(hideGiantHudHint, "ShowHudHint", null, delay, player, player)

    scope.giantHideHudThink <- function() {
        local buttons = NetProps.GetPropInt(self, "m_nButtons")

        //RELOAD will be used to hide giant info HUD as it is not often used
        //Heatmaker, vaccinator, and people with auto reload disabled will have to cope
        //That's why it's 3s minimum
        if(buttons & IN_RELOAD)
        {
            EntFireByHandle(hideGiantHudHint, "HideHudHint", null, 0, self, self)
            hasHiddenGiantHud = true
            player.SetScriptOverlayMaterial(null)

            //Think cleanup
            delete thinkFunctions.giantHideHudThink
        }
    }
    scope.thinkFunctions.giantHideHudThink <- scope.giantHideHudThink
}