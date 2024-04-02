	- decide atronachs
	- drop book? / any item			on wrong recipe

	- no savescumming
	- list of materials + salts required + gold
	- list of possible enchs
	- deleveled
	- clothing is levle 2
	- cant get best ench
	- takes effect from vanilla weapons for compatibility
	- added few special enchs
	- requires new game
	- requiem patch + black soul gems
	- skse requiered

scriptname AtronachForgeSCRIPT extends ObjectReference

;import stringUtil

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

Actor property enchanter auto 

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
; 10 - force push
; 11 - banish
; 12 - turn undead
int forcePushIndex = 10
int banishIndex = 11
int turnUndeadIndex = 12

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

Keyword property disallowEnchantingKeyword auto  
Keyword property disallowSellingKeyword auto  
Keyword[] property armorKeywords Auto
; 0 - helm
; 1 - cuirass
; 2 - gauntlets
; 3 - boots
; 4 - shield
; 5 - clothing helm
; 6 - clothing cuirass
; 7 - clothing gauntlets
; 8 - clothing boots

MagicEffect property banishDamageMgef auto
MagicEffect property turnUndeadDamageMgef auto
MagicEffect property banishBaseMgef auto
MagicEffect property turnUndeadBaseMgef auto
MagicEffect property dummyPreventDisenchanting auto

Formlist property tomesLeveledLists auto

SoulGem property blackSoulGem auto
Ingredient property voidSalts auto
Ingredient property briarHeart auto

String armorHelmetString = "armorHelmetString"
String armorCuirassString = "armorCuirassString"
String armorGauntletsString = "armorGauntletsString"
String armorBootsString = "armorBootsString"
String armorShieldString = "armorShieldString"
String clothingHelmetString = "clothingHelmetString"
String clothingCuirassString = "clothingCuirassString"
String clothingGauntletsString = "clothingGauntletsString"
String clothingBootsString = "clothingBootsString"

Int voidSaltsBaseCount = 1
Int clothingMaterialLevel = 2
Float randomDifference = 0.17
float elementResistsMultipler = 0.66
float fortifySchoolsMultipler = 0.85

String namePrefix = "Blighted "
String wrongRecipeMessage = "This recipe doesn't seem to be valid..." 
String nonEnchantableMessage = "This item cannot be enchanted..." 
String nonEnchantableSpelltomeMessage = "This book cannot be reforged..."
String errorMessage = "Item is incompatible with this mod - please reload the game" 

Bool failedWithMessage = FALSE

state busy
    event onActivate(objectReference actronaut)
    ; debug.trace("Atronach Forge is currently busy.  Try again later")
    endEvent
endState

auto state ready
    event onActivate(objectReference actronaut)
        gotoState("busy")
        bool daedricItemCrafted
        bool vanillaItemCrafted
        bool enchantmentCrafted
        bool spelltomeCrafted

        ; first attempt to craft Daedric items if the Sigil Stone is installed
        ; debug.trace("Atronach Forge checking for Sigil Stone")
        if(sigilStoneInstalled == TRUE)
            ; debug.trace("Atronach Forge detected Sigil Stone, attempt Daedric Combines first")
            daedricItemCrafted = scanForRecipes(sigilRecipeList, sigilResultList)
            utility.wait(0.1)
        endIf
        ; if no sigil stone, or if we checked and found no valid Daedric recipes...
        if(sigilStoneInstalled == FALSE || daedricItemCrafted == FALSE)
        ; debug.trace("Atronach Forge Either did not detect Sigil Stone, or no deadric combines were found")
            VanillaItemCrafted = scanForRecipes(recipeList, resultList)
        endIf
        if(vanillaItemCrafted == FALSE && daedricItemCrafted == FALSE)
            enchantmentCrafted = scanForEnchantments(recipeList, resultList)
        endIf
        if(!failedWithMessage && !enchantmentCrafted)
            spelltomeCrafted = scanForSpellomes(recipeList, resultList)
        endIf

        if(!failedWithMessage && !daedricItemCrafted && !vanillaItemCrafted && !enchantmentCrafted && !spelltomeCrafted)
            debug.notification(wrongRecipeMessage)
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
        if currentRecipe == none
            ; debug.trace("ERROR: Atronach Forge trying to check a none recipe")
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
        utility.wait(0.2)
        ;debug.notification(Results.getAt(i))
        objectReference createdItemRef = createPoint.placeAtMe(results.getAt(i))

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

        if (createdItemRef as actor) != none
            (createdItemRef as actor).startCombat(game.getPlayer())
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

bool function scanForEnchantments(formlist recipes, formList results)
    ; add 1 to compare it later and prevent disenchanting
    float[] maxCharges = new float[4]
    maxCharges[0] = 1951
    maxCharges[1] = 2301
    maxCharges[2] = 2651
    maxCharges[3] = 3001

    int materialLevel
    string armorType
    objectReference createdItemRef
    form removedItem
    weapon removedWeapon
    armor removedArmor

	int size = dropBox.getNumItems()
	int index = 0

    ; looking for item to enchant
	while index < size
		removedWeapon = dropBox.getNthForm(index) as weapon
		removedArmor = dropBox.getNthForm(index) as armor

		if(removedWeapon)
            removedItem = removedWeapon
			materialLevel = getMaterialLevel(removedWeapon, TRUE)
		elseIf(removedArmor)
            removedItem = removedArmor
		    materialLevel = getMaterialLevel(removedArmor, FALSE)

            armorType = getArmorType(removedArmor)      ; helm/cuirass/gauntlets/boots/shield/""
            if(!armorType)
                debug.notification(nonEnchantableMessage)
                return FALSE
            endIf

            if(armorType == clothingHelmetString || armorType == clothingCuirassString || armorType == clothingGauntletsString || armorType == clothingBootsString)
                materialLevel = clothingMaterialLevel
            endIf
		endIf

        if(removedItem)
            index = size

            dropBox.removeItem(removedItem, 1, TRUE, enchanter)
            utility.wait(0.1)

            enchanter.equipItem(removedItem)
            utility.wait(0.1)

            if(enchanter.wornHasKeyword(disallowEnchantingKeyword))
                return failGracefully(removedItem, nonEnchantableMessage)
            endIf

            int itemOldEnchantment = enchantmentCheck(removedItem, maxCharges)        ; 0 - not enchanted, 1 - has base enchant, 2 - has player made enchant, 3 - has forge enchant
            if(itemOldEnchantment == 1)
                ;debug.notification("1 - has base enchantment")
                return failGracefully(removedItem, nonEnchantableMessage)
            elseIf(itemOldEnchantment == 2)
                ;debug.notification("2 - has player made enchantment")
                if(dropBox.getItemCount(briarHeart) > 0)
                    dropBox.removeItem(briarHeart, 1)
                    return disenchant(removedItem, 0.0)
                else
                    return failGracefully(removedItem, wrongRecipeMessage)
                endIf
            elseIf(itemOldEnchantment == 3)
                ;debug.notification("3 - has forge enchant")
                return failGracefully(removedItem, nonEnchantableMessage)
            endIf

            int voidSaltsNeeded = materialLevel + voidSaltsBaseCount
            bool ingredientsMatch = scanAndRemoveEnchIngredients(voidSaltsNeeded)
            if(!ingredientsMatch)
                return failGracefully(removedItem, wrongRecipeMessage)
            endIf

            summonFXpoint.placeAtMe(summonFX)
            utility.wait(0.2)
            
            createdItemRef = getItemFromEnchanter(removedItem)
            if(createdItemRef == none)
                return FALSE
            endIf

            createdItemRef.moveTo(createPoint)

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
            lastSummonedObject = createdItemRef

            if(removedWeapon)
                int randomEnchIndex = utility.randomInt(0, weaponEnchantmentsWeak.getSize() - 1)
                
                int[] durations = new int[10]
                int[] areas = new int[10]
                float[] magnitudes = new float[10]
                magicEffect[] effects = new magicEffect[10]

               ; float magnitude = getEnchMagnitude(randomEnchIndex, materialLevel, weaponEnchantmentsWeak, weaponEnchantmentsBest)
               ; int enchDuration = getEnchDuration(randomEnchIndex, materialLevel)
                float maxCharge = maxCharges[materialLevel]
                
                ; add additional damage magicEffect for banish/turn undead
                if(randomEnchIndex == banishIndex || randomEnchIndex == turnUndeadIndex)
                    int effectCount = (weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNumEffects()
                    int effectIndex = 0

                    ; make sure that banish/turn undead mgef exists on this enchantment
                    while(effectIndex < effectCount)
                        if((weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(effectIndex) == banishBaseMgef || (weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(effectIndex) == turnUndeadBaseMgef)

                            magnitudes[0] = getEnchMagnitude(randomEnchIndex, materialLevel, weaponEnchantmentsWeak, weaponEnchantmentsBest, effectIndex)
                           ; magnitudes[0] = round(magnitudes[0] / 2)        ; nerf magnitude because it takes too much charge
                           ; magnitudes[1] = getSpecialDamageMagnitude(11, materialLevel)
                            durations[0] = getEnchDuration(randomEnchIndex, materialLevel, effectIndex)
                            durations[1] = 1                
                            areas[0] = 0
                            areas[1] = 0
                            ;effects[0] = banishBaseMgef
                            ;effects[1] = banishDamageMgef

                            effectIndex = effectCount
                        endIf

                       ; if((weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(effectIndex) == turnUndeadBaseMgef)
                     ;       magnitudes[0] = getEnchMagnitude(randomEnchIndex, materialLevel, weaponEnchantmentsWeak, weaponEnchantmentsBest, effectIndex)
                  ;          magnitudes[1] = getSpecialDamageMagnitude(12, materialLevel)
                     ;       durations[0] = getEnchDuration(randomEnchIndex, materialLevel, effectIndex)
                   ;         durations[1] = 1  
                   ;         areas[0] = 0
                   ;         areas[1] = 0
                    ;        effects[0] = turnUndeadBaseMgef
                   ;         effects[1] = turnUndeadDamageMgef

                     ;       effectIndex = effectCount
                        ;endIf

                        effectIndex += 1

                        ; banish/turn undead mgef not found on enchantment
                        if(effectIndex + 1 == effectCount)
                            while(randomEnchIndex == banishIndex || randomEnchIndex == turnUndeadIndex)
                                randomEnchIndex = utility.randomInt(0, weaponEnchantmentsWeak.getSize() - 1)
                            endWhile
                        endIf
                    endWhile

                    
                    if(randomEnchIndex == banishIndex)
                        effects[0] = banishBaseMgef
                        effects[1] = banishDamageMgef
                        magnitudes[0] = round(magnitudes[0] / 2)        ; nerf magnitude because it takes too much charge
                        magnitudes[1] = getSpecialDamageMagnitude(banishIndex, materialLevel)
                    elseIf(randomEnchIndex == turnUndeadIndex)
                        effects[0] = turnUndeadBaseMgef
                        effects[1] = turnUndeadDamageMgef
                        magnitudes[1] = getSpecialDamageMagnitude(turnUndeadIndex, materialLevel)
                    endIf
                endIf

                if(randomEnchIndex != banishIndex && randomEnchIndex != turnUndeadIndex)
                    int effectCount = (weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNumEffects()
                    int effectIndex = 0

                    while(effectIndex < effectCount)
                        durations[effectIndex] = getEnchDuration(randomEnchIndex, materialLevel, effectIndex)
                        areas[effectIndex] = 0
                        magnitudes[effectIndex] = getEnchMagnitude(randomEnchIndex, materialLevel, weaponEnchantmentsWeak, weaponEnchantmentsBest, effectIndex)
                        effects[effectIndex] = (weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(effectIndex)
                        effectIndex += 1
                    endWhile

                    if(randomEnchIndex == forcePushIndex)
                        magnitudes[0] = getSpecialDamageMagnitude(randomEnchIndex, materialLevel)
                    endIf
;                    effects[0] = (weaponEnchantmentsWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(0)
                endIf

                createdItemRef.CreateEnchantment(maxCharge, effects, magnitudes, areas, durations)
                createdItemRef.setItemCharge(0)
            else    ; armor
                createArmorEnchantment(createdItemRef, materialLevel, armorType)
            endIf

            return TRUE
        endIf

		index += 1
	endWhile
	
	return FALSE
endFunction

function setToDefaultState()
    enchanter.removeAllItems()
    failedWithMessage
endFunction

bool function disenchant(form item, float tempering)
    summonFXpoint.placeAtMe(summonFX)
    utility.wait(0.2)

    objectReference createdItemRef = getItemFromEnchanter(item)
    if(createdItemRef == none)
        return FALSE
    endIf
    
    createdItemRef.SetEnchantment(none, 0)
    createdItemRef.moveTo(createPoint)

    return TRUE
endFunction

int function getMaterialLevel(form item, bool isWeapon)
    int minGoldValueForWeaponLevel2 = 300
    int minGoldValueForWeaponLevel3 = 4500
    int minGoldValueForArmorLevel2 = 125
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

float function getEnchMagnitude(int index, int level, formlist mgefWeak, formlist mgefBest, int effectIndex)
    float step = ((mgefBest.getAt(index) as enchantment).getNthEffectMagnitude(effectIndex) - (mgefWeak.getAt(index) as enchantment).getNthEffectMagnitude(effectIndex)) / 3
	float magnitude = (mgefWeak.getAt(index) as enchantment).getNthEffectMagnitude(effectIndex) + (step * level)
    
	return round(utility.randomFloat(magnitude * (1 - randomDifference), magnitude * (1 + randomDifference)))
endFunction

int function getEnchDuration(int index, int level, int effectIndex)
	float step = (((weaponEnchantmentsBest.getAt(index) as enchantment).getNthEffectDuration(effectIndex) as float) - ((weaponEnchantmentsWeak.getAt(index) as Enchantment).getNthEffectDuration(effectIndex) as float)) / 3
	float duration = (weaponEnchantmentsWeak.getAt(index) as enchantment).getNthEffectDuration(effectIndex) + (step * level)
	
    return round(duration)
endFunction

int function enchantmentCheck(form item, float[] maxCharges)
	enchantment tempEnchantmentBase = none
	enchantment tempEnchantmentSpecial = none
	string itemName = none
    bool isForgeEnch = FALSE
    float maxCharge

	if(item.getType() == 41)
		tempEnchantmentBase = (item as weapon).getEnchantment()
		tempEnchantmentSpecial = wornObject.getEnchantment(enchanter, 1, 0)
        itemName = wornObject.getDisplayName(enchanter, 1, 0)
        maxCharge = wornObject.getItemMaxCharge(enchanter, 1, 0)
	else
		tempEnchantmentBase = (item as armor).getEnchantment()		
		int slotMask = (item as armor).getSlotMask()
		tempEnchantmentSpecial = wornObject.getEnchantment(enchanter, 0, slotMask)

        if(tempEnchantmentSpecial)
            int enchSize = tempEnchantmentSpecial.getNumEffects()
            int index = 0

            while(index < enchSize)

                if(tempEnchantmentSpecial.getNthEffectMagicEffect(index) == dummyPreventDisenchanting)
                    isForgeEnch = TRUE
                    index = enchSize
                endIf
                index += 1
            endWhile
        endIf
	endIf

    if(isForgeEnch || maxCharges.find(maxCharge) >= 0)
        return 3
    elseif(tempEnchantmentSpecial)
        return 2
    elseif(tempEnchantmentBase)
        return 1
    else
        return 0
    endIf
endFunction

;float function temperingCheck(form item)
;	float itemTempering = 1.0

;	if (item.getType() == 41)
;		itemTempering = wornObject.getItemHealthPercent(enchanter, 1, 0)
;	else
;		Int slotMask = (item as armor).getSlotMask()
;		itemTempering = wornObject.getItemHealthPercent(enchanter, 0, slotMask)
;	endIf

;	debug.notification(" ItemTempering " + itemTempering)

;    return itemTempering
;endFunction

; 10 - force, 11 - banish, 12 - turn undead
float function getSpecialDamageMagnitude(int index, int materialLevel)
    ; get magnutide from fire damage (0 index)
    float magnitude = getEnchMagnitude(0, materialLevel, weaponEnchantmentsWeak, weaponEnchantmentsBest, 0)

    if(index == forcePushIndex)
        magnitude = magnitude * 4.2
    elseIf(index == banishIndex)
        magnitude = magnitude * 2.8
    elseIf(index == turnUndeadIndex)
        magnitude = magnitude * 1.4
    endIf

    return round(magnitude)
endFunction

string function getArmorType(form item)
    if(item.hasKeyword(armorKeywords[0]))
        return armorHelmetString
    elseIf(item.hasKeyword(armorKeywords[1]))
        return armorCuirassString
    elseIf(item.hasKeyword(armorKeywords[2]))
        return armorGauntletsString
    elseIf(item.hasKeyword(armorKeywords[3]))
        return armorBootsString
    elseIf(item.hasKeyword(armorKeywords[4]))
        return armorShieldString
    elseIf(item.hasKeyword(armorKeywords[5]))
        return clothingHelmetString
    elseIf(item.hasKeyword(armorKeywords[6]))
        return clothingCuirassString
    elseIf(item.hasKeyword(armorKeywords[7]))
        return clothingGauntletsString
    elseIf(item.hasKeyword(armorKeywords[8]))
        return clothingBootsString
    else
        return ""
    endIf
endFunction

function createArmorEnchantment(objectReference itemRef, int materialLevel, string armorType)
    int totalEffectsCount
    int specialEffectOffset
    int specialEffectCount
    formList effectsFormlistWeak
    formList effectsFormlistBest

    int[] durations = new int[12]
    int[] areas = new int[12]
    float[] magnitudes = new float[12]
    magicEffect[] effects = new magicEffect[12]

    if(armorType == armorCuirassString || armorType == clothingCuirassString)           ; 2 special effects (fortify schools/element resists)
        effectsFormlistWeak = cuirassEnchantmentsWeak
        effectsFormlistBest = cuirassEnchantmentsBest
        totalEffectsCount = cuirassEnchantmentsWeak.getSize() + 1

        int specialEffectRandom = utility.randomInt(0, 1)
        if(specialEffectRandom == 0)
            specialEffectOffset = 2
            specialEffectCount = 5
        else
            specialEffectOffset = 7
            specialEffectCount = 3
        endIf
    elseIf(armorType == armorHelmetString || armorType == clothingHelmetString)         ; 1 special effect (fortify schools)
        effectsFormlistWeak = helmEnchantmentsWeak
        effectsFormlistBest = helmEnchantmentsBest
        totalEffectsCount = helmEnchantmentsWeak.getSize()
        specialEffectOffset = 2
        specialEffectCount = 5
    elseIf(armorType == armorGauntletsString || armorType == clothingGauntletsString)   ; 1 special effect (fortify melee damage)
        effectsFormlistWeak = gauntletsEnchantmentsWeak
        effectsFormlistBest = gauntletsEnchantmentsBest
        totalEffectsCount = gauntletsEnchantmentsWeak.getSize()
        specialEffectOffset = 0
        specialEffectCount = 2
    elseIf(armorType == armorBootsString || armorType == clothingBootsString)           ; 1 special effect (fortify melee damage)
        effectsFormlistWeak = bootsEnchantmentsWeak
        effectsFormlistBest = bootsEnchantmentsBest
        totalEffectsCount = bootsEnchantmentsWeak.getSize()
        specialEffectOffset = 0
        specialEffectCount = 2
    elseIf(armorType == armorShieldString)                                              ; 2 special effects (fortify schools/element resists)
        effectsFormlistWeak = shieldEnchantmentsWeak
        effectsFormlistBest = shieldEnchantmentsBest
        totalEffectsCount = shieldEnchantmentsWeak.getSize() + 1

        int specialEffectRandom = utility.randomInt(0, 1)
        if(specialEffectRandom == 0)
            specialEffectOffset = 2
            specialEffectCount = 5
        else
            specialEffectOffset = 7
            specialEffectCount = 3
        endIf
    endIf

    int randomEnchIndex = utility.randomInt(0, totalEffectsCount)
    float magnitude
    int index = 0

    if(randomEnchIndex >= effectsFormlistWeak.getSize())
        ; special ench - fortify melee damage/fortify schools/element resists 
        magnitude = getEnchMagnitude(specialEffectOffset, materialLevel, armorEnchantmentsSpecialWeak, armorEnchantmentsSpecialBest, 0)

        while (index < specialEffectCount)
            effects[index] = (armorEnchantmentsSpecialWeak.getAt(index + specialEffectOffset) as enchantment).getNthEffectMagicEffect(0)
            magnitudes[index] = magnitude
            ; nerf effects that are too strong: magic schools reductions (5), resist elements (3)
            if(specialEffectCount == 3)
                magnitudes[index] = math.floor(magnitudes[index] * elementResistsMultipler)      
                if(materialLevel == 0)
                    magnitudes[index] = magnitudes[index] + 1
                endIf
            elseIf(specialEffectCount == 5)
                magnitudes[index] = math.floor(magnitudes[index] * fortifySchoolsMultipler)      
            endIf
            areas[index] = 0
            durations[index] = 0
            index += 1
        endWhile
    else
        ; normal ench
        int effectCount = (effectsFormlistWeak.getAt(randomEnchIndex) as enchantment).getNumEffects()
        int effectIndex = 0

        while(effectIndex < effectCount)
            effects[effectIndex] = (effectsFormlistWeak.getAt(randomEnchIndex) as enchantment).getNthEffectMagicEffect(effectIndex)
            magnitudes[effectIndex] = getEnchMagnitude(randomEnchIndex, materialLevel, effectsFormlistWeak, effectsFormlistBest, effectIndex)
            areas[effectIndex] = 0
            durations[effectIndex] = 0
            effectIndex += 1
            index = effectIndex
        endWhile
    endIf

    ; add dummy effect to prevent disenchanting
    effects[index] = dummyPreventDisenchanting
    magnitudes[index] = 0
    areas[index] = 0
    durations[index] = 0

    itemRef.CreateEnchantment(0, effects, magnitudes, areas, durations)
endFunction

bool function failGracefully(form item, string warnMessage)
    failedWithMessage = TRUE

    objectReference createdItemRef = getItemFromEnchanter(item)
    if(createdItemRef == none)
        return FALSE
    endIf

    createdItemRef.moveTo(createPoint)
    createdItemRef.setItemCharge(0)

    debug.notification(warnMessage)

    return FALSE
endFunction

int function round(float number)
    float tempFloat = number - math.floor(number)

    if(tempFloat < 0.5)
        return math.floor(number)
    else
        return math.ceiling(number)
    endIf
endFunction

objectReference function getItemFromEnchanter(form item)
    objectReference itemRef = enchanter.dropObject(item, 1)
    utility.wait(0.1)

    ;int index = 0
    ;while(!itemRef.is3DLoaded())
    ;    index += 1
    ;    if(index >= 50)
    ;        debug.notification(errorMessage)
    ;        return none
    ;    endIf
    ;endWhile

    if(!itemRef)
        debug.notification(errorMessage)
        return none
    endIf

    return itemRef
endFunction

bool function scanForSpellomes(formlist recipes, formList results)
    objectReference createdItemRef
    book spelltomeForm

	int size = dropBox.getNumItems()
	int index = 0

    if(!scanAndRemoveEnchIngredients(0))
        return FALSE
    endIf

	while(index < size)
		spelltomeForm = dropBox.getNthForm(index) as book

        ; book found
        if(spelltomeForm)
            index = size

            int listsCount = tomesLeveledLists.getSize()
            int listsIndex = 0

            while(listsIndex < listsCount)
                leveledItem leveledSpelltomes = (tomesLeveledLists.getAt(listsIndex) as leveledItem)
                int listItemsCount = leveledSpelltomes.getNumForms()
                int listItemsIndex = 0

                while(listItemsIndex < listItemsCount)
                    if(leveledSpelltomes.getNthForm(listItemsIndex) == spelltomeForm)
                        ; spelltomeFound

                        if(listItemsCount < 2)
                            return FALSE
                        endIf
                        int randomTomeIndex = utility.randomInt(0, listItemsCount)
                        while(randomTomeIndex == listItemsIndex)
                            randomTomeIndex = utility.randomInt(0, listItemsCount)
                        endWhile

                        dropBox.removeItem(spelltomeForm, 1, TRUE, enchanter)
                        objectReference oldSpelltome = getItemFromEnchanter(spelltomeForm)
                        string oldName = oldSpelltome.getdisplayName()

                        ; cancel if spelltome was renamed (probably by this mod)
                        if(oldSpelltome.getdisplayName() != spelltomeForm.getName())
                            oldSpelltome.moveTo(createPoint)
                            debug.notification(nonEnchantableSpelltomeMessage)
                            failedWithMessage = TRUE
                            return FALSE
                        endIf

                        summonFXpoint.placeAtMe(summonFX)
                        utility.wait(0.2)
                        createdItemRef = createPoint.placeAtMe(leveledSpelltomes.getNthForm(randomTomeIndex))
                        utility.wait(0.1)

                        string createdItemName = createdItemRef.getdisplayName()
                        createdItemRef.setDisplayName(namePrefix + createdItemName)         ; overrides name forever

                        oldSpelltome.delete()
                        
                        return TRUE
                    endIf
                    
                    listItemsIndex += 1
                endWhile

                listsIndex += 1
            endWhile

            ; spelltome not found in any leveled lists
            debug.notification(nonEnchantableSpelltomeMessage)
            failedWithMessage = TRUE
            return FALSE
        endIf

        index += 1
    endWhile

    return FALSE
endFunction
