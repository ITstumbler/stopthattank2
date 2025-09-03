function root::tryDeployBomb()
{
    if(!activator.HasItem()) return
    activator.EndLongTaunt()
    activator.CancelTaunt()
    activator.SetForcedTauntCam(1)
    activator.Taunt(0, 0)
    activator.GetScriptScope().isDeploying <- true
    EntFire("finish_deploy_relay", "trigger", null, 0, activator)
    debugPrint("ATTEMPTING TO DEPLOY")
}

function root::stopDeployBomb()
{
    if(!activator.HasItem()) return
	activator.SetForcedTauntCam(0)
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
    EntFire("bomb_deploy_relay", "trigger")
    //Disable countdown sounds
    AddThinkToEnt(roundTimer, null)
    bombFlag.AcceptInput("Disable", null, null, null)

    //Remove the persisting no rocket jump attribute
    for (local i = 0; i < MaxWeapons; i++)
	{
		local weapon = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i)
		if (weapon == null)
			continue
		weapon.RemoveAttribute("self dmg push force decreased") //This needs to be applied to WEAPONS and not the players??? Garbage game
	}
}