IncludeCS 'shared.lua'

local SPAWNTYPE_FIREDONLY = 0;
local SPAWNTYPE_TIMER     = 1;
local SPAWNTYPE_ALWAYS    = 2;


hook.Add('EntityKeyValue', 'lr_kvWeaponSpawner', function(ent, key, val)
	
	if ent:GetClass() == 'lr_weapon_spawner' then
		
		if key == 'WeaponType' then
			ent.WeaponType = val;
		elseif key == 'SpawnType' then
			ent.SpawnType = tonumber(val);
		elseif key == 'StartSpawned' then
			ent.StartSpawned = (tonumber(val) ~= 0);
		elseif key == 'SpawnTimer' then
			ent.SpawnTimer   = tonumber(val);
		end
		
	end
	
end);

function ENT:Initialize()
	
	self.IsRandom = false;
	if self.WeaponType == nil then
		self.IsRandom = true;
	end
	if self.SpawnType == nil then
		self.SpawnType = SPAWNTYPE_TIMER;
	end
	if self.StartSpawned == nil then
		self.StartSpawned = true;
	end
	if self.SpawnTimer == nil then
		self.SpawnTimer = 15;
	end
	--[[
	self:PhysicsInitBox(Vector(-16,-16,-16), Vector(16,16,0));
	self:SetMoveType(MOVETYPE_NONE);
	self:SetSolid(SOLID_NONE);
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER);
	self:SetTrigger(true);
	]]
	self.IsSpawned = false;
	
	if self.StartSpawned then
		
		self.NextRespawn = CurTime();
		
	else
		
		self:ReloadWeaponType();
		
		self.NextRespawn = CurTime() + self.SpawnTimer;
		
	end
	
end
--[[
function ENT:Touch(ent)
	
	if not self.IsSpawned then return end
	
	if IsValid(ent) and ent:IsPlayer() then
		
		if not ent:HasWeapon(self.WeaponType) then
			
			self:Pickup(ent);
			
		end
		
	end
	
end
]]
function ENT:Think()
	
	if self.IsSpawned then
		
		for k,v in pairs(ents.FindInBox(self:GetPos() + Vector(-16,-16,-16), self:GetPos() + Vector(16,16,16))) do
			
			if IsValid(v) and v:IsPlayer() and v:Alive() then
				
				if not v:HasWeapon(self.WeaponType) then
					
					self:Pickup(v);
					
				end
				
			end
			
		end
		
		if IsValid(self.WeaponModel) then
			
			local ang = self.WeaponModel:GetAngles();
			ang:RotateAroundAxis(Vector(0,0,1), 2);
			self.WeaponModel:SetAngles(ang);
		end
		
	else
	
		if self.SpawnType == SPAWNTYPE_ALWAYS then
			
			self:RespawnWeapon();
			
		elseif self.SpawnType == SPAWNTYPE_TIMER then
			
			if CurTime() >= self.NextRespawn then
				self:RespawnWeapon();
			end
			
		end
		
	end
	
	self:NextThink(CurTime() + 0.05);
	return true;
	
end

function ENT:ReloadWeaponType()
	
	if self.IsRandom and (self.SpawnType ~= SPAWNTYPE_ALWAYS or self.WeaponType == nil) then
		self.WeaponType = table.Random({
			'weapon_fastlaser',
			'weapon_shotgunlaser',
			'weapon_sniperlaser',
			'weapon_laserminigun',
		});
	end
	
	if IsValid(self.WeaponModel) then
	
		local wepTable = weapons.Get(self.WeaponType);
		
		if wepTable ~= nil then
			self.WeaponModel:SetModel(Model(wepTable.WorldModel));
		else
			MsgC(Color(255, 90, 90), "lr_weapon_spawner: Could not retrieve weapon type '" .. wepType .. "'!\n");
		end
		
	end
	
end

function ENT:Pickup(pl)
	
	pl:Give(self.WeaponType);
	--pl:GiveAmmo(1, 'gravity'); -- To play pickup sound.
	pl:EmitSound(Sound("items/ammo_pickup.wav"))
	
	if self.WeaponModel:IsValid() then
		self.WeaponModel:Remove();
	end
	
	self.IsSpawned = false;
	
	if self.SpawnType == SPAWNTYPE_TIMER then
		
		self.NextRespawn = CurTime() + self.SpawnTimer;
		
	elseif self.SpawnType == SPAWNTYPE_ALWAYS then
		
		self:RespawnWeapon();
		
	end
	
end

function ENT:RespawnWeapon()
	
	if IsValid(self.WeaponModel) then
		self.WeaponModel:Remove();
	end
	
	if self.SpawnType ~= SPAWNTYPE_ALWAYS then
		self:EmitSound(Sound("NPC_RollerMine.Shock"), 1);
	end
	
	self.WeaponModel = ents.Create('prop_dynamic');
	self.WeaponModel:SetPos(self:GetPos());
	self:ReloadWeaponType();
	self.WeaponModel:SetMoveType(MOVETYPE_NONE);
	self.WeaponModel:SetSolid(SOLID_NONE);
	self.WeaponModel:Spawn();
	self.WeaponModel:Activate();
	
	self.IsSpawned = true;
	
end