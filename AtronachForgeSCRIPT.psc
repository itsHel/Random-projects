scriptname AtronachForgeSCRIPT extends objectReference

Import PO3_SKSEFunctions

formlist property RecipeList auto
{Master list of valid recipes. Most Complex should be first}
formlist property ResultList auto
{Master list of recipe results.  Indices of Rewards MUST MATCH those of the recipe list}
formlist property SigilRecipeList auto
{Recipes that are only available when sigil stone is installed}
formlist property SigilResultList auto
{Items attainable only with sigil stone installed}
objectReference  property createPoint auto
{Marker where we place created items}
objectReference property DropBox auto
{where the player places items to be crafted}
activator property summonFX auto
{Point to a fake summoning cloud activator}
objectReference property summonFXpoint auto
{Where we place the summoning FX cloud}
bool property sigilStoneInstalled auto hidden
{has the sigil stone been installed?}
objectReference property lastSummonedObject auto hidden
; store whatever we summoned last time to help clean up dead references.

Ingredient property strangeRemains auto

;MagicEffect[] property weaponEnchantments auto
;MagicEffect[] property armorEnchantments auto
MagicEffect[] property armorEnchantmentsSpecial auto

Formlist property keywordsArmorLevel1 auto
Formlist property keywordsArmorLevel2 auto
Formlist property keywordsArmorLevel3 auto
Formlist property keywordsArmorLevel4 auto

Formlist property keywordsWeaponLevel1 auto
Formlist property keywordsWeaponLevel2 auto
Formlist property keywordsWeaponLevel3 auto
Formlist property keywordsWeaponLevel4 auto

Formlist property weaponEnchantmentsWeak auto
Formlist property weaponEnchantmentsBest auto
Formlist property armorEnchantmentsWeak auto
Formlist property armorEnchantmentsBest auto
Formlist property armorEnchantmentsSpecialWeak auto
Formlist property armorEnchantmentsSpecialBest auto

SoulGem property blackSoulGem auto
Ingredient property voidSalts auto

Keyword Property disallowEnchantingKeyword Auto  
Keyword Property disallowSellingKeyword Auto  

Actor Property enchanter Auto  

Float randomDifference = 0.15

Event onLoad()
    debug.notification("insertedItems.length: ")
endEVENT

; 000CE734

STATE busy
    EVENT onActivate(objectReference actronaut)
    ; debug.trace("Atronach Forge is currently busy.  Try again later")
    endEVENT
endSTATE

auto STATE ready
    EVENT onActivate(objectReference actronaut)
        gotoState("busy")
        bool DaedricItemCrafted
        bool VanillaItemCrafted
        ; debug.notification("activat")
        ; first attempt to craft Daedric items if the Sigil Stone is installed
        ; debug.trace("Atronach Forge checking for Sigil Stone")
        if sigilStoneInstalled == TRUE
            ; debug.trace("Atronach Forge detected Sigil Stone, attempt Daedric Combines first")
            DaedricItemCrafted = scanForRecipes(SigilRecipeList, SigilResultList)
            utility.wait(0.1)
        endif

        ; if no sigil stone, or if we checked and found no valid Daedric recipes...
        if sigilStoneInstalled == FALSE || DaedricItemCrafted == FALSE
        ; debug.trace("Atronach Forge Either did not detect Sigil Stone, or no deadric combines were found")
            VanillaItemCrafted = ScanForRecipes(RecipeList, ResultList)
        endif
        if VanillaItemCrafted == FALSE && DaedricItemCrafted == FALSE
            ScanForEnchantments(RecipeList, ResultList)
        endif


        gotoState("ready")

    endEVENT
endSTATE

bool FUNCTION ScanForRecipes(formlist Recipes, formList Results)

    ; set up our counter vars
    int i = 0
    int t = Recipes.getSize()
    bool foundCombine = FALSE
    bool checking = TRUE

    ;========================================================

    While checking == TRUE && i < t
        formlist currentRecipe = (Recipes.getAt(i)) as formList
        if currentRecipe == NONE
            ; debug.trace("ERROR: Atronach Forge trying to check a NONE recipe")
            else
            if scanSubList(currentRecipe) == TRUE
                ; I have found a valid recipe
                ; debug.trace("Atronach Forge found ingredients for "+currentRecipe)
                removeIngredients(currentRecipe)
                foundCombine = TRUE
                checking = FALSE
                else
                ; found nothing
            endif
        endif

        if foundCombine == FALSE
            ; only increment if we are continuing to loop
            i += 1
        endif

    endWhile


    if foundCombine == TRUE
        ; we found a valid item, so create it!
        ; debug.trace("Attempting to spawn a "+Results.getAt(i))
        summonFXpoint.placeatme(summonFX);summonFX.playGamebryoAnimation("mIdle")
        utility.wait(0.33)
        ;debug.notification(Results.getAt(i))
        objectReference newREF = createPoint.placeAtMe(Results.getAt(i))

        ; if the last thing I summoned is a dead actor, just get rid of it.
        if (lastSummonedObject)
            if ((lastSummonedObject as actor).isDead())
                ; transfer any items to the offering box (just in case I had anything valuable on me!)
                lastSummonedObject.RemoveAllItems(DropBox, FALSE, TRUE)
                lastSummonedObject.disable()
                lastSummonedObject.delete()
            endif
        endif

        ; now store whatever we just created as the current/last summoned object
        lastSummonedObject = newREF

        if (newREF as actor) != NONE
            (newREF as actor).startCombat(game.getPlayer())
        endif

        return TRUE
    else
        ; did not find any valid combines - choose a "failure" scenario
        return FALSE
    endif

endFUNCTION
;========================================================
;========================================================
;========================================================
bool FUNCTION scanSubList(formList recipe)
    int size = recipe.getSize()
    int cnt = 0

    while cnt < size
        form toCheck = recipe.getAt(cnt)
        if dropBox.getItemCount(toCheck) < 1 
            ;debug.notification(toCheck)
            ;debug.notification(toCheck.GetName())
            ; ;debug.trace("Did not have item "+toCheck+" ("+cnt+") for recipe #"+recipe)
            return FALSE

            ; ;debug.trace("I Have item "+toCheck+" ("+cnt+") for recipe #"+recipe)
            ; we have the item in cnt
        endif
        cnt += 1
    endWhile

    return TRUE

endFUNCTION

FUNCTION removeIngredients(formlist recipe)
    int size = recipe.getSize()
    int cnt = 0

    while cnt < size
        form toCheck = recipe.getAt(cnt)
        dropBox.removeItem(toCheck, 1)
        ; debug.trace("Atronach Forge is consuming "+toCheck)
        cnt += 1
    endWhile
endFUNCTION



bool FUNCTION ScanForEnchantments(formlist Recipes, formList Results)
;    if(insertedItems.length != 1)
;        debug.notification("Seems like recipe is wrong...")
;        return false
;    endif

	int size = dropBox.GetNumItems()
	; int size = recipe.getSize()
	int i = 0
	debug.notification(size)

objectReference newREF
; here *************
	while i < size
        		debug.notification("materialLevel " +i)
		Weapon removedWeapon = dropBox.GetNthForm(i) as Weapon
		Armor removedArmor = dropBox.GetNthForm(i) as Armor
	;	objectReference obj = dropBox.GetNthForm(i) as objectReference
	;	debug.notification(obj)
	;	obj.moveto(createPoint, 0,0,0,false)

		if(removedWeapon)
            dropBox.RemoveItem(removedWeapon, 1, true, game.getPlayer())

			int randomEnchIndex = Utility.RandomInt(0, weaponEnchantmentsWeak.GetSize() - 1)
			int materialLevel = getWeaponMaterialLevel(removedWeapon)
			float enchStrength = getEnchStrenght(randomEnchIndex, materialLevel, true)

			;debug.notification("enchIndex" + randomEnchIndex)
    		debug.notification("materialLevel " + materialLevel)
    		debug.notification("enchStrength " + enchStrength)


return false

        EnchantmentCheck(dropBox.GetNthForm(i))
			newREF = createPoint.placeAtMe(removedWeapon)
			debug.notification("weapon")
            i = size
;return true
			

		elseif(removedArmor)
         i = size
		    int materialLevel = getArmorMaterialLevel(removedWeapon)
			debug.notification("armor")
			newREF = createPoint.placeAtMe(removedArmor)

		endif

		i += 1
	endWhile


	;========================================================


	; we found a valid item, so create it!
	; debug.trace("Attempting to spawn a "+Results.getAt(i))
	summonFXpoint.placeatme(summonFX);summonFX.playGamebryoAnimation("mIdle")
	utility.wait(0.33)
	;debug.notification(Results.getAt(i))
newREF = createPoint.placeAtMe(Results.getAt(i))

AddKeywordToRef(newREF, disallowEnchantingKeyword) 
AddKeywordToRef(newREF, disallowSellingKeyword) 

	; transfer any items to the offering box (just in case I had anything valuable on me!)
	lastSummonedObject.RemoveAllItems(DropBox, FALSE, TRUE)
	lastSummonedObject.disable()
	lastSummonedObject.delete()

	; now store whatever we just created as the current/last summoned object
	lastSummonedObject = newREF

	int[] durations = new int[1]
	durations[0] = 2
	int[] areas = new int[1]
	areas[0] = 10
	float[] magnitudes = new float[1]
	magnitudes[0] = 30.0

	float maxCharge = 1000.0



	;newREF.SetEnchantment(enchantments[0], 100)
;	enchantment e = newREF.CreateEnchantment(maxCharge, weaponEnchantments,magnitudes , areas , durations )
;	debug.notification(newREF)
;	debug.notification((newREF as form).HasKeyword(keywordsLevel1[0]))
;	debug.notification(weaponEnchantments[0])

	if (newREF as actor) != NONE
	(newREF as actor).startCombat(game.getPlayer())
	endif

	return TRUE
EndFunction

int Function getArmorMaterialLevel(Form item)
    int minGoldValueForArmorLevel2 = 100
    int minGoldValueForArmorLevel3 = 1500

	int i = 0
	;int keywordsTotal = keywordsLevel1.length + keywordsLevel2.length + keywordsLevel3.length + keywordsLevel4.length

    int keywordCount = item.GetNumKeywords()
	while i < keywordCount

        if(keywordsArmorLevel1.HasForm(item.GetNthKeyword(i)))
			return 0
	    elseif(keywordsArmorLevel2.HasForm(item.GetNthKeyword(i)))
	        return 1
	    elseif(keywordsArmorLevel3.HasForm(item.GetNthKeyword(i)))
	        return 2
	    elseif(keywordsArmorLevel4.HasForm(item.GetNthKeyword(i)))
	        return 3
        else                   
            ; decide by value if no keywords found
            if(item.GetGoldValue() < minGoldValueForArmorLevel2)
                return 0
            elseif(item.GetGoldValue() < minGoldValueForArmorLevel3)   
                return 1
            else
                return 2
            endif     
		endif
		i += 1
	endWhile
EndFunction

int Function getWeaponMaterialLevel(Form item)
    int minGoldValueForWeaponLevel2 = 300
    int minGoldValueForWeaponLevel3 = 4500

	int i = 0
	;int keywordsTotal = keywordsLevel1.length + keywordsLevel2.length + keywordsLevel3.length + keywordsLevel4.length

    int keywordCount = item.GetNumKeywords()
	while i < keywordCount

        if(keywordsWeaponLevel1.HasForm(item.GetNthKeyword(i)))
			return 0
	    elseif(keywordsWeaponLevel2.HasForm(item.GetNthKeyword(i)))
	        return 1
	    elseif(keywordsWeaponLevel3.HasForm(item.GetNthKeyword(i)))
	        return 2
	    elseif(keywordsWeaponLevel4.HasForm(item.GetNthKeyword(i)))
	        return 3
        else                   
            ; decide by value if no keywords found
            if(item.GetGoldValue() < minGoldValueForWeaponLevel2)
                return 0
            elseif(item.GetGoldValue() < minGoldValueForWeaponLevel3)   
                return 1
            else
                return 2
            endif  
		endif
		i += 1
	endWhile
EndFunction

bool Function ScanForEnchIngredients(int voidsaltsCount)
	if (dropBox.getItemCount(blackSoulGem) >= 1 && dropBox.getItemCount(voidSalts) >= voidsaltsCount)
		return TRUE
	else
		return false
	EndIf
EndFunction


Float Function getEnchStrenght(int index, int level, bool isWeapon)
    float strength
    float step

	if(isWeapon)
		step = ((weaponEnchantmentsBest.getAt(index) as Enchantment).GetNthEffectMagnitude(0) - (weaponEnchantmentsWeak.getAt(index) as Enchantment).GetNthEffectMagnitude(0)) / 3
		strength = (weaponEnchantmentsWeak.getAt(index) as Enchantment).GetNthEffectMagnitude(0) + (step * level)
    else
        step = ((armorEnchantmentsBest.getAt(index) as Enchantment).GetNthEffectMagnitude(0) - (armorEnchantmentsWeak.getAt(index) as Enchantment).GetNthEffectMagnitude(0)) / 3
		strength = (armorEnchantmentsWeak.getAt(index) as Enchantment).GetNthEffectMagnitude(0) + (step * level)
    endif

	return Utility.RandomFloat(strength * (1 - randomDifference), strength * (1 + randomDifference))
EndFunction


Function EnchantmentCheck(Form First)
	Enchanter.EquipItem(First)

	Enchantment TempEnchantmentBase = None
	Enchantment TempEnchantmentSpecial = None
	float ItemTempering = 0.0

	if ( First.GetType() == 41 )
		TempEnchantmentBase = (First as Weapon).GetEnchantment()
		TempEnchantmentSpecial = WornObject.GetEnchantment(Game.getPlayer(), 1, 0)
		ItemTempering = WornObject.GetItemHealthPercent(Game.getPlayer(), 1, 0)
	Else
		TempEnchantmentBase = (First as Armor).GetEnchantment()		
		Int SlotMask = (First as Armor).GetSlotMask()
		TempEnchantmentSpecial = WornObject.GetEnchantment(Game.getPlayer(), 0, SlotMask)
		ItemTempering = WornObject.GetItemHealthPercent(Game.getPlayer(), 0, SlotMask)
	EndIf

	debug.notification(" TempEnchantmentBase " + TempEnchantmentBase)
	debug.notification(" TempEnchantmentSpecial " + TempEnchantmentSpecial)
	debug.notification(" ItemTempering " + ItemTempering)
EndFunction


;step = (best - worst) / 3
;MagicEffect GetNthEffectMagicEffect(Int index)






;/
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
return
    debug.notification("insertedItems.length: ")

DropObject(akItemReference)
    if(insertedItems)
        if((akBaseItem as weapon) || (akBaseItem as armor))
            int i = 0

            while i < aiItemCount
                insertedItems[insertedItems.length] = akItemReference
                i += 1
            endwhile
        endif
    else
    ; breaks if more than 128 items are inserted
        insertedItems = new ObjectReference[128]
    endif

    debug.notification("insertedItems.length: " + insertedItems.length)
endEVENT

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
return
    if(insertedItems)
        if((akBaseItem as weapon) || (akBaseItem as armor))
            int i = 0
            int foundAt = -1
            int totalLength = insertedItems.length
            

         ;   while i < totalLength
         ;       foundAt = insertedItems.find(akItemReference)
;
           ;     if(foundAt >= 0)
        ;            insertedItems.removeItem(akItemReference)
         ;       endif
         ;       i += 1
         ;   endwhile
        endif
    else
    ; breaks if more than 128 items are inserted
        insertedItems = new ObjectReference[128]
    endif

    debug.notification("insertedItems.length: " + insertedItems.length)
endEVENT
/;