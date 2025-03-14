::spawnCritCash <- function()
{
    //First, delete all existing cash entities so we can spawn in our own
    local currencyPackClassnames = ["item_currencypack_small", "item_currencypack_medium", "item_currencypack_large", "item_currencypack_custom"]
    local currencyEnt = null
    for(local i = 0; i < currencyPackClassnames.len(); i++)
    {
        currencyEnt = null
        while(currencyEnt = Entities.FindByClassname(currencyEnt, currencyPackClassnames[i]))
        {
            currencyEnt.Kill()
        }
    }

    //Now we get the origin where the tank died - we do this by finding the origin of the train watcher dummy 
    local tankDiedOrigin = trainWatcherDummy.GetOrigin()
    
    local cashSpawned = 0
    local totalCashAmountToSpawn = SMALL_CASH_DROP_AMOUNT + MEDIUM_CASH_DROP_AMOUNT + LARGE_CASH_DROP_AMOUNT

    while(cashSpawned < totalCashAmountToSpawn)
    {
        //Set the cash model based on the amount desired to spawn
        //We'll need to set the bounding box size for the triggers
        local cashModel = "models/items/currencypack_small.mdl"
        local triggerSize = Vector(24, 24, 32)
        if (cashSpawned >= MEDIUM_CASH_DROP_AMOUNT && cashSpawned < LARGE_CASH_DROP_AMOUNT)
        {
            cashModel = "models/items/currencypack_medium.mdl"
            triggerSize = Vector(32, 32, 32)
        }
        else if (cashSpawned >= LARGE_CASH_DROP_AMOUNT)
        {
            cashModel = "models/items/currencypack_large.mdl"
            triggerSize = Vector(48, 48, 48)
        }

        //Create the crit cash entity
        local spawnedCashEnt = SpawnEntityFromTable("tf_ammo_pack", {
            targetname = "crit_cash_prop",
            origin = tankDiedOrigin,
            TeamNum = 5,
            model = cashModel
        })

        //The crit cash model is intangible to players
        //We'll parent a trigger that does everything when a player touches it
        //This is done so that the same player cant pick up crit cash while still crit boosted from one
         local spawnedCashTrigger = SpawnEntityFromTable("trigger_multiple", {
            targetname = "crit_cash_trigger",
            spawnflags = 1,
            origin = tankDiedOrigin,
            filtername = filter_cash_eligible_red,
            StartDisabled = 1 //In mvm, money can't be picked up mid-air (some exceptions incl. instantly collecting tank money if you stand on top of it, but w/e)
        })
        spawnedCashTrigger.SetSize(triggerSize * -1, triggerSize)
        spawnedCashTrigger.SetSolid(2) // SOLID_BBOX

        //Parent the trigger to the ammo pack
        spawnedCashTrigger.AcceptInput("SetParent", "!activator", spawnedCashEnt, spawnedCashEnt)

        //Now we need the trigger to do something when an eligible player touches it
        EntityOutputs.AddOutput(spawnedCashTrigger, "OnStartTouch", "!activator", "CallScriptFunction", "giveCritCashBuffs", -1, -1)
        
        //Also the cash piles should unalive themselves when triggered
        EntityOutputs.AddOutput(spawnedCashTrigger, "OnStartTouch", "!self", "CallScriptFunction", "killCash", -1, -1)

        //Money will only be able to be picked up 2s after it spawns so that it has time to drop to the ground
        //This isn't fully faithful to mvm (see above for one major exception) but simplest to implement + probably healthy for pvp
        EntFireByHandle(spawnedCashTrigger, "Enable", null, 2, null, null)

        //Cash explode in random directions when a tank blows up, let's simulate that
        //First we'll decide what direction the cash will blow up to
        impulseVecX = RandomFloat(-1, 1)
        impulseVecY = RandomFloat(-1, 1)
        impulseVecZ = RandomFloat(5, 20)

        //Normalize to get the angles we want to launch the cash to
        impulseVec = Vector(impulseVecX, impulseVecY, impulseVecZ)
        impulseVec.Norm()

        //Now we decide the speed that we launch the cash with
        impulseVec = impulseVec * 250 * RandomFloat(1, 4)

        //And now we launch those money piles!!
        spawnedCashEnt.ApplyAbsVelocityImpulse(impulseVec)

        //TODO: make custom models for cash with built-in particles so that we dont have to worry about attaching them via vscript (pain)

        cashSpawned++
    }
}

::giveCritCashBuffs <- function()
{
    //Apply all cash buff conds
    foreach(condition, duration in CASH_CONDS)
    {
        activator.AddCondEx(condition, duration, null)
    }
}

//We gotta murder the trigger's parent as well (the cash prop)
::killCash <- function()
{
    local cashEnt = self.GetParent()
    self.Kill()
    cashEnt.Kill()
}

::blinkCash <- function()
{
    local currencyEnt = null
    while(currencyEnt = Entities.FindByName(currencyEnt, "crit_cash_prop"))
    {
        currencyEnt.AcceptInput("AddOutput", "renderfx 2", null, null)
    }
    EntFire("gamerules", "CallScriptFunction", "expireCash", 5)
}

::expireCash <- function()
{
    local currencyEnt = null
    while(currencyEnt = Entities.FindByName(currencyEnt, "crit_cash_prop"))
    {
        DispatchParticleEffect("mvm_cash_explosion", currencyEnt.GetOrigin(), Vector())
        currencyEnt.Kill()
    }
}