
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local la = 50 //amount of lasers emitted on detonate. default 50
local damage = 1000 //damage per laser. default 1000
local HitS = true //Will explode after 2 seconds, after it touches something. default true

local Done = false // no touchy
function ENT:Detonate()

	self.Entity:EmitSound(Sound("ambient/energy/zap2.wav"),100,100)
	for i=0,la do
		
		//trace stuffs
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = Vector(math.Rand(self.Entity:GetPos().x - 1000,self.Entity:GetPos().x + 1000),math.Rand(self.Entity:GetPos().y - 1000,self.Entity:GetPos().y + 1000),math.Rand(self.Entity:GetPos().z - 1000,self.Entity:GetPos().z + 1000))
		trace.filter = { self.Entity }
		trace = util.TraceLine(trace) //do the trace
		
		//laser beam pewpew
		local effect = EffectData()
		effect:SetStart(self.Entity:GetPos())
		effect:SetOrigin(trace.HitPos)
		effect:SetEntity(self.Entity:GetOwner())
		util.Effect("laser",effect)
		
		//lol ur dead
		//updated. now the blast damage will only utilize if the laser hits an valid entity (discluding world)
		local HitEnt = trace.Entity
		if HitEnt:IsValid() && !HitEnt:IsWorld() then
			util.BlastDamage(self.Entity,self.Entity:GetOwner(),trace.HitPos,16,damage) //do damage at the end of the laser. damage came from weapon_laser
		end
		
		//and we're done, so remove dat nade
		self.Entity:Remove()
	end
	if Done == true then Done = false end
end

//yay, we spawned a new nade
local time = 1.5 //Time before detonation.
function ENT:Initialize()
	self.Entity:SetModel( Model("models/Weapons/w_grenade.mdl") )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:StartMotionController()
	//if HitS is false, it will always detonate after 2 seconds.
	//if HitS is true, it will wait until it hits something. but if 10 seconds past and it still didn't hit anything, detonate anyways.
	if HitS == false then
		//after 2 seconds, do think
		self.Entity:NextThink( CurTime() + time )
	else
		self.Entity:NextThink( CurTime() + 10 )
	end
end

//go boom
function ENT:Think()
	self:Detonate()
    return true
end

//if it hits the world, start the timer. (Only if HitS is set to true)
function ENT:PhysicsCollide( data, physobj )
	if HitS == true then
		if data.HitEntity:IsWorld() && Done == false then
			Done = true
			self.Entity:NextThink( CurTime() + time )
		end
	end
end

//once it is touched by a player or npc, it will esplod
function ENT:Touch( ent )
	if ent:IsPlayer() || ent:IsNPC() then
		self:Detonate()
	end
end