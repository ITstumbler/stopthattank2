::spawnTank <- function()
{
    //Timer finishes three times in our current setup, let's ensure that tank only spawns on the first one
    if(isIntermissionHappening || isBombMissionHappening) return

    //Make sure tank hologram is called tank_hologram!!
    tankHologram.AcceptInput("Disable", null, null, null)

    tank = SpawnEntityFromTable("tank_boss", {
        targetname = "tank",
        TeamNum = 4,
        speed = TANK_SPEED,
        angles = startingPathTrack.GetAbsAngles(),
        health = 1,
        model = "models/bots/boss_bot/boss_tank.mdl"
	})

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
}

//Input TANK_SPEED as speedInput to reset its speed
::setSpeedTank <- function(speedInput, dummyOnly=false)
{
    //Intermission is happening and the command isnt to stop, ignore all previous instructions
    if(isIntermissionHappening && speedInput != 0) return
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

