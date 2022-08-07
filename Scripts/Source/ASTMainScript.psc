Scriptname ASTMainScript extends Quest  

; Variables
;---------------------------------------------

;/ Lvl /;

GlobalVariable Property SuccubusLvl Auto

;/ For use by other scripts /;

bool Property isOArousedInstalled = false Auto
bool Property IsDrainOn = true Auto
bool Property clicked = false Auto

;/ Creation Kit References /;

spell[] Property lifeForceSpells Auto
GlobalVariable Property GameDaysPassed Auto
Actor Property playerRef Auto
ASTFillAliasScript Property FIllAliasScript Auto
Quest Property MSRTAliasQuest Auto

;/ UserSettings /;   

float Property arousalGainf = 30.0 Auto
bool property enableArousalChange = true Auto
bool Property enableHealthBarsUi = true Auto
bool Property AreDisadvantagesEnabled = true Auto
int Property energyCurr = 400 Auto
float Property energyIncr = 0.75 Auto
int Property energyMax = 800 Auto
int Property energyUpdateFreq = 3 Auto
bool Property TreatAsMale = false Auto
int Property DrainSwitchKey = 37 Auto; k default drain switch key
int Property LifeForceCheckKey = 38 Auto
bool Property IsPlayerGuilty = false Auto
bool Property usesTatoo = true Auto
float Property WaitForThreesomeTime = 1.0 Auto
bool Property EnableThreesomes = true Auto

;/ Script references /;

ASTConditions Property ConditionsScript Auto
OsexIntegrationMain ostim
ASTUiScript UiScript
ASTDrainScript DrainScript
ASTTattooScript TattooScript
ASTLvlManager LevelManager
OArousedScript oAroused

VoiceCharmFactionScript es

; Events
;---------------------------------------------

Event OnInit()
    UiScript = (Self as Quest) as ASTUiScript
    DrainScript = (Self as Quest) as ASTDrainScript
    TattooScript = (Self as Quest) as ASTTattooScript
    LevelManager = (Self as Quest) as ASTLvlManager
    ConditionsScript = (Self as Quest) as ASTConditions
    ostim = Outils.GetOStim()
    CheckForIntegrations()

    SuccubusLvl.SetValueInt(0)

    ;RegisterForSingleUpdate(5)
EndEvent

Event OnUpdateGameTime()
    If UpdateLifeForce()
        RegisterForSingleUpdateGameTime(energyUpdateFreq as float)
    EndIf
EndEvent

Event OnKeyDown(int keyCode)
    ; ASTMainScript.AstConsole("Current xp: " + LevelManager.CurrXp + "Required xp: " + LevelManager.XpRequired + "Xp pct: " + LevelManager.CurrXp/LevelManager.XpRequired)
    If outils.MenuOpen()
        Return
    EndIf

    If keyCode == DrainSwitchKey
        SwitchDrainModes()
    ElseIf keyCode == LifeForceCheckKey
        CheckLifeForce()
    EndIf
EndEvent

Event OnOstimOrgasm(string eventName, string strArg, float numArg, Form sender)
    If isDrainOn
        int drainDamage = (LevelManager.calcDamage)
        Actor Act = ostim.GetMostRecentOrgasmedActor()

        if((Act != playerRef) && ostim.IsPlayerInvolved())
            Actor[] actors = ostim.GetActors()
            If enableHealthBarsUi
                UiScript.SetBarsVisibility(actors, true)
                UiScript.UpdateHealthBarsPc(actors)
            EndIf

            ASTMainScript.AstConsole("Draining " + Act + " for " + drainDamage)
            DrainScript.Drain(playerRef, Act, drainDamage as float)

            Utility.Wait(1)
            UiScript.SetBarsVisibility(actors, false)
        EndIf
    EndIf
EndEvent

Event OnOstimEnd(string eventName, string strArg, float numArg, Form sender)
    While ostim.AnimationRunning()
        Utility.Wait(0.1)
    EndWhile
    Utility.Wait(3)
    If !StartSceneShiftQueue()
        MSRTAliasQuest.Stop()
    EndIf
EndEvent

; Functions
;---------------------------------------------

;do main script onload stuff
Function OnLoadFunc()
    If LevelManager.IsSuccubus()
        RegisterForKey(DrainSwitchKey)
        RegisterForKey(LifeForceCheckKey)
        RegisterForModEvent("ostim_orgasm", "OnOstimOrgasm")
        RegisterForModEvent("ostim_end", "OnOstimEnd")
        UiScript.OnLoadFunc()
    Else
        UnregisterForKey(DrainSwitchKey)
        UnregisterForKey(DrainSwitchKey)
        UnregisterForModEvent("ostim_orgasm")
        UnregisterForModEvent("ostim_end")
        UiScript.UnregisterForModEvent("iWantWidgetsReset")
    EndIf
EndFunction

;Switches drain modes on / off if isnt currently animating
Function SwitchDrainModes()
    ;LevelManager.LevelUp()
    if(!UiScript.isAnimatingLetters)
        IsDrainOn = !IsDrainOn
        UiScript.AnimateLetters(IsDrainOn)
    Else
        clicked = true
    endif
EndFunction

float Property lastCheckedTime = -1.0 Auto
;returns true if applicable for life force
bool Function UpdateLifeForce()
    ;ASTMainScript.AstConsole("UPDATE!, issuc: " + levelmanager.IsSuccubus() + " aredisen: " + AreDisadvantagesEnabled)
    If (LevelManager.IsSuccubus() && AreDisadvantagesEnabled)
        ;ASTMainScript.AstConsole("Last Checked Time: " + lastCheckedTime)
        If ( !(lastCheckedTime == -1.0) ); if default just skip
            float timePassed = (GameDaysPassed.GetValue() - lastCheckedTime)
            float energyToSubtract = ((timePassed / 0.0417) * (SuccubusLvl.GetValue() * 2.5)) ;(1 h = 0,0417 days)

            If (energyCurr > (energyToSubtract as int))
                ; ASTMainScript.AstConsole("current energy: " + energyCurr + "To subtract: " + energyToSubtract)
                energyCurr -= (energyToSubtract as int)
            Else
                energyCurr = 0
            EndIf
        EndIf

        lastCheckedTime = GameDaysPassed.GetValue()
        RefreshBuffsDebuffsEnergy()
        return true
    EndIf
    return false
EndFunction

;if there is something in queue start, if 3 start threesome, returns true if started
bool Function StartSceneShiftQueue()
    If !ostim.AnimationRunning()
        int queueLength = StorageUtil.FormListCount(none, "SuccubusQueueDom")

        AstConsole("Queue Length is: " + queueLength)

        ;three actors (potentialy 4)
        If (queueLength > 1) && EnableThreesomes

            Actor sub1 = StorageUtil.FormListShift(none, "SuccubusQueueSub") as Actor
            Actor dom1 = StorageUtil.FormListShift(none, "SuccubusQueueDom") as Actor
            Actor sub2 = StorageUtil.FormListShift(none, "SuccubusQueueSub") as Actor
            Actor dom2 = StorageUtil.FormListShift(none, "SuccubusQueueDom") as Actor

            AstConsole("We have: sub1: " + sub1 + " sub2: " + sub2 + " dom1: " + dom1 + " dom2: " + dom2 )

            If sub1 == sub2
                If ostim.StartScene(dom1, sub1, zThirdActor = dom2)
                    AstConsole("Started with: " + dom1 + " , " + dom2 + " , " + sub1)
                    return true
                EndIf
                AstConsole("Couldnt start same sub")
            ElseIf dom1 == dom2
                If ostim.StartScene(dom1, sub1, zThirdActor = sub2)
                    AstConsole("Started with: " + dom1 + " , " + sub2 + " , " + sub1)
                    return true
                EndIf
                AstConsole("Couldnt start same dom")
            Else
                StorageUtil.FormListAdd(none, "SuccubusQueueDom", dom2)
                StorageUtil.FormListAdd(none, "SuccubusQueueSub", sub2)
                If ostim.StartScene(dom1, sub1)

                    return true
                EndIf
                AstConsole("Couldnt start different doms and subs")
            EndIf

        ;two actors
        ElseIf queueLength > 0

            Actor dom = StorageUtil.FormListShift(none, "SuccubusQueueDom") as Actor
            Actor sub = StorageUtil.FormListShift(none, "SuccubusQueueSub") as Actor

            If ostim.StartScene(dom, sub)
                return true
            EndIf

        EndIf
    EndIf
    return false
EndFunction

int prevLFSpell = -1
; will apply or remove correct buffs/debuffs according to energy levels
Function RefreshBuffsDebuffsEnergy()
    int newLfSpell = prevLFSpell
    If (LevelManager.IsSuccubus() && AreDisadvantagesEnabled)
        If energyCurr <= (energyMax * 0.25) ; low lf
            If energyCurr > (energyMax * 0.06)
                newLfSpell = 0
            Else
                newLfSpell = 1
            EndIf
        ElseIf energyCurr >= (energyMax * 0.75) ; high lf
            If energyCurr < (energyMax * 0.94)
                newLfSpell = 2
            Else
                newLfSpell = 3
            EndIf
        Else ; med lf
            newLfSpell = -1
        EndIf
    Else
        newLfSpell = -1
    EndIf

    If (prevLFSpell != newLfSpell) ;changes spells, -1 is none
        If prevLFSpell != -1
            playerRef.RemoveSpell(lifeForceSpells[prevLFSpell])
        EndIf
        If newLfSpell != -1
            playerRef.AddSpell(lifeForceSpells[newLfSpell], false)
        EndIf
        LFMessage(newLfSpell)
        prevLFSpell = newLfSpell
    EndIf
EndFunction

Function CheckLifeForce()
    UpdateLifeForce()
    int pct = ((((energyCurr as float) / (energyMax as float)) * 100) as int)
    UiScript.ShowLifeForceBar(pct)
EndFunction

Function CheckForIntegrations()
    isOArousedInstalled = Game.IsPluginInstalled("OAroused.esp")
    If isOArousedInstalled
        oAroused = OArousedScript.GetOAroused()
    EndIf
EndFunction

Function RemoveAllGivenSpells(spell[] spells, actor act)
    int i = 0
    While (i < spells.Length)
        spell item = spells[i]
            act.RemoveSpell(item)
        i += 1
    EndWhile
EndFunction

Function LFMessage(int i)
    If i == 0
        debug.Notification("You start to lose your strength. You should find someone to drain")
    ElseIf i == 1
        Debug.Notification("You feel very weak. Might have to drain someone")
    ElseIf i == 2
        debug.Notification("You can feel the Life Force giving you strength")
    ElseIf i == 3
        debug.Notification("You feel stronger from all the Life Force you've accumulated")
    EndIf
EndFunction

Function modifyArousal(Actor act, float value)
    oAroused.ModifyArousal(act, value)
EndFunction

;sends console log with a prefix
Function AstConsole(string in) Global
	MiscUtil.PrintConsole("A Succubus' tale: " + In)
EndFunction