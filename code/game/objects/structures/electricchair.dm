/obj/structure/bed/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/on = 0
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1.0

/obj/structure/bed/chair/e_chair/Initialize()
	. = ..()
	add_overlay(image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1))

/obj/structure/bed/chair/e_chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		var/obj/structure/bed/chair/C = new /obj/structure/bed/chair(loc)
		playsound(loc, W.usesound, 50, 1)
		C.set_dir(dir)
		part.loc = loc
		part.master = null
		part = null
		qdel(src)

/obj/structure/bed/chair/e_chair/verb/toggle()
	set name = "Toggle Electric Chair"
	set category = "Object"
	set src in oview(1)

	if(on)
		on = 0
		icon_state = "echair0"
	else
		on = 1
		shock()
		icon_state = "echair1"
	usr << "<span class='notice'>You switch [on ? "on" : "off"] [src].</span>"

/obj/structure/bed/chair/e_chair/proc/shock()
	if(!on)
		return
	if(last_time + 50 > world.time)
		return
	last_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	A.use_power(EQUIP, 5000)
	var/light = A.power_light
	A.update_icon()

	flick("echair1", src)
	spark(src, 12, alldirs)
	if(buckled_mob)
		buckled_mob.burn_skin(85)
		buckled_mob << "<span class='danger'>You feel a deep shock course through your body!</span>"
		sleep(1)
		buckled_mob.burn_skin(85)
		buckled_mob.Stun(600)
	visible_message("<span class='danger'>The electric chair goes off!</span>", "<span class='danger'>You hear a deep sharp shock!</span>")

	A.power_light = light
	A.update_icon()
	return
