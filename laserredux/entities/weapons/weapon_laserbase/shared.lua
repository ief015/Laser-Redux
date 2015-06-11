if SERVER then
	AddCSLuaFile();
	SWEP.HoldType = "ar2";
end

if CLIENT then
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
	SWEP.PrintName = "Laser Base";
	SWEP.Author	= "ief015";
	SWEP.Slot = 0;
	SWEP.SlotPos = 0;
	SWEP.IconLetter = "c";
	SWEP.ViewModelFlip = false;
	killicon.AddFont("Laser Base", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255));
end

SWEP.Base                  = "weapon_base";

SWEP.Spawnable             = true;
SWEP.AdminSpawnable        = true;

SWEP.ViewModel             = "models/weapons/v_pistol.mdl";
SWEP.WorldModel            = "models/weapons/w_pistol.mdl";

SWEP.Weight                = 5;
SWEP.AutoSwitchTo          = false;
SWEP.AutoSwitchFrom        = false;

SWEP.Primary.ClipSize      = -1;
SWEP.Primary.DefaultClip   = -1;
SWEP.Primary.Automatic     = false;
SWEP.Primary.Ammo          = "none";

SWEP.Secondary.ClipSize    = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic   = false;
SWEP.Secondary.Ammo        = "none";

-- Laser Redux specific parameters.

SWEP.CooldownMessage = "Cooldown";

SWEP.Primary.AllowHeadshots = true;
SWEP.Primary.Anim           = ACT_VM_PRIMARYATTACK;
SWEP.Primary.Cone           = 0.02;
SWEP.Primary.Delay          = 0.125;
SWEP.Primary.Kickback       = 150;
SWEP.Primary.NumShots       = 1;
SWEP.Primary.Recoil         = 0;
SWEP.Primary.Sound          = Sound("Weapon_Pistol.Single");
SWEP.Primary.UseCooldown    = false;
SWEP.Primary.Offset         = Vector(0, 0, 6);

SWEP.Secondary.AllowHeadshots = false;
SWEP.Secondary.Anim           = ACT_VM_SECONDARYATTACK;
SWEP.Secondary.Cone           = 0.04;
SWEP.Secondary.Delay          = 2.5;
SWEP.Secondary.Kickback       = 600;
SWEP.Secondary.NumShots       = 6;
SWEP.Secondary.Recoil         = 2;
SWEP.Secondary.Sound          = Sound("weapons/flaregun/fire.wav");
SWEP.Secondary.UseCooldown    = true;
SWEP.Secondary.Offset         = Vector(0, 0, 6);

--[[
function SWEP:ShootLaser(xcone, ycone, kickback, offset)
	
	if SERVER then
		
		ycone = (ycone == nil) and xcone or ycone;
		
		FireLaser(self.Owner, self.Weapon, { self.Owner },
		          self.Owner:GetShootPos() - (offset or Vector(0, 0, 0)),
		          (self.Owner:GetAimVector() + Vector(math.Rand(-xcone, xcone), math.Rand(-xcone, xcone), math.Rand(-ycone, ycone))),
		          kickback);
		
	end
	
end]]

function SWEP:ShootLaser(kickback, xcone, ycone, offset)
	
	if SERVER then
		
		ycone = (ycone == nil) and xcone or ycone;
		
		laser.FireLaser(team.GetColor(self.Owner:Team()), { self.Owner },
		          self.Owner:GetShootPos() - (offset or Vector(0, 0, 0)),
		          (self.Owner:GetAimVector() + Vector(math.Rand(-xcone, xcone), math.Rand(-xcone, xcone), math.Rand(-ycone, ycone))),
		          kickback);
		
	end
	
end

function SWEP:GetCooldownProgress()
	
	if not self:GetCoolingDown() then
		return 0;
	end
	
	local start = self:GetCoolingStartTime();
	
	return math.min((CurTime() - start) / (self:GetCoolingEndTime() - start), 1);
	
end

function SWEP:StartCooldown(duration)
	
	local st  = CurTime();
	local et = st + duration;
	
	self:SetCoolingDown(true);
	self:SetCoolingStartTime(st);
	self:SetCoolingEndTime(et);
	
	return et;
	
end

function SWEP:IsReadyToFire()
	
	return (CurTime() > self:GetNextFire() and not self:GetCoolingDown());
	
end

function SWEP:SetupDataTables()
	
	self:NetworkVar('Float', 0, 'NextFire');
	self:NetworkVar('Bool', 0, 'CoolingDown');
	self:NetworkVar('Float', 1, 'CoolingStartTime');
	self:NetworkVar('Float', 2, 'CoolingEndTime');
	
	self:ExtraSetupDataTables();
	
end

function SWEP:ExtraSetupDataTables()
	-- Slots 0->2 are reserved for baselaser! It is recommended you use a higher slot.
end

function SWEP:FinishedCooldown()
	
end

function SWEP:PreAttack(isPrimary)
	
end

function SWEP:PostAttack(isPrimary)
	
end

function SWEP:OnThink()
	
end

function SWEP:PrimaryAttack()
	
	-- Can we fire yet?
	if not self:CanPrimaryAttack() then return end
	self.Owner:LagCompensation(true);
	
	self:PreAttack(true);
	
	-- Fire animation and sounds.
	self.Weapon:SendWeaponAnim(self.Primary.Anim);
	self.Weapon:EmitSound(self.Primary.Sound, 120, 60);
	self.Owner:ViewPunch(Angle(-self.Primary.Recoil, 0, 0));
	
	if SERVER then
		
		-- Shoot the lasers.
		laser.StartLasers(self.Owner, self.Weapon, self.Primary.AllowHeadshots);
		for i = 1, self.Primary.NumShots do
			self:ShootLaser(self.Primary.Kickback / self.Primary.NumShots, self.Primary.Cone, self.Primary.Cone, self.Primary.Offset);
		end
		laser.EndLasers();
		
		-- Send our playing flying back.
		self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Primary.Kickback);
		
	end
	
	-- Set when allowed to fire next.
	if self.Primary.UseCooldown then
		self:SetNextFire(self:StartCooldown(self.Primary.Delay));
	else
		self:SetNextFire(CurTime() + self.Primary.Delay);
	end
	
	self:PostAttack(true);
	
	self.Owner:LagCompensation(false);
	
end

function SWEP:SecondaryAttack()
	
	-- Can we fire yet?
	if not self:CanSecondaryAttack() then return end
	self.Owner:LagCompensation(true);
	
	self:PreAttack(false);
	
	-- Fire animation and sounds.
	self.Weapon:SendWeaponAnim(self.Secondary.Anim);
	self.Weapon:EmitSound(self.Secondary.Sound, 120, 60);
	self.Owner:ViewPunch(Angle(-self.Secondary.Recoil, 0, 0));
	
	if SERVER then
		
		-- Shoot the lasers.
		laser.StartLasers(self.Owner, self.Weapon, self.Secondary.AllowHeadshots);
		for i = 1, self.Secondary.NumShots do
			self:ShootLaser(self.Secondary.Kickback / self.Secondary.NumShots, self.Secondary.Cone, self.Secondary.Cone, self.Secondary.Offset);
		end
		laser.EndLasers();
		
		-- Send our playing flying back.
		self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Secondary.Kickback);
		
	end
	
	-- Set when allowed to fire next.
	if self.Secondary.UseCooldown then
		self:SetNextFire(self:StartCooldown(self.Secondary.Delay));
	else
		self:SetNextFire(CurTime() + self.Secondary.Delay);
	end
	
	self:PostAttack(false);
	
	self.Owner:LagCompensation(false);
	
end

function SWEP:Think()
	
	if self:GetCoolingDown() then
		
		if CurTime() >= self:GetCoolingEndTime() then
			
			self:SetCoolingDown(false);
			self:FinishedCooldown()
			
		end
	end
	
	self:OnThink();
	
end

function SWEP:CanPrimaryAttack()
	
	return self:IsReadyToFire();
	
end

function SWEP:CanSecondaryAttack()
	
	return self:IsReadyToFire();
	
end