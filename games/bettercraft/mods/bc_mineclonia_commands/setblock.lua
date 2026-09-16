--------------------------------------------------
-- MINECLONIA COMMANDS - SETBLOCK SYSTEM
--------------------------------------------------

bc_mineclonia_commands = bc_mineclonia_commands or {}

bc_mineclonia_commands.node_cache = {}
bc_mineclonia_commands.search_results = {}
bc_mineclonia_commands.results_per_page = 20
bc_mineclonia_commands.selected_block = {}

--------------------------------------------------
-- COORD PARSER (~ e ^)
--------------------------------------------------

local function parse_coord(coord, player_pos, look_dir)

    if coord:sub(1,1) == "~" then
        local offset = tonumber(coord:sub(2)) or 0
        return player_pos + offset

    elseif coord:sub(1,1) == "^" then
        local offset = tonumber(coord:sub(2)) or 0
        return player_pos + (look_dir * offset)

    else
        return tonumber(coord)
    end
end

local function get_pos_from_args(args, player)

    if #args < 3 then return nil end

    local pos = player:get_pos()
    local look = player:get_look_dir()

    local x = parse_coord(args[1], pos.x, look.x)
    local y = parse_coord(args[2], pos.y, look.y)
    local z = parse_coord(args[3], pos.z, look.z)

    if not x or not y or not z then
        return nil
    end

    return {
        x = math.floor(x + 0.5),
        y = math.floor(y + 0.5),
        z = math.floor(z + 0.5)
    }, { unpack(args, 4) }
end

--------------------------------------------------
-- CACHE DE NODES
--------------------------------------------------

minetest.register_on_mods_loaded(function()

    for name, def in pairs(minetest.registered_nodes) do
        table.insert(bc_mineclonia_commands.node_cache, {
            name = name,
            description = def.description or ""
        })
    end

    table.sort(bc_mineclonia_commands.node_cache, function(a, b)
        return a.name < b.name
    end)

    minetest.log("action",
        "[Mineclonia Commands] Cache generated with "
        .. #bc_mineclonia_commands.node_cache .. " nodes.")
end)

--------------------------------------------------
-- BUSCA
--------------------------------------------------

local function search_nodes(term)

    local results = {}
    term = term:lower()

    for _, node in ipairs(bc_mineclonia_commands.node_cache) do
        if node.name:lower():find(term, 1, true)
        or node.description:lower():find(term, 1, true) then
            table.insert(results, node.name)
        end
    end

    table.sort(results)
    return results
end

local function show_page(player_name, page)

    local results = bc_mineclonia_commands.search_results[player_name]
    if not results or #results == 0 then
        minetest.chat_send_player(player_name, "No resultado.")
        return
    end

    page = tonumber(page) or 1
    local per_page = bc_mineclonia_commands.results_per_page
    local max_page = math.ceil(#results / per_page)

    if page < 1 then page = 1 end
    if page > max_page then page = max_page end

    local start_i = (page - 1) * per_page + 1
    local end_i = math.min(start_i + per_page - 1, #results)

    minetest.chat_send_player(player_name,
        "---- Página " .. page .. "/" .. max_page .. " ----")

    for i = start_i, end_i do
        minetest.chat_send_player(player_name, i .. ": " .. results[i])
    end

    minetest.chat_send_player(player_name,
        "Use: /setblock_pick <numero> ou /setblock_page <NumeroPagina>")
end

--------------------------------------------------
-- /setblock_search
--------------------------------------------------

minetest.register_chatcommand("setblock_search", {
    params = "<termo>",
    description = "Busca blocks",
    privs = {server = true},

    func = function(name, param)

        if param == "" then
            return false, "Enter algo for buscar."
        end

        local results = search_nodes(param)
        bc_mineclonia_commands.search_results[name] = results

        if #results == 0 then
            return false, "No block found."
        end

        show_page(name, 1)
        return true
    end
})

--------------------------------------------------
-- /setblock_pick
--------------------------------------------------

minetest.register_chatcommand("setblock_pick", {
    params = "<numero>",
    description = "Seleciona block",
    privs = {server = true},

    func = function(name, param)

        local index = tonumber(param)
        if not index then
            return false, "Número invalid."
        end

        local results = bc_mineclonia_commands.search_results[name]
        if not results or not results[index] then
            return false, "Índice does not exist."
        end

        bc_mineclonia_commands.selected_block[name] = results[index]

        return true, "Selected: " .. results[index]
    end
})

--------------------------------------------------
-- /setblock
--------------------------------------------------

minetest.register_chatcommand("setblock", {
    params = "<x> <y> <z> [block]",
    description = "Coloca um block",
    privs = {server = true},

    func = function(name, param)

        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player invalid"
        end

        local args = param:split(" ")
        local pos, remaining = get_pos_from_args(args, player)

        if not pos then
            return false, "Position invalid"
        end

        local block_name = remaining[1]

        if not block_name then
            block_name = bc_mineclonia_commands.selected_block[name]
            if not block_name then
                return false, "No block selected."
            end
        end

        -- namespace automático
        if not block_name:find(":") then

            local try1 = "mcl_trees:" .. block_name
            local try2 = "mcl_core:" .. block_name

            if minetest.registered_nodes[try1] then
                block_name = try1
            elseif minetest.registered_nodes[try2] then
                block_name = try2
            end
        end

        if not minetest.registered_nodes[block_name] then
            return false, "Block does not exist: " .. block_name
        end

        -- valida chunk loaded
        if not minetest.get_node_or_nil(pos) then
            return false, "Map not loaded at this position."
        end

        minetest.set_node(pos, {name = block_name})

        return true, "Colocado: " .. block_name
    end
})

--------------------------------------------------
-- /setblock_page
--------------------------------------------------

minetest.register_chatcommand("setblock_page", {
    params = "<numero>",
    description = "Muda página da busca",
    privs = {server = true},

    func = function(name, param)

        local page = tonumber(param)
        if not page then
            return false, "Número invalid."
        end

        local results = bc_mineclonia_commands.search_results[name]

        if not results or #results == 0 then
            return false, "Noa busca ativa."
        end

        local per_page = bc_mineclonia_commands.results_per_page
        local max_page = math.ceil(#results / per_page)

        if page < 1 or page > max_page then
            return false, "Página invalid. Máx: " .. max_page
        end

        show_page(name, page)
        return true
    end
})