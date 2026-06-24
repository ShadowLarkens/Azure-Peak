/proc/hairmask_clean(mask)
	if(!istext(mask))
		return null
	var/mask_length = length(mask)
	if(!mask_length)
		return null
	mask = lowertext(mask)
	if(mask_length != 256)
		return null
	for(var/i in 1 to mask_length)
		var/char_code = text2ascii(mask, i)
		if(char_code < 48)
			return null
		if(char_code <= 57)
			continue
		if(char_code < 97 || char_code > 102)
			return null
	return mask

/proc/hairmask_hex_value(mask, index)
	if(!istext(mask) || index < 1 || index > length(mask))
		return -1
	var/char_code = text2ascii(mask, index)
	if(char_code >= 48 && char_code <= 57)
		return char_code - 48
	if(char_code >= 97 && char_code <= 102)
		return char_code - 87
	if(char_code >= 65 && char_code <= 70)
		return char_code - 55
	return -1

/proc/hair_preview_dirs()
	var/static/list/dirs = list(SOUTH, WEST, NORTH, EAST)
	return dirs

/proc/hair_dir_valid(preview_dir)
	return preview_dir in hair_preview_dirs()

/proc/hairmask_dir_map(dir_layers)
	if(!islist(dir_layers))
		return null
	var/list/mapped = list()
	for(var/list/layer in dir_layers)
		if(!islist(layer))
			continue
		var/color = sanitize_hexcolor(layer["color"], 6, TRUE)
		if(!color)
			continue
		var/mask = hairmask_normalize(layer["mask"])
		if(mask)
			mapped[color] = mask
	return mapped.len ? mapped : null

/proc/hairmask_valid(mask)
	return istext(mask) && length(mask) == 256

/proc/hairmask_normalize(mask)
	return hairmask_valid(mask) ? mask : hairmask_clean(mask)

/proc/hairmask_get_fast(masks, preview_dir)
	if(!islist(masks))
		return null
	var/key = hair_dir_key(preview_dir)
	var/mask = masks[key]
	return hairmask_valid(mask) ? mask : null

/proc/hairmask_list_fast(masks)
	if(!islist(masks))
		return null
	var/list/out = list()
	for(var/preview_dir in hair_preview_dirs())
		var/key = hair_dir_key(preview_dir)
		var/mask = masks[key]
		if(hairmask_valid(mask))
			out[key] = mask
	return out.len ? out : null

/proc/hairmask_layers_fast(layers)
	if(!islist(layers))
		return null
	var/list/out = list()
	for(var/color in layers)
		var/safe_color = sanitize_hexcolor(color, 6, TRUE)
		var/list/masks = hairmask_list_fast(layers[color])
		if(safe_color && masks?.len)
			out[safe_color] = masks
	return out.len ? out : null

/proc/hairmask_put_fast(masks, preview_dir, mask)
	if(!islist(masks))
		masks = list()
	var/key = hair_dir_key(preview_dir)
	masks[key] = hairmask_valid(mask) ? mask : null
	return hairmask_list_fast(masks)

/proc/hairmask_set_fast(mask, pixel_x, pixel_y, state)
	if(pixel_x < 1 || pixel_x > 32 || pixel_y < 1 || pixel_y > 32)
		return hairmask_valid(mask) ? mask : null
	if(!hairmask_valid(mask))
		mask = repeat_string(256, "0")
	var/pixel_index = ((pixel_y - 1) * 32) + (pixel_x - 1)
	var/hex_index = (pixel_index >> 2) + 1
	var/bit_index = pixel_index & 3
	var/hex_value = hairmask_hex_value(mask, hex_index)
	if(state)
		hex_value |= (1 << bit_index)
	else
		hex_value &= ~(1 << bit_index)
	return copytext(mask, 1, hex_index) + num2hex(hex_value, 1) + copytext(mask, hex_index + 1)

/proc/hairmask_bit_fast(mask, pixel_x, pixel_y)
	if(!hairmask_valid(mask) || pixel_x < 1 || pixel_x > 32 || pixel_y < 1 || pixel_y > 32)
		return FALSE
	var/pixel_index = ((pixel_y - 1) * 32) + (pixel_x - 1)
	var/hex_index = (pixel_index >> 2) + 1
	var/bit_index = pixel_index & 3
	var/hex_value = hairmask_hex_value(mask, hex_index)
	return !!(hex_value & (1 << bit_index))

/proc/hairmask_set(mask, pixel_x, pixel_y, state)
	return hairmask_set_fast(hairmask_clean(mask), pixel_x, pixel_y, state)

/proc/hair_dir_key(preview_dir)
	var/static/list/dir_keys = list(
		"[SOUTH]" = "s",
		"[WEST]" = "w",
		"[NORTH]" = "n",
		"[EAST]" = "e",
	)
	return dir_keys["[preview_dir]"]

/proc/hair_dir_label(preview_dir)
	switch(preview_dir)
		if(SOUTH)
			return "South"
		if(WEST)
			return "West"
		if(NORTH)
			return "North"
		if(EAST)
			return "East"
	return "South"

/proc/hairmask_list(masks)
	if(!islist(masks))
		return null
	var/list/out = list()
	for(var/preview_dir in hair_preview_dirs())
		var/key = hair_dir_key(preview_dir)
		var/mask = hairmask_clean(masks[key])
		if(mask)
			out[key] = mask
	return out.len ? out : null

/proc/hairmask_get(masks, preview_dir)
	if(!islist(masks))
		return null
	var/key = hair_dir_key(preview_dir)
	return hairmask_clean(masks[key])

/proc/hairmask_put(masks, preview_dir, mask)
	return hairmask_put_fast(masks, preview_dir, hairmask_clean(mask))

/proc/hairmask_plot(masks, preview_dir, pixel_x, pixel_y, state)
	return hairmask_put_fast(masks, preview_dir, hairmask_set_fast(hairmask_get_fast(masks, preview_dir), pixel_x, pixel_y, state))

/proc/hairmask_union(mask_a, mask_b)
	mask_a = hairmask_clean(mask_a)
	mask_b = hairmask_clean(mask_b)
	if(!mask_a)
		return mask_b
	if(!mask_b)
		return mask_a
	if(mask_a == mask_b)
		return mask_a
	var/static/empty_row = "00000000"
	var/list/rows = list()
	for(var/row in 1 to 32)
		var/row_start = ((row - 1) << 3) + 1
		var/row_end = row_start + 8
		var/row_a = copytext(mask_a, row_start, row_end)
		var/row_b = copytext(mask_b, row_start, row_end)
		if(row_a == row_b)
			rows += row_a
			continue
		if(row_a == empty_row)
			rows += row_b
			continue
		if(row_b == empty_row)
			rows += row_a
			continue
		var/row_text = ""
		for(var/hex_offset in 0 to 7)
			var/index = row_start + hex_offset
			var/value_a = hairmask_hex_value(mask_a, index)
			var/value_b = hairmask_hex_value(mask_b, index)
			row_text += num2hex(value_a | value_b, 1)
		rows += row_text
	return jointext(rows, "")

/proc/hairmask_layers(layers)
	if(!islist(layers))
		return null
	var/list/out = list()
	for(var/color in layers)
		var/safe_color = sanitize_hexcolor(color, 6, TRUE)
		var/list/masks = hairmask_list(layers[color])
		if(safe_color && masks?.len)
			out[safe_color] = masks
	return out.len ? out : null

/proc/hairmask_layer_get(layers, color, preview_dir)
	if(!islist(layers))
		return null
	color = sanitize_hexcolor(color, 6, TRUE)
	if(!color)
		return null
	return hairmask_get(layers[color], preview_dir)

/proc/hairmask_layer_put(layers, color, preview_dir, mask)
	color = sanitize_hexcolor(color, 6, TRUE)
	if(!color)
		return hairmask_layers(layers)
	if(!islist(layers))
		layers = list()
	var/list/updated = hairmask_put(layers[color], preview_dir, mask)
	if(updated)
		layers[color] = updated
	else
		layers -= color
	return hairmask_layers(layers)

/proc/hairmask_layer_plot(layers, color, preview_dir, pixel_x, pixel_y, state)
	color = sanitize_hexcolor(color, 6, TRUE)
	if(!color)
		return hairmask_layers(layers)
	if(!islist(layers))
		layers = list()
	var/current_mask = hairmask_get_fast(layers[color], preview_dir)
	var/list/updated = hairmask_put_fast(layers[color], preview_dir, hairmask_set_fast(current_mask, pixel_x, pixel_y, state))
	if(updated)
		layers[color] = updated
	else
		layers -= color
	return hairmask_layers(layers)

/proc/hairmask_layers_any(layers)
	return !!hairmask_layers_fast(layers)

/proc/hairmask_dir_any(layers, preview_dir)
	if(!islist(layers))
		return FALSE
	for(var/color in layers)
		if(hairmask_get_fast(layers[color], preview_dir))
			return TRUE
	return FALSE

/proc/hairmask_dir_data(layers, preview_dir)
	layers = hairmask_layers_fast(layers)
	if(!layers)
		return null
	var/list/data = list()
	for(var/color in layers)
		var/mask = hairmask_get_fast(layers[color], preview_dir)
		if(mask)
			data += list(list(
				"color" = color,
				"mask" = mask,
			))
	return data.len ? data : null

/proc/hairmask_clear_px(layers, preview_dir, pixel_x, pixel_y)
	layers = hairmask_layers_fast(layers) || hairmask_layers(layers)
	if(!layers)
		return null
	var/list/colors = list()
	for(var/color in layers)
		colors += color
	for(var/color in colors)
		var/list/masks = layers[color]
		var/current_mask = hairmask_get_fast(masks, preview_dir)
		var/list/updated = hairmask_put_fast(masks, preview_dir, hairmask_set_fast(current_mask, pixel_x, pixel_y, FALSE))
		if(updated)
			layers[color] = updated
		else
			layers -= color
	return hairmask_layers_fast(layers)

/proc/hairmask_layer_merge(layers, color, masks)
	color = sanitize_hexcolor(color, 6, TRUE)
	masks = hairmask_list_fast(masks) || hairmask_list(masks)
	if(!color || !masks)
		return hairmask_layers(layers)
	if(!islist(layers))
		layers = list()
	var/list/existing = hairmask_list_fast(layers[color]) || hairmask_list(layers[color])
	var/list/merged = list()
	for(var/preview_dir in hair_preview_dirs())
		var/mask = hairmask_union(hairmask_get_fast(existing, preview_dir), hairmask_get_fast(masks, preview_dir))
		var/key = hair_dir_key(preview_dir)
		if(mask)
			merged[key] = mask
	if(merged.len)
		layers[color] = merged
	else
		layers -= color
	return hairmask_layers(layers)

/proc/hairmask_dir_replace(layers, preview_dir, dir_layers)
	if(!hair_dir_valid(preview_dir))
		return hairmask_layers(layers)
	var/list/current_layers = hairmask_layers_fast(layers)
	if(!current_layers)
		current_layers = hairmask_layers(layers)
	var/list/replaced = hairmask_dir_map(dir_layers)
	var/list/next_layers = list()
	var/list/colors = list()
	if(islist(current_layers))
		for(var/color in current_layers)
			if(!(color in colors))
				colors += color
	if(islist(replaced))
		for(var/color in replaced)
			if(color && !(color in colors))
				colors += color
	for(var/color in colors)
		var/list/color_masks = current_layers?[color]
		var/mask = replaced?[color]
		var/list/updated = hairmask_put_fast(color_masks, preview_dir, mask)
		if(updated)
			next_layers[color] = updated
	return hairmask_layers_fast(next_layers)

/proc/hairmask_has_bits(mask)
	mask = hairmask_normalize(mask)
	if(!mask)
		return FALSE
	var/mask_length = length(mask)
	for(var/i in 1 to mask_length)
		if(text2ascii(mask, i) != 48)
			return TRUE
	return FALSE

/proc/hairmask_crop_y(mask, min_y, max_y)
	mask = hairmask_normalize(mask)
	if(!mask)
		return null
	min_y = clamp(round(min_y), 1, 32)
	max_y = clamp(round(max_y), 1, 32)
	if(min_y > max_y)
		return null
	var/prefix_len = (min_y - 1) << 3
	var/suffix_len = (32 - max_y) << 3
	var/keep_start = prefix_len + 1
	var/keep_end = (max_y << 3) + 1
	var/body = copytext(mask, keep_start, keep_end)
	var/has_bits = FALSE
	var/body_length = length(body)
	for(var/i in 1 to body_length)
		if(text2ascii(body, i) != 48)
			has_bits = TRUE
			break
	if(!has_bits)
		return null
	return "[repeat_string(prefix_len, "0")][body][repeat_string(suffix_len, "0")]"

/proc/hair_entry_masks(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return null
	var/list/colormasks = hairmask_layers_fast(hair_entry.colormasks)
	if(!colormasks)
		colormasks = hairmask_layers(hair_entry.colormasks)
	hair_entry.colormasks = colormasks
	var/list/addmasks = hairmask_list_fast(hair_entry.addmasks)
	if(!addmasks)
		addmasks = hairmask_list(hair_entry.addmasks)
	hair_entry.addmasks = addmasks
	if(hair_entry.addmasks)
		var/legacy_colour = sanitize_hexcolor(hair_entry.pix_color, 6, TRUE, hair_entry.hair_color)
		hair_entry.colormasks = hairmask_layer_merge(hair_entry.colormasks, legacy_colour, hair_entry.addmasks)
		hair_entry.addmasks = null
	hair_entry.colormasks = hairmask_palette_layers(hair_entry.colormasks, hair_entry)
	return hair_entry.colormasks

/proc/hair_entry_prepare(datum/customizer_entry/hair/hair_entry, norm_color = FALSE)
	if(!hair_entry)
		return null
	hair_entry.colormasks = hair_entry_masks(hair_entry)
	hair_entry.addmasks = null
	hair_entry.rmmasks = null
	if(norm_color)
		hair_entry.pix_color = hair_palette_colour(hair_entry.pix_color, hair_entry)
	return hair_entry

/proc/hair_colour_mix(colour, target, amount)
	colour = sanitize_hexcolor(colour, 6, TRUE)
	if(!colour)
		return null
	amount = clamp(amount, 0, 1)
	var/red = hex2num(copytext(colour, 2, 4))
	var/green = hex2num(copytext(colour, 4, 6))
	var/blue = hex2num(copytext(colour, 6, 8))
	red = round(red + ((target - red) * amount))
	green = round(green + ((target - green) * amount))
	blue = round(blue + ((target - blue) * amount))
	return "#[num2hex(clamp(red, 0, 255), 2)][num2hex(clamp(green, 0, 255), 2)][num2hex(clamp(blue, 0, 255), 2)]"

/proc/hair_palette(datum/customizer_entry/hair/hair_entry)
	var/list/entries = hair_palette_entries(hair_entry)
	var/list/palette = list()
	for(var/list/entry in entries)
		var/colour = sanitize_hexcolor(entry["color"], 6, TRUE)
		if(colour && !(colour in palette))
			palette += colour
	return palette.len ? palette : list("#FFFFFF")

/proc/hair_nearest_colour(colour, list/palette)
	colour = sanitize_hexcolor(colour, 6, TRUE)
	if(!islist(palette) || !palette.len)
		return colour || "#FFFFFF"
	if(!colour)
		return palette[1]
	var/red = hex2num(copytext(colour, 2, 4))
	var/green = hex2num(copytext(colour, 4, 6))
	var/blue = hex2num(copytext(colour, 6, 8))
	var/best_colour = palette[1]
	var/best_score = INFINITY
	for(var/palette_colour in palette)
		var/palette_red = hex2num(copytext(palette_colour, 2, 4))
		var/palette_green = hex2num(copytext(palette_colour, 4, 6))
		var/palette_blue = hex2num(copytext(palette_colour, 6, 8))
		var/delta_red = red - palette_red
		var/delta_green = green - palette_green
		var/delta_blue = blue - palette_blue
		var/score = (delta_red * delta_red) + (delta_green * delta_green) + (delta_blue * delta_blue)
		if(score < best_score)
			best_score = score
			best_colour = palette_colour
	return best_colour

/proc/hair_palette_key(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return null
	return "[sanitize_hexcolor(hair_entry.hair_color, 6, TRUE, "#FFFFFF")]|[hair_entry.natural_gradient]|[sanitize_hexcolor(hair_entry.natural_color, 6, TRUE, "#FFFFFF")]|[hair_entry.dye_gradient]|[sanitize_hexcolor(hair_entry.dye_color, 6, TRUE, "#FFFFFF")]"

/proc/hair_palette_entries(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return list(list("label" = "Hair", "color" = "#FFFFFF"))
	var/palette_key = hair_palette_key(hair_entry)
	var/static/list/palette_entries_cache = list()
	var/list/cached_entries = palette_entries_cache[palette_key]
	if(islist(cached_entries))
		return cached_entries
	var/list/palette = list()
	var/base = sanitize_hexcolor(hair_entry.hair_color, 6, TRUE, "#FFFFFF")
	palette += list(list("label" = "Base Hair", "color" = base))
	palette += list(list("label" = "Darker Base Hair", "color" = hair_colour_mix(base, 0, 0.25)))
	palette += list(list("label" = "Lighter Base Hair", "color" = hair_colour_mix(base, 255, 0.25)))
	if(hair_entry.natural_gradient != /datum/hair_gradient/none)
		var/natural = sanitize_hexcolor(hair_entry.natural_color, 6, TRUE)
		if(natural)
			palette += list(list("label" = "Natural Gradient", "color" = natural))
			palette += list(list("label" = "Darker Natural Gradient", "color" = hair_colour_mix(natural, 0, 0.25)))
			palette += list(list("label" = "Lighter Natural Gradient", "color" = hair_colour_mix(natural, 255, 0.25)))
	if(hair_entry.dye_gradient != /datum/hair_gradient/none)
		var/dye = sanitize_hexcolor(hair_entry.dye_color, 6, TRUE)
		if(dye)
			palette += list(list("label" = "Dye Gradient", "color" = dye))
			palette += list(list("label" = "Darker Dye Gradient", "color" = hair_colour_mix(dye, 0, 0.25)))
			palette += list(list("label" = "Lighter Dye Gradient", "color" = hair_colour_mix(dye, 255, 0.25)))
	palette_entries_cache[palette_key] = palette
	return palette

/proc/hair_palette_colour(colour, datum/customizer_entry/hair/hair_entry)
	var/list/palette = hair_palette(hair_entry)
	return hair_nearest_colour(colour, palette)

/proc/hairmask_palette_layers(layers, datum/customizer_entry/hair/hair_entry)
	layers = hairmask_layers_fast(layers)
	if(!layers)
		layers = hairmask_layers(layers)
	if(!layers || !hair_entry)
		return layers
	var/list/merged = null
	for(var/colour in layers)
		merged = hairmask_layer_merge(merged, hair_palette_colour(colour, hair_entry), layers[colour])
	return hairmask_layers_fast(merged)

/proc/hair_pack(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return
	hair_entry_masks(hair_entry)
	hair_entry.maskjson = hair_entry.colormasks ? json_encode(hair_entry.colormasks) : null
	hair_entry.addjson = null
	hair_entry.rmjson = null
	hair_entry.colormasks = null
	hair_entry.addmasks = null
	hair_entry.rmmasks = null

/proc/hair_unpack(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return
	if(!hair_entry.colormasks && hair_entry.maskjson)
		hair_entry.colormasks = hairmask_palette_layers(safe_json_decode(hair_entry.maskjson), hair_entry)
	if(!hair_entry.addmasks && hair_entry.addjson)
		hair_entry.addmasks = hairmask_list(safe_json_decode(hair_entry.addjson))
	if(!hair_entry.rmmasks && hair_entry.rmjson)
		hair_entry.rmmasks = hairmask_list(safe_json_decode(hair_entry.rmjson))
	hair_entry.maskjson = null
	hair_entry.addjson = null
	hair_entry.rmjson = null

/proc/hair_clear(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return
	hair_entry.colormasks = null
	hair_entry.addmasks = null
	hair_entry.rmmasks = null
	hair_entry.maskjson = null
	hair_entry.addjson = null
	hair_entry.rmjson = null
	hair_entry.custom_mask_version++


/proc/hairmask_bits(icon/target_icon, mask, fillcolor)
	if(!target_icon)
		return null
	mask = hairmask_clean(mask)
	if(!mask)
		return target_icon
	return hairmask_bits_fast(target_icon, mask, fillcolor)

/proc/hairmask_bits_fast(icon/target_icon, mask, fillcolor)
	if(!target_icon || !hairmask_valid(mask))
		return target_icon
	for(var/pixel_y in 1 to 32)
		var/run_start = 0
		var/pixel_x = 1
		var/row_hex_index = ((pixel_y - 1) << 3) + 1
		for(var/hex_offset in 0 to 7)
			var/hex_value = hairmask_hex_value(mask, row_hex_index + hex_offset)
			for(var/bit_index in 0 to 3)
				if(hex_value & (1 << bit_index))
					if(!run_start)
						run_start = pixel_x
				else if(run_start)
					target_icon.DrawBox(fillcolor, run_start, pixel_y, pixel_x - 1, pixel_y)
					run_start = 0
				pixel_x++
		if(run_start)
			target_icon.DrawBox(fillcolor, run_start, pixel_y, 32, pixel_y)
	return target_icon

/proc/hairmask_drawbits(icon/target_icon, mask, fillcolor)
	fillcolor = sanitize_hexcolor(fillcolor, 6, TRUE, "#FFFFFF")
	return hairmask_bits(target_icon, mask, fillcolor)

/proc/hairmask_drawbits_fast(icon/target_icon, mask, fillcolor)
	fillcolor = sanitize_hexcolor(fillcolor, 6, TRUE, "#FFFFFF")
	return hairmask_bits_fast(target_icon, mask, fillcolor)

/proc/hairmask_clearbits(icon/target_icon, mask)
	return hairmask_bits(target_icon, mask, null)

/proc/hair_preview_icon(mob/living/carbon/human/human, preview_dir)
	if(!human)
		return null
	return getFlatIcon(human, defdir = preview_dir, no_anim = TRUE)

/proc/hair_band_layers(list/overlays, preview_dir)
	if(!overlays?.len)
		return null
	var/icon/band_icon = icon('icons/effects/effects.dmi', "nothing")
	for(var/mutable_appearance/appearance as anything in overlays)
		var/icon/layer_icon = icon(appearance.icon, appearance.icon_state, dir = preview_dir)
		if(!layer_icon)
			continue
		if(appearance.pixel_x > 0)
			layer_icon.Shift(EAST, appearance.pixel_x)
		else if(appearance.pixel_x < 0)
			layer_icon.Shift(WEST, -appearance.pixel_x)
		if(appearance.pixel_y > 0)
			layer_icon.Shift(NORTH, appearance.pixel_y)
		else if(appearance.pixel_y < 0)
			layer_icon.Shift(SOUTH, -appearance.pixel_y)
		band_icon.Blend(layer_icon, ICON_OVERLAY)
	return band_icon

/proc/hair_bands(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry?.accessory_type)
		return null
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(hair_entry.accessory_type)
	if(!accessory?.icon_state)
		return null
	var/list/overlays = accessory.get_overlay(accessory.icon_state, hair_entry.hair_color)
	if(!overlays?.len)
		return null
	return list(
		"s_band" = hair_band_layers(overlays, SOUTH),
		"w_band" = hair_band_layers(overlays, WEST),
		"n_band" = hair_band_layers(overlays, NORTH),
		"e_band" = hair_band_layers(overlays, EAST),
	)

/proc/hair_band_cache(list/cache, preview_dir)
	if(!islist(cache))
		return null
	var/key = hair_dir_key(preview_dir)
	if(!key)
		return null
	var/icon/band_icon = cache["[key]_band"]
	if(!band_icon)
		return null
	return band_icon

/proc/hair_icon_colors(icon/source_icon, list/colors)
	if(!source_icon)
		return colors
	if(!islist(colors))
		colors = list()
	for(var/pixel_y in 1 to 32)
		for(var/pixel_x in 1 to 32)
			var/pixel = source_icon.GetPixel(pixel_x, pixel_y)
			if(!pixel)
				continue
			pixel = sanitize_hexcolor(pixel, 6, TRUE)
			if(!(pixel in colors))
				colors += pixel
	return colors


/proc/hair_gradient_palette(datum/sprite_accessory/accessory, gradient_type, gradient_color)
	if(gradient_type == /datum/hair_gradient/none || isnull(gradient_type))
		return null
	var/datum/hair_gradient/gradient = HAIR_GRADIENT(gradient_type)
	if(!gradient?.icon || !gradient.icon_state || !accessory?.icon || !accessory.icon_state)
		return null
	gradient_color = sanitize_hexcolor(gradient_color, 6, TRUE, "#FFFFFF")
	var/static/list/gradient_cache = list()
	var/static/list/blended_gradient_cache = list()
	var/cache_key = "[gradient_type]|[gradient_color]|[accessory.icon]|[accessory.icon_state]"
	var/list/cached_colors = gradient_cache[cache_key]
	if(islist(cached_colors))
		return cached_colors
	cached_colors = list()
	for(var/preview_dir in hair_preview_dirs())
		var/blended_key = "[gradient_type]|[accessory.icon]|[accessory.icon_state]|[preview_dir]"
		var/icon/blended_gradient = blended_gradient_cache[blended_key]
		if(!blended_gradient)
			var/icon/gradient_icon_base = icon(gradient.icon, gradient.icon_state, dir = preview_dir)
			var/icon/hair_icon = icon(accessory.icon, accessory.icon_state, dir = preview_dir)
			if(!gradient_icon_base || !hair_icon)
				continue
			gradient_icon_base.Blend(hair_icon, ICON_ADD)
			blended_gradient = gradient_icon_base
			blended_gradient_cache[blended_key] = blended_gradient
		var/icon/gradient_icon = icon(blended_gradient)
		gradient_icon.Blend(gradient_color, ICON_MULTIPLY)
		cached_colors = hair_icon_colors(gradient_icon, cached_colors)
	gradient_cache[cache_key] = cached_colors
	return cached_colors

/proc/hair_gradient_colors(list/colors, datum/sprite_accessory/accessory, gradient_type, gradient_color)
	var/list/gradient_colors = hair_gradient_palette(accessory, gradient_type, gradient_color)
	if(!islist(gradient_colors))
		return colors
	for(var/color in gradient_colors)
		if(!(color in colors))
			colors += color
	return colors

/proc/hair_colors(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return list("#ffffff")
	var/fillcolor = sanitize_hexcolor(hair_entry.hair_color, 6, TRUE, "#FFFFFF")
	if(!hair_entry.accessory_type)
		return list(fillcolor)
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(hair_entry.accessory_type)
	if(!accessory || !accessory.icon_state)
		return list(fillcolor)
	var/natural_gradient = hair_entry.natural_gradient
	var/natural_color = sanitize_hexcolor(hair_entry.natural_color, 6, TRUE, "#FFFFFF")
	var/dye_gradient = hair_entry.dye_gradient
	var/dye_color = sanitize_hexcolor(hair_entry.dye_color, 6, TRUE, "#FFFFFF")
	var/static/list/hair_colors_cache = list()
	var/cache_key = "[hair_entry.accessory_type]|[fillcolor]|[natural_gradient]|[natural_color]|[dye_gradient]|[dye_color]"
	var/list/cached_colors = hair_colors_cache[cache_key]
	if(islist(cached_colors))
		return cached_colors
	var/list/colors = list(fillcolor)
	for(var/preview_dir in hair_preview_dirs())
		var/icon/palette_icon = icon(accessory.icon, accessory.icon_state, dir = preview_dir)
		if(!palette_icon)
			continue
		palette_icon.Blend(fillcolor, ICON_MULTIPLY)
		colors = hair_icon_colors(palette_icon, colors)
	if(natural_gradient != /datum/hair_gradient/none)
		colors = hair_gradient_colors(colors, accessory, natural_gradient, natural_color)
	if(dye_gradient != /datum/hair_gradient/none)
		colors = hair_gradient_colors(colors, accessory, dye_gradient, dye_color)
	if(!colors.len)
		colors = list(fillcolor)
	hair_colors_cache[cache_key] = colors
	return colors

/proc/hair_cache_key(datum/customizer_entry/hair/hair_entry, customizer_type)
	if(!hair_entry)
		return null
	return "[customizer_type]|[hair_entry.accessory_type]|[sanitize_hexcolor(hair_entry.hair_color, 6, TRUE, "#FFFFFF")]|[hair_entry.natural_gradient]|[sanitize_hexcolor(hair_entry.natural_color, 6, TRUE, "#FFFFFF")]|[hair_entry.dye_gradient]|[sanitize_hexcolor(hair_entry.dye_color, 6, TRUE, "#FFFFFF")]"

/proc/hair_asset(icon/preview_icon)
	if(!isicon(preview_icon))
		return null
	var/list/name_ref = generate_and_hash_rsc_file(preview_icon, FALSE)
	var/asset_name = "[name_ref[3]].png"
	if(!SSassets.cache[asset_name])
		SSassets.transport.register_asset(asset_name, name_ref[1], name_ref[2])
	return asset_name

/proc/hair_asset_url(asset_name, mob/user = null)
	if(!asset_name || !SSassets.cache[asset_name])
		return null
	if(user?.client)
		SSassets.transport.send_assets(user, asset_name)
	return SSassets.transport.get_asset_url(asset_name)

/proc/hair_edit_count(datum/customizer_entry/hair/hair_entry)
	if(!hair_entry)
		return 0
	var/list/colormasks = hair_entry_masks(hair_entry)
	var/count = 0
	for(var/preview_dir in hair_preview_dirs())
		if(hairmask_dir_any(colormasks, preview_dir))
			count++
	return count

/proc/hair_edit_band(icon/diricon)
	if(!diricon)
		return list("minX" = 7, "maxX" = 26, "minY" = 11, "maxY" = 32)
	var/left_x = 0
	var/right_x = 0
	var/top_y = 0
	for(var/pixel_y in 32 to 1 step -1)
		for(var/pixel_x in 1 to 32)
			if(!diricon.GetPixel(pixel_x, pixel_y))
				continue
			if(!left_x || pixel_x < left_x)
				left_x = pixel_x
			if(pixel_x > right_x)
				right_x = pixel_x
			if(!top_y)
				top_y = pixel_y
	if(!top_y)
		return list("minX" = 7, "maxX" = 26, "minY" = 11, "maxY" = 32)
	if(!left_x)
		left_x = 7
	if(!right_x)
		right_x = 26
	var/window_width = 20
	var/top_padding = 2
	var/window_height = window_width + top_padding
	var/min_x = round((left_x + right_x - window_width) / 2)
	if(min_x < 1)
		min_x = 1
	if(min_x + window_width - 1 > 32)
		min_x = 32 - window_width + 1
	var/max_x = min_x + window_width - 1
	var/max_y = top_y + top_padding
	if(max_y < window_height)
		max_y = window_height
	if(max_y > 32)
		max_y = 32
	var/min_y = max_y - window_height + 1
	return list(
		"minX" = min_x,
		"maxX" = max_x,
		"minY" = min_y,
		"maxY" = max_y,
	)