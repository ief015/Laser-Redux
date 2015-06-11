local tex = Material("trails/laser")

function EFFECT:Init(data)
	self.Start = data:GetStart()
	self.End = data:GetOrigin()
	--print(tostring(data:GetEntity()))
	if data:GetEntity():IsValid() then
		self.Owner = data:GetEntity()
	end
	self.CurWidth = 32
	self.MaxWidth = self.CurWidth
	self.WidthDel = 0.1
	self.WidthDec = 1
	self.NextWidth = CurTime() + self.WidthDel
	self.LaserColor = Color(0,0,255,255)
end

function EFFECT:Think()
	if CurTime() > self.NextWidth then
		--print("Changing it at "..CurTime())
		self.CurWidth = self.CurWidth - self.WidthDec
		self.NextWidth = CurTime() + self.WidthDel
		self.LaserColor.a = 255 * (self.CurWidth / self.MaxWidth) -- Fade out as well as get smaller.
	end
	if self.CurWidth <= 0 then
		return false -- If our width has reached or went past 0, kill the effect.
	end
	return true
end

function EFFECT:Render()
	render.SetMaterial(tex)
	render.DrawBeam(self.Start,self.End,self.CurWidth,0,0,self.LaserColor)
end
