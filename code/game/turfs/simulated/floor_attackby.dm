/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob)

	if(!C || !user)
		return 0

	if(flooring)
		if(iscrowbar(C))
			if(broken || burnt)
				user << "<span class='notice'>You remove the broken [flooring.descriptor].</span>"
				make_plating()
			else if(flooring.flags & TURF_IS_FRAGILE)
				user << "<span class='danger'>You forcefully pry off the [flooring.descriptor], destroying them in the process.</span>"
				make_plating()
			else if(flooring.flags & TURF_REMOVE_CROWBAR)
				user << "<span class='notice'>You lever off the [flooring.descriptor].</span>"
				make_plating(1)
			else
				return
			playsound(src, C.usesound, 80, 1)
			return
		else if(isscrewdriver(C) && (flooring.flags & TURF_REMOVE_SCREWDRIVER))
			if(broken || burnt)
				return
			user << "<span class='notice'>You unscrew and remove the [flooring.descriptor].</span>"
			make_plating(1)
			playsound(src, C.usesound, 80, 1)
			return
		else if(iswrench(C) && (flooring.flags & TURF_REMOVE_WRENCH))
			user << "<span class='notice'>You unwrench and remove the [flooring.descriptor].</span>"
			make_plating(1)
			playsound(src, C.usesound, 80, 1)
			return
		else if(istype(C, /obj/item/weapon/shovel) && (flooring.flags & TURF_REMOVE_SHOVEL))
			user << "<span class='notice'>You shovel off the [flooring.descriptor].</span>"
			make_plating(1)
			playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
			return
		else if(iscoil(C))
			user << "<span class='warning'>You must remove the [flooring.descriptor] first.</span>"
			return
	else

		if(iscoil(C))
			if(broken || burnt)
				user << "<span class='warning'>This section is too damaged to support anything. Use a welder to fix the damage.</span>"
				return
			var/obj/item/stack/cable_coil/coil = C
			coil.turf_place(src, user)
			return
		else if(istype(C, /obj/item/stack))
			if(broken || burnt)
				user << "<span class='warning'>This section is too damaged to support anything. Use a welder to fix the damage.</span>"
				return
			var/obj/item/stack/S = C
			var/decl/flooring/use_flooring
			for(var/flooring_type in flooring_types)
				var/decl/flooring/F = flooring_types[flooring_type]
				if(!F.build_type)
					continue
				if(ispath(S.type, F.build_type) || ispath(S.build_type, F.build_type))
					use_flooring = F
					break
			if(!use_flooring)
				return
			// Do we have enough?
			if(use_flooring.build_cost && S.get_amount() < use_flooring.build_cost)
				user << "<span class='warning'>You require at least [use_flooring.build_cost] [S.name] to complete the [use_flooring.descriptor].</span>"
				return
			// Stay still and focus...
			if(use_flooring.build_time && !do_after(user, use_flooring.build_time))
				return
			if(flooring || !S || !user || !use_flooring)
				return
			if(S.use(use_flooring.build_cost))
				set_flooring(use_flooring)
				playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
				return
		// Repairs.
		else if(iswelder(C))
			var/obj/item/weapon/weldingtool/welder = C
			if(welder.isOn() && (is_plating()))
				if(broken || burnt)
					if(welder.remove_fuel(0,user))
						user << "<span class='notice'>You fix some dents on the broken plating.</span>"
						playsound(src, 'sound/items/Welder.ogg', 80, 1)
						icon_state = "plating"
						burnt = null
						broken = null
					else
						user << "<span class='warning'>You need more welding fuel to complete this task.</span>"

/turf/simulated/floor/can_lay_cable()
	return !flooring

/turf/simulated/can_have_cabling()
	return TRUE
