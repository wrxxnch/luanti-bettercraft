-- mapgen.lua - Estruturas de Superfície e Cavernas
local modname = minetest.get_current_modname()
local target_biomes = {"Plains", "MesaPlateauFM_sandlevel", "dead_forest", "megaTaiga"}

--------------------------------------------------------------------------------
-- 1. REGISTRO DO BIOMA (Necessário para o /locate biome sulphur_cave)
--------------------------------------------------------------------------------
core.register_biome({
    name = "sulphur_cave",
    node_stone = "mcl_core:stone",
    node_filler = modname .. ":sulfur", -- Preenchimento predominante
    y_max = -15,
    y_min = -1000,
    -- Valores de calor e umidade para que o motor de busca o localize
    -- (Ajustado para ambientes quentes/secos onde enxofre costuma estar)
    heat_point = 90,
    humidity_point = 10,
})

--------------------------------------------------------------------------------
-- 2. REGISTRO DAS ORES (Blobs de Enxofre e Cinábrio)
--------------------------------------------------------------------------------
core.register_ore({
    ore_type       = "blob",
    ore            = modname .. ":sulfur",
    wherein        = {"mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite"},
    clust_scarcity = 900,
    clust_num_ores = 250,
    clust_size     = 18,
    y_max          = -15,
    y_min          = -1000,
    biomes         = {"sulphur_cave", unpack(target_biomes)}, -- Adicionado o novo bioma aqui
})

core.register_ore({
    ore_type       = "blob",
    ore            = modname .. ":cinnabar",
    wherein        = {modname .. ":sulfur", "mcl_core:stone"},
    clust_scarcity = 1400,
    clust_num_ores = 80,
    clust_size     = 10,
    y_max          = -30,
    y_min          = -1000,
    biomes         = {"sulphur_cave", unpack(target_biomes)},
})

--------------------------------------------------------------------------------
-- 3. DECORAÇÕES (Spikes e Espeleotemas)
--------------------------------------------------------------------------------

-- Estalagmites (Spikes que nascem no CHÃO de Sulfur)
core.register_decoration({
    name = modname .. ":sulfur_spikes_floor",
    deco_type = "simple",
    place_on = {modname .. ":sulfur", modname .. ":cinnabar"},
    sidelen = 16,
    noise_params = {
        offset = 0.02,
        scale = 0.1,
        spread = {x = 50, y = 50, z = 50},
        seed = 500,
        octaves = 3,
        persist = 0.6
    },
    y_max = -15,
    y_min = -1000,
    decoration = {
        modname .. ":sulfur_spike_up_tip", 
        modname .. ":sulfur_spike_up_tip", -- Repetir para aumentar chance
    },
    biomes = {"sulphur_cave"}, -- Restrito ao bioma para otimização
})

-- Estalactites (Spikes que nascem no TETO de Sulfur)
core.register_decoration({
    name = modname .. ":sulfur_spikes_ceiling",
    deco_type = "simple",
    place_on = {modname .. ":sulfur", modname .. ":cinnabar"},
    sidelen = 16,
    noise_params = {
        offset = 0.02,
        scale = 0.1,
        spread = {x = 50, y = 50, z = 50},
        seed = 600,
        octaves = 3,
        persist = 0.6
    },
    y_max = -15,
    y_min = -1000,
    decoration = modname .. ":sulfur_spike_down_tip",
    flags = "all_ceilings", -- Força o nascimento no teto
    biomes = {"sulphur_cave"},
})

--------------------------------------------------------------------------------
-- 4. ESTRUTURAS DE SUPERFÍCIE (GEYSERS)
--------------------------------------------------------------------------------
for i = 1, 4 do
    core.register_decoration({
        name = modname .. ":geyser_structure_" .. i,
        deco_type = "schematic",
        place_on = {
            "mcl_core:dirt_with_grass", 
            "mcl_core:sand", 
            "mcl_core:coarse_dirt", 
            "mcl_core:red_sand"
        },
        sidelen = 16,
        noise_params = {
            offset = 0.0002,
            scale = 0.001,
            spread = {x = 250, y = 250, z = 250},
            seed = 100 + i,
            octaves = 3,
            persist = 0.6
        },
        biomes = target_biomes,
        y_max = 31000,
        y_min = 60,
        schematic = core.get_modpath(modname) .. "/schematics/geyser" .. i .. ".mts",
        flags = "place_center_x, place_center_z",
        rotation = "random",
    })
end