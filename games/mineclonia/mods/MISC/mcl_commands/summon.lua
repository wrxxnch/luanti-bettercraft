local S = core.get_translator(core.get_current_modname())

-- Copia spawnentity
local base_cmd = core.registered_chatcommands["spawnentity"]
assert(base_cmd, "[summon] spawnentity não encontrado")

local cmd = table.copy(base_cmd)

cmd.params = S("<entidade> [param=valor] ...")
cmd.description = S("Invoca entidades com parâmetros avançados")

cmd.func = function(name, param)
	if not param or param == "" then
		return false, S("Uso: /summon <entidade> [param=valor]...")
	end

	local args = param:split(" ")
	local entname = table.remove(args, 1)

	-- Nome curto
	if not entname:find(":") then
		if core.registered_entities["mobs_mc:" .. entname] then
			entname = "mobs_mc:" .. entname
		end
	end

	local ent_def = core.registered_entities[entname]
	if not ent_def then
		return false, S("Entidade desconhecida: @1", entname)
	end

	if core.settings:get_bool("only_peaceful_mobs", false)
	and ent_def.is_mob
	and ent_def.type == "monster" then
		return false, S("Apenas mobs pacíficos são permitidos!")
	end

	local player = core.get_player_by_name(name)
	if not player then
		return false, S("Jogador não encontrado.")
	end

	local pos = player:get_pos()
	pos.y = pos.y + 1.5

	local obj = core.add_entity(pos, entname)
	if not obj then
		return false, S("Falha ao criar a entidade: @1", entname)
	end

	local luaent = obj:get_luaentity()

	-- =====================================================
	-- PARÂMETROS
	-- =====================================================
	for _, arg in ipairs(args) do
		local key, value = arg:match("([^=]+)=(.+)")
		if key and value then
			local final = value

			if value == "true" then
				final = true
			elseif value == "false" then
				final = false
			elseif tonumber(value) then
				final = tonumber(value)
			end

			if key == "child" and luaent then
				luaent.child = final
				if luaent.set_child then
					luaent:set_child(final)
				end

			elseif key == "passive" and luaent then
				luaent.passive = final

			elseif key == "tamed" and luaent then
				luaent.tamed = final
				luaent.owner = final and name or nil

			elseif key == "nametag" then
				obj:set_nametag_attributes({ text = tostring(final) })

			elseif key == "hp" then
				obj:set_hp(tonumber(final) or obj:get_hp())

			elseif key == "yaw" then
				obj:set_yaw(math.rad(tonumber(final) or 0))

			elseif key == "hand" and luaent then
	if luaent.set_wielded_item then
		luaent:set_wielded_item(ItemStack(final))
	elseif luaent.wield_item then
		-- fallback para mods antigos
		luaent:wield_item(final)
	else
		core.chat_send_player(name,
			S("Esta entidade não pode segurar itens."))
	end


			elseif key == "armor" and luaent and luaent.set_armor_groups then
				luaent:set_armor_groups({ fleshy = tonumber(final) or 100 })

			elseif key == "ride" then
	local ride_name = value

	-- resolve nome curto
	if not ride_name:find(":") then
		if core.registered_entities["mobs_mc:" .. ride_name] then
			ride_name = "mobs_mc:" .. ride_name
		end
	end

	if not core.registered_entities[ride_name] then
		core.chat_send_player(name,
			S("Montaria desconhecida: @1", ride_name))
	else
		local mount = core.add_entity(pos, ride_name)
		if mount then
			obj:set_attach(mount, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
		end
	end


			else
				pcall(function()
					obj:set_properties({ [key] = final })
				end)
			end
		end
	end

	return true, S("Entidade invocada: @1", entname)
end

-- Substitui spawnentity
if core.registered_chatcommands["spawnentity"] then
	core.unregister_chatcommand("spawnentity")
end
core.register_chatcommand("summon", cmd)

-- =====================================================
-- HELP
-- =====================================================
core.register_chatcommand("summon_help", {
	description = S("Ajuda completa do /summon"),
	func = function(name)
		core.chat_send_player(name, [[
/summon <entidade> [param=valor]

PARÂMETROS:
child=true|false
passive=true|false
tamed=true|false
nametag=Texto
hp=NUM
yaw=GRAUS
hand=itemstring
armor=NUM
ride=entidade

EXEMPLOS:
/summon zombie
/summon zombie child=true
/summon wolf tamed=true
/summon villager nametag=Bob
]])
		return true
	end
})
