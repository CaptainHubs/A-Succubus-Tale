Scriptname ASTPlayerAliasScript extends ReferenceAlias  

ASTMainScript main

Event OnInit()
    main = GetOwningQuest() as ASTMainScript
EndEvent

Event OnPlayerLoadGame()
    main.OnLoadFunc()
EndEvent