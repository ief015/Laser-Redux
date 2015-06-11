local width = ScrW();
local height = ScrH();

local curMessages = {};


function AddMessage(text, life)
	
	local i = #curMessages + 1;
	
	curMessages[i] = {};
	curMessages[i].Message = text;
	curMessages[i].Life = CurTime() + (life or 3);
	
end

--[[
local function DrawMessages()
	
	if #curMessages > 0 then
		draw.RoundedBox(8,width * 0.3,height * 0,width * 0.4,height * (0.021 * #curMessages),Color(0,0,0,(200 - (#curMessages * 20))))
	end
	
	for i=1,#curMessages do
		if curMessages[i] then
			if curMessages[i].Life > CurTime() then
				draw.DrawText(curMessages[i].Message,"Font_20",width * 0.5,height * (0.02 * (i-1)),Color(255,255,255,(255 - (#curMessages * 20))),1)
			end
			if curMessages[i].Life < CurTime() then
				curMessages[i] = nil
				table.Shift(curMessages)
			end
		end
	end
	
end
]]

local function DrawMessages()
	
	if #curMessages > 0 then
		draw.RoundedBox(8,width * 0.3,height * 0,width * 0.4,height * (0.021 * #curMessages),Color(0,0,0,(200 - (#curMessages * 20))))
	end
	
	--for i=1,#curMessages do
	local i = 1; while i <= #curMessages do
		
		local msg = curMessages[i];
		
		if msg.Life > CurTime() then
			draw.DrawText(msg.Message,'lr_planetside18s',width * 0.5,height * (0.02 * (i-1)) + 1,Color(255,255,255,(255 - (#curMessages * 20))),1)
		end
		
		if msg.Life < CurTime() then
			msg = nil
			--table.Shift(curMessages)
			table.remove(curMessages, i);
			
			i = i - 1;
		end
		
		i = i + 1;
	end
	
end

local function DrawEndBoard()
	
	draw.RoundedBox(8, width * 0.01, height * 0.01, width * 0.98, height * 0.98, Color(0,0,0,240));
	
	if GetGlobalInt('winteam') == laser.TEAM_RED then
		draw.DrawText("Red Victory", 'lr_airstream128', width * 0.5 + 4, height * 0.05 + 4, color_black, 1);
		draw.DrawText("Red Victory", 'lr_airstream128', width * 0.5, height * 0.05, team.GetColor(laser.TEAM_RED), 1);
	else
		draw.DrawText("Blue Victory", 'lr_airstream128', width * 0.5 + 4, height * 0.05 + 4, color_black, 1);
		draw.DrawText("Blue Victory", 'lr_airstream128', width * 0.5, height * 0.05, team.GetColor(laser.TEAM_BLUE), 1);
	end
	
	
	--draw.DrawText("Top five fraggers", 'laser_planetside40', width * 0.5, height * 0.125, color_white, 1);
	
	local rteam = team.GetPlayers(1);
	local bteam = team.GetPlayers(2);
	table.sort(rteam, function (a,b) return a:Frags() > b:Frags() end);
	table.sort(bteam, function (a,b) return a:Frags() > b:Frags() end);
	
	-- Red team's top five fraggers
	draw.DrawText("Red", 'lr_airstream64s', width * 0.2, height * 0.18, team.GetColor(laser.TEAM_RED), 0);
	for k,v in ipairs(rteam) do
		draw.DrawText(v:Nick() .. " - " .. v:Frags(), 'lr_planetside30s', width * 0.2, height * (0.22 + (0.03 * k)), Color(255,255,255,255), 0);
	end
	
	-- Blue team's top five fraggers
	draw.DrawText("Blue", 'lr_airstream64s', width * 0.8, height * 0.18, team.GetColor(laser.TEAM_BLUE),2);
	for k,v in ipairs(bteam) do
		draw.DrawText(v:Nick() .. " - " .. v:Frags(), 'lr_planetside30s', width * 0.8, height * (0.22 + (0.03 * k)), Color(255,255,255,255), 2);
	end
	
	-- Time left
	local tleft = string.ToMinutesSeconds((GetGlobalFloat('changein') + 1) - CurTime());
	draw.DrawText("Time left: " .. tleft, 'lr_planetside30s', width * 0.5, height * 0.5, color_white, 1);
	
end

local function DrawDeathScreen()
	
	local user = LocalPlayer();
	local target = user:GetObserverTarget();
	local time = user:GetNWFloat('lr_nextRespawn') - CurTime();
	
	draw.RoundedBox(16, width * 0.3, height * 0.75, width * 0.4, height * 0.2, Color(0,0,0,100));
		
	if time > 0 then
		draw.DrawText("Time until respawn... " .. string.ToMinutesSeconds(time + 1), 'lr_planetside30s', width * 0.5, height * 0.88, Color(255, 255, 255, 96), TEXT_ALIGN_CENTER);
	else
		draw.DrawText("Respawn Ready!", 'lr_planetside30s', width * 0.5, height * 0.88, Color(255,255,255, math.abs(math.sin(CurTime()*3)) * 255), TEXT_ALIGN_CENTER);
	end
	
	if IsValid(target) and target:IsPlayer() then
		
		if user:GetObserverMode() == OBS_MODE_FREEZECAM then
			draw.DrawText("Killed By", 'lr_airstream64s', width * 0.5, height * 0.76, color_white, TEXT_ALIGN_CENTER);
			draw.DrawText(target:Nick(), 'lr_planetside64', width * 0.5 + 2, height * 0.815 + 2, color_black, TEXT_ALIGN_CENTER);
			draw.DrawText(target:Nick(), 'lr_planetside64', width * 0.5, height * 0.815, team.GetColor(target:Team()), TEXT_ALIGN_CENTER);
		else
			
			draw.DrawText("Spectating", 'lr_airstream64s', width * 0.5, height * 0.76, color_white, TEXT_ALIGN_CENTER);
			draw.DrawText(target:Nick(), "lr_planetside64", width * 0.5 + 2, height * 0.815 + 2, color_black, TEXT_ALIGN_CENTER);
			draw.DrawText(target:Nick(), "lr_planetside64", width * 0.5, height * 0.815, team.GetColor(target:Team()), TEXT_ALIGN_CENTER);
		end
		
	elseif user:GetNWBool('lr_isSuicide', false) then
		
		draw.DrawText("Suicide", 'lr_airstream128', width * 0.5 + 4, height * 0.76 + 4, Color(0,0,0), TEXT_ALIGN_CENTER);
		draw.DrawText("Suicide", 'lr_airstream128', width * 0.5, height * 0.76, Color(255,150,50), TEXT_ALIGN_CENTER);
		
	end
	
end

local function DrawTeamStats()
	
	local user = LocalPlayer();
	local teamcolor = team.GetColor(user:Team());
	
	local width = ScrW();
	local height = ScrH();
	
	-- Draw team's frags
	draw.RoundedBox(2,width * 0.8,height * 0,width * 0.2,height * 0.2,Color(0,0,0,220));
	
	if user.TFrags == nil then
		user.TFrags = 0;
	end
	local rfrags = laser.GetTeamFrags(1);
	local bfrags = laser.GetTeamFrags(2);
	
	surface.SetFont('lr_airstream34s');
	local w = surface.GetTextSize("You are on ");
	
	--draw.DrawText("You are on "..team.GetName(user:Team()).." Team!","laser_airstream34s",width * 0.81,height * 0.005, teamcolor,0)
	draw.DrawText("You are on ",'lr_airstream34s',width * 0.81,height * 0.005, color_white,0);
	draw.DrawText(team.GetName(user:Team()).." Team",'lr_airstream34s',width * 0.81 + w,height * 0.005, teamcolor,0);
	draw.DrawText("Red Team  - "..rfrags,'lr_planetside18s',width * 0.81,height * 0.04,Color(255,0,0,255),0);
	draw.DrawText("Blue Team - "..bfrags,'lr_planetside18s',width * 0.81,height * 0.06,Color(100,100,255,255),0);

	-- Top fraggers
	draw.DrawText("Top Fraggers:", 'lr_airstream34s', width * 0.81, height * 0.08, color_white, 0);
	
	local rfrag = laser.GetSortedFraggers(1)[1];
	if rfrag then
		draw.DrawText(rfrag:Nick().."  -  "..rfrag:Frags(),'lr_planetside18s',width * 0.81,height * 0.115,Color(255,0,0,255),0);
	end
	
	local bfrag = laser.GetSortedFraggers(2)[1];
	if bfrag then
		draw.DrawText(bfrag:Nick().."  -  "..bfrag:Frags(),'lr_planetside18s',width * 0.81,height * 0.135,Color(100,100,255,255),0);
	end
	
end
--[[
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
]]
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
	local maxDistanceEnemy = 256;
	for k,v in pairs(player.GetAll()) do
		
		if v != user and v:Alive() then
			
			local dist = (user:GetPos():DistToSqr(v:GetPos()));
			
			if (user:Team() == v:Team() and dist <= maxDistanceTeam*maxDistanceTeam)
			or (dist <= maxDistanceEnemy*maxDistanceEnemy and user:IsLineOfSightClear(v)) then
				
				local spos = (v:GetPos() + Vector(0,0,82)):ToScreen();
				local spx = math.floor(spos.x);
				local spy = math.floor(spos.y - 28);
				
				local shadow = 1;
				
				local nick = v:Nick();
				
				-- A rich text outline because Valve's font outline rendering looks awful.
				draw.DrawText(nick, 'lr_planetside20', spx+shadow, spy+shadow, color_black, TEXT_ALIGN_CENTER);
				draw.DrawText(nick, 'lr_planetside20', spx-shadow, spy-shadow, color_black, TEXT_ALIGN_CENTER);
				draw.DrawText(nick, 'lr_planetside20', spx+shadow, spy-shadow, color_black, TEXT_ALIGN_CENTER);
				draw.DrawText(nick, 'lr_planetside20', spx-shadow, spy+shadow, color_black, TEXT_ALIGN_CENTER);
				
				draw.DrawText(nick, 'lr_planetside20', spx, spy, team.GetColor(v:Team()), TEXT_ALIGN_CENTER);
				
			end
			
		end
		
	end
	
end

function GM:HUDPaint()
	
	local pl = LocalPlayer();
	if not IsValid(pl) then return end
	--[[
	surface.SetDrawColor(255,0,0);
	surface.DrawLine(ScrW()/2, 0, ScrW()/2, ScrH());
	surface.SetDrawColor(0,255,0);
	surface.DrawLine(0, ScrH()/2, ScrW(), ScrH()/2);
	surface.SetDrawColor(0,0,255);
	surface.DrawOutlinedRect( 0, 0, ScrW(), ScrH());
	]]
	DrawMessages();
	if GetGlobalBool('roundover') then
		DrawEndBoard();
	else
		DrawTeamStats();
		--DrawDominationBars();
	end
	
	if not pl:Alive() then
		DrawDeathScreen();
	end
	
	DrawPlayerMarkers();

	-- Are we being evenized?
	if GetGlobalEntity("evenized") == pl then
		draw.RoundedBox(0,0,0,width,height,Color(0,0,0,255))
		draw.DrawText("YOU ARE BEING EVENIZED.",'lr_planetside40',width * 0.5,height * 0.4,Color(255,255,255,255),1)
		draw.DrawText("Don't whine or moan about how COOL you were, or how you're going to lose all your FRAGS.",'laser_planetside20',width * 0.5,height * 0.47,Color(255,255,255,255),1)
		draw.DrawText("No one cares.",'lr_planetside20',width * 0.5,height * 0.5,Color(255,255,255,255),1)
	end
end

local function Draw3D_DominationBars(mat)
	
	local x = 0.05 * ScrW();
	local y = 0.05 * ScrH();
	
	local width  = math.max(0.25 * ScrW(), 250);
	local height = 40;
	
	local teamBarHeight = height / 8;
	
	surface.SetDrawColor(0, 0, 0, 220);
	surface.DrawRect(x, y, width, height);
	
	local txtDomination;
	if width >= 420 then
		txtDomination = "D  O  M  I  N  A  T  I  O  N";
	elseif width >= 340 then
		txtDomination = "D O M I N A T I O N";
	else
		txtDomination = "DOMINATION";
	end
	draw.DrawText(txtDomination, 'lr_planetside40', x + width - 12, y - 1, Color(255, 255, 255, 16), 2)
	
	local redColour     = team.GetColor(laser.TEAM_RED);
	local redPercentage = laser.GetTeamFrags(laser.TEAM_RED) / laser.TeamGoal * 100;
	local redProgress   = math.max((laser.GetTeamFrags(laser.TEAM_RED) + 1) / (laser.TeamGoal + 1), 0);
	
	surface.SetDrawColor(redColour.r, redColour.g, redColour.b, 220);
	surface.DrawRect(x, y, width * redProgress, teamBarHeight);
	
	local blueColour     = team.GetColor(laser.TEAM_BLUE);
	local bluePercentage = laser.GetTeamFrags(laser.TEAM_BLUE) / laser.TeamGoal * 100;
	local blueProgress   = math.max((laser.GetTeamFrags(laser.TEAM_BLUE) + 1) / (laser.TeamGoal + 1), 0);
	
	surface.SetDrawColor(blueColour.r, blueColour.g, blueColour.b, 220);
	surface.DrawRect(x, y + height - teamBarHeight, width * blueProgress, teamBarHeight);
	
	draw.DrawText(tostring(math.floor(redPercentage))  .. "%", 'lr_planetside18s', x + 2, y + teamBarHeight - 2,      Color(redColour.r,  redColour.g,  redColour.b, 220))
	draw.DrawText(tostring(math.floor(bluePercentage)) .. "%", 'lr_planetside18s', x + 2, y + teamBarHeight + 12, Color(blueColour.r, blueColour.g, blueColour.b, 220))
	
end

local function Draw3D_PlayerInfo(mat)
	
	local pl = LocalPlayer();
	
	local x = 0.05 * ScrW();
	local y = 0.85 * ScrH();
	
	local width  = math.max(0.2 * ScrW(), 200);
	local height = 64;
	
	local hpBarHeight = height/8;
	
	surface.SetDrawColor(0, 0, 0, 220);
	surface.DrawRect(x, y, width, height);
	
	local col = team.GetColor(pl:Team());
	local hp = pl:Health() / pl:GetMaxHealth();
	
	draw.DrawText(tostring(math.floor(hp * 100)) .. "%", 'lr_planetside64', x + 8, y - hpBarHeight/2, Color(255, 255, 255, 32), 0);
	
	--local popout = Matrix();
	--popout:Set(mat);
	--popout:Translate(Vector(0, 0, 20));
	
	--cam.PushModelMatrix(popout);
		surface.SetDrawColor(col.r, col.g, col.b, 220);
		surface.DrawRect(x, y + height - hpBarHeight, width * math.Clamp(hp, 0, 1), hpBarHeight);
	--cam.PopModelMatrix();
	
	local drawnAmmo = false;
	local ammoWidth;
	
	if IsValid(pl:GetActiveWeapon()) then
		
		local clip1 = pl:GetActiveWeapon():Clip1();
		local clip2 = pl:GetActiveWeapon():Clip2();
		
		surface.SetFont('lr_planetside40');
		local clip1TxtWidth = surface.GetTextSize(tostring(clip1));
		
		local ammoX = x + width + 4;
		ammoWidth   = math.max(math.max(clip1TxtWidth - 76, 0) + 96, 96);
		
		--local primaryOffset = 0; -- Shift primary ammo indicator
		                         -- if there is a secondary ammo indicator.
		
		if clip1 >= 0 or clip2 >= 0 then
			
			surface.SetDrawColor(0, 0, 0, 220);
			surface.DrawRect(ammoX, y, ammoWidth, height);
			
			drawnAmmo = true;
			
		end
		
		if clip2 >= 0 then
			
			draw.DrawText(tostring(clip2), 'lr_planetside20', ammoX + ammoWidth - 28, y + 34, Color(255, 255, 255, 32), 0);
			
			primaryOffset = -40;
			
		end
		
		if clip1 >= 0 then
			
			local maxClip = pl:GetActiveWeapon():GetTable().Primary.ClipSize;
			
			local textColor;
			if clip1 / maxClip < 0.2 then
				textColor = Color(255, 0, 0, 96);
			elseif clip1 / maxClip < 0.5 then
				textColor = Color(255, 200, 0, 96);
			else
				textColor = Color(255, 255, 255, 32);
			end
			
			draw.DrawText(tostring(clip1), 'lr_planetside40', ammoX + ammoWidth - 16, y, textColor, 2);
			
			if maxClip then
				surface.SetDrawColor(col.r, col.g, col.b, 220);
				surface.DrawRect(ammoX + ammoWidth - 12, y + 33, 4, math.Clamp(clip1 / maxClip, 0, 1) * -25);
			end
			
		end
		
	end
	
	-- Charging bar.
	local wep = pl:GetActiveWeapon();
	
	if IsValid(wep) and laser.IsLaserWeapon(wep) and wep:GetCoolingDown() then
		
		local chargeWidth  = width;
		local chargeHeight = height * 0.75;
		
		local chargeY      = y - chargeHeight - 4
		
		if drawnAmmo then
			chargeWidth = chargeWidth + ammoWidth + 4;
		end
		
		local progress = wep:GetCooldownProgress();
		--[[
		draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, ScrW() * 0.4, ScrH() * 0.04, Color(100,100,100,255))
		draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, (ScrW() * 0.4) * progress, ScrH() * 0.04, Color(0,100,0,255))
		draw.SimpleText(self.CooldownMessage, "lr_planetside40", ScrW() * 0.5, ScrH() * 0.04, Color(255,255,255,255), 1)
		]]
		
		surface.SetDrawColor(0, 0, 0, 220);
		surface.DrawRect(x, chargeY, chargeWidth, chargeHeight);
		
		surface.SetDrawColor(50, 255, 50, 32);
		surface.DrawRect(x, chargeY, chargeWidth * (1-progress), chargeHeight);
		
		draw.SimpleText(wep:GetTable().CooldownMessage, "lr_planetside40", x + 8, chargeY + 4, Color(255,255,255,128), TEXT_ALIGN_LEFT)
		
		if chargeWidth >= 240 then
			draw.SimpleText(tostring(math.Round((progress) * 100)) .. "%", "lr_planetside40", x + chargeWidth - 8, chargeY + 4, Color(255,255,255,32), TEXT_ALIGN_RIGHT)
		end
		
		--[[
		draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, ScrW() * 0.4, ScrH() * 0.04, Color(100,100,100,255))
		draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, (ScrW() * 0.4) * progress, ScrH() * 0.04, Color(0,100,0,255))
		draw.SimpleText(wep:GetTable().CooldownMessage, "lr_planetside40", ScrW() * 0.5, ScrH() * 0.04, Color(255,255,255,255), 1)
		]]
		
	end
	
end
--[[
local function Draw3D_TeamStats(mat)
	
	local pl = LocalPlayer();
	
	local teamcolor = team.GetColor(pl:Team())
	-- Draw team's frags
	draw.RoundedBox(2,width * 0.8,height * 0,width * 0.2,height * 0.2,Color(0,0,0,100))
	
	if pl.TFrags == nil then
		pl.TFrags = 0
	end
	local rfrags = laser.GetTeamFrags(1)
	local bfrags = laser.GetTeamFrags(2)
	
	//draw.DrawText( "You are on "..team.GetName(pl:Team()).." Team!", "Font_20", ScrW() * 0.5, ScrH() * 0.25, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
	
	draw.DrawText("You are on "..team.GetName(pl:Team()).." Team!","Font_20",width * 0.81,height * 0.01, teamcolor,0)
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
]]
hook.Add('PostDrawViewModel', 'lr_RenderHUD', function(vm, ply, wep)
	
	local pl = LocalPlayer();
	if not IsValid(pl) then return end
	
	local fov = pl:GetFOV();
	local aspect = ScrW() / ScrH();
	local factor = 20;
	
	local ang = vm:GetAngles();
	ang:RotateAroundAxis(ang:Forward(), 90);
	ang:RotateAroundAxis(ang:Right(), 90);
	ang:RotateAroundAxis(ang:Right(), -15);
	--ang = Angle(0, ang.y, ang.r);
	
	local pos = Vector(1.11, aspect/2, 0.5) * factor;
	pos:Rotate(pl:EyeAngles());
	pos:Add(vm:GetPos());
	
	local scale = (1/ScrW()) * aspect * factor;
	
	cam.IgnoreZ(true);
	
	if not GetGlobalBool('roundover') then
		if pl:Alive() then
			
			local mat = Matrix();
			mat:Translate(pos);
			mat:Rotate(ang);
			mat:Scale(Vector(scale,-scale,scale));
			
			cam.Start3D2D(Vector(), Angle(), 1);
			cam.PushModelMatrix(mat);
			--[[
			surface.SetDrawColor(255,0,0,20);
			surface.DrawLine(ScrW()/2, 0, ScrW()/2, ScrH());
			surface.SetDrawColor(0,255,0,20);
			surface.DrawLine(0, ScrH()/2, ScrW(), ScrH()/2);
			surface.SetDrawColor(0,0,255,20);
			surface.DrawOutlinedRect( 0, 0, ScrW(), ScrH());
			]]
			Draw3D_DominationBars(mat);
			Draw3D_PlayerInfo(mat);
			
			--Draw3D_TeamStats(mat);
			
			cam.PopModelMatrix();
			cam.End3D2D();
		end
	end
	
	cam.IgnoreZ(false);
	
end);

hook.Add('HUDShouldDraw', 'lr_HUDShouldDraw', function(name)
	
	if name == 'CHudHealth'
	or name == 'CHudAmmo'
	or name == 'CHudSecondaryAmmo'
	or name == 'CHudBattery'
	--or name == 'CHudWeaponSelection'
	then
		return false;
	end
	
end);