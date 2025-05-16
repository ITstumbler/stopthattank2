::startGiantMode <- function()
{
    //2:30 to deliver the bomb or else
    //Might want to move this soon
    roundTimer.AcceptInput("SetTime", BOMB_MISSION_LENGTH.tostring(), null, null)

    //Update team respawn times
    gamerules.AcceptInput("SetRedTeamRespawnWaveTime", RED_GIANT_RESPAWN_TIME.tostring(), null, null)

    if(giantProperties[chosenGiantThisRound].respawnOverride)
    {
        debugPrint("Special giant type " + giantProperties[chosenGiantThisRound].giantName + " will override BLU's respawn time to " + giantProperties[chosenGiantThisRound].respawnOverride.tostring())
        gamerules.AcceptInput("SetBlueTeamRespawnWaveTime", giantProperties[chosenGiantThisRound].respawnOverride.tostring(), null, null)
    }
    else
    {
        gamerules.AcceptInput("SetBlueTeamRespawnWaveTime", BLUE_GIANT_RESPAWN_TIME.tostring(), null, null)
    }

    //Next time the timer runs out, red wins!
    //Because this thing is prone to race condition, it's delayed
    EntFire("gamerules", "RunScriptCode", "setSTTRoundState(STATE_BOMB)", 1)
    
    //Adjust HUD to be CTF CP mode
    NetProps.SetPropInt(gamerules, "m_nHudType", 2)
    NetProps.SetPropBool(gamerules, "m_bPlayingHybrid_CTF_CP", true)

    //Set bomb origin to latest capped CP (start if no capped CP)
    //EDGE CASE WARNING: bomb might get picked up by another pleb and not the giant, careful
    bombFlag.AcceptInput("Enable", null, null, null)
    bombFlag.SetAbsOrigin(bombSpawnOrigin)

    //For every red pleb that wouldve been inside the giant somehow despite the push, forcefully shove them aside
    local playersToShove = null
    while(playersToShove = Entities.FindByClassnameWithin(playersToShove, "player", bombSpawnOrigin, 163))
    {
        //We don't shove blu team
        if(playersToShove.GetTeam == TF_TEAM_BLUE) continue

        local playerOrigin = playersToShove.GetOrigin()

        //Get them out of the giant by forcefully setting their origin outside, similar to tanks
        if(playerOrigin.x >= bombSpawnOrigin.x) {
            playersToShove.SetAbsOrigin(Vector(bombSpawnOrigin.x + 69, playerOrigin.y, playerOrigin.z))
        }
        if(playerOrigin.x < bombSpawnOrigin.x) {
            playersToShove.SetAbsOrigin(Vector(bombSpawnOrigin.x - 69, playerOrigin.y, playerOrigin.z))
        }
        if(playerOrigin.y >= bombSpawnOrigin.y) {
            playersToShove.SetAbsOrigin(Vector(playerOrigin.x, bombSpawnOrigin.y + 69, playerOrigin.z))
        }
        if(playerOrigin.y < bombSpawnOrigin.y) {
            playersToShove.SetAbsOrigin(Vector(playerOrigin.x, bombSpawnOrigin.y - 69, playerOrigin.z))
        }
    }

    //Check which pleb has isBecomingGiant
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_BLUE) continue
        if (!player.GetScriptScope().isBecomingGiant) continue
        debugPrint("Attempting to make player index " + i + " a giant")
        becomeGiant(i)
        player.GetScriptScope().isBecomingGiant = false
        break
    }

    //Add special bomb uber thinks for blu medics that let them uber bomb carriers
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_BLUE) continue
        if (player.GetPlayerClass() != TF_CLASS_MEDIC) continue
        
        addBombUberThink(player)
        
        break
    }
}

//Called 0.4s before giant spawns via intermission.nut
::pushPlayersNearGiantSpawnPoint <- function()
{
    //Nearby players will take 1 damage and get pushed back before giant spawns
    local playersToPush = null
    while(playersToPush = Entities.FindByClassnameWithin(playersToPush, "player", bombSpawnOrigin, 256))
    {
        //We don't push blu team
        if(playersToPush.GetTeam == TF_TEAM_BLUE) continue
        
        //Do trigonometry homework to find the angle to launch the players to
        local playerOrigin = playersToPush.GetOrigin()
        local deltaX = bombSpawnOrigin.x - playerOrigin.x
        local deltaY = bombSpawnOrigin.y - playerOrigin.y

        local pushAngle = atan(deltaY / deltaX)
        local pushPowerX = sin(pushAngle) * -250
        local pushPowerY = cos(pushAngle) * -250

        // debugPrint("\x07FF2222Delta X: " + deltaX)
        // debugPrint("\x07FF2222Delta Y: " + deltaY)
        // debugPrint("\x07FF2222Arctan: " + pushAngle)
        // debugPrint("\x07FF2222Sin Theta: " + sin(pushAngle))
        // debugPrint("\x07FF2222Cos Theta: " + cos(pushAngle))
        // debugPrint("\x07FF2222Push power X: " + pushPowerX)
        // debugPrint("\x07FF2222Push power Y: " + pushPowerY)

        playersToPush.ApplyAbsVelocityImpulse(Vector(pushPowerX, pushPowerY, 375))
    }
}

::GivePlayerWeapon <- function(player, className, itemID, itemSlotToDestroy=0)
{
    //Setting itemID to null means that we dont want players to have anything in that slot
    if(itemID == null)
    {
        // remove existing weapon in same slot
        for (local i = 0; i < MaxWeapons; i++)
        {
            local heldWeapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
            if (heldWeapon == null)
                continue
            if (heldWeapon.GetSlot() != itemSlotToDestroy)
                continue
            heldWeapon.Destroy()
            NetProps.SetPropEntityArray(player, "m_hMyWeapons", null, i)
            break
        }
        return
    }

    local weapon = null

    //Set of workarounds for spawning wearables such as targes
    if(className == "tf_weapon_demoshield") {
        local parachute = Entities.CreateByClassname("tf_weapon_parachute")
        NetProps.SetPropInt(parachute, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1101)
        NetProps.SetPropBool(parachute, "m_AttributeManager.m_Item.m_bInitialized", true)
        parachute.SetTeam(player.GetTeam())
        parachute.DispatchSpawn()
        player.Weapon_Equip(parachute)
        weapon = NetProps.GetPropEntity(parachute, "m_hExtraWearable")
        parachute.Kill()

        NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID)
        NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
        NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
        weapon.DispatchSpawn()

        SendGlobalGameEvent("post_inventory_application", { userid = GetPlayerUserID(player) })

        player.ValidateScriptScope()
        local player_scope = player.GetScriptScope()
        if (!("wearables" in player_scope))
            player_scope.wearables <- []
        player_scope.wearables.append(weapon)
    }
    
    //Regular weapon spawning protocol
    else {
        weapon = Entities.CreateByClassname(className)
        NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID)
        NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
        NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
        weapon.SetTeam(player.GetTeam())
        weapon.DispatchSpawn()
    }

    // remove existing weapon in same slot
    for (local i = 0; i < MaxWeapons; i++)
    {
        local heldWeapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (heldWeapon == null)
            continue
        if (heldWeapon.GetSlot() != itemSlotToDestroy)
            continue
        heldWeapon.Destroy()
        NetProps.SetPropEntityArray(player, "m_hMyWeapons", null, i)
        break
    }
    
    player.Weapon_Equip(weapon)
    player.Weapon_Switch(weapon)

    return weapon
}

//Internally, weapons like Razorback, Splendid Screen etc. are cosmetics with stats and not "weapons"
//they need to be removed manually
::removeWeaponWearables <- function(player)
{
    for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
    {
        local itemId = NetProps.GetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")

        if(wearable == null) continue
        //Check if item ID is no good, like Razorback
        if(!(itemId in WEARABLE_IDS_TO_REMOVE)) continue

        debugPrint("Found valid wearable with the ID " + itemId)
        EntFireByHandle(wearable, "Kill", null, -1, wearable, wearable)
    }
}

::becomeGiant <- function(playerIndex)
{
    local player = PlayerInstanceFromIndex(playerIndex)

    //If player is engineer, manually destroy all existing buildings they owned
    if(player.GetPlayerClass() == TF_CLASS_ENGINEER)
    {
        debugPrint("\x07666666Player was engineer, destroy all previously owned buildings")
		local buildingEnt = null
		while(buildingEnt = Entities.FindByClassname(buildingEnt, "obj_*")) //this does allow sappers but engies don't own sappers
		{
			debugPrint("\x07666666Found a building!")
			if(NetProps.GetPropEntity(buildingEnt, "m_hBuilder") == player) {
				debugPrint("\x07666666It is owned by the giant player!")
				buildingEnt.AcceptInput("RemoveHealth", "9999", null, null)
			}
		}
    }

    local scope = player.GetScriptScope()
    scope.isGiant = true

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

    //Remove weapon wearables such as Razorback
    removeWeaponWearables(player)

    //Give player the giant's weapons and weapon attributes
    //These functions are separated and delayed to ensure that the players' default weapons don't override
    // EntFire("gamerules", "RunScriptCode", "applyGiantWeapons(" + playerIndex + ")", 1)

    //Order is inverted so that primary then secondary weapons are prioritized to be equipped first
    GivePlayerWeapon(player, giantSpecifics.meleeWeaponClassName,       giantSpecifics.meleeWeaponID,       2)
    GivePlayerWeapon(player, giantSpecifics.secondaryWeaponClassName,   giantSpecifics.secondaryWeaponID,   1)
    GivePlayerWeapon(player, giantSpecifics.primaryWeaponClassName,     giantSpecifics.primaryWeaponID,     0)

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

    //You are an AWESOME GIANT you will LOOK AT YOURSELF when you spawn
    //Everything here is delayed to ensure that they get called after the player teleport
    EntFireByHandle(player, "RunScriptCode", "self.SetForcedTauntCam(1)", -1, player, player)
    EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`SET BONUS: move speed set bonus`, 0.0001, GIANT_CAMERA_DURATION)", -1, player, player)
    EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`dmg taken increased`, 0.001, GIANT_CAMERA_DURATION)", -1, player, player)
    EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`health regen`, 10000, GIANT_CAMERA_DURATION)", -1, player, player)

    //Ok enough looking at yourself move it move it
    EntFireByHandle(player, "RunScriptCode", "self.SetForcedTauntCam(0)", GIANT_CAMERA_DURATION, player, player)

    //STOP THE TIMER THE GIANT PLAYER IS FLEXING
    roundTimer.AcceptInput("Pause", null, null, null)

    //Giant player is done flexing, resume timer
    EntFireByHandle(roundTimer, "Resume", null, GIANT_CAMERA_DURATION, null, null)

    //Giant player teleporting in shakes nearby players for a little bit, just to hammer it in that he's a big boy
    ScreenShake(bombSpawnOrigin, 8, 2.5, 1, 700, 0, true)
    
    //Yell at red that there's a new threat they need to look at
    //Im so sorry for no newlines the game doesnt like it when I do that :(
    EntFireByHandle(gamerules, "RunScriptCode", "SendGlobalGameEvent(`show_annotation`, { worldPosX = bombSpawnOrigin.x, worldPosY = bombSpawnOrigin.y, worldPosZ = bombSpawnOrigin.z, text = giantProperties[chosenGiantThisRound].giantName + ` has the bomb!`, show_distance = false, play_sound = `mvm/mvm_warning.wav`, lifetime = 4.5 })", GIANT_CAMERA_DURATION, null, null)

    //Sounds to play when giant teleports in
    playSoundEx("mvm/giant_heavy/giant_heavy_entrance.wav")
    playSoundEx("misc/halloween/spell_mirv_explode_primary.wav")

    EntFireByHandle(gamerules, "RunScriptCode", "playSoundEx(giantProperties[chosenGiantThisRound].introSound)", 3, null, null)
    
    //Also play a sound when giant starts moving
    //Sound is currently handled by show_annotation above
    // EntFireByHandle(gamerules, "RunScriptCode", "playSoundEx(`mvm/mvm_warning.wav`)", GIANT_CAMERA_DURATION, null, null) 

    //Clean up the shaker and annotations
    // EntFireByHandle(giantShaker,        "Kill", null, GIANT_CAMERA_DURATION + 1, null, null)
    // EntFireByHandle(giantAnnotation,    "Kill", null, GIANT_CAMERA_DURATION + 1, null, null)

    //While giant is alive, no one else on blu is allowed to pick up the bomb
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        //Don't apply this to the giant themselves
        if (i == playerIndex) continue

        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != 3) continue

        player.AddCustomAttribute("cannot pick up intelligence", 1, -1)
    }

    //A bunch of think funcs, see the function below for the list of things it does
    addGiantThink(player)

    if(giantProperties[chosenGiantThisRound].conds != null)
    {
        foreach(condId in giantProperties[chosenGiantThisRound].conds)
        {
            player.AddCondEx(condId, -1, null)
        }
    }
}

::addGiantThink <- function(player)
{
    local scope = player.GetScriptScope()
    scope.giantThink <- function()
    {
        //Remove think on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            AddThinkToEnt(self, null)
            NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
            return -1
        }

        //Delete nearby dropped weapons to ensure giants can never pick one up
        local droppedWeapon = null
        while(droppedWeapon = Entities.FindByClassnameWithin(droppedWeapon, "tf_dropped_weapon", player.GetOrigin(), 256)) //this does allow sappers but engies don't own sappers
        {
            droppedWeapon.Kill()
        }

        //If giant does not have bomb, and is not ubered, teleport the bomb back to them
        if(!self.HasItem() && !self.InCond(5))
        {
            bombFlag.SetAbsOrigin(self.GetOrigin())
        }

        return -1
    }
    AddThinkToEnt(player, null)
    AddThinkToEnt(player, "giantThink")
}

::handleGiantDeath <- function()
{
    //Update team respawn times
    gamerules.AcceptInput("SetRedTeamRespawnWaveTime", RED_POST_GIANT_RESPAWN_TIME.tostring(), null, null)
    gamerules.AcceptInput("SetBlueTeamRespawnWaveTime", BLUE_POST_GIANT_RESPAWN_TIME.tostring(), null, null)

    //Giant no longer active, allow all blu players to pick up the bomb
    isBombGiantDead = true

    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_BLUE) continue

        player.RemoveCustomAttribute("cannot pick up intelligence")
    }
}

::displayGiantTeleportParticle <- function()
{
    DispatchParticleEffect("stt_giant_teleport", bombSpawnOrigin, Vector(90, 0, 0))
    playSoundEx("mvm/mvm_tele_activate.wav")
}