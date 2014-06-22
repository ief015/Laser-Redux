
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local la = 75 //amount of lasers emitted on detonate
function ENT:Detonate()
	
	self.Entity:EmitSound(Sound("ambient/energy/zap2.wav"),100,100)
	for i=0,la do
		
		//trace stuffs
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = Vector(math.Rand(self.Entity:GetPos().x - 10000,self.Entity:GetPos().x + 10000),math.Rand(self.Entity:GetPos().y - 10000,self.Entity:GetPos().y + 10000),math.Rand(self.Entity:GetPos().z - 10000,self.Entity:GetPos().z + 10000))
		trace.filter = { self.Entity }
		trace = util.TraceLine(trace) //do the trace
		
		//laser beam pewpew
		local effect = EffectData()
		effect:SetStart(self.Entity:GetPos())
		effect:SetOrigin(trace.HitPos)
		effect:SetEntity(self.Entity:GetOwner())
		util.Effect("laser",effect)
		
		//lol ur dead
		util.BlastDamage(self.Entity,self.Entity:GetOwner(),trace.HitPos,16,1000) //do damage at the end of the laser. damage came from weapon_laser
		
		//and we're done, so remove dat nade
		self.Entity:Remove()
	end
	
end

function ENT:Initialize()
	self.Entity:SetModel( Model("models/Weapons/w_grenade.mdl") )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:StartMotionController()
	//after 2 seconds, do think
	self.Entity:NextThink( CurTime() + 2 )
end

function ENT:Think()
	self:Detonate()
    return true
end


function ENT:Touch( ent )
	if ent:IsValid() and ent:IsPlayer() then
		self:Detonate()
	end
end