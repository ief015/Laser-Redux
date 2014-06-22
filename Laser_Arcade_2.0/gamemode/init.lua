AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

GM.Name = "Laser Arcade 2.0"

//local newmap, MapList="",{};

//local mapfinder = file.Find( "^/maps/la_*.bsp");

  //=====================================================================//
 // Yes this is the teamspawning script, pain in the ass to code this   // 
//=====================================================================//

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

//Map Change scripts cause we need them

//-------------------------Old Script Start
//function PickNextMap()
//	for k, v in ( mapfinder ) do
//		MapList[k]="mapfinder"
//	end
//
//	newmap = table.Random(MapList);
//
//	while(string.find( string.lower( game.GetMap() ), newmap )) do
//		newmap = table.Random(MapList);
//	end
//
//	game.ConsoleCommand( "changelevel " ..newmap )
//	Msg("changelevel " ..newmap )
//end
//-----------------------Old Script End

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

hook.Add( "PickNextMap",PickNextMap )

  //================================================================//
 //                                                                //
//================================================================//

function GM:PlayerSpawn(user)
	if user:Team() > 2 then
		if team.NumPlayers(1) > team.NumPlayers(2) then
			user:SetTeam(2)
		else
			user:SetTeam(1)
		end
		user.KillingSpree = 0
		user.Trail = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt")
	end
	
	if user:Team() == 1 then 
		user:Give("weapon_laser")
		user:SetModel(RedPlayerModels[math.random(1,#RedPlayerModels)])
		user:ShouldDropWeapon(false)
	else 
		user:Give("weapon_laser")
		user:SetModel(BluePlayerModels[math.random(1,#BluePlayerModels)])
		user:ShouldDropWeapon(false)
	end
end

RedPlayerModels = {"models/player/combine_super_soldier.mdl","models/player/combine_soldier.mdl"}
BluePlayerModels = {"models/player/monk.mdl","models/player/breen.mdl"}

PlayerKillMessages = {">v got pulverized by >a!!", -- >v == victim, >a == attacker
">a OWNED >v!!",
">v got obliterated by >a!!",
">v had no chance against >a!!",
">a humiliated >v!!"}

KillingSprees = {}
KillingSprees[2] = "Double kill!"
KillingSprees[3] = "Triple kill!"
KillingSprees[4] = "Multi kill!"
KillingSprees[5] = "Killing Spree!!"
KillingSprees[6] = "Monster kill!!"
KillingSprees[8] = "Unstoppable!"
KillingSprees[10] = "Godlike!!!"
KillingSprees[14] = "HOLY MELONS!!!!!!"

function GM:PlayerDeath(user,wep,atk)
	
	if user != atk then
		if atk:IsPlayer() then
			local pos = user:GetPos()
			
			local effect = EffectData()
			effect:SetStart(pos)
			effect:SetEntity(user)
			if(user:Team()==1) then
				util.Effect("redlaserdeath",effect)
			else
				util.Effect("bluelaserdeath",effect)
			end
			
			--AddMessageAll(atk:Nick().. " pulverized "..user:Nick().."!",3)
			local message = PlayerKillMessages[math.random(1,#PlayerKillMessages)]
			local message = string.gsub(message,">a",atk:Nick())
			local message = string.gsub(message,">v",user:Nick())
			AddMessageAll(message,3)
			
			user.KillingSpree = 0
			atk.KillingSpree = atk.KillingSpree + 1
			DetermineKillingSpree(atk)

		else
			user.KillingSpree = 0
			AddMessageAll(user:Nick().. " kicked the bucket...",3)
		end
	else
		user.KillingSpree = 0
		AddMessageAll(user:Nick().. " ended it all!!",3)
		
			local effect = EffectData()
			effect:SetStart(user:GetPos())
			effect:SetEntity(user)
			if(user:Team()==1) then
				util.Effect("redlaserdeath",effect)
			else
				util.Effect("bluelaserdeath",effect)
			end
	end
	
	if true then --player gibs
		local t = ents.Create("prop_ragdoll")
		local l = ents.Create("prop_ragdoll")
		if !(t:IsValid() && l:IsValid()) then return end
		
		user:GetRagdollEntity():Remove() //Remove player ragdoll
		
		t:SetModel("models/Gibs/Fast_Zombie_Torso.mdl")
		l:SetModel("models/Gibs/Fast_Zombie_Legs.mdl")
		t:SetKeyValue( "origin", user:GetPos().x .. " " .. user:GetPos().y .. " " .. user:GetPos().z+0 )
		l:SetKeyValue( "origin", user:GetPos().x .. " " .. user:GetPos().y .. " " .. user:GetPos().z+0 )
		t:SetAngles(user:GetAngles())
		l:SetAngles(user:GetAngles())
		t:Spawn()
		l:Spawn()
		t:SetCollisionGroup(COLLISION_GROUP_WORLD)
		l:SetCollisionGroup(COLLISION_GROUP_WORLD)
		t:Activate()
		l:Activate()
		t:GetPhysicsObject():SetVelocity(user:GetVelocity())
		l:GetPhysicsObject():SetVelocity(user:GetVelocity())
		
		SafeRemoveEntityDelayed( t, 10 ) //Removes gibs after 10 seconds
		SafeRemoveEntityDelayed( l, 10 )

	end
end


function DetermineKillingSpree(user)
	for k,v in pairs(KillingSprees) do
		if k == user.KillingSpree then
			AddMessage(user,user:Nick()..": "..v,5)
		end
	end
end


function GM:PlayerShouldTakeDamage(user,atk)
	if atk:IsPlayer() && (user:Team() == atk:Team()) then return false else return true end
end

function GM:GetFallDamage(ply, fspeed)
	return 0
end

function GetTeamFrags(pteam) -- Counts up all the players in a team's frags and returns them combined
	curFrags = 0
	for k,v in pairs(team.GetPlayers(pteam)) do
		curFrags = curFrags + v:Frags()
	end
	timer.Simple(0.5,function() curFrags = 0 end) -- Delay it slightly, so this doesn't stay filled. Globals. :|
	return curFrags
end

function AddMessage(user,msg,life)
	user:SendLua([[AddMessage("]]..msg..[[",]]..life..[[)]])
end

function AddMessageAll(msg,life)
	for k,v in pairs(player.GetAll()) do
		AddMessage(v,msg,life)
	end
end

function AddMessageTeam(pteam,msg,life)
	for k,v in pairs(team.GetPlayers(pteam)) do
		AddMessage(v,msg,life)
	end
end

function RoundCheckThink()
	if (GetTeamFrags(1) >= TeamGoal) and (!GetGlobalBool("roundover")) then
		for k,v in pairs(player.GetAll()) do
			v:Lock()
		end
		SetGlobalFloat("winteam",1)
		SetGlobalBool("roundover",true)
		SetGlobalFloat("changein",CurTime() + IntermissionTime)
		timer.Simple(IntermissionTime, PickNextMap)
	elseif (GetTeamFrags(2) >= TeamGoal) and (!GetGlobalBool("roundover")) then
		for k,v in pairs(player.GetAll()) do
			v:Lock()
		end
		SetGlobalFloat("winteam",2)
		SetGlobalBool("roundover",true)
		SetGlobalFloat("changein",CurTime() + IntermissionTime)  
		timer.Simple(IntermissionTime, PickNextMap)
	end
end
hook.Add("Think","Round Check Thing",RoundCheckThink)

function Evenizer() -- When someone disconnects, the teams will get disrupted. As an example, the game could be 4 on 2. This will help even out the teams.
	if !GetGlobalEntity("evenized"):IsValid() then
		if (team.NumPlayers(1) > team.NumPlayers(2)) and ((team.NumPlayers(1) - team.NumPlayers(2)) >= 2) then
			local rteam = team.GetPlayers(1)
			local victim = rteam[math.random(1,#rteam)]
			SetGlobalEntity("evenized",victim)
			timer.Simple(EvenizeDelay + 1,function(user) ResetTrail(user) SetGlobalEntity("evenized",NULL) user:SetTeam(2) user:AddFrags(user:Frags() * -1) user:Kill() AddMessageAll(user:Nick().." Has been EVENIZED!",5) end, victim)
		end
		if (team.NumPlayers(2) > team.NumPlayers(1)) and ((team.NumPlayers(2) - team.NumPlayers(1)) >= 2) then
			local bteam = team.GetPlayers(2)
			local victim = bteam[math.random(1,#bteam)]
			SetGlobalEntity("evenized",victim)
			timer.Simple(EvenizeDelay + 1,function(user) SetGlobalEntity("evenized",NULL) ResetTrail(user) user:AddFrags(user:Frags() * -1) user:SetTeam(1) user:Kill() AddMessageAll(user:Nick().." Has been EVENIZED!",5) end, victim)
		end
	end
end
hook.Add("Think","Evenizer",Evenizer)

function ResetTrail(user)
	print("CALL!")
	user.Trail:Remove()
	timer.Simple(0.2,function(user) user.Trail = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt") end,user)
end

function EvenizePlayer(user,nteam)
	SetGlobalEntity("evenized",victim)
	timer.Simple(EvenizeDelay + 1,function(user) SetGlobalEntity("evenized",NULL) user.Trail:Remove() user.Trail = util.SpriteTrail(user, 0, team.GetColor(user:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt") user:AddFrags(user:Frags() * -1) user:SetTeam(1) user:Kill() AddMessageAll(user:Nick().." Has been EVENIZED!",5) end, user)
end	
		
