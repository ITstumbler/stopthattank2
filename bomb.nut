::applyBombCarrierProperties <- function()
{
    //Don't apply these to giants!!
    local scope = activator.GetScriptScope()
    if ("isGiant" in scope) return
    
    //Check if player is eligible for temporary conds
    local timePickedUp = Time()
    local eligibleForTempConds = true
    if ("lastBombDropTime" in scope) {
        if((scope.lastBombDropTime - Time()) < BOMB_CARRIER_TEMP_CONDS_DELAY) {
            //Did the player drop the bomb very recently? They're not getting those temp conds again.
            eligibleForTempConds = false
        }
    }

    //Apply all bomb carrier conds
    foreach(condition, duration in BOMB_CARRIER_CONDS)
    {
        if(duration != -1 && !eligibleForTempConds) continue //Blocks temp conds from getting re-applied if ineligible (see above)
        activator.AddCondEx(condition, duration, null)
    }

    //Apply all bomb carrier atributes
    foreach(attribute, value in BOMB_CARRIER_ATTRIBUTES)
    {
        activator.AddCustomAttribute(attribute, value, -1)
    }
}

::removeBombCarrierProperties <- function()
{
    //If player is giant, revoke their giant privileges
    local scope = activator.GetScriptScope()
    if ("isGiant" in scope) {
        delete scope.isGiant
        return
    }
    
    //Remove all bomb carrier conds
    foreach(condition, duration in BOMB_CARRIER_CONDS)
    {
        activator.RemoveCondEx(condition, true)
    }

    //Remove all bomb carrier attributes
    foreach(attribute, value in BOMB_CARRIER_ATTRIBUTES)
    {
        activator.RemoveCustomAttribute(attribute)
    }

    //Update when the player last dropped the bomb, to check if they're eligible for temporary conds (see above)
    scope.lastBombDropTime <- Time()
}

::resetBombOrigin <- function()
{
    //Bomb reset because blue left it on the ground for too long
    //This function resets it to the nearest captured point 
    bombFlag.SetAbsOrigin(bombSpawnOrigin)
}