-- Pale Garden Biome - Bioma do Jardim Pálido

-- Registra o bioma Pale Garden
minetest.register_biome({
    name = "PaleGarden",
    node_top = "pale_garden:pale_moss_block",
    depth_top = 1,
    node_filler = "mcl_core:dirt",
    depth_filler = 3,
    node_riverbed = "mcl_core:sand",
    depth_riverbed = 2,
    y_min = 1,
    y_max = 31000,
    humidity_point = 80,
    heat_point = 25,
})

-- Decoração: Árvores Pale Oak
minetest.register_decoration({
    deco_type = "schematic",
    place_on = {"pale_garden:pale_moss_block"},
    sidelen = 16,
    fill_ratio = 0.02,
    biomes = {"PaleGarden"},
    y_min = 1,
    y_max = 31000,
    schematic = {
        size = {x=5, y=8, z=5},
        data = {
            -- Estrutura simplificada de árvore
            -- Será gerada pela função generate_pale_oak_tree
        }
    },
    flags = "place_center_x, place_center_z",
    rotation = "random",
})

-- Decoração: Tapete de musgo pálido
minetest.register_decoration({
    deco_type = "simple",
    place_on = {"pale_garden:pale_moss_block"},
    sidelen = 16,
    fill_ratio = 0.3,
    biomes = {"PaleGarden"},
    y_min = 1,
    y_max = 31000,
    decoration = "pale_garden:pale_moss_carpet",
})

-- Gera árvores Pale Oak no bioma
minetest.register_on_generated(function(minp, maxp, seed)
    local c_pale_moss = minetest.get_content_id("pale_garden:pale_moss_block")
    local c_air = minetest.get_content_id("air")
    
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
    
    -- Procura por blocos de musgo pálido para spawnar árvores
    for x = minp.x, maxp.x, 8 do
        for z = minp.z, maxp.z, 8 do
            for y = minp.y, maxp.y do
                local pos = {x=x, y=y, z=z}
                local vi = area:indexp(pos)
                
                if data[vi] == c_pale_moss then
                    local above = area:indexp({x=x, y=y+1, z=z})
                    if data[above] == c_air and math.random(1, 20) == 1 then
                        -- Spawna árvore após a geração do chunk
                        minetest.after(0.5, function()
                            pale_garden.generate_pale_oak_tree(pos)
                        end)
                    end
                end
            end
        end
    end
end)

minetest.log("action", "[Pale Garden] Bioma Pale Garden registrado!")
