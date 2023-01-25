/*
 proteans
*/
/obj/item/weapon/rig/protean
	name = "nanosuit control cluster"
	suit_type = "nanomachine"
	icon = 'icons/obj/rig_modules_ch.dmi'
	default_mob_icon = null	//Actually having a forced sprite for Proteans is ugly af. I'm not gonna make this a toggle
	icon_state = "nanomachine_rig"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	siemens_coefficient= 1
	slowdown = 0
	offline_slowdown = 0
	seal_delay = 1
	var/mob/living/myprotean
	initial_modules = list(/obj/item/rig_module/protean/syphon, /obj/item/rig_module/protean/armor, /obj/item/rig_module/protean/healing)

	helm_type = /obj/item/clothing/head/helmet/space/rig/protean //These are important for sprite pointers
	boot_type = /obj/item/clothing/shoes/magboots/rig/protean
	chest_type = /obj/item/clothing/suit/space/rig/protean
	glove_type = /obj/item/clothing/gloves/gauntlets/rig/protean
	protean = 1
	offline_vision_restriction = 0
	open = 1
	cell_type =  /obj/item/weapon/cell/protean
	var/dead = 0
	//interface_path = "RIGSuit_protean"
	//ai_interface_path = "RIGSuit_protean"
	var/sealed = 0
	var/assimilated_rig

/obj/item/weapon/rig/protean/relaymove(mob/user, var/direction)
	if(user.stat || user.stunned)
		return
	forced_move(direction, user, 0)

/obj/item/weapon/rig/protean/check_suit_access(mob/living/user)
	if(user == myprotean)
		return 1
	return ..()

/obj/item/weapon/rig/protean/digest_act(atom/movable/item_storage = null)
	return 0

/obj/item/weapon/rig/protean/New(var/newloc, var/mob/living/carbon/human/P)
	if(P)
		var/datum/species/protean/S = P.species
		S.OurRig = src
		if(P.back)
			addtimer(CALLBACK(src, .proc/AssimilateBag, P, 1, P.back), 3)
			myprotean = P
		else
			to_chat(P, "<span class='notice'>You should have spawned with a backpack to assimilate into your RIG. Try clicking it with a backpack.</span>")
	..(newloc)

/obj/item/weapon/rig/proc/AssimilateBag(var/mob/living/carbon/human/P, var/spawned, var/obj/item/weapon/storage/backpack/B)
	if(istype(B,/obj/item/weapon/storage/backpack))
		if(spawned)
			B = P.back
			P.unEquip(P.back)
		B.forceMove(src)
		rig_storage = B
		P.drop_item(B)
		to_chat(P, "<span class='notice'>[B] has been integrated into the [src].</span>")
		if(spawned)	//This feels very dumb to have a second if but I'm lazy
			P.equip_to_slot_if_possible(src, slot_back)
		src.Moved()
	else
		to_chat(P,"<span class ='warning'>Your rigsuit can only assimilate a backpack into itself. If you are seeing this message, and you do not have a rigsuit, tell a coder.</span>")

/obj/item/weapon/rig/protean/verb/RemoveBag()
	set name = "Remove Stored Bag"
	set category = "Object"

	if(rig_storage)
		usr.put_in_hands(rig_storage)
		rig_storage = null
	else
		to_chat(usr, "This Rig does not have a bag installed. Use a bag on it to install one.")

/obj/item/weapon/rig/protean/attack_hand(mob/user as mob)
	if (src.loc == user)
		if(rig_storage)
			src.rig_storage.open(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.rig_storage.close(M)
	src.add_fingerprint(user)
	return

/obj/item/clothing/head/helmet/space/rig/protean
	name = "mass"
	desc = "A helmet-shaped clump of nanomachines."
	light_overlay = "should not use a light overlay"
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJ, SPECIES_UNATHI, SPECIES_NEVREAN, SPECIES_AKULA, SPECIES_SERGAL, SPECIES_ZORREN_HIGH, SPECIES_VULPKANIN, SPECIES_PROMETHEAN, SPECIES_XENOHYBRID, SPECIES_VOX, SPECIES_TESHARI, SPECIES_VASILISSAN)

/obj/item/clothing/gloves/gauntlets/rig/protean
	name = "mass"
	desc = "Glove-shaped clusters of nanomachines."
	siemens_coefficient= 0
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJ, SPECIES_UNATHI, SPECIES_NEVREAN, SPECIES_AKULA, SPECIES_SERGAL, SPECIES_ZORREN_HIGH, SPECIES_VULPKANIN, SPECIES_PROMETHEAN, SPECIES_XENOHYBRID, SPECIES_VOX, SPECIES_TESHARI, SPECIES_VASILISSAN)

/obj/item/clothing/shoes/magboots/rig/protean
	name = "mass"
	desc = "Boot-shaped clusters of nanomachines."
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJ, SPECIES_UNATHI, SPECIES_NEVREAN, SPECIES_AKULA, SPECIES_SERGAL, SPECIES_ZORREN_HIGH, SPECIES_VULPKANIN, SPECIES_PROMETHEAN, SPECIES_XENOHYBRID, SPECIES_VOX, SPECIES_TESHARI, SPECIES_VASILISSAN)

/obj/item/clothing/suit/space/rig/protean
	name = "mass"
	desc = "A body-hugging mass of nanomachines."
	can_breach = 0
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJ, SPECIES_UNATHI, SPECIES_NEVREAN, SPECIES_AKULA, SPECIES_SERGAL, SPECIES_ZORREN_HIGH, SPECIES_VULPKANIN, SPECIES_PROMETHEAN, SPECIES_XENOHYBRID, SPECIES_VOX, SPECIES_TESHARI, SPECIES_VASILISSAN)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/device/flashlight,
		/obj/item/weapon/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/storage/backpack,
		)




//Backend stuff to make the sprites work. Copied and pasted from rig_pieces_vr.dm, but added ch to everything. Only reason for this to be touched is to add or remove species. This might just need to go in a new file named rig_pieces_ch.dm.
/obj/item/clothing/head/helmet/space/rig/protean
	sprite_sheets = list(
		SPECIES_HUMAN			= 'modular_chomp/icons/mob/head_ch.dmi',
		SPECIES_TAJ 			= 'modular_chomp/icons/mob/species/tajaran/helmet_ch.dmi',
		SPECIES_SKRELL 			= 'modular_chomp/icons/mob/species/skrell/helmet_ch.dmi',
		SPECIES_UNATHI 			= 'modular_chomp/icons/mob/species/unathi/helmet_ch.dmi',
		SPECIES_XENOHYBRID		= 'modular_chomp/icons/mob/species/unathi/helmet_ch.dmi',
		SPECIES_AKULA 			= 'modular_chomp/icons/mob/species/akula/helmet_ch.dmi',
		SPECIES_SERGAL			= 'modular_chomp/icons/mob/species/sergal/helmet_ch.dmi',
		SPECIES_NEVREAN			= 'modular_chomp/icons/mob/species/sergal/helmet_ch.dmi',
		SPECIES_VULPKANIN 		= 'modular_chomp/icons/mob/species/vulpkanin/helmet_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'modular_chomp/icons/mob/species/fox/helmet_ch.dmi',
		SPECIES_FENNEC 			= 'modular_chomp/icons/mob/species/vulpkanin/helmet_ch.dmi',
		SPECIES_PROMETHEAN		= 'modular_chomp/icons/mob/species/skrell/helmet_ch.dmi',
		SPECIES_TESHARI 		= 'icons/inventory/head/mob_ch_teshari.dmi',
		SPECIES_VASILISSAN		= 'modular_chomp/icons/mob/species/skrell/helmet_ch.dmi',
		SPECIES_VOX				= 'modular_chomp/icons/mob/species/vox/head_ch.dmi'
		)

	sprite_sheets_obj = list(
		SPECIES_HUMAN			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_TAJ 			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_SKRELL 			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_UNATHI 			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_XENOHYBRID		= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_AKULA 			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_SERGAL			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_NEVREAN			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_VULPKANIN 		= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_FENNEC 			= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_PROMETHEAN		= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_TESHARI 		= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_VASILISSAN		= 'icons/obj/clothing/hats_ch.dmi',
		SPECIES_VOX				= 'icons/obj/clothing/hats_ch.dmi'
		)

/obj/item/clothing/suit/space/rig/protean
	sprite_sheets = list(
		SPECIES_HUMAN			= 'modular_chomp/icons/mob/spacesuit_ch.dmi',
		SPECIES_TAJ 			= 'modular_chomp/icons/mob/species/tajaran/suit_ch.dmi',
		SPECIES_SKRELL 			= 'modular_chomp/icons/mob/species/skrell/suit_ch.dmi',
		SPECIES_UNATHI 			= 'modular_chomp/icons/mob/species/unathi/suit_ch.dmi',
		SPECIES_XENOHYBRID		= 'modular_chomp/icons/mob/species/unathi/suit_ch.dmi',
		SPECIES_AKULA 			= 'modular_chomp/icons/mob/species/akula/suit_ch.dmi',
		SPECIES_SERGAL			= 'modular_chomp/icons/mob/species/sergal/suit_ch.dmi',
		SPECIES_NEVREAN			= 'modular_chomp/icons/mob/species/sergal/suit_ch.dmi',
		SPECIES_VULPKANIN		= 'modular_chomp/icons/mob/species/vulpkanin/suit_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'modular_chomp/icons/mob/species/fox/suit_ch.dmi',
		SPECIES_FENNEC			= 'modular_chomp/icons/mob/species/vulpkanin/suit_ch.dmi',
		SPECIES_PROMETHEAN		= 'modular_chomp/icons/mob/species/skrell/suit_ch.dmi',
		SPECIES_TESHARI 		= 'icons/inventory/suit/mob_ch_teshari.dmi',
		SPECIES_VASILISSAN		= 'modular_chomp/icons/mob/species/skrell/suit_ch.dmi',
		SPECIES_VOX				= 'modular_chomp/icons/mob/species/vox/suit_ch.dmi'
		)

	sprite_sheets_obj = list(
		SPECIES_HUMAN			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_TAJ 			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_SKRELL 			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_UNATHI 			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_XENOHYBRID		= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_AKULA 			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_SERGAL			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_NEVREAN			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_VULPKANIN 		= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_FENNEC 			= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_PROMETHEAN		= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_TESHARI 		= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_VASILISSAN		= 'icons/obj/clothing/spacesuits_ch.dmi',
		SPECIES_VOX				= 'icons/obj/clothing/spacesuits_ch.dmi'
		)

/obj/item/clothing/gloves/gauntlets/rig/protean
	sprite_sheets = list(
		SPECIES_HUMAN			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_TAJ 			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_SKRELL 			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_UNATHI 			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_XENOHYBRID		= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_AKULA 			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_SERGAL			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_NEVREAN			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_VULPKANIN		= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_FENNEC			= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_PROMETHEAN		= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_TESHARI 		= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_VASILISSAN		= 'modular_chomp/icons/mob/hands_ch.dmi',
		SPECIES_VOX				= 'modular_chomp/icons/mob/species/vox/gloves_ch.dmi'
		)

	sprite_sheets_obj = list(
		SPECIES_HUMAN			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_TAJ 			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_SKRELL 			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_UNATHI 			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_XENOHYBRID		= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_AKULA 			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_SERGAL			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_NEVREAN			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_VULPKANIN 		= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_FENNEC 			= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_PROMETHEAN		= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_TESHARI 		= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_VASILISSAN		= 'icons/obj/clothing/gloves_ch.dmi',
		SPECIES_VOX				= 'icons/obj/clothing/gloves_ch.dmi'
		)

/obj/item/clothing/shoes/magboots/rig/protean
	sprite_sheets = list(
		SPECIES_HUMAN			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_TAJ 			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_SKRELL 			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_UNATHI 			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_XENOHYBRID		= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_AKULA 			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_SERGAL			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_NEVREAN			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_VULPKANIN		= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_FENNEC			= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_PROMETHEAN		= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_TESHARI 		= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_VASILISSAN		= 'modular_chomp/icons/mob/feet_ch.dmi',
		SPECIES_VOX				= 'modular_chomp/icons/mob/species/vox/shoes_ch.dmi'
		)

	sprite_sheets_obj = list(
		SPECIES_HUMAN			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_TAJ 			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_SKRELL 			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_UNATHI 			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_XENOHYBRID		= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_AKULA 			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_SERGAL			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_NEVREAN			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_VULPKANIN 		= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_ZORREN_HIGH 	= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_FENNEC 			= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_PROMETHEAN		= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_TESHARI 		= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_VASILISSAN		= 'icons/obj/clothing/shoes_ch.dmi',
		SPECIES_VOX				= 'icons/obj/clothing/shoes_ch.dmi'
		)

//Copy pasted most of this proc from base because I don't feel like rewriting the base proc with a shit load of exceptions
/obj/item/weapon/rig/protean/attackby(obj/item/W as obj, mob/living/user as mob)
	if(!istype(user))
		return 0
	if(dead)
		switch(dead)
			if(1)
				if(W.is_screwdriver())
					playsound(src, W.usesound, 50, 1)
					if(do_after(user,50,src,exclusive = TASK_ALL_EXCLUSIVE))
						to_chat(user, "<span class='notice'>You unscrew the maintenace panel on the [src].</span>")
						dead +=1
				return
			if(2)
				if(istype(W, /obj/item/device/protean_reboot))//placeholder
					if(do_after(user,50,src,exclusive = TASK_ALL_EXCLUSIVE))
						playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You carefully slot [W] in the [src].</span>")
						dead +=1
						qdel(W)
				return
			if(3)
				if(istype(W, /obj/item/stack/nanopaste))
					if(do_after(user,50,src,exclusive = TASK_ALL_EXCLUSIVE))
						playsound(src, 'sound/effects/ointment.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You slather the interior confines of the [src] with the [W].</span>")
						dead +=1
						W?:use(1)
				return
			if(4)
				if(istype(W, /obj/item/weapon/shockpaddles))
					if(W?:can_use(user))
						to_chat(user, "<span class='notice'>You hook up the [W] to the contact points in the maintenance assembly</span>")
						if(do_after(user,50,src,exclusive = TASK_ALL_EXCLUSIVE))
							playsound(src, 'sound/machines/defib_charge.ogg', 50, 0)
							if(do_after(user,10,src))
								playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)
								playsound(src, 'sound/machines/defib_success.ogg', 50, 0)
								new /obj/effect/gibspawner/robot(src.loc)
								src.atom_say("Contact received! Reassembly nanites calibrated. Estimated time to resucitation: 1 minute 30 seconds")
								dead = 0
								addtimer(CALLBACK(src, .proc/make_alive, myprotean?:humanform), 900)
				return
	if(istype(W,/obj/item/weapon/rig))
		if(!assimilated_rig)
			AssimilateRig(user,W)
	if(istype(W,/obj/item/weapon/tank)) //Todo, some kind of check for suits without integrated air supplies.
		if(air_supply)
			to_chat(user, "\The [src] already has a tank installed.")
			return

		if(!user.unEquip(W))
			return

		air_supply = W
		W.forceMove(src)
		to_chat(user, "You slot [W] into [src] and tighten the connecting valve.")
		return

		// Check if this is a hardsuit upgrade or a modification.
	else if(istype(W,/obj/item/rig_module))
		if(!installed_modules)
			installed_modules = list()
		if(installed_modules.len)
			for(var/obj/item/rig_module/installed_mod in installed_modules)
				if(!installed_mod.redundant && istype(installed_mod,W))
					to_chat(user, "The hardsuit already has a module of that class installed.")
					return 1

		var/obj/item/rig_module/mod = W
		to_chat(user, "You begin installing \the [mod] into \the [src].")
		if(!do_after(user,40))
			return
		if(!user || !W)
			return
		if(!user.unEquip(mod))
			return
		to_chat(user, "You install \the [mod] into \the [src].")
		installed_modules |= mod
		mod.forceMove(src)
		mod.installed(src)
		update_icon()
		return 1
	else if(W.is_wrench())
		if(!air_supply)
			to_chat(user, "There is no tank to remove.")
			return

		if(user.r_hand && user.l_hand)
			air_supply.forceMove(get_turf(user))
		else
			user.put_in_hands(air_supply)
		to_chat(user, "You detach and remove \the [air_supply].")
		air_supply = null
		return
	else if(W.is_screwdriver())
		var/list/possible_removals = list()
		for(var/obj/item/rig_module/module in installed_modules)
			if(module.permanent)
				continue
			possible_removals[module.name] = module

		if(!possible_removals.len)
			to_chat(user, "There are no installed modules to remove.")
			return

		var/removal_choice = tgui_input_list(usr, "Which module would you like to remove?", "Removal Choice", possible_removals)
		if(!removal_choice)
			return

		var/obj/item/rig_module/removed = possible_removals[removal_choice]
		to_chat(user, "You detach \the [removed] from \the [src].")
		removed.forceMove(get_turf(src))
		removed.removed()
		installed_modules -= removed
		update_icon()
		return
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(W,user)) //Item is handled in this proc
			return
	if(rig_storage)
		var/obj/item/weapon/storage/backpack = rig_storage
		if(backpack.can_be_inserted(W, 1))
			backpack.handle_item_insertion(W)
	else
		if(istype(W,/obj/item/weapon/storage/backpack))
			AssimilateBag(user,0,W)
	..()

/obj/item/weapon/rig/protean/proc/make_alive(var/mob/living/carbon/human/H, var/partial)
	if(H)
		H.setToxLoss(0)
		H.setOxyLoss(0)
		H.setCloneLoss(0)
		H.setBrainLoss(0)
		H.SetParalysis(0)
		H.SetStunned(0)
		H.SetWeakened(0)
		H.blinded = 0
		H.SetBlinded(0)
		H.eye_blurry = 0
		H.ear_deaf = 0
		H.ear_damage = 0
		H.heal_overall_damage(H.getActualBruteLoss(), H.getActualFireLoss(), 1)
		for(var/I in H.organs_by_name)
			if(!H.organs_by_name[I] || istype(H.organs_by_name[I], /obj/item/organ/external/stump))
				if(H.organs_by_name[I])
					var/obj/item/organ/external/oldlimb = H.organs_by_name[I]
					oldlimb.removed()
					qdel(oldlimb)
				var/list/organ_data = H.species.has_limbs[I]
				var/limb_path = organ_data["path"]
				var/obj/item/organ/external/new_eo = new limb_path(H)
				new_eo.robotize(H.synthetic ? H.synthetic.company : null)
				new_eo.sync_colour_to_human(H)
		if(!partial)
			dead_mob_list.Remove(H)
			living_mob_list += H
			H.tod = null
			H.timeofdeath = 0
			H.set_stat(CONSCIOUS)
			if(istype(H.species, /datum/species/protean))
				var/datum/species/protean/S
				S = H.species
				S.pseudodead = 0
				to_chat(myprotean, "<span class='notice'>You have finished reconstituting.</span>")
				playsound(src, 'sound/machines/ping.ogg', 50, 0)

/obj/item/weapon/rig/protean/take_hit(damage, source, is_emp=0)
	return	//We don't do that here

/obj/item/weapon/rig/protean/emp_act(severity_class)
	return	//Same here

/obj/item/weapon/rig/protean/cut_suit()
	return	//nope

/obj/item/weapon/rig/protean/force_rest(var/mob/user)
	wearer.lay_down()
	to_chat(user, "<span class='notice'>\The [wearer] is now [wearer.resting ? "resting" : "getting up"].</span>")

/obj/item/weapon/cell/protean
	name = "Protean power cell"
	desc = "Something terrible must have happened if you're managing to see this."
	maxcharge = 10000
	charge_amount = 100
	var/mob/living/carbon/human/charger

/obj/item/weapon/cell/protean/New()
	charge = maxcharge
	update_icon()
	addtimer(CALLBACK(src, .proc/search_for_protean), 60)

/obj/item/weapon/cell/protean/proc/search_for_protean()
	if(istype(src.loc, /obj/item/weapon/rig/protean))
		var/obj/item/weapon/rig/protean/prig = src.loc
		charger = prig.wearer
	if(charger)
		START_PROCESSING(SSobj, src)

/obj/item/weapon/cell/protean/process()
	var/C = charge
	if(charger)
		if((world.time >= last_use + charge_delay) && charger.nutrition > 100)
			give(charge_amount)
			charger.nutrition -= ((1/200)*(charge - C))	//Take nutrition relative to charge. Change the 1/200 if you want to alter the nutrition to charge ratio
	else
		return PROCESS_KILL


/obj/item/weapon/rig/protean/equipped(mob/living/carbon/human/M)
	..()
	if(dead)
		canremove = 1
	else
		canremove = 0

/obj/item/weapon/rig/protean/ai_can_move_suit(mob/user, check_user_module = 0, check_for_ai = 0)
	if(check_for_ai)
		return 0	//We don't do that here.
	if(offline || !cell || !cell.charge || locked_down)
		if(user)
			to_chat(user, "<span class='warning'>Your host rig is unpowered and unresponsive.</span>")
		return 0
	if(!wearer || (wearer.back != src && wearer.belt != src))
		if(user)
			to_chat(user, "<span class='warning'>Your host rig is not being worn.</span>")
		return 0
	return 1

/obj/item/weapon/rig/protean/toggle_seals(mob/living/carbon/human/M, instant)
	M = src.wearer
	..()

/obj/item/weapon/rig/protean/toggle_cooling(mob/user)
	user = src.wearer
	..()

/obj/item/weapon/rig/protean/toggle_piece(piece, mob/living/carbon/human/H, deploy_mode, forced)
	H = src.wearer
	..()

/obj/item/weapon/rig/protean/get_description_interaction()
	if(dead)
		var/list/results = list()
		switch(dead)
			if(1)
				results += "Use a screwdriver to start repairs."
			if(2)
				results += "Insert a Protean Reboot Programmer, printed from a protolathe."
			if(3)
				results += "Use some Nanopaste."
			if(4)
				results += "Use either a defib or jumper cables to start the reboot sequence."
		return results

//Effectively a round about way of letting a Protean wear other rigs.
/obj/item/weapon/rig/protean/proc/AssimilateRig(mob/user, var/obj/item/weapon/rig/R)
	if(!R || assimilated_rig)
		return
	to_chat(user, "You assimilate the [R] into the [src]. Mimicking its stats and appearance.")
	for(var/obj/item/piece in list(gloves,helmet,boots,chest))
		piece.armor = R.armor.Copy()
	//I dislike this piece of code, but not every rig has the full set of parts
	if(R.gloves)
		gloves.sprite_sheets = R.gloves.sprite_sheets.Copy()
		gloves.sprite_sheets_obj = R.gloves.sprite_sheets.Copy()
		gloves.icon_state = R.gloves.icon_state
	if(R.helmet)
		helmet.sprite_sheets = R.helmet.sprite_sheets.Copy()
		helmet.sprite_sheets_obj = R.helmet.sprite_sheets.Copy()
		helmet.icon_state = R.helmet.icon_state
	if(R.boots)
		boots.sprite_sheets = R.boots.sprite_sheets.Copy()
		boots.sprite_sheets_obj = R.boots.sprite_sheets.Copy()
		boots.icon_state = R.boots.icon_state
	if(R.chest)
		chest.sprite_sheets = R.chest.sprite_sheets.Copy()
		chest.sprite_sheets_obj = R.chest.sprite_sheets.Copy()
		chest.icon_state = R.chest.icon_state
	suit_state = R.suit_state
	user.drop_item(R)
	contents += R
	assimilated_rig = R
	slowdown = (R.slowdown *0.5)
	offline_slowdown = slowdown

/obj/item/weapon/rig/protean/verb/RemoveRig()
	set name = "Remove Assimilated Rig"
	set category = "Object"

	if(assimilated_rig)
		for(var/obj/item/piece in list(gloves,helmet,boots,chest))
			piece.armor = armor.Copy()
			piece.icon_state = initial(piece.icon_state)

		//Byond at this time does not support initial() on lists
		//So we have to create a new rig, just so we can copy the lists we're after
		//If someone figures out a smarter way to do this, please tell me
		var/obj/item/weapon/rig/tempRig = new /obj/item/weapon/rig/protean()
		gloves.sprite_sheets = tempRig.gloves.sprite_sheets.Copy()
		gloves.sprite_sheets_obj = tempRig.gloves.sprite_sheets.Copy()
		helmet.sprite_sheets = tempRig.helmet.sprite_sheets.Copy()
		helmet.sprite_sheets_obj = tempRig.helmet.sprite_sheets.Copy()
		boots.sprite_sheets = tempRig.boots.sprite_sheets.Copy()
		boots.sprite_sheets_obj = tempRig.boots.sprite_sheets.Copy()
		chest.sprite_sheets = tempRig.chest.sprite_sheets.Copy()
		chest.sprite_sheets_obj = tempRig.chest.sprite_sheets.Copy()
		slowdown = initial(slowdown)
		suit_state = icon_state
		offline_slowdown = initial(offline_slowdown)
		usr.put_in_hands(assimilated_rig)
		assimilated_rig = null
		qdel(tempRig)
	else
		to_chat(usr, "[src] has not assimilated a RIG. Use one on it to assimilate.")
