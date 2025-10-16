function root::setGameTextMessage(gameTextEntity, newText)
{
    gameTextEntity.AcceptInput("AddOutput", "message " + newText, null, null)
}

function root::updateGameTexts()
{
    setGameTextMessage(gameText_becomingAGiant, "You are about to become a giant!\n" + giantProperties[chosenGiantThisRound].giantName.upper() + "\nYou will transform once the timer ends")
    setGameTextMessage(gameText_receivingAGiant, "Receiving a giant!\n" + giantProperties[chosenGiantThisRound].giantName.upper() + "\nA teammate will transform once the timer ends")
    setGameTextMessage(gameText_giantDetails, "Transformed into a" + giantProperties[chosenGiantThisRound].giantName.upper() + "\n" + giantProperties[chosenGiantThisRound].playerInfo)
}

//You are about to become a giant!
//<GIANT NAME IN ALL CAPS>
//You will transform once the timer ends

::gameText_becomingAGiant <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_becomingAGiant",
    color1 = "220 220 220",
    color2 = "170 170 170",
    effect = "2",
    fadein = "0.35",
    fadeout = "0.35",
    holdtime = "10",
    fxtime = "0.35",
    channel = "1",
    x = "-1",
    y = "0.8",
    message = "Test"
})

//Receiving a giant!
//<GIANT NAME IN ALL CAPS>
//A teammate will transform once the timer ends

::gameText_receivingAGiant <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_receivingAGiant",
    color1 = "220 220 220",
    color2 = "170 170 170",
    effect = "2",
    fadein = "0.35",
    fadeout = "0.35",
    holdtime = "10",
    fxtime = "0.35",
    channel = "1",
    x = "-1",
    y = "0.8",
    message = "Test"
})

//<GIANT NAME IN ALL CAPS>
//<GIANT TIP>

::gameText_giantDetails <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_giantDetails",
    color1 = "220 220 220",
    color2 = "170 170 170",
    effect = "2",
    fadein = "0.35",
    fadeout = "0.35",
    holdtime = "6",
    fxtime = "0.35",
    channel = "1",
    x = "-1",
    y = "0.8",
    message = "Test"
})

//WARNING: GIANT ROBOT INCOMING

::gameText_giantWarning <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_giantWarning",
    color1 = "220 220 220",
    color2 = "170 170 170",
    effect = "2",
    fadein = "0.35",
    fadeout = "0.35",
    holdtime = "10",
    fxtime = "0.35",
    channel = "1",
    x = "-1",
    y = "0.8",
    message = "WARNING: GIANT ROBOT INCOMING"
})