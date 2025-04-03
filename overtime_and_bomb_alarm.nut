::startControlPointAlarm <- function()
{
    SetOvertimeAllowedForCTF(true)
    EntFire("control_point_alarm*", "PlaySound") //Easier to do this for looping sounds
}

::stopControlPointAlarm <- function()
{
    SetOvertimeAllowedForCTF(true)
    EntFire("control_point_alarm*", "StopSound") //Two ambient generics so asterisks are used to target both of them
}

::startBombAlarm <- function()
{
    SetOvertimeAllowedForCTF(true)
    SetMannVsMachineAlarmStatus(true) //Needed to make alarm go weewoo and administrator to scream at red
}

::stopBombAlarm <- function()
{
    SetOvertimeAllowedForCTF(false)
    SetMannVsMachineAlarmStatus(false)
}