-- ===============================
-- PARTICLE COMMAND (ISOLADO)
-- ===============================
local function normalize_texture(name)
    if not name or name == "" then
        return nil
    end
    if not name:find("%.png$") then
        name = name .. ".png"
    end
    return name
end

-- Position parsing with support for ~ and ^
local function parse_pos(args, player)

    local base

    -- PRIORIDADE 1: position do player
    if player and player:get_pos() then

        base = vector.round(player:get_pos())
        base.y = base.y + 1.5

        -- PRIORIDADE 2: position do command block
    elseif core.commandblock_pos then

        base = vector.round(core.commandblock_pos)

    elseif minetest.get_commandblock_pos then

        base = vector.round(minetest.get_commandblock_pos())

        -- FALLBACK seguro
    else

        base = {
            x = 0,
            y = 0,
            z = 0
        }

    end

    local function parse_axis(v, axis)

        if not v then
            return base[axis]
        end

        if v == "~" then
            return base[axis]
        end

        if v:sub(1, 1) == "~" then
            return base[axis] + (tonumber(v:sub(2)) or 0)
        end

        if v == "^" then
            return base[axis]
        end

        if v:sub(1, 1) == "^" then
            return base[axis] + (tonumber(v:sub(2)) or 0)
        end

        return tonumber(v) or base[axis]

    end

    if args[1] then

        return {
            x = parse_axis(table.remove(args, 1), "x"),
            y = parse_axis(table.remove(args, 1), "y"),
            z = parse_axis(table.remove(args, 1), "z")
        }

    end

    return base

end

-- Helper function to collect all textures registered in the game
local function get_all_textures()
    local textures = {}

    -- 1. Coletar textures de todos os itens e nós registrados
    for name, def in pairs(minetest.registered_items) do
        -- Textures de inventário
        if def.inventory_image and def.inventory_image ~= "" then
            textures[def.inventory_image] = true
        end
        -- Textures de tiles (for nós)
        if def.tiles then
            for _, tile in ipairs(def.tiles) do
                local tile_name = type(tile) == "table" and tile.name or tile
                if type(tile_name) == "string" and tile_name ~= "" then
                    textures[tile_name] = true
                end
            end
        end
        -- Textures especiais
        if def.special_tiles then
            for _, tile in ipairs(def.special_tiles) do
                local tile_name = type(tile) == "table" and tile.name or tile
                if type(tile_name) == "string" and tile_name ~= "" then
                    textures[tile_name] = true
                end
            end
        end
    end

    -- 2. Coletar textures de entidades registradas
    for name, def in pairs(minetest.registered_entities) do
        if def.initial_properties and def.initial_properties.textures then
            for _, tex in ipairs(def.initial_properties.textures) do
                if type(tex) == "string" and tex ~= "" then
                    textures[tex] = true
                end
            end
        end
    end

    -- Converter o set em uma lista ordenada
    local list = {}
    for tex in pairs(textures) do
        -- Remove texture modifiers (ex: [combine, ^, etc) for cleaner search
        local base_tex = tex:split("^")[1]:split("[")[1]
        if base_tex ~= "" then
            list[base_tex] = true
        end
    end

    local final_list = {}
    for tex in pairs(list) do
        table.insert(final_list, tex)
    end
    table.sort(final_list)
    return final_list
end

minetest.register_chatcommand("particle_search", {
    params = "<termo>",
    description = "Lista textures registradas que podem ser usadas como partículas",
    privs = {
        server = true
    },
    func = function(name, param)
        if param == "" then
            return false, "Usage: /particle_search <termo>"
        end

        local search = param:lower()
        local all_textures = get_all_textures()
        local found = {}

        for _, tex in ipairs(all_textures) do
            if tex:lower():find(search, 1, true) then
                table.insert(found, tex)
            end
        end

        if #found == 0 then
            return false, "Noa texture found containing: " .. param
        end

        -- Limit the display when there are many results to avoid freezing the chat
        local max_display = 50
        local output = "✨ Textures containing '" .. param .. "':\n"
        for i = 1, math.min(#found, max_display) do
            output = output .. found[i] .. (i == #found and "" or ", ")
        end

        if #found > max_display then
            output = output .. "\n... e mais " .. (#found - max_display) .. " resultados."
        end

        minetest.chat_send_player(name, output)
        return true
    end
})

minetest.register_chatcommand("particle", {
    params = "<texture> [args...]",
    description = "Cria partículas (static, floating, falling, sphere, hollow)",
    privs = {
        server = true
    },

    func = function(name, param)
        local args = param:split(" ")
        if #args == 0 then
            return false, "Usage: /particle <texture> [args]"
        end

        local player = nil

        if name and name ~= "" then
            player = minetest.get_player_by_name(name)
        end

        -- TEXTURE
        local texture = normalize_texture(table.remove(args, 1))
        if not texture then
            return false, "Texture invalid"
        end

        -- CONFIG DEFAULT
        local cfg = {
            mode = "static", -- static | floating | falling
            shape = "point", -- point | sphere
            hollow = false,
            radius = 3,
            size = 4,
            count = 30,
            spread = 0.3,
            seed = os.time()
        }

        -- PARSE DE FLAGS
        local i = 1
        while i <= #args do
            local a = args[i]:lower()

            if a == "floating" or a == "falling" or a == "static" then
                cfg.mode = a
                table.remove(args, i)

            elseif a == "hollow" then
                cfg.hollow = true
                table.remove(args, i)

            elseif a == "sphere" then
                cfg.shape = "sphere"
                table.remove(args, i)

            elseif a:match("^sphere=") then
                cfg.shape = "sphere"
                cfg.radius = tonumber(a:match("sphere=(.+)")) or cfg.radius
                table.remove(args, i)

            elseif a:match("^size=") then
                cfg.size = tonumber(a:match("size=(.+)")) or cfg.size
                table.remove(args, i)

            elseif a:match("^count=") then
                cfg.count = tonumber(a:match("count=(.+)")) or cfg.count
                table.remove(args, i)

            elseif a:match("^spread=") then
                cfg.spread = tonumber(a:match("spread=(.+)")) or cfg.spread
                table.remove(args, i)

            elseif a:match("^seed=") then
                cfg.seed = tonumber(a:match("seed=(.+)")) or cfg.seed
                table.remove(args, i)

            else
                i = i + 1
            end
        end

        -- POSITION
        local pos = parse_pos(args, player)

        math.randomseed(cfg.seed)

        -- MOVIMENTO
        local vel, acc, collision = vector.zero(), vector.zero(), false

        if cfg.mode == "falling" then
            vel = {
                x = 0,
                y = 1,
                z = 0
            }
            acc = {
                x = 0,
                y = -9.8,
                z = 0
            }
            collision = true

        elseif cfg.mode == "floating" then
            vel = {
                x = 0,
                y = 1,
                z = 0
            }
            acc = {
                x = 0,
                y = 0.3,
                z = 0
            }
        end

        -- SPAWN
        if cfg.shape == "sphere" then
            for x = -cfg.radius, cfg.radius do
                for y = -cfg.radius, cfg.radius do
                    for z = -cfg.radius, cfg.radius do
                        local d = math.sqrt(x * x + y * y + z * z)
                        if d <= cfg.radius and (not cfg.hollow or d >= cfg.radius - 1) then
                            minetest.add_particle({
                                pos = vector.add(pos, {
                                    x = x,
                                    y = y,
                                    z = z
                                }),
                                velocity = vel,
                                acceleration = acc,
                                expirationtime = 4,
                                size = cfg.size,
                                texture = texture,
                                collisiondetection = collision,
                                glow = 10
                            })
                        end
                    end
                end
            end
        else
            local spread_vec = {
                x = cfg.spread,
                y = cfg.spread,
                z = cfg.spread
            }

            minetest.add_particlespawner({
                amount = cfg.count,
                time = 0.1,

                minpos = vector.subtract(pos, spread_vec),
                maxpos = vector.add(pos, spread_vec),

                minvel = vel,
                maxvel = vel,

                minacc = acc,
                maxacc = acc,

                minsize = cfg.size,
                maxsize = cfg.size,

                texture = texture,
                collisiondetection = collision,
                glow = 10
            })
        end

        return true, " Particle criado: " .. texture
    end
})
