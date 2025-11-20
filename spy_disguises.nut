//It's possible to disguise as a teammate so this complicated check is separated
//Defined differently so that global_think_functions can access this
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

    // scope.isDisguised <- false
    scope.lastDisguiseClass <- 0
    scope.lastDisguiseTeam <- false
    scope.disguiseClass <- 0
    
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
        //Remove think on death or if not spy
        if(NetProps.GetPropInt(self, "m_lifeState") != 0 || self.GetPlayerClass() != TF_CLASS_SPY) {
            delete thinkFunctions.spyDisguiseThink
            return -1
        }

        disguiseClass = NetProps.GetPropInt(player,"m_Shared.m_nDisguiseClass")

        //Run if we just disguised as an enemy
        if(IsDisguisedAsOpposingTeam(self) && (disguiseClass != lastDisguiseClass || IsDisguisedAsOpposingTeam(self) != lastDisguiseTeam)) {
            self.AddCustomAttribute("override footstep sound set", disguisedFootsteps, -1)

            //Override the "romevision" model that the enemy team will see
            
            if(self.GetTeam() == TF_TEAM_BLUE) {
                NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", disguiseModelIndex[disguiseClass], 3);
            }
        }

        //Run if we just undisguised
        else if(!IsDisguisedAsOpposingTeam(self) || (disguiseClass != lastDisguiseClass || IsDisguisedAsOpposingTeam(self) != lastDisguiseTeam)) {
            self.AddCustomAttribute("override footstep sound set", defaultFootsteps, -1)

            //Reset the "romevision" model that the enemy team will see
            if(self.GetTeam() == TF_TEAM_BLUE) {
                if(disguiseClass == 0) {
                    NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", defaultModelIndex[TF_CLASS_SPY], 3);
                }
                else {
                    NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", defaultModelIndex[disguiseClass], 3);
                }
            }
        }

        lastDisguiseClass = disguiseClass
        lastDisguiseTeam = IsDisguisedAsOpposingTeam(self)

        return -1
    }

    scope.thinkFunctions["spyDisguiseThink"] <- scope.spyDisguiseThink
}