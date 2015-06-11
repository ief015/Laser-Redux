local lasers = {};
local LASER_MATERIAL  = Material("trails/laser");
local LASER_MAX_WIDTH = 32;
local LASER_LIFE_TIME = 3;


--[[
net.Receive('laser_LaserEffect', function()
	
	local owner  = net.ReadEntity();
	local start  = net.ReadVector();
	local endpos = net.ReadVector();
	
	local effect = EffectData();
	effect:SetStart(start);
	effect:SetOrigin(endpos);
	effect:SetEntity(owner);
	util.Effect("laser", effect);
	
	effect = EffectData();
	effect:SetStart(endpos);
	effect:SetOrigin(start);
	effect:SetEntity(owner);
	util.Effect("laser", effect);
	
end)
]]

local function CreateLaser(start, origin, r, g, b)
	
	local l = {};
	
	l.start     = start;
	l.origin    = origin;
	l.colour    = Color(r, g, b);
	
	l.width     = LASER_MAX_WIDTH;
	l.startTime = CurTime();
	
	table.insert(lasers, l);
	
end

net.Receive('lr_LaserEffect', function()
	
	local count = net.ReadUInt(8) + 1;
	
	for i = 1, count do
		
		local start = net.ReadVector();
		local origin = net.ReadVector();
		
		CreateLaser(start, origin, net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8));
		
	end
	
end)

hook.Add('Think', 'lr_UpdateLasers', function()
	
	local curTime = CurTime();
	
	local l;
	
	local i = 1;
	while i <= #lasers do
		
		l = lasers[i];
		
		if curTime >= l.startTime + LASER_LIFE_TIME then
			
			table.remove(lasers, i);

		else
			
			local lifeProgress = 1 - (curTime - l.startTime) / LASER_LIFE_TIME;
			l.width            = lifeProgress * LASER_MAX_WIDTH;
			l.colour.a         = lifeProgress * 255;
			
		end
		
		i = i + 1;
		
	end
	
end);

hook.Add('PostDrawTranslucentRenderables', 'lr_DrawLasers', function()
	
	local render_DrawBeam = render.DrawBeam;
	render.SetMaterial(LASER_MATERIAL);
	
	for k,v in ipairs(lasers) do
		render_DrawBeam(v.start, v.origin, v.width, 0, 0, v.colour);
	end
	
end);