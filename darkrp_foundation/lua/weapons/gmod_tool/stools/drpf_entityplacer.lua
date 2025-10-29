TOOL.Category = "DarkRP Foundation"
TOOL.Name = "Entity Placer"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
if( SERVER ) then
	concommand.Add( "drpf_stoolcmd_entityclass", function( ply, cmd, args )
		if( args[1] ) then
			ply:SetNWString( "drpf_stool_entityclass", args[1] )
		end
	end )
end

function TOOL:LeftClick( trace )
	if( !trace.HitPos || IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not DRPF_Functions.HasAdminAccess( ply ) ) then
		DarkRP.notify( ply, 1, 2, "You don't have permission to use this tool." )
		return
	end
	
	local EntClassTable = DarkRPFoundation.DEVCONFIG.EntityTypes[ply:GetNWString( "drpf_stool_entityclass" )]
	if( EntClassTable ) then
		local DRPFEnt = ents.Create( ply:GetNWString( "drpf_stool_entityclass" ) )
		if( !IsValid( DRPFEnt ) ) then
			DarkRP.notify( ply, 1, 2, "Invalid Entity type, choose a valid one from the tool menu." )
			return
		end
		DRPFEnt:SetPos( trace.HitPos )
		local DRPFEntAngles = DRPFEnt:GetAngles()
		local PlayerAngle = ply:GetAngles()
		if( EntClassTable.AngleToSurface == true ) then
			DRPFEnt:SetAngles( trace.HitNormal:Angle() )
		elseif( EntClassTable.AngleToPlayer == true ) then
			DRPFEnt:SetAngles( Angle( DRPFEntAngles.p, PlayerAngle.y+180, DRPFEntAngles.r ) )
		end
		DRPFEnt:Spawn()
		
		DarkRP.notify( ply, 1, 2, "Entity succesfully placed." )
		ply:ConCommand( "drpf_saveentpositions" )
	else
		DarkRP.notify( ply, 1, 2, "Invalid Entity type, choose a valid one from the tool menu." )
	end
end
 
function TOOL:RightClick( trace )
	if( !trace.HitPos ) then return false end
	if( !IsValid( trace.Entity ) or trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not DRPF_Functions.HasAdminAccess( ply ) ) then
		DarkRP.notify( ply, 1, 2, "You don't have permission to use this tool." )
		return
	end
	
	if( DarkRPFoundation.DEVCONFIG.EntityTypes[trace.Entity:GetClass()] ) then
		trace.Entity:Remove()
		DarkRP.notify( ply, 1, 2, "Entity succesfully removed." )
		ply:ConCommand( "drpf_saveentpositions" )
	else
		DarkRP.notify( ply, 1, 2, "You can only use this tool to remove/create an Entity." )
		return false
	end
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "Entity Type", Description = "Places and entities from DarkRP Foundation and saves its position. LeftClick - Place. RightClick - Remove." })
 
	local combo = panel:AddControl( "ComboBox", { Label = "Entity Type", ConVar = "testcommand" } )
	for k, v in pairs( DarkRPFoundation.DEVCONFIG.EntityTypes ) do
		combo:AddOption( v.PrintName, { drpf_stoolcmd_entityclass = k } )
	end
end