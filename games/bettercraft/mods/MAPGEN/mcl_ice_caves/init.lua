local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath .. "/nodes.lua")

if core.global_exists("mcl_levelgen")
	and (mcl_levelgen.levelgen_enabled or mcl_levelgen.enable_ersatz) then
	mcl_levelgen.register_levelgen_script(modpath .. "/lg_register.lua")
end
