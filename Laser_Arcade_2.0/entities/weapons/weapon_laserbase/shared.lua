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

SWEP.Primary.Anim          = ACT_VM_PRIMARYATTACK;
SWEP.Primary.Cone          = 0.01;
SWEP.Primary.Delay         = 0.5;
SWEP.Primary.Kickback      = 400;
SWEP.Primary.NumShots      = 1;
SWEP.Primary.Recoil        = 0;
SWEP.Primary.Sound         = Sound("npc/sniper/sniper1.wav");
SWEP.Primary.UseCooldown   = false;

SWEP.Secondary.Anim        = ACT_VM_SECONDARYATTACK;
SWEP.Secondary.Cone        = 0.04;
SWEP.Secondary.Delay       = 2.5;
SWEP.Secondary.Kickback    = 600;
SWEP.Secondary.NumShots    = 6;
SWEP.Secondary.Recoil      = 2;
SWEP.Secondary.Sound       = Sound("weapons/flaregun/fire.wav");
SWEP.Secondary.UseCooldown = true;

--[[
SWEP.NextFire              = 0;
SWEP.Cooldown              = {
	IsCooling              = false,
	StartTime              = 0,
	EndTime                = 0,
};]]

function SWEP:ShootLaser(xcone, ycone, kickback)
	
	if SERVER then
		
		ycone = (ycone == nil) and xcone or ycone;
		
		FireLaser(self.Owner, self.Weapon, { self.Owner },
		          self.Owner:GetShootPos() - Vector(0, 0, 6),
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

function SWEP:DrawCooldownBar()
	
	if self:GetCoolingDown() then
		
		local progress = self:GetCooldownProgress();
		
		draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, ScrW() * 0.4, ScrH() * 0.04, Color(100,100,100,255))
		draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, (ScrW() * 0.4) * progress, ScrH() * 0.04, Color(0,100,0,255))
		draw.SimpleText("Cooldown", "Font_40", ScrW() * 0.5, ScrH() * 0.04, Color(255,255,255,255), 1)
	end
	
end


--[[

function SWEP:GetNextFire()
	
	return self.Weapon:GetNWFloat('NextFire');
	
end

function SWEP:IsCoolingDown()
	
	return self.Weapon:GetNWBool('IsCoolingDown');
	
end

function SWEP:GetCoolingStartTime()
	
	return self.Weapon:GetNWFloat('CoolingStart');
	
end

function SWEP:GetCoolingEndTime()
	
	return self.Weapon:GetNWFloat('CoolingEnd');
	
end

function SWEP:GetCooldownProgress()
	
	if not self:IsCoolingDown() then
		return 0;
	end
	
	local start = self:GetCoolingStartTime();
	
	return math.min((CurTime() - start) / (self:GetCoolingEndTime() - start), 1);
	
end

if SERVER then
	
	function SWEP:StartCooldown(duration)
		
		local st  = CurTime();
		local et = st + duration;
		
		self:SetCoolingDown(true);
		self:SetCoolingStartTime(st);
		self:SetCoolingEndTime(et);
		
		return et;
		
	end
	
	function SWEP:SetNextFire(nextFire)
		
		self.Weapon:SetNWFloat('NextFire', nextFire);
		
	end
	
	function SWEP:SetCoolingDown(coolingDown)
		
		self.Weapon:SetNWBool('IsCoolingDown', coolingDown);
		
	end
	
	function SWEP:SetCoolingStartTime(startTime)
		
		self.Weapon:SetNWFloat('CoolingStart', startTime);
		
	end
	
	function SWEP:SetCoolingEndTime(endTime)
		
		self.Weapon:SetNWBool('CoolingEnd', endTime);
		
	end
	
end

function SWEP:Initialize()
	
	if SERVER then
		
		self:SetNextFire(0);
		self:SetCoolingDown(false);
		self:SetCoolingStartTime(0);
		self:SetCoolingEndTime(0);
		
	end
	
end

]]

function SWEP:SetupDataTables()
	
	self:NetworkVar('Float', 0, 'NextFire');
	self:NetworkVar('Bool', 0, 'CoolingDown');
	self:NetworkVar('Float', 1, 'CoolingStartTime');
	self:NetworkVar('Float', 2, 'CoolingEndTime');
	
	if self.ExtraSetupDataTables then
		self:ExtraSetupDataTables();
	end
	
end

function SWEP:PrimaryAttack()
	
	-- Can we fire yet?
	if not self:CanPrimaryAttack() then return end
	self.Owner:LagCompensation(true);
	
	-- Fire animation and sounds.
	self.Weapon:SendWeaponAnim(self.Primary.Anim);
	self.Weapon:EmitSound(self.Primary.Sound, 120, 60);
	
	if SERVER then
		
		-- Shoot the lasers.
		for i = 1, self.Primary.NumShots do
			self:ShootLaser(self.Primary.Cone, self.Primary.Cone, self.Primary.Kickback);
		end
		
		-- Send our playing flying back.
		self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Primary.Kickback);
	end
	
	self.Owner:ViewPunch(Angle(-self.Primary.Recoil, 0, 0));
	
	-- Set when allowed to fire next.
	if self.Primary.UseCooldown then
		self:SetNextFire(self:StartCooldown(self.Primary.Delay));
	else
		self:SetNextFire(CurTime() + self.Primary.Delay);
	end
	
	self.Owner:LagCompensation(false);
	
end

function SWEP:SecondaryAttack()
	
	-- Can we fire yet?
	if not self:CanSecondaryAttack() then return end
	self.Owner:LagCompensation(true);
	
	-- Fire animation and sounds.
	self.Weapon:SendWeaponAnim(self.Secondary.Anim);
	self.Weapon:EmitSound(self.Secondary.Sound, 120, 60);
	
	
	if SERVER then
		
		-- Shoot the lasers.
		for i = 1, self.Secondary.NumShots do
			self:ShootLaser(self.Secondary.Cone, self.Secondary.Cone, self.Secondary.Kickback);
		end
		
		-- Send our playing flying back.
		self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Secondary.Kickback);
	end
	
	self.Owner:ViewPunch(Angle(-self.Secondary.Recoil, 0, 0));
	
	-- Set when allowed to fire next.
	if self.Secondary.UseCooldown then
		self:SetNextFire(self:StartCooldown(self.Secondary.Delay));
	else
		self:SetNextFire(CurTime() + self.Secondary.Delay);
	end
	
	self.Owner:LagCompensation(false);
	
end

function SWEP:Think()
	
	if self:GetCoolingDown() then
		
		if CurTime() >= self:GetCoolingEndTime() then
			
			self:SetCoolingDown(false);
			
		end
	end
	
end

function SWEP:CanPrimaryAttack()
	
	return (CurTime() > self:GetNextFire() and not self:GetCoolingDown());
	
end

function SWEP:CanSecondaryAttack()
	
	return self:CanPrimaryAttack();
	
end

function SWEP:DrawHUD()
	
	self:DrawCooldownBar();
	
end