--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "rhandcuff"

mLogs.addLogger("Confiscation","confiscation",category)
mLogs.addHook("RHC_confis_weapon", category, function(vic,confis, wep)
	if(not IsValid(vic) or not IsValid(confis))then return end
	mLogs.log("confiscation", category, {player1=mLogs.logger.getPlayerData(confis),item=wep,player2=mLogs.logger.getPlayerData(vic),a=true})
end)
mLogs.addHook("RHC_confis_item", category, function(vic,confis, item)
	if(not IsValid(vic) or not IsValid(confis))then return end
	mLogs.log("confiscation", category, {player1=mLogs.logger.getPlayerData(confis),item=item,player2=mLogs.logger.getPlayerData(vic),a=true})
end)