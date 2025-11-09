//adapted from popextensions
function root::bonemergeBotModel(player)
{
	local scope = player.GetScriptScope()
	local model = scope.botModelName
	
	if("bonemergeModel" in scope && scope.bonemergeModel && scope.bonemergeModel.IsValid())
	{
		scope.bonemergeModel.Kill()
	}
	
	local wearable = Entities.CreateByClassname("tf_wearable")
	NetProps.SetPropString(wearable, "m_iName", "bonemerge_model")
	NetProps.SetPropInt(wearable, "m_nModelIndex", PrecacheModel(model))
	NetProps.SetPropBool(wearable, "m_bValidatedAttachedEntity", true)
	NetProps.SetPropEntity(wearable, "m_hOwnerEntity", player)
	wearable.SetTeam(player.GetTeam())
	wearable.SetOwner(player)
	Entities.DispatchSpawn(wearable)
	NetProps.SetPropBool(wearable, "m_bForcePurgeFixedupStrings", true)
	EntFireByHandle(wearable, "SetParent", "!activator", -1, player, player)
	NetProps.SetPropInt(wearable, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL)
	scope.bonemergeModel <- wearable
	
	NetProps.SetPropInt(player, "m_nRenderMode", kRenderTransColor)
	NetProps.SetPropInt(player, "m_clrRender", 0)
	
	function bonemergeThink()
	{
		if(bonemergeModel.IsValid() && (self.IsTaunting() || bonemergeModel.GetMoveParent() != self))
		{
			bonemergeModel.AcceptInput("SetParent", "!activator", self, self)
		}
	}
	scope.thinkFunctions.bonemergeThink <- bonemergeThink
}

function root::removeBonemergeModel(player)
{
	local scope = player.GetScriptScope()
	if("bonemergeModel" in scope && scope.bonemergeModel && scope.bonemergeModel.IsValid())
	{
		scope.bonemergeModel.Kill()
		scope.bonemergeModel = null
	}
	NetProps.SetPropInt(player, "m_nRenderMode", kRenderNormal)
	NetProps.SetPropInt(player, "m_clrRender", 0xFFFFFF)
}