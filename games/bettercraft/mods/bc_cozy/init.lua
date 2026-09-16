-- ===================================================
-- MOD: cozy (BetterCraft / Luanti)
-- Estado Default: DESENABLED
-- Commands: /cozy <on|off|toggle|sit|lay>
-- Installation directory: games/bettercraft/mods/cozy
-- ===================================================

local cozy_enabled = false
local sitting_players = {}

-- Registra command /cozy
minetest.register_chatcommand("cozy", {
    params = "<on|off|toggle|sit|lay>",
    description = "Gerencia o modo aconchegante/cozy for sentar e deitar",
    privs = { interact = true },
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found." end

        param = param and param:lower():trim() or ""

        if param == "on" then
            cozy_enabled = true
            minetest.chat_send_all("[Cozy] O sistema Cozy foi ENABLED no server!")
            return true, "[Cozy] Sistema enabled with success. Use /cozy sit for sentar."

        elseif param == "off" then
            cozy_enabled = false
            -- Levanta todos os playeres sentados
            for p_name, _ in pairs(sitting_players) do
                local p = minetest.get_player_by_name(p_name)
                if p then
                    p:set_physics_override({ speed = 1, jump = 1 })
                    sitting_players[p_name] = nil
                end
            end
            minetest.chat_send_all("[Cozy] O sistema Cozy foi DESENABLED no server.")
            return true, "[Cozy] Sistema desenabled."

        elseif param == "toggle" then
            if cozy_enabled then
                return minetest.registered_chatcommands["cozy"].func(name, "off")
            else
                return minetest.registered_chatcommands["cozy"].func(name, "on")
            end

        elseif param == "sit" or param == "" then
            if not cozy_enabled then
                return false, "[Cozy] O sistema is DESENABLED no server. Use '/cozy on' primeiro."
            end

            if sitting_players[name] then
                -- Se ja estiver sentado, levanta
                player:set_physics_override({ speed = 1, jump = 1 })
                sitting_players[name] = nil
                return true, "[Cozy] Voce se levantou."
            else
                -- Sentar
                player:set_physics_override({ speed = 0, jump = 0 })
                sitting_players[name] = true
                return true, "[Cozy] Voce se sentou! Enter '/cozy sit' novamente for levantar."
            end

        elseif param == "lay" then
            if not cozy_enabled then
                return false, "[Cozy] O sistema is DESENABLED no server. Use '/cozy on' primeiro."
            end
            player:set_physics_override({ speed = 0, jump = 0 })
            sitting_players[name] = true
            return true, "[Cozy] Voce se deitou for descansar. Enter '/cozy sit' for levantar."

        else
            return false, "Command invalid! Opcoes: /cozy on | /cozy off | /cozy sit | /cozy lay (Status: " .. (cozy_enabled and "ENABLED" or "DESENABLED") .. ")"
        end
    end,
})

-- Limpa estado do player ao desconectar
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    sitting_players[name] = nil
end)

minetest.log("action", "[cozy] Mod Cozy loaded in games/bettercraft/mods/cozy (Default: DESENABLED).")
