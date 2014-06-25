--[[
if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "ar2"
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
	SWEP.PrintName = "Laser Sniper"
	SWEP.Author	= "rcdraco"
	SWEP.Slot = 3
	SWEP.SlotPos = 0
	SWEP.IconLetter = "n"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Laser Nonce", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Sound			= Sound("weapons/gauss/fire1.wav")
SWEP.Primary.Recoil			= 4
SWEP.Primary.Damage			= 1000 -- LOL!
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay			= 1.5
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextFire = 0
SWEP.Kickback = 1300 -- This many units back.

-- Laser effect
function SWEP:ShootLaser(startp,endp,ang)
	local effect = EffectData()
	effect:SetStart(endp)
	effect:SetOrigin(startp)
	effect:SetEntity(self.Owner)
	util.Effect("laser",effect)
	
	local effect = EffectData()
	effect:SetStart(startp)
	effect:SetOrigin(endp)
	effect:SetEntity(self.Owner)
	util.Effect("laser",effect)
	
	util.BlastDamage(self.Weapon,self.Owner,endp,16,self.Primary.Damage)
end

-- Tell us to draw a bar
function SWEP:SendProgBar(endt)
	if SERVER then
		umsg.Start("laser_progbar",self.Owner)
		umsg.String(CurTime())
		umsg.String(CurTime() + endt)
		umsg.End()
	end
end

-- Single shot
function SWEP:PrimaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		self.Weapon:EmitSound(self.Primary.Sound,120,60)
		
		local tr = util.GetPlayerTrace(self.Owner,self.Owner:GetAimVector())
		local tr = util.TraceLine(tr)
		
		self:ShootLaser(self.Owner:GetShootPos() - Vector(0,0,10), tr.HitPos, self.Owner:GetAimVector())
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.NextFire = CurTime() + self.Primary.Delay
		self:SendProgBar(self.Primary.Delay * 1)
		if SERVER then
			self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Kickback)
		end
		self.Owner:LagCompensation(false)
	end
end

-- Secondary attack is a sniper zoom
/*---------------------------------------------------------
 SecondaryAttack
//-------------------------------------------------------*/
function SWEP:SecondaryAttack()
//The variable "ScopeLevel" tells how far the scope has zoomed.
//This SWEP has 2 zoom levels.
if(ScopeLevel == 0) then

	if(SERVER) then
		self.Owner:SetFOV( 45, 0 )
		//From what I'm guessing, the first parameter in
		//"self.Owner:SetFOV" is the percentage of the user's
		//entire field of view.
	end

		ScopeLevel = 1
		//This is zoom level 1.

	else if(ScopeLevel == 1) then
	
		if(SERVER) then
			self.Owner:SetFOV( 25, 0 )
		end

	ScopeLevel = 2
	//This is zoom level 2.

	else
		//If the user is zoomed in all the way, reset their view.
		if(SERVER) then
			self.Owner:SetFOV( 0, 0 )
		end

		ScopeLevel = 0
		//There is no zoom.
		end

	end

end 
-- ! CLientside stuff --
-- Retrieve umsg for bar

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
]]

if SERVER then
	AddCSLuaFile();
	SWEP.HoldType = "ar2";
end

if CLIENT then
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
	SWEP.PrintName = "Sniper Laser";
	SWEP.Author	= "ief015, rcdraco";
	SWEP.Slot = 3;
	SWEP.SlotPos = 0;
	SWEP.IconLetter = "s";
	SWEP.ViewModelFlip = true;
	killicon.AddFont("Sniper Laser", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255));
end

SWEP.Base                  = "weapon_laserbase";

SWEP.Spawnable             = true;
SWEP.AdminSpawnable        = true;

SWEP.ViewModel             = "models/weapons/v_snip_awp.mdl";
SWEP.WorldModel            = "models/weapons/w_snip_awp.mdl";

SWEP.Weight                = 10;
SWEP.AutoSwitchTo          = false;
SWEP.AutoSwitchFrom        = false;

SWEP.Primary.Automatic     = false;

SWEP.Primary.Anim          = ACT_VM_PRIMARYATTACK;
SWEP.Primary.Cone          = 0;
SWEP.Primary.Delay         = 1.5;
SWEP.Primary.Kickback      = 1200;
SWEP.Primary.NumShots      = 1;
SWEP.Primary.Recoil        = 0;
SWEP.Primary.Sound         = Sound("weapons/gauss/fire1.wav");
SWEP.Primary.UseCooldown   = true;
SWEP.Primary.Offset        = Vector(0, 0, 6);


function SWEP:ExtraSetupDataTables()
	
	self:NetworkVar('Int', 1, 'ZoomLevel');
	
end

function SWEP:PreAttack(isPrimary)
	
	if isPrimary then
		if self:GetZoomLevel() > 0 then
			self.Primary.Offset = Vector(0, 0, 0);
		else
			self.Primary.Offset = Vector(0, 0, 6);
		end
	end
	
end

function SWEP:SecondaryAttack()
	
	self:SetZoomLevel(self:GetZoomLevel() + 1);
	if self:GetZoomLevel() > 2 then
		self:SetZoomLevel(0);
	end
	
	if SERVER then
		
		if self:GetZoomLevel() == 0 then
			
			self.Owner:SetFOV(0, 0.125);
			self.Primary.Recoil = 2;
			
		elseif self:GetZoomLevel() == 1 then
			
			self.Owner:SetFOV(45, 0.125);
			self.Primary.Recoil = 0;
			
		elseif self:GetZoomLevel() == 2 then
			
			self.Owner:SetFOV(25, 0.125);
			self.Primary.Recoil = 0;
			
		end
		
	end
	
end

function SWEP:AdjustMouseSensitivity()
	
	if self:GetZoomLevel() == 0 then
		return 1;
	elseif self:GetZoomLevel() == 1 then
		return 0.4;
	elseif self:GetZoomLevel() == 2 then
		return 0.2;
	end
	
end

function SWEP:Holster()
	
	self:SetZoomLevel(0);
	
	return true;
	
end

function SWEP:HUDShouldDraw(elm)
	
	if self:GetZoomLevel() > 0 then
		
		if elm == 'CHudHealth' then return false; end
		
	else
		
		if elm == 'CHudCrosshair' then return false; end
		
	end
	
	return true;
	
end