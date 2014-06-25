if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "grenade"
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Laser Grenade"
	SWEP.Author	= "ief015"
	SWEP.Slot = 4
	SWEP.SlotPos = 0
	SWEP.IconLetter = "4"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Laser Grenade", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/Weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/Weapons/w_grenade.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Recoil			= 2.0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay			= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Recoil		= 2.0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Delay		= 3
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.OneNadeOnly 			= true //only one active nade at a time for each player, default true

local sec = false //no touchy.
function SWEP:PrimaryAttack()
	
	self.Owner:LagCompensation(true)
	
	//check if there are any other nades active by the owner
	if self.OneNadeOnly == true then
		
		for k,v in pairs( ents.FindByClass("laser_grenade") ) do
			if v:GetOwner() == self.Owner then return end
		end
		
	end
	
	//animinations
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	//spawn
	local ent = ents.Create("laser_grenade")
	ent:SetPos(self.Owner:GetShootPos())
	ent:SetAngles(Angle(self.Owner:GetAimVector().y,self.Owner:GetAimVector().x,-40))
	ent:SetOwner(self.Owner)
	ent:Spawn()
	ent:Activate()
	
	//throw
	local EntPhys = ent:GetPhysicsObject()
	if sec == true then
		EntPhys:ApplyForceCenter( self.Owner:GetAimVector():GetNormalized() * 1000 )
		sec = false
	else
		EntPhys:ApplyForceCenter( self.Owner:GetAimVector():GetNormalized() * 5000 )
	end
	
	self.Owner:LagCompensation(false)
	
end

function SWEP:SecondaryAttack()
	sec = true
	return self:PrimaryAttack()
end

function SWEP:Initialize()
	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end
end

