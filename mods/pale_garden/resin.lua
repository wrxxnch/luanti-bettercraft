-- Resin (Seiva) - Sistema de seiva do Pale Garden

-- Registra a seiva (item dropável)
minetest.register_craftitem("pale_garden:resin_clump", {
    description = "Grumo de Seiva",
    inventory_image = "default_resin_clump.png",
    groups = {craftitem = 1, material_organic = 1},
    _mcl_item_group = "materials", -- aparece na aba Materiais
})

-- Registra o bloco de seiva
minetest.register_node("pale_garden:resin_block", {
    description = "Bloco de Seiva",
    tiles = {"default_resin_block.png"},
    is_ground_content = false,
    groups = {pickaxey = 1, building_block = 1, material_stone = 1},
    sounds = mcl_sounds.node_sound_stone_defaults(),
    _mcl_blast_resistance = 1.5,
    _mcl_hardness = 1.5,
    _mcl_item_group = "building_blocks", -- aparece na aba Blocos de construção
})

-- Registra os tijolos de seiva
minetest.register_node("pale_garden:resin_bricks", {
    description = "Tijolos de Seiva",
    tiles = {"default_resin_bricks.png"},
    is_ground_content = false,
    groups = {pickaxey = 1, building_block = 1, stonebrick = 1, material_stone = 1},
    sounds = mcl_sounds.node_sound_stone_defaults(),
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_item_group = "building_blocks",
})

-- Registra tijolos de seiva cinzelados
minetest.register_node("pale_garden:chiseled_resin_bricks", {
    description = "Tijolos de Seiva Cinzelados",
    tiles = {"default_chiseled_resin_bricks.png"},
    is_ground_content = false,
    groups = {pickaxey = 1, building_block = 1, stonebrick = 1, material_stone = 1},
    sounds = mcl_sounds.node_sound_stone_defaults(),
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_item_group = "building_blocks",
})

-- Craft: 4 grumos de seiva -> 1 bloco de seiva
minetest.register_craft({
    output = "pale_garden:resin_block",
    recipe = {
        {"pale_garden:resin_clump", "pale_garden:resin_clump"},
        {"pale_garden:resin_clump", "pale_garden:resin_clump"},
    }
})

-- Craft: 1 bloco de seiva -> 4 grumos de seiva (reversível)
minetest.register_craft({
    output = "pale_garden:resin_clump 4",
    recipe = {
        {"pale_garden:resin_block"},
    }
})

-- Craft: 4 blocos de seiva -> 4 tijolos de seiva
minetest.register_craft({
    output = "pale_garden:resin_bricks 4",
    recipe = {
        {"pale_garden:resin_block", "pale_garden:resin_block"},
        {"pale_garden:resin_block", "pale_garden:resin_block"},
    }
})

-- Craft: 2 tijolos de seiva -> 2 tijolos cinzelados
minetest.register_craft({
    output = "pale_garden:chiseled_resin_bricks",
    recipe = {
        {"pale_garden:resin_bricks"},
        {"pale_garden:resin_bricks"},
    }
})

-- Adiciona seiva como drop das folhas de Pale Oak (chance rara)
local old_pale_leaves = minetest.registered_nodes["pale_garden:pale_oak_leaves"]
if old_pale_leaves then
    minetest.override_item("pale_garden:pale_oak_leaves", {
        drop = {
            max_items = 1,
            items = {
                {items = {"pale_garden:resin_clump"}, rarity = 10}, -- 10% de chance
                {items = {"pale_garden:pale_oak_sapling"}, rarity = 20},
                {items = {"pale_garden:pale_oak_leaves"}}
            }
        },
    })
end

-- ABM: Seiva aparece nas árvores Pale Oak ao longo do tempo
minetest.register_abm({
    label = "Resin Growth on Pale Oak",
    nodenames = {"pale_garden:pale_oak_log"},
    neighbors = {"pale_garden:pale_oak_leaves"},
    interval = 300, -- A cada 5 minutos
    chance = 50,
    action = function(pos, node)
        local directions = {
            {x=1, y=0, z=0},  -- Direita
            {x=-1, y=0, z=0}, -- Esquerda
            {x=0, y=0, z=1},  -- Frente
            {x=0, y=0, z=-1}, -- Trás
        }
        
        for _, dir in ipairs(directions) do
            local check_pos = vector.add(pos, dir)
            local check_node = minetest.get_node(check_pos)
            
            if check_node.name == "air" then
                minetest.set_node(check_pos, {name="pale_garden:resin_clump_node"})
                break
            end
        end
    end,
})

-- Registra seiva como nó (grudada na árvore)
-- Nó de seiva grudado na árvore (tipo vinha, mas sem escalar)
-- Nó de seiva grudado na árvore (plano tipo vinha, mas sem escalar)
minetest.register_node("pale_garden:resin_clump_node", {
    description = "Seiva",
    drawtype = "signlike", -- 🔥 plano, colado na superfície
    tiles = {"default_resin_clump_node.png"},
    inventory_image = "default_resin_clump_node.png",
    wield_image = "default_resin_clump_node.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    climbable = false, -- não é escalável como vinha
    use_texture_alpha = "clip", -- recorte limpo da textura
    orientation = "wall", -- garante orientação colada

    groups = {
        handy = 1,
        attached_node = 1, -- cai se o suporte for removido
        dig_immediate = 3,
        deco_block = 1,
    },

    drop = "pale_garden:resin_clump",
    sounds = mcl_sounds.node_sound_leaves_defaults(),
    _mcl_item_group = "materials",

    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05}, -- seleção vertical fina
    },

    -- Garante que a seiva "grude" na parede corretamente
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local under = pointed_thing.under
        local dir = vector.subtract(under, pos)
        local wall = minetest.dir_to_wallmounted(dir)
        local node = minetest.get_node(pos)
        node.param2 = wall
        minetest.swap_node(pos, node)
    end,

    -- Mantém apenas a lógica de cair se o suporte for destruído
    on_destruct = function(pos)
        -- nada extra, não remove outros nós adjacentes
    end,
})

minetest.log("action", "[Pale Garden] Nó de seiva registrado com sucesso (plano tipo vinha, sem escalar, sem destruir nós adjacentes).")


