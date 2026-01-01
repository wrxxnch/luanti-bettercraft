-- Pale Oak - Árvores e blocos do Pale Garden

-- Registra a madeira Pale Oak (tronco com casca)
minetest.register_node("pale_garden:pale_oak_log", {
    description = "Tronco de Carvalho Pálido",
    tiles = {
        "default_pale_oak_wood_top.png",
        "default_pale_oak_wood_top.png",
        "default_pale_oak_wood.png"
    },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {handy=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    on_place = mcl_util.rotate_axis,
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
})

-- Registra a madeira sem casca (stripped)
minetest.register_node("pale_garden:pale_oak_wood", {
    description = "Madeira de Carvalho Pálido (Descascada)",
    tiles = {
        "default_stripped_pale_oak_wood_top.png",
        "default_stripped_pale_oak_wood_top.png",
        "default_stripped_pale_oak_wood.png"
    },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {handy=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    on_place = mcl_util.rotate_axis,
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
})

-- Registra as tábuas
minetest.register_node("pale_garden:pale_oak_planks", {
    description = "Tábuas de Carvalho Pálido",
    tiles = {"default_pale_oak_planks.png"},
    is_ground_content = false,
    groups = {handy=1, axey=1, flammable=3, wood=1, building_block=1, material_wood=1},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    _mcl_blast_resistance = 3,
    _mcl_hardness = 2,
})

-- Registra as folhas
minetest.register_node("pale_garden:pale_oak_leaves", {
    description = "Folhas de Carvalho Pálido",
    drawtype = "allfaces_optional",
    waving = 2,
    tiles = {"default_pale_oak_leaves_simple.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {handy=1, hoey=1, shearsy=1, swordy=1, dig_by_piston=1, flammable=2, leaves=1, deco_block=1},
    drop = {
        max_items = 1,
        items = {
            {items = {"pale_garden:pale_oak_sapling"}, rarity = 20},
            {items = {"pale_garden:pale_oak_leaves"}}
        }
    },
    sounds = mcl_sounds.node_sound_leaves_defaults(),
    _mcl_blast_resistance = 0.2,
    _mcl_hardness = 0.2,
    _mcl_silk_touch_drop = true,
})

-- Registra a muda
minetest.register_node("pale_garden:pale_oak_sapling", {
    description = "Muda de Carvalho Pálido",
    drawtype = "plantlike",
    waving = 1,
    visual_scale = 1.0,
    tiles = {"default_pale_oak_sapling.png"},
    inventory_image = "default_pale_oak_sapling.png",
    wield_image = "default_pale_oak_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {-4/16, -0.5, -4/16, 4/16, 7/16, 4/16}
    },
    groups = {plant=1, sapling=1, non_mycelium_plant=1, attached_node=1, dig_by_water=1, dig_by_piston=1, destroy_by_lava_flow=1, deco_block=1},
    sounds = mcl_sounds.node_sound_leaves_defaults(),
    _mcl_blast_resistance = 0,
    _mcl_hardness = 0,
})

-- Registra o musgo pálido
minetest.register_node("pale_garden:pale_moss_block", {
    description = "Bloco de Musgo Pálido",
    tiles = {"default_pale_moss_block.png"},
    is_ground_content = true,
    groups = {handy=1, shovely=1, dirt=1, soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=1, building_block=1},
    sounds = mcl_sounds.node_sound_dirt_defaults(),
    _mcl_blast_resistance = 0.1,
    _mcl_hardness = 0.1,
})

-- Registra o tapete de musgo pálido
minetest.register_node("pale_garden:pale_moss_carpet", {
    description = "Tapete de Musgo Pálido",
    drawtype = "nodebox",
    tiles = {"default_pale_moss_carpet.png"},
    paramtype = "light",
    sunlight_propagates = true,
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}
    },
    groups = {handy=1, carpet=1, attached_node=1, dig_by_piston=1, flammable=-1, fire_encouragement=0, fire_flammability=0},
    sounds = mcl_sounds.node_sound_wool_defaults(),
    _mcl_blast_resistance = 0.1,
    _mcl_hardness = 0.1,
})

-- Registra o musgo pendurado
minetest.register_node("pale_garden:pale_hanging_moss", {
    description = "Musgo Pendurado Pálido",
    drawtype = "plantlike",
    tiles = {"default_pale_hanging_moss.png"},
    inventory_image = "default_pale_hanging_moss.png",
    wield_image = "default_pale_hanging_moss.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    climbable = true,
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}
    },
    groups = {handy=1, attached_node=1, dig_by_water=1, destroy_by_lava_flow=1, deco_block=1},
    sounds = mcl_sounds.node_sound_leaves_defaults(),
})

-- Registra a ponta do musgo pendurado
minetest.register_node("pale_garden:pale_hanging_moss_tip", {
    description = "Ponta de Musgo Pendurado Pálido",
    drawtype = "plantlike",
    tiles = {"default_pale_hanging_moss_tip.png"},
    inventory_image = "default_pale_hanging_moss_tip.png",
    wield_image = "default_pale_hanging_moss_tip.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}
    },
    groups = {handy=1, attached_node=1, dig_by_water=1, destroy_by_lava_flow=1, deco_block=1, not_in_creative_inventory=1},
    sounds = mcl_sounds.node_sound_leaves_defaults(),
})

local S = minetest.get_translator("pale_garden")

if mcl_doors and mcl_doors.register_door then
    mcl_doors:register_door("pale_garden:pale_oak_door", {
        description = S("Porta de Carvalho Pálido"),
        _doc_items_longdesc = S("Porta feita de madeira de Carvalho Pálido."),
        _doc_items_usagehelp = S("Clique com o botão direito para abrir ou fechar."),
        inventory_image = "default_pale_oak_door_item.png",
        groups = {handy=1, axey=1, flammable=3, door_wood=1, material_wood=1},
        _mcl_hardness = 2,
        tiles_bottom = {"default_pale_oak_door_bottom.png", "default_stripped_pale_oak_wood.png"},
        tiles_top = {"default_pale_oak_door_top.png", "default_stripped_pale_oak_wood.png"},
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sound_open = "doors_wood_door_open",
        sound_close = "doors_wood_door_close",

        -- ✅ Craft embutido no padrão do MineClonia
        recipe = {
            {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
            {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
            {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
        },
    })
end
if mcl_doors and mcl_doors.register_trapdoor then
    mcl_doors:register_trapdoor("pale_garden:pale_oak_trapdoor", {
        description = S("Alçapão de Carvalho Pálido"),
        _doc_items_longdesc = S("Alçapão feito de madeira de Carvalho Pálido."),
        _doc_items_usagehelp = S("Clique com o botão direito para abrir ou fechar."),
        tile_front = "default_pale_oak_trapdoor.png",
        tile_side = "default_stripped_pale_oak_wood.png",
        inventory_image = "default_pale_oak_trapdoor.png",
        groups = {handy=1, axey=1, flammable=3, door_wood=1, material_wood=1},
        _mcl_hardness = 2,
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sound_open = "doors_wood_door_open",
        sound_close = "doors_wood_door_close",

        -- ✅ Craft embutido no padrão do MineClonia
        recipe = {
            {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
            {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
        },
    })
end


minetest.register_craft({
    output = "pale_garden:pale_oak_door",
    recipe = {
        {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
        {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
        {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
    }
})

minetest.register_craft({
    output = "pale_garden:pale_oak_trapdoor",
    recipe = {
        {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
        {"mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks", "mcl_core:pale_oak_planks"},
    }
})

-- Craft: Tronco -> Tábuas
minetest.register_craft({
    output = "pale_garden:pale_oak_planks 4",
    recipe = {
        {"pale_garden:pale_oak_log"},
    }
})

-- Craft: Madeira -> Tábuas
minetest.register_craft({
    output = "pale_garden:pale_oak_planks 4",
    recipe = {
        {"pale_garden:pale_oak_wood"},
    }
})

-- Geração de árvore Pale Oak
function pale_garden.generate_pale_oak_tree(pos)
    local height = math.random(5, 8)
    
    -- Tronco
    for y = 0, height do
        minetest.set_node({x=pos.x, y=pos.y+y, z=pos.z}, {name="pale_garden:pale_oak_log"})
    end
    
    -- Copa (folhas)
    local top = pos.y + height
    for dx = -2, 2 do
        for dz = -2, 2 do
            for dy = 0, 2 do
                local p = {x=pos.x+dx, y=top+dy-1, z=pos.z+dz}
                if math.abs(dx) + math.abs(dz) <= 3 then
                    if minetest.get_node(p).name == "air" then
                        minetest.set_node(p, {name="pale_garden:pale_oak_leaves"})
                    end
                end
            end
        end
    end
    
    -- Musgo pendurado nas folhas (chance aleatória)
    for dx = -2, 2 do
        for dz = -2, 2 do
            if math.random(1, 5) == 1 then
                local leaf_pos = {x=pos.x+dx, y=top, z=pos.z+dz}
                local below = {x=leaf_pos.x, y=leaf_pos.y-1, z=leaf_pos.z}
                if minetest.get_node(leaf_pos).name == "pale_garden:pale_oak_leaves" and 
                   minetest.get_node(below).name == "air" then
                    minetest.set_node(below, {name="pale_garden:pale_hanging_moss_tip"})
                end
            end
        end
    end
end

-- Crescimento da muda
minetest.register_abm({
    label = "Pale Oak Sapling Growth",
    nodenames = {"pale_garden:pale_oak_sapling"},
    interval = 30,
    chance = 5,
    action = function(pos, node)
        local light_level = minetest.get_node_light(pos)
        if light_level and light_level >= 9 then
            minetest.remove_node(pos)
            pale_garden.generate_pale_oak_tree(pos)
        end
    end,
})

minetest.log("action", "[Pale Garden] Pale Oak registrado!")
