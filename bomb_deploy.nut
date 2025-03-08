::tryDeployBomb <- function()
{
    debugPrint("Trying to")
    if(!activator.HasItem()) return
    activator.EndLongTaunt()
    activator.CancelTaunt()
    activator.SetForcedTauntCam(1)
    activator.Taunt(0, 0)
    local scope = activator.GetScriptScope()
    scope.isDeploying <- true
    EntFire("finish_deploy_relay", "trigger", null, 0, activator)
    debugPrint("ATTEMPTING TO DEPLOY")
}

::stopDeployBomb <- function()
{
    if(!activator.HasItem()) return
    local scope = activator.GetScriptScope()
    scope.isDeploying = false
    debugPrint("STOP DEPLOYING")
    EntFire("finish_deploy_relay", "CancelPending")
    activator.SetForcedTauntCam(0)
}

::finishDeployBomb <- function()
{
    debugPrint("ATTEMPTING TO FINISH")
    if(!activator.HasItem()) {
        debugPrint("ACTIVATOR DOES NOT HAVE ITEM, CANCELLING FINISH")
        return
    }
    local scope = activator.GetScriptScope()
    if(!(scope.isDeploying)) {
        debugPrint("ACTIVATOR IS NOT DEPLOYING, CANCELLING FINISH")
        return
    }
    EntFire("bomb_deploy_relay", "trigger")
    bombFlag.AcceptInput("Disable", null, null, null)
}