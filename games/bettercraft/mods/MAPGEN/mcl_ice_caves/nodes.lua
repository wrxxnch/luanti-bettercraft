local S = core.get_translator(core.get_current_modname())
local sounds = mcl_sounds.node_sound_glass_defaults()
local stone_sounds = mcl_sounds.node_sound_stone_defaults()

core.register_node("mcl_ice_caves:ice_crystal", {
	description = S("Ice crystal"),
	_doc_items_longdesc = S("A luminous crystal found on the floor of ice caves."),
	drawtype = "plantlike",
	tiles = {"mcl_ice_caves_ice_crystal.png"},
	inventory_image = "mcl_ice_caves_ice_crystal.png",
	wield_image = "mcl_ice_caves_ice_crystal.png",
	paramtype = "light",
	light_source = 9,
	walkable = false,
	buildable_to = true,
	groups = {cracky = 3, attached_node = 1, oddly_breakable_by_hand = 1},
	sounds = sounds,
	_mcl_hardness = 0.3,
	_mcl_blast_resistance = 0.3,
})

local icicle_shapes = {
	base = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3},
	middle = {-0.22, -0.5, -0.22, 0.22, 0.5, 0.22},
	tip = {-0.08, -0.5, -0.08, 0.08, 0.5, 0.08},
}

for stage, box in pairs(icicle_shapes) do
	core.register_node("mcl_ice_caves:icicle_" .. stage, {
		description = S("Icicle (@1)", stage),
		_doc_items_hidden = stage ~= "base",
		drawtype = "nodebox",
		node_box = {type = "fixed", fixed = box},
		selection_box = {type = "fixed", fixed = box},
		collision_box = {type = "fixed", fixed = box},
		tiles = {"mcl_ice_caves_icicle.png"},
		paramtype = "light",
		groups = {cracky = 2, attached_node = 1, icicle = 1},
		sounds = stone_sounds,
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 0.8,
	})
end

core.register_alias("mcl_ice_caves:ice_crystal_block", "mcl_ice_caves:ice_crystal")
