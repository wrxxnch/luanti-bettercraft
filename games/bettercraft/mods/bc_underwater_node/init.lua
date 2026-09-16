-- --[[
--     underwater_api.lua
--     ----------------------------------------------------------------
--     API genérica for "plantas/corais subaquáticos" no estilo do
--     plantlike_rooted do BetterCraft/Mineclonia, funcionando em cima de
--     uma lista de blocks "ground" curada e extensível — not travada em
--     7 blocks fixos, mas também without tentar cobrir literalmente TODO
--     node do jogo (this quebra o motor, ver seção de limitação abaixo).

--     COMO USAR
--     ----------------------------------------------------------------
--     1) Registro manual (explícito):

--         core.register_node("meumod:coral_vermelho", {
--             description = S("Coral Vermelho"),
--             drawtype    = "mesh",
--             mesh        = "coral_vermelho.obj",
--             tiles       = {"coral_vermelho.png"},
--             groups      = {handy = 1, oddly_breakable_by_hand = 1},
--             -- outros campos normais do node...
--         })

--         underwater_api.register_bc_underwater_node("meumod:coral_vermelho")

--     2) Registro automático via group (mais simples, "zero-config"):

--         core.register_node("meumod:coral_azul", {
--             description = S("Coral Azul"),
--             drawtype    = "mesh",
--             mesh        = "coral_azul.obj",
--             tiles       = {"coral_azul.png"},
--             groups      = {
--                 handy = 1,
--                 oddly_breakable_by_hand = 1,
--                 bc_underwater_node = 1,   -- <<< é só this!
--             },
--         })

--     Em ambos os casos, quando o player colocar o node with água (fonte)
--     logo acima do ponto de colocação, o node vira automaticamente a
--     versão "enraizada" (plantlike_rooted) usando o block que está
--     embaixo como "ground", seja ele qual for.

--     LIMITAÇÃO TÉCNICA (inerente ao motor, not dá pra contornar)
--     ----------------------------------------------------------------
--     O drawtype "plantlike_rooted" precisa ter o tile do "ground" definido
--     no registro do node (not dá pra change a texture em tempo real por
--     position). O Luanti também tem um limite RÍGIDO de 32767 IDs de node
--     no total (protocolo). Jogos como Mineclonia/BetterCraft já registram
--     thousands de nodes (stairs, slabs, colors, variants de wood...).

--     Therefore this script does NOT scan "every node already registered" (this
--     estourava o limite, gerando 1 variante enraizada por planta X por
--     CADA node existente, incluindo stairs, painéis, portas etc.).

--     Em vez disso, ele usa uma LISTA DE CHÃOS PERMITIDOS (curada e
--     filtrada: só blocks sólidos "cubo cheio", without decoractives), with:
--       - uma lista default de blocks comuns (pedra, terra, areia...)
--       - detecção automática de aliases comuns entre jogos (MTG,
--         Mineclonia, BetterCraft) por nome
--       - underwater_api.register_surface("mod:node") for you add
--         qualquer block extra manualmente, without limite de "precisar ser
--         só os 7 originais"
--       - um teto de segurança (MAX_SURFACES) que impede estourar o
--         limite do motor, avisando no log quais chãos foram ignorados
-- ]]--

-- underwater_api = underwater_api or {}

-- local S = core.get_translator(core.get_current_modname())

-- -- Teto de segurança: no máximo N chãos por planta registrada.
-- -- Ajuste with cuidado — cada ground a mais = 1 node novo POR planta.
-- local MAX_SURFACES = 24

-- -- nodes registrados manualmente, aguardando processamento
-- local pending = {}

-- -- Chãos aceitos por default (nomes candidatos; só entram se existirem
-- -- actually no jogo loaded). Cubra os principais de MTG/Mineclonia/
-- -- BetterCraft. Adicione mais with underwater_api.register_surface().
-- local default_surface_candidates = {
-- 	"mcl_core:stone", "mcl_core:dirt", "mcl_core:sand", "mcl_core:gravel",
-- 	"mcl_core:cobble", "mcl_core:mossycobble", "mcl_core:granite",
-- 	"mcl_core:diorite", "mcl_core:andesite", "mcl_core:redsand",
-- 	"mcl_deepslate:deepslate", "mcl_nether:netherrack", "mcl_end:end_stone",
-- 	"mcl_core:clay",
-- 	"default:stone", "default:dirt", "default:sand", "default:gravel",
-- 	"default:cobble", "default:desert_sand",
-- }

-- -- Conjunto (set) de chãos efetivamente actives; preenchido em
-- -- core.register_on_mods_loaded, quando todos os nodes já existem.
-- local active_surfaces = {}
-- local extra_surfaces = {} -- added via register_surface()

-- -- Public call nº1: registro explícito de planta subaquática
-- function underwater_api.register_bc_underwater_node(name, def)
-- 	def = def or core.registered_nodes[name]
-- 	if not def then
-- 		core.log("error", "[underwater_api] Node does not exist: " .. tostring(name))
-- 		return
-- 	end
-- 	pending[name] = def
-- end

-- -- Public call nº2: add um block extra como "ground" valid
-- -- (ex: underwater_api.register_surface("mymod:basalto"))
-- function underwater_api.register_surface(node_name)
-- 	table.insert(extra_surfaces, node_name)
-- end

-- -- Considera "ground" valid: sólido, cubo cheio, not líquido, without
-- -- variants decorativas (escada/laje/porta/etc.), not uma variante
-- -- enraizada gerada por nós mesmos (evita recursão infinita)
-- local DECORATIVE_PATTERNS = {
-- 	"stair", "slab", "wall", "fence", "door", "trapdoor", "carpet",
-- 	"pane", "railing", "ladder", "sign", "torch", "button", "lever",
-- 	"pressure_plate", "bed", "chest", "stripped", "_top", "_side",
-- 	"glazed", "corner", "railroad",
-- }

-- local function is_decorative_name(node_name)
-- 	for _, pattern in ipairs(DECORATIVE_PATTERNS) do
-- 		if node_name:find(pattern, 1, true) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- local function is_valid_surface(node_name, node_def)
-- 	if node_name == "air" or node_name == "ignore" then return false end
-- 	if not node_def then return false end
-- 	if node_def.liquidtype and node_def.liquidtype ~= "none" then return false end
-- 	if node_def.walkable == false then return false end
-- 	if node_def.drawtype ~= "normal" then return false end -- só cubo cheio
-- 	if node_def.drawtype == "plantlike_rooted" then return false end
-- 	if node_name:find("_rooted_", 1, true) then return false end
-- 	if is_decorative_name(node_name) then return false end
-- 	return true
-- end

-- -- Monta a lista final de chãos actives, respeitando o teto de segurança
-- local function build_active_surfaces()
-- 	local candidates = {}
-- 	local seen = {}

-- 	local function add(name)
-- 		if seen[name] then return end
-- 		seen[name] = true
-- 		local def = core.registered_nodes[name]
-- 		if is_valid_surface(name, def) then
-- 			table.insert(candidates, name)
-- 		end
-- 	end

-- 	for _, name in ipairs(default_surface_candidates) do add(name) end
-- 	for _, name in ipairs(extra_surfaces) do add(name) end

-- 	if #candidates > MAX_SURFACES then
-- 		core.log("warning", string.format(
-- 			"[underwater_api] %d chãos candidatos, cortando for %d " ..
-- 			"(ajuste MAX_SURFACES se precisar de mais).",
-- 			#candidates, MAX_SURFACES))
-- 		for i = MAX_SURFACES + 1, #candidates do
-- 			candidates[i] = nil
-- 		end
-- 	end

-- 	for _, name in ipairs(candidates) do
-- 		active_surfaces[name] = true
-- 	end
-- end

-- -- Deixa o nome seguro for compor o identificador do node novo
-- local function sanitize(name)
-- 	return (name:gsub("[:%s]", "_"))
-- end

-- local function setup_bc_underwater_node(name, def)
-- 	-- 1) Sobrescreve o on_place do node original (funciona mesmo se
-- 	--    o node já tiver sido registrado por outro mod)
-- 	core.override_item(name, {
-- 		on_place = function(itemstack, placer, pointed_thing)
-- 			if pointed_thing.type ~= "node" then
-- 				return core.item_place(itemstack, placer, pointed_thing)
-- 			end

-- 			local pos_under = pointed_thing.under
-- 			local pos_above = pointed_thing.above
-- 			local node_under = core.get_node(pos_under)
-- 			local node_above = core.get_node(pos_above)
-- 			local def_above = core.registered_nodes[node_above.name]

-- 			local tem_agua_em_cima = def_above
-- 				and core.get_item_group(node_above.name, "water") ~= 0
-- 				and def_above.liquidtype == "source"

-- 			if tem_agua_em_cima then
-- 				local rooted_name = name .. "_rooted_" .. sanitize(node_under.name)

-- 				if core.registered_nodes[rooted_name] then
-- 					core.set_node(pos_under, {name = rooted_name, param2 = 3})
-- 					if not core.is_creative_enabled(placer:get_player_name()) then
-- 						itemstack:take_item()
-- 					end
-- 					return itemstack
-- 				end
-- 				-- se not existe variante pra esse ground específico
-- 				-- (block raro/novo demais), cai no comportamento normal
-- 			end

-- 			return core.item_place(itemstack, placer, pointed_thing)
-- 		end,
-- 	})

-- 	-- 2) Gera as variants enraizadas só for os chãos da lista ativa
-- 	--    (curada + filtrada + with teto de segurança, ver build_active_surfaces)
-- 	for surface_name in pairs(active_surfaces) do
-- 		local surface_def = core.registered_nodes[surface_name]
-- 		if surface_def then
-- 			local rooted_name = name .. "_rooted_" .. sanitize(surface_name)

-- 			if not core.registered_nodes[rooted_name] then
-- 				core.register_node(":" .. rooted_name, {
-- 					drawtype        = "plantlike_rooted",
-- 					description     = def.description,
-- 					tiles           = surface_def.tiles,   -- texture do "ground"
-- 					special_tiles   = def.tiles or {"unknown_node.png"}, -- texture da planta/mesh
-- 					paramtype       = "light",
-- 					use_texture_alpha = def.use_texture_alpha or "clip",
-- 					paramtype2      = "meshoptions",
-- 					mesh            = def.mesh,
-- 					light_source    = def.light_source or 0,
-- 					groups          = {handy = 1, not_in_creative_inventory = 1, attached_node = 1},
-- 					drop            = name,
-- 					selection_box = {
-- 						type = "fixed",
-- 						fixed = {
-- 							{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- colisão do ground
-- 							{-0.4, 0.5, -0.4, 0.4, 1.3, 0.4},  -- colisão da planta
-- 						},
-- 					},
-- 					after_dig_node = function(pos)
-- 						core.set_node(pos, {name = surface_name})
-- 					end,
-- 				})
-- 			end
-- 		end
-- 	end
-- end

-- -- Roda só depois que TODOS os mods (do jogo/world) terminarem de
-- -- registrar seus nodes, pra pegar qualquer block possível como ground.
-- core.register_on_mods_loaded(function()
-- 	-- 1) monta a lista de chãos válidos (curada + filtrada + teto de segurança)
-- 	build_active_surfaces()

-- 	-- 2a) nodes registrados manualmente
-- 	for name, def in pairs(pending) do
-- 		setup_bc_underwater_node(name, def)
-- 	end

-- 	-- 2b) nodes registrados só via groups = {bc_underwater_node = 1}
-- 	for name, def in pairs(core.registered_nodes) do
-- 		if not pending[name] and core.get_item_group(name, "bc_underwater_node") == 1 then
-- 			setup_bc_underwater_node(name, def)
-- 		end
-- 	end
-- end)
