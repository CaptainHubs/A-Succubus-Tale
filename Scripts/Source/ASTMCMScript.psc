Scriptname ASTMCMScript extends SKI_ConfigBase  


int tattooOption
int guiltyOption
int waitForThreesomeTimeOption
int EnableThreesomesOption
int stopMagickaRegenOption
int stopHealthRegenOption
int tattooMenu
int isSucOption
int fixedTattooOption
int tattooLeveledMenuOption
int currLeveledTattosIndex
int maleTattooOption
; int usesSamOption
int enableGlowOption
int treatMaleOption

int flag

string[] progressSpeedArr
string[] tattoos
string[] leveledTattos

ASTMainScript main
ASTTattooScript TattooScript
ASTLvlManager LevelManager

; EVENTS
;---------------------------------------------


Event OnConfigInit()
    main = (self as Quest) as ASTMainScript
    TattooScript = (Self as Quest) as ASTTattooScript
    LevelManager = (Self as Quest) as ASTLvlManager

    tattoos = new string[10]

    int i = 0
    While (i < 10)
        tattoos[i] = stringUtil.Substring(TattooScript.GetTattooNameFromIndex(i), 3)
        i += 1
    EndWhile

    leveledTattos = new string[2]
    leveledTattos[0] = "Default"
    leveledTattos[1] = "Small"

    progressSpeedArr = new string[2]
    progressSpeedArr[0] = "Immersive"
    progressSpeedArr[1] = "Fast"
EndEvent

Event OnPageReset(string page)
    If (page == "")
        LoadCustomContent("ASuccubusTale/Logo.dds", 26, 23)
        Else
            UnloadCustomContent()
            If LevelManager.IsSuccubus()
                flag = OPTION_FLAG_NONE
            Else
                flag = OPTION_FLAG_DISABLED
            EndIf
            SetCursorFillMode(TOP_TO_BOTTOM)
    EndIf

    If page == "Mod Configuration"
        Hotkeys()
        AddEmptyOption()

        GameplayOptionsColumn()
        SetCursorPosition(1)

        ToggleMod()
        AddEmptyOption()

        Disadvantages()
        AddEmptyOption()

        Debug()
        AddEmptyOption()
    ElseIf page == "Tattoo"
        AddHeaderOption("Tattoo", flag)
        tattooOption = AddToggleOption("Apply tattoo", main.usesTatoo, flag)
        AddEmptyOption()

        int previousFlag = flag
        if !main.usesTatoo
            flag = OPTION_FLAG_DISABLED
        EndIf

        AddHeaderOption("Configuration", flag)
        If TattooScript.fixedTattoo
            tattooLeveledMenuOption = AddMenuOption("Tattoo Type", leveledTattos[currLeveledTattosIndex], OPTION_FLAG_DISABLED)
        Else
            tattooLeveledMenuOption = AddMenuOption("Tattoo Type", leveledTattos[currLeveledTattosIndex], flag)
        EndIf
        enableGlowOption = AddToggleOption("Glowing Effect", TattooScript.enableGlow, flag)
        AddEmptyOption()
        
        fixedTattooOption = AddToggleOption("Use a fixed tattoo", TattooScript.fixedTattoo, flag)
        If !TattooScript.fixedTattoo
            tattooMenu = AddMenuOption("Tattoo", tattoos[tattooScript.currTattooIndex], OPTION_FLAG_DISABLED)
        Else
            tattooMenu = AddMenuOption("Tattoo", tattoos[tattooScript.currTattooIndex], flag)
        EndIf
        AddHeaderOption("Male Support", flag)

        maleTattooOption = AddToggleOption("Force use male Tattoos", TattooScript.usesMaleTextures, flag)
        ; usesSamOption = AddToggleOption("Uses SAM", TattooScript.usesSam, flag)

        flag = previousFlag

    ElseIf page == "Stats"
        AddHeaderOption("SUCCUBUS STATS")

        If LevelManager.SuccubusLvl.GetValueInt() >= 8
            AddTextOption("Progress till next Succubus Lvl: ", "LVL max", OPTION_FLAG_DISABLED)
        Else
            AddTextOption("Progress till next Succubus Lvl: ", ((LevelManager.CurrXp / LevelManager.XpRequired) + "% (" + LevelManager.currXp as int + "/" + LevelManager.XpRequired as int + ")"), OPTION_FLAG_DISABLED)
        EndIf
        
        SetCursorPosition(1)

        AddHeaderOption("Life Force")
        AddTextOption("Current Life Force: ", (((main.energyCurr as float) / (main.energyMax as float)) + "% (" + main.energyCurr + "/" + main.energyMax + ")" ), OPTION_FLAG_DISABLED)

    ElseIf page == "UI Settings"
        AddHeaderOption("Health Bars")
        AddToggleOptionST("healthBarsUIToggleState", "Enable health bars", main.enableHealthBarsUi, flag)
    ElseIf page == "Integrations"
        OSLAroused()
        AddEmptyOption()

        AddHeaderOption("Debug")
        AddToggleOptionST("checkForIntegrationsState", "Check For Integrations", false, flag)
    EndIf
EndEvent

Event OnOptionSliderOpen(Int Option)
	If (Option == waitForThreesomeTimeOption)
		SetSliderDialogStartValue(Main.WaitForThreesomeTime)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.5)
    EndIf
EndEvent

Event OnOptionMenuOpen(int a_option)
    If a_option == tattooMenu
        SetMenuDialogOptions(tattoos)
		SetMenuDialogStartIndex(TattooScript.currTattooIndex)
		SetMenuDialogDefaultIndex(0)
    ElseIf a_option == tattooLeveledMenuOption
        SetMenuDialogOptions(leveledTattos)
        SetMenuDialogStartIndex(currLeveledTattosIndex)
        SetMenuDialogDefaultIndex(0)
    EndIf
EndEvent

event OnOptionMenuAccept(int a_option, int a_index)
	if (a_option == tattooMenu)
		TattooScript.currTattooIndex = a_index
        TattooScript.RefreshTattoo()
		SetMenuOptionValue(tattooMenu, tattoos[a_index])
    Elseif (a_option == tattooLeveledMenuOption)
        TattooScript.currTattooIndex = 2 + (a_index * 4)
        currLeveledTattosIndex = a_index
        TattooScript.RefreshTattoo()
        SetMenuOptionValue(tattooLeveledMenuOption, leveledTattos[a_index])
	endIf
endEvent

Event OnOptionSelect(int option)
    if option == tattooOption
        main.usesTatoo = !main.usesTatoo
        If main.usesTatoo
            SetOptionFlags(option, OPTION_FLAG_NONE)
        Else
            SetOptionFlags(option, OPTION_FLAG_HIDDEN)
        EndIf
        TattooScript.RefreshTattoo()
        SetToggleOptionValue(option, main.usesTatoo)
    ElseIf option == isSucOption
        If LevelManager.IsSuccubus()
            LevelManager.UnSuccuby()
        Else
            LevelManager.LevelUp()
            TattooScript.RefreshTattoo()
            main.OnLoadFunc()
        EndIf
        SetToggleOptionValue(option, LevelManager.IsSuccubus())
        Utility.Wait(0.1)
    ElseIf option == guiltyOption
        main.IsPlayerGuilty = !(main.IsPlayerGuilty)
        SetToggleOptionValue(option, main.IsPlayerGuilty)
    ElseIf option == treatMaleOption
        main.TreatAsMale = !(main.TreatAsMale)
        SetToggleOptionValue(option, main.TreatAsMale)
    ElseIf option == EnableThreesomesOption
        main.EnableThreesomes = !(main.EnableThreesomes)
        SetToggleOptionValue(option, main.EnableThreesomes)
    ElseIf option == stopMagickaRegenOption
        main.ConditionsScript.DisableManaRegenInScene = !main.ConditionsScript.DisableManaRegenInScene
        SetToggleOptionValue(option, main.ConditionsScript.DisableManaRegenInScene)
    ElseIf option == stopHealthRegenOption
        main.ConditionsScript.DisableHealthRegenInScene = !main.ConditionsScript.DisableHealthRegenInScene
        SetToggleOptionValue(option, main.ConditionsScript.DisableHealthRegenInScene)
    ElseIf option == fixedTattooOption
        TattooScript.fixedTattoo = !TattooScript.fixedTattoo
        SetToggleOptionValue(option, TattooScript.fixedTattoo)
        TattooScript.RefreshTattoo()
        Utility.wait(0.1)
    ; ElseIf option == usesSamOption
    ;     TattooScript.usesSam = !(TattooScript.usesSam)
    ;     TattooScript.RefreshTattoo()
    ;     SetToggleOptionValue(option, TattooScript.usesSam)
    ElseIf option == maleTattooOption
        TattooScript.usesMaleTextures = !(TattooScript.usesMaleTextures)
        TattooScript.RefreshTattoo()
        SetToggleOptionValue(option, TattooScript.usesMaleTextures)
    ElseIf option == enableGlowOption
        TattooScript.enableGlow = !(TattooScript.enableGlow)
        TattooScript.RefreshTattoo()
        SetToggleOptionValue(option, TattooScript.enableGlow)
    endIf
EndEvent

Event OnOptionSliderAccept(int a_option, float a_value)
    If a_option == waitForThreesomeTimeOption
        main.WaitForThreesomeTime = a_value
        SetSliderOptionValue(a_option, main.WaitForThreesomeTime)
    EndIf
EndEvent

Event OnOptionHighlight(int a_option)
    If a_option == isSucOption
        SetInfoText("Toggle the mod ON/OFF, note that disabling this mid playthrough will ZERO your progress")
    ElseIf a_option == guiltyOption
        SetInfoText("If on, the player will be marked as guilty of killing a sexdrain victim")
    ElseIf a_option == EnableThreesomesOption
        SetInfoText("If off, this mod won't start threesome scenes")
    ElseIf a_option == stopMagickaRegenOption
        SetInfoText("If on, the magicka regen will stop while in a scene started by this mod")
    ElseIf a_option == stopHealthRegenOption
        SetInfoText("If on, the health regen will stop while in a scene started by this mod")
    ElseIf a_option == waitForThreesomeTimeOption
        SetInfoText("How much time to wait for a third character to get in range after a seduction spell affected character reaches you")
    ElseIf a_option == treatMaleOption
        SetInfoText("Treat Player as a male character. Note that this doesn't affect tattoos")
    ElseIf a_option == tattooOption
        SetInfoText("Toggle tattoos ON/OFF")
    ElseIf a_option == tattooLeveledMenuOption
        SetInfoText("Choose the tattoo variant")
    ElseIf a_option == enableGlowOption
        SetInfoText("Enable tattoo glow")
    ElseIf a_option == fixedTattooOption
        SetInfoText("Use a fixed, chosen by you tattoo. Disables tattoo evolving with level")
    ElseIf a_option == tattooMenu
        SetInfoText("Select a fixed tattoo from the list")
    ElseIf a_option == maleTattooOption
        SetInfoText("Forces the use of male tattoo textures. Usefull for futa characters")
    EndIf
EndEvent

; Functions
;---------------------------------------------

Function Hotkeys()
    AddHeaderOption("HOTKEYS", flag)
    AddKeyMapOptionST("DrainToggleKeymap", "Drain toggle key", main.DrainSwitchKey, flag)
    AddKeyMapOptionST("LifeForceCheckKeymap", "Check Life Force key", main.LifeForceCheckKey, flag)
EndFunction

Function ToggleMod()
    AddHeaderOption("Toggle Mod")
    isSucOption = AddToggleOption("Enable Mod", LevelManager.IsSuccubus())
EndFunction

Function GameplayOptionsColumn()
    AddHeaderOption("Gameplay", flag)
    AddMenuOptionST("progressSpeedMenuState", "Progress speed", progressSpeedArr[LevelManager.progressSpeed], flag)
    guiltyOption = AddToggleOption("Player guilty of drain kill", main.IsPlayerGuilty, flag)
    EnableThreesomesOption = AddToggleOption("Allow Threesomes", main.EnableThreesomes, flag)
    stopMagickaRegenOption = AddToggleOption("Stop magicka regen in scene", main.ConditionsScript.DisableManaRegenInScene, flag)
    stopHealthRegenOption = AddToggleOption("Stop health regen in scene", main.ConditionsScript.DisableHealthRegenInScene, flag)
    waitForThreesomeTimeOption = AddSliderOption("Third actor wait time", main.WaitForThreesomeTime, a_flags = flag)
    AddEmptyOption()
    
    treatMaleOption = AddToggleOption("Treat player as male", main.TreatAsMale, flag)
EndFunction

Function Disadvantages()
    AddHeaderOption("Life Force", flag)
    AddToggleOptionST("ToggleDisadvantagesState", "Enable", main.AreDisadvantagesEnabled, flag)
    int prevFlag = flag
    If !main.AreDisadvantagesEnabled
        flag = OPTION_FLAG_DISABLED
    EndIf
    AddSliderOptionST("energyIncrState", "Life Force multiplier", main.energyIncr,  "{2} x", a_flags = flag)
    AddSliderOptionST("energyMaxState", "Maximum storage", main.energyMax, a_flags = flag)
    AddSliderOptionST("energyUpdateFreq", "Life force Update Frequency", main.energyUpdateFreq, a_flags = flag)
    flag = prevFlag
EndFunction

bool Property areCheatsAllowed = false Auto
Function Debug()
    AddHeaderOption("Debug", flag)
    AddToggleOptionST("LFRESET", "Reset Life Force Updater", false, flag)
    AddEmptyOption()
    AddToggleOptionST("EnableCheatsState", "Enable Cheats", areCheatsAllowed, flag)
    int prevFlag = flag
    If !areCheatsAllowed
        flag = OPTION_FLAG_DISABLED
    EndIf
    AddToggleOptionST("LvlUpState", "Level up character", false, flag)
    flag = prevFlag
EndFunction

Function OSLAroused()
    int prevFlag = flag
    If !main.isOArousedInstalled
        flag = OPTION_FLAG_DISABLED
    EndIf
    AddHeaderOption("OAroused/OslAroused", flag)
    AddToggleOptionST("enableOarousedState", "Enable arousal modifier", main.enableArousalChange, flag)
    AddSliderOptionST("arousalGainState", "Arousal gain on seduction", main.arousalGainf, a_flags = flag)
    flag = prevFlag;

EndFunction

; States
;---------------------------------------------

;/ Keys /;

    State DrainToggleKeymap
        event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
            main.UnregisterForKey(main.DrainSwitchKey)
            main.DrainSwitchKey = newKeyCode
            main.RegisterForKey(newKeyCode)
            SetKeyMapOptionValueST(main.DrainSwitchKey)
        endEvent

        Event OnDefaultST()
            main.UnregisterForKey(main.DrainSwitchKey)
            main.DrainSwitchKey = 37
            main.RegisterForKey(main.DrainSwitchKey)
            SetKeyMapOptionValueST(main.DrainSwitchKey)
        EndEvent

        Event OnHighlightST()
            SetInfoText("The key used to toggle draining ON/OFF")
        EndEvent
    EndState

    State LifeForceCheckKeymap
        event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
            main.UnregisterForKey(main.LifeForceCheckKey)
            main.LifeForceCheckKey = newKeyCode
            main.RegisterForKey(newKeyCode)
            SetKeyMapOptionValueST(main.LifeForceCheckKey)
        endEvent

        Event OnDefaultST()
            main.UnregisterForKey(main.LifeForceCheckKey)
            main.LifeForceCheckKey = 38
            main.RegisterForKey(main.LifeForceCheckKey)
            SetKeyMapOptionValueST(main.LifeForceCheckKey)
        EndEvent

        Event OnHighlightST()
            SetInfoText("The key used to check your Life Force")
        EndEvent
    EndState
;-

;/ Disadvantages /;
    State ToggleDisadvantagesState
        Event OnSelectST()
            main.AreDisadvantagesEnabled = !main.AreDisadvantagesEnabled
            main.lastCheckedTime = main.GameDaysPassed.GetValue()
            main.UpdateLifeForce()
            main.RefreshBuffsDebuffsEnergy()
            SetToggleOptionValueST(main.AreDisadvantagesEnabled)
            Utility.Wait(0.1)
        EndEvent

        Event OnDefaultST()
            main.AreDisadvantagesEnabled = true
            main.lastCheckedTime = main.GameDaysPassed.GetValue()
            main.UpdateLifeForce()
            main.RefreshBuffsDebuffsEnergy()
            SetToggleOptionValueST(main.AreDisadvantagesEnabled)
            Utility.Wait(0.1)
        EndEvent

        Event OnHighlightST()
            SetInfoText("Toggle buffs and debuffs based on your Life Force")
        EndEvent
    EndState

    State energyIncrState
        Event OnSliderOpenST()
            SetSliderDialogStartValue(main.energyIncr)
            SetSliderDialogDefaultValue(0.75)
            SetSliderDialogRange(0, 2.0)
            SetSliderDialogInterval(0.25)
        EndEvent
        
        Event OnSliderAcceptST(float a_value)
            main.energyIncr = a_value
            SetSliderOptionValueST(main.energyIncr, "{2} x")
        EndEvent
        
        event OnDefaultST()
            main.energyIncr = 0.75
            SetSliderOptionValueST(main.energyIncr, "{2} x")
        endEvent
        
        event OnHighlightST()
            SetInfoText("How much life force you get from draining someone(I tried to balance it, so don't change the value too much or it won't be immersive!)")
        endEvent
    EndState

    State energyMaxState
        Event OnSliderOpenST()
            SetSliderDialogStartValue(main.energyMax)
            SetSliderDialogDefaultValue(800)
            SetSliderDialogRange(0, 1600)
            SetSliderDialogInterval(100)
        EndEvent
        
        Event OnSliderAcceptST(float a_value)
            main.energyMax = a_value as int
            SetSliderOptionValueST(main.energyMax)
        EndEvent
        
        event OnDefaultST()
            main.energyMax = 800
            SetSliderOptionValueST(main.energyMax)
        endEvent
        
        event OnHighlightST()
            SetInfoText("How much life force you can store(I tried to balance it, don't change the value too much or it won't be immersive!)")
        endEvent
    EndState

    State energyUpdateFreq
        Event OnSliderOpenST()
            SetSliderDialogStartValue(main.energyUpdateFreq)
            SetSliderDialogDefaultValue(3)
            SetSliderDialogRange(1, 10)
            SetSliderDialogInterval(1)
        EndEvent
        
        Event OnSliderAcceptST(float a_value)
            main.energyUpdateFreq = a_value as int
            SetSliderOptionValueST(main.energyUpdateFreq)
        EndEvent
        
        event OnDefaultST()
            main.energyUpdateFreq = 3
            SetSliderOptionValueST(main.energyUpdateFreq)
        endEvent
        
        event OnHighlightST()
            SetInfoText("How often life force level will update in game hours")
        endEvent
    EndState
;-

;/ Debug /;

    State LFRESET
        Event OnSelectST()
            UnregisterForUpdateGameTime()
            RegisterForSingleUpdateGameTime(1)
        EndEvent

        event OnHighlightST()
            SetInfoText("Use this if you arent getting life force updates")
        endEvent
    EndState

    State checkForIntegrationsState
        Event OnSelectST()
            main.CheckForIntegrations()
        EndEvent

        event OnHighlightST()
            SetInfoText("Use this if you have some integration installed but it appears disabled on this page")
        endEvent
    EndState

    State EnableCheatsState
        Event OnSelectST()
            areCheatsAllowed = !areCheatsAllowed
            SetToggleOptionValueST(areCheatsAllowed)
            ForcePageReset()
        EndEvent

        Event OnDefaultST()
            areCheatsAllowed = false
            SetToggleOptionValueST(areCheatsAllowed)
            ForcePageReset()
        EndEvent

        Event OnHighlightST()
            SetInfoText("Toggle cheat options on/off")
        EndEvent
    EndState

    State LvlUpState
        Event OnSelectST()
            levelmanager.LevelUp()
            SetToggleOptionValueST(true)
        EndEvent

        event OnHighlightST()
            SetInfoText("Use this if you want to test some stuff, !!!BREAKS IMMERSION!!!")
        endEvent
    EndState

;-

;/ UI /;
    State healthBarsUIToggleState
        Event OnSelectST()
            main.enableHealthBarsUi = !main.enableHealthBarsUi
            SetToggleOptionValueST(main.enableHealthBarsUi)
        EndEvent

        Event OnDefaultST()
            main.enableHealthBarsUi = true
            SetToggleOptionValueST(main.enableHealthBarsUi)
        EndEvent

        Event OnHighlightST()
            SetInfoText("Toggle display of health bars in the right bottom corner when draining")
        EndEvent
    EndState
;-

;/ Integrations /;
    State enableOarousedState
        Event OnSelectST()
            main.enableArousalChange = !main.enableArousalChange
            SetToggleOptionValueST(main.enableArousalChange)
        EndEvent

        Event OnDefaultST()
            main.enableHealthBarsUi = true
            SetToggleOptionValueST(main.enableArousalChange)
        EndEvent

        Event OnHighlightST()
            SetInfoText("Toggle changing of target's arousal on seduction spells")
        EndEvent
    EndState

    State arousalGainState
        Event OnSliderOpenST()
            SetSliderDialogStartValue(main.arousalGainf)
            SetSliderDialogDefaultValue(30.0)
            SetSliderDialogRange(0.0, 60.0)
            SetSliderDialogInterval(5.0)
        EndEvent
        
        Event OnSliderAcceptST(float a_value)
            main.arousalGainf = a_value
            SetSliderOptionValueST(main.arousalGainf)
        EndEvent
        
        event OnDefaultST()
            main.arousalGainf = 30.0
            SetSliderOptionValueST(main.arousalGainf)
        endEvent
        
        event OnHighlightST()
            SetInfoText("How much arousal will a succubus spell's target gain")
        endEvent
    EndState
;-

;/ Gameplay /;
        state progressSpeedMenuState
            event OnMenuOpenST()
                SetMenuDialogStartIndex(LevelManager.progressSpeed)
                SetMenuDialogDefaultIndex(0)
                LevelManager.RefreshXpIncreaseValue()
                SetMenuDialogOptions(progressSpeedArr)
            endEvent
        
            event OnMenuAcceptST(int index)
                LevelManager.progressSpeed = index
                LevelManager.RefreshXpIncreaseValue()
                SetMenuOptionValueST(progressSpeedArr[LevelManager.progressSpeed])
            endEvent
        
            event OnDefaultST()
                LevelManager.progressSpeed = 0
                LevelManager.RefreshXpIncreaseValue()
                SetMenuOptionValueST(progressSpeedArr[LevelManager.progressSpeed])
            endEvent
        
            event OnHighlightST()
                SetInfoText("How fast you will level up (the fast setting is for people who really find the grind too big)")
            endEvent
        endState
;-