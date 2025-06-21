function Think()
{
    local scene = null
    while (scene = Entities.FindByClassname(scene, "instanced_scripted_scene")) //Reponse rules make my head spin
    {
        local owner = NetProps.GetPropEntity(scene, "m_hOwner")
        //Nest so that it doesnt try to IsPlayer null
        if (owner != null)
		{
            if (owner.IsPlayer())
            {
                //Blue team OR disguised red spy
                //Find IsDisguisedAsOpposingTeam in robot_voicelines.nut
                if ((owner.GetTeam() == TF_TEAM_BLUE && !IsDisguisedAsOpposingTeam(owner)) || (owner.GetPlayerClass() == TF_CLASS_SPY && IsDisguisedAsOpposingTeam(owner) && owner.GetTeam() == TF_TEAM_RED))
                {
                    owner.AddCustomAttribute("voice pitch scale", 0.0, -1.0) //Mute voicelines and play our own
                    debugPrint("\x04Replacing voiceline")
                    ReplaceVoiceline(owner, scene)
                }
                else
                {
                    owner.RemoveCustomAttribute("voice pitch scale")
                }
            }
		}
        scene.KeyValueFromString("classname", "_scene")
    }
    return -1
}