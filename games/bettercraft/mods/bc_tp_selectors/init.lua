local S = core.get_translator(core.get_current_modname())

-------------------------------------------------
-- Utilidades
-------------------------------------------------

local function distance(a, b)
	return vector.distance(a, b)
end

local function get_nearest_player(pos)
	local nearest, dist
	for _, player in ipairs(core.get_connected_players()) do
		local d = distance(pos, player:get_pos())
		if not dist or d < dist then
			dist = d
			nearest = player
		end
	end
	return nearest
end

local function get_random_player()
	local players = core.get_connected_players()
	if #players == 0 then return nil end
	return players[math.random(#players)]
end

local function parse_selector(selector, origin_pos)
	-- @p
	if selector == "@p" then
		local p = get_nearest_player(origin_pos)
		return p and { p } or {}
	end

	-- @r
	if selector == "@r" then
		local p = get_random_player()
		return p and { p } or {}
	end

	-- @e[type=xxx,r=nnn]
	local type_name = selector:match("type=([^,%]]+)")
	local radius = tonumber(selector:match("r=([^,%]]+)"))

	if selector:sub(1, 2) ~= "@e" and selector:sub(1, 2) ~= "@r" then
		return {}
	end

	local result = {}

	for _, obj in ipairs(core.get_objects_inside_radius(
		origin_pos,
		radius or 32000
	)) do
		local ent = obj:get_luaentity()
		if ent then
			if not type_name or ent.name == type_name then
				table.insert(result, obj)
			end
		end
	end

	-- @r[type=...]
	if selector:sub(1, 2) == "@r" and #result > 0 then
		return { result[math.random(#result)] }
	end

	return result
end

-------------------------------------------------
-- Teleportation
-------------------------------------------------

local function teleport_object(obj, target_pos)
	if obj:is_player() then
		obj:set_pos(target_pos)
	else
		obj:set_pos(target_pos)
	end
end

-------------------------------------------------
-- Command /tp
-------------------------------------------------

core.register_chatcommand("tp", {
	params = "<origem> <destino>",
	description = "Teleport with selectors estilo Minecraft",
	privs = { teleport = true },

	func = function(name, param)
		local from, to = param:match("^(%S+)%s+(%S+)$")
		if not from or not to then
			return false, "Usage: /tp <origem> <destino>"
		end

		local executor = core.get_player_by_name(name)
		if not executor then return end
		local exec_pos = executor:get_pos()

		-------------------------------------------------
		-- 1️⃣ Resolver DESTINO primeiro (selector ou nome)
		-------------------------------------------------
		local dest_pos = nil

		if to:sub(1,1) == "@" then
			local dest_objs = parse_selector(to, exec_pos)
			if #dest_objs == 0 then
				return false, "Destination selector found nothing"
			end
			dest_pos = dest_objs[1]:get_pos()
		else
			local p = core.get_player_by_name(to)
			if not p then
				return false, "Destino invalid"
			end
			dest_pos = p:get_pos()
		end

		-------------------------------------------------
		-- 2️⃣ Resolver ORIGEM (selector ou nome)
		-------------------------------------------------
		local sources = {}

		if from:sub(1,1) == "@" then
			sources = parse_selector(from, exec_pos)
			if #sources == 0 then
				return false, "Source selector found nothing"
			end
		else
			local p = core.get_player_by_name(from)
			if not p then
				return false,
					"It is not possible teleport with o nome \"" .. from .. "\""
			end
			sources = { p }
		end

		-------------------------------------------------
		-- 3️⃣ Executar teleportation
		-------------------------------------------------
		for _, obj in ipairs(sources) do
			obj:set_pos(dest_pos)
		end

		return true, "Teleportation completed successfully."
	end
})

