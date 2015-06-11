local tex = Material("sprites/glow01")
/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	local origin = data:GetStart()
	self.Entity = data:GetEntity()
	self.CurWidth = 512
	self.MaxWidth = self.CurWidth
	self.WidthDel = 0.01
	self.WidthDec = 4
	self.NextWidth = CurTime() + self.WidthDel
	self.LaserColor = Color(255,255,255,255)
	self.Origin = origin
	for i=1, 24 do
		local ang = VectorRand()
		local length = math.random(128,512)
		
		local effect = EffectData()
		effect:SetStart(origin)
		effect:SetOrigin(origin + (ang * length))
		util.Effect("bluelaser",effect)
		
		local effect = EffectData()
		effect:SetStart(origin + (ang * length))
		effect:SetOrigin(origin)
		util.Effect("bluelaser",effect)
	end
	util.PrecacheSound("ambient/explosions/explode_5.wav",100,100)
	for i=1,10 do
		self.Entity:EmitSound("ambient/explosions/explode_5.wav")
	end
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )
	if CurTime() > self.NextWidth then
		--print("Changing it at "..CurTime())
		self.CurWidth = self.CurWidth - self.WidthDec
		self.NextWidth = CurTime() + self.WidthDel
		self.LaserColor.a = 255 * (self.CurWidth / self.MaxWidth) -- Fade out as well as get smaller.
	end
	if self.CurWidth <= 0 then
		return false -- If our width has reached or went past 0, kill the effect.
	end
	return false
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
	render.SetMaterial(tex)
	render.DrawSprite(self.Origin,self.CurWidth,self.CurWidth,self.LaserColor)
end



