function root::spawnCritCash()
{
    debugPrint("\x07CC8888Attempting to spawn crit cash triggers")
    //Iterate through all the cash entities
    local currencyEnt = null
	while(currencyEnt = Entities.FindByClassname(currencyEnt, "item_currencypack_*"))
	{
		//Cash cannot be picked up and can only be collected through trigger 
		currencyEnt.SetTeam(4)

		//Iterate through them more easily later
		//Theyre not props but they used to be and i dont want to change it idk
		NetProps.SetPropString(currencyEnt, "m_iName", "crit_cash_prop")
	}

    //Iterate again - we'll add triggers next
    //This is delayed so that the cash is on the ground before red can pick them up
    EntFire("gamerules", "CallScriptFunction", "addCritCashTriggers", 3)
}

function root::addCritCashTriggers()
{
    local currencyEnt = null
    while(currencyEnt = Entities.FindByName(currencyEnt, "crit_cash_prop"))
    {
        //We'll need to set the bounding box size for the triggers
        local triggerSize = Vector(12, 12, 12)

        //The crit cash model is intangible to players
        //We'll parent a trigger that does everything when a player touches it
        //This is done so that the same player cant pick up crit cash while still crit boosted from one
        local spawnedCashTrigger = SpawnEntityFromTable("trigger_multiple", {
            targetname = "crit_cash_trigger",
            spawnflags = 1,
            origin = currencyEnt.GetOrigin(),
            filtername = "filter_cash_eligible_red",
            StartDisabled = 0
        })
        spawnedCashTrigger.SetSize(triggerSize * -1, triggerSize)
        spawnedCashTrigger.SetSolid(2) // SOLID_BBOX

        //Parent the trigger to the ammo pack
        spawnedCashTrigger.AcceptInput("SetParent", "!activator", currencyEnt, currencyEnt)

        //Now we need the trigger to do something when an eligible player touches it
        EntityOutputs.AddOutput(spawnedCashTrigger, "OnStartTouch", "!activator", "CallScriptFunction", "giveCritCashBuffs", -1, -1)
        
        //Also the cash piles should vaporize themselves when triggered
        EntityOutputs.AddOutput(spawnedCashTrigger, "OnStartTouch", "!self", "CallScriptFunction", "killCash", -1, -1)
    }
}

function root::giveCritCashBuffs()
{
    //Apply all cash buff conds
    foreach(condition, duration in CASH_CONDS)
    {
        activator.AddCondEx(condition, duration, null)
    }

    //Restore all ammo but dont restore all health
    local playerHealthOnPickup = activator.GetHealth()
    activator.Regenerate(true)
    activator.SetHealth(playerHealthOnPickup)

    //Money pickup voiceline
    playerSpeakResponseConcept("ConceptMvMMoneyPickup:1", "TLK_MVM_MONEY_PICKUP", activator)

    //For red medics: give them projectile shield for 5 seconds
    if(activator.GetPlayerClass() != TF_CLASS_MEDIC) return

    activator.AddCustomAttribute("generate rage on heal", 1, 5)
    NetProps.SetPropFloat(activator, "m_Shared.m_flRageMeter", 50.0)
    NetProps.SetPropBool(activator, "m_Shared.m_bRageDraining", true)

    //The projectile shield will need to be spawned manually if our medic has their medi gun out
    local scope = activator.GetScriptScope()

	//this should probably be removed
	if(!("medigun" in scope)) {
		scope.medigun <- null
	}
    
    for(local i = 0; i < NetProps.GetPropArraySize(activator, "m_hMyWeapons"); i++) {
        local wep = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i)
    
        if(wep && wep.GetClassname() == "tf_weapon_medigun") {
            scope.medigun = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i);
            break;
        }
    }

    if(scope.medigun == null) return
    if(activator.GetActiveWeapon() != scope.medigun) return

    if(scope.projShield != null && scope.projShield.IsValid()) {
        return
    }
	
	//projshield is placed into scope when player first connects
    scope.projShield = SpawnEntityFromTable("entity_medigun_shield", {
        //targetname = "shield"
        teamnum = activator.GetTeam()
        skin = activator.GetTeam() == TF_TEAM_RED ? 0 : 1
    })
    projShield.SetOwner(activator)

    //A think is needed to despawn our spawned shield if medic switches away from medi gun
    scope.projShieldThink <- function()
    {
        //Remove think on death
        if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
            delete thinkFunctions.projShieldThink
        }

        if(self.GetActiveWeapon() == medigun) return

        if(!projShield.IsValid()) return

        projShield.Destroy()
        delete thinkFunctions.projShieldThink
    }
    scope.thinkFunctions.projShieldThink <- scope.projShieldThink

    playerSpeakResponseConcept("ConceptMvMDeployRage:1", "TLK_MVM_DEPLOY_RAGE", activator)
}

//We gotta murder the trigger's parent as well
//For now lets try making the cash collectible and teleporting it to the collector
function root::killCash()
{
    local cashEnt = self.GetMoveParent()
    self.Kill()
    cashEnt.SetTeam(TF_TEAM_RED)
    // cashEnt.Kill()
}

// ::blinkCash <- function()
// {
//     debugPrint("\x0744AAAABLINKING CASH")
//     local currencyEnt = null
//     while(currencyEnt = Entities.FindByName(currencyEnt, "crit_cash_prop"))
//     {
//         currencyEnt.AcceptInput("AddOutput", "renderfx 2", null, null)
//     }
//     EntFire("gamerules", "CallScriptFunction", "expireCash", 5)
// }

function root::expireCash()
{
    debugPrint("\x0744AAAAKILLING CASH")
    local currencyEnt = null
    while(currencyEnt = Entities.FindByName(currencyEnt, "crit_cash_prop"))
    {
        DispatchParticleEffect("mvm_cash_explosion", currencyEnt.GetOrigin(), Vector())
        currencyEnt.Kill()
    }
}