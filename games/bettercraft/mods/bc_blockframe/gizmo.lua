--------------------------------------------------
-- BLOCKFRAME GIZMO SYSTEM (FIXED V5)
--------------------------------------------------
bc_blockframe.gizmo_entities = {}
bc_blockframe.active_parent = nil

-- Valores default (podem ser sobrescritos pelo step no command)
bc_blockframe.gizmo_step = {
    move = 0.1,
    rotate = math.rad(15),
    scale = 0.1
}

--------------------------------------------------
-- SAFE GET PARENT
--------------------------------------------------
local function get_parent(self)
    if self.parent and self.parent:get_luaentity() then
        return self.parent
    end
    return nil
end

--------------------------------------------------
-- REMOVE GIZMOS
--------------------------------------------------
function bc_blockframe.remove_gizmos(parent_obj)
    if not parent_obj then return end
    local list = bc_blockframe.gizmo_entities[parent_obj]
    if list then
        for _, obj in ipairs(list) do
            if obj and obj:get_luaentity() then
                obj:remove()
            end
        end
    end
    bc_blockframe.gizmo_entities[parent_obj] = nil
    if bc_blockframe.active_parent == parent_obj then
        bc_blockframe.active_parent = nil
    end
end

--------------------------------------------------
-- REMOVE ALL GIZMOS
--------------------------------------------------
local function remove_all_gizmos()
    for parent, _ in pairs(bc_blockframe.gizmo_entities) do
        bc_blockframe.remove_gizmos(parent)
    end
end

--------------------------------------------------
-- SPAWN AXIS GIZMOS
--------------------------------------------------
local function spawn_axis_gizmos(parent_obj)
    remove_all_gizmos()
    bc_blockframe.active_parent = parent_obj

    local pos = parent_obj:get_pos()
    local entities = {}

    local gizmos = {
        {type = "move", axis = "x", tex = "bc_blockframe_gizmo_move_x.png", off = {x = 1.5, y = 0, z = 0}},
        {type = "move", axis = "y", tex = "bc_blockframe_gizmo_move_y.png", off = {x = 0, y = 1.5, z = 0}},
        {type = "move", axis = "z", tex = "bc_blockframe_gizmo_move_z.png", off = {x = 0, y = 0, z = 1.5}},
        {type = "rotate", axis = "x", tex = "bc_blockframe_gizmo_rotate.png", off = {x = -1.5, y = 0, z = 0}},
        {type = "rotate", axis = "y", tex = "bc_blockframe_gizmo_rotate.png", off = {x = 0, y = -1.5, z = 0}},
        {type = "rotate", axis = "z", tex = "bc_blockframe_gizmo_rotate.png", off = {x = 0, y = 0, z = -1.5}},
        {type = "scale", axis = "x", tex = "bc_blockframe_gizmo_scale.png", off = {x = 2.5, y = 0, z = 0}},
        {type = "scale", axis = "y", tex = "bc_blockframe_gizmo_scale.png", off = {x = 0, y = 2.5, z = 0}},
        {type = "scale", axis = "z", tex = "bc_blockframe_gizmo_scale.png", off = {x = 0, y = 0, z = 2.5}}
    }

    for _, data in ipairs(gizmos) do
        local obj = minetest.add_entity(vector.add(pos, data.off), "bc_blockframe:gizmo_axis")
        if obj then
            local ent = obj:get_luaentity()
            ent.parent = parent_obj
            ent.gizmo_type = data.type
            ent.axis = data.axis
            ent.offset = data.off

            obj:set_properties({
                visual = "sprite",
                textures = {data.tex},
                visual_size = {x = 0.7, y = 0.7},
                glow = 10,
                physical = false,
                pointable = true,
                use_texture_alpha = true
            })
            table.insert(entities, obj)
        end
    end
    bc_blockframe.gizmo_entities[parent_obj] = entities
end

--------------------------------------------------
-- CENTER GIZMO
--------------------------------------------------
function bc_blockframe.spawn_center(parent_obj)
    if not parent_obj then return end
    bc_blockframe.remove_gizmos(parent_obj)
    local pos = parent_obj:get_pos()
    local entities = {}
    local center = minetest.add_entity(pos, "bc_blockframe:gizmo_center")
    if center then
        center:get_luaentity().parent = parent_obj
        table.insert(entities, center)
    end
    bc_blockframe.gizmo_entities[parent_obj] = entities
end

minetest.register_entity("bc_blockframe:gizmo_center", {
    initial_properties = {
        visual = "sprite",
        textures = {"bc_blockframe_gizmo_center.png"},
        visual_size = {x = 0.3, y = 0.3},
        glow = 8,
        physical = false,
        pointable = true,
        use_texture_alpha = true
    },
    on_punch = function(self)
        local parent = get_parent(self)
        if not parent then return end
        if bc_blockframe.active_parent == parent then
            bc_blockframe.remove_gizmos(parent)
        else
            spawn_axis_gizmos(parent)
        end
    end,
    on_step = function(self)
        local parent = get_parent(self)
        if not parent then
            self.object:remove()
            return
        end
        self.object:set_pos(parent:get_pos())
    end
})

--------------------------------------------------
-- AXIS GIZMO
--------------------------------------------------
minetest.register_entity("bc_blockframe:gizmo_axis", {
    on_punch = function(self)
        self.object:set_hp(1000)
        local parent = get_parent(self)
        if not parent then return end
        local ent = parent:get_luaentity()
        if not ent then return end

        if self.gizmo_type == "move" then
            local step = bc_blockframe.gizmo_step.move
            local pos = parent:get_pos()
            pos[self.axis] = pos[self.axis] + step
            parent:set_pos(pos)
            ent.args.pos = pos
        elseif self.gizmo_type == "rotate" then
            local step = bc_blockframe.gizmo_step.rotate
            local rot = parent:get_rotation() or {x = 0, y = 0, z = 0}
            rot[self.axis] = rot[self.axis] + step
            parent:set_rotation(rot)
            ent.args.rotate = {x = math.deg(rot.x), y = math.deg(rot.y), z = math.deg(rot.z)}
        elseif self.gizmo_type == "scale" then
            local step = bc_blockframe.gizmo_step.scale
            local props = parent:get_properties()
            local size = table.copy(props.visual_size or {x = 0.5, y = 0.5, z = 0.5})
            if self.axis == "z" then
                size.x = size.x + step
                size.y = size.y + step
                size.z = size.z + step
            else
                size[self.axis] = size[self.axis] + step
            end
            parent:set_properties({visual_size = size})
            ent.args.size = size
        end
    end,

    on_rightclick = function(self)
        local parent = get_parent(self)
        if not parent then return end
        local ent = parent:get_luaentity()
        if not ent then return end

        if self.gizmo_type == "move" then
            local step = bc_blockframe.gizmo_step.move
            local pos = parent:get_pos()
            pos[self.axis] = pos[self.axis] - step
            parent:set_pos(pos)
            ent.args.pos = pos
        elseif self.gizmo_type == "rotate" then
            local step = bc_blockframe.gizmo_step.rotate
            local rot = parent:get_rotation() or {x = 0, y = 0, z = 0}
            rot[self.axis] = rot[self.axis] - step
            parent:set_rotation(rot)
            ent.args.rotate = {x = math.deg(rot.x), y = math.deg(rot.y), z = math.deg(rot.z)}
        elseif self.gizmo_type == "scale" then
            local step = bc_blockframe.gizmo_step.scale
            local props = parent:get_properties()
            local size = table.copy(props.visual_size or {x = 0.5, y = 0.5, z = 0.5})
            if self.axis == "z" then
                size.x = math.max(0.1, size.x - step)
                size.y = math.max(0.1, size.y - step)
                size.z = math.max(0.1, size.z - step)
            else
                size[self.axis] = math.max(0.1, size[self.axis] - step)
            end
            parent:set_properties({visual_size = size})
            ent.args.size = size
        end
    end,

    on_step = function(self)
        local parent = get_parent(self)
        if not parent then
            self.object:remove()
            return
        end
        local base = parent:get_pos()
        self.object:set_pos(vector.add(base, self.offset))
    end
})

--------------------------------------------------
-- CHAT COMMAND (TOGGLE & STEP)
--------------------------------------------------
minetest.register_chatcommand("bc_blockframe_gizmos", {
    description = "Toggle ALL gizmos or change step (ex: /bc_blockframe_gizmos step=0.5)",
    params = "[step=N]",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false end

        local args = bc_blockframe.parse_args(param)
        local new_step = tonumber(args.step)

        -- Se o user forneceu um step, atualiza os valuees globais dos gizmos
        if new_step then
            bc_blockframe.gizmo_step.move = new_step
            bc_blockframe.gizmo_step.scale = new_step
            -- For rotation, convert degrees to radians (assuming the user enters degrees for convenience)
            -- Ou se for um value muito pequeno, pode ser radianos, mas 15 graus é o default.
            -- Vamos tratar como graus se for > 1, ou manter como value direto se for pequeno.
            if new_step >= 1 then
                bc_blockframe.gizmo_step.rotate = math.rad(new_step)
            else
                bc_blockframe.gizmo_step.rotate = new_step -- assume radianos se for decimal pequeno
            end
            return true, "Step dos gizmos atualizado for: " .. new_step
        end

        -- Lógica normal de Toggle
        local any_active = false
        for parent, _ in pairs(bc_blockframe.gizmo_entities) do
            any_active = true
            break
        end

        if any_active then
            remove_all_gizmos()
            bc_blockframe.gizmo_entities = {}
            bc_blockframe.active_parent = nil
            return true, "All gizmos removed."
        end

        local pos = player:get_pos()
        local objects = minetest.get_objects_inside_radius(pos, 15)
        local shown = 0
        for _, obj in ipairs(objects) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "bc_blockframe:placed" then
                bc_blockframe.spawn_center(obj)
                shown = shown + 1
            end
        end
        return true, "Centers mostrados: " .. shown
    end
})
