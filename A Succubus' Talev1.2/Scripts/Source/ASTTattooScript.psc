Scriptname ASTTattooScript extends Quest 

; Variables
;---------------------------------------------

bool property enableGlow = true Auto
bool property usesMaleTextures = false Auto
; bool property usesSam = false Auto
bool property fixedTattoo = false Auto
int property currTattooIndex = 2 Auto
int Property TattoosCount = 10 Auto
int Property currTattooLvl = 1 Auto
string TattooNode


OSexIntegrationMain ostim
ASTMainScript main
ASTLvlManager LevelManager

; Events
;---------------------------------------------

Event OnInit()
    ostim = Outils.GetOStim()
    main = (Self as Quest) as ASTMainScript
	LevelManager = (self as Quest) as ASTLvlManager
EndEvent

; Functions
;---------------------------------------------

;Applies succubus tattoo to an Actor
Function ApplyTattoo(Actor act)
    bool gender = ostim.AppearsFemale(act)
    int slot = GetEmptySlot(act, gender, "Body")
    TattooNode = "Body" + " [ovl" + slot + "]"
    console("Applying tattoo to node: " + TattooNode)

	; string sosPrefix = ""
	string MalePrefix = ""
	If !gender || usesMaleTextures
		MalePrefix = "Male"
		; sosPrefix = "sos"
		; If usesSam
		; 	sosPrefix = ""
		; EndIf
	EndIf

	int tatLvlTemp = (currTattooLvl - 1) * ( (!fixedTattoo) as int) ; will be zero if tatto is fixed
    string TextureToApply = "Tattoos\\" + MalePrefix + GetTattooNameFromIndex(currTattooIndex + tatLvlTemp) + ".dds"

    int EmColor = 0xFFFF00FF ;pink/violet

    NiOverride.AddNodeOverrideString(act, Gender, TattooNode, 9, 0, TextureToApply, true) ;textures
    NiOverride.AddNodeOverrideInt(act, Gender, TattooNode, 0, -1, EmColor, true) ;ShaderEmissiveColor
    ;NiOverride.AddNodeOverrideInt(act, Gender, Node, 7, -1, TintColor, true) ;ShaderTintColor
    NiOverride.AddNodeOverrideFloat(act, Gender, TattooNode, 8, -1, 0.8, true) ;ShaderAlpha
	NiOverride.AddNodeOverrideFloat(act, Gender, TattooNode, 2, -1, 0, true) ;ShaderGlossiness
	NiOverride.AddNodeOverrideFloat(act, Gender, TattooNode, 3, -1, 1, true) ;ShaderSpecularStrength
	
	If enableGlow
		NiOverride.AddNodeOverrideFloat(act, Gender, TattooNode, 1, -1, 0.5, true) ;ShaderEmissiveMultiple
	Else
		NiOverride.AddNodeOverrideFloat(act, Gender, TattooNode, 1, -1, 0.0, true) ;ShaderEmissiveMultiple
	EndIf

    NiOverride.ApplyNodeOverrides(act)
EndFunction

Function RemoveTattoo(Actor act)
    
	ASTMainScript.AstConsole("Removing tattoo")

	bool Gender = ostim.AppearsFemale(act)
	int i = 0
	int max = NiOverride.GetNumBodyOverlays()

	while i < max 
		String Node = "Body" + " [ovl" + i + "]"

		string tex = NiOverride.GetNodeOverrideString(act, Gender, Node, 9, 0)

		If ostim.StringContains(tex, "SucTattoo")
			NiOverride.AddNodeOverrideString(act, Gender, Node, 9, 0, "actors\\character\\overlays\\default.dds", false)
    		NiOverride.RemoveNodeOverride(act, Gender, Node , 9, 0) ;textures
    		NiOverride.RemoveNodeOverride(act, Gender, Node, 0, -1) ;ShaderEmissiveColor
    		NiOverride.RemoveNodeOverride(act, Gender, Node, 8, -1) ;ShaderAlpha
			NiOverride.RemoveNodeOverride(act, Gender, Node, 2, -1) ;ShaderGlossiness
			NiOverride.RemoveNodeOverride(act, Gender, Node, 3, -1) ;ShaderSpecularStrength
    		NiOverride.RemoveNodeOverride(act, Gender, Node, 1, -1) ;ShaderEmissiveMultiple

		EndIf

		i += 1
	endwhile

EndFunction

;kinda yoinked this from ocum
Int Function GetEmptySlot(Actor akTarget, Bool Gender, String Area)
	Int i = 0
	Int NumSlots = GetNumSlots(Area)
	String TexPath
	Bool FirstPass = true

	While i < NumSlots
		TexPath = NiOverride.GetNodeOverrideString(akTarget, Gender, Area + " [ovl" + i + "]", 9, 0)
		console(TexPath)
		If TexPath == "" || TexPath == "actors\\character\\overlays\\default.dds"
			console("Slot " + i + " chosen for area: " + area)
			Return i
		EndIf
		i += 1
		If !FirstPass && i == NumSlots
			FirstPass = true
			i = 0
		EndIf
	EndWhile
	Return -1
EndFunction

;oh and this too ;)
Int Function GetNumSlots(String Area)
	If Area == "Body"
		Return NiOverride.GetNumBodyOverlays()
	ElseIf Area == "Face"
		Return NiOverride.GetNumFaceOverlays()
	ElseIf Area == "Hands"
		Return NiOverride.GetNumHandOverlays()
	Else
		Return NiOverride.GetNumFeetOverlays()
	EndIf
EndFunction

Function Console(string in) Global
	MiscUtil.PrintConsole("A Succubus' tale: " + In)
EndFunction

;Applies or removes a Tattoo depending on user settings and succubus status
Function RefreshTattoo()
	If main.usesTatoo && LevelManager.IsSuccubus()
		RemoveTattoo(game.GetPlayer())
		ApplyTattoo(Game.GetPlayer())
    Else
        RemoveTattoo(Game.GetPlayer())
    EndIf
EndFunction

string Function GetTattooNameFromIndex(int i)
	; If i == 0
	; 	return "SucTattooDefault"
	If i == 0
		return "SucTattooGradNoWings"
	; ElseIf i == 2
	; 	return "SucTattooGradNoSides"
	; ElseIf i == 3
	; 	return "SucTattooGradBorders"
	; ElseIf i == 4
	; 	return "SucTattooPinkBorders"
	; ElseIf i == 5
	; 	return "SucTattooGradNoSidesWithWings"
	ElseIf i == 1
		return "SucTattooGrad"
	ElseIf i == 2
		return "SucTattooMediumlvl1"
	ElseIf i == 3
		return "SucTattooMediumlvl2"
	ElseIf i == 4
		return "SucTattooMediumlvl3"
	ElseIf i == 5
		return "SucTattooMediumlvl4"
	ElseIf i == 6
		return "SucTattooSmalllvl1"
	ElseIf i == 7
		return "SucTattooSmalllvl2"
	ElseIf i == 8
		return "SucTattooSmalllvl3"
	ElseIf i == 9
		return "SucTattooSmalllvl4"
	EndIf
EndFunction

Function LevelUpTattoo()
	If !fixedTattoo && currTattooLvl != 4
		currTattoolvl += 1
	EndIf
EndFunction
