::ReplaceVoiceline <- function(player, scene)
{
    local name = null
    local vcdpath  = NetProps.GetPropString(scene, "m_szInstanceFilename")
    if (vcdpath)
    {
        for (local i = vcdpath.len() - 1, endindex = null; i >= 0; --i)
        {
            if (vcdpath[i] == 46) // '.'
                endindex = i
            else if (vcdpath[i] == 47 && endindex) // '/'
            {
                name = vcdpath.slice(i + 1, endindex);
                break
            }
        }
    }

    if(name == null)
        return

    local voicelineClass = player.GetPlayerClass()
    if((player.GetPlayerClass() == TF_CLASS_SPY) && (player.InCond(TF_COND_DISGUISED))) voicelineClass = NetProps.GetPropInt(player,"m_Shared.m_nDisguiseClass")

    debugPrint("\x05Voiceline name: " + name)

    if(!(name in VCDToSoundscriptList[voicelineClass])) {
        debugPrint("\x07FF4444Voiceline not in soundscript list")
        return
    }

    debugPrint("\x05Voiceline to play: " + VCDToSoundscriptList[voicelineClass][name])
    
    EntFireByHandle(player, "RunScriptCode", "PlayRobotVoiceline(activator,`" + VCDToSoundscriptList[voicelineClass][name] + "`)", 0.02, player, player)
}

//It's possible to disguise as a teammate so this complicated check is separated
::IsDisguisedAsOpposingTeam <- function(player)
{
    local team = player.GetTeam()
    if(!player.InCond(TF_COND_DISGUISED)) return false
    if(player.GetDisguiseTeam() == team) return false
    return true
}

::PlayRobotVoiceline <- function(player, name)
{
    //Ty popext from potato.tf once again
    local dotindex =  name.find( "." )
    if ( dotindex == null ) return
    local soundName = name.slice( 0, dotindex+1 ) + "MVM_" + name.slice( dotindex+1 )

    if(player.IsMiniBoss())
    {
        EmitSoundEx({
            sound_name = soundName,
            origin = player.GetCenter(),
            flags = 2,
            pitch = 70,
            speaker_entity = player,
            entity = player,
        })
    }

    else {
        debugPrint("\x05Attempting to emit sound " + soundName)
        player.EmitSound(soundName)
    }
}