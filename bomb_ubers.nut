function root::addBombUberThink(medic)
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
            delete thinkFunctions.bombUberThink
        }

        //Don't think if the bomb is not out yet
        if(getSTTRoundState() != STATE_BOMB) {
            // debugPrint("\x04Not bomb round, don't do anything")
            return
        }
		
		//only update medigun when we need to (it was destroyed at whatever point)
		if(!medigun.IsValid()) {
			for(local i = 0; i < NetProps.GetPropArraySize(self, "m_hMyWeapons"); i++) {
				local wep = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
			
				if(wep && wep.GetClassname() == "tf_weapon_medigun") {
					medigun = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i);
					break;
				}
			}
		}
		
        local medigunType = NetProps.GetPropInt(medigun, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

        //If medi gun does not provide stock ubercharge, don't bother
        //Think is NOT removed because medics can switch medi guns mid life via picking up dropped ones
        if(medigunType in NON_STOCK_MEDIGUN_IDS) {
            return
        }

        local healTarget = self.GetHealTarget()
		local healTargetScope = healTarget != null ? healTarget.GetScriptScope() : null
        
        if(healTarget != null) {
            //If ubered target gets near hatch, say no
            if(healTargetScope.isCarryingBombInAlarmZone)
            {
                healTarget.RemoveCond(TF_COND_INVULNERABLE_CARD_EFFECT)
                healTarget.RemoveCond(TF_COND_INVULNERABLE_WEARINGOFF)
                ClientPrint(medic, 4, "Bomb carriers cannot be Ubercharged near hatch")
                ClientPrint(healTarget, 4, "Bomb carriers cannot be Ubercharged near hatch")
                return
            }
            //If ubered target is a giant without a bomb (because dropped while ubered), disconnect the heal beam so that the giant can pick it up
            if(!healTarget.HasItem() && healTargetScope.isGiant) {
                // debugPrint("\x07FF2222GIANT WITHOUT BOMB IS BEING HEALED, DISCONNECTING BEAM RN")
				// NetProps.SetPropEntity(medigun, "m_hHealingTarget", null);
				healTarget.RemoveCondEx(TF_COND_INVULNERABLE, true)
            }
        }

        isUbercharged = NetProps.GetPropBool(medigun, "m_bChargeRelease") && self.InCond(TF_COND_INVULNERABLE)

        //If medic is not ubered, or not healing anyone, or healing someone else other than bomb carrier,
        //make sure the bomb carrier isnt ubered if we have ubered them before
        if(healTarget != null && !isUbercharged) {
            //debugPrint("\x04Medic is not healing, or not ubercharged")
            //If heal target doesnt have bomb, no special treatment needed, but...
            //If they WERE the bomb carrier, and dropped the bomb while ubered, forget them as the ubered bomb carrier
            if(!healTarget.HasItem()) {
                //debugPrint("\x04Heal target does not have bomb")
                //If they were a giant, refuse to get ubercharged until they picked up the bomb again
                if(healTargetScope.isGiant && uberedBombCarrier != null) { //this is possibly redundant with the above?
                    uberedBombCarrier.RemoveCond(TF_COND_INVULNERABLE)
                }
                if(healTarget == uberedBombCarrier) {
                    uberedBombCarrier.RemoveCond(TF_COND_INVULNERABLE_CARD_EFFECT)
                    uberedBombCarrier.RemoveCond(TF_COND_INVULNERABLE_WEARINGOFF)
                    uberedBombCarrier = null
                }
                return
            }
        }

        if(healTarget == null || !isUbercharged) {
            if(uberedBombCarrier == null) return
            
            //Remember when the uber beam was disconnected
            if(lastBombUberTime == null) {
                //Flashing uber effect
                uberedBombCarrier.AddCondEx(TF_COND_INVULNERABLE_WEARINGOFF, 1, self)
                lastBombUberTime = Time() + 1
            }

            //If 1s has passed after beam has been disconnected, make their uber disappear
            if(Time() >= lastBombUberTime) {
                uberedBombCarrier.RemoveCond(TF_COND_INVULNERABLE_CARD_EFFECT)
                uberedBombCarrier.RemoveCond(TF_COND_INVULNERABLE_WEARINGOFF)
                lastBombUberTime = null
                uberedBombCarrier = null
            }
            return
        }
        
        //debugPrint("\x04Checking if ubered bomb carrier is null")
        if(uberedBombCarrier == null) {
            //debugPrint("\x04Doing stuff to uber bomb carrier")
            //If bomb carrier is currently near hatch, say no 
            if(healTargetScope.isCarryingBombInAlarmZone) {
                ClientPrint(medic, 4, "Bomb carriers cannot be Ubercharged near hatch")
                ClientPrint(healTarget, 4, "Bomb carriers cannot be Ubercharged near hatch")
                return
            }
            //Bomb carriers normally can't get ubered, so we forcefully make them shiny
            healTarget.AddCondEx(TF_COND_INVULNERABLE_CARD_EFFECT, -1, self)

            //Were they flashing? un-flash them
            healTarget.RemoveCond(TF_COND_INVULNERABLE_WEARINGOFF)
            lastBombUberTime = null
            uberedBombCarrier = healTarget
        }
        return
    }

    scope.thinkFunctions.bombUberThink <- scope.bombUberThink
}