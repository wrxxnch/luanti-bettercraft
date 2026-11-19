-- Load and place .mts structures from a folder named for each biome.
-- Add schematics to schematics/biomes/<folder_name>/*.mts.
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local schematic_root = modpath .. "/schematics/biomes"

-- Keys are the folder names; values are the biome IDs reported by
-- core.get_biome_name across the Minecraft/Mineclonia mapgen registrations.
local BIOME_FOLDERS = {
	taiga = {
		"Taiga", "SnowyTaiga", "ColdTaiga", "OldGrowthSpruceTaiga",
	},
	acacia_forest = {
		"Savanna", "SavannaM", "Savannah", "SavannahM", "SavannaPlateau",
		"WindsweptSavanna",
	},
	dappled_forest = {
		"dappled_forest", "DappledForest",
	},
	pale_garden = {
		"PaleGarden", "pale_garden",
	},
	pine_forest = {
		"OldGrowthPineTaiga", "MegaTaiga",
	},
	jungle = {
		"Jungle", "JungleM", "SparseJungle", "BambooJungle",
		"JungleEdge", "JungleEdgeM",
	},
}

local biome_folder_by_id = {}
for folder, biome_ids in pairs(BIOME_FOLDERS) do
	for _, biome_id in ipairs(biome_ids) do
		biome_folder_by_id[biome_id] = folder
	end
end

local function discover_schematics()
	local schematics = {}
	if not core.get_dir_list then
		core.log("warning", "[" .. modname .. "] core.get_dir_list unavailable; biome schematics disabled")
		return schematics
	end

	for folder in pairs(BIOME_FOLDERS) do
		local directory = schematic_root .. "/" .. folder
		local filenames = core.get_dir_list(directory, false) or {}
		table.sort(filenames)
		for _, filename in ipairs(filenames) do
			local lower_filename = filename:lower()
			local camp_variant = lower_filename:match("^abandoned_camp(%d+)%.mts$")
			if lower_filename:match("%.mts$") then
				schematics[#schematics + 1] = {
					biome_folder = folder,
					path = directory .. "/" .. filename,
					abandoned_camp_variant = tonumber(camp_variant),
				}
			end
		end
	end

	return schematics
end

local schematics = discover_schematics()
if #schematics == 0 then
	core.log("action", "[" .. modname .. "] no biome .mts schematics found yet")
else
	core.log("action", "[" .. modname .. "] loaded " .. #schematics .. " biome .mts schematic(s)")
end

if #schematics == 0 or not core.register_on_generated
		or not core.get_biome_data or not core.get_biome_name
		or not core.place_schematic then
	return
end

local function target_folder_at(pos)
	local data = core.get_biome_data(pos)
	if not data then
		return nil
	end
	local biome_name = core.get_biome_name(data.biome)
	return biome_folder_by_id[biome_name]
end

local function find_surface(x, z, min_y, max_y)
	for y = max_y, min_y, -1 do
		local ground = core.get_node_or_nil({x = x, y = y, z = z})
		local above = core.get_node_or_nil({x = x, y = y + 1, z = z})
		if ground and above and ground.name ~= "ignore" and above.name == "air"
				and core.registered_nodes[ground.name]
				and core.registered_nodes[ground.name].walkable then
			return y
		end
	end
	return nil
end

core.register_on_generated(function(minp, maxp, blockseed)
	-- Most generated map chunks are not surface chunks. Avoid scanning them.
	if maxp.y < 0 or minp.y > 320 then
		return
	end

	local rng = PseudoRandom((blockseed or 0) + 78341)
	-- Structures are intentionally uncommon; at most one is attempted per chunk.
	if rng:next(1, 40) ~= 1 then
		return
	end

	local candidates = {}
	for _ = 1, 8 do
		local x = rng:next(minp.x + 1, maxp.x - 1)
		local z = rng:next(minp.z + 1, maxp.z - 1)
		local surface_y = find_surface(x, z, minp.y, maxp.y)
		if surface_y then
			local folder = target_folder_at({x = x, y = surface_y + 1, z = z})
			if folder then
				candidates[#candidates + 1] = {
					x = x,
					y = surface_y + 1,
					z = z,
					folder = folder,
				}
			end
		end
	end

	for _, candidate in ipairs(candidates) do
		local eligible = {}
		for _, schematic in ipairs(schematics) do
			if schematic.biome_folder == candidate.folder then
				eligible[#eligible + 1] = schematic
			end
		end
		if #eligible > 0 then
			local chosen = eligible[rng:next(1, #eligible)]
			-- Keep the full MTS filename so the engine reads the stored schematic.
			core.place_schematic(
				{x = candidate.x, y = candidate.y, z = candidate.z},
				chosen.path,
				"random",
				nil,
				true,
				"place_center_x,place_center_z"
			)
			return
		end
	end
end)
