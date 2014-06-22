local tex = Material("vgui/white")

function EFFECT:Init(data)
	self.Owner = data:GetEntity()
	local c = team.GetColor(self.Owner:Team())
	self.SquareColor = table.Copy(c)
end

function EFFECT:Think()
	return self.Owner:Alive()
end

function EFFECT:Render()
	render.SetMaterial(tex)
	self.SquareColor.a = 100
	local pos = self.Owner:GetPos() + Vector(0,0,90)
	render.DrawQuadEasy(pos + Vector(0,0,-64),Vector(0,0,-1),64,64,self.SquareColor)
	render.DrawQuadEasy(pos + Vector(0,0,64),Vector(0,0,1),64,64,self.SquareColor)
	render.DrawQuadEasy(pos + Vector(0,64,0),Vector(0,1,0),64,64,self.SquareColor)
	render.DrawQuadEasy(pos + Vector(0,-64,0),Vector(0,-1,0),64,64,self.SquareColor)
	render.DrawQuadEasy(pos + Vector(64,0,0),Vector(1,0,0),64,64,self.SquareColor)
	render.DrawQuadEasy(pos + Vector(-64,0,0),Vector(-1,0,0),64,64,self.SquareColor)
end
