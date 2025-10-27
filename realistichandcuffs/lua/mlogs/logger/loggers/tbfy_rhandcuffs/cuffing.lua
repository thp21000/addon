--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "rhandcuff"

mLogs.addLogger("Cuffing","cuffing",category)
mLogs.addHook("RHC_restrain", category, function(vic,handcuffer)
	if(not IsValid(vic) or not IsValid(handcuffer))then return end
	local LogText = "cuffed"
	if !vic.Restrained then
		LogText = "uncuffed"
	end

	mLogs.log("cuffing", category, {player1=mLogs.logger.getPlayerData(handcuffer),action=LogText,player2=mLogs.logger.getPlayerData(vic),a=true})
end)