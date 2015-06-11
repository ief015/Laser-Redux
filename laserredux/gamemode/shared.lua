GM.Name    = "Laser Redux"
GM.Author  = "Gmod4Ever, rcdraco, ief015, TheGreen16"
GM.Email   = "ief015@gmail.com"
GM.Website = "github.com/ief015/Laser-Redux"
--GM.TeamBased	= True

resource.AddSingleFile 'sound/laserredux/mlestn1_pop3.wav'
resource.AddSingleFile 'resource/fonts/Airstream.ttf'
resource.AddSingleFile 'resource/fonts/PlanetSide2.ttf'

laser = {};

-- These should be shared globals.
laser.TeamGoal          = 50; -- How many total frags must a team get for the next level?
laser.IntermissionTime  = 15; -- How many seconds to show board before going to next map
laser.EvenizerIntervals = 60;
laser.EvenizeDelay      = 5;
laser.NextEvenize       = CurTime() + laser.EvenizerIntervals;

laser.MIN_DEATH_TIME = 6;

laser.LASER_DAMAGE = 100;

laser.TEAM_RED  = 1;
laser.TEAM_BLUE = 2;

laser.TEAM_RED_COLOR = Color(255, 50, 50);
laser.TEAM_BLUE_COLOR = Color(100, 100, 255);


function GM:CreateTeams()
	
	team.SetUp(laser.TEAM_RED, "Red", laser.TEAM_RED_COLOR);
	team.SetUp(laser.TEAM_BLUE, "Blue", laser.TEAM_BLUE_COLOR);
	
	team.SetSpawnPoint(laser.TEAM_RED, { 'info_player_start', 'info_player_deathmatch', 'info_player_combine', "info_player_terrorist", 'info_player_axis' });
	team.SetSpawnPoint(laser.TEAM_BLUE, { 'info_player_start', 'info_player_deathmatch', 'info_player_rebel', 'info_player_counterterrorist', 'info_player_allies' });
	
end

-- Get all fraggers on a given team, sorted from most frags ([1]) to least ([#last]).
function laser.GetSortedFraggers(teamid)
	
	local all = team.GetPlayers(teamid);
	table.sort(all, function(a,b) return a:Frags() > b:Frags() end);
	
	return all;
	
end

-- Returns the sum of all the frags on a given team.
function laser.GetTeamFrags(teamid)

	local curFrags = 0;
	
	for k,v in pairs(team.GetPlayers(teamid)) do
		curFrags = curFrags + v:Frags();
	end
	
	return curFrags;
	
end

-- Check to see if a weapon is a LaserRedux-compatible weapon.
function laser.IsLaserWeapon(wep)
	
	local cl = wep:GetClass();
	
	if cl == 'weapon_laserbase' then
		return true;
	end
	
	return (wep:GetTable().Base == 'weapon_laserbase');
	
end

-- Shuffle table.
--[[
function table.Shuffle(t)
	
	-- Algorithm altered and borrowed from http://snippets.luacode.org/snippets/Shuffle_array_145
	
	local n, order = #t, {};
	
	for i=1, n do
		order[i] = { rnd = math.random(), val = t[i] };
	end
	
	table.sort(order, function(a,b) return a.rnd < b.rnd; end);
	
	for i=1,n do
		t[i] = order[i].val;
	end
	
end
]]

--[[
function table.Shift(tbl)
	shiftpoint = 10000
	for i=1,table.getn(tbl) do 
		if tbl[i] == nil then
			shiftpoint = i
		end
		if i > shiftpoint then
			tbl[i-1] = tbl[i]
			tbl[i] = nil
		end
	end
end
]]

-- Returns a random number shared between the server and client.
--[[
if SERVER then SetGlobalString('laser_randomSeed', tostring(os.time())); end
local iseed = 0;
local seed = GetGlobalString('laser_randomSeed');
function laser.getSharedRandom(min, max)
	
	iseed = iseed + 1;
	return util.SharedRandom(seed, min or 0, max or 1, iseed);
	
	
end]]