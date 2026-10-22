local S = core.get_translator(core.get_current_modname())

local MAX_LENGTH = 5
local GROWTH_INTERVAL = 69
local GROWTH_CHANCE = 88
local SUPPORT = "mcl_core:packed_ice"

core.register_node("mcl_ice_caves:ice_crystal", {
	description = S("Ice crystal"),
	_doc_items_longdesc = S("A luminous crystal found on the floor of ice caves."),
	drawtype = "plantlike",
	tiles = {"mcl_ice_caves_ice_crystal.png"},
	use_texture_alpha = "clip",
	inventory_image = "mcl_ice_caves_ice_crystal.png",
	wield_image = "mcl_ice_caves_ice_crystal.png",
	paramtype = "light",
	light_source = 9,
	walkable = false,
	buildable_to = true,
	groups = {cracky = 3, attached_node = 1, oddly_breakable_by_hand = 1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_hardness = 0.3,
	_mcl_blast_resistance = 0.3,
})

local stages = {
base = {name = "mcl_ice_caves:icicle_base", box = {-0.30, -0.5, -0.30, 0.30, 0.5, 0.30}},
middle = {name = "mcl_ice_caves:icicle_middle", box = {-0.22, -0.5, -0.22, 0.22, 0.5, 0.22}},
tip = {name = "mcl_ice_caves:icicle_tip", box = {-0.08, -0.5, -0.08, 0.08, 0.5, 0.08}},
}
local icicle_names = {}
for _, stage in pairs(stages) do
icicle_names[stage.name] = true
end

local function is_icicle(name)
return icicle_names[name] == true
end

local function is_support(name)
if name == SUPPORT then return true end
local def = core.registered_nodes[name]
return def and def.walkable == true or false
end

local function stage_for(index, length)
if length == 1 or index == length - 1 then
return stages.tip.name
elseif index == 0 then
return stages.base.name
end
return stages.middle.name
end

local function restage(start_pos, length)
for i = 0, length - 1 do
local pos = vector.offset(start_pos, 0, -i, 0)
local name = stage_for(i, length)
if core.get_node(pos).name ~= name then
core.swap_node(pos, {name = name})
end
end
end

local function measure_chain(tip_pos)
local pos = vector.new(tip_pos)
local length = 1
while is_icicle(core.get_node(vector.offset(pos, 0, 1, 0)).name) do
pos.y = pos.y + 1
length = length + 1
if length > MAX_LENGTH then return nil end
end
if not is_support(core.get_node(vector.offset(pos, 0, 1, 0)).name) then
return nil
end
return pos, length
end

local function has_nearby_light(pos)
	return core.get_node_light(pos, 0.5) >= 5
end

local function restage_from(pos)
	local start, length = measure_chain(pos)
	if start and length <= MAX_LENGTH then
		restage(start, length)
	end
end

local function place_icicle(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then return itemstack end
	local under = core.get_node(pointed_thing.under)
	local target = pointed_thing.above

	-- When the player clicks the tip's bottom face, add the new small
	-- segment below it and immediately rebuild the visual stages.
	if is_icicle(under.name)
	and target.x == pointed_thing.under.x
	and target.z == pointed_thing.under.z
	and target.y == pointed_thing.under.y - 1
	and core.get_node(target).name == "air" then
		core.set_node(target, {name = stages.tip.name})
		restage_from(target)
		if placer and not core.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end

	return core.item_place(itemstack, placer, pointed_thing)
end

local function grow_icicle(pos)
if has_nearby_light(pos) then return end
local start, length = measure_chain(pos)
if not start or length >= MAX_LENGTH then return end
local front = vector.offset(pos, 0, -1, 0)
if core.get_node(front).name ~= "air" or has_nearby_light(front) then return end
core.set_node(front, {name = stages.tip.name})
restage(start, length + 1)
end

for stage_name, stage in pairs(stages) do
core.register_node(stage.name, {
description = S("Icicle (@1)", stage_name),
_doc_items_hidden = stage_name ~= "base",
drawtype = "plantlike",
node_box = {type = "fixed", fixed = stage.box},
selection_box = {type = "fixed", fixed = stage.box},
	collision_box = {type = "fixed", fixed = stage.box},
	tiles = {"mcl_ice_caves_icicle_" .. stage_name .. ".png"},
	use_texture_alpha = "clip",
	paramtype = "light",
sunlight_propagates = true,
	groups = {pickaxey = 1, icicle = 1},
		drop = "mcl_ice_caves:icicle_tip",
		on_place = place_icicle,
		after_place_node = function(pos)
		-- Placing another spike at the tip immediately extends and re-stages
		-- the chain instead of waiting for the growth ABM.
		restage_from(pos)
	end,
	sounds = mcl_sounds.node_sound_glass_defaults(),
_mcl_hardness = 0.5,
_mcl_blast_resistance = 0.5,
})
end

core.register_abm({
label = "Ice icicle growth",
nodenames = {stages.tip.name},
interval = GROWTH_INTERVAL,
chance = GROWTH_CHANCE,
action = grow_icicle,
})

core.register_abm({
label = "Unsupported ice icicle cleanup",
nodenames = {"group:icicle"},
interval = 10,
chance = 1,
action = function(pos, node)
local start, length = measure_chain(pos)
if start and length > 0 then return end
core.remove_node(pos)
core.add_item(pos, node.name)
end,
})
