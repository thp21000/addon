--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Realistic Handcuff System", -- Name
	"rhandcuff", 
	Color(0,0,255), -- Color
	function() -- Check
		return true
	end,
	true
)

mLogs.addCategoryDefinitions("rhandcuff", {
	cuffing = function(data) return mLogs.doLogReplace({"^player1", "^action", "^player2"},data) end,
	jailing = function(data) return mLogs.doLogReplace({"^player1", "jailed", "^player2", "for", "^time", "seconds, reason:", "^reason"},data) end,
	confiscation = function(data) return mLogs.doLogReplace({"^player1", "confiscated a", "^item", "from", "^player2"},data) end,
})