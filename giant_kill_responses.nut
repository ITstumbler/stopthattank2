//This list is so fat I decided to separate it into another file
::GIANT_KILL_RESPONSES <- {}
::GIANT_KILL_RESPONSES[TF_CLASS_SCOUT]      <-  {
                                                    [0] = "vo/scout_autocappedcontrolpoint03.mp3",
                                                    [1] = "vo/scout_autocappedcontrolpoint04.mp3",
                                                    [2] = "vo/scout_autocappedintelligence03.mp3",
                                                    [3] = "vo/scout_award11.mp3",
                                                    [4] = "vo/scout_award12.mp3",
                                                    [5] = "vo/scout_cheers02.mp3",
                                                    [6] = "vo/scout_domination06.mp3",
                                                    [7] = "vo/scout_domination08.mp3",
                                                    [8] = "vo/scout_domination14.mp3",
                                                    [9] = "vo/scout_domination19.mp3",
                                                    [10] = "vo/taunts/scout_taunts02.mp3",
                                                    [11] = "vo/taunts/scout_taunts18.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_SOLDIER]    <-  {
                                                    [0] = "vo/soldier_autocappedcontrolpoint01.mp3",
                                                    [1] = "vo/soldier_autocappedintelligence02.mp3",
                                                    [2] = "vo/soldier_dominationmedic03.mp3",
                                                    [3] = "vo/soldier_laughhappy03.mp3",
                                                    [4] = "vo/soldier_mvm_taunt05.mp3",
                                                    [5] = "vo/soldier_mvm_wave_end04.mp3",
                                                    [6] = "vo/taunts/soldier_taunts07.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_PYRO]       <-  {
                                                    [0] = "vo/pyro_autocappedcontrolpoint01.mp3",
                                                    [1] = "vo/taunts/pyro/pyro_taunt_ballon_11.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_DEMOMAN]    <-  {
                                                    [0] = "vo/demoman_autocappedintelligence01.mp3",
                                                    [1] = "vo/demoman_specialcompleted12.mp3",
                                                    [2] = "vo/demoman_laughlong01.mp3",
                                                    [3] = "vo/demoman_laughevil03.mp3",
                                                    [4] = "vo/taunts/demoman_taunts08.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_HEAVYWEAPONS]   <-  {
                                                    [0] = "vo/taunts/heavy_taunts02.mp3",
                                                    [1] = "vo/taunts/heavy_taunts12.mp3",
                                                    [2] = "vo/heavy_award08.mp3",
                                                    [3] = "vo/heavy_award09.mp3",
                                                    [4] = "vo/heavy_laughlong01.mp3",
                                                    [5] = "vo/heavy_laughterbig04.mp3",
                                                    [6] = "vo/heavy_mvm_giant_robot02.mp3",
                                                    [7] = "vo/heavy_revenge13.mp3",
                                                    [8] = "vo/heavy_specialcompleted11.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_ENGINEER]   <-  {
                                                    [0] = "vo/engineer_dominationspy10.mp3",
                                                    [1] = "vo/engineer_autocappedcontrolpoint01.mp3",
                                                    [2] = "vo/engineer_autocappedintelligence01.mp3",
                                                    [3] = "vo/engineer_revenge01.mp3",
                                                    [4] = "vo/engineer_revenge02.mp3",
                                                    [5] = "vo/engineer_laughlong02.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_MEDIC]      <-  {
                                                    [0] = "vo/medic_autocappedcontrolpoint03.mp3",
                                                    [1] = "vo/medic_laughlong01.mp3",
                                                    [2] = "vo/medic_laughlong02.mp3",
                                                    [3] = "vo/medic_laughhappy03.mp3",
                                                    [4] = "vo/medic_mvm_giant_robot02.mp3",
                                                    [5] = "vo/medic_sf13_influx_big03.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_SNIPER]     <-  {
                                                    [0] = "vo/sniper_autocappedcontrolpoint02.mp3",
                                                    [1] = "vo/sniper_award12.mp3",
                                                    [2] = "vo/sniper_dominationheavy05.mp3",
                                                    [3] = "vo/sniper_laughlong01.mp3",
                                                    [4] = "vo/sniper_laughlong02.mp3",
                                                    [5] = "vo/taunts/sniper_taunts21.mp3"
                                                }
::GIANT_KILL_RESPONSES[TF_CLASS_SPY]        <-  {
                                                    [0] = "vo/spy_laughevil01.mp3",
                                                    [1] = "vo/spy_laughevil02.mp3",
                                                    [2] = "vo/spy_revenge03.mp3",
                                                    [3] = "vo/taunts/spy_taunts15.mp3",
                                                    [4] = "vo/taunts/spy/spy_taunt_rps_win_11.mp3"
                                                }

function root::speakGiantKillResponse(player)
{
    local playerClass = player.GetPlayerClass()
    local soundListLen = GIANT_KILL_RESPONSES[playerClass].len()
    local soundIndex = RandomInt(0, soundListLen - 1)
    playSoundOnePlayer(GIANT_KILL_RESPONSES[playerClass][soundIndex], player)
} 