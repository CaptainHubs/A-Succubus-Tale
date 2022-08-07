Scriptname ASTUiScript extends Quest  

bool property isanimatingletters = false auto

int dist = 30
int logo
int OnText
int OffText
int[] drainModeText
int[] healthBars
int LifeForceBar
bool IWiRRUnning = false

OSexIntegrationMain ostim
iwant_widgets iWidgets
ASTMainScript main

;--------------------Events

Event OnInit()
    ostim = outils.GetOStim()
    main = (Self as Quest) as ASTMainScript
EndEvent

Event OniWantWidgetsReset(String eventName, String strArg, Float numArg, Form sender)
    If eventName == "iWantWidgetsReset"
        If !IWiRRunning
            iWidgets = sender As iWant_Widgets
            IWiRRunning = True
                SetTextAndLogo()
                SetBars()
                SetLifeForceBar()
            IWiRRunning = False
        EndIf
    EndIf
EndEvent

;-------------------Functions

;Do UI onload stuff
Function OnLoadFunc()
    RegisterForModEvent("iWantWidgetsReset", "OniWantWidgetsReset")
EndFunction

;Initialize bars
Function SetBars()
    healthBars = new int[3]
    int i = 0
    While(i < 3)
        healthBars[i] = iWidgets.loadMeter()
        iWidgets.setPos(healthBars[i], 1120, (670 - (i * dist)))
        iWidgets.setMeterFillDirection(healthBars[i], "right")
        iWidgets.setMeterRGB(healthBars[i],200, 0, 0, 100, 0, 0)
        iWidgets.setSize(healthBars[i], 30, 420)
        i += 1
    EndWhile
EndFunction

Function SetLifeForceBar()
    LifeForceBar = iWidgets.loadMeter()
    iWidgets.setPos(LifeForceBar, 1120, 140)
    iWidgets.setMeterFillDirection(LifeForceBar, "right")
    iWidgets.setMeterRGB(LifeForceBar, 128, 49, 167, 104, 71, 141)
    iWidgets.setSize(LifeForceBar, 30, 420)
EndFunction

bool lfBarAnimating = false
Function ShowLifeForceBar(int pct)
    If !lfBarAnimating
        lfBarAnimating = true

        iWidgets.setTransparency(LifeForceBar, 0)
        iWidgets.setMeterPercent(LifeForceBar, pct)
        iWidgets.setVisible(LifeForceBar)
        iWidgets.doTransitionByTime(LifeForceBar, 100, 0.3)
        Utility.Wait(3)
        iWidgets.doTransitionByTime(LifeForceBar, 0, 0.3)
        Utility.Wait(0.3)
        iWidgets.setVisible(LifeForceBar, 0)
        
        lfBarAnimating = false
    EndIf
EndFunction

Function ShowLifeForceBarDontDisappear(int pct)
        iWidgets.setTransparency(LifeForceBar, 0)
        iWidgets.setMeterPercent(LifeForceBar, pct)
        iWidgets.setVisible(LifeForceBar)
        iWidgets.doTransitionByTime(LifeForceBar, 100, 0.3)
EndFunction

Function UpdateBarPct(int pct)
    iWidgets.setMeterPercent(LifeForceBar, pct)
EndFunction

Function HideLifeForceBar()
    iWidgets.doTransitionByTime(LifeForceBar, 0, 0.3)
    Utility.Wait(0.3)
    iWidgets.setVisible(LifeForceBar, 0)
EndFunction

;Initialize logo and text letters
Function SetTextAndLogo()
    
    logo = iWidgets.loadLibraryWidget("LogoSuccubus")
    iWidgets.setSize(logo, 60, 60)
    iWidgets.setpos(logo, 1240, 683)

    string[] drainModeLetters = StringUtil.Split("D, r, a, i, n, ,M, o, d, e", ",")
    drainModeText = new int[10]

    int i = 0
    
    while i < 10
        drainModeText[i] = iWidgets.loadText(drainModeLetters[i], "$EverywhereFont", 24)
        iWidgets.setpos(drainModeText[i], 1240, 685)
        i += 1
    endWhile

    OnText = iWidgets.loadText("On")
    iWidgets.setPos(OnText, 1240, 685)
    OffText = iWidgets.loadText("Off")
    iWidgets.setPos(OffText, 1240, 685)
EndFunction

;Animate letters also setting the value when running
Function AnimateLetters(bool isOn)
    isAnimatingLetters = true
    int i = 0
    int startingPos = 1102
    int ONOFFPos
    int ONOFFText

    ;/ FIRST PART /;

    iWidgets.sendToFront(logo)
    iWidgets.setTransparency(logo, 0)
    iWidgets.setVisible(logo)
    iWidgets.doTransitionByTime(logo, 100, 0.3)

    Utility.Wait(0.2)

    int[] LettersCoords = GetPositionsForDrainModeLetters(startingPos)

    ;roll out letters
    While i < 10
        iwidgets.setVisible(drainModeText[i])
        iWidgets.doTransitionByTime(drainModeText[i], LettersCoords[i], 0.5, "x")
        i += 1
    EndWhile
    
    ;set on or off to roll out
    If isOn
        ONOFFText = OnText
        ONOFFPos = 1200
    Else
        ONOFFText = OffText
        ONOFFPos = 1198
    EndIf

    iWidgets.setVisible(ONOFFText)
    iWidgets.doTransitionByTime(ONOFFText, ONOFFPos, 0.5, "x")

    Utility.Wait(0.4)

    i = 0
    While (i < 10)

        If main.clicked
            iWidgets.doTransitionByTime(ONOFFText, 1240, 0.5, "x")
            isOn = !isOn
            main.IsDrainOn = isOn
            If isOn
                ONOFFText = OnText
                ONOFFPos = 1200
            Else
                ONOFFText = OffText
                ONOFFPos = 1198
            EndIf
            iWidgets.setVisible(ONOFFText, 1)
            iWidgets.doTransitionByTime(ONOFFText, ONOFFPos, 0.5, "x")
            main.clicked = false
            i = 0
        EndIf

        Utility.Wait(0.1)
        i += 1
    EndWhile


    ;/ SECOND PART /;

    iWidgets.doTransitionByTime(ONOFFText, 1240, 0.5, "x")

    ;hide letters
    i = 0
    While i < 10
        iWidgets.doTransitionByTime(drainModeText[i], 1240, 0.5, "x")
        i += 1
    EndWhile

    Utility.Wait(0.5)

    iWidgets.setVisible(OnText, 0)
    iWidgets.setVisible(OffText, 0)

    i = 0
    While i < 10
        iWidgets.setVisible(drainModeText[i], 0)
        i += 1
    EndWhile

    iWidgets.doTransitionByTime(logo, 0, 0.5)

    Utility.Wait(0.5)

    iWidgets.setVisible(Logo, 0)
    main.clicked = false
    isAnimatingLetters = false
EndFunction

;returns drain mode letters final positions
Int[] Function GetPositionsForDrainModeLetters(int begginingX)
    
    string[] spaces = StringUtil.Split("6, 7, 7, 7, 8, 12, 9, 9, 9", ",")
    int i = 0
    int distance = 0
    int[] output = new int[10]

    while i < 10
        output[i] = begginingX + distance
        distance += spaces[i] as int
        i += 1
    endWhile
    return output
EndFunction

Function UpdateHealthBarsPc(Actor[] actors)
    int i = 0
    While i < actors.Length
        iWidgets.setMeterPercent(healthBars[i], ( (actors[i].GetActorValuePercentage("Health") * 100) as int) )
        i += 1
    EndWhile
EndFunction

Function SetBarsVisibility(Actor[] actors, bool visibility)
    If visibility
        int i = 0
        While (i < actors.Length)
            iWidgets.setTransparency(healthBars[i], 0)
            iWidgets.setVisible(healthBars[i], 1)
            iWidgets.doTransitionByTime(healthBars[i], 100, 0.5)
            i += 1
        EndWhile
    Else
        int i = 0
        While (i < actors.Length)
            iWidgets.doTransitionByTime(healthBars[i], 0, 0.5)
            Utility.Wait(0.5)
            iWidgets.setVisible(healthBars[i], 0)
            i += 1
        EndWhile
    EndIf
EndFunction