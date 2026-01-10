-- Custom Food Mod for Mineclonia
-- Adds Fried Egg and Pumpkin Slices

local S = minetest.get_translator("custom_food")

-------------------------------------------------
-- Pumpkin Slice (Raw)
-------------------------------------------------
minetest.register_craftitem("custom_food:pumpkin_slice", {
	description = "Pedaço de Abóbora",
	inventory_image = "custom_food_pumpkin_slice.png",

	on_place = core.item_eat(2),
	on_secondary_use = core.item_eat(2),

	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 0.4,

	-- Resultado ao cozinhar (fornalha / defumador / fogueira)
	_mcl_cooking_output = "custom_food:pumpkin_slice_cooked",
})

-------------------------------------------------
-- Cooked Pumpkin Slice
-------------------------------------------------
minetest.register_craftitem("custom_food:pumpkin_slice_cooked", {
	description = "Pedaço de Abóbora Cozida",
	inventory_image = "custom_food_cooked_pumpkin_slice.png",

	on_place = core.item_eat(6),
	on_secondary_use = core.item_eat(6),

	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 0.8,
})

-------------------------------------------------
-- Fried Egg
-------------------------------------------------
minetest.register_craftitem("custom_food:fried_egg", {
	description = "Ovo Frito",
	inventory_image = "custom_food_fried_egg.png",

	on_place = core.item_eat(6),
	on_secondary_use = core.item_eat(6),

	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 0.8,
})

-------------------------------------------------
-- Pumpkin Slice -> Pumpkin Seeds
-------------------------------------------------
minetest.register_craft({
	type = "shapeless",
	output = "mcl_farming:pumpkin_seeds",
	recipe = {"custom_food:pumpkin_slice"},
})

-------------------------------------------------
-- Recipes that depend on other mods
-------------------------------------------------
minetest.register_on_mods_loaded(function()
	-- Egg -> Fried Egg
	local egg_item = "mcl_throwing:egg"
	if not minetest.registered_items[egg_item] then
		egg_item = "mcl_mobitems:egg"
	end

	if minetest.registered_items[egg_item] then
		minetest.register_craft({
			type = "cooking",
			output = "custom_food:fried_egg",
			recipe = egg_item,
		})
	end

	-- Pumpkin Block -> 9 Pumpkin Slices
	local pumpkin_block = "mcl_farming:pumpkin"
	if not minetest.registered_nodes[pumpkin_block] then
		pumpkin_block = "mcl_core:pumpkin"
	end

	if minetest.registered_nodes[pumpkin_block] then
		minetest.register_craft({
			output = "custom_food:pumpkin_slice 9",
			recipe = {{pumpkin_block}},
		})
	end
end)
