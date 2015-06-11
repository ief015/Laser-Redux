if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "ar2"
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Translocator"
	SWEP.Author	= "ief015"
	SWEP.Slot = 5
	SWEP.SlotPos = 0
	SWEP.IconLetter = "r"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Translocator", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_RPG.mdl"
SWEP.WorldModel			= "models/weapons/w_RPG.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Recoil			= 2.0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay			= 1.5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Recoil		= 2.0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextFire 				= 0
SWEP.Ent 					= nil

//editable suff
SWEP.Power 					= 13000 //throw power, default 13000
local sound_fail 			= Sound("player/suit_denydevice.wav") //Sound when teleport fails

// Tell us to draw a bar
function SWEP:SendProgBar(endt)
	if SERVER then
		umsg.Start("laser_progbar",self.Owner)
		umsg.String(CurTime())
		umsg.String(CurTime() + endt)
		umsg.End()
	end
end

function SWEP:PrimaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		
		//check if there are any other beacons active by the owner
		for k,v in pairs( ents.FindByClass( "trans_beacon" ) ) do
			if v:GetOwner() == self.Owner then
				v:Remove()
				return
			end
		end
		
		//animations
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		//spawn
		self.Ent = ents.Create("trans_beacon")
		self.Ent:SetPos(self.Owner:GetShootPos())
		self.Ent:SetModel( Model("models/props_c17/clock01.mdl") )
		self.Ent:SetMaterial( "models/props_combine/metal_combinebridge001")
		self.Ent:SetOwner(self.Owner)
		self.Ent:Spawn()
		self.Ent:Activate()
		
		//Trail
		util.SpriteTrail(self.Ent, 0, team.GetColor(self.Owner:Team()), false, 16, 2, 3, 1 / ((16 + 2) * 0.5), "trails/laser.vmt")
		
		//throw and etc
		local EntPhys = self.Ent:GetPhysicsObject()
		local ang = EntPhys:GetAngle()
		constraint.Keepupright( self.Ent, ang, 0, 100000 ) //refuses to work. unknown reason.
		EntPhys:ApplyForceCenter( self.Owner:GetAimVector():GetNormalized() * self.Power )
		
		self.Owner:LagCompensation(false)
	end
end

function SWEP:SecondaryAttack()
	//check if there are any other beacons active by the owner
	local foundentsowner = false //if there is a beacon owned by the owner
	for k,v in pairs( ents.FindByClass( "trans_beacon" ) ) do //check if there are any other beacons active by the owner
		if v:GetOwner() == self.Owner then foundentsowner = true end
	end
	//continue if there are any beacons by the owner
	if foundentsowner == false then return end
	
	//attempt teleport
	local worked = self.Ent:Teleport()
	
	//if the teleport failed, stop here
	if worked == false then self.Weapon:EmitSound(sound_fail,100,100) return end
	
	self.NextFire = CurTime() + (self.Primary.Delay)
	self:SendProgBar(self.Primary.Delay)
end

/* ! CLientside stuff
   Retrieve umsg for bar */

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