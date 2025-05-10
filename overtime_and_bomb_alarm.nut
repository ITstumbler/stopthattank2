::startControlPointAlarm <- function()
{
    SetOvertimeAllowedForCTF(true)
    EntFire("control_point_alarm*", "PlaySound") //Easier to do this for looping sounds
    debugPrint("\x07CCFFAAStarting control point alarm, allowing overtime")
}

::stopControlPointAlarm <- function()
{
    SetOvertimeAllowedForCTF(false)
    EntFire("control_point_alarm*", "StopSound") //Two ambient generics so asterisks are used to target both of them
    debugPrint("\x07CCFFAAStopping control point alarm, disallowing overtime")
}

::startBombAlarm <- function()
{
    SetOvertimeAllowedForCTF(true)
    SetMannVsMachineAlarmStatus(true) //Needed to make alarm go weewoo and administrator to scream at red
    debugPrint("\x07CCFFAAStarting hatch alarm, allowing overtime")
    // debugPrint("\x07CCFFAAActivator: " + activator.GetClassname())

    
    //Mark the bomb carrier near alarm zone as ineligible for ubercharge
    local scope = activator.GetScriptScope()
    scope.isCarryingBombInAlarmZone = true
}

::stopBombAlarm <- function()
{
    SetOvertimeAllowedForCTF(false)
    SetMannVsMachineAlarmStatus(false)
    debugPrint("\x07CCFFAAStopping hatch alarm, disallowing overtime")

    //For god knows why the activator for stop touch is the flagdetectionzone itself and not the player for god knows why
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (!player.HasItem()) continue
        local scope = player.GetScriptScope()
        scope.isCarryingBombInAlarmZone = false
        ClientPrint(player, 3, "\x07CCFFAAFound the bomb carrier, marking the thingy as false")
        break
    }
}