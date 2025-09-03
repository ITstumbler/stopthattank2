function root::ReplaceVoiceline(player, scene)
{
    local name = null
    local vcdpath = NetProps.GetPropString(scene, "m_szInstanceFilename")
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

    // debugPrint("\x05Voiceline name: " + name)

    if(!(name in VCDToSoundscriptList[voicelineClass])) {
        // debugPrint("\x07FF4444Voiceline not in soundscript list")
        return
    }

    //Special exception for red spies disguised as blu spies
    if((player.GetPlayerClass() == TF_CLASS_SPY) && player.GetTeam() == TF_TEAM_RED && IsDisguisedAsOpposingTeam(player) && (NetProps.GetPropInt(player,"m_Shared.m_nDisguiseClass") == TF_CLASS_SPY)) {
        local scope = player.GetScriptScope()
        local timeSinceLastResponse = Time() - scope.lastResponseTime
        if(timeSinceLastResponse <= 0.5) {
            return
        }
        else {
            scope.lastResponseTime = Time()
        }
    }

    // debugPrint("\x05Voiceline to play: " + VCDToSoundscriptList[voicelineClass][name])
    
    EntFireByHandle(player, "RunScriptCode", "PlayRobotVoiceline(activator,`" + VCDToSoundscriptList[voicelineClass][name] + "`)", 0.02, player, player)
}

//It's possible to disguise as a teammate so this complicated check is separated
function root::IsDisguisedAsOpposingTeam(player)
{
    local team = player.GetTeam()
    if(!player.InCond(TF_COND_DISGUISED)) return false
    if(player.GetDisguiseTeam() == team) return false
    return true
}

function root::PlayRobotVoiceline(player, name)
{
    //Ty popext from potato.tf once again
    local dotindex =  name.find( "." )
    if ( dotindex == null ) return
    local soundName = name.slice( 0, dotindex+1 ) + "MVM_" + name.slice( dotindex+1 )
    local playerClass = player.GetPlayerClass()

    if(player.IsMiniBoss())
    {
        if(playerClass == TF_CLASS_SCOUT || playerClass == TF_CLASS_SOLDIER || playerClass == TF_CLASS_PYRO || playerClass == TF_CLASS_DEMOMAN || playerClass == TF_CLASS_HEAVYWEAPONS) {
            //Scout, Soldier, Pyro, Demoman and Heavy have proper giant voicelines, let's refer to that
            soundName = name.slice( 0, dotindex+1 ) + "M_MVM_" + name.slice( dotindex+1 )
            player.EmitSound(soundName)
        }
        else {
            //The other 4 classes should just speak with lower pitch
            EmitSoundEx({
                sound_name = soundName,
                origin = player.GetCenter(),
                flags = 2,
                pitch = 70,
                speaker_entity = player,
                entity = player,
            })
        }
        
    }
    else {
        // debugPrint("\x05Attempting to emit sound " + soundName)
        player.EmitSound(soundName)
    }
}