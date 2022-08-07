Scriptname LifeForceDrainConc extends activemagiceffect  

ASTMainScript Property main Auto
Actor Property playerRef Auto
ASTUiScript Property UiScript Auto

bool isOn = false


Event OnEffectStart(Actor akTarget, Actor akCaster)
    isOn = true
    main.UpdateLifeForce()
    int pct = ((((main.energyCurr as float) / (main.energyMax as float)) * 100) as int)
    UiScript.ShowLifeForceBarDontDisappear(pct)
    RegisterForSingleUpdate(0.5)
EndEvent

Event OnUpdate()
    If isOn
        int damage = (GetMagnitude() / 10) as int
        If main.energyCurr >= damage
            main.energyCurr -= damage
            playerRef.RestoreActorValue("Health", damage * 2)
            int pct = ((((main.energyCurr as float) / (main.energyMax as float)) * 100) as int)
            UiScript.UpdateBarPct(pct)
            RegisterForSingleUpdate(0.1)
        EndIf
    EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    UiScript.HideLifeForceBar()
    main.UpdateLifeForce()
    isOn = false
EndEvent