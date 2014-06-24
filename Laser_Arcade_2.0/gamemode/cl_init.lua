include 'shared.lua'

local width = ScrW();
local height = ScrH();

local CurMessages = {}


surface.CreateFont( "Font_20", {font = "coolvetica",
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Font_20s", {font = "arial",
	size = 15,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true,
} )
surface.CreateFont( "Font_30", {font = "akbar",
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Font_34", {font = "akbar",
	size = 34,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Font_34s", {font = "akbar",
	size = 34,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Font_40", {font = "roboto",
	size = 40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Font_64", {font = "coolvetica",
	size = 64,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

function AddMessage(text,life)
	
	local i = #CurMessages + 1
	
	CurMessages[i] = {}
	CurMessages[i].Message = text
	CurMessages[i].Life = CurTime() + life
	
end

--[[
local function DrawMessages()
	
	if #CurMessages > 0 then
		draw.RoundedBox(8,width * 0.3,height * 0,width * 0.4,height * (0.021 * #CurMessages),Color(0,0,0,(200 - (#CurMessages * 20))))
	end
	
	for i=1,#CurMessages do
		if CurMessages[i] then
			if CurMessages[i].Life > CurTime() then
				draw.DrawText(CurMessages[i].Message,"Font_20",width * 0.5,height * (0.02 * (i-1)),Color(255,255,255,(255 - (#CurMessages * 20))),1)
			end
			if CurMessages[i].Life < CurTime() then
				CurMessages[i] = nil
				table.Shift(CurMessages)
			end
		end
	end
	
end
]]

local function DrawMessages()
	
	if #CurMessages > 0 then
		draw.RoundedBox(8,width * 0.3,height * 0,width * 0.4,height * (0.021 * #CurMessages),Color(0,0,0,(200 - (#CurMessages * 20))))
	end
	
	--for i=1,#CurMessages do
	local i = 1; while i <= #CurMessages do
		
		local msg = CurMessages[i];
		
		if msg.Life > CurTime() then
			draw.DrawText(msg.Message,"Font_20",width * 0.5,height * (0.02 * (i-1)),Color(255,255,255,(255 - (#CurMessages * 20))),1)
		end
		
		if msg.Life < CurTime() then
			msg = nil
			--table.Shift(CurMessages)
			table.remove(CurMessages, i);
			
			i = i - 1;
		end
		
		i = i + 1;
	end
	
end

local function DrawEndBoard()
	
	draw.RoundedBox(8,width * 0.01,height * 0.01,width * 0.98,height * 0.98,Color(0,0,0,240))
	if GetGlobalFloat("winteam") == 1 then
		draw.DrawText("Red Team won!!","Font_30",width * 0.5,height * 0.05,Color(255,0,0,255),1)
	else
		draw.DrawText("Blue Team won!!","Font_30",width * 0.5,height * 0.05,Color(100,100,255,255),1)
	end
	
	local rteam = team.GetPlayers(1)
	table.sort(rteam,function (a,b) return a:Frags() > b:Frags() end)
	
	local bteam = team.GetPlayers(2)
	table.sort(bteam,function (a,b) return a:Frags() > b:Frags() end)
	
	draw.DrawText("Top five fraggers","Font_40",width * 0.5,height * 0.09,Color(255,255,255,255),1)
	-- Red team's top five fraggers
	draw.DrawText("Red","Font_30",width * 0.2,height * 0.18,Color(255,0,0,255),0)
	for i=1,5 do
		if rteam[i] then
			draw.DrawText(rteam[i]:Nick().." - "..rteam[i]:Frags(),"Font_20",width * 0.2,height * (0.2 + (0.02 * i)),Color(255,255,255,255),0)
		end
	end
	-- Red team's top five fraggers
	draw.DrawText("Blue","Font_30",width * 0.8,height * 0.18,Color(100,100,255,255),2)
	for i=1,5 do
		if bteam[i] then
			draw.DrawText(bteam[i]:Nick().." - "..bteam[i]:Frags(),"Font_20",width * 0.8,height * (0.2 + (0.02 * i)),Color(255,255,255,255),2)
		end
	end
	
	-- Time left
	local tleft = (GetGlobalFloat("changein") + 1) - CurTime()
	local tleft = string.ToMinutesSeconds(tleft)
	draw.DrawText("Time left: "..tleft,"Font_34",width * 0.5,height * 0.5,Color(255,255,255,255),1)
	
end

local function DrawDeathScreen()
	
	local user = LocalPlayer();
	local target = user:GetObserverTarget();
	local time = user:GetNWFloat('laser_nextRespawn') - CurTime();
	
	draw.RoundedBox(16, width * 0.3, height * 0.75, width * 0.4, height * 0.2, Color(0,0,0,100));
		
	if time > 0 then
		draw.DrawText("Time until respawn... " .. string.ToMinutesSeconds(time + 1), "Font_34s", width * 0.5, height * 0.88, color_white, TEXT_ALIGN_CENTER);
	else
		draw.DrawText("Respawn Ready!", "Font_34s", width * 0.5, height * 0.88, Color(255,255,255, math.abs(math.sin(CurTime()*3)) * 255), TEXT_ALIGN_CENTER);
	end
	
	if IsValid(target) and target:IsPlayer() then
		
		if user:GetObserverMode() == OBS_MODE_FREEZECAM then
			draw.DrawText("Killed by " .. target:Nick(), "Font_64", width * 0.5, height * 0.8, color_white, TEXT_ALIGN_CENTER);
		else
			
			draw.DrawText(target:Nick(), "Font_64", width * 0.5, height * 0.8, color_white, TEXT_ALIGN_CENTER);
		end
		
	end
	
end

local function DrawTeamStats()
	
	local user = LocalPlayer();
	
	local teamcolor = team.GetColor(user:Team())
	-- Draw team's frags
	draw.RoundedBox(2,width * 0.8,height * 0,width * 0.2,height * 0.2,Color(0,0,0,100))
	
	if user.TFrags == nil then
		user.TFrags = 0
	end
	local rfrags = laser.GetTeamFrags(1)
	local bfrags = laser.GetTeamFrags(2)
	
	//draw.DrawText( "You are on "..team.GetName(user:Team()).." Team!", "Font_20", ScrW() * 0.5, ScrH() * 0.25, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
	
	draw.DrawText("You are on "..team.GetName(user:Team()).." Team!","Font_20",width * 0.81,height * 0.01, teamcolor,0)
	draw.DrawText("Red Team - "..rfrags,"Font_20",width * 0.81,height * 0.03,Color(255,0,0,255),0)
	draw.DrawText("Blue Team - "..bfrags,"Font_20",width * 0.81,height * 0.05,Color(100,100,255,255),0)

	-- Top fraggers
	draw.DrawText("Top Fraggers:","Font_34",width * 0.81,height * 0.08,Color(255,255,255,255),0)
	
	local rfrag = laser.GetSortedFraggers(1)[1];
	if rfrag then
		draw.DrawText(rfrag:Nick().." - "..rfrag:Frags(),"Font_20",width * 0.81,height * 0.115,Color(255,0,0,255),0)
	end
	
	local bfrag = laser.GetSortedFraggers(2)[1];
	if bfrag then
		draw.DrawText(bfrag:Nick().." - "..bfrag:Frags(),"Font_20",width * 0.81,height * 0.135,Color(100,100,255,255),0)
	end
	
end

local function DrawDominationBars()
	
	-- Domination bars
	-- Backgrounds
	draw.RoundedBox(12,width * 0.001,height * -0.1,width * 0.032,height * 0.6,Color(0,0,0,240)) -- Red's bar
	draw.RoundedBox(12,width * 0.034,height * -0.1,width * 0.032,height * 0.6,Color(0,0,0,240)) -- Blue's bar
	-- Fill 'er up!
	-- Red
	local rscale = laser.GetTeamFrags(1) / laser.TeamGoal
	local hgt = height * 0.5 * rscale
	draw.RoundedBox(0,width * 0.002,height * -0.1,width * 0.03,height * 0.12,Color(255,0,0,255))
	draw.RoundedBox(12,width * 0.002,height * 0,width * 0.03,hgt,Color(255,0,0,255))
	-- Blue
	local bscale = laser.GetTeamFrags(2) / laser.TeamGoal
	local hgt = height * 0.5 * bscale
	draw.RoundedBox(0,width * 0.035,height * -0.1,width * 0.03,height * 0.12,Color(100,100,255,255))
	draw.RoundedBox(12,width * 0.035,height * 0,width * 0.03,hgt,Color(100,100,255,255))
	
	-- Percentages
	draw.DrawText(math.floor(rscale * 100) .. "%","Font_20",width * 0.02,height * 0.5,Color(255,255,255,255),1)
	draw.DrawText(math.floor(bscale * 100) .. "%","Font_20",width * 0.053,height * 0.5,Color(255,255,255,255),1)
	
	-- D O M I N A T I O N
	
	draw.DrawText("D", "Font_34", width * 0.08, height * 0,    color_white, 1)
	draw.DrawText("O", "Font_34", width * 0.08, height * 0.04, color_white, 1)
	draw.DrawText("M", "Font_34", width * 0.08, height * 0.08, color_white, 1)
	draw.DrawText("I", "Font_34", width * 0.08, height * 0.12, color_white, 1)
	draw.DrawText("N", "Font_34", width * 0.08, height * 0.16, color_white, 1)
	draw.DrawText("A", "Font_34", width * 0.08, height * 0.20, color_white, 1)
	draw.DrawText("T", "Font_34", width * 0.08, height * 0.24, color_white, 1)
	draw.DrawText("I", "Font_34", width * 0.08, height * 0.28, color_white, 1)
	draw.DrawText("O", "Font_34", width * 0.08, height * 0.32, color_white, 1)
	draw.DrawText("N", "Font_34", width * 0.08, height * 0.36, color_white, 1)
	
end

local function DrawPlayerMarkers()
	
	local user = LocalPlayer();
	
	-- Team Markers
	--surface.SetDrawColor( team.GetColor(user:Team()) )
	local heightOffset = 80;
	for k,v in pairs(player.GetAll()) do
		
		if v ~= user and v:Team() == user:Team() then //is on same team
			
			local markpos = (v:GetPos() + Vector(0, 0, heightOffset)):ToScreen();
			local dist    = user:GetPos():Distance(v:GetPos());
			local alpha   = 255 - math.min(math.max(dist / 12, 32), 148);
			
			//Draw a small v above them!
			surface.SetDrawColor( Color(0, 255, 100, alpha) );
			draw.NoTexture();
			surface.DrawPoly({
				{ x = markpos.x - 9, y = markpos.y - 10 },
				{ x = markpos.x + 9, y = markpos.y - 10 },
				{ x = markpos.x, y = markpos.y },
			});
			
		end
		
	end
	
	-- Player names
	local maxDistanceTeam  = 1024;
	local maxDistanceEnemy = 256
	for k,v in pairs(player.GetAll()) do
		
		if v != user then
			
			local dist = (user:GetPos():DistToSqr(v:GetPos()))
			
			if (user:Team() == v:Team() and dist <= maxDistanceTeam*maxDistanceTeam)
			or (dist <= maxDistanceEnemy*maxDistanceEnemy and user:IsLineOfSightClear(v)) then
				
				local spos = (v:GetPos() + Vector(0,0,80)):ToScreen()
				
				local col = team.GetColor(v:Team())
				if not v:Alive() then
					col = Color(200,200,200,255)
				end
				
				draw.DrawText(v:Nick(), "Font_20s", spos.x, spos.y - 28, col, 1)
				
			end
			
		end
		
	end
	
end

function GM:HUDPaint()
	
	local pl = LocalPlayer();
	if not IsValid(pl) then return end
	
	DrawMessages();
	if GetGlobalBool("roundover") then
		DrawEndBoard();
	else
		DrawTeamStats();
		DrawDominationBars();
	end
	
	if not pl:Alive() then
		DrawDeathScreen();
	end
	
	DrawPlayerMarkers();

	-- Are we being evenized?
	if GetGlobalEntity("evenized") == pl then
		draw.RoundedBox(0,0,0,width,height,Color(0,0,0,255))
		draw.DrawText("YOU ARE BEING EVENIZED.","Font_40",width * 0.5,height * 0.4,Color(255,255,255,255),1)
		draw.DrawText("Don't whine or moan about how COOL you were, or how you're going to lose all your FRAGS.","Font_30",width * 0.5,height * 0.47,Color(255,255,255,255),1)
		draw.DrawText("No one cares.","Font_34",width * 0.5,height * 0.5,Color(255,255,255,255),1)
	end
end

--[[
function table.Shift(tbl)
	shiftpoint = 10000
	for i=1,table.getn(tbl) do 
		if tbl[i] == nil then
			shiftpoint = i
		end
		if i > shiftpoint then
			tbl[i-1] = tbl[i]
			tbl[i] = nil
		end
	end
end
]]