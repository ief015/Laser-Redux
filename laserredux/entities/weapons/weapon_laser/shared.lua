--[[
if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "ar2"
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Laser Nonce"
	SWEP.Author	= "Gmod4ever"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.IconLetter = "c"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Laser Nonce", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "weapon_laserbase"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_famas.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Sound			= Sound("npc/sniper/sniper1.wav")
SWEP.Primary.Recoil			= 2.0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay			= 0.25

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextFire = 0
SWEP.Kickback = 400


function SWEP:ShootLaser(cone)
	
	if SERVER then
		FireLaser(self.Owner, self.Weapon, self.Owner,
		          self.Owner:GetShootPos() - Vector(0, 0, 10),
		          (self.Owner:GetAimVector() + Vector(math.Rand(-cone, cone), math.Rand(-cone, cone),math.Rand(-cone, cone))),
		          self.Kickback);
		
	end
	
end

-- Tell us to draw a bar
function SWEP:SendProgBar(endt)
	if SERVER then
		umsg.Start("laser_progbar",self.Owner)
		umsg.String(CurTime())
		umsg.String(CurTime() + endt)
		umsg.End()
	end
end

-- Single shot
function SWEP:PrimaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		self.Weapon:EmitSound(self.Primary.Sound,120,60)
		
		local tr = util.GetPlayerTrace(self.Owner,self.Owner:GetAimVector())
		local tr = util.TraceLine(tr)
		
		self:ShootLaser(self.Owner:GetShootPos() - Vector(0,0,10), tr.HitPos, self.Owner:GetAimVector())
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.NextFire = CurTime() + self.Primary.Delay
		
		if SERVER then
			self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Kickback)
		end
		self.Owner:LagCompensation(false)
	end
end

SWEP.MaxShots = 12
SWEP.MaxOff = 0.15
SWEP.ShotgunSound = Sound("weapons/shotgun/shotgun_dbl_fire.wav")
-- Secondary attack is a shotgun-like effect
function SWEP:SecondaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.NextFire = CurTime() + (self.Primary.Delay * 20)
		
		self.Weapon:EmitSound(self.ShotgunSound,120,60)
		for i=1,self.MaxShots do
			local ang = self.Owner:GetAimVector() + Vector(math.Rand(-self.MaxOff,self.MaxOff),math.Rand(-self.MaxOff,self.MaxOff),math.Rand(-self.MaxOff,self.MaxOff))
			local tr = util.GetPlayerTrace(self.Owner,ang)
			local tr = util.TraceLine(tr)
			
			self:ShootLaser(self.Owner:GetShootPos() - Vector(0,0,0), tr.HitPos, ang)
		end
		
		self:SendProgBar(self.Primary.Delay * 20)
		if SERVER then
			self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * (self.Kickback * 2)) -- Double kickback
		end
		self.Owner:LagCompensation(false)
	end
end

-- ! CLientside stuff --
-- Retrieve umsg for bar

function RetrieveProgBar(msg)
	if CLIENT then
		Freeze = tonumber(msg:ReadString())
		End = tonumber(msg:ReadString())
		DrawingBar = true
	end
end
usermessage.Hook("laser_progbar",RetrieveProgBar)

function SWEP:DrawHUD()
	if DrawingBar then
		if CurTime() < End then
			local scale = (CurTime() - Freeze) / (End - Freeze)
			
			draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, ScrW() * 0.4, ScrH() * 0.04, Color(100,100,100,255))
			draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, (ScrW() * 0.4) * scale, ScrH() * 0.04, Color(0,100,0,255))
			draw.SimpleText("Recharging", "Font_40", ScrW() * 0.5, ScrH() * 0.04, Color(255,255,255,255), 1)
		else
			DrawingBar = false
		end
	end
end
]]



--[[
Laser Nonce

This standard issue weapon is a pinpoint accurate semi-automatic Nonce that
is applicable in almost any situation. Its alternative fire-mode is a
powerful burst of lasers for those desperate CQC moments.
]]

if SERVER then
	AddCSLuaFile();
	SWEP.HoldType = "ar2";
end

if CLIENT then
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = false;
	SWEP.PrintName = "Laser Nonce";
	SWEP.Author	= "ief015, Gmod4Ever";
	SWEP.Slot = 0;
	SWEP.SlotPos = 0;
	SWEP.IconLetter = "c";
	SWEP.ViewModelFlip = false;
	killicon.AddFont("Laser Nonce", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255));
end

SWEP.Base                  = "weapon_laserbase";

SWEP.Spawnable             = true;
SWEP.AdminSpawnable        = true;

SWEP.ViewModel             = "models/weapons/v_rif_famas.mdl";
SWEP.WorldModel            = "models/weapons/w_rif_famas.mdl";

SWEP.Weight                = 5;
SWEP.AutoSwitchTo          = false;
SWEP.AutoSwitchFrom        = false;

SWEP.Primary.AllowHeadshots = true;
SWEP.Primary.Anim           = ACT_VM_PRIMARYATTACK;
SWEP.Primary.Cone           = 0;
SWEP.Primary.Delay          = 0.25;
SWEP.Primary.Kickback       = 400;
SWEP.Primary.NumShots       = 1;
SWEP.Primary.Recoil         = 0;
SWEP.Primary.Sound          = Sound("npc/sniper/sniper1.wav");
SWEP.Primary.UseCooldown    = false;

SWEP.Secondary.AllowHeadshots = false;
SWEP.Secondary.Anim           = ACT_VM_PRIMARYATTACK;
SWEP.Secondary.Cone           = 0.1;
SWEP.Secondary.Delay          = 5;
SWEP.Secondary.Kickback       = 600;
SWEP.Secondary.NumShots       = 12;
SWEP.Secondary.Recoil         = 3;
SWEP.Secondary.Sound          = Sound("weapons/shotgun/shotgun_dbl_fire.wav");
SWEP.Secondary.UseCooldown    = true;