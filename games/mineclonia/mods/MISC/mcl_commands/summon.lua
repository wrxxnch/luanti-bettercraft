local S = core.get_translator(core.get_current_modname())

local orig_func = core.registered_chatcommands["spawnentity"].func
local cmd = table.copy(core.registered_chatcommands["spawnentity"])

cmd.func = function(name, param)
	if param == "" or not param then
		return false, S("Usage: /summon <entity>")
	end

	local entname = param

	-- Se não tiver namespace, assume mobs_mc:
	if not entname:find(":") then
		if core.registered_entities["mobs_mc:" .. entname] then
			entname = "mobs_mc:" .. entname
		end
	end

	local ent = core.registered_entities[entname]
	if not ent then
		return false, S("Unknown entity: @1"):gsub("@1", param)
	end

	-- Respeita only_peaceful_mobs
	if core.settings:get_bool("only_peaceful_mobs", false)
	and ent.is_mob
	and ent.type == "monster" then
		return false, S("Only peaceful mobs allowed!")
	end

	-- Chama o comando original com o nome corrigido
	local bool, msg = orig_func(name, entname)
	return bool, msg
end

core.unregister_chatcommand("spawnentity")
core.register_chatcommand("summon", cmd)
