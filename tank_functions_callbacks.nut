function root::spawnTank()
{
    //Make sure tank hologram is called tank_hologram!!
    tankHologram.AcceptInput("Disable", null, null, null)

    local redPlayerCount = 0
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != TF_TEAM_RED) continue
        redPlayerCount += 1
    }

    local tankHealth = BASE_TANK_HEALTH / BASE_TANK_PLAYER_COUNT.tofloat()
    tankHealth = (tankHealth * redPlayerCount) / 2
    
    //Why is nobody on red? Tank gets 1000 hp as consolation prize
    if(tankHealth == 0) {
        tankHealth = 1000
        debugPrint("\x05NOBODY is on red? Tank HP is now " + tankHealth)
    }

    tank = SpawnEntityFromTable("tank_boss", {
        targetname = "tank",
        TeamNum = TF_TEAM_BLUE,
        speed = TANK_SPEED,
        angles = startingPathTrack.GetAbsAngles(),
        health = tankHealth,
        model = "models/bots/boss_bot/boss_tank.mdl"
	})

    SetBossEntity(tank)
	UpdateBossBarLeaderboardIcon(leaderboard.tank)

    //We need to make everyone see romevision for spy disguises, so the tank needs to be un-romevision'd
    NetProps.SetPropIntArray(tank, "m_nModelIndexOverrides", GetModelIndex("models/bots/boss_bot/boss_tank.mdl"), 3);

    //Ty tankextensions
    for(local hChild = tank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
    {
        local sChildModel = hChild.GetModelName().tolower()
        local childModelIndex = null
        if((sChildModel.find("track_l"))) {
            childModelIndex = GetModelIndex("models/bots/boss_bot/tank_track_l.mdl")
        }
        else if((sChildModel.find("track_r"))) {
            childModelIndex = GetModelIndex("models/bots/boss_bot/tank_track_r.mdl")
        }
        else if((sChildModel.find("bomb_mechanism"))) {
            childModelIndex = GetModelIndex("models/bots/boss_bot/bomb_mechanism.mdl")
        }

        if(childModelIndex != null) NetProps.SetPropIntArray(hChild, "m_nModelIndexOverrides", childModelIndex, 3);
    }

    //Allow tank to be instantly destroyed by anyone when debugging
    if(GetDeveloperLevel() >= 1) {
        tank.SetHealth(1)
        tank.SetTeam(4)
        debugPrint("\x07FF3333DEBUGGING: \x01Tank set to 1 HP and neutral team")
    }

    tank.SetAbsOrigin(startingPathTrack.GetOrigin())

    local tank_glow = SpawnEntityFromTable("tf_glow", {
        GlowColor = "125 168 196 255",
        Mode = 2,
        target = "tank",
        targetname = "tank_glow"
    })

    trainWatcherDummy.AcceptInput("SetSpeedDir", "1", null, null)
    trainWatcherDummy.KeyValueFromInt("startspeed", TANK_SPEED)

    //No round timer during tank phase, we'll need it again once the tank dies
    //Refer to startIntermission in intermission.nut
    roundTimer.AcceptInput("Disable", null, null, null)

    //Update team respawn times
    gamerules.AcceptInput("SetRedTeamRespawnWaveTime", RED_TANK_RESPAWN_TIME.tostring(), null, null)
    gamerules.AcceptInput("SetBlueTeamRespawnWaveTime", BLUE_TANK_RESPAWN_TIME.tostring(), null, null)

    //Mark phase change to be used by other parts of the script
    setSTTRoundState(STATE_TANK)

    //Have red mercs yell about the tank
    globalSpeakResponseConcept("ConceptMvMTankCallout:1", "TLK_MVM_TANK_CALLOUT IsMvMDefender:1")

    //Need anything else to happen? Put it in here
    EntFire("boss_spawn_relay", "trigger")
}

//Input TANK_SPEED as speedInput to reset its speed
function root::setSpeedTank(speedInput, dummyOnly=false)
{
    //Intermission is happening and the command isnt to stop, ignore all previous instructions
    if(getSTTRoundState() == STATE_INTERMISSION && speedInput != 0) return
    trainWatcherDummy.AcceptInput("SetSpeedDir", speedInput.tostring(), null, null)
    trainWatcherDummy.KeyValueFromInt("startspeed", speedInput)
    if(tank.IsValid() && !dummyOnly) tank.AcceptInput("SetSpeed", speedInput.tostring(), null, null)
}

// ::totalTankDistance <- 0

// ::calculateTankDistance <- function() {
//     local currentPathTrack = startingPathTrack
//     local nextPathTrack = NetProps.GetPropEntity(currentPathTrack, "m_pnext")

//     while(nextPathTrack) {

//         nextPathTrack = NetProps.GetPropEntity(currentPathTrack, "m_pnext")
//     }
// }

