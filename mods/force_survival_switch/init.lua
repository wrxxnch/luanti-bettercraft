-- Remove fly/fast SOMENTE ao sair do criativo para survival

local function remove_fly_fast(name)
	local privs = minetest.get_player_privs(name)
	privs.fly = nil
	privs.fast = nil
	minetest.set_player_privs(name, privs)
end

-- Inicializa o estado ao entrar
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local meta = player:get_meta()

	-- Salva o estado atual do criativo
	meta:set_int("was_creative", minetest.is_creative_enabled(name) and 1 or 0)
end)

-- Verifica mudança de criativo -> survival
minetest.register_globalstep(function()
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local meta = player:get_meta()

		local was_creative = meta:get_int("was_creative") == 1
		local is_creative = minetest.is_creative_enabled(name)

		-- Se estava no criativo e agora NÃO está mais
		if was_creative and not is_creative then
			remove_fly_fast(name)
		end

		-- Atualiza estado
		meta:set_int("was_creative", is_creative and 1 or 0)
	end
end)
