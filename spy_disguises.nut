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
    }

    //Red spies have robotic footsteps when disguised, human otherwise
    else {
        scope.disguisedFootsteps <- 0
        scope.defaultFootsteps <- 7
    }

    scope.spyDisguiseThink <- function()
    {
        //Remove think on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            delete thinkFunctions["spyDisguiseThink"]
        }

        if(self.InCond(TF_COND_DISGUISED) && !isDisguised) {
            isDisguised = true
            self.AddCustomAttribute("override footstep sound set", disguisedFootsteps, -1)
        }

        else if(!self.InCond(TF_COND_DISGUISED) && isDisguised) {
            isDisguised = false
            self.AddCustomAttribute("override footstep sound set", defaultFootsteps, -1)
        }

        return -1
    }

    scope.thinkFunctions["spyDisguiseThink"] <- scope.spyDisguiseThink
}