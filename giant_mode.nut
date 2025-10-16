function root::startGiantMode()
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
        if(playersToShove.GetTeam() == TF_TEAM_BLUE) continue

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
        break
    }

    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_BLUE) continue

        player.SetScriptOverlayMaterial(null) //Remove giant info hud
        local scope = player.GetScriptScope()
        if("giantHideHudThink" in scope.thinkFunctions) delete scope.thinkFunctions.giantHideHudThink
    }

    //Have red players all yell at the incoming giant
    globalSpeakResponseConcept("ConceptMvMGiantCallout:1", "TLK_MVM_GIANT_CALLOUT")
    EntFireByHandle(gamerules, "RunScriptCode", "globalSpeakResponseConcept(`ConceptMvMGiantHasBomb:1`, `TLK_MVM_GIANT_HAS_BOMB`)", 4, gamerules, gamerules)

    EntFireByHandle(hideGiantHudHint, "HideHudHint", null, 0, self, self)
}

//Called 0.4s before giant spawns via intermission.nut
function root::pushPlayersNearGiantSpawnPoint()
{
    //Nearby players will take 1 damage and get pushed back before giant spawns
    local playersToPush = null
    while(playersToPush = Entities.FindByClassnameWithin(playersToPush, "player", bombSpawnOrigin, 256))
    {
        //We don't push blu team
        if(playersToPush.GetTeam() == TF_TEAM_BLUE) continue
        
        //Do trigonometry homework to find the angle to launch the players to
        local playerOrigin = playersToPush.GetOrigin()
        local deltaOrigin = bombSpawnOrigin - playerOrigin
        deltaOrigin.z = 0
        deltaOrigin.Norm()
        deltaOrigin.z = 375

        playersToPush.ApplyAbsVelocityImpulse(deltaOrigin)
    }
}

function root::DestroyPlayerWeapon(player, itemSlotToDestroy)
{
	// remove existing weapon in slot
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
}

function root::GivePlayerWeapon(player, className, itemID, itemSlotToDestroy=0)
{
    // remove existing weapon in same slot
    DestroyPlayerWeapon(player, itemSlotToDestroy)
    
    if(className != null) {
        local weapon = Entities.CreateByClassname(className)
        NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID)
        NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
        NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
        weapon.SetTeam(player.GetTeam())
        weapon.DispatchSpawn()

        player.Weapon_Equip(weapon)
        player.Weapon_Switch(weapon)

        return weapon
    }
    
    else {
        return null
    }
}

//Internally, weapons like Razorback, Splendid Screen etc. are cosmetics with stats and not "weapons"
//they need to be removed manually
function root::removeWeaponWearables(player)
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

function root::becomeGiant(playerIndex)
{
    local player = PlayerInstanceFromIndex(playerIndex)

    //Sometimes the overlay persists???
    player.SetScriptOverlayMaterial(null)

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
	scope.isBecomingGiant = false
    scope.isGiant = true

	giantPlayer = player

    local giantSpecifics = giantProperties[chosenGiantThisRound]
    
    //Giant HP depends on the amount of players. Let's calculate that
    //Base HP is HP at 12 players, any less and we scale multiplicatively
    local giantHealth = giantSpecifics.baseHealth
    local redPlayerCount = 0
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_RED) continue
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
	healMult = healMult == 0 ? 0.5 : healMult
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
    player.Teleport(true, bombSpawnOrigin, false, QAngle(), false, Vector())

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
        if (player.GetTeam() != TF_TEAM_BLUE) continue

        player.AddCustomAttribute("cannot pick up intelligence", 1, -1)
    }

    //A bunch of think funcs, see the function below for the list of things it does
    addGiantThink(player)

    //Boss bar
    SetBossEntity(player)
	UpdateBossBarLeaderboardIcon(giantSpecifics.classIcon)

    player.SetIsMiniBoss(true)

    //Full ammo regeneration for the first 5 seconds
    player.AddCustomAttribute("ammo regen", 1, 5)

    //Show giant name and some tips if the giant is a bit complicated
    EntFireByHandle(gameText_giantDetails, "Display", null, -1, player, player)

    //Miscellaneous actions to do if a giant has tags
    if(giantSpecifics.tags == null) return

    foreach(tag in giantSpecifics.tags) {
        switch(tag) {
            case "always_crit":
                player.AddCondEx(TF_COND_CRITBOOSTED_RAGE_BUFF, -1, null)
				break
            
            case "knight_shield":
                EntFireByHandle(player, "RunScriptCode", "addGiantKnightShield(activator)", 0.1, player, player)
				break

            case "regenerate_on_spawn":
                EntFireByHandle(player, "RunScriptCode", "self.Regenerate(true)", 0.1, null, null)
                //EntFireByHandle(player, "RunScriptCode", "setWeaponClip(activator, 1, 5)", 0.1, player, player)
				break

            case "1_clip_primary":
                EntFireByHandle(player, "RunScriptCode", "setWeaponClip(activator, 0, 1)", -1, player, player)
				break

            case "1_clip_secondary":
                EntFireByHandle(player, "RunScriptCode", "setWeaponClip(activator, 1, 1)", -1, player, player)
				break

            case "airblast_crits":
                scope.gpyroThink <- function()
				{
                    if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
                        delete thinkFunctions.gpyroThink
                    }
                    local projectileToCheck = null
                    while(projectileToCheck = Entities.FindByClassname(projectileToCheck, "tf_projectile_*"))
					{
                        //Not belonging to blue = impossible to have been reflected by the giant pyro
                        //Projectiles change ownership on reflect, except for stickybombs
                        //Stickybombs are excluded completely from this mechanic
                        if(projectileToCheck.GetTeam() != TF_TEAM_BLUE) {
                            // debugPrint("PR: not blu team, skipping")
                            continue
                        }
                        if(projectileToCheck.GetClassname() in UNREFLECTABLE_PROJECTILES) {
                            // debugPrint("PR: in unreflectable list, skipping")
                            continue
                        }
                        if(!NetProps.GetPropInt(projectileToCheck, "m_iDeflected")) {
                            // debugPrint("PR: not deflected, skipping")
                            continue
                        }

                        //Grenades for some reasons dont change owner but instead deflectowner
                        local owner = NetProps.GetPropEntity(projectileToCheck, "m_hOwnerEntity")
                        if(owner != self) {
                            owner = NetProps.GetPropEntity(projectileToCheck, "m_hDeflectOwner")
                            if(owner != self) continue
                        }

                        if(NetProps.GetPropBool(projectileToCheck, "m_bCritical")) continue

                        debugPrint("PR: " + projectileToCheck.GetClassname() + " set to crit")

                        NetProps.SetPropBool(projectileToCheck, "m_bCritical", true)
                        local deflectCount = NetProps.GetPropInt(projectileToCheck, "m_iDeflected")
                        //Force data update to update trails
                        NetProps.SetPropInt(projectileToCheck, "m_iDeflected", deflectCount + 1)
                    }
				}
				scope.thinkFunctions.gpyroThink <- scope.gpyroThink
                break

            case "giant_engineer":
                //Activates a set of callbacks for giant engineer
				scope.gengieThink <- function()
				{
                    if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
                        delete thinkFunctions.gengieThink
                    }
					//based on main think's time of -1, so constantly spamming this might not be great
					local building = null
					while(building = Entities.FindByClassname(building, "obj_*"))
					{
						if(NetProps.GetPropEntity(building, "m_hBuilder") != self) continue

                        //Check if teleporter and is exit
                        if(building.GetClassname() == "obj_teleporter" && building.GetName() != "indestructible_tele_entrance")
                        {
                            //If teleporter state is ready, set the origin of tele exit
                            //This will cause player_spawn callback to teleport all blu players here and give temp uber
                            local teleState = NetProps.GetPropInt(building ,"m_iState")

                            if(teleState == 2)
                            {
                                setTeleExitOrigin(building.GetOrigin(), building.GetAbsAngles())

                                //Teleporters should be instantly set to level 3 if not already
                                local teleLevel = NetProps.GetPropInt(building, "m_iHighestUpgradeLevel")
                                if(teleLevel != 3) NetProps.SetPropInt(building, "m_iHighestUpgradeLevel", 3)
                            }
                            else
                            {
                                stopTeleExit()
                            }
                        }

						if(building.GetModelScale() == 1.5) continue
						
						//m_bCarried for buildings that were already placed
						if(NetProps.GetPropBool(building, "m_bPlacing") && !NetProps.GetPropBool(building, "m_bCarried"))
						{
							building.SetModelScale(1.5, 0)
						}
					}

                    //Dispenser screens are separate entities that need to be re-scaled fo g.engis
					local dispscreen = null
					while(dispscreen = Entities.FindByClassname(dispscreen, "vgui_screen"))
					{
                        if(NetProps.GetPropEntity(dispscreen, "m_hPlayerOwner") != self) continue
                        if(NetProps.GetPropFloat(dispscreen, "m_flWidth") == 29.25) continue

                        NetProps.SetPropFloat(dispscreen, "m_flWidth", 30.375)
                        NetProps.SetPropFloat(dispscreen, "m_flHeight", 16.70625)
                    }
				}
				scope.thinkFunctions.gengieThink <- scope.gengieThink

                createIndestructibleTeleEntrance(player)
                //Set g.engi FJ to start with 6 shots
                EntFireByHandle(player, "RunScriptCode", "setWeaponClip(activator, 0, 6)", -1, player, player)
				break

            case "giant_medic":
                //Amputator effect
                player.AddCondEx(TF_COND_RADIUSHEAL_ON_DAMAGE, -1, null)

                //Only need to be done once since giants have a dropped weapon deletion aura
                //bomb_ubers.nut's think runs it every tick since other medics can switch medi guns mid life via dropped weapons
                for(local i = 0; i < NetProps.GetPropArraySize(player, "m_hMyWeapons"); i++) {
                    local wep = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
                
                    if(wep && wep.GetClassname() == "tf_weapon_medigun") {
                        scope.medigun <- NetProps.GetPropEntityArray(player, "m_hMyWeapons", i);
                        break;
                    }
                }

                //Keeps track of medics deploying ubercharges for the first time
                scope.hasDeployedUbercharge <- false

				scope.gmedicThink <- function()
				{
                    if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
                        delete thinkFunctions.gmedicThink
                    }

                    //Amputator effect
                    //Needs to be in think because it's removed if the gmed ends any taunt
                    player.AddCondEx(55, 1, null)

                    //If medic doesnt have medi gun out, dont do any of these stuffs
                    local activeWeapon = self.GetActiveWeapon()
                    if(activeWeapon != medigun) {
                        if(hasDeployedUbercharge) {
                            hasDeployedUbercharge = false
                            debugPrint("Stopping kritz uber sound")
                            //Stops the kritz uber sound
                            playSoundOnePlayer("weapons/weapon_crit_charged_on.wav", self, SND_STOP)

                            playSoundOnePlayer("weapons/weapon_crit_charged_off.wav", self)
                        }
                        return
                    }

                    //For god knows why kritzkrieg cant ubercharge if medic is carrying the flag so we need to do it ourselves
                    local buttons = NetProps.GetPropInt(self, "m_nButtons")
                    local uberMeter = NetProps.GetPropFloat(medigun, "m_flChargeLevel") //Only be able to activate uber if you're full of course
                    if((buttons & IN_ATTACK2) && uberMeter >= 1) {
                        NetProps.SetPropBool(medigun, "m_bChargeRelease", true)
                    }

                    local isUbercharged = NetProps.GetPropBool(medigun, "m_bChargeRelease")

                    if(!isUbercharged) {
                        if(hasDeployedUbercharge) {
                            hasDeployedUbercharge = false
                            debugPrint("Uber ran out, stopping kritz uber sound")
                            //Stops the kritz uber sound
                            playSoundOnePlayer("weapons/weapon_crit_charged_on.wav", self, SND_STOP)
                        }
                    }
					else {
						if(!hasDeployedUbercharge) {
							debugPrint("Starting kritz uber sound and voiceline")
							playSoundOnePlayer("weapons/weapon_crit_charged_on.wav", self)

							//This one is global
							playSoundEx("vo/mvm/norm/medic_mvm_specialcompleted05.mp3")
							hasDeployedUbercharge = true
						}
						
						local radialKritzPlayer = null
						while(radialKritzPlayer = Entities.FindByClassnameWithin(radialKritzPlayer, "player", self.GetOrigin(), 450))
						{
							//Cond 39 to not override other crits or have the dumb conditions 11 has
							radialKritzPlayer.AddCondEx(39, 0.045, null)
						}
					}
				}
				scope.thinkFunctions.gmedicThink <- scope.gmedicThink

                //Set g.medic crossbow to start with 20 shots
                EntFireByHandle(player, "RunScriptCode", "setWeaponClip(activator, 0, 20)", -1, player, player)
                break

            default:
				break
        }
    }
}

//Despite its general name it's only for Nukesalot to spawn with 1 clip kek
function root::setWeaponClip(player, weaponSlot, clipCount)
{
    for (local i = 0; i < MaxWeapons; i++)
    {
        local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null) continue
        if (weapon.GetSlot() != weaponSlot) continue
        weapon.SetClip1(clipCount)
    }
}

//This stupid fucking weapon needs its own workaround kms
function root::addGiantKnightShield(player)
{
    debugPrint("ADDING CHARGIN TARGE")
    CTFBot.GenerateAndWearItem.call(player, "The Chargin' Targe")
}

function root::addGiantThink(player)
{
    local scope = player.GetScriptScope()
    scope.giantThink <- function()
    {
        //Remove think on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            delete thinkFunctions.giantThink
            return
        }

        //Delete nearby dropped weapons to ensure giants can never pick one up
        local droppedWeapon = null
        while(droppedWeapon = Entities.FindByClassnameWithin(droppedWeapon, "tf_dropped_weapon", player.GetOrigin(), 256))
        {
            droppedWeapon.Kill()
        }

        //If giant does not have bomb, and is not ubered, teleport the bomb back to them
        if(!self.HasItem() && !self.InCond(TF_COND_INVULNERABLE))
        {
            bombFlag.SetAbsOrigin(self.GetOrigin())
        }

        //Everything below handles giant speed cap
        //Do not do anything if it's giant demoknight charging
        if(self.InCond(TF_COND_SHIELD_CHARGE)) return

        local vel = self.GetAbsVelocity()
        
        local scalarVel = pow(pow(vel.x, 2) + pow(vel.y, 2), 0.5).tofloat()
        // debugPrint("Scalar vel: " + scalarVel)

        if(scalarVel <= giantProperties[chosenGiantThisRound].speedCap) return

        //Because of acceleration and allat just going for speedCap / scalarVel doesnt seem to work nicely, so i added 0.9 scale
        //It's not perfect but it's close enough that any speed boost that actually happens will be less than 5% at most
        local speedScale = (giantProperties[chosenGiantThisRound].speedCap / scalarVel) * 0.9
        self.SetAbsVelocity(Vector(vel.x * speedScale, vel.y * speedScale, vel.z))

        return
    }
    
    scope.thinkFunctions.giantThink <- scope.giantThink
}

//For giant engineers: ban the construction of a tele entrance by spawning one out of bounds
function root::createIndestructibleTeleEntrance(player)
{
    if(giantPlayer == null) return //Safeguard
    local tele_entrance = SpawnEntityFromTable("obj_teleporter", {
        targetname = "indestructible_tele_entrance",
        TeamNum = TF_TEAM_BLUE,
        defaultupgrade = 2,
        teleporterType = 1,
        spawnflags = 2,
        origin = GIANT_ENGINEER_TELE_ENTRANCE_ORIGIN
	})
    EntFireByHandle(tele_entrance, "SetBuilder", null, -1, player, player)
}

function root::setTeleExitOrigin(origin, angles)
{
    //Think is executed every tick but we dont want to do this if it didnt change
    if(giantEngineerTeleExitOrigin == origin) return

    EmitSoundEx("mvm/mvm_tele_activate.wav")

    giantEngineerTeleExitOrigin = origin
    giantEngineerTeleExitOrigin.z = giantEngineerTeleExitOrigin.z

    giantEngineerTeleExitAngle = angles

    //Ensures particle doesnt stack
    if(giantEngineerTeleExitParticle != null) return

    giantEngineerTeleExitParticle = SpawnEntityFromTable("info_particle_system", {
        targetname = "gengi_tele_particle",
        origin = giantEngineerTeleExitOrigin,
        effect_name = "teleporter_mvm_bot_persist",
        start_active = 1
	})
}

function root::stopTeleExit()
{
    if(giantEngineerTeleExitParticle != null) {
        giantEngineerTeleExitParticle.Kill()
        giantEngineerTeleExitParticle = null
    } 
    giantEngineerTeleExitOrigin = null
    giantEngineerTeleExitAngle = null
}

function root::handleGiantDeath()
{
    //Update team respawn times
    gamerules.AcceptInput("SetRedTeamRespawnWaveTime", RED_POST_GIANT_RESPAWN_TIME.tostring(), null, null)
    gamerules.AcceptInput("SetBlueTeamRespawnWaveTime", BLUE_POST_GIANT_RESPAWN_TIME.tostring(), null, null)

    //Giant no longer active, allow all blu players to pick up the bomb
    isBombGiantDead = true

    //Announcer is happy that red took something down
    EntFireByHandle(gamerules, "PlayVORed", "Announcer.MVM_General_Destruction", -1, null, null)
    EntFireByHandle(gamerules, "PlayVORed", "MVM.TankEnd", -1, null, null)
	
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_BLUE) continue

        player.RemoveCustomAttribute("cannot pick up intelligence")
    }

    //Disable healthbar
    SetBossEntity(null)

    //On giant death: destroy all buildings that they owned.
    //Relevant for giant engineer
	if(giantPlayer.GetPlayerClass() == TF_CLASS_ENGINEER)
	{
		debugPrint("\x07666666Player was engineer, destroy all previously owned buildings")
		local buildingEnt = null
		while(buildingEnt = Entities.FindByClassname(buildingEnt, "obj_*")) //this does allow sappers but engies don't own sappers
		{
			debugPrint("\x07666666Found a building!")
			if(NetProps.GetPropEntity(buildingEnt, "m_hBuilder") == giantPlayer) {
				debugPrint("\x07666666It is owned by the giant player!")
				buildingEnt.AcceptInput("RemoveHealth", "9999", null, null)
			}
		}
		giantEngineerTeleExitOrigin = null
		giantEngineerTeleExitAngle = null
	}
	
	//now done with the giant
	giantPlayer = null
}

function root::displayGiantTeleportParticle()
{
    DispatchParticleEffect("stt_giant_teleport", bombSpawnOrigin, Vector(90, 0, 0))
    playSoundEx("mvm/mvm_tele_activate.wav")
}