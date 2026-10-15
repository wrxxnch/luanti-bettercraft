local mcl_levelgen = mcl_levelgen
local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local is_air = mcl_levelgen.is_air
local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local cid_air = core.CONTENT_AIR
local cid_crystal = core.get_content_id("mcl_ice_caves:ice_crystal")
local cid_base = core.get_content_id("mcl_ice_caves:icicle_base")
local cid_middle = core.get_content_id("mcl_ice_caves:icicle_middle")
local cid_tip = core.get_content_id("mcl_ice_caves:icicle_tip")
local rng = mcl_levelgen.xoroshiro(mcl_levelgen.ull(0, 0), mcl_levelgen.ull(0, 0))

local function solid(x, y, z)
	local cid = get_block(x, y, z)
	return cid ~= cid_air and not is_air(x, y, z)
end

local function place_ice_cave_decorations(_, x, y, z, _, feature_rng)
	rng:reseed(feature_rng:next_long())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end
	if not is_air(x, y, z) then
		return false
	end

	-- Floor crystals: support below, open space above.
	if solid(x, y - 1, z) and is_air(x, y + 1, z)
		and rng:next_within(5) == 0 then
		set_block(x, y, z, cid_crystal, 0)
		return true
	end

	-- Ceiling icicles: grow down from the first solid ceiling block.
	if solid(x, y + 1, z) and is_air(x, y - 1, z)
		and rng:next_within(4) == 0 then
		local length = 1 + rng:next_within(4)
		for i = 0, length - 1 do
			if not is_air(x, y - i, z) then
				return i > 0
			end
			local cid = i == length - 1 and cid_tip
				or (i == 0 and cid_base or cid_middle)
			set_block(x, y - i, z, cid, 0)
		end
		return true
	end
	return false
end

mcl_levelgen.register_feature("mcl_ice_caves:ice_cave_decorations", {
	place = place_ice_cave_decorations,
})

mcl_levelgen.register_configured_feature("mcl_ice_caves:ice_cave_decorations", {
	feature = "mcl_ice_caves:ice_cave_decorations",
})

mcl_levelgen.register_placed_feature("mcl_ice_caves:ice_cave_decorations", {
	configured_feature = "mcl_ice_caves:ice_cave_decorations",
	placement_modifiers = {
		mcl_levelgen.build_count(18),
		mcl_levelgen.build_in_square(),
		mcl_levelgen.build_height_range(mcl_levelgen.uniform_height(-64, 48)),
		mcl_levelgen.build_in_biome(),
	},
})
