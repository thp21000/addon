local function DrawServerBanner( X, Y )
	surface.SetMaterial( DarkRPFoundation.MATERIALS.ServerLogo )
	surface.SetDrawColor( 255, 255, 255 )
	local MatSize = 130
	surface.DrawTexturedRect( X, Y, MatSize, MatSize )
	
	draw.SimpleText( DarkRPFoundation.CONFIG.GENERAL.ServerName, "DarkRPFoundation_Font90", X+MatSize+25-1, Y+(MatSize/2)+1, Color( 0, 0, 0 ), 0, TEXT_ALIGN_CENTER )
	draw.SimpleText( DarkRPFoundation.CONFIG.GENERAL.ServerName, "DarkRPFoundation_Font90", X+MatSize+25, Y+(MatSize/2), Color( 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
end

DRPF_ATMPAGES = {}

DRPF_ATMPAGES["home"] = {
	DrawPage = function( ent, width, height )
		surface.SetDrawColor( 69, 111, 178, 100 )
		surface.DrawRect( 0, 0, width, height )
		
		surface.SetMaterial( DarkRPFoundation.MATERIALS.ServerLogo )
		surface.SetDrawColor( 255, 255, 255 )
		local MatSize = 350
		surface.DrawTexturedRect( (width/2)-(MatSize/2), (height/2)-(MatSize/2), MatSize, MatSize )
		
		draw.SimpleText( DarkRPFoundation.CONFIG.GENERAL.ServerName, "DarkRPFoundation_Font90", width/2-1, (height/2)+(MatSize/2)+15+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, 0 )
		draw.SimpleText( DarkRPFoundation.CONFIG.GENERAL.ServerName, "DarkRPFoundation_Font90", width/2, (height/2)+(MatSize/2)+15, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
	end
}

DRPF_ATMPAGES["myaccount"] = {
	DrawPage = function( ent, width, height )
		surface.SetDrawColor( 69, 111, 178, 100 )
		surface.DrawRect( 0, 0, width, height )
		
		DrawServerBanner( 25, 25 )
		
		surface.SetMaterial( DarkRPFoundation.MATERIALS.BankLogo )
		surface.SetDrawColor( 255, 255, 255 )
		local MatSize = 300
		surface.DrawTexturedRect( (width/2)-(MatSize/2), (height/2)-(MatSize/2), MatSize, MatSize )

		surface.SetFont( "DarkRPFoundation_Font65" )
		local PlyAccountKey = DRPFBANKING_Table.AccountType or 1
		local PlyAccountTable = DarkRPFoundation.CONFIG.ATM.AccountTypes[PlyAccountKey]
		local TextX, TextY = surface.GetTextSize( LocalPlayer():Nick() .. " - " .. PlyAccountTable.Title )
		surface.SetTextColor( 255, 255, 255 )
		surface.SetTextPos( (width/2)-(TextX/2), (height/2)+(MatSize/2)+25 )
		surface.DrawText( LocalPlayer():Nick() .. " - " )
		surface.SetTextColor( PlyAccountTable.DisplayColor )
		surface.DrawText( PlyAccountTable.Title )
		
		draw.SimpleText( DRPF_Functions.L( "atmEntBalance" ) .. " " .. DarkRP.formatMoney( math.Round(DRPFBANKING_Table.AccountBalance or 0) ), "DarkRPFoundation_Font65", width/2, (height/2)+(MatSize/2)+95, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
	end
}

DRPF_ATMPAGES["transactionlogs"] = {
	DrawPage = function( ent, width, height )
		surface.SetDrawColor( 69, 111, 178, 100 )
		surface.DrawRect( 0, 0, width, height )
		
		DrawServerBanner( 25, 25 )
		
		local TransactionLogs = DRPFBANKING_Table.TransactionLogs or {}
		table.SortByMember( TransactionLogs, "Date" )
		
		local Bars = 6
		for i = 1, Bars do
			if( TransactionLogs[i] ) then
				if( TransactionLogs[i].Amount > 0 ) then
					surface.SetDrawColor( 100, 200, 100, 255 )
				else
					surface.SetDrawColor( 200, 100, 100, 255 )
				end
				local BarSpacing = 10
				local HeightLeft = height-(25+130+50)-((width-(width*0.75))/2)
				local BarHeight = (HeightLeft-((Bars-1)*BarSpacing))/Bars
				surface.DrawRect( (width/2)-((width*0.75)/2), 25+130+50+((i-1)*(BarHeight+BarSpacing)), width*0.75, BarHeight )
				
				draw.SimpleText( os.date( "%H:%M:%S - %d/%m" , TransactionLogs[i].Date ), "DarkRPFoundation_Font35", ((width-(width*0.75))/2)+15, 25+130+50+((i-1)*(BarHeight+BarSpacing))+(BarHeight/2), Color( 0, 0, 0 ), 0, TEXT_ALIGN_CENTER )
				draw.SimpleText( TransactionLogs[i].Title, "DarkRPFoundation_Font35", width/2, 25+130+50+((i-1)*(BarHeight+BarSpacing))+(BarHeight/2), Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				if( TransactionLogs[i].Amount > 0 ) then
					draw.SimpleText( "+" .. DarkRP.formatMoney( math.Round(TransactionLogs[i].Amount) ), "DarkRPFoundation_Font40", width-((width-(width*0.75))/2)-15, 25+130+50+((i-1)*(BarHeight+BarSpacing))+(BarHeight/2), Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( DarkRP.formatMoney( math.Round(TransactionLogs[i].Amount) ), "DarkRPFoundation_Font40", width-((width-(width*0.75))/2)-15, 25+130+50+((i-1)*(BarHeight+BarSpacing))+(BarHeight/2), Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
				end
			end
		end
	end
}

DRPF_ATMPAGES["groupaccounts"] = {
	DrawPage = function( ent, width, height )
		surface.SetDrawColor( 69, 111, 178, 100 )
		surface.DrawRect( 0, 0, width, height )
		
		DrawServerBanner( 25, 25 )
	end
}

DRPF_ATMPAGES["groupaccount"] = {
	DrawPage = function( ent, width, height, GroupID )
		surface.SetDrawColor( 69, 111, 178, 100 )
		surface.DrawRect( 0, 0, width, height )
		
		DrawServerBanner( 25, 25 )
		
		surface.SetMaterial( DarkRPFoundation.MATERIALS.BankLogo )
		surface.SetDrawColor( 255, 255, 255 )
		local MatSize = 300
		surface.DrawTexturedRect( (width/2)-(MatSize/2), (height/2)-(MatSize/2), MatSize, MatSize )
		
		local GroupAccount = DRPF_GroupAccounts[LocalPlayer():SteamID64()]
		if( GroupAccount ) then
			draw.SimpleText( GroupAccount.PrintName or "Unknown", "DarkRPFoundation_Font65", width/2, (height/2)+(MatSize/2)+25, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
			draw.SimpleText( DRPF_Functions.L( "atmEntBalance" ) .. " " .. DarkRP.formatMoney( math.Round(GroupAccount.AccountBalance or 0) ), "DarkRPFoundation_Font65", width/2, (height/2)+(MatSize/2)+95, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
		else
			draw.SimpleText( "You shouldn't be here... tut tut tut...", "DarkRPFoundation_Font65", width/2, (height/2)+(MatSize/2)+25, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
			draw.SimpleText( DRPF_Functions.L( "atmEntBalance" ) .. " " .. DarkRP.formatMoney( 0 ), "DarkRPFoundation_Font65", width/2, (height/2)+(MatSize/2)+95, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
		end
	end
}