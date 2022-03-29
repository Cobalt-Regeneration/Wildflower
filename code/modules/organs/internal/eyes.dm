
/obj/item/organ/internal/eye
	name = "left eyeball"
	desc = "Well... this isn't right."
	icon_state = "eye"
	gender = PLURAL
	organ_tag = BP_L_EYE
	parent_organ = BP_HEAD
	surface_accessible = TRUE
	relative_size = 5
	var/phoron_guard = 0
	var/list/eye_colour = list(0,0,0)
	var/innate_flash_protection = FLASH_PROTECTION_NONE
	max_damage = 45
	var/eye_icon = 'icons/mob/human_races/species/default_left_eye.dmi'
	var/apply_eye_colour = TRUE
	var/tmp/last_cached_eye_colour
	var/tmp/last_eye_cache_key
	var/flash_mod
	var/darksight_range
	var/darksight_tint

/obj/item/organ/internal/eye/right
	name = "right eyeball"
	desc = "Well... this isn't left."
	eye_icon = 'icons/mob/human_races/species/default_right_eye.dmi'
	organ_tag = BP_R_EYE

/obj/item/organ/internal/eye/proc/get_eye_cache_key()
	last_cached_eye_colour = rgb(eye_colour[1],eye_colour[2], eye_colour[3])
	last_eye_cache_key = "[type]-[eye_icon]-[last_cached_eye_colour]"
	return last_eye_cache_key

/obj/item/organ/internal/eye/proc/get_onhead_icon()
	var/cache_key = get_eye_cache_key()
	if(!human_icon_cache[cache_key])
		var/icon/eyes_icon = icon(icon = eye_icon, icon_state = "")
		if(apply_eye_colour)
			eyes_icon.Blend(last_cached_eye_colour, ICON_ADD)
		human_icon_cache[cache_key] = eyes_icon
	return human_icon_cache[cache_key]

/obj/item/organ/internal/eye/proc/get_special_overlay()
	var/icon/I = get_onhead_icon()
	if(I)
		var/cache_key = "[last_eye_cache_key]-glow"
		if(!human_icon_cache[cache_key])
			var/image/eye_glow = image(I)
			eye_glow.layer = EYE_GLOW_LAYER
			eye_glow.plane = EFFECTS_ABOVE_LIGHTING_PLANE
			human_icon_cache[cache_key] = eye_glow
		return human_icon_cache[cache_key]

/obj/item/organ/internal/eye/proc/change_left_eye_color()
	set name = "Change Left Eye Color"
	set desc = "Changes your robotic eye color."
	set category = "IC"
	set src in usr
	if (!owner || owner.incapacitated())
		return
	var/new_eyes = input("Please select left eye color.", "Eye Color", rgb(owner.r_l_eye, owner.g_l_eye, owner.b_l_eye)) as color|null
	if(new_eyes)
		var/r_eyes = hex2num(copytext(new_eyes, 2, 4))
		var/g_eyes = hex2num(copytext(new_eyes, 4, 6))
		var/b_eyes = hex2num(copytext(new_eyes, 6, 8))
		if(do_after(owner, 10) && owner.change_specific_eye_color(r_eyes, g_eyes, b_eyes, TRUE))
			update_colour()
			// Finally, update the eye icon on the mob.
			owner.regenerate_icons()
			owner.visible_message(SPAN_NOTICE("\The [owner] changes their left eye color."),SPAN_NOTICE("You change your eye color."),)

/obj/item/organ/internal/eye/right/change_left_eye_color()
	return

/obj/item/organ/internal/eye/right/proc/change_right_eye_color()
	set name = "Change Right Eye Color"
	set desc = "Changes your robotic eye color."
	set category = "IC"
	set src in usr
	if (!owner || owner.incapacitated())
		return
	var/new_eyes = input("Please select right eye color.", "Eye Color", rgb(owner.r_r_eye, owner.g_r_eye, owner.b_r_eye)) as color|null
	if(new_eyes)
		var/r_eyes = hex2num(copytext(new_eyes, 2, 4))
		var/g_eyes = hex2num(copytext(new_eyes, 4, 6))
		var/b_eyes = hex2num(copytext(new_eyes, 6, 8))
		if(do_after(owner, 10) && owner.change_specific_eye_color(r_eyes, g_eyes, b_eyes, FALSE))
			update_colour()
			// Finally, update the eye icon on the mob.
			owner.regenerate_icons()
			owner.visible_message(SPAN_NOTICE("\The [owner] changes their right eye color."),SPAN_NOTICE("You change your eye color."),)

/obj/item/organ/internal/eye/replaced(var/mob/living/carbon/human/target)

	// Apply our eye colour to the target.
	if(istype(target) && eye_colour)
		target.change_specific_eye_color(eye_colour[1], eye_colour[2], eye_colour[3], organ_tag == BP_L_EYE ? TRUE : FALSE)
	..()

/obj/item/organ/internal/eye/proc/update_colour()
	if(!owner)
		return
	if(organ_tag == BP_L_EYE)
		eye_colour = list(owner.r_l_eye ? owner.r_l_eye : 0, owner.g_l_eye ? owner.g_l_eye : 0, owner.b_l_eye ? owner.b_l_eye : 0)
	else
		eye_colour = list(owner.r_r_eye ? owner.r_r_eye : 0, owner.g_r_eye ? owner.g_r_eye : 0, owner.b_r_eye ? owner.b_r_eye : 0)

/obj/item/organ/internal/eye/take_internal_damage(amount, var/silent=0)
	var/oldbroken = is_broken()
	. = ..()
	if(is_broken() && !oldbroken && owner && !owner.stat)
		to_chat(owner, "<span class='danger'>You go blind!</span>")

/obj/item/organ/internal/eye/Process() //Eye damage replaces the old eye_stat var.
	..()
	/* No longer needed, Life() handles these checks for all eyes on a mob
	if(!owner)
		return
	if(is_bruised())
		owner.eye_blurry = 20
	if(is_broken())
		owner.eye_blind = 20
	*/

/obj/item/organ/internal/eye/New()
	..()
	flash_mod = species.flash_mod
	darksight_range = species.darksight_range
	darksight_tint = species.darksight_tint

/obj/item/organ/internal/eye/proc/get_total_protection(var/flash_protection = FLASH_PROTECTION_NONE)
	return (flash_protection + innate_flash_protection)

/obj/item/organ/internal/eye/proc/additional_flash_effects(var/intensity)
	return -1

/obj/item/organ/internal/eye/robot
	name = "left optical sensor"
	organ_tag = BP_L_EYE
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/eye/right/robot
	name = "right optical sensor"
	organ_tag = BP_R_EYE
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/eye/robot/New()
	..()
	robotize()

/obj/item/organ/internal/eye/robotize()
	..()
	name = "[organ_tag == BP_L_EYE ? "left" : "right"] optical sensor"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	dead_icon = "camera_broken"
	if(istype(src, /obj/item/organ/internal/eye/right)) // This is messy. I hate this.
		var/obj/item/organ/internal/eye/right/R = src
		R.verbs |= /obj/item/organ/internal/eye/right/proc/change_right_eye_color
	else
		verbs |= /obj/item/organ/internal/eye/proc/change_left_eye_color
	update_colour()
	flash_mod = 1
	darksight_range = 2
	darksight_tint = DARKTINT_NONE
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/eye/get_mechanical_assisted_descriptor()
	return "retinal overlayed [name]"
