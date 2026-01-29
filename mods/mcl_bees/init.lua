-- mcl_bees/init.lua
-- Mod de abelhas para Mineclonia/MineClone2
-- Baseado no PR 2129 do Mineclonia

mcl_bees = {}

-- Registrar a entidade da abelha
mcl_mobs.register_mob("mcl_bees:bee", {
    on_rightclick = function(self, clicker)
        if mcl_util.is_item_in_hand(clicker, "mcl_flowers:flower_all") then
            -- Lógica de alimentação/reprodução simplificada
            return
        end
    end,
    do_custom = function(self, dtime)
        -- Procurar flores próximas
        local pos = self.object:get_pos()
        if not pos then return end
        if math.random(1, 100) == 1 then
            local nodes = minetest.find_nodes_in_area(
                {x=pos.x-5, y=pos.y-2, z=pos.z-5},
                {x=pos.x+5, y=pos.y+2, z=pos.z+5},
                {"group:flower"}
            )
            if #nodes > 0 then
                self.order = "follow"
                self.follow = nodes[math.random(1, #nodes)]
            end
        end
    end,

    type = "animal",
    spawn_class = "passive",
    hp_min = 20,
    hp_max = 20,
    xp_min = 5,
    xp_max = 5,
    reach = 3,
    armor = 10,
    collisionbox = { -0.2, -0.1, -0.2, 0.2, 0.7, 0.2 },
    visual = "mesh",
    mesh = "mobs_mc_bee.b3d",
    visual_size = { x = 1, y = 1},
    textures = {
        {"mobs_mc_bee.png"},
    },
    glow = 4,
    fly = true,
    fly_in = { "air" },
    fly_velocity = 4,
    sounds = {
        random = "mcl_bees_bee_idle",
        hurt = "mcl_bees_bee_hurt",
        death = "mcl_bees_bee_death",
    },
    drops = {},
    view_range = 16,
    stepheight = 1.1,
    fall_damage = false,
    animation = {
        stand_start = 1, stand_end = 40, stand_speed = 10,
        walk_start = 1, walk_end = 40, speed_normal = 10,
        run_start = 1, run_end = 40, speed_run = 15,
        punch_start = 1, punch_end = 40, punch_speed = 15,
    },
})

mcl_mobs.register_egg("mcl_bees:bee", "Bee", "#6f4833", "#daa047", 0)

-- Registrar Colmeia (Beehive)
minetest.register_node("mcl_bees:beehive", {
    description = "Beehive",
    tiles = {
        "mcl_bees_beehive_top.png", "mcl_bees_beehive_top.png",
        "mcl_bees_beehive_side.png", "mcl_bees_beehive_side.png",
        "mcl_bees_beehive_side.png", "mcl_bees_beehive_front.png"
    },
    groups = {pickaxey = 1, axey = 1, handy = 1, deco_block = 1},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("honey_level", 0)
        meta:set_int("bee_count", 0)
    end,
})

-- Registrar Ninho de Abelha (Bee Nest)
minetest.register_node("mcl_bees:bee_nest", {
    description = "Bee Nest",
    tiles = {
        "mcl_bees_bee_nest_top.png", "mcl_bees_bee_nest_bottom.png",
        "mcl_bees_bee_nest_side.png", "mcl_bees_bee_nest_side.png",
        "mcl_bees_bee_nest_side.png", "mcl_bees_bee_nest_front.png"
    },
    groups = {pickaxey = 1, axey = 1, handy = 1, deco_block = 1},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("honey_level", 0)
        meta:set_int("bee_count", 0)
    end,
})

-- Itens: Mel e Favo de Mel
minetest.register_craftitem("mcl_bees:honey_bottle", {
    description = "Honey Bottle",
    inventory_image = "mcl_bees_honey_bottle.png",
    on_use = minetest.item_eat(6),
})

minetest.register_craftitem("mcl_bees:honeycomb", {
    description = "Honeycomb",
    inventory_image = "mcl_bees_honeycomb.png",
})

-- Receitas de Crafting
minetest.register_craft({
    output = "mcl_bees:beehive",
    recipe = {
        {"mcl_core:wood", "mcl_core:wood", "mcl_core:wood"},
        {"mcl_bees:honeycomb", "mcl_bees:honeycomb", "mcl_bees:honeycomb"},
        {"mcl_core:wood", "mcl_core:wood", "mcl_core:wood"},
    }
})

-- Registrar spawn das abelhas
mcl_mobs.spawn({
    name = "mcl_bees:bee",
    nodes = {"mcl_core:dirt_with_grass"},
    min_light = 10,
    max_light = 15,
    interval = 60,
    chance = 8000,
    active_object_count = 2,
    min_height = 1,
    max_height = 31000,
})


-- Adicionar abelhas aos biomas específicos (Planícies, Florestas, etc.)
if minetest.get_modpath("mcl_biomes") then
mcl_mobs.spawn({
    name = "mcl_bees:bee",
    nodes = {"mcl_core:dirt_with_grass"},
    neighbors = {"air"},
    min_light = 10,
    max_light = 15,
    interval = 60,
    chance = 8000,
    active_object_count = 2,
    min_height = 1,
    max_height = 31000,
    biomes = {
        "plains",
        "sunflower_plains",
        "forest",
        "flower_forest",
        "birch_forest"
    }
})

end
