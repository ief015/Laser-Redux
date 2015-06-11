util.AddNetworkString('lr_LaserEffect');

local laserData = {
	Queue          = {},
	AllowHeadshots = false,
	Attacker       = NULL,
	Inflictor      = NULL,
	Started        = false,
};

local dmgQueue = {};


--[[
function laser.StartLasers(attacker, inflictor)
	
	table.Empty(laserData.Queue);
	
	if IsValid(attacker) then
		laserData.Attacker = attacker;
	else
		laserData.Attacker = NULL;
	end
	
	if IsValid(inflictor) then
		laserData.Inflictor = inflictor;
	else
		laserData.Inflictor = NULL;
	end
	
	laserData.Started = true;
	
end

function laser.FireLaser(colour, filter, pos, dir, force, range)
	
	if not laserData.Started then return end
	
	local queue = laserData.Queue; 
	local tr = util.TraceLine({
		start  = pos,
		endpos = pos + (dir * ((range == nil or range == 0) and (4096*8) or range)),
		filter = filter,
	});
	
	table.insert(queue, {
		start  = tr.StartPos,
		origin = tr.HitPos,
		colour = colour,
	});
	
	if tr.HitNonWorld then
		
		local hitEnt = tr.Entity;
		
		if IsValid(hitEnt) then
			
			local atk = laserData.Attacker;
			
			--if (not hitEnt:IsPlayer()) or (hitEnt:IsPlayer() and hitEnt:Team() ~= attacker:Team()) then
				
				local dmg = DamageInfo();
				dmg:SetAttacker(atk);
				dmg:SetInflictor(laserData.Inflictor);
				dmg:SetDamage(laser.LASER_DAMAGE);
				dmg:SetDamageForce(tr.Normal * (force or 1));
				dmg:SetDamagePosition(tr.HitPos);
				dmg:SetDamageType(DMG_ENERGYBEAM);
				
				--hitEnt:TakeDamage(laser.LASER_DAMAGE, attacker, inflictor);
				hitEnt:TakeDamageInfo(dmg);
				
				if IsValid(atk) and atk:IsPlayer() and hitEnt:IsPlayer() and atk:Team() ~= hitEnt:Team() then
					
					if tr.HitGroup == HITGROUP_HEAD then
						
						hitEnt:EmitSound(Sound('laserredux/mlestn1_pop.wav'));
						atk:ConCommand('play laserredux/mlestn1_pop2.wav');
						--PrintMessage(HUD_PRINTTALK, atk:Nick() .. " headshot " .. hitEnt:Nick());
						
					end
					
				end
				
			--end
			
			if force ~= nil then
				hitEnt:SetVelocity(tr.Normal * force);
			end
			
		end
		
	end
	
end

function laser.EndLasers(isUnreliable)
	
	if not laserData.Started then return end
	if isUnreliable == nil then isUnreliable = false; end
	
	local queue = laserData.Queue;
	local count = math.min(#queue, 256) - 1;
	
	net.Start('laser_laserEffect', isUnreliable);
	net.WriteUInt(count, 8);
	for k,v in pairs(queue) do
		net.WriteVector(v.start);
		net.WriteVector(v.origin);
		net.WriteUInt(v.colour.r, 8);
		net.WriteUInt(v.colour.g, 8);
		net.WriteUInt(v.colour.b, 8);
	end
	net.Broadcast();
	
	laserData.Started = false;
	
end
]]













function laser.StartLasers(attacker, inflictor, allowHeadshots)
	
	if allowHeadshots == nil then
		allowHeadshots = false;
	end
	laserData.AllowHeadshots = allowHeadshots;
	
	if IsValid(attacker) then
		laserData.Attacker = attacker;
	else
		laserData.Attacker = NULL;
	end
	
	if IsValid(inflictor) then
		laserData.Inflictor = inflictor;
	else
		laserData.Inflictor = NULL;
	end
	
	table.Empty(laserData.Queue);
	laserData.Started = true;
	
end

function laser.FireLaser(colour, filter, pos, dir, force, range)
	
	if not laserData.Started then return end
	
	table.insert(laserData.Queue, {
		colour = colour,
		filter = filter,
		pos    = pos,
		dir    = dir,
		force  = force,
		range  = range,
	});
	
end

function laser.EndLasers(isUnreliable)
	
	if not laserData.Started then return end
	if isUnreliable == nil then isUnreliable = false; end
	
	local atk = laserData.Attacker;
	local inflictor = laserData.Inflictor;
	
	local queue = laserData.Queue;
	local count = math.min(#queue, 256) - 1;
	
	local playSound = 0; -- 0=none, 1=normal, 2=head
	
	net.Start('lr_laserEffect', isUnreliable);
	net.WriteUInt(count, 8);
	for k,v in ipairs(queue) do
		
		local tr = util.TraceLine({
			start  = v.pos,
			endpos = v.pos + (v.dir * ((v.range == nil or v.range == 0) and (4096*8) or v.range)),
			filter = v.filter,
		});
		
		v.tr = tr;
		
		net.WriteVector(tr.StartPos);
		net.WriteVector(tr.HitPos);
		net.WriteUInt(v.colour.r, 8);
		net.WriteUInt(v.colour.g, 8);
		net.WriteUInt(v.colour.b, 8);
		
	end
	net.Broadcast();
	
	for k,v in ipairs(queue) do
		
		local tr = v.tr;
		
		if tr.HitNonWorld then
			
			local hitEnt = tr.Entity;
			
			if IsValid(hitEnt) then
				
				if v.force ~= nil then
					
					if hitEnt:IsPlayer() then
						
						hitEnt:SetLocalVelocity(hitEnt:GetVelocity() + (tr.Normal * v.force));
						
					else
						
						local physobj = hitEnt:GetPhysicsObject();
						
						if IsValid(physobj) then
							physobj:ApplyForceCenter(tr.Normal * v.force);
						end
						
					end
					
					--[[
					local physobj = hitEnt:GetPhysicsObject();
					if IsValid(physobj) then
						--physobj:Wake();
						--physobj:SetVelocity(hitEnt:GetVelocity() + (tr.Normal * v.force));
						physobj:AddVelocity(tr.Normal * v.force);
						PrintMessage(HUD_PRINTTALK, "phys");
					else
						hitEnt:SetVelocity(hitEnt:GetVelocity() + (tr.Normal * v.force));
						PrintMessage(HUD_PRINTTALK, "no phys");
					end
					]]
				end
				
				--if (not hitEnt:IsPlayer()) or (hitEnt:IsPlayer() and hitEnt:Team() ~= attacker:Team()) then
					
					
					local dmg = DamageInfo();
					dmg:SetAttacker(atk);
					dmg:SetInflictor(inflictor);
					dmg:SetDamage(laser.LASER_DAMAGE);
					dmg:SetDamageForce(tr.Normal * (force or 1));
					dmg:SetDamagePosition(tr.HitPos);
					dmg:SetDamageType(DMG_ENERGYBEAM);
					
					if IsValid(atk) and atk:IsPlayer() and hitEnt:IsPlayer() and atk:Team() ~= hitEnt:Team() then
						
						if tr.HitGroup == HITGROUP_HEAD and laserData.AllowHeadshots then
							
							hitEnt:EmitSound(Sound('laserredux/mlestn1_pop3.wav'));
							dmg:ScaleDamage(2);
							
							hitEnt.KilledByHeadshot = true;
							playSound = 2;
							
						else
							
							if playSound == 0 then
								playSound = 1;
							end
							
						end
						
					end
					
					--hitEnt:TakeDamageInfo(dmg); -- We do this in the Think hook 'laser_FireOffLasers'
					table.insert(dmgQueue, {
						dmginfo = dmg,
						ent     = hitEnt,
					});
					
				--end
				
			end
			
		end
		
	end
	
	if IsValid(atk) then
		
		if playSound == 1 then
			
			atk:ConCommand('play physics/flesh/flesh_impact_bullet5.wav');
			
		elseif playSound == 2 then
			
			atk:ConCommand('play laserredux/mlestn1_pop3.wav');
			
		end
		
	end
	
	laserData.Started = false;
	
end

hook.Add('Think', 'lr_FireOffLasers', function()
	
	if laserData.Started then return end
	
	local n = #dmgQueue;
	
	for i=1, n do
		local v = dmgQueue[1];
		v.ent:TakeDamageInfo(v.dmginfo);
		table.remove(dmgQueue, 1);
	end
	
end);

--[[
hook.Add('EntityTakeDamage', 'laser_LaserDamage', function(victim, dmginfo)
	
	
	
end);
]]
--[[
hook.Add('PlayerDeath', 'laser_LaserKill', function(victim, weapon, attacker)
	
	
	
end);
]]
















-- FireLaser(Entity attacker, Entity inflictor, Entity|Table filter, Vector pos, Vector dir, number force, number range = 0)
-- Fire a laser and inflict some damage.
--[[
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
]]