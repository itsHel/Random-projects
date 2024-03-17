scriptname AtronachForgeSCRIPT extends ObjectReference

Import PO3_SKSEfunctions

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
; 0 - fire damage
; 1 - frost damage
; 2 - shock damage
; 3 - soul trap
; 4 - paralyze
; 5 - fear
; 6 - stamina absorb
; 7 - magicka absorb
; 8 - health absorb
; 9 - chaos damage
; 10 - banish
; 11 - turn undead

Formlist property helmEnchantmentsWeak auto
Formlist property helmEnchantmentsBest auto
Formlist property gauntletsEnchantmentsWeak auto
Formlist property gauntletsEnchantmentsBest auto
Formlist property cuirassEnchantmentsWeak auto
Formlist property cuirassEnchantmentsBest auto
Formlist property bootsEnchantmentsWeak auto
Formlist property bootsEnchantmentsBest auto
Formlist property shieldEnchantmentsWeak auto
Formlist property shieldEnchantmentsBest auto
Formlist property armorEnchantmentsSpecialWeak auto
Formlist property armorEnchantmentsSpecialBest auto
; 0 - fortify onehanded
; 1 - fortify twohanded
; 2 - fortify conjuration
; 3 - fortify destruction
; 4 - fortify illusion
; 5 - fortify restoration
; 6 - fortify alteration
; 7 - resist fire
; 8 - resist shock
; 9 - resist frost

MagicEffect property banishDamageMgef auto
MagicEffect property turnUndeadDamageMgef auto

SoulGem property blackSoulGem auto
Ingredient property voidSalts auto
Ingredient property briarHeart auto

Keyword property disallowEnchantingKeyword auto  
Keyword property disallowSellingKeyword auto  
Keyword[] property armorKeywords Auto
; 0 - helm
; 1 - cuirass
; 2 - gauntlets
; 3 - boots
; 4 - shield

Actor property enchanter auto 

Float randomDifference = 0.15
String wrongRecipeMessage = "This recipe doesn't seem to be valid..." 

; 000CE734
	
;	-* check if no ingredient		- item isnt returned
;	-* check if disenchanting		- item isnt returned
;	- armor
;	-* maxcharge calc    1500+
;	-* special weapon enchs
;			-* banish daedra		60 80 100			- chech helltweaks for values
;			-* banish undead		15 20 30 35			- chech helltweaks for values

;   - bit better lvl0 enchs
;   - special weapon enchs no autocalc + cost to 0
;   - special weapon enchs duration 0 OR 1
;   - briarheart not working
;   - disenchanting - check if has keyword no disench
;   - check multiple items
;   - Bool SetDisplayName(Actor akActor, Int handSlot, Int slotMask, String name, Bool forced)
;   - poison


state busy
    event onActivate(objectReference actronaut)
    ; debug.trace("Atronach Forge is currently busy.  Try again later")
    endEvent
endState

auto state ready
    event onActivate(objectReference actronaut)
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
        endIf

        ; if no sigil stone, or if we checked and found no valid Daedric recipes...
        if sigilStoneInstalled == FALSE || DaedricItemCrafted == FALSE
        ; debug.trace("Atronach Forge Either did not detect Sigil Stone, or no deadric combines were found")
            VanillaItemCrafted = ScanForRecipes(RecipeList, ResultList)
        endIf
        if VanillaItemCrafted == FALSE && DaedricItemCrafted == FALSE
            ScanForEnchantments(RecipeList, ResultList)
        endIf

        setToDefaultState()

        gotoState("ready")
    endEvent
endState

bool function scanForRecipes(formlist recipes, formList results)

    ; set up our counter vars
    int i = 0
    int t = recipes.getSize()
    bool foundCombine = FALSE
    bool checking = TRUE

    ;========================================================

    while checking == TRUE && i < t
        formlist currentRecipe = (recipes.getAt(i)) as formList
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
            endIf
        endIf

        if foundCombine == FALSE
            ; only increment if we are continuing to loop
            i += 1
        endIf

    endWhile


    if foundCombine == TRUE
        ; we found a valid item, so create it!
        ; debug.trace("Attempting to spawn a "+Results.getAt(i))
        summonFXpoint.placeAtMe(summonFX);summonFX.playGamebryoAnimation("mIdle")
        utility.wait(0.33)
        ;debug.notification(Results.getAt(i))
        objectReference createdItemREF = createPoint.placeAtMe(results.getAt(i))

        ; if the last thing I summoned is a dead actor, just get rid of it.
        if (lastSummonedObject)
            if ((lastSummonedObject as actor).isDead())
                ; transfer any items to the offering box (just in case I had anything valuable on me!)
                lastSummonedObject.RemoveAllItems(DropBox, FALSE, TRUE)
                lastSummonedObject.disable()
                lastSummonedObject.delete()
            endIf
        endIf

        ; now store whatever we just created as the current/last summoned object
        lastSummonedObject = createdItemREF

        if (createdItemREF as actor) != NONE
            (createdItemREF as actor).startCombat(game.getPlayer())
        endIf

        return TRUE
    else
        ; did not find any valid combines - choose a "failure" scenario
        return FALSE
    endIf
endFunction

;========================================================
;========================================================
;========================================================
bool function scanSubList(formList recipe)
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
        endIf
        cnt += 1
    endWhile

    return TRUE
endFunction

function removeIngredients(formlist recipe)
    int size = recipe.getSize()
    int cnt = 0

    while cnt < size
        form toCheck = recipe.getAt(cnt)
        dropBox.removeItem(toCheck, 1)
        ; debug.trace("Atronach Forge is consuming "+toCheck)
        cnt += 1
    endWhile
endFunction

bool function ScanForEnchantments(formlist recipes, formList results)
    objectReference createdItemREF
    int randomEnchIndex
    int enchDuration
    int materialLevel
    float itemTempering
    float enchStrength
    form removedItem
    weapon removedWeapon
    armor removedArmor

	int size = dropBox.GetNumItems()
	int i = 0

    ; looking for item to enchant
	while i < size
		removedWeapon = dropBox.getNthForm(i) as weapon
		removedArmor = dropBox.getNthForm(i) as armor

		if(removedWeapon)
            removedItem = removedWeapon

            dropBox.removeItem(removedWeapon, 1, TRUE, enchanter )
            
			randomEnchIndex = utility.randomInt(0, weaponEnchantmentsWeak.getSize() - 1)

			materialLevel = getMaterialLevel(removedWeapon, TRUE)
            int voidSaltsNeeded = materialLevel + 1

			enchStrength = getEnchStrenght(randomEnchIndex, materialLevel, TRUE)
			enchDuration = getEnchDuration(randomEnchIndex, materialLevel, TRUE)

		;	debug.notification("enchIndex" + randomEnchIndex)
    	;	debug.notification("materialLevel " + materialLevel)
    	;	debug.notification("enchStrength " + enchStrength)
    		debug.notification("enchDuration " + enchDuration)
    		;debug.notification("ingredientsMatch " + ingredientsMatch)

            enchanter.equipItem(removedWeapon)
            utility.wait(0.1)
            if(enchanter.wornHasKeyword(disallowEnchantingKeyword))
                enchanter.RemoveItem(removedWeapon, 1, false, dropBox)
                debug.notification(wrongRecipeMessage)
                return false
            endIf
            
            ; 0 - isnt enchanted, 1 - has base enchantment, 2 - has player made enchantment
            itemTempering = temperingCheck(removedWeapon)
            int itemOldEnchantment = enchantmentCheck(removedWeapon)

            if(itemOldEnchantment == 1)
                debug.notification("1 - has base enchantment")
;Form ItemToRemove = Enchanter.GetNthForm(0)
                enchanter.RemoveItem(removedWeapon, 1, false, dropBox)
                ;enchanter.RemoveItem(removedWeapon, 1, TRUE, dropBox)
                debug.notification(wrongRecipeMessage)
                return FALSE
            elseif(itemOldEnchantment == 2)
                debug.notification("2 - has player made enchantment")
                if(dropBox.getItemCount(briarHeart) > 0 || true)        ; TEMP
                    dropBox.removeItem(briarHeart, 1)
                    disenchant(removedWeapon, itemTempering)
                    return TRUE
                else
                    enchanter.RemoveItem(removedItem, 1, false, dropBox)
                    debug.notification(wrongRecipeMessage)
                    return FALSE
                endIf
                ;enchanter.RemoveItem(removedWeapon, 1, false, Game.GetPlayer())
               ; disenchant(removedWeapon, itemTempering)
                ;setToDefaultState()
            endIf
            debug.notification("0 - isnt enchanted")

            bool ingredientsMatch = ScanAndRemoveEnchIngredients(voidSaltsNeeded)
            if(!ingredientsMatch)
                enchanter.RemoveItem(removedWeapon, 1, false, dropBox)
                ;enchanter.RemoveItem(removedWeapon, 1, TRUE, dropBox)
                debug.notification(wrongRecipeMessage)
                return FALSE
            endIf

			debug.notification("weapon")
            i = size			

		elseIf(removedArmor)
            removedItem = removedArmor

            i = size
		    materialLevel = getMaterialLevel(removedArmor, FALSE)
			debug.notification("armor")
		endIf

		i += 1
	endWhile

	;========================================================

	; we found a valid item, so create it!
	; debug.trace("Attempting to spawn a "+Results.getAt(i))
    if(removedItem)
        summonFXpoint.placeAtMe(summonFX);summonFX.playGamebryoAnimation("mIdle")
        utility.wait(0.33)

        createdItemREF = createPoint.placeAtMe(removedItem)
        createdItemREF.SetItemHealthPercent(itemTempering)

        ;debug.notification(Results.getAt(i))

        ;createdItemREF = createPoint.placeAtMe(Results.getAt(i))
        utility.wait(0.1)
        AddKeywordToRef(createdItemREF, disallowEnchantingKeyword) 
        AddKeywordToRef(createdItemREF, disallowSellingKeyword) 

        ; if the last thing I summoned is a dead actor, just get rid of it.
        if (lastSummonedObject)
            if ((lastSummonedObject as actor).isDead())
                ; transfer any items to the offering box (just in case I had anything valuable on me!)
                lastSummonedObject.RemoveAllItems(DropBox, FALSE, TRUE)
                lastSummonedObject.disable()
                lastSummonedObject.delete()
            endIf
        endIf

        ; now store whatever we just created as the current/last summoned object
        lastSummonedObject = createdItemREF

        ;;;createdItemREF.SetEnchantment(enchantments[0], 100)

        if(removedWeapon)
            ; add additional damage magicEffect for banish/turn undead
            if(randomEnchIndex == 10 || randomEnchIndex == 11)
                float maxCharge = 1500 + materialLevel * 500
                int[] durations = new int[2]
                durations[0] = enchDuration
                durations[1] = 0
                int[] areas = new int[2]
                areas[0] = 0
                areas[1] = 0
                magicEffect[] effects = new magicEffect[2]
                effects[0] = (weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(0)
                if(randomEnchIndex == 10)
                    effects[1] = banishDamageMgef
                else
                    effects[1] = turnUndeadDamageMgef
                endIf
                float[] magnitudes = new float[2]
                magnitudes[0] = enchStrength
                magnitudes[1] = getBonusDamageStrength(effects[1], materialLevel)

                enchantment e = createdItemREF.CreateEnchantment(maxCharge, effects, magnitudes, areas, durations)
            else 
                float maxCharge = 1500 + materialLevel * 500
                int[] durations = new int[1]
                durations[0] = enchDuration
                int[] areas = new int[1]
                areas[0] = 0
                float[] magnitudes = new float[1]
                magnitudes[0] = enchStrength
                magicEffect[] effects = new magicEffect[1]
                effects[0] = (weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(0)

                enchantment e = createdItemREF.CreateEnchantment(maxCharge, effects, magnitudes, areas, durations)
            endIf
        elseIf(removedArmor)
            string armorType = getArmorType(removedArmor)   ; helm/cuirass/gauntlets/boots/shield/""

           ; enchantment e = createdItemREF.CreateEnchantment(maxCharge, effects, magnitudes, areas, durations)

           ; enchantment e = createdItemREF.CreateEnchantment(maxCharge, weaponEnchantmentsWeak.(randomEnchIndex),magnitudes , areas , durations )
        endIf
    ;enchantment e = createdItemREF.CreateEnchantment(maxCharge, weaponEnchantments,magnitudes , areas , durations )
    ;	debug.notification(createdItemREF)
    ;	debug.notification((createdItemREF as form).HasKeyword(keywordsLevel1[0]))
    ;	debug.notification(weaponEnchantments[0])

        ;setToDefaultState()
        return TRUE
    else
        ;setToDefaultState()
	    return FALSE
    endIf
endFunction

function setToDefaultState()
    enchanter.removeAllItems()
endFunction

function disenchant(form item, float tempering)
	summonFXpoint.placeAtMe(summonFX);summonFX.playGamebryoAnimation("mIdle")
	utility.wait(0.33)

    objectReference createdItemREF = createPoint.placeAtMe(item)
    createdItemREF.setItemHealthPercent(tempering)
endFunction

int function getMaterialLevel(form item, bool isWeapon)
    int minGoldValueForWeaponLevel2 = 300
    int minGoldValueForWeaponLevel3 = 4500
    int minGoldValueForArmorLevel2 = 100
    int minGoldValueForArmorLevel3 = 1500

	int i = 0
    int keywordCount = item.getNumKeywords()

    if(isWeapon)                        ; weapon
        while i < keywordCount
            if(keywordsWeaponLevel1.hasForm(item.getNthKeyword(i)))
                return 0
            elseIf(keywordsWeaponLevel2.hasForm(item.getNthKeyword(i)))
                return 1
            elseIf(keywordsWeaponLevel3.hasForm(item.getNthKeyword(i)))
                return 2
            elseIf(keywordsWeaponLevel4.hasForm(item.getNthKeyword(i)))
                return 3
            endIf
            i += 1
        endWhile

        ; decide by value if no keywords found
        debug.notification("getWeaponMaterialLevel else")
        if(item.getGoldValue() < minGoldValueForWeaponLevel2)
            return 0
        elseIf(item.getGoldValue() < minGoldValueForWeaponLevel3)   
            return 1
        else
            return 2
        endIf  
    else                                ; armor
        while i < keywordCount
            if(keywordsArmorLevel1.hasForm(item.getNthKeyword(i)))
                return 0
            elseIf(keywordsArmorLevel2.hasForm(item.getNthKeyword(i)))
                return 1
            elseIf(keywordsArmorLevel3.hasForm(item.getNthKeyword(i)))
                return 2
            elseIf(keywordsArmorLevel4.hasForm(item.getNthKeyword(i)))
                return 3
          
            endIf
            i += 1
        endWhile

        ; decide by value if no keywords found
        if(item.getGoldValue() < minGoldValueForArmorLevel2)
            return 0
        elseIf(item.getGoldValue() < minGoldValueForArmorLevel3)   
            return 1
        else
            return 2
        endIf     
    endIf
endFunction

bool function scanAndRemoveEnchIngredients(int voidsaltsMinCount)
	if (dropBox.getItemCount(blackSoulGem) >= 1 && dropBox.getItemCount(voidSalts) >= voidsaltsMinCount)
        dropBox.removeItem(blackSoulGem, 1)
        dropBox.removeItem(voidSalts, voidsaltsMinCount)
		return TRUE
	else
		return FALSE
	endIf
endFunction

float function getEnchStrenght(int index, int level, bool isWeapon)
    float strength
    float step

	if(isWeapon)
		step = ((weaponEnchantmentsBest.getAt(index) as enchantment).getNthEffectMagnitude(0) - (weaponEnchantmentsWeak.getAt(index) as enchantment).getNthEffectMagnitude(0)) / 3
		strength = (weaponEnchantmentsWeak.getAt(index) as enchantment).getNthEffectMagnitude(0) + (step * level)
    else
        step = ((armorEnchantmentsBest.getAt(index) as enchantment).getNthEffectMagnitude(0) - (armorEnchantmentsWeak.getAt(index) as enchantment).getNthEffectMagnitude(0)) / 3
		strength = (armorEnchantmentsWeak.getAt(index) as enchantment).getNthEffectMagnitude(0) + (step * level)
    endif

	return utility.randomFloat(strength * (1 - randomDifference), strength * (1 + randomDifference))
endFunction

int function getEnchDuration(int index, int level, bool isWeapon)
    float strength
    float step

	step = ((weaponEnchantmentsBest.getAt(index) as enchantment).getNthEffectDuration(0) - (weaponEnchantmentsWeak.getAt(index) as Enchantment).getNthEffectDuration(0)) / 3
	strength = (weaponEnchantmentsWeak.getAt(index) as enchantment).getNthEffectDuration(0) + (step * level)

	return math.floor(strength)
endFunction

int function enchantmentCheck(form item)
	enchantment tempEnchantmentBase = None
	enchantment tempEnchantmentSpecial = None

	if (item.GetType() == 41)
		tempEnchantmentBase = (item as weapon).getEnchantment()
		tempEnchantmentSpecial = wornObject.getEnchantment(enchanter, 1, 0)
	else
		tempEnchantmentBase = (item as armor).getEnchantment()		
		Int slotMask = (item as armor).getSlotMask()
		tempEnchantmentSpecial = wornObject.getEnchantment(enchanter, 0, slotMask)
	endIf

	;debug.notification(" TempEnchantmentBase " + tempEnchantmentBase)
	;debug.notification(" TempEnchantmentSpecial " + tempEnchantmentSpecial)

    if(tempEnchantmentSpecial)
        return 2
    elseif(tempEnchantmentBase)
        return 1
    else
        return 0
    endIf
endFunction

float function temperingCheck(form item)
	float itemTempering = 1.0

	if (item.getType() == 41)
		itemTempering = wornObject.getItemHealthPercent(enchanter, 1, 0)
	else
		Int slotMask = (item as armor).getSlotMask()
		itemTempering = wornObject.getItemHealthPercent(enchanter, 0, slotMask)
	endIf

	debug.notification(" ItemTempering " + itemTempering)

    return itemTempering
endFunction

float function getBonusDamageStrength(magicEffect damageEffect, int materialLevel)
    float strength

    if(damageEffect == banishDamageMgef)
        strength = 40 + 20 * materialLevel          ; banishDamageMgef
    else 
        strength = 16 + 9 * materialLevel           ; turnUndeadDamageMgef
    endIf

    return utility.randomFloat(strength * (1 - randomDifference), strength * (1 + randomDifference))
endFunction

string function getArmorType(form item)
    if(item.hasKeyword(armorKeywords[0]))
        return "helm"
    elseIf(item.hasKeyword(armorKeywords[1]))
        return "cuirass"
    elseIf(item.hasKeyword(armorKeywords[2]))
        return "gauntlets"
    elseIf(item.hasKeyword(armorKeywords[3]))
        return "boots"
    elseIf(item.hasKeyword(armorKeywords[4]))
        return "shield"
    else
        return ""
    endIf
endFunction

function createArmorEnchantment(objectReference itemRef, int materialLevel, string armorType)

endFunction

