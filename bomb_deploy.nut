PrecacheSound("mvm/mvm_deploy_giant.wav")
PrecacheSound("mvm/mvm_deploy_small.wav")

function root::tryDeployBomb()
{
    if(!activator.HasItem()) return
	
	local scope = activator.GetScriptScope()
	
    activator.EndLongTaunt()
    activator.CancelTaunt()
    activator.SetForcedTauntCam(1)
    activator.AddCustomAttribute("move speed penalty", 0.000000001, -1)
	
    EmitSoundEx(
    {
        sound_name = scope.isGiant ? "mvm/mvm_deploy_giant.wav" : "mvm/mvm_deploy_small.wav",
        filter_type = RECIPIENT_FILTER_GLOBAL,
        entity = activator
    })
	
    scope.isDeploying = true
    EntFire("finish_deploy_relay", "trigger", null, 0, activator) //calls finishDeployBomb
    debugPrint("ATTEMPTING TO DEPLOY")
    //TODO: add some impulse or something to push players during the animation
	
    //no fake prop for these two
    if(activator.GetPlayerClass() == TF_CLASS_ENGINEER || activator.GetPlayerClass() == TF_CLASS_SPY)
    {
        return
    }
	
    NetProps.SetPropInt(activator, "m_nRenderMode", kRenderNone)
	
    local modelString = CLASSNAMES[activator.GetPlayerClass()]
    if(activator.GetPlayerClass() != TF_CLASS_MEDIC)
    {
        modelString = scope.isGiant ? modelString + "_boss" : modelString
    }
    modelString = format("models/bots/%s/bot_%s.mdl", modelString, modelString)

    local fakePlayer = SpawnEntityFromTable("prop_dynamic",
    {
        targetname = "playerdeployprop",
        origin = activator.GetOrigin(),
        angles = activator.GetAbsAngles(),
        disablebonefollowers = 1,
        model = modelString,
        skin = 1,
        defaultanim = "primary_deploybomb"
    })
    if(scope.isGiant)
	{
        fakePlayer.SetModelScale(1.75, 0)
    }
	
    bombFlag.AcceptInput("SetParent", "playerdeployprop", null, null)
    EntFireByHandle(bombFlag, "SetParentAttachment", "flag", 0.02, null, null)
    for(local wearable = activator.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
    {	
        local name = wearable.GetClassname()
        if(name == "item_teamflag") continue //don't make bomb invis
		
        NetProps.SetPropInt(wearable, "m_nRenderMode", kRenderNone)
		
        if(startswith(name, "tf_weapon") || name == "tf_viewmodel") continue
        if(name == "env_spritetrail") continue //Demoknight charge particle
		
        local dummyWearable = SpawnEntityFromTable("prop_dynamic_ornament",
        {
            initialowner = "playerdeployprop",
            model = wearable.GetModelName(),
            skin = wearable.GetSkin()
            //todo: body groups are an itemattr
		})
		/*
		local id = NetProps.GetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
		
		local weapon = Entities.CreateByClassname("tf_weapon_parachute")
		NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1101)
		NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
		weapon.SetTeam(activator.GetTeam())
		weapon.DispatchSpawn()
		NetProps.SetPropEntity(weapon, "m_hOwner", fakePlayer)
		local dummyWearable = NetProps.GetPropEntity(weapon, "m_hExtraWearable")
		weapon.Kill()
		
		NetProps.SetPropInt(dummyWearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", id)
		NetProps.SetPropBool(dummyWearable, "m_AttributeManager.m_Item.m_bInitialized", true)
		NetProps.SetPropBool(dummyWearable, "m_bValidatedAttachedEntity", true)
		dummyWearable.DispatchSpawn()
		//dummyWearable.AcceptInput("SetParent", "playerdeployprop", null, null)
		*/
	}
}

function root::stopDeployBomb() //called by capture trigger onendtouch
{
    if(!activator.GetScriptScope().isDeploying) return
    activator.SetForcedTauntCam(0)
    activator.RemoveCustomAttribute("move speed penalty")

    debugPrint("STOP DEPLOYING")	
    activator.GetScriptScope().isDeploying = false
    EntFire("finish_deploy_relay", "CancelPending")
	
    if(activator.GetPlayerClass() == TF_CLASS_ENGINEER || activator.GetPlayerClass() == TF_CLASS_SPY)
    {
        return
    }
	
    NetProps.SetPropInt(activator, "m_nRenderMode", kRenderNormal)
    for(local wearable = activator.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
    {
        NetProps.SetPropInt(wearable, "m_nRenderMode", kRenderNormal)
    }	
    bombFlag.AcceptInput("ClearParent", "", null, null)
    EntFire("playerdeployprop", "Kill")
}

function root::finishDeployBomb()
{
	local scope = activator.GetScriptScope()
    debugPrint("ATTEMPTING TO FINISH")
    if(!scope.isDeploying) {
        debugPrint("ACTIVATOR IS NOT DEPLOYING, CANCELLING FINISH")
        return
    }
	
    scope.isDeploying = false
    scope.isGiant = false
    EntFire("bomb_deploy_relay", "trigger") //hatch blows up and other stuff
    //Disable countdown sounds
    AddThinkToEnt(roundTimer, null)
	
    if(activator.GetPlayerClass() == TF_CLASS_ENGINEER || activator.GetPlayerClass() == TF_CLASS_SPY)
    {
        return
    }
	
    bombFlag.AcceptInput("ClearParent", "", null, null)
    bombFlag.AcceptInput("Disable", "", null, null)
    NetProps.SetPropInt(activator, "m_nRenderMode", kRenderNormal)
    EntFire("playerdeployprop", "Kill")
    
    //TODO: is this necessary?
    //Remove the persisting no rocket jump attribute
    for (local i = 0; i < MaxWeapons; i++)
	{
		local weapon = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i)
		if (weapon == null)
			continue
		weapon.RemoveAttribute("self dmg push force decreased") //This needs to be applied to WEAPONS and not the players??? Garbage game
	}
}