::eligibleGiantPlayers <- {}
::playerScoreTable <- {}
::playersThatHaveRejectedGiant <- {}

::setBombSpawnOrigin <- function(ent_name)
{
    local entToFind = Entities.FindByName(null, ent_name)
    bombSpawnOrigin = entToFind.GetOrigin()
}

::startIntermission <- function()
{
    EntFire("boss_dead_relay", "trigger")

    //Roll back hud train to nearest cp
    trainWatcherDummy.KeyValueFromInt("startspeed", INTERMISSION_ROLLBACK_SPEED)
    trainWatcherDummy.AcceptInput("SetSpeedDir", "-1", null, null)
    

    //Tell path tracks to stop the hud train
    isIntermissionHappening = true

    //Decide on which player gets giant privileges
    eligibleGiantPlayers.clear()
    playerScoreTable.clear()
    playersThatHaveRejectedGiant.clear()
    debugPrint("There are " + playersThatHaveRejectedGiant.len() + " players that have rejected")
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != 3) continue
        local playerScore = NetProps.GetPropIntArray(playerManager, "m_iTotalScore", i)
        playerScoreTable[i] <- playerScore
    }

    //No blue players? Abandon everything return
    if(playerScoreTable.len() == 0)
    {
        debugPrint("There are no blue players!")
        //Enable the bomb and teleport it to the most recent CP
        bombFlag.AcceptInput("Enable", null, null, null)
        bombFlag.SetOrigin(bombSpawnOrigin)
        return
    }

    debugPrint("There are " + playerScoreTable.len() + " scoring players")

    local playerScoreArrayTop = playerScoreTable.values()
    playerScoreArrayTop = playerScoreArrayTop.sort()
    playerScoreArrayTop = playerScoreArrayTop.reverse()
    playerScoreArrayTop = playerScoreArrayTop.slice(0,playerScoreArrayTop.len() < TOP_PLAYERS_ELIGIBLE_FOR_GIANT ?
                            playerScoreArrayTop.len() : TOP_PLAYERS_ELIGIBLE_FOR_GIANT)

    debugPrint("There are " + playerScoreArrayTop.len() + " top scoring players")

    foreach (playerIndex, score in playerScoreTable)
    {
        if(playerScoreArrayTop.find(score) != null)
        {
            debugPrint("We found an eligible player!!")
            eligibleGiantPlayers[playerIndex] <- null
        }
    }

    pickRandomPlayerToBeGiant(eligibleGiantPlayers)

    //28s intermission, then go do giant stuff
    EntFire("gamerules", "CallScriptFunction", "startGiantMode", INTERMISSION_LENGTH)
}

::pickRandomPlayerToBeGiant <- function(eligibleTable)
{
    if(eligibleTable.len() > 0)
    {
        local randomGiantPlayerIndex = eligibleTable.keys()[RandomInt(0, eligibleTable.len() - 1)]
        debugPrint("Prompting player index " + randomGiantPlayerIndex + " to be giant")
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
            if (player.GetTeam() != 3) continue
            //Player has rejected before, dont ask them again
            if (i in playersThatHaveRejectedGiant) continue
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
            if (player.GetTeam() != 3) continue
            //Find me in giant_mode.nut
            becomeGiant(i)
            break
        }
    }
}

::stopTrainWatcherDummy <- function()
{
    if(isIntermissionHappening) {
        debugPrint("Attempting to stop train dummy")
        setSpeedTank(0, true)
    }
}

::promptGiant <- function(playerIndex)
{
    local player = PlayerInstanceFromIndex(playerIndex)
    
    //Temporary until HUD stuff has been worked on
    ClientPrint(player, 3, "\x01You are about to become a \x0799CCFFGIANT\x01!")
    ClientPrint(player, 3, "\x01You will become a: \x0799CCFF" + giantProperties[chosenGiantThisRound].giantName)
    ClientPrint(player, 3, "\x04" + giantProperties[chosenGiantThisRound].playerInfo)
    EntFireByHandle(rejectGiantHudHint, "ShowHudHint", null, 0, player, player)

    player.ValidateScriptScope()
    local scope = player.GetScriptScope()
    scope.isBecomingGiant <- null
    
    scope.promptGiantThink <- function() {
        //Cleanup on death
        if(NetProps.GetPropInt(player, "m_lifeState") != 0) {
            AddThinkToEnt(player, null)
            NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")
        }
        local buttons = NetProps.GetPropInt(self, "m_nButtons")

        //ATTACK3 will be used to reject giant prompt as it is not used in pvp
        if(buttons & IN_ATTACK3)
        {
            EntFireByHandle(rejectGiantHudHint, "HideHudHint", null, 0, player, player)
            debugPrint("\x04Current candidate has rejected to become a giant!")
            //Player didn't want to be giant; remember that so that we don't pick them again
            playersThatHaveRejectedGiant[playerIndex] <- null
            delete eligibleGiantPlayers[playerIndex]
            delete scope.isBecomingGiant

            //Pick another pleb to be giant
            pickRandomPlayerToBeGiant(eligibleGiantPlayers)
            
            //Think cleanup
            AddThinkToEnt(player, null)
            NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")
        }
        return -1
    }
}

