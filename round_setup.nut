//Allows us to reference constants by name so no need to remember the cringe out-of-order class ID e.g. TF_CLASS_SNIPER = 2
::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
    foreach (a,b in Constants)
        foreach (k,v in b)
            ROOT[k] <- v != null ? v : 0;
}

::SND_STOP <- 4 //flag for emitsoundex

//Setup for stacking thinks
::playerThink <- function() {
	foreach(key, func in thinkFunctions) {
		func()
	}
    return -1
}

//Balance-sensitive parameters
::TANK_SPEED                        <- 45           //The speed at which the tank goes. The fake_train in the map must be set to the same speed
::BASE_TANK_HEALTH                  <- 12000        //Base tank health, will be increased or decreased if the amount of players on red is more or less than BASE_TANK_PLAYER_COUNT. Can be overriden using overrideBaseTankHealth(health)
::BASE_TANK_PLAYER_COUNT            <- 12           //If there are this many players on red team, the tank will use BASE_TANK_HEALTH. Scaled linearly if there are more or less players on red team
::SETUP_LENGTH                      <- 6           //Time between round starting and doors opening, like other gamemodes' setup. MUST match team_round_timer keyvalues.
::POST_SETUP_LENGTH                 <- 15           //Time between setup ending and tank spawning. MUST match team_round_timer keyvalues.
::INTERMISSION_LENGTH               <- 30           //Time between tank dying and giant spawning. MUST be higher than 2 seconds. Avoid changing this since it lines up with cash expiring.
::BOMB_MISSION_LENGTH               <- 150          //Time blu has to deploy the bomb the moment their giant can move, in seconds (like everything else)
::TOP_PLAYERS_ELIGIBLE_FOR_GIANT    <- 5            //Pick from the first x top performing players in scoreboard to be giant
::GIANT_TYPES_AMOUNT                <- 12           //Pick first x giant templates to choose from
::GIANT_SCALE                       <- 1.75         //Giant players will be scaled by this much
::INTERMISSION_ROLLBACK_SPEED       <- 400          //HUD tank rolls back during intermission - this determines its speed
::BOMB_CARRIER_CONDS                <- {            //Conditions to apply to non-giant players carrying the bomb. Value determines duration (-1: infinite)
                                        [TF_COND_OFFENSEBUFF]               = -1,
                                        [TF_COND_DEFENSEBUFF_NO_CRIT_BLOCK] = -1,
                                        [TF_COND_HALLOWEEN_QUICK_HEAL]      = 3
                                       }
::BOMB_CARRIER_ATTRIBUTES           <- {            //Attributes to apply to non-giant players carrying the bomb
                                        "move speed penalty": 0.8
                                        // "self dmg push force decreased": 0.01 //This needs to be applied to all weapons and not the character because this game sucks
                                       }
::MINIMUM_PLAYERS_FOR_BOMB_BUFFS    <- 5            //If there are less than this many players on red, do not apply any conds
::BOMB_CARRIER_TEMP_CONDS_DELAY     <- 10           //Temporary conds will be blocked if a player recently dropped the bomb, this is the delay (seconds) that allows said player to get temp conds again
::GIANT_CAMERA_DURATION             <- 3            //When a player becomes giant, they will enter third person and be unable to move for this long
::GIANT_CAMERA_INVULN_DURATION      <- 5            //When a player becomes giant, they become invincible for this long
::BASE_GIANT_HEALING                <- 1            //Multiply ALL healing received by giant players by this much if player count is at BASE_GIANT_PLAYER_COUNT. Increased or decreased linearly if the amount of players on red is higher or lower than that.
::BASE_GIANT_PLAYER_COUNT           <- 12           //If there are this many players on red team, all giants have their base hp and all healing received is multiplied by BASE_GIANT_HEALING. Increased or decreased linearly if the amount of players on red is higher or lower than that.
::GIANT_SPAWN_PUSH_FORCE            <- 375          //Players near giant robot spawn point will be pushed by this much force shortly before the giant spawns. What's the measurements? idk
::RED_TANK_RESPAWN_TIME             <- 0.1          //Sets red's respawn time, in seconds, while tank is active
::BLUE_TANK_RESPAWN_TIME            <- 3            //Sets blu's respawn time, in seconds, while tank is active
::RED_INTERMISSION_RESPAWN_TIME     <- 0.1          //Sets red's respawn time, in seconds, during intermission
::BLUE_INTERMISSION_RESPAWN_TIME    <- 0.1          //Sets blu's respawn time, in seconds, during intermission
::RED_GIANT_RESPAWN_TIME            <- 3            //Sets red's respawn time, in seconds, while giant is active
::BLUE_GIANT_RESPAWN_TIME           <- 9            //Sets blu's respawn time, in seconds, while giant is active. Overriden by respawnOverride in giant_attributes.nut if set.
::RED_POST_GIANT_RESPAWN_TIME       <- 3            //Sets red's respawn time, in seconds, after giant is dead
::BLUE_POST_GIANT_RESPAWN_TIME      <- 0.1          //Sets blu's respawn time, in seconds, after giant is dead
// ::SMALL_CASH_DROP_AMOUNT            <- 7            //Amount of small cash dropped by the tank when it dies. Size is purely cosmetic
// ::MEDIUM_CASH_DROP_AMOUNT           <- 4            //Amount of medium cash dropped by the tank when it dies. Size is purely cosmetic
// ::LARGE_CASH_DROP_AMOUNT            <- 2            //Amount of large cash dropped by the tank when it dies. Size is purely cosmetic
::CASH_CONDS                        <- {            //Conditions to apply to red players when they pick up cash. Value determines duration (-1: infinite)
                                        [TF_COND_OFFENSEBUFF]               = 5,
                                        [TF_COND_CRITBOOSTED_CTF_CAPTURE]   = 5, //If you remove this, be sure to also change the cond in filter_cash_eligible
                                        [TF_COND_HALLOWEEN_QUICK_HEAL]      = 3
                                       }
::WEARABLE_IDS_TO_REMOVE            <-  {           //Weapons like razorback, booties etc. need to be removed manually when a player becomes giant. This determines the list of weapons to remove manually.
                                            [1101] = "The B.A.S.E. Jumper",
                                            [444] = "The Mantreads",
                                            [133] = "The Gunboats",
                                            [131] = "The Chargin' Targe",
                                            [406] = "The Splendid Screen",
                                            [1099] = "The Tide Turner",
                                            [405] = "Ali Baba's Wee Booties",
                                            [608] = "The Bootlegger",
                                            [57] = "The Razorback",
                                            [231] = "Darwin's Danger Shield",
                                            [642] = "The Cozy Camper",
                                            [1144] = "Festive Targe 2014"
                                        }
::NON_STOCK_MEDIGUN_IDS             <-  { //Needed so that the script knows which medi guns give stock ubercharge and which ones don't
                                            [35] = "The Kritzkrieg",
                                            [411] = "The Quick-Fix",
                                            [998] = "The Vaccinator"
                                        }
::UNREFLECTABLE_PROJECTILES         <-  { //In order to make Giant Pyro's airblast turn everything into crits, the code needs to iterate through every single projectile on the field. This list tells the code which projectiles to not bother with since they either can't crit or can't be reflected
                                            "tf_projectile_energy_ring": null,
                                            "tf_projectile_jar": null,
                                            "tf_projectile_jar_gas": null,
                                            "tf_projectile_jar_milk": null,
                                            "tf_projectile_syringe": null
                                        }
::RED_REANIMATORS                   <-  false //Enables reanimators for red players
::GIANT_ENGINEER_TELE_ENTRANCE_ORIGIN   <- Vector(0,0,-376) //Must be somewhere out of bounds. Used to spawn an indestructible tele entrance

::DEBUG_FORCE_GIANT_TYPE            <- null            //If not null, always chooses this giant ID.


//round states
::STATE_SETUP <- 0
::STATE_PRESPAWN_TANK <- 1 //period before the tank spawns in
::STATE_TANK <- 2 //tank is active
::STATE_INTERMISSION <- 3 //period between tank dying and giant mode/bomb mission starting
::STATE_BOMB <- 4 //Bomb is OUT and READY TO DEPLOY BY PLAYERS

::isBombGiantDead <- false              //Tracks whether or not a blu giant is active

//Find map entities
::startingPathTrack <- Entities.FindByName(null, "tank_path_1")
::customFirstGiantSpawn <- Entities.FindByName(null, "first_giant_spawn")
::customGiantEngineerTeleEntranceMarker <- Entities.FindByName(null, "giant_engineer_tele_hint")
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
    message = "%+attack3% Reject becoming a giant"
})

::hideGiantHudHint <- SpawnEntityFromTable("env_hudhint", {
    targetname = "hide_giant_hud_hint",
    message = "%+reload% Hide giant info"
})

//Keep track of some things
::tank <- null
::bombSpawnOrigin <- startingPathTrack.GetOrigin()
if(customFirstGiantSpawn != null) bombSpawnOrigin = customFirstGiantSpawn.GetOrigin()
if(customGiantEngineerTeleEntranceMarker != null) GIANT_ENGINEER_TELE_ENTRANCE_ORIGIN = customGiantEngineerTeleEntranceMarker.GetOrigin()
::chosenGiantThisRound <- RandomInt(0, GIANT_TYPES_AMOUNT - 1)
::sttRoundState <- STATE_SETUP

//Reanimators don't automatically destroy themselves when the player they're reviving for spawns,
//So we need to keep track of the reanimators each player has
::reanimTable <- {}

//Specifically for giant engineer, keep track of a lot of the special things he has 
::giantEngineerPlayer <- null
::giantEngineerTeleExitOrigin <- null
::giantEngineerTeleExitAngle <- null
::giantEngineerTeleExitParticle <- null

if(DEBUG_FORCE_GIANT_TYPE != null) chosenGiantThisRound = DEBUG_FORCE_GIANT_TYPE

//Misc.
::MaxPlayers <- MaxClients().tointeger()
::MaxWeapons <- 8

IncludeScript("stopthattank2/precaches.nut")
IncludeScript("stopthattank2/custom_boss_bar.nut")
IncludeScript("stopthattank2/giant_kill_responses.nut")
IncludeScript("stopthattank2/intermission.nut")
IncludeScript("stopthattank2/bomb_deploy.nut")
IncludeScript("stopthattank2/bomb.nut")
IncludeScript("stopthattank2/bomb_ubers.nut")
IncludeScript("stopthattank2/overtime_and_bomb_alarm.nut")
IncludeScript("stopthattank2/tank_functions_callbacks.nut")
IncludeScript("stopthattank2/crit_cash.nut")
IncludeScript("stopthattank2/reanimators.nut")
IncludeScript("stopthattank2/blue_robots.nut")
IncludeScript("stopthattank2/giant_mode.nut")
IncludeScript("stopthattank2/giant_attributes.nut")
IncludeScript("stopthattank2/vcd_soundscript.nut")
IncludeScript("stopthattank2/robot_voicelines.nut")
IncludeScript("stopthattank2/spy_disguises.nut")
IncludeScript("stopthattank2/vs_math.nut")

::debugPrint <- function(msg)
{
    if(GetDeveloperLevel() < 1) return
    ClientPrint(null,3,msg)
}

//Set team names
Convars.SetValue("mp_tournament_redteamname", "HUMANS")
Convars.SetValue("mp_tournament_blueteamname", "ROBOTS")

//Function for mapmakers to override base tank health
::overrideBaseTankHealth <- function(health_input)
{
    BASE_TANK_HEALTH = health_input
}

roundTimer.ValidateScriptScope()

//Function for mapmakers to override round time
::overrideRoundTime <- function(seconds, round_type)
{
    switch(round_type) {
        case STATE_SETUP:
            SETUP_LENGTH = seconds
            break
        case STATE_PRESPAWN_TANK:
            POST_SETUP_LENGTH = seconds
            break
        case STATE_INTERMISSION:
            INTERMISSION_LENGTH = seconds
            break
        case STATE_BOMB:
            BOMB_MISSION_LENGTH = seconds
            break
        default:
            break
    }
}

//returns current round state, general use for any other things that could happen at round state
::getSTTRoundState <- function() {
	return sttRoundState
}

::setSTTRoundState <- function(state) {
	sttRoundState = state
}

//Timer finishes 3 times, so we have to know which function we need to call
::callTimerFunction <- function()
{
    debugPrint("\x05Call timer: \x01Executing a function")
	switch(getSTTRoundState()) {
		case STATE_PRESPAWN_TANK:
			spawnTank()
			debugPrint("\x05Call timer: \x01Spawning tank")
			break;
		case STATE_INTERMISSION:
			startGiantMode()
			debugPrint("\x05Call timer: \x01Starting giant mode")
			//Giant camera duration pauses the timer
			//Giant being dead at this point means that theres no blu players
			if(isBombGiantDead) {
				roundTimer.GetScriptScope().currentRoundTime <- BOMB_MISSION_LENGTH
			}
			else {
				roundTimer.GetScriptScope().currentRoundTime <- BOMB_MISSION_LENGTH + GIANT_CAMERA_DURATION
			}
			
			debugPrint("\x05Call timer function: \x01setting current round time to " + (BOMB_MISSION_LENGTH + GIANT_CAMERA_DURATION))
			AddThinkToEnt(roundTimer, null)
			AddThinkToEnt(roundTimer, "countdownThink")
			break;
		case STATE_BOMB:
			redWin.AcceptInput("RoundWin", null, null, null)
			debugPrint("\x05Call timer: \x01Winning red")
			break;
		default:
			break;
	}
}

//Other stuffs we need to do after setup finishes
::handleSetupFinish <- function()
{
    roundTimer.GetScriptScope().currentRoundTime <- POST_SETUP_LENGTH
    AddThinkToEnt(roundTimer, null)
    AddThinkToEnt(roundTimer, "countdownThink")
    setSTTRoundState(STATE_PRESPAWN_TANK)
}

//Round win and loss music has been removed via level_sounds, so we need to replay them
//Red has special music for winning and losing
::handleRedWin <- function()
{
    EntFireByHandle(gamerules, "PlayVORed", "music.mvm_end_wave", -1, null, null)
    EntFireByHandle(gamerules, "PlayVORed", "Announcer.MVM_Final_Wave_End", -1, null, null)
    EntFireByHandle(gamerules, "PlayVOBlue", "STT.YourTeamLost", -1, null, null)
    //Resetting hp is a pain so instead giant hp becomes 50 during humiliation
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_BLUE) continue
        if (!player.GetScriptScope().isGiant) continue
        debugPrint("\x0799CCFFShame on blu giant. Its HP will become 50.")
        player.SetHealth(50)
        player.RemoveCustomAttribute("max health additive bonus")
        break
    }
    AddThinkToEnt(roundTimer, null)
}

::handleBlueWin <- function()
{
    EntFireByHandle(gamerules, "PlayVORed", "music.mvm_lost_wave", -1, null, null)
    EntFireByHandle(gamerules, "PlayVORed", "Announcer.MVM_Game_Over_Loss", -1, null, null)
    EntFireByHandle(gamerules, "PlayVOBlue", "STT.YourTeamWon", -1, null, null)
    AddThinkToEnt(roundTimer, null)
}

//We manually count down our own timer because outputs like On5SecRemain are off by 1 second for some reason
::startCountdownSounds <- function()
{
    //For some reasons onsetupstart is fired during waiting for players phase 
    if(IsInWaitingForPlayers()) return

    roundTimer.ValidateScriptScope()
    local scope = roundTimer.GetScriptScope()
    scope.endTime <- NetProps.GetPropFloat(roundTimer, "m_flTimerEndTime")
    scope.prevEndTime <- 99999
    scope.countdownThink <- function()
    {
        endTime = NetProps.GetPropFloat(roundTimer, "m_flTimerEndTime")

        //Change fl time to i time, these don't tend to be ints
        local realEndTime = floor(endTime - Time())

        //Detect whenever the integer changes
        if(realEndTime != prevEndTime) {
            switch(realEndTime) {
                case 60:
                    playCountdownSound(60)
                    break
                case 30:
                    playCountdownSound(30)
                    break
                case 10:
                    playCountdownSound(10)
                    break
                case 5:
                    playCountdownSound(5)
                    break
                case 4:
                    playCountdownSound(4)
                    break
                case 3:
                    playCountdownSound(3)
                    break
                case 2:
                    playCountdownSound(2)
                    break
                case 1:
                    playCountdownSound(1)
                    break
                default:
                    break
            }
        }

        prevEndTime = realEndTime

        // debugPrint("\x077700FFTime remaining: " + realEndTime.tostring())
        return -1
    }
    AddThinkToEnt(roundTimer, null)
    AddThinkToEnt(roundTimer, "countdownThink")
}

//Handles countdown sounds (e.g. mission ends in 10 seconds!)
::playCountdownSound <- function(secondsRemaining)
{
    //If bomb mission hasnt started yet, all countdown sounds should be mission begins in x seconds
    local prefix = getSTTRoundState() != STATE_BOMB ? "vo/announcer_begins_" : "vo/announcer_ends_"
    gamerules.AcceptInput("PlayVO", prefix + secondsRemaining.tostring() + "sec.mp3", null, null)
    debugPrint("\x07AA44AAPlaying countdown sound for " + secondsRemaining)
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

::playSoundOnePlayer <- function(soundname, player, soundflags=0)
{
    local soundfilter = (soundflags == 4) ? RECIPIENT_FILTER_GLOBAL : RECIPIENT_FILTER_SINGLE_PLAYER
    
    EmitSoundEx({
        sound_name = soundname,
        flags = soundflags,
        origin = player.GetCenter(),
        filter_type = soundfilter,
        entity = player
    })
}

//Must be separated and delayed, or applying attributes wont work
::applyAttributeOnSpawn <- function(attribute, value, duration)
{
    activator.AddCustomAttribute(attribute, value, duration)
}

//Trigger merc voicelines e.g. THE TANK IS DEPLOYING THE BOMB!!
::globalSpeakResponseConcept <- function(p_context, p_response, p_team=TF_TEAM_RED, overrideFlags=" IsMvMDefender:1")
{
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != p_team) continue
        
        EntFireByHandle(player, "AddContext", p_context, -1, null, null)
        EntFireByHandle(player, "SpeakResponseConcept", p_response + overrideFlags, -1, null, null)
        EntFireByHandle(player, "RemoveContext", p_context, 1, null, null)
    }
}

//Do it for one player only
::playerSpeakResponseConcept <- function(p_context, p_response, player, overrideFlags=" IsMvMDefender:1")
{
    EntFireByHandle(player, "AddContext", p_context, -1, null, null)
    EntFireByHandle(player, "SpeakResponseConcept", p_response + overrideFlags, -1, null, null)
    EntFireByHandle(player, "RemoveContext", p_context, 1, null, null)
}

//Handles what responses players should say a few seconds after they spawn
::handleSpawnResponse <- function(player)
{
    if(getSTTRoundState() == STATE_TANK) playerSpeakResponseConcept("ConceptMvMAttackTheTank:1", "TLK_MVM_ATTACK_THE_TANK", player)
    if(getSTTRoundState() == STATE_BOMB && !isBombGiantDead) playerSpeakResponseConcept("ConceptMvMGiantHasBomb:1", "TLK_MVM_GIANT_HAS_BOMB", player)
    if(getSTTRoundState() == STATE_BOMB && isBombGiantDead) playerSpeakResponseConcept("ConceptMvMFirstBombPickup:1", "TLK_MVM_FIRST_BOMB_PICKUP", player)
    if(getSTTRoundState() == STATE_INTERMISSION) playerSpeakResponseConcept("ConceptMvMEncourageMoney:1", "TLK_MVM_ENCOURAGE_MONEY", player)
}

::roundCallbacks <-
{
    Cleanup = function() {
        //Reset HUD type
        NetProps.SetPropInt(gamerules, "m_nHudType", 3)
        NetProps.SetPropBool(gamerules, "m_bPlayingHybrid_CTF_CP", false)

        //Reset round state
		setSTTRoundState(STATE_SETUP)

        //Reroll chosen giant type
        chosenGiantThisRound = RandomInt(0, GIANT_TYPES_AMOUNT - 1)
        if(DEBUG_FORCE_GIANT_TYPE != null) chosenGiantThisRound = DEBUG_FORCE_GIANT_TYPE

        //Cleanup timer countdown think so it doesn't stack
        AddThinkToEnt(roundTimer, null)

        //Reset overtime availability
        SetOvertimeAllowedForCTF(false)

        //Prevent callbacks from stacking
		delete ::roundCallbacks
        
        //Flush out reanim list
        reanimTable.clear()
        addReanimatorThink()

        //Stop keeping track of who the giant engi is because they dont exist anymore
        giantEngineerPlayer = null

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
    }

    OnGameEvent_scorestats_accumulated_update = function(_) {
		if (GetRoundState() == 3) {
			Cleanup()
		}
	}

    OnGameEvent_player_hurt = function(params) {
		local player = GetPlayerFromUserID(params.userid)
        
        //Flash giants when shot during invuln phase
        if (player.GetCustomAttribute("dmg taken increased", 1) != 0.001) return
        player.AddCondEx(5, 0.5, null)
	}

    OnGameEvent_player_spawn = function(params) {
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

            AddThinkToEnt(player, null)
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
            applyAttributeOnSpawn("armor piercing", 75, -1) //750 backstab dmg to giants
        }

        //Red players should say something a few seconds after spawning
        if(params.team == TF_TEAM_RED) EntFireByHandle(player, "RunScriptCode", "handleSpawnResponse(activator)", 4, player, player)

        //Lets players about to become giant reject if they die during intermission
        if(getSTTRoundState() == STATE_INTERMISSION && scope.isBecomingGiant && !(player.entindex() in playersThatHaveRejectedGiant)) promptGiant(player.entindex())

        //Giant engineer: if a teleporter exit is active, teleport all newly spawned blu players
        if(giantEngineerTeleExitOrigin != null && params.team == TF_TEAM_BLUE)
        {
            local playerTeleportOrigin = giantEngineerTeleExitOrigin
            playerTeleportOrigin.z = giantEngineerTeleExitOrigin.z + 18

            player.Teleport(true, playerTeleportOrigin, true, giantEngineerTeleExitAngle, false, Vector(0,0,0))
            player.AddCondEx(57, 1, giantEngineerPlayer)
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

            //If they were top 5, also remove them from the list
            //The player that rejected might not be in top 5 because top 5 all rejected already
            if(player.GetEntityIndex() in eligibleGiantPlayers)
            {
                debugPrint("\x0788BB88They were eligible to be giant, handling leaving case")
                delete eligibleGiantPlayers[player.GetEntityIndex()]
            }

            //Player disconnected when they were prompted to be giant, so toss it to someone else
            if (scope.isBecomingGiant) {
                debugPrint("\x0788BB88They were prompted to be giant, handling leaving case")
                pickRandomPlayerToBeGiant(eligibleGiantPlayers)
            }
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

    OnGameEvent_mvm_tank_destroyed_by_players = function(params) {
        debugPrint("Intermission stuff happening now")
        startIntermission() //Find in intermission.nut

        //Delay the crit cash function to ensure that it happens after the cash entities spawn
        EntFire("gamerules", "CallScriptFunction", "spawnCritCash", -1) //Find in crit_cash.nut

        //Mapmaker decides what else needs to happen using boss_dead_relay

        //Red mercs celebrate with voicelines
        globalSpeakResponseConcept("ConceptMvMTankDead:1", "TLK_MVM_TANK_DEAD")
    }

    OnGameEvent_object_destroyed = function(params) {
        if(giantEngineerPlayer == null) return

        local owner = GetPlayerFromUserID(params.userid)

        //Only execute for giant engis
        if(owner != giantEngineerPlayer) return

        //Check if destroyed object was a teleporter entrance
        if(params.objecttype != 1) return

        local tele = EntIndexToHScript(params.index)

        if(tele.GetName() == "indestructible_tele_entrance") return
            
        stopTeleExit()
    }

    OnGameEvent_object_detonated = function(params) {
        if(giantEngineerPlayer == null) return

        local detonator = GetPlayerFromUserID(params.userid)

        //Only execute for giant engis
        if(detonator != giantEngineerPlayer) return

        //Check if detonated object was a teleporter entrance
        if(params.objecttype != 1) return

        local tele = EntIndexToHScript(params.index)

        if(tele.GetName() != "indestructible_tele_entrance")
        {
            stopTeleExit()
        }

        else
        {
            //UNDO YOU MAY NOT BUILD TELE ENTRANCES
            createIndestructibleTeleEntrance(detonator)
            ClientPrint(detonator, 4, "You may not build teleporter entrance as Giant Engineer; Just build an exit")
        }
        
    }

    OnGameEvent_player_death = function(params) {
        local player = GetPlayerFromUserID(params.userid)
        local killer = GetPlayerFromUserID(params.attacker)
        local scope = player.GetScriptScope()

        //If a red player dies, create reanimators for them
        //CURRENTLY DISABLED because a lot of reanimator aspects are beyond the reach of vscript
        if(player.GetTeam() == TF_TEAM_RED && RED_REANIMATORS) {
            spawnReanim(player, params.userid) //Find in reanimators.nut
        }

        //If a giant killed a red player, have red heavies scream METAL GIANT IS KILLING US
        if(killer != null) { //This nested if setup is so cooked but kinda necessary
            if(killer.IsPlayer()) {

                local killerScope = killer.GetScriptScope()

                if(player.GetTeam() == TF_TEAM_RED && killerScope.isGiant) {
                    globalSpeakResponseConcept("ConceptMvMGiantKilledTeammate:1", "TLK_MVM_GIANT_KILLED_TEAMMATE")
                }

            }
        }

        //Below handles giant death events
        if (!scope.isGiant) return
        handleGiantDeath() //Global events
        if(killer != player && killer.IsAlive() && killer.IsPlayer()) { //Don't say anything if suicide
            speakGiantKillResponse(killer) //Have the killer say something cool, find in giant_kill_responses.nut
        }

        playSoundEx("mvm/sentrybuster/mvm_sentrybuster_explode.wav")

        local deadPlayerName = Convars.GetClientConvarValue("name", player.GetEntityIndex())
        debugPrint("\x01Giant privileges removed on death for player \x0799CCFF" + deadPlayerName)

        player.SetIsMiniBoss(false)

        //Stop being giant
        scope.isGiant = false
    }

    //Whenever a revive starts: force players to remain dead and unable to respawn
    OnGameEvent_revive_player_notify = function(params) {
        local player = EntIndexToHScript(params.entindex)
        local scope = player.GetScriptScope()
        scope.isReviving = true
    }

    //Whenever a revive stops: they may revive is ok
    OnGameEvent_revive_player_stopped = function(params) {
        local player = EntIndexToHScript(params.entindex)
        local scope = player.GetScriptScope()
        scope.isReviving = false
    }

    // OnGameEvent_revive_player_complete = function(params) {
    //     debugPrint("\x074444FFRevive player complete event!")
    // }

    OnGameEvent_player_disconnect = function(params) {
		local player = GetPlayerFromUserID(params.userid)
		local scope = player.GetScriptScope()

        //Disconnected while you have a reanim up? Forget about it
        //The cleanup is automatic so the Kill() is redundant
        if(params.userid in reanimTable) {
            // reanimTable[userid].Kill()
            delete reanimTable[userid]
        }

        //Set of checks for when a jerk disconnects during intermission
        if(getSTTRoundState() == STATE_INTERMISSION) {
            debugPrint("\x0788BB88Some jerk disconnected during intermission")

            //If they were top 5, also remove them from the list
            //The player that rejected might not be in top 5 because top 5 all rejected already
            if(player.GetEntityIndex() in eligibleGiantPlayers)
            {
                debugPrint("\x0788BB88They were eligible to be giant, handling leaving case")
                delete eligibleGiantPlayers[player.GetEntityIndex()]
            }

            //Player disconnected when they were prompted to be giant, so toss it to someone else
            if (scope.isBecomingGiant) {
                debugPrint("\x0788BB88They were prompted to be giant, handling leaving case")
                pickRandomPlayerToBeGiant(eligibleGiantPlayers)
            }
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

debugPrint("Script is hopefully up and running")
__CollectGameEventCallbacks(roundCallbacks)