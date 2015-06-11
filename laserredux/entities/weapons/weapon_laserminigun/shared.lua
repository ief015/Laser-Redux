--[[
local shotnumber=0;

if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "ar2"
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
	SWEP.PrintName = "Mini-Laser Gun"
	SWEP.Author	= "rcdraco"
	SWEP.Slot = 4
	SWEP.SlotPos = 0
	SWEP.IconLetter = "c"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Laser Gun", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Sound		= Sound("weapons/ar1/ar1_dist1.wav")
SWEP.Primary.Recoil		= .01
SWEP.Primary.Damage		= 1000 -- LOL!
SWEP.Primary.NumShots		= 10
SWEP.Primary.Cone		= 0.05
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay		= 0.03
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 3
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "pistol"


SWEP.Secondary.Sound		= Sound("npc/sniper/sniper1.wav")
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.Recoil		= .01
SWEP.Secondary.Damage		= 1000 -- LOL!
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone		= 0.05
SWEP.Secondary.ClipSize		= 12
SWEP.Secondary.Delay		= 0.03
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.NextFire = 0
SWEP.Kickback = 50 -- This many units back.

-- Laser effect
function SWEP:ShootLaser(startp,endp,ang)
	local effect = EffectData()
	effect:SetStart(endp)
	effect:SetOrigin(startp)
	effect:SetEntity(self.Owner)
	util.Effect("laser",effect)
	
	local effect = EffectData()
	effect:SetStart(startp)
	effect:SetOrigin(endp)
	effect:SetEntity(self.Owner)
	util.Effect("laser",effect)
	
	util.BlastDamage(self.Weapon,self.Owner,endp,16,self.Primary.Damage)
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

-- High Power Beam
function SWEP:PrimaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		self.Weapon:EmitSound(self.Primary.Sound,120,60)
		
		local tr = util.GetPlayerTrace(self.Owner,self.Owner:GetAimVector())
		local tr = util.TraceLine(tr)
		
		self:ShootLaser(self.Owner:GetShootPos() - Vector(0,5,10), tr.HitPos, self.Owner:GetAimVector())
		
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.NextFire = CurTime() + self.Primary.Delay

		shotnumber=shotnumber+1
		
		if(shotnumber==30) then
			self:SendProgBar(self.Primary.Delay * 250)
			self.NextFire = CurTime() + (self.Primary.Delay * 250)
			shotnumber=0;
		end

		if SERVER then
			self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Kickback)
		end
		self.Owner:LagCompensation(false)
	end
end

SWEP.MaxShots = 12
SWEP.MaxOff = 0.15

SWEP.ShotgunSound = Sound("weapons/shotgun/shotgun_dbl_fire.wav")

-- Secondary attack is a placeholder until I determine a fair way for this weapon to be balanced
function SWEP:SecondaryAttack()
	//Do Nothing
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
Mini-Beamer

The ultimate laser-spamming weapon. Throw a massive amount of lasers on the
field as your heart desires. Initially accurate, but its strong recoil makes
it necessary to burst-fire at range.
]]

if SERVER then
	AddCSLuaFile();
	SWEP.HoldType = "ar2";
end

if CLIENT then
	SWEP.DrawAmmo = true;
	SWEP.DrawCrosshair = false;
	SWEP.PrintName = "Mini-Beamer";
	SWEP.Author	= "ief015";
	SWEP.Slot = 4;
	SWEP.SlotPos = 0;
	SWEP.IconLetter = "c";
	SWEP.ViewModelFlip = false;
	killicon.AddFont("Mini-Beamer", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255));
end

SWEP.Base                  = "weapon_laserbase";

SWEP.Spawnable             = true;
SWEP.AdminSpawnable        = true;

SWEP.ViewModel             = "models/weapons/v_mach_m249para.mdl";
SWEP.WorldModel            = "models/weapons/w_mach_m249para.mdl";

SWEP.Weight                = 5;
SWEP.AutoSwitchTo          = false;
SWEP.AutoSwitchFrom        = false;

SWEP.CooldownMessage       = "Reloading";

SWEP.IncrementCOF          = 0.032;
SWEP.DecrementCOFPerSec    = 0.3;
SWEP.RestingCOF            = 0.02;
SWEP.MaxCOF                = 0.2;
SWEP.LastChangeCOF         = 0;

SWEP.Primary.Ammo          = "Pistol";
SWEP.Primary.Automatic     = true;
SWEP.Primary.ClipSize      = 55;
SWEP.Primary.DefaultClip   = 55;
SWEP.Primary.Reload        = 6.5;

SWEP.Primary.AllowHeadshots = false;
SWEP.Primary.Anim           = ACT_VM_PRIMARYATTACK;
SWEP.Primary.Cone           = SWEP.RestingCOF;
SWEP.Primary.Delay          = 0.08;
SWEP.Primary.Kickback       = 100;
SWEP.Primary.NumShots       = 1;
SWEP.Primary.Recoil         = 0;
SWEP.Primary.Sound          = Sound("Weapon_M249.Single");
SWEP.Primary.UseCooldown    = false;

-- TODO: TEMPORARY
--[[
SWEP.Secondary.ClipSize    = 5;
SWEP.Secondary.DefaultClip = 5;
SWEP.Secondary.Automatic   = true;
SWEP.Secondary.Ammo        = "none";
SWEP.Secondary.AllowHeadshots = true;
SWEP.Secondary.Anim           = ACT_VM_SECONDARYATTACK;
SWEP.Secondary.Cone           = 0.01;
SWEP.Secondary.Delay          = 1;
SWEP.Secondary.Kickback       = 1000;
SWEP.Secondary.NumShots       = 1;
SWEP.Secondary.Recoil         = 0;
SWEP.Secondary.Sound          = Sound("weapons/flaregun/fire.wav");
SWEP.Secondary.UseCooldown    = false;
SWEP.Secondary.Offset         = Vector(0, 0, 6);
]]

function SWEP:OnThink()
	
	local t = CurTime();
	
	self.Primary.Cone = math.Clamp(self.Primary.Cone - ((t - self.LastChangeCOF) * self.DecrementCOFPerSec), self.RestingCOF, self.MaxCOF);
	
	--if SERVER then PrintMessage(HUD_PRINTTALK, "Cone: " .. self.Primary.Cone); end
	
	self.LastChangeCOF = t;
	
end

function SWEP:PostAttack(isPrimary)
	
	if isPrimary then
		
		self.Primary.Cone = math.Clamp(self.Primary.Cone + self.IncrementCOF, self.RestingCOF, self.MaxCOF);
		self.LastChangeCOF = CurTime();
		
	end
	
end

function SWEP:CanPrimaryAttack()
	
	if self:IsReadyToFire() then
		
		if self.Weapon:Clip1() <= 0 then
		
			self:EmitSound("Weapon_Pistol.Empty");
			self:Reload();
			
			return false;
		end
		
		self:TakePrimaryAmmo(1);
		
		return true;
	end
	
	return false;
	
end

function SWEP:Reload()
	
	if not self:IsReadyToFire() then return end
	if self.Weapon:Clip1() >= self.Primary.ClipSize then return end
	
	self.Weapon:DefaultReload(ACT_VM_RELOAD);
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD);
	self:StartCooldown(self.Primary.Reload);
	
end

function SWEP:FinishedCooldown()
	
	self:SetClip1(self.Primary.ClipSize);
	
end

function SWEP:SecondaryAttack()
	-- No secondary.
end

--[[
function SWEP:PostDrawViewModel(vm, ply, wep)
	
	local ang = vm:GetAngles();
	ang:RotateAroundAxis(ang:Forward(), 90);
	ang:RotateAroundAxis(ang:Right(), 90);
	ang:RotateAroundAxis(ang:Right(), -45);
	--ang = Angle(0, ang.y, ang.r);
	
	local pos = Vector(32, 20, -8);
	pos:Rotate(vm:GetAngles());
	pos:Add(vm:GetPos());
	
	cam.Start3D2D(pos, ang, 0.04);
	
	draw.RoundedBox(8, 0, 0, 128, 32, Color(0, 32, 64, 200));
	
	surface.SetFont('Font_30');
	surface.SetTextColor(100, 200, 255, 255);
	surface.SetTextPos(8, 0)
	surface.DrawText(tostring(self:Clip1()));
	
	cam.End3D2D();
	
end
]]