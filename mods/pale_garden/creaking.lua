-- Creaking Mob - O Rangedor do Pale Garden
-- Versão simplificada usando apenas API básica do Minetest

-- Define a entidade Creaking
minetest.register_entity("pale_garden:creaking", {
    initial_properties = {
        hp_max = 1,
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.7, 0.0, -0.7, 0.7, 2.7, 0.7}, -- Tamanho Iron Golem, tocando o chão
        visual = "mesh",
        mesh = "creaking.x", -- Modelo correto do Creaking
        textures = {"creaking.png"},
        visual_size = {x=20, y=20}, -- Tamanho padrão (modelo já vem no tamanho certo)
        makes_footstep_sound = true,
        stepheight = 1.1,
        automatic_rotate = 0, -- Desativa rotação automática
    },
    
    -- Variáveis do mob
    state = "stand",
    timer = 0,
    attack_timer = 0,
    frozen = false,
    target = nil,
    
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})
        self.timer = 0
        self.attack_timer = 0

        -- Corrige posição vertical (ajuste fino)
        local pos = self.object:get_pos()
        if pos then
            pos.y = pos.y - 3.5 -- Ajuste pra modelo grande
            self.object:set_pos(pos)
        end
    end,
    
    -- Comportamento principal
    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        self.attack_timer = self.attack_timer + dtime
        
        -- Atualiza a cada 0.1 segundos
        if self.timer < 0.1 then
            return
        end
        self.timer = 0
        
        local pos = self.object:get_pos()
        if not pos then return end
        
        -- Procura jogadores próximos
        local players = minetest.get_connected_players()
        local closest_player = nil
        local closest_dist = 16
        
        for _, player in ipairs(players) do
            local player_pos = player:get_pos()
            local dist = vector.distance(pos, player_pos)
            
            if dist < closest_dist then
                closest_player = player
                closest_dist = dist
            end
        end
        
        -- Se não há jogador próximo, fica parado
        if not closest_player then
            self.object:set_velocity({x=0, y=0, z=0})
            return
        end
        
        -- Verifica se o jogador está olhando para o Creaking
        local player_pos = closest_player:get_pos()
        local player_look = closest_player:get_look_dir()
        
        -- Vetor do jogador para o Creaking
        local to_creaking = vector.subtract(pos, player_pos)
        local dist = vector.length(to_creaking)
        
        if dist > 0 then
            to_creaking = vector.normalize(to_creaking)
            
            -- Produto escalar para verificar se está olhando
            local dot = vector.dot(player_look, to_creaking)
            
            -- Se o jogador está olhando (dot > 0.6), CONGELA
            if dot > 0.6 then
                self.frozen = true
                self.object:set_velocity({x=0, y=0, z=0})
                self.object:set_animation({x=0, y=40}, 0, 0, true)
                return
            end
        end
        
        -- Se não está sendo olhado, se move em direção ao jogador
        self.frozen = false
        
        if dist > 1.5 then
            -- Move em direção ao jogador
            local dir = vector.direction(pos, player_pos)
            local vel = vector.multiply(dir, 1.0)
            vel.y = self.object:get_velocity().y -- Mantém velocidade Y (gravidade)
            self.object:set_velocity(vel)
            
            -- Rotaciona para o jogador (corrigido)
            local yaw = math.atan2(dir.z, dir.x) + math.pi/2
            self.object:set_yaw(yaw)
            
            -- Animação de andar
            self.object:set_animation({x=40, y=60}, 30, 0, true)
        else
            -- Próximo o suficiente para atacar
            if self.attack_timer > 1.0 then
                self.attack_timer = 0
                
                -- Causa dano ao jogador
                closest_player:set_hp(closest_player:get_hp() - 2)
                
                -- Animação de ataque
                self.object:set_animation({x=90, y=110}, 50, 0, false)
            end
        end
    end,
    
    -- Invulnerável a dano
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        -- Não recebe dano
        return true
    end,
    
    -- Remove quando muito longe
    get_staticdata = function(self)
        return ""
    end,
})

-- Spawn do Creaking à noite no Pale Garden
minetest.register_abm({
    label = "Creaking Spawn",
    nodenames = {"pale_garden:pale_moss_block"},
    interval = 60,
    chance = 100,
    action = function(pos, node)
        -- Só spawna à noite
        local time = minetest.get_timeofday()
        if time < 0.2 or time > 0.8 then
            return
        end
        
        -- Verifica se já tem Creaking próximo
        local objs = minetest.get_objects_inside_radius(pos, 32)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "pale_garden:creaking" then
                return -- Já tem um
            end
        end
        
        -- Verifica se a posição acima está livre
        local above = {x=pos.x, y=pos.y+1, z=pos.z}
        if minetest.get_node(above).name == "air" then
            -- Spawna o Creaking
            minetest.add_entity(above, "pale_garden:creaking")
        end
    end,
})

-- Registra "ovo" de spawn para modo criativo
minetest.register_craftitem("pale_garden:creaking_spawn_egg", {
    description = "Ovo de Spawn do Rangedor",
    inventory_image = "spawn_egg_creaking.png",
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.above
            minetest.add_entity(pos, "pale_garden:creaking")
            if not minetest.is_creative_enabled(placer:get_player_name()) then
                itemstack:take_item()
            end
        end
        return itemstack
    end,
})

minetest.log("action", "[Pale Garden] Creaking registrado!")
