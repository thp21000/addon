concommand.Add( "drpf_saveentpositions", function( ply, cmd, args )
	if( DRPF_Functions.HasAdminAccess( ply ) ) then
		local Entities = {}
		for k, v in pairs( DarkRPFoundation.DEVCONFIG.EntityTypes ) do
			for key, ent in pairs( ents.FindByClass( k ) ) do
				local EntVector = string.Explode(" ", tostring(ent:GetPos()))
				local EntAngles = string.Explode(" ", tostring(ent:GetAngles()))
				
				local EntTable = {
					Class = k,
					Position = ""..(EntVector[1])..";"..(EntVector[2])..";"..(EntVector[3])..";"..(EntAngles[1])..";"..(EntAngles[2])..";"..(EntAngles[3])..""
				}
				
				table.insert( Entities, EntTable )
			end
		end
		
		file.Write("darkrpfoundation/saved_ents/".. string.lower(game.GetMap()) ..".txt", util.TableToJSON( Entities ), "DATA")
		DarkRP.notify( ply, 1, 2, "Entity positions updated." )
	else
		DarkRP.notify( ply, 1, 2, "You don't have permission to use this command." )
	end
end )

concommand.Add( "drpf_clearentpositions", function( ply, cmd, args )
	if( DRPF_Functions.HasAdminAccess( ply ) ) then
		for k, v in pairs( ents.GetAll() ) do
			if( DarkRPFoundation.DEVCONFIG.EntityTypes[v:GetClass()] ) then
				v:Remove()
			end
			
			if( file.Exists( "darkrpfoundation/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
				file.Delete( "darkrpfoundation/saved_ents/".. string.lower(game.GetMap()) ..".txt" )
			end
		end
	else
		DarkRP.notify( ply, 1, 2, "You don't have permission to use this command." )
	end
end )

hook.Add( "InitPostEntity", "DarkRPFoundationHooks_InitPostEntity_LoadNPCs", function()	
	if not file.IsDir("darkrpfoundation/saved_ents", "DATA") then
		file.CreateDir("darkrpfoundation/saved_ents", "DATA")
	end
	
	local Entities = {}
	if( file.Exists( "darkrpfoundation/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
		Entities = ( util.JSONToTable( file.Read( "darkrpfoundation/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) )
	end
	
	if( table.Count( Entities ) > 0 ) then
		for k, v in pairs( Entities ) do
			if( DarkRPFoundation.DEVCONFIG.EntityTypes[v.Class] ) then
				local ThePosition = string.Explode( ";", v.Position )
				
				local TheVector = Vector(ThePosition[1], ThePosition[2], ThePosition[3])
				local TheAngle = Angle(tonumber(ThePosition[4]), ThePosition[5], ThePosition[6])
				local NewEnt = ents.Create( v.Class )
				NewEnt:SetPos(TheVector)
				NewEnt:SetAngles(TheAngle)
				NewEnt:Spawn()
			else
				Entities[k] = nil
			end
		end
		
		print( "[DarkRPFoundation] " .. table.Count( Entities ) .. " saved Entities were spawned." )
	else
		print( "[DarkRPFoundation] No saved Entities were spawned." )
	end
end )

hook.Add( "PostCleanupMap", "DarkRPFoundationHooks_PostCleanupMap_LoadNPCs", function()	
	if not file.IsDir("darkrpfoundation/saved_ents", "DATA") then
		file.CreateDir("darkrpfoundation/saved_ents", "DATA")
	end
	
	local Entities = {}
	if( file.Exists( "darkrpfoundation/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
		Entities = ( util.JSONToTable( file.Read( "darkrpfoundation/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) )
	end
	
	if( table.Count( Entities ) > 0 ) then
		for k, v in pairs( Entities ) do
			if( DarkRPFoundation.DEVCONFIG.EntityTypes[v.Class] ) then
				local ThePosition = string.Explode( ";", v.Position )
				
				local TheVector = Vector(ThePosition[1], ThePosition[2], ThePosition[3])
				local TheAngle = Angle(tonumber(ThePosition[4]), ThePosition[5], ThePosition[6])
				local NewEnt = ents.Create( v.Class )
				NewEnt:SetPos(TheVector)
				NewEnt:SetAngles(TheAngle)
				NewEnt:Spawn()
			else
				Entities[k] = nil
			end
		end
		
		print( "[DarkRPFoundation] " .. table.Count( Entities ) .. " saved Entities were spawned." )
	else
		print( "[DarkRPFoundation] No saved Entities were spawned." )
	end
end )