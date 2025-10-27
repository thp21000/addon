local MODULE = GAS.Logging:MODULE()

MODULE.Category = "ToBadForYou"
MODULE.Name     = "Realistic Handcuffs"
MODULE.Colour   = Color(0,0,255)

MODULE:Hook("RHC_restrain","rhc_toggle_restrain",function(vic, handcuffer)
	local LogText = "cuffed"
	if !vic.Restrained then
		LogText = "uncuffed"
	end
	MODULE:Log(GAS.Logging:FormatPlayer(handcuffer) .. " " .. LogText .. " " .. GAS.Logging:FormatPlayer(vic))
end)
		
MODULE:Hook("RHC_jailed","rhc_jailed_player",function(vic, jailer, time, reason)
	MODULE:Log(GAS.Logging:FormatPlayer(jailer) .. " jailed " .. GAS.Logging:FormatPlayer(vic) .. " for " .. time .. " seconds, reason: " .. reason)
end)
		
MODULE:Hook("RHC_confis_weapon","rhc_confis_w",function(vic, confis, wep)
	MODULE:Log(GAS.Logging:FormatPlayer(confis) .. " confiscated a " .. wep .. " from " .. GAS.Logging:FormatPlayer(vic) .. ".")
end)
		
MODULE:Hook("RHC_confis_item","rhc_confis_i",function(vic, confis, item)
	MODULE:Log(GAS.Logging:FormatPlayer(confis) .. " confiscated a " .. item .. " from " .. GAS.Logging:FormatPlayer(vic) .. ".")
end)

GAS.Logging:AddModule(MODULE)
