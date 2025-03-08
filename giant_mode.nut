::startGiantMode <- function()
{
    //2:30 to deliver the bomb or else
    //Might want to move this soon
    roundTimer.AcceptInput("SetTime", BOMB_MISSION_LENGTH.tostring(), null, null)

    //Next time the timer runs out, red wins!
    isIntermissionHappening = false
    isBombMissionHappening = true
    
    //Adjust HUD to be CTF CP mode
    NetProps.SetPropInt(gamerules, "m_nHudType", 2)
    NetProps.SetPropBool(gamerules, "m_bPlayingHybrid_CTF_CP", true)

    //Set bomb origin to latest capped CP (start if no capped CP)
    //EDGE CASE WARNING: bomb might get picked up by another pleb and not the giant, careful
    bombFlag.AcceptInput("Enable", null, null, null)
    bombFlag.SetAbsOrigin(bombSpawnOrigin)

    //Check which pleb has isBecomingGiant
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != 3) continue
        if (!("isBecomingGiant" in player.GetScriptScope())) continue
        debugPrint("Attempting to make player index " + i + " a giant")
        becomeGiant(i)
        break
    }
}

::becomeGiant <- function(playerIndex)
{
    local player = PlayerInstanceFromIndex(playerIndex)

    local scope = player.GetScriptScope()
    scope.isGiant <- null

    local giantSpecifics = giantProperties[chosenGiantThisRound]
    
    //Giant HP depends on the amount of players. Let's calculate that
    //Base HP is HP at 12 players, any less and we scale multiplicatively
    local giantHealth = giantSpecifics.baseHealth
    local redPlayerCount = 0
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != 2) continue
        redPlayerCount += 1
    }
    giantHealth = giantHealth / BASE_GIANT_PLAYER_COUNT.tofloat()
    giantHealth = giantHealth * redPlayerCount
    //Why is nobody on red? You get 1000 hp as consolation prize
    if(giantHealth == 0) {
        giantHealth = 1000
        debugPrint("\x05NOBODY is on red? Giant HP is now " + giantHealth)
    }

    //The healing the giant receives is also scaled based on player count
    local healMult = BASE_GIANT_HEALING / BASE_GIANT_PLAYER_COUNT.tofloat()
    healMult = BASE_GIANT_HEALING * redPlayerCount
    if(healMult == 0) {
        healMult = 0.5
    }
    player.AddCustomAttribute("healing received penalty", healMult, -1)
    debugPrint("\x05Giant healing scale is now " + healMult)

    //It's time to switch classes. It's not as simple as one func 
    player.SetPlayerClass(giantSpecifics.classId)
    NetProps.SetPropInt(player, "m_Shared.m_iDesiredPlayerClass", giantSpecifics.classId)
    player.ForceRegenerateAndRespawn()

    //General giant adjustments
    debugPrint("Player should have " + (giantHealth - baseClassHealth[giantSpecifics.classId]).tostring() + " max health bonus")
    player.AddCustomAttribute("max health additive bonus", giantHealth.tofloat() - baseClassHealth[giantSpecifics.classId].tofloat(), -1)
    player.SetHealth(giantHealth)

    player.SetModelScale(GIANT_SCALE, 0)
    player.SetCustomModelWithClassAnimations(giantSpecifics.playerModel)
    player.AddCond(130)

    //Give player the giant's weapons and weapon attributes
    //These functions are separated and delayed to ensure that the players' default weapons don't override
    // EntFire("gamerules", "RunScriptCode", "applyGiantWeapons(" + playerIndex + ")", 1)

    GivePlayerWeapon(player, giantSpecifics.primaryWeaponClassName,     giantSpecifics.primaryWeaponID,     0)
    GivePlayerWeapon(player, giantSpecifics.secondaryWeaponClassName,   giantSpecifics.secondaryWeaponID,   1)
    GivePlayerWeapon(player, giantSpecifics.meleeWeaponClassName,       giantSpecifics.meleeWeaponID,       2)

    //Give each weapon the player has the giant weapon attributes
    for (local i = 0; i < MaxWeapons; i++)
    {
        local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null)
            continue
        // debugPrint("Looking at weapon " + weapon.GetClassname() + " with the slot " + weapon.GetSlot())
        local attributesTable = {}
        switch(weapon.GetSlot())
        {
            case 0:
                attributesTable = giantSpecifics.primaryAttributes
                break
            case 1:
                attributesTable = giantSpecifics.secondaryAttributes
                break
            case 2:
                attributesTable = giantSpecifics.meleeAttributes
                break
            default:
                break
        }

        if(attributesTable == null) continue
        
        foreach(attribute, value in attributesTable)
        {
            weapon.AddAttribute(attribute, value, -1)
            // debugPrint("To weapon in slot " + weapon.GetSlot() + " attempting to add attribute \x04" + attribute + " \x01with the value \x04" + value)
        }
    }

    //Give the player the giant's player attributes
    foreach(attribute, value in giantSpecifics.playerAttributes)
    {
        player.AddCustomAttribute(attribute, value, -1)
        // debugPrint("To player, attempting to add attribute \x04" + attribute + " \x01with the value \x04" + value)
    }

    //Give the player the global giant attributes
    foreach(attribute, value in globalGiantAttributes)
    {
        player.AddCustomAttribute(attribute, value, -1)
        // debugPrint("To player, attempting to add attribute \x04" + attribute + " \x01with the value \x04" + value)
    }

    //Teleport giant to nearest CP
    player.Teleport(true, bombSpawnOrigin, false, QAngle(0,0,0), false, Vector(0,0,0))

    //We teleported the bomb already but just to be sure we also set its owner to the newly gigantified player
    bombFlag.SetOwner(player)
}