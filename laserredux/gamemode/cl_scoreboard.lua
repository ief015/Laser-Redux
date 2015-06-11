local scoreboard = nil;
--[[
surface.CreateFont('ScoreboardDefault',
{
	font   = 'Helvetica',
	size   = 18,
	weight = 800,
});

surface.CreateFont('ScoreboardDefaultTitle',
{
	font   = 'Helvetica',
	size   = 32,
	weight = 800,
});
]]
local VGUIPlayerLine = vgui.RegisterTable({
	
	Init = function(self)
		
		self.AvatarButton = self:Add('DButton');
		self.AvatarButton:Dock(LEFT);
		self.AvatarButton:SetSize(24, 24);
		self.AvatarButton.DoClick = function() self.Player:ShowProfile(); end
		
		self.Avatar = vgui.Create('AvatarImage', self.AvatarButton);
		self.Avatar:SetSize(24, 24);
		self.Avatar:SetMouseInputEnabled(false);
		
		self.Name = self:Add('DLabel');
		self.Name:Dock(FILL);
		self.Name:SetFont('ScoreboardDefault');
		self.Name:DockMargin(8, 0, 0, 0);
		
		self.Mute = self:Add('DImageButton');
		self.Mute:SetSize(24, 24);
		self.Mute:Dock(RIGHT);
		
		self.Ping = self:Add('DLabel');
		self.Ping:Dock(RIGHT);
		self.Ping:SetWidth(50);
		self.Ping:SetFont('ScoreboardDefault');
		self.Ping:SetTextColor(color_white);
		self.Ping:SetContentAlignment(5);
		
		self.Deaths = self:Add('DLabel');
		self.Deaths:Dock(RIGHT);
		self.Deaths:SetWidth(50);
		self.Deaths:SetFont('ScoreboardDefault');
		self.Deaths:SetTextColor(color_white);
		self.Deaths:SetContentAlignment(5);
		
		self.Kills = self:Add('DLabel');
		self.Kills:Dock(RIGHT);
		self.Kills:SetWidth(50);
		self.Kills:SetFont('ScoreboardDefault');
		self.Kills:SetTextColor(color_white);
		self.Kills:SetContentAlignment(5);
		
		self:Dock(TOP);
		self:DockPadding(4, 4, 4, 4);
		self:SetHeight(24 + 3*2);
		self:DockMargin(2, 0, 2, 2);
		
	end,
	
	Setup = function(self, pl)
		
		self.Player = pl;
		self.Team   = pl:Team();
		
		self.Avatar:SetPlayer(pl);
		self.Name:SetText(pl:Nick());
		
		self:Think();
		
		--local friend = self.Player:GetFriendStatus();
		--MsgN(pl, " Friend: ", friend);
		
	end,
	
	Think = function(self)
		
		if not IsValid(self.Player) or self.Player:Team() ~= self.Team then
			self:Remove();
			return;
		end
		
		if self.NumKills == nil or self.NumKills ~= self.Player:Frags() then
			self.NumKills = self.Player:Frags();
			self.Kills:SetText(self.NumKills);
		end
		
		if self.NumDeaths == nil or self.NumDeaths ~= self.Player:Deaths() then
			self.NumDeaths = self.Player:Deaths();
			self.Deaths:SetText(self.NumDeaths);
		end
		
		if self.NumPing == nil or self.NumPing ~= self.Player:Ping() then
			self.NumPing = self.Player:Ping();
			self.Ping:SetText(self.NumPing);
		end
		
		if self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
			
			self.Muted = self.Player:IsMuted();
			if self.Muted then
				self.Mute:SetImage('icon32/muted.png');
			else
				self.Mute:SetImage('icon32/unmuted.png');
			end
			
			self.Mute.DoClick = function()
				self.Player:SetMuted(not self.Muted);
			end
			
		end
		
		if self.Player:Alive() then
			self.Name:SetTextColor(Color(255, 255, 255, 255))
		else
			self.Name:SetTextColor(Color(0, 0, 0, 128))
		end
		
		self:SetZPos((self.NumKills * -50) + self.NumDeaths);
		
	end,
	
	--[[Paint = function(self, w, h)
		
		if not IsValid(self.Player ) then
			return;
		end
		
		if self.Player:Team() == TEAM_CONNECTING then
			draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200, 200));
			return;
		end
		
		if not self.Player:Alive() then
			draw.RoundedBox(4, 0, 0, w, h, Color(230, 200, 200, 255));
			return;
		end
		
		if self.Player:IsAdmin() then
			draw.RoundedBox(4, 0, 0, w, h, Color(230, 255, 230, 255));
			return;
		end
		
		draw.RoundedBox(4, 0, 0, w, h, Color(230, 230, 230, 255));
		
	end,]]
	
}, 'DPanel' );

local VGUITeamBoard = vgui.RegisterTable({
	
	Init = function(self)
		
		self.Header = self:Add('Panel');
		self.Header:Dock(TOP);
		self.Header:SetHeight(80);
		
		self.Name = self.Header:Add('DLabel');
		self.Name:SetFont('ScoreboardDefaultTitle');
		self.Name:SetTextColor(Color(255, 255, 255, 255));
		self.Name:Dock(TOP);
		self.Name:SetHeight(40);
		self.Name:SetContentAlignment(5);
		self.Name:SetExpensiveShadow(3, Color(0, 0, 0, 200));
		
		self.TeamScore = self.Header:Add('DLabel');
		self.TeamScore:Dock(TOP);
		self.TeamScore:SetHeight(40);
		self.TeamScore:SetFont('ScoreboardDefaultTitle');
		self.TeamScore:SetTextColor(Color(255, 255, 255, 255));
		self.TeamScore:SetContentAlignment(5);
		
		self.Scores = self:Add('DScrollPanel');
		self.Scores:SetBGColor(color_transparent);
		self.Scores:DockMargin(2, 2, 2, 2);
		self.Scores:Dock(TOP);
		--self.Scores:SetHeight(100); -- TODO: remove this line
		
		self:DockPadding(8, 8, 8, 8);
		--self:SetHeight(20 + 3*2);
		self:DockMargin(2, 0, 2, 2);
		
	end,
	
	Setup = function(self, teamid, reversed)
		
		self.Team = teamid;
		self.Name:SetText(team.GetName(teamid));
		--self.Name:SizeToContents();
		
		if reversed then
			self.Name:Dock(RIGHT);
			self.Name:DockMargin(0,0,128,0);
			self.TeamScore:Dock(LEFT);
		else
			self.Name:Dock(LEFT);
			self.Name:DockMargin(128,0,0,0);
			self.TeamScore:Dock(RIGHT);
		end
		
		self:Think();
		
	end,
	
	Think = function(self)
		
		local curScore = team.GetScore(self.Team);
		
		if self.NumScore ~= curScore then
			self.NumScore = curScore;
			self.TeamScore:SetText(tostring(curScore));
		end
		
		for k, pl in pairs(team.GetPlayers(self.Team)) do
			
			if not IsValid(pl.ScoreEntry) then
				
				pl.ScoreEntry = vgui.CreateFromTable(VGUIPlayerLine);
				pl.ScoreEntry:Setup(pl);
				
				self.Scores:AddItem(pl.ScoreEntry);
				--[[
			elseif pl:Team() ~= self.Team then
				
				pl.ScoreEntry:Remove();
				pl.ScoreEntry = nil;
				]]
			end
			
		end
		
		self.Scores:SizeToContents();
		
	end,
	
	Paint = function(self, w, h)
		
		local teamColour = team.GetColor(self.Team);
		teamColour.a = 64;
		
		draw.RoundedBox(4, 0, 0, w, self.Header:GetTall(), teamColour);
		
	end,
	
	
}, 'DScrollPanel' );

local VGUIScoreBoard = vgui.RegisterTable({
	
	Init = function(self)
		
		self.Header = self:Add('Panel');
		self.Header:Dock(TOP);
		self.Header:SetHeight(100);
		
		self.Name = self.Header:Add('DLabel');
		self.Name:SetFont('ScoreboardDefaultTitle');
		self.Name:SetTextColor(Color(255, 255, 255, 255));
		self.Name:Dock(TOP);
		self.Name:SetHeight(40);
		self.Name:SetContentAlignment(5);
		self.Name:SetExpensiveShadow(3, Color(0, 0, 0, 200));
		
		self.Teams = self:Add('Panel');
		self.Teams:SetContentAlignment(4);
		self.Teams:Dock(FILL);
		
		self.TeamRed = vgui.CreateFromTable(VGUITeamBoard);
		self.TeamRed:Setup(laser.TEAM_RED, false);
		self.TeamRed:Dock(LEFT);
		self.TeamRed:SetWidth(347);
		self.Teams:Add(self.TeamRed);
		
		self.TeamBlue = vgui.CreateFromTable(VGUITeamBoard);
		self.TeamBlue:Setup(laser.TEAM_BLUE, true);
		self.TeamBlue:Dock(RIGHT);
		self.TeamBlue:SetWidth(347);
		self.Teams:Add(self.TeamBlue);
		
	end,

	PerformLayout = function(self)
		
		local width = 700;
		
		self:SetSize(width, ScrH() - 200);
		self:SetPos((ScrW() / 2) - (width / 2), 100);
		
	end,

	Paint = function(self, w, h)
		
		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150));
		
	end,
	
	Think = function(self, w, h)
		
		self.Name:SetText(GetHostName());
		
	end,
	
}, 'EditablePanel' );


function GM:ScoreboardShow()
	
	if not IsValid(scoreboard) then
		scoreboard = vgui.CreateFromTable(VGUIScoreBoard);
	end
	
	if IsValid(scoreboard) then
		scoreboard:Show();
		scoreboard:MakePopup();
		scoreboard:SetKeyboardInputEnabled(false);
	end
	
end


function GM:ScoreboardHide()

	if IsValid(scoreboard) then
		scoreboard:Hide();
	end

end