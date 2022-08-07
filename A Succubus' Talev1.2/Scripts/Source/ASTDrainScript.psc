Scriptname ASTDrainScript extends Quest

int Property numOfTicks = 20 Auto
bool property DeathFuncRunning = false Auto
MagicEffect Property SuccubusWeakness Auto
MagicEffect Property Lust Auto
spell Property lustSpell Auto

Actor[] actors

;/ Script references /;

ASTDrainFx FxScript
ASTMainScript main
ASTUiScript UiScript
ASTLvlManager LevelManager
OSexIntegrationMain ostim

Event OnInit()
    main = (Self as Quest) as ASTMainScript
    FxScript = (Self as Quest) as ASTDrainFx
    UiScript = (Self as Quest) as ASTUiScript
    LevelManager = (Self as Quest) as ASTLvlManager
    ostim = Outils.GetOStim()
EndEvent

; Drains target for specified amount
Function Drain(Actor akCaster, Actor akTarget, float amount)

    int i = 0

    If akTarget.HasMagicEffect(SuccubusWeakness)
        amount *= 1.2
    EndIf
    
    If akTarget.HasMagicEffect(Lust)
        amount *= 2
        akTarget.DispelSpell(lustSpell)
    EndIf

    float tickDmg = (amount / numOfTicks)
    float xpEarned = 0

    FxScript.AbsorbEffectStart(akTarget, akCaster)
    
    While (i < numOfTicks)
        ;ASTMainScript.AstConsole("Tick " + (i + 1) + " for " +  tickDmg + " going off on " + akTarget)

        akTarget.DamageActorValue("Health", tickDmg)
        akCaster.RestoreActorValue("Health", tickDmg)
        xpEarned += tickDmg

        UiScript.UpdateHealthBarsPc(ostim.GetActors())

        If akTarget.GetActorValue("health") <= tickDmg
            ;ASTMainScript.AstConsole("DeathFunc Launching")
            DeathFunc(akTarget, akCaster)
            i = numOfTicks; break the while
        EndIf

        Utility.Wait(0.1)
        i += 1
    EndWhile

    Utility.Wait(3)

    int inrease = (xpEarned * main.energyIncr) as int
    main.energyCurr += inrease
    If main.energyCurr > main.energyMax
        main.energyCurr = main.energyMax
    EndIf
    main.RefreshBuffsDebuffsEnergy()

    LevelManager.CurrXp += xpEarned
    LevelManager.CheckForLvlUp()
    FxScript.AbsorbEffectFinish(akTarget, akCaster)
EndFunction

; stops the animation and kills the target, 
Function DeathFunc(Actor akTarget, Actor akCaster)
    If !deathFuncRunning
        DeathFuncRunning = true

        bool hasThirdActor = ostim.GetThirdActor() as bool
        actors = ostim.GetActors()

        ;ASTMainScript.AstConsole("We are inside death func ")

        ostim.EndAnimation()
        While ostim.AnimationRunning()
            Utility.Wait(0.1)
        EndWhile
        Utility.Wait(3)

        ; If hasThirdActor
        ;     ASTMainScript.AstConsole("Has Third Actor")
        ;     int i = 0
        ;     While (i < actors.Length)
        ;         actor item = actors[i]

        ;         If item != akTarget && item != akCaster   
                    
        ;             StorageUtil.FormListAdd(none, "SuccubusQueueDom", item)
        ;             StorageUtil.FormListAdd(none, "SuccubusQueueSub", akCaster)
        ;             i = actors.Length; break the while
        ;         EndIf

        ;         i += 1
        ;     EndWhile

        ; EndIf

        If main.IsPlayerGuilty
            akTarget.kill(akCaster)
        Else
            akTarget.kill()
        EndIf
        
        DeathFuncRunning = false
    EndIf
EndFunction