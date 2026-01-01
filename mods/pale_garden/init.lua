-- Pale Garden Mod para Mineclonia/VoxeLibre
-- Adiciona o bioma Pale Garden e o mob Creaking

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- IMPORTANTE: Inicializa o namespace ANTES de carregar os outros arquivos
pale_garden = {}

-- Carrega os componentes do mod
dofile(modpath .. "/pale_oak.lua")      -- Árvores e blocos Pale Oak
dofile(modpath .. "/pale_biome.lua")    -- Bioma Pale Garden
dofile(modpath .. "/resin.lua")         -- Sistema de seiva (resin)
dofile(modpath .. "/creaking.lua")      -- Mob Creaking
dofile(modpath .. "/creaking_heart.lua") -- Bloco Creaking Heart

minetest.log("action", "[Pale Garden] Mod carregado com sucesso!")
minetest.log("action", "[Pale Garden] Bioma Pale Garden, Pale Oak e Creaking adicionados!")
