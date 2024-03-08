ScriptName MSR_spawnMore Extends Actor 

Import Utility

ActorBase Property spawnNPC Auto
ActorBase Property spawnNPCstrong Auto
GlobalVariable Property spawnChance Auto
GlobalVariable Property spawnInteriorChance Auto
GlobalVariable Property doubleSpawnChance Auto
GlobalVariable Property hardLocationMult Auto
FormList Property bonusLocations Auto

Bool alreadySpawned = False

Event OnLoad()
	Actor spawn = Self As Actor
	
	If(alreadySpawned || spawn.IsDead() || spawn.IsGhost() || spawn.GetActorValue("IgnoreCrippledLimbs") == -1 || spawn.IsCommandedActor() == 1)
		alreadySpawned = True
		Return
	EndIf

	string[] ignoredNamesList = new string[4]
	ignoredNamesList[0] = "Yngvild Ghost"
	ignoredNamesList[1] = "Soul"
	ignoredNamesList[2] = "Subjugated Ghost"
	ignoredNamesList[3] = "Ghostly Adventurer"

	string spawnName = spawn.GetDisplayName()

	If (!(ignoredNamesList.Find(spawnName) < 0))
		alreadySpawned = True
	  	Return
	EndIf

	; Dustman's Cairn check
	If (spawnName == "Silver Hand" && !spawn.IsHostileToActor(Game.GetPlayer()))
		alreadySpawned = True
	  	Return
	EndIf

	spawnExtras(spawn, spawnNPC)
	alreadySpawned = True
EndEvent

Function SpawnExtras(Actor oldSpawnRef, ActorBase toSpawn)
	ActorBase finalSpawn = toSpawn
	Bool isHardLocation = False

	If(bonusLocations.HasForm(GetCurrentLocation()))
		If(spawnNPCstrong)
			finalSpawn = spawnNPCstrong
		EndIf
		isHardLocation = True
	EndIf
	
	Int numSpawns = getSpawnNum(isHardLocation)
	;Debug.Notification("numSpawns: " + numSpawns)
	;Debug.Notification("GetDisplayName(): " + oldSpawnRef.GetDisplayName())

	If(numSpawns == 0)
		Return
	EndIf
	
	Faction[] oldFactions = oldSpawnRef.GetFactions(-128, 127)
	
	string[] toRenameNamesList = new string[4]
	toRenameNamesList[0] = "Silver Hand"
	toRenameNamesList[1] = "Corsair"
	toRenameNamesList[2] = "Blood Horker"
	toRenameNamesList[3] = "Blackblood Marauder"

	Int i = 0
	While(i < numSpawns)
		Wait(0.1)
		Actor newSpawn = PlaceActorAtMe(finalSpawn)
		; To prevent script from working on NPC spawned by it
		newSpawn.SetAV("IgnoreCrippledLimbs", -1)
		newSpawn.AddToFaction(oldFactions[0])

		If (!(toRenameNamesList.Find(oldSpawnRef.GetDisplayName()) < 0))
			newSpawn.SetDisplayName(oldSpawnRef.GetDisplayName())
		EndIf

		i += 1
	EndWhile
EndFunction 

Int Function getSpawnNum(Bool isHardLocation)
	Float spawnChanceFinal

	If(spawnInteriorChance && IsInInterior())
		spawnChanceFinal = spawnInteriorChance.GetValueInt()
	Else
		spawnChanceFinal = spawnChance.GetValueInt()
	EndIf
	
	If(isHardLocation && hardLocationMult)
		spawnChanceFinal *= hardLocationMult.GetValue()
	EndIf
	
	Int Random = Utility.RandomInt(1, 100)

	;Debug.Notification("spawnChanceFinal: " + spawnChanceFinal)
	
	If(Random <= spawnChanceFinal)
		If(isHardLocation && doubleSpawnChance && Random <= doubleSpawnChance.GetValueInt())
			Return 2
		Else
			Return 1
		EndIf
	Else
		Return 0
	EndIf
EndFunction
