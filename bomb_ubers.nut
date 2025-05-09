::addBombUberThink <- function(medic)
{
    local scope = medic.GetScriptScope()

    debugPrint("\x04Thinks added?")

    scope.uberedBombCarrier <- null
    scope.lastBombUberTime <- null
    scope.bombUberThink <- function()
    {
        //Remove think on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            AddThinkToEnt(self, null)
            NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
        }

        //Don't think if the bomb is not out yet
        if(getSTTRoundState() != STATE_BOMB) {
            debugPrint("\x04Not bomb round, don't do anything")
            return -1
        }

        local healTarget = self.GetHealTarget()

        //If ubered target gets near hatch, say no
        if(healTarget != null) {
            if(healTarget.GetScriptScope().isCarryingBombInAlarmZone)
            {
                healTarget.RemoveCond(57)
                ClientPrint(medic, 1, "Bomb carriers cannot be Ubercharged near hatch")
                ClientPrint(healTarget, 1, "Bomb carriers cannot be Ubercharged near hatch")
                return -1
            }
        }

        //If medic is not ubered, or not healing anyone, or healing someone else other than bomb carrier,
        //make sure the bomb carrier isnt ubered if we have ubered them before
        if(healTarget == null || !self.InCond(5)) {
            debugPrint("\x04Medic is not healing, or not ubercharged")
            //If heal target doesnt have bomb, no special treatment needed, but...
            //If they WERE the bomb carrier, and dropped the bomb while ubered, forget them as the ubered bomb carrier
            if(!healTarget.HasItem()) {
                debugPrint("\x04Heal target does not have bomb")
                if(healTarget == uberedBombCarrier) uberedBombCarrier = null
                return -1
            }
            if(uberedBombCarrier == null) return -1
            
            //Remember when the uber beam was disconnected
            if(lastBombUberTime == null) {
                //Flashing uber effect
                uberedBombCarrier.AddCondEx(8, 1, self)
                lastBombUberTime = Time()
            }

            //If 1s has passed after beam has been disconnected, make their uber disappear
            if(lastBombUberTime != null) {
                uberedBombCarrier.RemoveCond(57)
                uberedBombCarrier.RemoveCond(8)
                lastBombUberTime = null
                uberedBombCarrier = null
            }

            return -1
        }

        debugPrint("\x04Checking if ubered bomb carrier is null")
        if(uberedBombCarrier == null) {
            debugPrint("\x04Doing stuff to uber bomb carrier")
            //If bomb carrier is currently near hatch, say no 
            if(healTarget.GetScriptScope().isCarryingBombInAlarmZone) {
                ClientPrint(medic, 1, "Bomb carriers cannot be Ubercharged near hatch")
                ClientPrint(healTarget, 1, "Bomb carriers cannot be Ubercharged near hatch")
                return -1
            }
            //Bomb carriers normally can't get ubered, so we forcefully make them shiny
            healTarget.AddCondEx(57, -1, self)

            //Were they flashing? un-flash them
            healTarget.RemoveCond(8)
            lastBombUberTime = null
            uberedBombCarrier = healTarget
        }

        return -1
    }

    AddThinkToEnt(medic, null)
    AddThinkToEnt(medic, "bombUberThink")
}