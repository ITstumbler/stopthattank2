//Allows us to reference constants by name so no need to remember the cringe out-of-order class ID e.g. TF_CLASS_SNIPER = 2
::root <- getroottable();
if (!("ConstantNamingConvention" in root)) // make sure folding is only done once
{
    foreach (a,b in Constants)
        foreach (k,v in b)
            root[k] <- v != null ? v : 0;
}

::SND_STOP <- 4 //flag for emitsoundex

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

if(customGiantEngineerTeleEntranceMarker != null) GIANT_ENGINEER_TELE_ENTRANCE_ORIGIN = customGiantEngineerTeleEntranceMarker.GetOrigin()

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
::bombSpawnOrigin <- customFirstGiantSpawn != null ? customFirstGiantSpawn.GetOrigin() : startingPathTrack.GetOrigin()
::chosenGiantThisRound <- RandomInt(0, GIANT_TYPES_AMOUNT - 1)
::sttRoundState <- STATE_SETUP
::giantPlayer <- null

//Reanimators don't automatically destroy themselves when the player they're reviving for spawns,
//So we need to keep track of the reanimators each player has
::reanimTable <- {}

//Specifically for giant engineer, keep track of a lot of the special things he has 
::giantEngineerTeleExitOrigin <- null
::giantEngineerTeleExitAngle <- null
::giantEngineerTeleExitParticle <- null

if(DEBUG_FORCE_GIANT_TYPE != null) chosenGiantThisRound = DEBUG_FORCE_GIANT_TYPE

//Misc.
::MaxPlayers <- MaxClients().tointeger()
::MaxWeapons <- 8

IncludeScript("stopthattank2/precaches.nut")
IncludeScript("stopthattank2/round_callbacks.nut")
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
IncludeScript("stopthattank2/bonemerge.nut")
IncludeScript("stopthattank2/blue_robots.nut")
IncludeScript("stopthattank2/giant_mode.nut")
IncludeScript("stopthattank2/giant_attributes.nut")
IncludeScript("stopthattank2/vcd_soundscript.nut")
IncludeScript("stopthattank2/robot_voicelines.nut")
IncludeScript("stopthattank2/spy_disguises.nut")
IncludeScript("stopthattank2/model_indexes.nut")
IncludeScript("stopthattank2/game_text_entities.nut")
IncludeScript("stopthattank2/vs_math.nut")

updateGameTexts()

//Setup for stacking thinks
::playerThink <- function() {
	foreach(key, func in thinkFunctions) {
		func()
	}
    return -1
}

function root::debugPrint(msg)
{
    if(GetDeveloperLevel() < 1) return
    ClientPrint(null,3,msg)
}

//Set team names
Convars.SetValue("mp_tournament_redteamname", "HUMANS")
Convars.SetValue("mp_tournament_blueteamname", "ROBOTS")

//Function for mapmakers to override base tank health
function root::overrideBaseTankHealth(health_input)
{
    BASE_TANK_HEALTH = health_input
}

roundTimer.ValidateScriptScope()

//Function for mapmakers to override round time
function root::overrideRoundTime(seconds, round_type)
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
function root::getSTTRoundState() {
	return sttRoundState
}

function root::setSTTRoundState(state) {
	sttRoundState = state
}

//Timer finishes 3 times, so we have to know which function we need to call
function root::callTimerFunction()
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
function root::handleSetupFinish()
{
    roundTimer.GetScriptScope().currentRoundTime <- POST_SETUP_LENGTH
    AddThinkToEnt(roundTimer, "countdownThink")
    setSTTRoundState(STATE_PRESPAWN_TANK)
}

//Round win and loss music has been removed via level_sounds, so we need to replay them
//Red has special music for winning and losing
function root::handleRedWin()
{
    EntFireByHandle(gamerules, "PlayVORed", "music.mvm_end_wave", -1, null, null)
    EntFireByHandle(gamerules, "PlayVORed", "Announcer.MVM_Final_Wave_End", -1, null, null)
    EntFireByHandle(gamerules, "PlayVOBlue", "STT.YourTeamLost", -1, null, null)
    //Resetting hp is a pain so instead giant hp becomes 50 during humiliation
	if(giantPlayer != null) {
		debugPrint("\x0799CCFFShame on blu giant. Its HP will become 50.")
        giantPlayer.SetHealth(50)
        giantPlayer.RemoveCustomAttribute("max health additive bonus")
	}
    AddThinkToEnt(roundTimer, null)
}

function root::handleBlueWin()
{
    EntFireByHandle(gamerules, "PlayVORed", "music.mvm_lost_wave", -1, null, null)
    EntFireByHandle(gamerules, "PlayVORed", "Announcer.MVM_Game_Over_Loss", -1, null, null)
    EntFireByHandle(gamerules, "PlayVOBlue", "STT.YourTeamWon", -1, null, null)
    AddThinkToEnt(roundTimer, null)
}

//We manually count down our own timer because outputs like On5SecRemain are off by 1 second for some reason
function root::startCountdownSounds()
{
    //For some reasons onsetupstart is fired during waiting for players phase 
    if(IsInWaitingForPlayers()) return

    roundTimer.ValidateScriptScope()
    local scope = roundTimer.GetScriptScope()
    scope.prevEndTime <- 99999
    scope.countdownThink <- function()
    {
        //Change fl time to i time, these don't tend to be ints
        local realEndTime = floor(NetProps.GetPropFloat(roundTimer, "m_flTimerEndTime") - Time())

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
    AddThinkToEnt(roundTimer, "countdownThink")
}

//Handles countdown sounds (e.g. mission ends in 10 seconds!)
function root::playCountdownSound(secondsRemaining)
{
    //If bomb mission hasnt started yet, all countdown sounds should be mission begins in x seconds
    local prefix = getSTTRoundState() != STATE_BOMB ? "vo/announcer_begins_" : "vo/announcer_ends_"
    gamerules.AcceptInput("PlayVO", prefix + secondsRemaining.tostring() + "sec.mp3", null, null)
    debugPrint("\x07AA44AAPlaying countdown sound for " + secondsRemaining)
}

function root::playSoundEx(soundname)
{
	local soundTable = {
		sound_name = soundname,
        channel = 6,
        filter_type = RECIPIENT_FILTER_GLOBAL
	}
	
    EmitSoundEx(soundTable)
    EmitSoundEx(soundTable)
}

function root::playSoundOnePlayer(soundname, player, soundflags=0)
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
function root::applyAttributeOnSpawn(attribute, value, duration)
{
    activator.AddCustomAttribute(attribute, value, duration)
}

//Trigger merc voicelines e.g. THE TANK IS DEPLOYING THE BOMB!!
function root::globalSpeakResponseConcept(p_context, p_response, p_team=TF_TEAM_RED, overrideFlags=" IsMvMDefender:1")
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
function root::playerSpeakResponseConcept(p_context, p_response, player, overrideFlags=" IsMvMDefender:1")
{
    EntFireByHandle(player, "AddContext", p_context, -1, null, null)
    EntFireByHandle(player, "SpeakResponseConcept", p_response + overrideFlags, -1, null, null)
    EntFireByHandle(player, "RemoveContext", p_context, 1, null, null)
}

//Handles what responses players should say a few seconds after they spawn
function root::handleSpawnResponse(player)
{
    if(getSTTRoundState() == STATE_TANK) playerSpeakResponseConcept("ConceptMvMAttackTheTank:1", "TLK_MVM_ATTACK_THE_TANK", player)
    if(getSTTRoundState() == STATE_BOMB && !isBombGiantDead) playerSpeakResponseConcept("ConceptMvMGiantHasBomb:1", "TLK_MVM_GIANT_HAS_BOMB", player)
    if(getSTTRoundState() == STATE_BOMB && isBombGiantDead) playerSpeakResponseConcept("ConceptMvMFirstBombPickup:1", "TLK_MVM_FIRST_BOMB_PICKUP", player)
    if(getSTTRoundState() == STATE_INTERMISSION) playerSpeakResponseConcept("ConceptMvMEncourageMoney:1", "TLK_MVM_ENCOURAGE_MONEY", player)
}

//clean up a player from giant eligibility if they disconnected/switched teams
function root::removeInvalidatedPlayer(player)
{
    local scope = player.GetScriptScope()
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

debugPrint("Script is hopefully up and running")