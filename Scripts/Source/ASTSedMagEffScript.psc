Scriptname ASTSedMagEffScript extends activemagiceffect  

; Variables
;---------------------------------------------

bool running = false

;/ Creation Kit References /;

Package Property FollowPlayer Auto
ASTMainScript Property main Auto

;/ Config /;

float Property distance = 160.0 Auto
float Property distanceMax = 700.0 Auto

;/ Scripts References /;

OSexIntegrationMain ostim

; Events
;---------------------------------------------

Event OnInit()
    ostim = OUtils.GetOStim()
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
    ActorUtil.AddPackageOverride(akTarget, FollowPlayer, 100)
    akTarget.EvaluatePackage()
    If main.isOArousedInstalled
        main.modifyArousal(akTarget, main.arousalGainf)
    EndIf

    int limit = 0
    While (distance < akCaster.GetDistance(akTarget)) && (limit < 75)
        Utility.Wait(0.2)
        limit += 1
    EndWhile

    If akCaster.GetDistance(akTarget) > distanceMax
        ;ASTMainScript.AstConsole("Distance from " + akCaster + " to " + akTarget + " is " + akCaster.GetDistance(akTarget))
        ActorUtil.RemovePackageOverride(akTarget, FollowPlayer)
        akTarget.EvaluatePackage()
        Dispel()
    Else
        While !main.MSRTAliasQuest.Start()
            ASTMainScript.AstConsole("Cant Start Quest!!!")
            Utility.Wait(0.1)
        EndWhile
        
        Actor dom
        Actor sub
        If Outils.AppearsFemale(akCaster) || main.TreatAsMale
            dom = akTarget
            sub = akCaster
        Else
            dom = akCaster
            sub = akTarget
        EndIf

        StorageUtil.FormListAdd(none, "SuccubusQueueDom", dom)
        StorageUtil.FormListAdd(none, "SuccubusQueueSub", sub)

        Utility.Wait(main.WaitForThreesomeTime)

        If main.StartSceneShiftQueue()
            ActorUtil.RemovePackageOverride(akTarget, FollowPlayer)
            akTarget.EvaluatePackage()
            Dispel()
        Else
            Utility.Wait(GetDuration() - GetTimeElapsed() - 5)

            StorageUtil.FormListRemove(none, "SuccubusQueueDom", dom)
            StorageUtil.FormListRemove(none, "SuccubusQueueSub", sub)
            ActorUtil.RemovePackageOverride(akTarget, FollowPlayer)
            akTarget.EvaluatePackage()
        EndIF
    EndIf
EndEvent

; Event OnEffectFinish(Actor akTarget, Actor akCaster)
;     StorageUtil.FormListRemove(none, "SuccubusQueueDom", akTarget)
;     StorageUtil.FormListRemove(none, "SuccubusQueueSub", akCaster)
;     ActorUtil.RemovePackageOverride(akTarget, FollowPlayer)
;     akTarget.EvaluatePackage()
; EndEvent

; Functions
;---------------------------------------------

