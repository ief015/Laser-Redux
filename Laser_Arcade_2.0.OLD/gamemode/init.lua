AddCSLuaFile 'cl_init.lua'
AddCSLuaFile 'shared.lua'
include 'shared.lua'

GM.Name = "Laser Arcade 2.0"

util.AddNetworkString('laser_LaserEffect');

local PlayerKillMessages = {">v got pulverized by >a!!", -- >v == victim, >a == attacker
">a owned >v!!",
">v got obliterated by >a!!",
">v had no chance against >a!!",
">a humiliated >v!!"}

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

-- FireLaser(Entity attacker, Entity inflictor, Entity|Table filter, Vector pos, Vector dir, number force, number range = 0)
-- Fire a laser and inflict some damage.
function FireLaser(attacker, inflictor, filter, pos, dir, force, range)
	
	if IsValid(attacker) then
		
		local tr = util.TraceLine({
			start  = pos,
			endpos = pos + (dir * ((range == nil or range == 0) and (4096*8) or range)),
			filter = filter,
		});
		
		-- We do two because they're only drawn if the player is looking at the starting point of the beam.
		-- We want the lasers to draw more often than that. Drawing twice with the start/origin swapped
		-- should help in most cases.
		local effect = EffectData();
		effect:SetStart(tr.StartPos);
		effect:SetOrigin(tr.HitPos);
		effect:SetEntity(attacker);
		util.Effect("laser", effect);
		
		effect = EffectData();
		effect:SetStart(tr.HitPos);
		effect:SetOrigin(tr.StartPos);
		effect:SetEntity(attacker);
		util.Effect("laser", effect);
		
		-- Unfortunate hack, for now.
		if attacker:IsPlayer() then
			
			if not game.SinglePlayer() then
				
				net.Start('laser_laserEffect');
					net.WriteEntity(attacker);
					net.WriteVector(tr.StartPos);
					net.WriteVector(tr.HitPos);
				net.Send(attacker);
				
			end
			
		end
		
		if tr.HitNonWorld then
			
			local hitEnt = tr.Entity;
			
			if IsValid(hitEnt) then
				
				--if (not hitEnt:IsPlayer()) or (hitEnt:IsPlayer() and hitEnt:Team() ~= attacker:Team()) then
					
					local dmg = DamageInfo();
					dmg:SetAttacker(attacker);
					dmg:SetInflictor(inflictor);
					dmg:SetDamage(laser.LASER_DAMAGE);
					dmg:SetDamageForce(tr.Normal * (force or 1));
					dmg:SetDamagePosition(tr.HitPos);
					dmg:SetDamageType(DMG_ENERGYBEAM);
					
					--hitEnt:TakeDamage(laser.LASER_DAMAGE, attacker, inflictor);
					hitEnt:TakeDamageInfo(dmg);
				--end
				
				if force then
					hitEnt:SetVelocity(tr.Normal * force);
				end
				
			end
			
		end
		
	end
	
end

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
	
	local effect = EffectData()
	
	effect:SetStart(pl:GetPos())
	effect:SetEntity(pl)
	
	if pl:Team() == laser.TEAM_RED then
		util.Effect("redlaserdeath",effect)
	else
		util.Effect("bluelaserdeath",effect)
	end
	
end

local function StartPlayerSpectate(pl, attacker)
	
	if IsValid(attacker) and attacker:IsPlayer() then
		
		pl:SendLua([[surface.PlaySound("misc/freeze_cam.wav")]]);
		
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
	
	user:Give("weapon_laser");
	--user:Give("weapon_lasergun");
	--user:Give("weapon_fastlaser");
	--user:Give("weapon_shotgunlaser");
	--user:Give("weapon_sniperlaser");
	user:ShouldDropWeapon(false);
	user:SetNoCollideWithTeammates(true);
	user:SetWalkSpeed(450);
	user:SetRunSpeed(450);
	user:SetCrouchedWalkSpeed(0.33);
	user:SetJumpPower(240);
	user:UnSpectate();
	
	local teamColor = team.GetColor(user:Team());
	user:SetPlayerColor( Vector(teamColor.r / 255, teamColor.g / 255, teamColor.b / 255) );
	
	if user:Team() == 1 then
		user:SetModel(RedPlayerModels[math.random(1,#RedPlayerModels)])
	else
		user:SetModel(BluePlayerModels[math.random(1,#BluePlayerModels)])
	end
	
	--user.Trail = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt")
	user.Trail = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 0, 64, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt")
	
end

function GM:PlayerDeath(user,wep,atk)
	
	user:SetNWFloat('laser_nextRespawn', CurTime() + laser.MIN_DEATH_TIME);
	user.KillingSpree = 0;
	
	SafeRemoveEntity(user.Trail);
	
	if user ~= atk then
		if atk:IsPlayer() then
			
			--AddMessageAll(atk:Nick().. " pulverized "..user:Nick().."!",3)
			local message = PlayerKillMessages[math.random(1,#PlayerKillMessages)];
			message = string.gsub(message,">a", atk:Nick());
			message = string.gsub(message,">v", user:Nick());
			AddMessageAll(message, 3);
			
			atk.KillingSpree = atk.KillingSpree + 1
			DetermineKillingSpree(atk);
			
			PlayerLaserExplosion(user);
			StartPlayerSpectate(user, atk);
			
		else
			
			AddMessageAll(user:Nick() .. " kicked the bucket...", 3);
			StartPlayerSpectate(user);
			
		end
	else
		
		AddMessageAll(user:Nick() .. " ended it all!!", 3);
		PlayerLaserExplosion(user);
		StartPlayerSpectate(user);
		
	end
	
	-- Gibs
	if atk:IsPlayer() then
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
	
end

function GM:PlayerDeathThink(ply)
	
	-- Disallow respawn before laser.MIN_DEATH_TIME seconds.
	if CurTime() < ply:GetNWFloat('laser_nextRespawn') then return end
	
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
	local dmg = math.max((speed - 750) / 50, 0);
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

hook.Add("Think", "laser_RoundCheckThink", function()
	
	local roundOver = false;
	
	if (laser.GetTeamFrags(laser.TEAM_RED) >= laser.TeamGoal) and (not GetGlobalBool("roundover")) then
		
		SetGlobalFloat("winteam", laser.TEAM_RED);
		roundOver = true;
		
	elseif (laser.GetTeamFrags(laser.TEAM_BLUE) >= laser.TeamGoal) and (not GetGlobalBool("roundover")) then
		
		SetGlobalFloat("winteam", laser.TEAM_BLUE);
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
hook.Add("Think", "laser_Evenizer", function()
	
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