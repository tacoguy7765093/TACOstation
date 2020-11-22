// These metroids have the mechanics xenobiologists care about, such as reproduction, mutating into new colors, and being able to submit through fear.

/mob/living/simple_mob/metroid/juvenile
	desc = "This metroid should not be spawned. Yell at your local dev or event manager."
	layer = MOB_LAYER + 1 // Need them on top of other mobs or it looks weird when consuming something.
	max_nutrition = 1000
	var/is_queen = FALSE // When the metroid is a queen, it should just be shitting out babies. Found in metAI.dm and in metTypes for the queen.
	var/maxHealth_adult = 200
	var/power_charge = 0 // Disarm attacks can shock someone if high/lucky enough.
	var/mob/living/victim = null // the person the metroid is currently feeding on
	var/amount_grown = 0 // controls how long the metroid has been overfed, if 10, grows or reproduces
	var/number = 0 // This is used to make the metroid semi-unique for indentification.
	var/harmless = FALSE // Set to true when pacified. Makes the metroid harmless, not get hungry, and not be able to grow/reproduce.


/mob/living/simple_mob/metroid/juvenile/Destroy()
	if(victim)
		stop_consumption() // Unbuckle us from our victim.
	return ..()


/mob/living/simple_mob/metroid/juvenile/handle_special()
	if(stat != DEAD)
		if(victim)
			handle_consumption()

		handle_stuttering() // ??

	..()

/mob/living/simple_mob/metroid/juvenile/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		. += "It appears to be dead."
	else if(incapacitated(INCAPACITATION_DISABLED))
		. += "It appears to be incapacitated."
	else if(harmless)
		. += "It appears to have been pacified."

/mob/living/simple_mob/metroid/juvenile/verb/evolve()
	set category = "metroid"
	set desc = "This will let you advance to next form."

	if(stat)
		to_chat(src, span("warning", "I must be conscious to do this..."))
		return

	if(is_queen)
		paralysis = 7998
		playsound(src, 'sound/metroid/metroidgrow.ogg', 50, 1)
		src.visible_message("<span class='notice'>\The [src] begins to lay an egg.</span>")
		spawn(50)
		new /obj/effect/metroid/egg(loc, src)
		adjust_nutrition(-500)
		paralysis = 0
		return
		
	if(nutrition >= evo_point && !buckled && vore_fullness == 0 && !victim)
		if(next == "/mob/living/simple_mob/metroid/juvenile/queen" && GLOB.queen_amount > 0)
			to_chat(src, span("warning", "There is already a queen."))
			return
		playsound(src, 'sound/metroid/metroidgrow.ogg', 50, 1)
		paralysis = 7998
		sleep(50)
		expand_troid()

	if(nutrition >= evo_limit && (buckled || vore_fullness == 1)) //spit dat crap out if nutrition gets too high!
		release_vore_contents()
		prey_excludes.Cut()
		stop_consumption()
		
	else
		to_chat(src, span("warning", "I am not ready to evolve yet..."))

/mob/living/simple_mob/metroid/juvenile/proc/expand_troid()
	var/mob/living/L
	L = new next(get_turf(src)) //Next is a variable defined by metTypes.dm that just points to the next metroid in the evolutionary stage.
	if(mind)
		src.mind.transfer_to(L)
	visible_message("<span class='warning'>\The [src] suddenly evolves!</span>")
	qdel(src)	

// Code for metroids attacking other things.
// metroid attacks change based on intent.
/mob/living/simple_mob/metroid/juvenile/apply_attack(mob/living/L, damage_to_do)
	if(istype(L))
		switch(a_intent)
			if(I_HELP) // This shouldn't happen but just in case.
				return FALSE

			if(I_DISARM)
				var/stun_power = between(0, power_charge + rand(0, 3), 10)

				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					stun_power *= max(H.species.siemens_coefficient, 0)

				if(prob(stun_power * 10)) // Try an electric shock.
					power_charge = max(0, power_charge - 3)
					L.visible_message(
						span("danger", "\The [src] has shocked \the [L]!"),
						span("danger", "\The [src] has shocked you!")
						)
					playsound(src, 'sound/weapons/Egloves.ogg', 75, 1)
					L.Weaken(4)
					L.Stun(4)
					do_attack_animation(L)
					if(L.buckled)
						L.buckled.unbuckle_mob() // To prevent an exploit where being buckled prevents metroids from jumping on you.
					L.stuttering = max(L.stuttering, stun_power)

					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, L)
					s.start()

					if(prob(stun_power * 10) && stun_power >= 8)
						L.adjustFireLoss(power_charge * rand(1, 2))
					return FALSE

				else if(prob(20)) // Try to do a regular disarm attack.
					L.visible_message(
						span("danger", "\The [src] has pounced at \the [L]!"),
						span("danger", "\The [src] has pounced at you!")
						)
					playsound(src, 'sound/weapons/thudswoosh.ogg', 75, 1)
					L.Weaken(2)
					do_attack_animation(L)
					if(L.buckled)
						L.buckled.unbuckle_mob() // To prevent an exploit where being buckled prevents metroids from jumping on you.
					return FALSE

				else // Failed to do anything this time.
					L.visible_message(
						span("warning", "\The [src] has tried to pounce at \the [L]!"),
						span("warning", "\The [src] has tried to pounce at you!")
						)
					playsound(src, 'sound/weapons/punchmiss.ogg', 75, 1)
					do_attack_animation(L)
					return FALSE

			if(I_GRAB)
				start_consuming(L)
				return FALSE

			if(I_HURT)
				return ..() // Regular stuff.
	else
		return ..() // Do the regular stuff if we're hitting a window/mech/etc.

/mob/living/simple_mob/metroid/juvenile/apply_melee_effects(mob/living/L)
	if(istype(L) && a_intent == I_HURT)
		// Feed off of their flesh, if able.
		consume(L, 5)
