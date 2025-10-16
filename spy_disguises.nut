//It's possible to disguise as a teammate so this complicated check is separated
function root::IsDisguisedAsOpposingTeam(player)
{
    local team = player.GetTeam()
    if(!player.InCond(TF_COND_DISGUISED)) return false
    if(player.GetDisguiseTeam() == team) return false
    return true
}

//Triggered via spawn callbacks in round_setup.nut
::addSpyDisguiseThink <- function(player, team)
{
    local scope = player.GetScriptScope()

    debugPrint("\x04Spy thinks added")

    scope.isDisguised <- false
    
    //Blu spies have human footsteps when disguised, robotic otherwise
    //There are no, and should never be any, giant spies
    //So spies being giant aren't a concern
    if(team == TF_TEAM_BLUE) {
        scope.disguisedFootsteps <- 0
        scope.defaultFootsteps <- 7
        scope.disguiseModelIndex <- HUMAN_PLAYER_MODEL_INDEXES
        scope.defaultModelIndex <- ROBOT_PLAYER_MODEL_INDEXES
    }

    //Red spies have robotic footsteps when disguised, human otherwise
    else {
        scope.disguisedFootsteps <- 7
        scope.defaultFootsteps <- 0
        scope.disguiseModelIndex <- ROBOT_PLAYER_MODEL_INDEXES
        scope.defaultModelIndex <- HUMAN_PLAYER_MODEL_INDEXES
    }

    scope.spyDisguiseThink <- function()
    {
        //Remove think on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            delete thinkFunctions["spyDisguiseThink"]
        }

        //Run if we just disguised as an enemy
        if(IsDisguisedAsOpposingTeam(self) && !isDisguised) {
            isDisguised = true
            self.AddCustomAttribute("override footstep sound set", disguisedFootsteps, -1)

            //Override the "romevision" model that the enemy team will see
            local DisguiseClass = NetProps.GetPropInt(player,"m_Shared.m_nDisguiseClass")
            NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", disguiseModelIndex[DisguiseClass], 3);
        }

        //Run if we just undisguised
        else if(!IsDisguisedAsOpposingTeam(self) && isDisguised) {
            isDisguised = false
            self.AddCustomAttribute("override footstep sound set", defaultFootsteps, -1)

            //Reset the "romevision" model that the enemy team will see
            local DisguiseClass = NetProps.GetPropInt(player,"m_Shared.m_nDisguiseClass")
            NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", defaultModelIndex[DisguiseClass], 3);
        }

        return -1
    }

    scope.thinkFunctions["spyDisguiseThink"] <- scope.spyDisguiseThink
}