PrecacheSound("mvm/mvm_deploy_giant.wav")
PrecacheSound("mvm/mvm_deploy_small.wav")

function root::tryDeployBomb()
{
    if(!activator.HasItem()) return
    activator.EndLongTaunt()
    activator.CancelTaunt()
    activator.SetForcedTauntCam(1)
	NetProps.SetPropInt(activator, "m_nRenderMode", kRenderNone)
	activator.AddCustomAttribute("move speed penalty", 0.000000001, -1)
	
	local fakePlayer = SpawnEntityFromTable("prop_dynamic",
	{
		targetname = "playerdeployprop",
		origin = activator.GetOrigin(),
		angles = activator.GetAbsAngles(),
		disablebonefollowers = 1,
		model = activator.GetModelName(),
		skin = 1,
		defaultanim = "primary_deploybomb"
	})
	if(activator.GetScriptScope().isGiant)
	{
		fakePlayer.SetModelScale(1.75, 0)
	}
	
	local fakeFlag = SpawnEntityFromTable("prop_dynamic",
	{
		targetname = "bombdeployprop",
	})
	fakeFlag.SetModel("models/props_td/atom_bomb.mdl")
	fakeFlag.AcceptInput("SetParent", "playerdeployprop", null, null)
	EntFireByHandle(fakeFlag, "SetParentAttachment", "flag", 0.02, null, null)
	
	bombFlag.AcceptInput("Disable", null, null, null) //hide the light
	for(local wearable = activator.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
	{	
		NetProps.SetPropInt(wearable, "m_nRenderMode", kRenderNone)
		
		local name = wearable.GetClassname()
		if(name == "item_teamflag" || startswith(name, "tf_weapon") || name == "tf_viewmodel") continue
		
		local dummyWearable = SpawnEntityFromTable("prop_dynamic_ornament",
		{
			initialowner = "playerdeployprop",
			model = wearable.GetModelName(),
			skin = wearable.GetSkin()
			//todo: figure out body groups
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
	
	local sound = activator.GetScriptScope().isGiant ? "mvm/mvm_deploy_giant.wav" : "mvm/mvm_deploy_small.wav"
	EmitSoundEx(
	{
		sound_name = sound,
		filter_type = RECIPIENT_FILTER_GLOBAL,
		entity = activator
	})
	
    activator.GetScriptScope().isDeploying <- true
    EntFire("finish_deploy_relay", "trigger", null, 0, activator) //calls finishDeployBomb
    debugPrint("ATTEMPTING TO DEPLOY")
}

function root::stopDeployBomb() //called by capture trigger onendtouch
{
    if(!activator.HasItem()) return
	activator.SetForcedTauntCam(0)
	NetProps.SetPropInt(activator, "m_nRenderMode", kRenderNormal)
	activator.RemoveCustomAttribute("move speed penalty")
	for(local wearable = activator.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
	{
		NetProps.SetPropInt(wearable, "m_nRenderMode", kRenderNormal)
	}	
	bombFlag.AcceptInput("Enable", null, null, null)
	EntFire("playerdeployprop", "Kill")
	
    activator.GetScriptScope().isDeploying = false
    debugPrint("STOP DEPLOYING")
    EntFire("finish_deploy_relay", "CancelPending")
}

function root::finishDeployBomb()
{
    debugPrint("ATTEMPTING TO FINISH")
    if(!activator.HasItem()) {
        debugPrint("ACTIVATOR DOES NOT HAVE ITEM, CANCELLING FINISH")
        return
    }
    if(!activator.GetScriptScope().isDeploying) {
        debugPrint("ACTIVATOR IS NOT DEPLOYING, CANCELLING FINISH")
        return
    }
	EntFire("playerdeployprop", "Kill")
    EntFire("bomb_deploy_relay", "trigger") //hatch blows up and other stuff
    //Disable countdown sounds
    AddThinkToEnt(roundTimer, null)
    
    //Remove the persisting no rocket jump attribute
    for (local i = 0; i < MaxWeapons; i++)
	{
		local weapon = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i)
		if (weapon == null)
			continue
		weapon.RemoveAttribute("self dmg push force decreased") //This needs to be applied to WEAPONS and not the players??? Garbage game
	}
}