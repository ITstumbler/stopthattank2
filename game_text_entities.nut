function root::setGameTextMessage(gameTextEntity, newText)
{
    gameTextEntity.AcceptInput("AddOutput", "message " + newText, null, null)
}

function root::updateGameTexts()
{
    setGameTextMessage(gameText_becomingAGiant, "You are about to become a giant!\n" + giantProperties[chosenGiantThisRound].giantName.toupper() + "\nYou will transform once the timer ends")
    setGameTextMessage(gameText_receivingAGiant, "Receiving a giant!\n" + giantProperties[chosenGiantThisRound].giantName.toupper() + "\nA teammate will transform once the timer ends")
    setGameTextMessage(gameText_giantDetails, "Transformed into a " + giantProperties[chosenGiantThisRound].giantName.toupper() + "\n" + giantProperties[chosenGiantThisRound].playerInfo)
}

//You are about to become a giant!
//<GIANT NAME IN ALL CAPS>
//You will transform once the timer ends

::gameText_becomingAGiant <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_becomingAGiant",
    color1 = "255 255 255",
    color2 = "255 255 255",
    effect = "2",
    fadein = "0.02",
    fadeout = "5",
    holdtime = "5",
    fxtime = "10",
    channel = "1",
    x = "-1",
    y = "0.1",
    message = "Test"
})

//Receiving a giant!
//<GIANT NAME IN ALL CAPS>
//A teammate will transform once the timer ends

::gameText_receivingAGiant <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_receivingAGiant",
    color1 = "255 255 255",
    color2 = "255 255 255",
    effect = "2",
    fadein = "0.02",
    fadeout = "5",
    holdtime = "5",
    fxtime = "10",
    channel = "1",
    x = "-1",
    y = "0.1",
    message = "Test"
})

//<GIANT NAME IN ALL CAPS>
//<GIANT TIP>

::gameText_giantDetails <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_giantDetails",
    color1 = "255 255 255",
    color2 = "255 255 255",
    effect = "2",
    fadein = "0.02",
    fadeout = "5",
    holdtime = "5",
    fxtime = "10",
    channel = "1",
    x = "-1",
    y = "0.3",
    message = "Test"
})

//WARNING: GIANT ROBOT INCOMING

::gameText_giantWarning <- SpawnEntityFromTable("game_text", {
    targetname = "gameText_giantWarning",
    color1 = "255 220 220",
    color2 = "255 255 255",
    effect = "2",
    fadein = "0.02",
    fadeout = "5",
    holdtime = "5",
    fxtime = "10",
    channel = "1",
    x = "-1",
    y = "0.1",
    message = "WARNING: GIANT ROBOT INCOMING"
})