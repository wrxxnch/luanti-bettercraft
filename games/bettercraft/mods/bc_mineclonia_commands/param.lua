-- Function auxiliar for pegar o block que o player está olhando
local function get_pointed_node(player)
	local eye_pos = player:get_pos()
	eye_pos.y = eye_pos.y + player:get_properties().eye_height
	local look_dir = player:get_look_dir()
	local dist = 10 -- distância máxima
	local ray = minetest.raycast(eye_pos, eye_pos + look_dir * dist, false, false)
	local pointed = ray:next()

	if pointed and pointed.type == "node" then
		return pointed.under
	end
	return nil
end

-- Command /set_param <num>
minetest.register_chatcommand("set_param", {
	params = "<num>",
	description = "Altera o param2 do block que you está olhando",
	privs = {server = true},
	func = function(name, param)
		local val = tonumber(param)
		if not val then
			return false, "Error: enter um número (Ex: /set_param 4)"
		end

		local player = minetest.get_player_by_name(name)
		local pos = get_pointed_node(player)

		if pos then
			local node = minetest.get_node(pos)
			node.param2 = val
			minetest.swap_node(pos, node)
			return true, "Param2 de " .. node.name .. " alterado for " .. val
		end
		return false, "No block found na mira."
	end
})

-- Command /honeylevel <0-5>
minetest.register_chatcommand("honeylevel", {
	params = "<0-5>",
	description = "Altera o nível de mel da colmeia que you está olhando",
	privs = {server = true},
	func = function(name, param)
		local level = tonumber(param)
		if not level then
			return false, "Usage: /honeylevel <número>"
		end

		local player = minetest.get_player_by_name(name)
		local pos = get_pointed_node(player)

		if pos then
			local node = minetest.get_node(pos)
			-- Remove qualquer sufixo de mel atual (ex: beehive_1 vira beehive)
			local base_name = node.name:gsub("_%d+$", "")
			
			local new_name
			if level == 0 then
				new_name = base_name
			else
				new_name = base_name .. "_" .. level
			end

			-- Verifica se esse block existe no jogo antes de change
			if minetest.registered_nodes[new_name] then
				minetest.swap_node(pos, {name = new_name, param2 = node.param2})
				return true, "Colmeia alterada for: " .. new_name
			else
				return false, "Error: O block " .. new_name .. " not existe no registro."
			end
		end
		return false, "No block found na mira."
	end
})