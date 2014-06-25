if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "shotgun"
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Laser Shotgun"
	SWEP.Author	= "rcdraco"
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.IconLetter = "s"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Laser Shotgun", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Sound			= Sound("weapons/flaregun/fire.wav")
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 2000 -- LOL!
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay			= 1.8
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextFire = 0
SWEP.Kickback = 500 -- This many units back.

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

SWEP.MaxShots = 16
SWEP.MaxOff = 0.25
SWEP.ShotgunSound = Sound("weapons/flaregun/fire.wav")
-- Primary attack is a big-spread shotgun-like effect
function SWEP:PrimaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.NextFire = CurTime() + (self.Primary.Delay * 1)
		
		self.Weapon:EmitSound(self.ShotgunSound,120,60)
		for i=1,self.MaxShots do
			local ang = self.Owner:GetAimVector() + Vector(math.Rand(-self.MaxOff,self.MaxOff),math.Rand(-self.MaxOff,self.MaxOff),math.Rand(-self.MaxOff,self.MaxOff))
			local tr = util.GetPlayerTrace(self.Owner,ang)
			local tr = util.TraceLine(tr)
			
			self:ShootLaser(self.Owner:GetShootPos() - Vector(0,0,0), tr.HitPos, ang)
		end
		
		self:SendProgBar(self.Primary.Delay * 1)
		if SERVER then
			self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * (self.Kickback * 2)) -- Double kickback
		end
		self.Owner:LagCompensation(false)
	end
end

SWEP.SecondMaxShots = 16
SWEP.SecondMaxOff = 0.05
SWEP.SecondShotgunSound = Sound("weapons/flaregun/fire.wav")
-- Secondary attack is a short-spread shotgun-like effect
function SWEP:SecondaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.NextFire = CurTime() + (self.Primary.Delay * 1)
		
		self.Weapon:EmitSound(self.SecondShotgunSound,120,60)
		for i=1,self.SecondMaxShots do
			local ang = self.Owner:GetAimVector() + Vector(math.Rand(-self.SecondMaxOff,self.SecondMaxOff),math.Rand(-self.SecondMaxOff,self.SecondMaxOff),math.Rand(-self.SecondMaxOff,self.SecondMaxOff))
			local tr = util.GetPlayerTrace(self.Owner,ang)
			local tr = util.TraceLine(tr)
			
			self:ShootLaser(self.Owner:GetShootPos() - Vector(0,0,10), tr.HitPos, ang)
		end
		
		self:SendProgBar(self.Primary.Delay * 1)
		if SERVER then
			self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * (self.Kickback * 1)) -- Double kickback
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
		
	
		
