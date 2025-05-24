::addBombUberThink <- function(medic)
{
    local scope = medic.GetScriptScope()

    debugPrint("\x04Thinks added?")

    scope.uberedBombCarrier <- null
    scope.lastBombUberTime <- null

    scope.medigun <- null
    scope.isUbercharged <- false

    scope.bombUberThink <- function()
    {
        //Remove think on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            delete thinkFunctions["bombUberThink"]
        }

        //Don't think if the bomb is not out yet
        if(getSTTRoundState() != STATE_BOMB) {
            // debugPrint("\x04Not bomb round, don't do anything")
            return -1
        }

        for(local i = 0; i < NetProps.GetPropArraySize(self, "m_hMyWeapons"); i++) {
            local wep = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
        
            if(wep && wep.GetClassname() == "tf_weapon_medigun") {
                scope.medigun = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i);
                break;
            }
        }

        local medigunType = NetProps.GetPropInt(medigun, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

        //If medi gun does not provide stock ubercharge, don't bother
        //Think is NOT removed because medics can switch medi guns mid life via picking up dropped ones
        if(medigunType in NON_STOCK_MEDIGUN_IDS) {
            return -1
        }

        local healTarget = self.GetHealTarget()
        
        if(healTarget != null) {
            //If ubered target gets near hatch, say no
            if(healTarget.GetScriptScope().isCarryingBombInAlarmZone)
            {
                healTarget.RemoveCond(57)
                healTarget.RemoveCond(8)
                ClientPrint(medic, 4, "Bomb carriers cannot be Ubercharged near hatch")
                ClientPrint(healTarget, 4, "Bomb carriers cannot be Ubercharged near hatch")
                return -1
            }
            //If ubered target is a giant without a bomb (because dropped while ubered), disconnect the heal beam so that the giant can pick it up
            if(!healTarget.HasItem() && healTarget.GetScriptScope().isGiant) {
                // debugPrint("\x07FF2222GIANT WITHOUT BOMB IS BEING HEALED, DISCONNECTING BEAM RN")
                if(medigun.IsValid()) {
                    // NetProps.SetPropEntity(medigun, "m_hHealingTarget", null);
                    healTarget.RemoveCondEx(5, true)
                }
                return -1
            }
        }

        isUbercharged = NetProps.GetPropBool(medigun, "m_bChargeRelease") && self.InCond(5)

        //If medic is not ubered, or not healing anyone, or healing someone else other than bomb carrier,
        //make sure the bomb carrier isnt ubered if we have ubered them before
        if(healTarget != null && !isUbercharged) {
            //debugPrint("\x04Medic is not healing, or not ubercharged")
            //If heal target doesnt have bomb, no special treatment needed, but...
            //If they WERE the bomb carrier, and dropped the bomb while ubered, forget them as the ubered bomb carrier
            if(!healTarget.HasItem()) {
                //debugPrint("\x04Heal target does not have bomb")
                //If they were a giant, refuse to get ubercharged until they picked up the bomb again
                if(healTarget.GetScriptScope().isGiant && uberedBombCarrier != null) {
                    uberedBombCarrier.RemoveCond(5)
                }
                if(healTarget == uberedBombCarrier) {
                    uberedBombCarrier.RemoveCond(57)
                    uberedBombCarrier.RemoveCond(8)
                    uberedBombCarrier = null
                } 
                
                return -1
            }
        }

        if(healTarget == null || !isUbercharged) {
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
        

        //debugPrint("\x04Checking if ubered bomb carrier is null")
        if(uberedBombCarrier == null) {
            //debugPrint("\x04Doing stuff to uber bomb carrier")
            //If bomb carrier is currently near hatch, say no 
            if(healTarget.GetScriptScope().isCarryingBombInAlarmZone) {
                ClientPrint(medic, 4, "Bomb carriers cannot be Ubercharged near hatch")
                ClientPrint(healTarget, 4, "Bomb carriers cannot be Ubercharged near hatch")
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

    scope.thinkFunctions["bombUberThink"] <- scope.bombUberThink
}