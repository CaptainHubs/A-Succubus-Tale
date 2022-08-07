Scriptname ASTLvlManager extends Quest  

GlobalVariable Property SuccubusLvl Auto
float Property XpRequired = 200.0 Auto
float Property CurrXp = 0.0 Auto
int Property calcDamage Auto
Actor Property playerRef Auto
int Property progressSpeed = 0 Auto

;/ Spells /;

spell Property command Auto
Spell Property reanimate Auto
Spell Property SeductionArea Auto
Spell Property ConsumeLifeForce Auto
Spell Property SucPower Auto
Spell Property SpeechModifier Auto
Spell Property SeductionFFAimed Auto
Spell Property MassSeductionFFSelf Auto
Spell Property SuccubusWeakness Auto
Spell Property Lust Auto
Spell[] Property SuccubusSoul Auto
Spell[] Property DrainSpellLevels Auto
Spell[] Property FortifyMagickaLevels Auto
Spell[] Property FortifyMagickaRateLevels Auto

;/ Balance values /;

int Property baseDamage = 20 Auto
int Property damageIncrease = 10 Auto

float Property XpRequiredBase = 200.0 Auto
float Property XpIncreaseValue = 2.0 Auto

ASTMainScript main
ASTTattooScript TattooScript


; Events
;---------------------------------------------


Event OnInit()
    main = (Self as Quest) as ASTMainScript
    TattooScript = (Self as Quest) as ASTTattooScript
EndEvent


; Functions
;---------------------------------------------

;level up or become a succubus if not a succubus
int Function LevelUp()
    
    If !IsSuccubus()
        XpRequired = XpRequiredBase
        Debug.Notification("You are now a Succubus!")
        SuccubusLvl.SetValueInt(1)

        AddSpellsFromLevel(1)

        calcDamage = CalculateDamage()

        TattooScript.currTattooLvl = 1
        TattooScript.RefreshTattoo()

        main.TreatAsMale = !Outils.AppearsFemale(game.GetPlayer())
        main.OnLoadFunc()
        main.lastCheckedTime = main.GameDaysPassed.GetValue()
        main.UpdateLifeForce()
        RegisterForSingleUpdateGameTime(main.energyUpdateFreq)
    ElseIf SuccubusLvl.GetValueInt() < 8

        Debug.Notification("Succubus Level increased from " + SuccubusLvl.GetValueInt() + " to " + (SuccubusLvl.GetValueInt() + 1) )
        
        int sucLvl = SuccubusLvl.GetValueInt()

        CurrXp -= XpRequired
        
        XpRequired = (XpRequired * XpIncreaseValue)
        ;half as much xp required if on 'fast' setting
        CurrXp = PapyrusUtil.ClampFloat(CurrXp, 0, XpRequired)

        RemoveSpellsFromLevel(sucLvl)

        SuccubusLvl.SetValueInt(sucLvl + 1)
        sucLvl += 1

        AddSpellsFromLevel(sucLvl)

        calcDamage = CalculateDamage()

        If (sucLvl % 2) == 1
            TattooScript.currTattooLvl += 1
        EndIf
        TattooScript.RefreshTattoo()
    EndIf
EndFunction

;returns true if lvls up
bool Function CheckForLvlUp()
    If CurrXp >= XpRequired
        LevelUp()
        return true
    EndIf
    return false
EndFunction

;convenience function
bool Function IsSuccubus()
    If SuccubusLvl.GetValueInt() > 0
        return true
    EndIf
    return false
EndFunction

;convenience function
int Function CalculateDamage()
    return ((baseDamage + (damageIncrease * (SuccubusLvl.GetValueInt() - 1))) as int)
EndFunction

Function UnSuccuby()

    int suclvl = SuccubusLvl.GetValueInt()
    CurrXp = 0
    XpRequired = XpRequiredBase
    SuccubusLvl.SetValueInt(0)

    playerRef.RemoveSpell(SeductionFFAimed)
    playerRef.RemoveSpell(SpeechModifier)
    playerRef.RemoveSpell(SuccubusSoul[sucLvl])
    playerRef.RemoveSpell(DrainSpellLevels[sucLvl])
    playerRef.RemoveSpell(FortifyMagickaLevels[sucLvl])
    playerRef.RemoveSpell(FortifyMagickaRateLevels[sucLvl])

    If suclvl == 1
        playerRef.RemoveSpell(SpeechModifier)
        playerRef.RemoveSpell(SeductionFFAimed)

        If suclvl == 2
            playerRef.RemoveSpell(SuccubusWeakness)

            If suclvl == 3

                If suclvl == 4

                    If suclvl == 5

                        If suclvl == 6
                            
                            If suclvl == 7
                                playerRef.RemoveSpell(MassSeductionFFSelf)

                                If suclvl == 8

                                    ; code
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        endif
    EndIf


    main.OnLoadFunc()
    main.energyCurr = 400
    main.RefreshBuffsDebuffsEnergy()
    TattooScript.RefreshTattoo()
    Debug.Notification("You are no longer a Succubus!")
EndFunction

Function AddSpellsFromLevel(int lvl)

    playerRef.AddSpell(DrainSpellLevels[lvl], false)
    playerRef.AddSpell(SuccubusSoul[lvl], false)
    playerRef.AddSpell(FortifyMagickaLevels[lvl], false)
    playerRef.AddSpell(FortifyMagickaRateLevels[lvl], false)

    If lvl == 1
        playerRef.AddSpell(SpeechModifier, false)
        playerRef.AddSpell(SeductionFFAimed)
    ElseIf lvl == 2
        playerRef.AddSpell(Lust)
    ElseIf lvl == 3
        playerRef.AddSpell(ConsumeLifeForce)
    ElseIf lvl == 4
        playerRef.AddSpell(SucPower)
    ElseIf lvl == 5
        playerRef.AddSpell(command)
    ElseIf lvl == 6
        playerRef.AddSpell(SeductionArea)
    ElseIf lvl == 7
        playerRef.AddSpell(SuccubusWeakness)
    ElseIf lvl == 8
        playerRef.AddSpell(MassSeductionFFSelf)
    EndIf
EndFunction

Function RemoveSpellsFromLevel(int lvl)
    playerRef.RemoveSpell(SuccubusSoul[lvl])
    playerRef.RemoveSpell(DrainSpellLevels[lvl])
    playerRef.RemoveSpell(FortifyMagickaLevels[lvl])
    playerRef.RemoveSpell(FortifyMagickaRateLevels[lvl])
EndFunction

Function RefreshXpIncreaseValue()
    If progressSpeed == 1
        XpIncreaseValue = 1.5
    Else
        XpIncreaseValue = 2.0
    EndIf
EndFunction