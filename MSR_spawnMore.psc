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

FormList property listOfNPCs auto

Event OnLoad()
	string[] IgnoredNamesList = new string[4]
	IgnoredNamesList[0] = "Yngvild Ghost"
	IgnoredNamesList[1] = "Soul"
	IgnoredNamesList[2] = "Subjugated Ghost"
	IgnoredNamesList[3] = "Ghostly Adventurer"

	Actor spawn = Self As Actor

	If (!(IgnoredNamesList.Find(spawn.GetDisplayName()) < 0))
	  Return
	EndIf
	
	If(spawn.IsDead() || spawn.IsGhost() || alreadySpawned || spawn.GetAV("IgnoreCrippledLimbs") == -1 || spawn.IsCommandedActor() == 1 || !spawn.IsHostileToActor(Game.GetPlayer()))
		Return
	EndIf

	spawnExtras(spawn, spawnNPC)
	alreadySpawned = True
EndEvent

Function SpawnExtras(Actor oldSpawnRef, ActorBase toSpawn)
	string[] ToRenameNamesList = new string[4]
	ToRenameNamesList[0] = "Silver Hand"
	ToRenameNamesList[1] = "Corsair"
	ToRenameNamesList[2] = "Blood Horker"
	ToRenameNamesList[3] = "Blackblood Marauder"

	ActorBase finalSpawn = toSpawn
	Bool isHardLocation = False

	If(bonusLocations.HasForm(GetCurrentLocation()))
		If(spawnNPCstrong)
			finalSpawn = spawnNPCstrong
		EndIf
		isHardLocation = True
	EndIf
	
	Int numSpawns = getSpawnNum(isHardLocation) As Int
	;Debug.Notification("numSpawns: " + numSpawns)
	;Debug.Notification("GetDisplayName(): " + oldSpawnRef.GetDisplayName())
	
	Faction[] oldFactions = oldSpawnRef.GetFactions(-128, 127)
	
	Int i = 0
	While(i < numSpawns)
		Wait(0.1)
		Actor newSpawn = PlaceActorAtMe(finalSpawn)
		; To prevent script from working on NPC spawned by it
		newSpawn.SetAV("IgnoreCrippledLimbs", -1)
		newSpawn.AddToFaction(oldFactions[0])

		If (!(ToRenameNamesList.Find(oldSpawnRef.GetDisplayName()) < 0))
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
