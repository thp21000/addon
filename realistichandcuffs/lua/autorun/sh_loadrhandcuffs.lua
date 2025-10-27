
print("////////////////////////////////////////////")
print("//                                        //")
print("//Loading Realistic Handcuffs System Files//")
print("//   www.gmodstore.com/scripts/view/2979  //")
print("//         Created by ToBadForYou         //")
print("//                                        //")
print("////////////////////////////////////////////")
if SERVER then
	include("tbfy_rhandcuffs/sh_rhandcuffs_config.lua")
	include("tbfy_rhandcuffs/sh_rhandcuffs.lua")
	include("tbfy_rhandcuffs/sv_rhandcuffs.lua")
	include("tbfy_rhandcuffs/sv_rhandcuffs_npc.lua")

	AddCSLuaFile("tbfy_rhandcuffs/sh_rhandcuffs_config.lua")
	AddCSLuaFile("tbfy_rhandcuffs/sh_rhandcuffs.lua")
	AddCSLuaFile("tbfy_rhandcuffs/cl_rhandcuffs.lua")
	AddCSLuaFile("tbfy_rhandcuffs/cl_rhandcuffs_npc.lua")
elseif CLIENT then
	include("tbfy_rhandcuffs/sh_rhandcuffs_config.lua")
	include("tbfy_rhandcuffs/sh_rhandcuffs.lua")
	include("tbfy_rhandcuffs/cl_rhandcuffs.lua")
	include("tbfy_rhandcuffs/cl_rhandcuffs_npc.lua")
end
