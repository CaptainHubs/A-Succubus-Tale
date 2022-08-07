Scriptname ASTConjCost extends activemagiceffect  

ASTMainScript Property main Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    main.UpdateLifeForce()
    main.energyCurr -= 300
    main.CheckLifeForce()
EndEvent