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
	SWEP.IconLetter = "h"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Laser Nonce", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
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

SWEP.OneNadeOnly 			= true //only one active nade at a time for each player, default true
function SWEP:PrimaryAttack()
	self.Owner:LagCompensation(true)
	
	//check if there are any other nades active by the owner
	if self.OneNadeOnly == true then
		
		for k,v in pairs( ents.FindByClass("laser_grenade")) do
			if v:GetOwner() == self.Owner then return end
		end
		
	end
	
	//spawn
	local ent = ents.Create("laser_grenade")
	ent:SetOwner(self.Owner)
	ent:SetPos(self.Owner:GetShootPos())
	ent:Spawn()
	ent:Activate()
	
	//throw
	local EntPhys = ent:GetPhysicsObject()
	EntPhys:ApplyForceCenter( self.Owner:GetAimVector():GetNormalized() * 5000 ) //Default throw power factor is 5000
	
	self.Owner:LagCompensation(false)
end
