IncludeCS 'shared.lua'
AddCSLuaFile 'cl_init.lua'
AddCSLuaFile 'cl_hud.lua'
AddCSLuaFile 'cl_lasers.lua'
AddCSLuaFile 'cl_scoreboard.lua'

include 'sv_lasers.lua'

local KillingSprees = {}
KillingSprees[2] = "Double kill!"
KillingSprees[3] = "Triple kill!"
KillingSprees[4] = "Multi kill!"
KillingSprees[5] = "Killing Spree!!"
KillingSprees[6] = "Monster kill!!"
KillingSprees[8] = "Unstoppable!"
KillingSprees[10] = "Godlike!!!"
KillingSprees[14] = "HOLY MELONS!!!!!!"

local RedPlayerModels = { "models/player/combine_super_soldier.mdl", "models/player/combine_soldier.mdl" }
local BluePlayerModels = { "models/player/monk.mdl", "models/player/breen.mdl" }

-- Is this even necessary?
--[[
function GM:PlayerSelectSpawn( ply )

	if ply:Team() == 1 then
		if #ents.FindByClass( "info_player_combine" ) > 0 then

			return ents.FindByClass( "info_player_combine" )[math.random(#ents.FindByClass( "info_player_combine" ))]
		else 
			return ents.FindByClass( "info_player_start" )[math.random(#ents.FindByClass( "info_player_start" ))]
		end
	else
		if #ents.FindByClass( "info_player_combine" ) > 0 then

			return ents.FindByClass( "info_player_rebel" )[math.random(#ents.FindByClass( "info_player_rebel" ))]
		else 
			return ents.FindByClass( "info_player_start" )[math.random(#ents.FindByClass( "info_player_start" ))]
		end
	end
end
]]

--[[
local function SpawnBot()
	
	local bot = player.CreateNextBot("BOT " .. table.Random({
		"Bill",
		"Bob",
		"Joe",
		"Jack",
		"Andy",
		"Phil",
		"Mike",
		"Amanda",
		"Mindy",
		"Mary",
	}));
	
	if IsValid(bot) then
		
		--bot:SetTeam(team.BestAutoJoinTeam());
		
	else
		MsgN("Error creating bot! Is there enough player slots?");
	end
	
end
concommand.Add('laser_bot', SpawnBot);
]]


local function AddMessage(user, msg, life)
	
	user:SendLua([[AddMessage("]] .. msg .. [[",]] .. life .. [[)]]);
	
end

local function AddMessageAll(msg, life)
	
	for k,v in pairs(player.GetAll()) do
		AddMessage(v,msg,life);
	end
	
end

local function AddMessageTeam(pteam, msg, life)
	
	for k,v in pairs(team.GetPlayers(pteam)) do
		AddMessage(v,msg,life);
	end
	
end

local function DetermineKillingSpree(user)
	
	for k,v in pairs(KillingSprees) do
		if k == user.KillingSpree then
			AddMessage(user,user:Nick()..": "..v,5);
		end
	end
	
end

local function PickNextMap()
	
	-- Use the server's mapcycle instead.
	local nextmap = game.GetMapNext();
	
	-- No next map found, reload same map.
	if nextmap == nil then
		nextmap = game.GetMap();
	end
	
	-- Load next map.
	RunConsoleCommand('changelevel', nextmap);
	MsgN("changelevel " .. nextmap);
	
end

local function ResetTrail(user)
	
	user.Trail:Remove()
	
	timer.Simple(0.2,function(user) user.Trail = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt") end,user)
	
end

local function EvenizePlayer(user,nteam)
	
	SetGlobalEntity("evenized",victim)
	
	timer.Simple(EvenizeDelay + 1,function(user) SetGlobalEntity("evenized",NULL) user.Trail:Remove() user.Trail = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt") user:AddFrags(user:Frags() * -1) user:SetTeam(1) user:Kill() AddMessageAll(user:Nick().." Has been EVENIZED!",5) end, user)
	
end

local function PlayerLaserExplosion(pl)
	
	local col = team.GetColor(pl:Team());
	
	laser.StartLasers(pl, pl);
	for i=1, 50 do
		
		local ang = VectorRand();
		local range = math.random(256, 512);
		
		laser.FireLaser(col, {pl}, pl:GetPos(), ang, 100, range);
		
	end
	laser.EndLasers();
	
	pl:EmitSound(Sound('ambient/explosions/explode_5.wav'), 511);
	
	--[[
	local effect = EffectData()
	
	effect:SetStart(pl:GetPos())
	effect:SetEntity(pl)
	
	if pl:Team() == laser.TEAM_RED then
		util.Effect("redlaserdeath",effect)
	else
		util.Effect("bluelaserdeath",effect)
	end
	]]
	
end

local function StartPlayerSpectate(pl, attacker)
	
	if IsValid(attacker) and attacker:IsPlayer() then
		
		pl:SendLua([[surface.PlaySound(Sound("misc/freeze_cam.wav"))]]);
		
		pl:SpectateEntity(attacker);
		pl:Spectate(OBS_MODE_FREEZECAM);
		
	end
	
	timer.Simple(laser.MIN_DEATH_TIME - 3, function()
		
		local teammates = laser.GetSortedFraggers(pl:Team());
		
		for k,v in pairs(teammates) do
			if IsValid(v) and v:Alive() then
				pl:SpectateEntity(v);
				pl:Spectate(OBS_MODE_CHASE);
				
				return;
			end
		end
		
		pl:SpectateEntity(table.Random(teammates));
		pl:Spectate(OBS_MODE_CHASE);
		
	end);
	
end

function GM:PlayerSpawn(user)
	
	if user:Team() > 2 then
		
		if team.NumPlayers(1) > team.NumPlayers(2) then
			user:SetTeam(2)
		else
			user:SetTeam(1)
		end
		
		user.KillingSpree = 0
	end
	
	user:UnSpectate();
	
	user:Give("weapon_laser");
	--[[
	user:Give("weapon_fastlaser");
	user:Give("weapon_shotgunlaser");
	user:Give("weapon_sniperlaser");
	user:Give("weapon_laserminigun");
	]]
	user:ShouldDropWeapon(false);
	user:SetNoCollideWithTeammates(true);
	user:SetCanZoom(false);
	user:SetWalkSpeed(450);
	user:SetRunSpeed(450);
	user:SetCrouchedWalkSpeed(0.33);
	user:SetJumpPower(256);
	
	local teamColor = team.GetColor(user:Team());
	user:SetPlayerColor( Vector(teamColor.r / 255, teamColor.g / 255, teamColor.b / 255) );
	
	if user:Team() == 1 then
		user:SetModel(RedPlayerModels[math.random(1,#RedPlayerModels)]);
	else
		user:SetModel(BluePlayerModels[math.random(1,#BluePlayerModels)]);
	end
	
	--user.Trail          = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt");
	user.Trail            = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 0, 64, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt");
	user.KilledByHeadshot = false;
	user.LastWallJump     = CurTime();
end

function GM:PlayerDeath(user,wep,atk)
	
	user:SetNWFloat('lr_nextRespawn', CurTime() + laser.MIN_DEATH_TIME);
	user.KillingSpree = 0;
	
	SafeRemoveEntity(user.Trail);
	
	if user ~= atk then
		if atk:IsPlayer() then
			
			local message;
			
			if user.KilledByHeadshot then
				message = table.Random({ -- >v == victim, >a == attacker
					">a popped off >v's head",
					">v was headshotted by >a",
					">a offed >v's head",
				});
			else
				message = table.Random({ -- >v == victim, >a == attacker
					">v was pulverized by >a",
					">a owned >v",
					">v was obliterated by >a",
					">v had no chance against >a",
				});
			end
			message = string.gsub(message,">a", atk:Nick());
			message = string.gsub(message,">v", user:Nick());
			AddMessageAll(message, 3);
			
			atk.KillingSpree = atk.KillingSpree + 1;
			DetermineKillingSpree(atk);
			
			PlayerLaserExplosion(user);
			StartPlayerSpectate(user, atk);
			
		else
			
			AddMessageAll(user:Nick() .. " kicked the bucket...", 3);
			StartPlayerSpectate(user);
			
		end
		
		user:SetNWBool('lr_isSuicide', false);
		
	else
		
		AddMessageAll(user:Nick() .. " ended it all!!", 3);
		PlayerLaserExplosion(user);
		StartPlayerSpectate(user);
		
		user:SetNWBool('lr_isSuicide', true);
		
	end
	
	-- Gibs
	--[[
	if user:IsPlayer() then
		local t = ents.Create("prop_ragdoll");
		local l = ents.Create("prop_ragdoll");
		if !(t:IsValid() && l:IsValid()) then return end
		
		SafeRemoveEntity(user:GetRagdollEntity());
		
		t:SetModel("models/Gibs/Fast_Zombie_Torso.mdl");
		l:SetModel("models/Gibs/Fast_Zombie_Legs.mdl");
		t:SetKeyValue( "origin", user:GetPos().x .. " " .. user:GetPos().y .. " " .. user:GetPos().z+0 );
		l:SetKeyValue( "origin", user:GetPos().x .. " " .. user:GetPos().y .. " " .. user:GetPos().z+0 );
		t:SetAngles(user:GetAngles());
		l:SetAngles(user:GetAngles());
		t:Spawn();
		l:Spawn();
		t:SetCollisionGroup(COLLISION_GROUP_WORLD);
		l:SetCollisionGroup(COLLISION_GROUP_WORLD);
		t:Activate();
		l:Activate();
		t:GetPhysicsObject():SetVelocity(user:GetVelocity());
		l:GetPhysicsObject():SetVelocity(user:GetVelocity());
		
		SafeRemoveEntityDelayed(t, 10); //Removes gibs after 10 seconds
		SafeRemoveEntityDelayed(l, 10);
	end
	]]
end

function GM:PlayerDeathThink(ply)
	
	-- Disallow respawn before laser.MIN_DEATH_TIME seconds.
	if CurTime() < ply:GetNWFloat('lr_nextRespawn') then return end
	
	if ply:KeyPressed(IN_ATTACK)
	or ply:KeyPressed(IN_ATTACK2)
	or ply:KeyPressed(IN_JUMP)
	then
		ply:Spawn();
	end
	
end

function GM:PlayerShouldTakeDamage(user, atk)
	
	--if atk:IsPlayer() && (user:Team() == atk:Team()) then return false else return true end
	return not (atk:IsPlayer() and (user:Team() == atk:Team()));
	
end

function GM:GetFallDamage(ply, speed)
	--return 0
	--local dmg = math.max(math.min((speed - 500) / 150, 10), 0);
	--local dmg = math.max((speed - 500) / 150, 0);
	local dmg = math.ceil(math.max((speed - 750) / 40, 0));
	--PrintMessage(HUD_PRINTTALK, "speed="..speed .."    ".. "dmg="..dmg);
	return dmg;
end

--[[
-------------------------Old Script Start
function PickNextMap()
	for k, v in ( mapfinder ) do
		MapList[k]="mapfinder"
	end

	newmap = table.Random(MapList);

	while(string.find( string.lower( game.GetMap() ), newmap )) do
		newmap = table.Random(MapList);
	end

	game.ConsoleCommand( "changelevel " ..newmap )
	Msg("changelevel " ..newmap )
end
-----------------------Old Script End

function PickNextMap()
	lasermaps = {}
	local maps = file.Find( "maps/la_*.bsp", "GAME" )//Honestly taken from ULX  there's seems to work properly

	for _, map in ipairs( maps ) do
		table.insert( lasermaps, map:sub( 1, -5 ) ) -- Take off the .bsp
	end

	newmap = table.Random(lasermaps);

	while(string.find( string.lower( game.GetMap() ), newmap )) do
		newmap = table.Random(lasermaps);
	end

	game.ConsoleCommand( "changelevel " ..newmap.. "\n")
	Msg("changelevel " ..newmap )
end
]]

hook.Add('KeyPress', 'lr_WallJumping', function(pl, key)
	
	local WALLJUMP_DELAY = 0.4;
	
	if pl.LastWallJump + WALLJUMP_DELAY > CurTime() then return end
	if pl:OnGround() then return end
	
	if key == IN_JUMP then
		
		local WALLJUMP_FORCE = 500;
		
		local ang;
		local origin = pl:GetPos() + Vector(0, 0, 32);
		local left = true;
		
		if pl:KeyDown(IN_MOVELEFT) then
			ang = pl:GetRight();
		elseif pl:KeyDown(IN_MOVERIGHT) then
			ang = pl:GetRight() * Vector(-1, -1, 0);
			left = false;
		else
			return
		end
		
		local tr = util.TraceLine({
			start = origin,
			endpos = origin + (ang * 32),
			filter = { pl };
		});
		
		if tr.HitWorld and not tr.HitSky then
			
			local z = tr.HitNormal.z;
			
			if z < 0.5 and z > -0.5 then
				
				pl:SetLocalVelocity(pl:GetVelocity() + ((tr.HitNormal + Vector(0,0,0.5)) * WALLJUMP_FORCE));
				pl:ViewPunch(Angle(-5, left and 3 or -3, 0));
				
				pl.LastWallJump = CurTime();
				
			end
			
		end
		
	end
	
end);

hook.Add("Think", "lr_RoundCheckThink", function()
	
	local roundOver = false;
	
	if (laser.GetTeamFrags(laser.TEAM_RED) >= laser.TeamGoal) and (not GetGlobalBool("roundover")) then
		
		GetGlobalInt("winteam", laser.TEAM_RED);
		roundOver = true;
		
	elseif (laser.GetTeamFrags(laser.TEAM_BLUE) >= laser.TeamGoal) and (not GetGlobalBool("roundover")) then
		
		GetGlobalInt("winteam", laser.TEAM_BLUE);
		roundOver = true;
		
	end
	
	if roundOver then
		
		for k,v in pairs(player.GetAll()) do
			v:Lock()
		end
		
		SetGlobalBool("roundover",true)
		SetGlobalFloat("changein",CurTime() + laser.IntermissionTime)
		timer.Simple(laser.IntermissionTime, PickNextMap)
		
	end
	
end)

-- When someone disconnects, the teams will get disrupted. As an example, the game could be 4 on 2. This will help even out the teams.
hook.Add("Think", "lr_Evenizer", function()
	
	if not GetGlobalEntity("evenized"):IsValid() then
		
		if (team.NumPlayers(1) > team.NumPlayers(2)) and ((team.NumPlayers(1) - team.NumPlayers(2)) >= 2) then
			local rteam = team.GetPlayers(1)
			local victim = rteam[math.random(1,#rteam)]
			SetGlobalEntity("evenized",victim)
			timer.Simple(laser.EvenizeDelay + 1,function(user) ResetTrail(user) SetGlobalEntity("evenized",NULL) user:SetTeam(2) user:AddFrags(user:Frags() * -1) user:Kill() AddMessageAll(user:Nick().." Has been EVENIZED!",5) end, victim)
		end
		
		if (team.NumPlayers(2) > team.NumPlayers(1)) and ((team.NumPlayers(2) - team.NumPlayers(1)) >= 2) then
			local bteam = team.GetPlayers(2)
			local victim = bteam[math.random(1,#bteam)]
			SetGlobalEntity("evenized",victim)
			timer.Simple(laser.EvenizeDelay + 1,function(user) SetGlobalEntity("evenized",NULL) ResetTrail(user) user:AddFrags(user:Frags() * -1) user:SetTeam(1) user:Kill() AddMessageAll(user:Nick().." Has been EVENIZED!",5) end, victim)
		end
		
	end
	
end)