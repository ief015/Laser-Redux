
AddCSLuaFile( "shared.lua" )
include('shared.lua')

//editable stuffs:
local sound_teleport = Sound("weapons/physgun_off.wav") //Sound when teleport works
local sound_kill = Sound("weapons/stinger_fire1.wav") //Sound when teleport kills someone

local teleport_height = 16 //how high above the beacon the player will teleport

//Success! We have telemeported
function ENT:DoTeleport()
	self.Entity:GetOwner():SetPos(self.Entity:GetPos() + Vector(0,0,teleport_height))
	self.Entity:GetOwner():EmitSound(sound_teleport,100,100)
	self.Entity:Remove()
end

//Pre-teleport, this is some sexy code
function ENT:Teleport()
	
	local playertouch = false
	local playertouchents = {}
	local validents = {}
	
	//get all entities near beacon
	playertouchents = 	ents.FindInBox( Vector(self.Entity:GetPos().x - 24,self.Entity:GetPos().y - 24,self.Entity:GetPos().z), Vector(self.Entity:GetPos().x + 24,self.Entity:GetPos().y + 24,self.Entity:GetPos().z + (65 + teleport_height)))
	if not ( playertouchents[0] == nil ) then playertouch = true else playertouch = false end
	
	//teleporty stuffs
	if playertouch == true then
		
		local invalidents = false
		for k,v in pairs ( playertouchents ) do
			if v:IsPlayer() || v:IsNPC() then
				validents[k] = v
			else
				invalidents = true
			end
		end
		
		if invalidents == true then return false end
		
		for k,v in pairs( validents ) do
			util.BlastDamage(self.Entity,self.Entity:GetOwner(),v:GetPos() + Vector(0,0,40),16,1000)
			self.Entity:EmitSound(sound_kill,100,100)
		end
		
		self:DoTeleport()
		return true
		
	else
		self:DoTeleport()
		return true
	end
	
end

//spawn dat beacon
function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
end