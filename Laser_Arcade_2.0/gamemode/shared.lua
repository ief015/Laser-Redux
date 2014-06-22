GM.Name 	= "Laser Arcade 2.0"
GM.Author 	= "Gmod4Ever, rcdraco, and TheGreen16"
GM.Email 	= "rcdraco@gmail.com"
GM.Website 	= "rcdraco.freeforums.org"
GM.TeamBased    = True

//server to client downloads
//space skybox
resource.AddFile("materials/skybox/spaceup.vtf")
resource.AddFile("materials/skybox/spacert.vtf")
resource.AddFile("materials/skybox/spacelf.vtf")
resource.AddFile("materials/skybox/spaceft.vtf")
resource.AddFile("materials/skybox/spacedn.vtf")
resource.AddFile("materials/skybox/spacebk.vtf")
//vmt's necessary?
resource.AddFile("materials/skybox/spaceup.vmt")
resource.AddFile("materials/skybox/spacert.vmt")
resource.AddFile("materials/skybox/spacelf.vmt")
resource.AddFile("materials/skybox/spaceft.vmt")
resource.AddFile("materials/skybox/spacedn.vmt")
resource.AddFile("materials/skybox/spacebk.vmt")

//[Just to clarify, I've removed this because I guess it doesn't help enough.]
//
//function faimbot_on( player, command, arguments )
//	LocalPlayer():ConCommand("say", "LAWL I USED AIMBOT!")
//	LocalPlayer():ConCommand("aimbot_off")
//	LocalPlayer():ConCommand("kill")
//end
//
//concommand.Add( "aimbot_on", faimbot_on )
//
//function fsmartlock( player, command, arguments )
//	LocalPlayer():ConCommand("say", "LAWL I USED SMARTSNAP!")
//	LocalPlayer():ConCommand("kill")
//end
//
//concommand.Add( "smartlock", fsmartlock )
//

function GM:CreateTeams()//Loosely based on code from luabin.foszor, some sort of gmod code junk where this was finally explained
	TEAM_RED = 1
        team.SetUp( TEAM_RED, "Red", Color( 255, 0, 0 ) )
	TEAM_BLUE = 2
      	team.SetUp( TEAM_BLUE, "Blue", Color( 0, 172, 255 ) )

	if #ents.FindByClass("info_player_combine") > 0 then //This will check how many things are in the table of entities that it finds, and will run if there are any
		team.SetSpawnPoint( 1, "info_player_combine" )
        	team.SetSpawnPoint( 2, "info_player_rebel" )
	else
		team.SetSpawnPoint( 1, "info_player_start" )
        	team.SetSpawnPoint( 2, "info_player_start" )
	end
end

hook.Add("ShouldCollide", "IgnoreTeammates", function(a, b)
	
	if a:IsPlayer() and b:IsPlayer() then
		
		return a:Team() ~= b:Team()
		
	end
	
end)

TeamGoal = 50 -- How many total frags must a team get for the next level?
IntermissionTime = 15 -- How many seconds to show board before going to next map
EvenizerIntervals = 60
EvenizeDelay = 5

NextEvenize = CurTime() + EvenizerIntervals