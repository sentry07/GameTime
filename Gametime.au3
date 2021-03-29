#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Development\hockey_128x128.ico
#AutoIt3Wrapper_Outfile=GameTimeX NHL17-18.exe
#AutoIt3Wrapper_Res_Description=NHL Stats Scraper and Gameday Thread builder for /r/Hockey
#AutoIt3Wrapper_Res_Fileversion=1.0.17.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=n
#AutoIt3Wrapper_Res_LegalCopyright=(C)2013 Eric Walters sentry07@gmail.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Opt("GUICloseOnESC",0)

#include <Array.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Math.au3>
#include <Date.au3>
#include <JSON.au3>
#include <JSON_Translate.au3>

#region Constants
Const $MyVerArray[4] = [1, 0, 15, 2]
Const $CheckBaseURL = "https://dl.dropboxusercontent.com/u/5739973/NHL/Builds/"
Const $CheckVerURL = "checkver.txt"
HttpSetUserAgent("GameTime " & _ArrayToString($MyVerArray,"."))

Const $TeamNames[31] = ["Penguins", "Devils", "Rangers", "Islanders", "Flyers", "Blackhawks", "RedWings", "Blues", "BlueJackets", "Predators", "Canadiens", "Bruins", "Senators", "MapleLeafs", "Sabres", "Canucks", "Wild", "Oilers", "Flames", "Avalanche", "Ducks", "Kings", "Stars", "Sharks", "Coyotes", "Jets", "Hurricanes", "Capitals", "Lightning", "Panthers", "Golden Knights"]
Const $TeamCities[31] = ["Pittsburgh", "New Jersey", "NY Rangers", "NY Islanders", "Philadelphia", "Chicago", "Detroit", "St. Louis", "Columbus", "Nashville", "Montréal", "Boston", "Ottawa", "Toronto", "Buffalo", "Vancouver", "Minnesota", "Edmonton", "Calgary", "Colorado", "Anaheim", "Los Angeles", "Dallas", "San Jose", "Arizona", "Winnipeg", "Carolina", "Washington", "Tampa Bay", "Florida", "Vegas"]
Const $TeamLong[31] = ["Pittsburgh Penguins", "New Jersey Devils", "New York Rangers", "New York Islanders", "Philadelphia Flyers", "Chicago Blackhawks", "Detroit Red Wings", "St. Louis Blues", "Columbus Blue Jackets", "Nashville Predators", "Montreal Canadiens", "Boston Bruins", "Ottawa Senators", "Toronto Maple Leafs", "Buffalo Sabres", "Vancouver Canucks", "Minnesota Wild", "Edmonton Oilers", "Calgary Flames", "Colorado Avalanche", "Anaheim Ducks", "Los Angeles Kings", "Dallas Stars", "San Jose Sharks", "Arizona Coyotes", "Winnipeg Jets", "Carolina Hurricanes", "Washington Capitals", "Tampa Bay Lightning", "Florida Panthers", "Vegas Golden Knights"]
Const $TeamNamesAbbr[31] = ["PIT", "NJD", "NYR", "NYI", "PHI", "CHI", "DET", "STL", "CBJ", "NSH", "MTL", "BOS", "OTT", "TOR", "BUF", "VAN", "MIN", "EDM", "CGY", "COL", "ANA", "LAK", "DAL", "SJS", "ARI", "WPG", "CAR", "WSH", "TBL", "FLA", "VGK"]
Const $TeamReddits[31] = ["/r/penguins", "/r/devils", "/r/rangers", "/r/newyorkislanders", "/r/flyers", "/r/hawks", "/r/detroitredwings", "/r/stlouisblues", "/r/bluejackets", "/r/predators", "/r/habs", "/r/bostonbruins", "/r/ottawasenators", "/r/leafs", "/r/sabres", "/r/canucks", "/r/wildhockey", "/r/edmontonoilers", "/r/calgaryflames", "/r/coloradoavalanche", "/r/anaheimducks", "/r/losangeleskings", "/r/dallasstars", "/r/sanjosesharks", "/r/coyotes", "/r/winnipegjets", "/r/canes", "/r/caps", "/r/tampabaylightning", "/r/floridapanthers", "/r/goldenknights"]
Const $TeamArenas[31] = ["Consol Energy Center", "Prudential Center", "Madison Square Garden", "Barclays Center", "Wells Fargo Center", "United Center", "Joe Louis Arena", "Scottrade Center", "Nationwide Arena", "Bridgestone Arena", "Bell Centre", "TD Garden", "Canadian Tire Centre", "Air Canada Centre", "First Niagara Center", "Rogers Arena", "Xcel Energy Center", "Rexall Place", "Scotiabank Saddledome", "Pepsi Center", "Honda Center", "Staples Center", "American Airlines Center", "SAP Center", "Gila River Arena", "MTS Centre", "PNC Arena", "Verizon Center", "Tampa Bay Times Forum", "BB&T Center", "T-Mobile Arena"]
Const $TeamArenaPlace[31] = ["Pittsburgh, PA, USA", "Newark, NJ, USA", "New York, NY, USA", "Long Island, NY, USA", "Philadelphia, PA, USA", "Chicago, IL, USA", "Detroit, MI, USA", "St Louis, MO, USA", "Columbus, OH, USA", "Nashville, TN, USA", "Montreal, QC, CAN", "Boston, MA, USA", "Ottawa, ON, CAN", "Toronto, ON, CAN", "Buffalo, NY, USA", "Vancouver, BC, CAN", "St Paul, MN, USA", "Edmonton, AB, CAN", "Calgary, AB, CAN", "Denver, CO, USA", "Anaheim, CA, USA", "Los Angeles, CA, USA", "Dallas, TX, USA", "San Jose, CA, USA", "Glendale, AZ, USA", "Winnipeg, MB, CAN", "Raleigh, NC, USA", "Washington, DC, USA", "Tampa, FL, USA", "Sunrise, FL, USA", "Las Vegas, NV, USA"]
Const $TeamTimeZone[31] = ["ET", "ET", "ET", "ET", "ET", "CT", "ET", "CT", "ET", "CT", "ET", "ET", "ET", "ET", "ET", "PT", "CT", "MT", "MT", "MT", "PT", "PT", "CT", "PT", "MT", "CT", "ET", "ET", "ET", "ET", "PT"]

Const $TeamRedditLogos[31] = ["/penguinslogo", "/devilslogo", "/rangerslogo", "/islanderslogo", "/flyerslogo", "/blackhawkslogo", "/redwingslogo", "/blueslogo", "/bluejacketslogo", "/predatorslogo", "/canadienslogo", "/bruinslogo", "/senatorslogo", "/mapleleafslogo", "/sabreslogo", "/canuckslogo", "/wildlogo", "/oilerslogo", "/flameslogo", "/avalanchelogo", "/duckslogo", "/kingslogo", "/starslogo", "/sharkslogo", "/coyoteslogo", "/jetslogo", "/hurricaneslogo", "/capitalslogo", "/lightninglogo", "/pantherslogo", "/knightslogo"]

; This array has the team names with proper formatting for {home/away:short} tag
Const $TeamNamesFormatted[31] = ["Penguins", "Devils", "Rangers", "Islanders", "Flyers", "Blackhawks", "Red Wings", "Blues", "Blue Jackets", "Predators", "Canadiens", "Bruins", "Senators", "Maple Leafs", "Sabres", "Canucks", "Wild", "Oilers", "Flames", "Avalanche", "Ducks", "Kings", "Stars", "Sharks", "Coyotes", "Jets", "Hurricanes", "Capitals", "Lightning", "Panthers", "Golden Knights"]

; This array is necessary to match team names on NHL.com stats page
Const $TeamNHL[31] = ["Pittsburgh", "New Jersey", "New York Rangers", "New York Islanders", "Philadelphia", "Chicago", "Detroit", "St Louis", "Columbus", "Nashville", "Montreal", "Boston", "Ottawa", "Toronto", "Buffalo", "Vancouver", "Minnesota", "Edmonton", "Calgary", "Colorado", "Anaheim", "Los Angeles", "Dallas", "San Jose", "Arizona", "Winnipeg", "Carolina", "Washington", "Tampa Bay", "Florida", "Vegas"]
Const $TeamTSN[31] = ["Pittsburgh", "New Jersey", "NY Rangers", "NY Islanders", "Philadelphia", "Chicago", "Detroit", "St. Louis", "Columbus", "Nashville", "Montreal", "Boston", "Ottawa", "Toronto", "Buffalo", "Vancouver", "Minnesota", "Edmonton", "Calgary", "Colorado", "Anaheim", "Los Angeles", "Dallas", "San Jose", "Arizona", "Winnipeg", "Carolina", "Washington", "Tampa Bay", "Florida", "Vegas"]

;Daily Faceoff
Const $TeamLineUpBaseURL = "http://www2.dailyfaceoff.com/teams/lines/"
Const $TeamLineUpURL[31] = ["pittsburgh-penguins", "new-jersey-devils", "new-york-rangers", "new-york-islanders", "philadelphia-flyers", "chicago-blackhawks", "detroit-red-wings", "st-louis-blues", "columbus-blue-jackets", "nashville-predators", "montreal-canadiens", "boston-bruins", "ottawa-senators", "toronto-maple-leafs", "buffalo-sabres", "vancouver-canucks", "minnesota-wild", "edmonton-oilers", "calgary-flames", "colorado-avalanche", "anaheim-ducks/", "los-angeles-kings", "dallas-stars", "san-jose-sharks", "arizona-coyotes", "winnipeg-jets", "carolina-hurricanes", "washington-capitals", "tampa-bay-lightning", "florida-panthers", "vegas-golden-knights"]

Const $TeamStatCount = 16
Const $TeamStats[$TeamStatCount] = ["Rank","Team","GP","W","L","OT","P","ROW","P%","G/G","GA/G","PP%","PK%","S/G","SA/G","FO%"]
Const $TeamStats_JSON[$TeamStatCount] = ["", "", "gamesPlayed", "wins", "losses", "otLosses", "points", "regPlusOtWins", "pointPctg", "goalsForPerGame", "goalsAgainstPerGame", "ppPctg", "pkPctg", "shotsForPerGame", "shotsAgainstPerGame", "faceoffWinPctg"]

Const $PlayerStatCount = 14
Const $PlayerStats[$PlayerStatCount] = ["Num", "Pos", "Name", "GP", "G", "A", "P", "+/-", "PIM", "PP", "SH", "GW", "S", "S%"]

Const $GoalieStatCount = 16
Const $GoalieStats[$GoalieStatCount] = ["Num", "Name", "GPI", "GS", "Min", "GAA", "W", "L", "OT", "SO", "SA", "GA", "SV%", "G", "A", "PIM"]

Const $SpecialFields[4] = ["nameabbr", "redditname", "redditicon", "redditabbr"]

Const $TableHeader[23] = [":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:", ":--:"]

Const $AllPlayersFile = @ScriptDir & "\Data\AllPlayers.txt"
Const $AllGoaliesFile = @ScriptDir & "\Data\AllGoalies.txt"
Const $StandingsFile = @ScriptDir & "\Data\Standings.txt"

Const $StreamRates[5] = ["400","800","1600","3000","4500"]

Const $Months[12] = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

Const $ScheduleFields[5] = ["Date", "Away", "Home", "Time", "Network/Result"]

Const $InjuryURL = "http://www.tsn.ca/nhl/injuries/"
Const $InjuryFields[4] = [ "Player", "Date", "Status", "Injury" ]

#endregion

#region User Interface
$frmMain = GUICreate("GameTimeX NHL 16-17 - Gameday Stats Aggregator and Thread Builder v" & _ArrayToString($MyVerArray,"."), 785, 553, -1, -1)
$cmbHome = GUICtrlCreateCombo("", 96, 176, 201, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
$lblHomeTeam = GUICtrlCreateLabel("Home Team", 165, 158, 62, 17)

$inpStartTime = GUICtrlCreateInput("7:00", 306, 122, 81, 21)

$lblHGoalie = GUICtrlCreateLabel("Goalies", 177, 206, 39, 17)
$cmbHGoalie1 = GUICtrlCreateCombo("", 70, 224, 121, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
$cmbHGoalie2 = GUICtrlCreateCombo("", 198, 224, 121, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))

Dim $cmbHO[4][3] ; Home Offensive Line - [a][b] a = Line, b = {0=L,1=C,2=R}
Dim $cmbHD[3][2] ; Home Defensive Line - [a][b] a = Line, b = {0=L,1=R}
Dim $cmbAO[4][3] ; Away
Dim $cmbAD[3][2] ; Away

$lblHLineup = GUICtrlCreateLabel("Lineup", 178, 253, 36, 17)

$cmbHO[0][0] = GUICtrlCreateCombo("", 8, 271, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[0][1] = GUICtrlCreateCombo("", 136, 271, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[0][2] = GUICtrlCreateCombo("", 264, 271, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[1][0] = GUICtrlCreateCombo("", 8, 295, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[1][1] = GUICtrlCreateCombo("", 136, 295, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[1][2] = GUICtrlCreateCombo("", 264, 295, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[2][0] = GUICtrlCreateCombo("", 8, 319, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[2][1] = GUICtrlCreateCombo("", 136, 319, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[2][2] = GUICtrlCreateCombo("", 264, 319, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[3][0] = GUICtrlCreateCombo("", 8, 343, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[3][1] = GUICtrlCreateCombo("", 136, 343, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHO[3][2] = GUICtrlCreateCombo("", 264, 343, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))

$cmbHD[0][0] = GUICtrlCreateCombo("", 72, 375, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHD[0][1] = GUICtrlCreateCombo("", 200, 375, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHD[1][0] = GUICtrlCreateCombo("", 72, 399, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHD[1][1] = GUICtrlCreateCombo("", 200, 399, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHD[2][0] = GUICtrlCreateCombo("", 72, 423, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbHD[2][1] = GUICtrlCreateCombo("", 200, 423, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))

$cmbAway = GUICtrlCreateCombo("", 488, 176, 201, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
$lblAwayTeam = GUICtrlCreateLabel("Away Team", 558, 158, 60, 17)

$lblAGoalie = GUICtrlCreateLabel("Goalies", 569, 206, 39, 17)

$cmbAGoalie1 = GUICtrlCreateCombo("", 462, 224, 121, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
$cmbAGoalie2 = GUICtrlCreateCombo("", 590, 224, 121, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))

$lblALineup = GUICtrlCreateLabel("Lineup", 570, 253, 36, 17)

$cmbAO[0][0] = GUICtrlCreateCombo("", 400, 271, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[0][1] = GUICtrlCreateCombo("", 528, 271, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[0][2] = GUICtrlCreateCombo("", 656, 271, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[1][0] = GUICtrlCreateCombo("", 400, 295, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[1][1] = GUICtrlCreateCombo("", 528, 295, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[1][2] = GUICtrlCreateCombo("", 656, 295, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[2][0] = GUICtrlCreateCombo("", 400, 319, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[2][1] = GUICtrlCreateCombo("", 528, 319, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[2][2] = GUICtrlCreateCombo("", 656, 319, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[3][0] = GUICtrlCreateCombo("", 400, 343, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[3][1] = GUICtrlCreateCombo("", 528, 343, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAO[3][2] = GUICtrlCreateCombo("", 656, 343, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))

$cmbAD[0][0] = GUICtrlCreateCombo("", 464, 375, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAD[0][1] = GUICtrlCreateCombo("", 592, 375, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAD[1][0] = GUICtrlCreateCombo("", 464, 399, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAD[1][1] = GUICtrlCreateCombo("", 592, 399, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAD[2][0] = GUICtrlCreateCombo("", 464, 423, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
$cmbAD[2][1] = GUICtrlCreateCombo("", 592, 423, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))

$lblStatTime = GUICtrlCreateLabel("Last updated: Checking...", 16, 16, 200, 17)
$btnUpdate = GUICtrlCreateButton("Update Stats", 16, 32, 75, 25)

$lblArena = GUICtrlCreateLabel("Arena", 376, 8, 32, 17)
$inpArena = GUICtrlCreateInput("Select Home Team", 306, 26, 177, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$lblLocation = GUICtrlCreateLabel("Location", 370, 56, 45, 17)
$inpLocation = GUICtrlCreateInput("", 306, 74, 177, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$lblStartTime = GUICtrlCreateLabel("Start Time", 366, 104, 52, 17)
$inpTimeZone = GUICtrlCreateInput("?ST", 402, 122, 81, 21)
GUICtrlSetState(-1, $GUI_DISABLE)

$cmbTemplate = GUICtrlCreateCombo("", 300, 488, 185, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$btnBuild = GUICtrlCreateButton("Build Thread", 355, 514, 75, 25)
$lblTemplate = GUICtrlCreateLabel("Thread Template", 350, 468, 85, 17)
$btnRefresh = GUICtrlCreateButton("Refresh List", 493, 486, 75, 25)

HotKeySet("^d","CopyDailyTable")

GUISetState(@SW_SHOW)
#endregion ### END Koda GUI section ###

#region Variables
;Text version of selected teams
Global $SelectedHome
Global $SelectedAway

;Team indexes in the arrays
Global $HomeIndex = -1
Global $AwayIndex = -1

Global $StandingsLoaded = False
Global $AllStandings[31][$TeamStatCount]
Global $TeamRank[31]

Global $AllPlayers[31][40][$PlayerStatCount]
Global $PlayerCount[31] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $PlayerCountBlank[31] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

Global $AllGoalies[31][10][$GoalieStatCount]
Global $GoalieCount[31] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $GoalieCountBlank[31] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

Global $HomeSchedule[1][5]
Global $HomeGameDates[1]
Global $HomeTeamUpdated = False
Global $HomeScheduleIndex

Global $AwaySchedule[1][5]
Global $AwayGameDates[1]
Global $AwayTeamUpdated = False
Global $AwayScheduleIndex

Global $TeamInjuries[31][15][4]
Global $TeamInjuryCount[31] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

Dim $TeamLongSorted = $TeamLong
_ArraySort($TeamLongSorted)

Global $TodaySchedule[16][4]
Global $TodayHomeTeams[16]
Global $TodayAwayTeams[16]
Global $SelectedGame

Global $GameBroadcast
Global $NHLGameID

Global $TeamID[31]

#endregion

#region Startup Code
CheckForNewVersion()

If Not FileExists(@ScriptDir & "\Data\") Then
	DirCreate(@ScriptDir & "\Data\")
EndIf

If FileExists($AllPlayersFile) Then
	Local $t = FileGetTime($AllPlayersFile, 0)
	Local $t_format = $t[1] & "/" & $t[2] & "/" & $t[0] & " " & $t[3] & ":" & $t[4] & ":" & $t[5]

	GUICtrlSetData($lblStatTime, "Last updated: " & $t_format)

	Local $filetime = FileGetTimeForDiff($AllPlayersFile)
	If _DateDiff("h",$filetime,_NowCalc()) > 1 Then
		GetUpdatedStats()
	EndIf
	LoadPlayers()
	LoadStandings()
Else
	GetUpdatedStats()
	LoadPlayers()
	LoadStandings()
EndIf

RefreshFileList()
GetScheduleToday()
;GetTeamInjuries()

GUICtrlSetData($cmbHome, _ArrayToString($TeamLongSorted, "|"))
GUICtrlSetData($cmbAway, _ArrayToString($TeamLongSorted, "|"))
;GUICtrlSetData($cmbHome, _ArrayToString($TodayHomeTeams, "|"))
;GUICtrlSetData($cmbAway, _ArrayToString($TodayAwayTeams, "|"))
#endregion

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $btnUpdate
			GetUpdatedStats()
			LoadPlayers()
			LoadStandings()
		Case $cmbHome
			Local $CheckHome = GUICtrlRead($cmbHome)
			If StringLen($CheckHome) And $CheckHome <> $SelectedHome Then
				$SelectedHome = $CheckHome
				$HomeIndex = FindArrayEntry($TeamLong, $SelectedHome)
				$HomeTeamUpdated = False
				UpdateHomeTeam()
			EndIf
		Case $cmbAway
			Local $CheckAway = GUICtrlRead($cmbAway)
			If StringLen($CheckAway) And $CheckAway <> $SelectedAway Then
				$SelectedAway = $CheckAway
				$AwayIndex = FindArrayEntry($TeamLong, $SelectedAway)
				$AwayTeamUpdated = False
				UpdateAwayTeam()
			EndIf
		Case $btnBuild
			$TemplateFile = GUICtrlRead($cmbTemplate)
			If FileExists(@ScriptDir & "\" & $TemplateFile) Then
				BuildThread()
			Else
				MsgBox(48,"File Not Found","Please select a text file from the dropbown box.")
			EndIf
		Case $btnRefresh
			RefreshFileList()
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch

WEnd

Func CheckForNewVersion()					; Checks for a newer version of GameTime
	; Check for and delete local copy of the update info file
	Local $tempfile = @ScriptDir & "\checkver.txt"
	If FileExists($tempfile) Then
		FileDelete($tempfile)
	EndIf

	; Download the update info file
	Local $hDownload = InetGet($CheckBaseURL & $CheckVerURL, $tempfile, 1, 0)

	$FileHnd = FileOpen($tempfile)
	$update = FileRead($FileHnd)
	FileClose($FileHnd)

	If FileExists($tempfile) Then	; Update info file received
		FileDelete($tempfile)
		$update = StringReplace($update,@CRLF,@CR)
		$update = StringSplit($update,@CR,2)
		$newverarray = StringSplit($update[0],'.',2)

		; Convert x.x.x.x versions into integers to compare
		$newver = BitShift($newverarray[0],-24) + BitShift($newverarray[1],-16) + BitShift($newverarray[2],-8) + $newverarray[3]
		$myver = BitShift($MyVerArray[0],-24) + BitShift($MyVerArray[1],-16) + BitShift($MyVerArray[2],-8) + $MyVerArray[3]

		If $newver > $myver Then
			$checkdownload = MsgBox(36,"New Version Available","GameTime v" & $update[0] & " is available. Would you like to download it now?" & @CRLF & @CRLF & _ArrayToString($update,@CRLF,2,UBound($update) - 1))
			If $checkdownload = 6 Then	; User pressed "Yes"
				$hDownload = InetGet($CheckBaseURL & $update[1],@ScriptDir & "/" & $update[1],3,0)
				If Not $hDownload Then
					MsgBox(48,"Download Failed","The download failed. Please check /r/GameTime for new version.")
				Else
					MsgBox(64,"Download Successful","The latest version .ZIP file has been downloaded to your GameTime folder. Program will close now.")
					Exit
				EndIf
			EndIf
		EndIf
	EndIf

EndFunc

Func LoadPlayers() 							; Load player and goalie information from text files
	Local $AllPlayersFileHnd = FileOpen($AllPlayersFile, 0)
	Local $AllGoaliesFileHnd = FileOpen($AllGoaliesFile, 0)

	; Clear out arrays and variables
	$PlayerCount = $PlayerCountBlank
	$GoalieCount = $GoalieCountBlank
	$AllPlayers = 0
	$AllGoalies = 0
	Global $AllPlayers[31][40][$PlayerStatCount]
	Global $AllGoalies[31][10][$GoalieStatCount]

	; Skip the first two lines since they are headers
	Local $line = FileReadLine($AllPlayersFileHnd)
	Local $line = FileReadLine($AllPlayersFileHnd)

	; Read player file into memory and split it back into arrays
	While 1
		Local $line = FileReadLine($AllPlayersFileHnd)
		If @error = -1 Then	; We've reached the end of the file
			ExitLoop
		Else
			; Flat array is separated by pipes; split it into a temp array
			Local $player = StringSplit($line, "|", 2)
			;_ArrayDisplay($player)
			Local $teamindex = GetTeamIndex($player[0])
			; MsgBox(0,"Debug",$teamindex)
			Local $i
			; Then copy the temp array into the main array
			For $i = 0 To 13
				$AllPlayers[$teamindex][$PlayerCount[$teamindex]][$i] = $player[$i + 1]
			Next
			$PlayerCount[$teamindex] += 1
		EndIf
	WEnd

	; Skip the first two lines since they are headers
	Local $line = FileReadLine($AllGoaliesFileHnd)
	Local $line = FileReadLine($AllGoaliesFileHnd)

	; Read goalie file into memory and split it back into arrays
	While 1
		Local $line = FileReadLine($AllGoaliesFileHnd)
		If @error = -1 Then	; We've reached the end of the file
			ExitLoop
		Else
			; Flat array is separated by pipes; split it into a temp array
			Local $Goalie = StringSplit($line, "|", 2)
			;_ArrayDisplay($Goalie)
			Local $teamindex = GetTeamIndex($Goalie[0])
			; MsgBox(0,"Debug",$teamindex)
			Local $i
			; Then copy the temp array into the main array
			For $i = 0 To 15
				$AllGoalies[$teamindex][$GoalieCount[$teamindex]][$i] = $Goalie[$i + 1]
			Next
			$GoalieCount[$teamindex] += 1
		EndIf
	WEnd

	FileClose($AllPlayersFileHnd)
	FileClose($AllGoaliesFileHnd)
EndFunc   ;==>LoadPlayers

Func LoadStandings()						; Load team standings from text file
	Local $StandingsFileHnd = FileOpen($StandingsFile,0)
	If @error = -1 Then
		MsgBox(48,"Standings","Standings file not found. Standings placeholders will not be available in templates.")
		$StandingsLoaded = False
		Return
	EndIf

	$AllStandings = 0
	$TeamRank = 0
	Global $AllStandings[31][$TeamStatCount]
	Global $TeamRank[31]

	; Skip the first two lines since they're headers
	Local $line = FileReadLine($StandingsFileHnd)
	Local $line = FileReadLine($StandingsFileHnd)

	While 1
		Local $line = FileReadLine($StandingsFileHnd)
		If @error = -1 Then
			ExitLoop
		Else
			Local $team = StringSplit($line, "|", 2)
			Local $teamline = StringMid($team[2],2,StringInStr($team[2],"]") - 2)
			Local $teamindex = GetTeamIndex($teamline)
			$TeamRank[$teamindex] = $team[1]

			Local $i
			For $i = 1 To $TeamStatCount
				If $i = 2 Then
					$AllStandings[$team[1]-1][$i - 1] = $teamline
				Else
					$AllStandings[$team[1]-1][$i - 1] = $team[$i]
				EndIf
			Next

		EndIf
	WEnd

	FileClose($StandingsFileHnd)
EndFunc

Func UpdateHomeTeam()						; Get updated information for the home team
	GUICtrlSetData($cmbHome, $TeamLong[$HomeIndex])
	GUICtrlSetData($inpArena, $TeamArenas[$HomeIndex])
	GUICtrlSetData($inpLocation, $TeamArenaPlace[$HomeIndex])
	GUICtrlSetData($inpTimeZone, $TeamTimeZone[$HomeIndex])
	GUICtrlSetData($cmbHGoalie1, "")
	GUICtrlSetData($cmbHGoalie1, GetTeamGoalies($HomeIndex))
	GUICtrlSetData($cmbHGoalie2, "")
	GUICtrlSetData($cmbHGoalie2, GetTeamGoalies($HomeIndex))

	Local $HomePlayers = GetTeamPlayers($HomeIndex)

	; Fill offensive line combo boxes
	Local $i, $j
	For $i = 0 To 3
		For $j = 0 To 2
			GUICtrlSetData($cmbHO[$i][$j], "")
			GUICtrlSetData($cmbHO[$i][$j], $HomePlayers)
		Next
	Next

	; Fill defensive line combo boxes
	Local $i, $j
	For $i = 0 To 2
		For $j = 0 To 1
			GUICtrlSetData($cmbHD[$i][$j], "")
			GUICtrlSetData($cmbHD[$i][$j], $HomePlayers)
		Next
	Next

	; Go get other info about the team
	GetTeamLineUp($HomeIndex)
	GetTeamSchedule($HomeIndex)

	; Look through today's schedule to see if the home team is playing
	For $i = 0 to UBound($TodaySchedule) - 1
		If $TodaySchedule[$i][1] = $TeamNHL[$HomeIndex] Then
			$NHLGameID = $TodaySchedule[$i][3]
			$SelectedGame = $i
		EndIf
	Next

	$HomeTeamUpdated = True
EndFunc

Func UpdateAwayTeam()						; Get updated information for the Away Team
	GUICtrlSetData($cmbAway, $TeamLong[$AwayIndex])
	GUICtrlSetData($cmbAGoalie1, "")
	GUICtrlSetData($cmbAGoalie1, GetTeamGoalies($AwayIndex))
	GUICtrlSetData($cmbAGoalie2, "")
	GUICtrlSetData($cmbAGoalie2, GetTeamGoalies($AwayIndex))

	Local $AwayPlayers = GetTeamPlayers($AwayIndex)

	; Fill offensive line combo boxes
	Local $i, $j
	For $i = 0 To 3
		For $j = 0 To 2
			GUICtrlSetData($cmbAO[$i][$j], "")
			GUICtrlSetData($cmbAO[$i][$j], $AwayPlayers)
		Next
	Next

	; Fill defensive line combo boxes
	Local $i, $j
	For $i = 0 To 2
		For $j = 0 To 1
			GUICtrlSetData($cmbAD[$i][$j], "")
			GUICtrlSetData($cmbAD[$i][$j], $AwayPlayers)
		Next
	Next

	; Go get other info about the team
	GetTeamLineUp($AwayIndex)
	GetTeamSchedule($AwayIndex)

	; Look through today's schedule to see if the home team is playing
	For $i = 0 to UBound($TodaySchedule) - 1
		If $TodaySchedule[$i][0] = $TeamNHL[$AwayIndex] Then
			$NHLGameID = $TodaySchedule[$i][3]
			$SelectedGame = $i
		EndIf
	Next

	$AwayTeamUpdated = True
EndFunc

Func GetTeamPlayers($team, $sort = True) 	; Returns an array of players for $team = Index
	Local $i
	Local $temparray[$PlayerCount[$team] + 1]

	For $i = 0 To $PlayerCount[$team] - 1
		$temparray[$i] = FlipName($AllPlayers[$team][$i][2])
	Next

	If $sort Then
		_ArraySort($temparray)
	EndIf

	Local $temp = _ArrayToString($temparray, "|")

	Return $temp
EndFunc   ;==>GetTeamPlayers

Func GetTeamGoalies($team, $sort = True) 	; Returns an array of goalies for $team = Index
	Local $i
	Local $temparray[$GoalieCount[$team] + 1]

	For $i = 0 To $GoalieCount[$team] - 1
		$temparray[$i] = FlipName($AllGoalies[$team][$i][1])
	Next

	If $sort Then
		_ArraySort($temparray)
	EndIf

	Local $temp = _ArrayToString($temparray, "|")

	Return $temp
EndFunc   ;==>GetTeamGoalies

Func GetUpdatedStats() 						; Download and parse team and player statistics
	Local $tempfile = @ScriptDir & "\Data\teamlist.html"
	If FileExists($tempfile) Then
		Local $filetime = FileGetTimeForDiff($tempfile)
	EndIf

	If Not FileExists($tempfile) Or _DateDiff("n",$filetime,_NowCalc()) > 15 Then
		FileDelete($tempfile)
		Local $hDownload = InetGet("http://www.nhl.com/stats/rest/team?isAggregate=false&reportType=basic&isGame=false&reportName=teamsummary&cayenneExp=seasonId=20172018%20and%20gameTypeId=2", $tempfile, 1, 0)
	EndIf

	$FileHnd = FileOpen($tempfile)
	$teamlist = FileRead($FileHnd)
	FileClose($FileHnd)

	$json_teamlist = _JSONDecode($teamlist)

	If _JSONIsObject($json_teamlist) Then
		GUISetState(@SW_DISABLE,$frmMain)
		ProgressOn("Updating Stats", "Team stats downloading...")
	Else
		MsgBox(0, "Error", "Team Stats error has occured. " & @CRLF & "Please report in /r/GameTime")
		Exit
	EndIf

	$AllTeams = _JSONGet($json_teamlist,"data")

	Dim $TeamInfo[UBound($AllTeams)][$TeamStatCount]
	Dim $Rankings[UBound($AllTeams)][4]
	Dim $Step = 0

	For $i = 0 To (UBound($AllTeams) - 1)
		$Step += 1
		$_Percent = ($Step / 120) * 100
		$_Percent = _Max(_Min($_Percent, 99), 1)

		$team = _JSONGet($json_teamlist,"data." & $i)
		$Rankings[$i][0] = $i

		For $j = 0 to $TeamStatCount - 1
			If $j = 0 Then
				$TeamInfo[$i][$j] = 0
			ElseIf $j = 1 Then
				$teamnum = FindArrayEntry($TeamNamesAbbr,_JSONGet($team,"teamAbbrev"))
				$TeamID[$teamnum] = _JSONGet($team,"teamId")
				$TeamInfo[$i][$j] = $TeamCities[$teamnum]
				ProgressSet($_Percent, "Parsing standings for: " & $TeamInfo[$i][$j])
			Else
				$TeamInfo[$i][$j] = _JSONGet($team,$TeamStats_JSON[$j])
				If $TeamStats[$j] = "P" Then
					$Rankings[$i][1] = $TeamInfo[$i][$j]
				ElseIf $TeamStats[$j] = "GP" Then
					$Rankings[$i][2] = $TeamInfo[$i][$j]
				ElseIf $TeamStats[$j] = "ROW" Then
					$Rankings[$i][3] = $TeamInfo[$i][$j]
				EndIf
			EndIf
		Next

		Sleep(50)
	Next

	_ArraySort($Rankings,1,0,0,1,0)
	For $i = 0 to UBound($Rankings) - 1
		$TeamInfo[$Rankings[$i][0]][0] = $i + 1
	Next
	_ArraySort($TeamInfo,0,0,0,0,0)

	$FileHnd = FileOpen($StandingsFile, 10)
	FileWriteLine($FileHnd, "|" & _ArrayToString($TeamStats, "|") & "|")
	FileWriteLine($FileHnd, "|" & _ArrayToString($TableHeader, "|", 0, $TeamStatCount + 1) & "|")
	For $i = 0 To UBound($TeamInfo) - 1
		$Step += 1
		$_Percent = ($Step / 120) * 100
		$_Percent = _Max(_Min($_Percent, 99), 1)
		Local $teamIndex = GetTeamIndex($TeamInfo[$i][1])
		If $teamIndex = -1 Then
			MsgBox(48,"Error","Could not find index for " & $TeamInfo[$i][1])
		Else
			ProgressSet($_Percent, "Writing standings for: " & $TeamInfo[$i][1])

			Dim $temparray[$TeamStatCount]
			For $j = 0 To $TeamStatCount - 1
				If $j = 1 Then
					$temparray[$j] = "[" & $TeamInfo[$i][$j] & "](" & $TeamReddits[$teamindex] & ")"
				Else
					$temparray[$j] = $TeamInfo[$i][$j]
				EndIf
			Next
			$templine = _ArrayToString($temparray, "|")
			FileWriteLine($FileHnd, "|" & $templine & "|")
		EndIf
		Sleep(50)
	Next
	FileClose($FileHnd)

	; Clear out variables
	Dim $TeamRoster[UBound($TeamInfo)][50]
	Dim $TeamGoalies[UBound($TeamInfo)][10]

	; Open file and write headers
	Dim $AllPlayersFileHnd = FileOpen($AllPlayersFile, 10)
	FileWriteLine($AllPlayersFileHnd,"Team|" & _ArrayToString($PlayerStats,"|"))
	FileWriteLine($AllPlayersFileHnd,_ArrayToString($TableHeader,"|",0,$PlayerStatCount))

	; Open file and write headers
	Dim $AllGoaliesFileHnd = FileOpen($AllGoaliesFile, 10)
	FileWriteLine($AllGoaliesFileHnd,"Team|" & _ArrayToString($GoalieStats,"|"))
	FileWriteLine($AllGoaliesFileHnd,_ArrayToString($TableHeader,"|",0,$GoalieStatCount))

	For $i = 0 To UBound($TeamInfo) - 1
		Local $teamIndex = GetTeamIndex($TeamInfo[$i][1])
		If $teamIndex = -1 Then
			MsgBox(48,"Error","Could not find index for " & $TeamInfo[$i][1])
		Else
			Local $tempfile = @ScriptDir & "\Data\" & $TeamNames[$teamindex] & "-teamlist.txt"
			If FileExists($tempfile) Then
				Local $filetime = FileGetTimeForDiff($tempfile)
			EndIf

			If Not FileExists($tempfile) Or _DateDiff("n",$filetime,_NowCalc()) > 15 Then
				FileDelete($tempfile)
				Local $hDownload = InetGet("https://statsapi.web.nhl.com/api/v1/teams/" & $TeamID[$i] & "?hydrate=franchise(roster(season=20172018,person(name,stats(splits=[statsSingleSeason]))))", $tempfile, 1, 0)
			EndIf

			$FileHnd = FileOpen($tempfile)
			$teampage = FileRead($FileHnd)
			FileClose($FileHnd)

			If StringLen($teampage) Then
				$playersregex = StringRegExp($teampage, '<td class="noLftBdr"><span class="sweaterNo">(?<number>[0-9]*)</span></td>[\r\n\t\s ]*<td class="rw(?:.*)">(?<pos>[A-Za-z]*)</td>[\r\n\t\s ]*<td class="left"><nobr><a href="/club/player.htm\?id=[0-9]*" rel="[\w]*:[0-9]*">(?<player>.*)</a></nobr></td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<gp>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<g>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<a>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<p>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<pm>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<pim>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<pp>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<sh>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<gw>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<s>.*)</td>[\r\n\t\s ]*<td class="(?:rw|c)[\w]*">(?<sp>.*)</td>[\r\n\t\s ]*</tr>', 3)

				$Step += 1
				$_Percent = ($Step / 120) * 100
				$_Percent = _Max(_Min($_Percent, 99), 1)
				ProgressSet($_Percent, "Parsing and writing players for: " & $TeamInfo[$i][1])

				;$FileHnd = FileOpen(@ScriptDir & "\" & $TeamLong[$teamindex] & "\Players.txt", 10)
				;FileWriteLine($FileHnd, "|" & _ArrayToString($PlayerStats, "|") & "|")
				;FileWriteLine($FileHnd, "|" & _ArrayToString($TableHeader, "|", 0, 13) & "|")
				For $j = 0 To (UBound($playersregex) / 14) - 1
					$TeamRoster[$i][$j] = _ArrayToString($playersregex, "|", ($j * 14), ($j * 14) + 13)
					;FileWriteLine($FileHnd, "|" & $TeamRoster[$i][$j] & "|")
					FileWriteLine($AllPlayersFileHnd, $TeamCities[$teamindex] & "|" & $TeamRoster[$i][$j])
				Next
				;FileClose($FileHnd)

				$goaliesregex = StringRegExp($teampage, '<tr class="rw(?:Even|Odd)">[\r\n\t\s ]*<td class="noLftBdr"><span class="sweaterNo">(?<num>[0-9]*)</span></td>[\r\n\t\s ]*<td class="left"><nobr><a href="/club/player.htm\?id=[0-9]*" rel="[\w ]*:[0-9]*">(?<name>[\w\- ]*)</a></nobr></td>[\r\n\t\s ]*<td class="[\w ]*">(?<gpi>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<gs>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<min>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<gaa>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<w>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<l>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<ot>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<so>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<sa>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<ga>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<svp>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<g>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<a>[0-9\.]*)</td>[\r\n\t\s ]*<td class="[\w ]*">(?<pim>[0-9\.]*)</td>', 3)

				$Step += 1
				$_Percent = ($Step / 120) * 100
				$_Percent = _Max(_Min($_Percent, 99), 1)
				ProgressSet($_Percent, "Parsing and writing goalies for: " & $TeamInfo[$i][1])

				;$FileHnd = FileOpen(@ScriptDir & "\" & $TeamLong[$teamindex] & "\Goalies.txt", 10)
				;FileWriteLine($FileHnd, "|" & _ArrayToString($GoalieStats, "|") & "|")
				;FileWriteLine($FileHnd, "|" & _ArrayToString($TableHeader, "|", 0, 16) & "|")
				For $j = 0 To (UBound($goaliesregex) / 16) - 1
					$TeamGoalies[$i][$j] = _ArrayToString($goaliesregex, "|", ($j * 16), ($j * 16) + 15)
					;FileWriteLine($FileHnd, "|" & $TeamGoalies[$i][$j] & "|")
					FileWriteLine($AllGoaliesFileHnd, $TeamCities[$teamindex] & "|" & $TeamGoalies[$i][$j])
				Next
				;FileClose($FileHnd)

			EndIf
		EndIf
	Next

	FileClose($AllPlayersFileHnd)
	FileClose($AllGoaliesFileHnd)

	ProgressSet(100, "Cleaning up...")
	Sleep(2000)
	ProgressOff()
	GUISetState(@SW_ENABLE,$frmMain)

	Local $t = FileGetTime($AllPlayersFile, 0)
	Local $t_format = $t[1] & "/" & $t[2] & "/" & $t[0] & " " & $t[3] & ":" & $t[4] & ":" & $t[5]
	GUICtrlSetData($lblStatTime, "Last updated: " & $t_format)
EndFunc   ;==>GetUpdatedStats

Func GetTeamLineUp($teamindex)				; Download team lineups from dailyfaceoff
	; Offensive lines: 	<td id="LW[0-9]">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<LW>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<C>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[0-9]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<RW>[\w\.&#;\-'' ]*)</a>[\s]*</td>
	; Defensive lines: 	<td id="LD[0-9]">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<LD>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<RD>[\w\.&#;\-'' ]*)</a>[\s]*</td>
	; Goalies: 			<td id="G1">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<G1>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<G2>[\w\.&#;\-'' ]*)</a>[\s]*</td>

	Local $tempfile = @ScriptDir & "\Data\" & $TeamNames[$teamindex] & "-lineup.html"
	If FileExists($tempfile) Then
		Local $filetime = FileGetTimeForDiff($tempfile)
	EndIf

	If Not FileExists($tempfile) Or _DateDiff("n",$filetime,_NowCalc()) > 15 Then
		FileDelete($tempfile)
		Local $hDownload = InetGet($TeamLineUpBaseURL & $TeamLineUpURL[$teamindex], $tempfile, 1, 0)
	EndIf

	$FileHnd = FileOpen($tempfile)
	Local $lineup = FileRead($FileHnd)
	FileClose($FileHnd)

	Local $tmpOffensiveLines = StringRegExp($lineup, '<td id="LW[0-9]">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<LW>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<C>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[0-9]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<RW>[\w\.&#;\-'' ]*)</a>[\s]*</td>', 3)
	If @error Then
		MsgBox(0, "Error", "Offensive Lines RegEx error: " & @error & " for team: " & $TeamNamesFormatted[$teamindex] & @CRLF & "This is most likely an error with DailyFaceOff. Please set your lines manually.")
		Return 0
	Else
	EndIf

	Local $tmpDefensiveLines = StringRegExp($lineup, '<td id="LD[0-9]">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<LD>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<RD>[\w\.&#;\-'' ]*)</a>[\s]*</td>', 3)
	If @error Then
		MsgBox(0, "Error", "Defensive Lines RegEx error: " & @error & " for team: " & $TeamNamesFormatted[$teamindex] & @CRLF & "This is most likely an error with DailyFaceOff. Please set your lines manually.")
		Return 0
	Else
	EndIf

	Local $tmpGoalies = StringRegExp($lineup, '<td id="G1">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<G1>[\w\.&#;\-'' ]*)</a>[\s]*</td>[\s]*<td id="[\w]*">[\s]*<a href="[\w\.\:\-/ ]*"><img src="[\w\.\-\:/% ]*"  width="[\w]*px" height="auto" alt="[\w\.&#;\-'' ]*" />[\s]*<br />(?<G2>[\w\.&#;\-'' ]*)</a>[\s]*</td>', 3)
	If @error Then
		MsgBox(0, "Error", "Goalies RegEx error: " & @error & " for team: " & $TeamNamesFormatted[$teamindex] & @CRLF & "This is most likely an error with DailyFaceOff. Please set your lines manually.")
		Return 0
	Else
	EndIf


	;_ArrayDisplay($tmpOffensiveLines)
	;_ArrayDisplay($tmpDefensiveLines)
	;_ArrayDisplay($tmpGoalies)

	If $HomeIndex = $teamindex Then
		If UBound($tmpOffensiveLines) = 12 Then
			GUICtrlSetData($cmbHO[0][0],FlipName($tmpOffensiveLines[0]),FlipName($tmpOffensiveLines[0]))
			GUICtrlSetData($cmbHO[0][1],FlipName($tmpOffensiveLines[1]),FlipName($tmpOffensiveLines[1]))
			GUICtrlSetData($cmbHO[0][2],FlipName($tmpOffensiveLines[2]),FlipName($tmpOffensiveLines[2]))
			GUICtrlSetData($cmbHO[1][0],FlipName($tmpOffensiveLines[3]),FlipName($tmpOffensiveLines[3]))
			GUICtrlSetData($cmbHO[1][1],FlipName($tmpOffensiveLines[4]),FlipName($tmpOffensiveLines[4]))
			GUICtrlSetData($cmbHO[1][2],FlipName($tmpOffensiveLines[5]),FlipName($tmpOffensiveLines[5]))
			GUICtrlSetData($cmbHO[2][0],FlipName($tmpOffensiveLines[6]),FlipName($tmpOffensiveLines[6]))
			GUICtrlSetData($cmbHO[2][1],FlipName($tmpOffensiveLines[7]),FlipName($tmpOffensiveLines[7]))
			GUICtrlSetData($cmbHO[2][2],FlipName($tmpOffensiveLines[8]),FlipName($tmpOffensiveLines[8]))
			GUICtrlSetData($cmbHO[3][0],FlipName($tmpOffensiveLines[9]),FlipName($tmpOffensiveLines[9]))
			GUICtrlSetData($cmbHO[3][1],FlipName($tmpOffensiveLines[10]),FlipName($tmpOffensiveLines[10]))
			GUICtrlSetData($cmbHO[3][2],FlipName($tmpOffensiveLines[11]),FlipName($tmpOffensiveLines[11]))
		Else
			MsgBox(16,"Error","The lineups page for " & $TeamNames[$HomeIndex] & " returned incomplete or unexpected offensive line data. This is a problem with dailyfaceoff.com. Sorry.")
		EndIf


		If UBound($tmpDefensiveLines) = 6 Then
			GUICtrlSetData($cmbHD[0][0],FlipName($tmpDefensiveLines[0]),FlipName($tmpDefensiveLines[0]))
			GUICtrlSetData($cmbHD[0][1],FlipName($tmpDefensiveLines[1]),FlipName($tmpDefensiveLines[1]))
			GUICtrlSetData($cmbHD[1][0],FlipName($tmpDefensiveLines[2]),FlipName($tmpDefensiveLines[2]))
			GUICtrlSetData($cmbHD[1][1],FlipName($tmpDefensiveLines[3]),FlipName($tmpDefensiveLines[3]))
			GUICtrlSetData($cmbHD[2][0],FlipName($tmpDefensiveLines[4]),FlipName($tmpDefensiveLines[4]))
			GUICtrlSetData($cmbHD[2][1],FlipName($tmpDefensiveLines[5]),FlipName($tmpDefensiveLines[5]))
		Else
			MsgBox(16,"Error","The lineups page for " & $TeamNames[$HomeIndex] & " returned incomplete or unexpected defensive line data.  This is a problem with dailyfaceoff.com. Sorry.")
		EndIf

		If UBound($tmpGoalies) = 2 Then
			GUICtrlSetData($cmbHGoalie1,FlipName($tmpGoalies[0]),FlipName($tmpGoalies[0]))
			GUICtrlSetData($cmbHGoalie2,FlipName($tmpGoalies[1]),FlipName($tmpGoalies[1]))
		Else
			MsgBox(16,"Error","The lineups page for " & $TeamNames[$HomeIndex] & " returned incomplete or unexpected goalie data.  This is a problem with dailyfaceoff.com. Sorry.")
		EndIf
	EndIf
	If $AwayIndex = $teamindex Then
		If UBound($tmpOffensiveLines) = 12 Then
			GUICtrlSetData($cmbAO[0][0],FlipName($tmpOffensiveLines[0]),FlipName($tmpOffensiveLines[0]))
			GUICtrlSetData($cmbAO[0][1],FlipName($tmpOffensiveLines[1]),FlipName($tmpOffensiveLines[1]))
			GUICtrlSetData($cmbAO[0][2],FlipName($tmpOffensiveLines[2]),FlipName($tmpOffensiveLines[2]))
			GUICtrlSetData($cmbAO[1][0],FlipName($tmpOffensiveLines[3]),FlipName($tmpOffensiveLines[3]))
			GUICtrlSetData($cmbAO[1][1],FlipName($tmpOffensiveLines[4]),FlipName($tmpOffensiveLines[4]))
			GUICtrlSetData($cmbAO[1][2],FlipName($tmpOffensiveLines[5]),FlipName($tmpOffensiveLines[5]))
			GUICtrlSetData($cmbAO[2][0],FlipName($tmpOffensiveLines[6]),FlipName($tmpOffensiveLines[6]))
			GUICtrlSetData($cmbAO[2][1],FlipName($tmpOffensiveLines[7]),FlipName($tmpOffensiveLines[7]))
			GUICtrlSetData($cmbAO[2][2],FlipName($tmpOffensiveLines[8]),FlipName($tmpOffensiveLines[8]))
			GUICtrlSetData($cmbAO[3][0],FlipName($tmpOffensiveLines[9]),FlipName($tmpOffensiveLines[9]))
			GUICtrlSetData($cmbAO[3][1],FlipName($tmpOffensiveLines[10]),FlipName($tmpOffensiveLines[10]))
			GUICtrlSetData($cmbAO[3][2],FlipName($tmpOffensiveLines[11]),FlipName($tmpOffensiveLines[11]))
		Else
			MsgBox(16,"Error","The lineups page for " & $TeamNames[$AwayIndex] & " returned incomplete or unexpected offensive line data.  This is a problem with dailyfaceoff.com. Sorry.")
		EndIf


		If UBound($tmpDefensiveLines) = 6 Then
			GUICtrlSetData($cmbAD[0][0],FlipName($tmpDefensiveLines[0]),FlipName($tmpDefensiveLines[0]))
			GUICtrlSetData($cmbAD[0][1],FlipName($tmpDefensiveLines[1]),FlipName($tmpDefensiveLines[1]))
			GUICtrlSetData($cmbAD[1][0],FlipName($tmpDefensiveLines[2]),FlipName($tmpDefensiveLines[2]))
			GUICtrlSetData($cmbAD[1][1],FlipName($tmpDefensiveLines[3]),FlipName($tmpDefensiveLines[3]))
			GUICtrlSetData($cmbAD[2][0],FlipName($tmpDefensiveLines[4]),FlipName($tmpDefensiveLines[4]))
			GUICtrlSetData($cmbAD[2][1],FlipName($tmpDefensiveLines[5]),FlipName($tmpDefensiveLines[5]))
		Else
			MsgBox(16,"Error","The lineups page for " & $TeamNames[$AwayIndex] & " returned incomplete or unexpected defensive line data.  This is a problem with dailyfaceoff.com. Sorry.")
		EndIf

		If UBound($tmpGoalies) = 2 Then
			GUICtrlSetData($cmbAGoalie1,FlipName($tmpGoalies[0]),FlipName($tmpGoalies[0]))
			GUICtrlSetData($cmbAGoalie2,FlipName($tmpGoalies[1]),FlipName($tmpGoalies[1]))
		Else
			MsgBox(16,"Error","The lineups page for " & $TeamNames[$AwayIndex] & " returned incomplete or unexpected goalie data.  This is a problem with dailyfaceoff.com. Sorry.")
		EndIf
	EndIf
EndFunc

Func GetTeamInjuries()						; Download team injuries from TSN
; Team regex: <td [\w\=\' ]*><h3>(?<team>[\w\.; ]*)</h3></td></tr>(?:<thead>)?<tr><th class='alignLeft'>Player</th><th>Date</th><th class='alignLeft'>Status</th><th class='alignLeft'>Description</th></tr></thead>(?<playerlist>(?:<tr class='bg[\d]'><td class='alignLeft noBr'><a href="/nhl/teams/players/\?name=(?:[\w\+`\- ]*)">(?:[\w\+&;`\- ]*)</a></td><th class='noBr'>(?:[\w\- ]*)</th><td class='alignLeft'>(?:[\w\-\' ]*)</td><th class='alignLeft'>(?:[\w\-//' ]*)</th></tr>)*)(?:<tr>|</table>)
; Player regex: <tr class='bg[\d]'><td class='alignLeft noBr'><a href="/nhl/teams/players/\?name=(?:[\w\+`\- ]*)">(?<player>[\w\+&;`\- ]*)</a></td><th class='noBr'>(?<date>[\w\- ]*)</th><td class='alignLeft'>(?<status>[\w\-\' ]*)</td><th class='alignLeft'>(?<injury>[\w\-//' ]*)</th></tr>

	Local $tempfile = @ScriptDir & "\Data\injuries.html"
	If FileExists($tempfile) Then
		Local $filetime = FileGetTimeForDiff($tempfile)
	EndIf

	If Not FileExists($tempfile) Or _DateDiff("n",$filetime,_NowCalc()) > 15 Then
		FileDelete($tempfile)
		Local $hDownload = InetGet($InjuryURL, $tempfile, 1, 0)
	EndIf

	$FileHnd = FileOpen($tempfile)
	Local $file = FileRead($FileHnd)
	FileClose($FileHnd)

	$file = StringReplace($file,"&nbsp;"," ")

	Local $tmpTeams = StringRegExp($file, '<td [\w\=\'' ]*><h3>(?<team>[\w\.; ]*)</h3></td></tr>(?:<thead>)?<tr><th class=''alignLeft''>Player</th><th>Date</th><th class=''alignLeft''>Status</th><th class=''alignLeft''>Description</th></tr></thead>(?<playerlist>(?:<tr class=''bg[\d]''><td class=''alignLeft noBr''><a href="/nhl/teams/players/\?name=(?:[\w\+`\-. ]*)">(?:[\w\+&;`\-. ]*)</a></td><th class=''noBr''>(?:[\w\- ]*)</th><td class=''alignLeft''>(?:[\w\-\.'' ]*)</td><th class=''alignLeft''>(?:[\w\-//'' ]*)</th></tr>)*)(?:<tr>|</table>)', 3)
	If @error Then
		MsgBox(0, "Error", "Team Injury RegEx error: " & @error & @CRLF & "Please report in /r/GameTime.")
		Return -1
	EndIf

	Local $i
	For $i = 0 to UBound($tmpTeams)-1 Step 2
		Local $teamindex = FindArrayEntry($TeamTSN,$tmpTeams[$i])
		If $teamindex = -1 Then
			MsgBox(16,"Error","Could not find team entry for " & $tmpTeams[$i])
		Else
			Local $players = StringRegExp($tmpTeams[$i + 1],'<tr class=''bg[\d]''><td class=''alignLeft noBr''><a href="/nhl/teams/players/\?name=(?:[\w\+`\- ]*)">(?<player>[\w\+&;`\- ]*)</a></td><th class=''noBr''>(?<date>[\w\- ]*)</th><td class=''alignLeft''>(?<status>[\w\-\'' ]*)</td><th class=''alignLeft''>(?<injury>[\w\-//'' ]*)</th></tr>',3)

			IF @error Then
				MsgBox(16,"Error","Team Injury Player RegEx error: " & @error & @CRLF & "Please report in /r/GameTime.")
				Return -1
			Else
				Local $j,$k

				$TeamInjuryCount[$teamindex] = UBound($players) / 4

				For $j = 0 to UBound($players) - 1 Step 4
					If $j > 0 Then
						$k = $j / 4
					Else
						$k = 0
					EndIf
					$TeamInjuries[$teamindex][$k][0] = $players[$j + 0]
					$TeamInjuries[$teamindex][$k][1] = $players[$j + 1]
					$TeamInjuries[$teamindex][$k][2] = $players[$j + 2]
					$TeamInjuries[$teamindex][$k][3] = $players[$j + 3]
				Next
			EndIf
		EndIf
	Next

EndFunc

Func GetTeamSchedule($teamindex)			; Download team schedule from NHL.com
	;Schedule: <td  class="left" width="110" nowrap>[\s]*(?<date>[\w, ]*)[\s]*</td>[\s]*<td class="left" width="76" nowrap>(?<home>[\w ]*)</td>[\s]*<td class="left" nowrap>[\s]*(?<away>[\w ]*)<br>[\s]*</td>[\s]*<td class="left" nowrap>[\s]*(?<time>[0-9\:]*) (?:AM|PM)[\s]*</td>[\s]*<td class="left">[\s]*(?<broadcast>[\w\-,\(\)<>="/ ]*)[\s]*</td>
	Local $tempfile = @ScriptDir & "\Data\" & $TeamNames[$teamindex] & "-schedule.html"
	If FileExists($tempfile) Then
		Local $filetime = FileGetTimeForDiff($tempfile)
	EndIf

	; Check for local file and if it is older than a certain time
	If Not FileExists($tempfile) Or _DateDiff("n",$filetime,_NowCalc()) > 15 Then
		FileDelete($tempfile)
		Local $hDownload = InetGet("http://" & StringLower($TeamNames[$teamindex]) & ".nhl.com/club/schedule.htm", $tempfile, 1, 0)
	EndIf

	$FileHnd = FileOpen($tempfile)
	local $teamSchedule = FileRead($FileHnd)
	FileClose($FileHnd)

	; NHL Club websites show the date in two different orders: WED, 1 JAN 2014 or WED JAN 01 2014
	; We define two different RegExp strings and will test which one is correct
	Local $DateRegex[2] = ["(?<dow>[\w]*) (?<month>[\w]*) (?<date>[\d]*), (?<year>[\d]*)", "(?<dow>[\w]*), (?<date>[\d]*) (?<month>[\w]*) (?<year>[\d]*)"]
	Local $DateRegexSel

	; Filter info using RegExp
	Local $tmpSchedule = StringRegExp($teamSchedule, '<td  class="left" width="110" nowrap>[\s]*(?<date>[\w, ]*)[\s]*</td>[\s]*<td class="left" width="76" nowrap>(?<home>[\w ]*)</td>[\s]*<td class="left" nowrap>[\s]*(?<away>[\w ]*)<br>[\s]*</td>[\s]*<td class="left" nowrap>[\s]*(?<time>[0-9\:]*) (?:AM|PM)[\s]*</td>[\s]*<td class="left">[\s]*(?<broadcast>[\w\-,\(\)<>="/ ]*)[\s]*</td>', 3)
	If @error Then
		MsgBox(0, "Error", "Schedule RegEx error: " & @error & " for team: " & $TeamNamesFormatted[$teamindex] & @CRLF & "Please report in /r/GameTime.")
		Return 0
	Else
	EndIf

	; Test the first date to see which one it is
	Select
		Case StringRegExp($tmpSchedule[0],$DateRegex[0])
			$DateRegexSel = 0
		Case StringRegExp($tmpSchedule[0],$DateRegex[1])
			$DateRegexSel = 1
	EndSelect

	If $teamindex = $HomeIndex And Not $HomeTeamUpdated Then
		$HomeScheduleIndex = $teamindex

		ReDim $HomeSchedule[UBound($tmpSchedule) / 5][5]
		ReDim $HomeGameDates[UBound($tmpSchedule) / 5]
		Local $i

		For $i = 0 to (UBound($tmpSchedule) - 1) Step 5
			Local $tmpDateArr = StringRegExp($tmpSchedule[$i],$DateRegex[$DateRegexSel],1)

			If Not IsArray($tmpDateArr) Then
				MsgBox(0,"Debug",$tmpSchedule[$i])
			EndIf

			Switch $DateRegexSel
				Case 0
					If StringLen($tmpDateArr[2]) = 1 Then $tmpDateArr[2] = "0" & $tmpDateArr[2]
					Local $tmpDateStr = (FindArrayEntry($Months,$tmpDateArr[1]) + 1) & "/" & $tmpDateArr[2] & "/" & $tmpDateArr[3]
				Case 1
					If StringLen($tmpDateArr[1]) = 1 Then $tmpDateArr[1] = "0" & $tmpDateArr[1]
					Local $tmpDateStr = (FindArrayEntry($Months,$tmpDateArr[2]) + 1) & "/" & $tmpDateArr[1] & "/" & $tmpDateArr[3]
			EndSwitch

			$HomeGameDates[$i / 5] = $tmpDateStr
			$HomeSchedule[$i / 5][0] = $tmpDateStr
			$HomeSchedule[$i / 5][1] = $tmpSchedule[$i + 1]
			$HomeSchedule[$i / 5][2] = $tmpSchedule[$i + 2]
			$HomeSchedule[$i / 5][3] = $tmpSchedule[$i + 3]
			$HomeSchedule[$i / 5][4] = $tmpSchedule[$i + 4]

			$HomeSchedule[$i / 5][4] = StringReplace($HomeSchedule[$i / 5][4],"FINAL ","")
			$HomeSchedule[$i / 5][4] = StringRegExpReplace($HomeSchedule[$i / 5][4],'<span class="black">(?<team>[\w\(\) ]*)</span>',"**$1**")
			$HomeSchedule[$i / 5][4] = StringReplace($HomeSchedule[$i / 5][4],"<span>","")
			$HomeSchedule[$i / 5][4] = StringReplace($HomeSchedule[$i / 5][4],"</span>","")
		Next

		Local $CheckGame = FindArrayEntry($HomeGameDates,Int(@MON) & "/" & @MDAY & "/" & @YEAR)
		If $CheckGame <> -1 Then
			GUICtrlSetData($inpStartTime,$HomeSchedule[$CheckGame][3])
			If StringLower($HomeSchedule[$CheckGame][2]) = StringLower($TeamNamesFormatted[$HomeIndex]) Then
				Local $CheckAwayIndex = FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$CheckGame][1])
				If $CheckAwayIndex <> $AwayIndex Then
					$AwayIndex = $CheckAwayIndex
					$AwayTeamUpdated = False
					UpdateAwayTeam()
				EndIf
			Else
				MsgBox(48,"What's going on?","The team you have selected as Home has a game on this date, but is not the home team.")
			EndIf
		EndIf

	ElseIf $teamindex = $AwayIndex And Not $AwayTeamUpdated Then
		$AwayScheduleIndex = $teamindex

		ReDim $AwaySchedule[UBound($tmpSchedule) / 5][5]
		ReDim $AwayGameDates[UBound($tmpSchedule) / 5]
		Local $i

		For $i = 0 to (UBound($tmpSchedule) - 1) Step 5
			Local $tmpDateArr = StringRegExp($tmpSchedule[$i],$DateRegex[$DateRegexSel],1)

			If Not IsArray($tmpDateArr) Then
				MsgBox(0,"Debug",$tmpSchedule[$i])
			EndIf

			Switch $DateRegexSel
				Case 0
					If StringLen($tmpDateArr[2]) = 1 Then $tmpDateArr[2] = "0" & $tmpDateArr[2]
					Local $tmpDateStr = (FindArrayEntry($Months,$tmpDateArr[1]) + 1) & "/" & $tmpDateArr[2] & "/" & $tmpDateArr[3]
				Case 1
					If StringLen($tmpDateArr[1]) = 1 Then $tmpDateArr[1] = "0" & $tmpDateArr[1]
					Local $tmpDateStr = (FindArrayEntry($Months,$tmpDateArr[2]) + 1) & "/" & $tmpDateArr[1] & "/" & $tmpDateArr[3]
			EndSwitch

			$AwayGameDates[$i / 5] = $tmpDateStr
			$AwaySchedule[$i / 5][0] = $tmpDateStr
			$AwaySchedule[$i / 5][1] = $tmpSchedule[$i + 1]
			$AwaySchedule[$i / 5][2] = $tmpSchedule[$i + 2]
			$AwaySchedule[$i / 5][3] = $tmpSchedule[$i + 3]
			$AwaySchedule[$i / 5][4] = $tmpSchedule[$i + 4]
		Next

		Local $CheckGame = FindArrayEntry($AwayGameDates,@MON & "/" & @MDAY & "/" & @YEAR)
		If $CheckGame <> -1 Then
			If StringLower($AwaySchedule[$CheckGame][1]) = StringLower($TeamNamesFormatted[$AwayIndex]) Then
				Local $CheckHomeIndex = FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$CheckGame][2])
				If $CheckHomeIndex <> $HomeIndex Then
					$HomeIndex = $CheckHomeIndex
					$HomeTeamUpdated = False
					UpdateHomeTeam()
				EndIf
			Else
				MsgBox(48,"What's going on?","The team you have selected as Away has a game on this date, but is not the away team.")
			EndIf
		EndIf

	EndIf
EndFunc

Func GetScheduleToday()						; Download today's schedule from NHL.com
	;Schedule: href="(?:[\w\(\):; ]*)">(?<away>[\w. ]*)</a></div></td><td colspan="1" rowspan="1" class="team"><!-- Home --><a style="border-bottom:1px dotted;" onclick="(?:[\w\(\):; ]*)" rel="[\w]*" shape="rect" href="(?:[\w\(\):; ]*)"><div style="background-position: [\d\-]*px [\d\-]*px;margin-right: 5px" class="display teamJewel [\w]*"><!-- Black Background 50% Opacity Overlay --><div></div></div></a><div class="teamName"><a style="border-bottom:1px dotted;" onclick="(?:[\w\(\):; ]*)" rel="[\w]*" shape="rect" href="(?:[\w\(\):; ]*)">(?<home>[\w. ]*)</a></div></td><td colspan="1" rowspan="1" class="time"><!-- Time --><div style="display:block;" class="skedStartTimeEST">(?:[\w: ]*)</div><div style="display:none;" class="skedStartTimeLocal">(?:[\w: ]*)</div></td><td colspan="1" rowspan="1" class="tvInfo"><!-- Network -->[\s]*(?<broadcast>[\w\-, ]*)[\s]*</td><td colspan="1" rowspan="1" class="skedLinks"><!-- Button Links --><a class="btn" shape="rect" href="http://www.nhl.com/gamecenter/en/preview\?id=(?<gameid>[\d]*)"><span>PREVIEW›</span>
	Local $tempfile = @ScriptDir & "\Data\today-schedule.html"
	If FileExists($tempfile) Then
		Local $filetime = FileGetTimeForDiff($tempfile)
	EndIf

	; Check for local file and if it is older than a certain time
	If Not FileExists($tempfile) Or _DateDiff("h",$filetime,_NowCalc()) > 1 Then
		FileDelete($tempfile)
		Local $hDownload = InetGet("http://www.nhl.com/ice/schedulebyday.htm?navid=nav-sch-today", $tempfile, 1, 0)
	EndIf

	$FileHnd = FileOpen($tempfile)
	local $leagueschedule = FileRead($FileHnd)
	FileClose($FileHnd)

	; Filter info using RegExp
	$tempsched = StringRegExp($leagueschedule,'href="(?:[\w\(\):; ]*)">(?<away>[^\<\>]*)</a></div></td><td colspan="1" rowspan="1" class="team"><!-- Home --><a onclick="(?:[\w\(\):; ]*)" rel="[\w]*" shape="rect" href="(?:[\w\(\):; ]*)"><img title="[^\"]*" alt="[^\"]*" class="[^\"]*" src="[^\"]*"/></a><div class="teamName"><a onclick="[^\"]*" rel="[^\"]*" shape="rect" href="[^\"]*">(?<home>[^\<\>]*)</a></div></td><td colspan="1" rowspan="1" class="time"><!-- Time --><div style="display:block;" class="skedStartTimeEST">(?<time>[\w: ]*)</div><div style="display:none;" class="skedStartTimeLocal">(?:[\w: ]*)</div></td><td colspan="1" rowspan="1" class="tvInfo"><!-- Network -->[\s]*(?<broadcast>[\w\-,\+ ]*)[\s]*</td><td colspan="1" rowspan="1" class="skedLinks"><!-- Button Links --><a class="btn" shape="rect" href="http://www.nhl.com/gamecenter/en/preview\?id=(?<gameid>[\d]*)"><span>PREVIEW›</span>',3)
	If @error Then
		MsgBox(0, "Error", "League Schedule RegEx error: " & @error & @CRLF & "Please report in /r/GameTime.")
		Return 0
	Else
	EndIf

	; Clear and set up schedule variables
	Global $TodaySchedule[UBound($tempsched) / 5][5]
	Global $TodayAwayTeams[UBound($tempsched) / 5]
	Global $TodayHomeTeams[UBound($tempsched) / 5]

	Local $i,$j
	For $i = 0 to (UBound($tempsched) / 5) - 1
		$j = ($i * 5)

		$TodaySchedule[$i][0] = $tempsched[$j + 0]	; Away Team
		$TodaySchedule[$i][1] = $tempsched[$j + 1]	; Home Team
		$TodaySchedule[$i][2] = $tempsched[$j + 3]	; Broadcast Information
		$TodaySchedule[$i][3] = $tempsched[$j + 4]	; GameCenter Game ID
		$TodaySchedule[$i][4] = $tempsched[$j + 2]	; Start Time

		;ConsoleWrite($TodaySchedule[$i][0])
		$TodayAwayTeams[$i] = $TeamLong[FindArrayEntry($TeamCities,$TodaySchedule[$i][0])]
		$TodayHomeTeams[$i] = $TeamLong[FindArrayEntry($TeamCities,$TodaySchedule[$i][1])]
	Next

	;_ArrayDisplay($TodaySchedule)

EndFunc

Func GetTeamIndex($team)					; Find team index in $TeamCities
	For $a = 0 To 30
		If StringUpper($team) = StringUpper($TeamCities[$a]) Then
			Return $a
		EndIf
	Next

	Return -1
EndFunc   ;==>GetTeamIndex

Func GetStreams($teamindex,$rate = "*")		; Get team VLC streams
	;Streams: <ipad_url>(?<url>[\w\s\:\./ ]*)</ipad_url>
	Local $tempfile = @ScriptDir & "\Data\streams.xml"
	If FileExists($tempfile) Then
		Local $filetime = FileGetTimeForDiff($tempfile)
	EndIf

	If Not FileExists($tempfile) Or _DateDiff("n",$filetime,_NowCalc()) > 15 Then
		FileDelete($tempfile)
        HttpSetUserAgent("AppleCoreMedia/1.0.0.8C148 (iPad; U; CPU OS 4_2_1 like Mac OS X; en_us)")
		Local $hDownload = InetGet("http://feeds.cdnak.neulion.com/fs/nhl/mobile/feeds/data/" & @YEAR & @MON & @MDAY & ".xml", $tempfile, 1, 0)
		HttpSetUserAgent("GameTime " & _ArrayToString($MyVerArray,"."))
	EndIf

	$FileHnd = FileOpen($tempfile)
	Local $streamfile = FileRead($FileHnd)
	FileClose($FileHnd)

	Local $tmpStreams = StringRegExp($streamfile, '(?<url>http://[\w\s\:\./ ]*ipad.m3u8)', 3)
;~ 	If @error Then
;~ 		MsgBox(0, "Error", "VLC Streams RegEx error: " & @error & " for team: " & $TeamNamesFormatted[$teamindex] & @CRLF & "Please report in /r/GameTime.")
;~ 	Else
;~  EndIf

	Local $i
	For $i = 0 to UBound($tmpStreams) - 1
		If StringInStr($tmpStreams[$i],$TeamNames[$teamindex]) Then
			Local $streamlist,$j
			If $rate = "*" Then
				For $j = 0 to 4
					$streamlist &= "[" & $StreamRates[$j] & "](" & StringReplace($tmpStreams[$i],"ipad",$StreamRates[$j]) & ")"
					If $j < 4 Then $streamlist &= " - "
				Next
				Return $streamlist
			Else
				$streamlist = "[" & $rate & "](" & StringReplace($tmpStreams[$i],"ipad",$rate) & ")"
				Return $streamlist
			EndIf
		EndIf
	Next

	Return "**NO STREAM**"
EndFunc

Func BuildThread()							; Build thread file from template - This function replaces all the tags
	If FileExists($TemplateFile) Then
		Local $file = FileRead($TemplateFile)
	Else
		MsgBox(48,"Template File Not Found","Please select a template file that exists.")
		Return
	EndIf

	Local $i
	For $i = 0 to UBound($TodaySchedule) - 1
		If $TodaySchedule[$i][0] = $TeamCities[$AwayIndex] And $TodaySchedule[$i][1] = $TeamCities[$HomeIndex] Then
			$GameBroadcast = $TodaySchedule[$i][2]
			$NHLGameID = $TodaySchedule[$i][3]
		EndIf
	Next

	;Start Applying Tags

	#region TAGS - Date and Game Info
	$file = StringReplace($file,"{date:dayofweek}",_DateDayOfWeek(@WDAY))
	$file = StringReplace($file,"{date:mmddyyyy}",@MON & "/" & @MDAY & "/" & @YEAR)
	$file = StringReplace($file,"{date:ddmmyyyy}",@MDAY & "/" & @MON & "/" & @YEAR)

	Local $GameTime = GUICtrlRead($inpStartTime)
	Local $GameHour = StringRemove($GameTime,":")
	Local $GameTZ = $TeamTimeZone[$HomeIndex]
	Local $GamePST,$GameMST,$GameCST,$GameEST,$GameAST

	Select
		Case $GameTZ = "PT"
			$GamePST = $GameHour & ":" & $GameTime
			$GameMST = $GameHour + 1 & ":" & $GameTime
			$GameCST = $GameHour + 2 & ":" & $GameTime
			$GameEST = $GameHour + 3 & ":" & $GameTime
			$GameAST = $GameHour + 4 & ":" & $GameTime
		Case $GameTZ = "MT"
			$GamePST = $GameHour - 1 & ":" & $GameTime
			$GameMST = $GameHour & ":" & $GameTime
			$GameCST = $GameHour + 1 & ":" & $GameTime
			$GameEST = $GameHour + 2 & ":" & $GameTime
			$GameAST = $GameHour + 3 & ":" & $GameTime
		Case $GameTZ = "CT"
			$GamePST = $GameHour - 2 & ":" & $GameTime
			$GameMST = $GameHour - 1 & ":" & $GameTime
			$GameCST = $GameHour & ":" & $GameTime
			$GameEST = $GameHour + 1 & ":" & $GameTime
			$GameAST = $GameHour + 2 & ":" & $GameTime
		Case $GameTZ = "ET"
			$GamePST = $GameHour - 3 & ":" & $GameTime
			$GameMST = $GameHour - 2 & ":" & $GameTime
			$GameCST = $GameHour - 1 & ":" & $GameTime
			$GameEST = $GameHour & ":" & $GameTime
			$GameAST = $GameHour + 1 & ":" & $GameTime
	EndSelect

	$file = StringReplace($file,"{gametime:local}",GUICtrlRead($inpStartTime))
	$file = StringReplace($file,"{gametime:timezone}",$GameTZ)
	$file = StringReplace($file,"{gametime:pst}",$GamePST)
	$file = StringReplace($file,"{gametime:mst}",$GameMST)
	$file = StringReplace($file,"{gametime:cst}",$GameCST)
	$file = StringReplace($file,"{gametime:est}",$GameEST)
	$file = StringReplace($file,"{gametime:ast}",$GameAST)
	$file = StringReplace($file,"{gametime:pt}",$GamePST)
	$file = StringReplace($file,"{gametime:mt}",$GameMST)
	$file = StringReplace($file,"{gametime:ct}",$GameCST)
	$file = StringReplace($file,"{gametime:et}",$GameEST)
	$file = StringReplace($file,"{gametime:at}",$GameAST)

	$file = StringReplace($file,"{game:broadcast}",$GameBroadcast)
	$file = StringReplace($file,"{game:nhlgameid}",$NHLGameID)
	#endregion

	#region TAGS - League

	;Rankings
	If StringInStr($file,"{league:rankings}") Then
		Local $textblock,$i,$j,$team[$TeamStatCount],$hi,$lo
		If $TeamRank[$HomeIndex] > $TeamRank[$AwayIndex] Then
			$Hi = $TeamRank[$HomeIndex]
			$Lo = $TeamRank[$AwayIndex]
		Else
			$Lo = $TeamRank[$HomeIndex]
			$Hi = $TeamRank[$AwayIndex]
		EndIf

		If ($Hi - $Lo) <= 2 Then
			For $i = $Lo - 1 to $Hi + 1
				For $j = 0 to $TeamStatCount - 1
					If $i = $Lo or $i = $Hi Then
						$team[$j] = "**" & $AllStandings[$i][$j] & "**"
					Else
						$team[$j] = $AllStandings[$i][$j]
					EndIf
				Next
				$textblock &= "|" & _ArrayToString($team,"|") & "|" & @CRLF
			Next
		Else
			For $i = $Lo - 1 to $Lo + 1
				For $j = 0 to $TeamStatCount - 1
					If $i = $Lo or $i = $Hi Then
						$team[$j] = "**" & $AllStandings[$i][$j] & "**"
					Else
						$team[$j] = $AllStandings[$i][$j]
					EndIf
				Next
				$textblock &= "|" & _ArrayToString($team,"|") & "|" & @CRLF
			Next

			For $i = $Hi - 1 to $Hi + 1
				For $j = 0 to $TeamStatCount - 1
					If $i = $Lo or $i = $Hi Then
						$team[$j] = "**" & $AllStandings[$i][$j] & "**"
					Else
						$team[$j] = $AllStandings[$i][$j]
					EndIf
				Next
				$textblock &= "|" & _ArrayToString($team,"|") & "|" & @CRLF
			Next
		EndIf

		$file = StringReplace($file,"{league:rankings}",$textblock)
	EndIf

	;Team Ranks with Fields and Options
	Local $standings = StringRegExp($file,"{league:rankings:(?<fields>[\w\-\%+/, ]*):?(?<options>[\w\-/, ]*)}",3)
	If Not @error Then
		Local $textblock,$textline,$i,$j,$k,$hi,$lo

		$textblock = ""
		$textline = ""

		For $i = 0 to UBound($standings) - 1 Step 2
			Local $statlist = StringSplit($standings[$i],",",2)
			Local $optionlist = StringSplit($standings[$i + 1],",",2)

			If FindArrayEntry($optionlist,"noheader") = -1 Then
				Local $tmpstatlist = $statlist
				Local $j
				For $j = 0 to UBound($tmpstatlist) - 1
					If FindArrayEntry($TeamStats,$statlist[$j]) = -1 Then
						$tmpstatlist[$j] = ""
					EndIf
				Next

				$textblock &= "|" & _ArrayToString($tmpstatlist,"|") & "|" & @CRLF
				$textblock &= _ArrayToString($TableHeader,"|",0,UBound($statlist)-1) & @CRLF
			EndIf

			If Int($TeamRank[$HomeIndex]) > Int($TeamRank[$AwayIndex]) Then
				$Hi = $TeamRank[$HomeIndex]
				$Lo = $TeamRank[$AwayIndex]
			Else
				$Lo = $TeamRank[$HomeIndex]
				$Hi = $TeamRank[$AwayIndex]
			EndIf

			Local $team[UBound($statlist)]
			Local $LoStart,$LoEnd,$HiStart,$HiEnd

			If $Lo = 1 Then
				$LoStart = 1
				$LoEnd = 2
			Else
				$LoStart = $Lo - 1
				$LoEnd = $Lo + 1
			EndIf

			If $Hi = 31 Then
				If $Hi = $LoEnd Then
					$HiStart = $Hi
					$HiEnd = $Hi
					$LoEnd = $Lo
				Else
					$HiStart = 30
					$HiEnd = 31
				EndIf
			Else
				If $Hi = $LoEnd Then
					$LoEnd = $Lo
					$HiStart = $Hi
					$HiEnd = $Hi + 1
				Else
					$HiStart = $Hi - 1
					$HiEnd = $Hi + 1
				EndIf
			EndIf

			For $j = $LoStart to $HiEnd
				If ($j >= $LoStart And $j <= $LoEnd) or ($j >= $HiStart And $j <= $HiEnd) Then
					Local $tmphighlight
					Local $teamindex = GetTeamIndex($AllStandings[$j][1])

					$textline = "|"

					If $j = $Lo Or $j = $Hi Then
						$tmphighlight = "**"
					Else
						$tmphighlight = ""
					EndIf

					For $k = 0 to UBound($statlist) - 1
						If FindArrayEntry($TeamStats,$statlist[$k]) > -1 Then
							$textline &= $tmphighlight & $AllStandings[$j][FindArrayEntry($TeamStats,$statlist[$k])] & $tmphighlight & "|"
						Else
							Select
								Case StringLower($statlist[$k]) = "nameabbr"
									$textline &= $tmphighlight & $TeamNamesAbbr[$teamindex] & $tmphighlight& "|"
								Case StringLower($statlist[$k]) = "redditname"
									$textline &= $tmphighlight & "[" & $TeamNamesFormatted[$teamindex] & "](" & $TeamReddits[$teamindex] & ")" & $tmphighlight & "|"
								Case StringLower($statlist[$k]) = "redditicon"
									$textline &= $tmphighlight & "[](" & $TeamReddits[$teamindex] & ")" & $tmphighlight & "|"
								Case StringLower($statlist[$k]) = "redditabbr"
									$textline &= $tmphighlight & "[" & $TeamNamesAbbr[$teamindex] & "](" & $TeamReddits[$teamindex] & ")" & $tmphighlight & "|"
							EndSelect
						EndIf
					Next
					$textblock &= $textline
					If $j <> $HiEnd Then $textblock &= @CRLF
				EndIf

			Next

			If StringLen($standings[$i + 1]) Then
				$file = StringReplace($file,"{league:rankings:" & $standings[$i] & ":" & $standings[$i + 1] & "}",$textblock)
			Else
				$file = StringReplace($file,"{league:rankings:" & $standings[$i] & "}",$textblock)
			EndIf
		Next
	EndIf

	#endregion

	#region TAGS - Team Name and Other Info
	;Home Info
	$file = StringReplace($file,"{home:long}",$TeamLong[$HomeIndex])
	$file = StringReplace($file,"{home:short}",$TeamNamesFormatted[$HomeIndex])
	$file = StringReplace($file,"{home:city}",$TeamCities[$HomeIndex])
	$file = StringReplace($file,"{home:arena}",$TeamArenas[$HomeIndex])
	$file = StringReplace($file,"{home:arenaplace}",$TeamArenaPlace[$HomeIndex])
	$file = StringReplace($file,"{home:nameabbr}",$TeamNamesAbbr[$HomeIndex])

	$file = StringReplace($file,"{home:reddit}",$TeamReddits[$HomeIndex])
	$file = StringReplace($file,"{home:redditname}","[" & $TeamNamesFormatted[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")")
	$file = StringReplace($file,"{home:redditicon}","[](" & $TeamReddits[$HomeIndex] & ")")
	$file = StringReplace($file,"{home:redditabbr}","[" & $TeamNamesAbbr[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")")
    $file = StringReplace($file,"{home:redditiconlarge}","[](" & $TeamRedditLogos[$HomeIndex] & ")")
	$file = StringReplace($file,"{home:radio}","[" & $TeamNamesFormatted[$HomeIndex] & " Radio](http://" & $TeamNames[$HomeIndex] & ".nhl.com/club/RadioPlayer.htm?id=" & $NHLGameID & ")")

	;Away Info
	$file = StringReplace($file,"{away:long}",$TeamLong[$AwayIndex])
	$file = StringReplace($file,"{away:short}",$TeamNamesFormatted[$AwayIndex])
	$file = StringReplace($file,"{away:city}",$TeamCities[$AwayIndex])
	$file = StringReplace($file,"{away:nameabbr}",$TeamNamesAbbr[$AwayIndex])

	$file = StringReplace($file,"{away:reddit}",$TeamReddits[$AwayIndex])
	$file = StringReplace($file,"{away:redditname}","[" & $TeamNamesFormatted[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")")
	$file = StringReplace($file,"{away:redditicon}","[](" & $TeamReddits[$AwayIndex] & ")")
	$file = StringReplace($file,"{away:redditabbr}","[" & $TeamNamesAbbr[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")")
    $file = StringReplace($file,"{away:redditiconlarge}","[](" & $TeamRedditLogos[$AwayIndex] & ")")
	$file = StringReplace($file,"{away:radio}","[" & $TeamNamesFormatted[$AwayIndex] & " Radio](http://" & $TeamNames[$AwayIndex] & ".nhl.com/club/RadioPlayer.htm?id=" & $NHLGameID & ")")

	#endregion

	;Const $TeamStats[$TeamStatCount] = ["Rank","Team","GP","W","L","OT","P","ROW","P%","G/G","GA/G","PP%","PK%","S/G","SA/G","FO%"]
	#region TAGS - Team Stats
	$file = StringReplace($file,"{home:stats:rank}",  $AllStandings[$TeamRank[$HomeIndex]][0])
	$file = StringReplace($file,"{home:stats:gp}",    $AllStandings[$TeamRank[$HomeIndex]][2])
	$file = StringReplace($file,"{home:stats:w}",     $AllStandings[$TeamRank[$HomeIndex]][3])
	$file = StringReplace($file,"{home:stats:l}",     $AllStandings[$TeamRank[$HomeIndex]][4])
	$file = StringReplace($file,"{home:stats:ot}",    $AllStandings[$TeamRank[$HomeIndex]][5])
	$file = StringReplace($file,"{home:stats:p}",     $AllStandings[$TeamRank[$HomeIndex]][6])
	$file = StringReplace($file,"{home:stats:row}",   $AllStandings[$TeamRank[$HomeIndex]][7])
	$file = StringReplace($file,"{home:stats:p%}",    $AllStandings[$TeamRank[$HomeIndex]][8])
	$file = StringReplace($file,"{home:stats:g/g}",   $AllStandings[$TeamRank[$HomeIndex]][9])
	$file = StringReplace($file,"{home:stats:ga/g}",  $AllStandings[$TeamRank[$HomeIndex]][10])
	$file = StringReplace($file,"{home:stats:pp%}",   $AllStandings[$TeamRank[$HomeIndex]][11])
	$file = StringReplace($file,"{home:stats:pk%}",   $AllStandings[$TeamRank[$HomeIndex]][12])
	$file = StringReplace($file,"{home:stats:s/g}",   $AllStandings[$TeamRank[$HomeIndex]][13])
	$file = StringReplace($file,"{home:stats:sa/g}",  $AllStandings[$TeamRank[$HomeIndex]][14])
	$file = StringReplace($file,"{home:stats:fo%}",   $AllStandings[$TeamRank[$HomeIndex]][15])

	$file = StringReplace($file,"{away:stats:rank}",  $AllStandings[$TeamRank[$AwayIndex]][0])
	$file = StringReplace($file,"{away:stats:gp}",    $AllStandings[$TeamRank[$AwayIndex]][2])
	$file = StringReplace($file,"{away:stats:w}",     $AllStandings[$TeamRank[$AwayIndex]][3])
	$file = StringReplace($file,"{away:stats:l}",     $AllStandings[$TeamRank[$AwayIndex]][4])
	$file = StringReplace($file,"{away:stats:ot}",    $AllStandings[$TeamRank[$AwayIndex]][5])
	$file = StringReplace($file,"{away:stats:p}",     $AllStandings[$TeamRank[$AwayIndex]][6])
	$file = StringReplace($file,"{away:stats:row}",   $AllStandings[$TeamRank[$AwayIndex]][7])
	$file = StringReplace($file,"{away:stats:p%}",    $AllStandings[$TeamRank[$AwayIndex]][8])
	$file = StringReplace($file,"{away:stats:g/g}",   $AllStandings[$TeamRank[$AwayIndex]][9])
	$file = StringReplace($file,"{away:stats:ga/g}",  $AllStandings[$TeamRank[$AwayIndex]][10])
	$file = StringReplace($file,"{away:stats:pp%}",   $AllStandings[$TeamRank[$AwayIndex]][11])
	$file = StringReplace($file,"{away:stats:pk%}",   $AllStandings[$TeamRank[$AwayIndex]][12])
	$file = StringReplace($file,"{away:stats:s/g}",   $AllStandings[$TeamRank[$AwayIndex]][13])
	$file = StringReplace($file,"{away:stats:sa/g}",  $AllStandings[$TeamRank[$AwayIndex]][14])
	$file = StringReplace($file,"{away:stats:fo%}",   $AllStandings[$TeamRank[$AwayIndex]][15])

	#endregion

	#region TAGS - Team Streams
	;Home streams
	If StringInStr($file,"{home:streams}") Then
		$file = StringReplace($file,"{home:streams}",GetStreams($HomeIndex))
	EndIf

	;Home Streams with Rates
	Local $homestreams = StringRegExp($file,"{home:streams:(?<fields>[\w\-+/, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline

		For $i = 0 to UBound($homestreams) - 1
			$textblock = ""
			$textline = ""

			Local $ratelist = StringSplit($homestreams[$i],",",2)

			Local $j,$k

			For $j = 0 to UBound($ratelist) - 1
				If FindArrayEntry($StreamRates,$ratelist[$j]) > -1 Then
					$textline = GetStreams($HomeIndex,$ratelist[$j])
				EndIf

				$textblock &= $textline
				If $j < UBound($ratelist) - 1 Then $textblock &= " - "
			Next

			$file = StringReplace($file,"{home:streams:" & $homestreams[$i] & "}",$textblock)
		Next
	EndIf

	;Away Streams
	If StringInStr($file,"{away:streams}") Then
		$file = StringReplace($file,"{away:streams}",GetStreams($AwayIndex))
	EndIf

	;Away Streams with Rates
	Local $awaystreams = StringRegExp($file,"{away:streams:(?<fields>[\w\-+/, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline

		For $i = 0 to UBound($awaystreams) - 1
			$textblock = ""
			$textline = ""

			Local $ratelist = StringSplit($awaystreams[$i],",",2)

			Local $j,$k

			For $j = 0 to UBound($ratelist) - 1
				If FindArrayEntry($StreamRates,$ratelist[$j]) > -1 Then
					$textline = GetStreams($AwayIndex,$ratelist[$j])
				EndIf

				$textblock &= $textline
				If $j < UBound($ratelist) - 1 Then $textblock &= " - "
			Next

			$file = StringReplace($file,"{away:streams:" & $awaystreams[$i] & "}",$textblock)
		Next
	EndIf

	#endregion

	#region TAGS - Stat Tables
	;Home Player Table
	If StringInStr($file,"{home:players}") Then
		Local $homeplayers,$i,$j,$player[14]
		For $i = 0 to 4
			For $j = 0 to 13
				$player[$j] = $AllPlayers[$HomeIndex][$i][$j]
			Next
			$homeplayers &= "|[](" & $TeamReddits[$HomeIndex] & ")|" & _ArrayToString($player,"|") & "|"
			If $i < 4 Then $homeplayers &= @CRLF
		Next
		$file = StringReplace($file,"{home:players}",$homeplayers)
	EndIf

	;Home Player Table with Fields and Options
	Local $homeplayers = StringRegExp($file,"{home:players:(?<fields>[\w\-+/=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline,$limitcount

		;_ArrayDisplay($homeplayers)

		For $i = 0 to UBound($homeplayers) - 1 Step 2
			$textblock = ""
			$textline = ""

			Local $statlist = StringSplit($homeplayers[$i],",",2)
			Local $optionlist = StringSplit($homeplayers[$i + 1],",",2)

			If FindArrayEntry($PlayerStats,$statlist[0]) = -1 And FindArrayEntry($SpecialFields,$statlist[0]) = -1 Then
				$optionlist = $statlist
				$statlist = $PlayerStats
			EndIf

			If FindArrayEntry($optionlist,"noheader") = -1 Then
				Local $tmpstatlist = $statlist
				Local $j
				For $j = 0 to UBound($tmpstatlist) - 1
					If FindArrayEntry($PlayerStats,$statlist[$j]) = -1 Then
						$tmpstatlist[$j] = ""
					EndIf
				Next

				$textblock &= "|" & _ArrayToString($tmpstatlist,"|") & "|" & @CRLF
				$textblock &= _ArrayToString($TableHeader,"|",0,UBound($statlist)-1) & @CRLF
			EndIf

			Local $j,$k

			$limitcount = 5
			For $j = 0 to UBound($optionlist) - 1
				If StringLower(StringLeft($optionlist[$j],5)) = "limit" Then
					$limitcount = Int(StringRight($optionlist[$j],StringLen($optionlist[$j]) - 6))
				EndIf
			Next

			For $j = 0 to $limitcount - 1
				$textline = "|"
				For $k = 0 to UBound($statlist) - 1
					If FindArrayEntry($PlayerStats,$statlist[$k]) > -1 Then
						$textline &= $AllPlayers[$HomeIndex][$j][FindArrayEntry($PlayerStats,$statlist[$k])] & "|"
					Else
						Select
							Case StringLower($statlist[$k]) = "nameabbr"
								$textline &= $TeamNamesAbbr[$HomeIndex] & "|"
							Case StringLower($statlist[$k]) = "redditname"
								$textline &= "[" & $TeamNamesFormatted[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditicon"
								$textline &= "[](" & $TeamReddits[$HomeIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditabbr"
								$textline &= "[" & $TeamNamesAbbr[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
						EndSelect
					EndIf
				Next

				$textblock &= $textline
				If $j < ($limitcount - 1) Then $textblock &= @CRLF
			Next

			If StringLen($homeplayers[$i + 1]) Then
				$file = StringReplace($file,"{home:players:" & $homeplayers[$i] & ":" & $homeplayers[$i + 1] & "}",$textblock)
			Else
				$file = StringReplace($file,"{home:players:" & $homeplayers[$i] & "}",$textblock)
			EndIf
		Next
	EndIf

	;Home Goalie Table
	If StringInStr($file,"{home:goalies}") Then
		Local $homegoalies,$i,$j,$player[16]
		For $i = 0 to $GoalieCount[$HomeIndex] - 1
			For $j = 0 to 15
				$player[$j] = $AllGoalies[$HomeIndex][$i][$j]
			Next
			$homegoalies &= "|[](" & $TeamReddits[$HomeIndex] & ")|" & _ArrayToString($player,"|") & "|"
			If $i < $GoalieCount[$HomeIndex] - 1 Then $homegoalies &= @CRLF
		Next
		$file = StringReplace($file,"{home:goalies}",$homegoalies)
	EndIf

	;Home Goalie Table with Fields and Options
	Local $homegoalies = StringRegExp($file,"{home:goalies:(?<fields>[\w\-+/%=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline,$limitcount

		;_ArrayDisplay($homegoalies)

		For $i = 0 to UBound($homegoalies) - 1 Step 2
			$textblock = ""
			$textline = ""

			Local $statlist = StringSplit($homegoalies[$i],",",2)
			Local $optionlist = StringSplit($homegoalies[$i + 1],",",2)

			If FindArrayEntry($GoalieStats,$statlist[0]) = -1 And FindArrayEntry($SpecialFields,$statlist[0]) = -1 Then
				$optionlist = $statlist
				$statlist = $GoalieStats
			EndIf

			If FindArrayEntry($optionlist,"noheader") = -1 Then
				Local $tmpstatlist = $statlist
				Local $j
				For $j = 0 to UBound($tmpstatlist) - 1
					If FindArrayEntry($GoalieStats,$statlist[$j]) = -1 Then
						$tmpstatlist[$j] = ""
					EndIf
				Next

				$textblock &= "|" & _ArrayToString($tmpstatlist,"|") & "|" & @CRLF
				$textblock &= _ArrayToString($TableHeader,"|",0,UBound($statlist)-1) & @CRLF
			EndIf

			Local $j,$k

			$limitcount = $GoalieCount[$HomeIndex]
			For $j = 0 to UBound($optionlist) - 1
				If StringLower(StringLeft($optionlist[$j],5)) = "limit" Then
					$limitcount = Int(StringRight($optionlist[$j],StringLen($optionlist[$j]) - 6))
					If $limitcount > $GoalieCount[$HomeIndex] Then
						$limitcount = $Goaliecount[$HomeIndex]
					EndIf
				EndIf
			Next

			For $j = 0 to $limitcount - 1
				$textline = "|"
				For $k = 0 to UBound($statlist) - 1
					If FindArrayEntry($GoalieStats,$statlist[$k]) > -1 Then
						$textline &= $AllGoalies[$HomeIndex][$j][FindArrayEntry($GoalieStats,$statlist[$k])] & "|"
					Else
						Select
							Case StringLower($statlist[$k]) = "nameabbr"
								$textline &= $TeamNamesAbbr[$HomeIndex] & "|"
							Case StringLower($statlist[$k]) = "redditname"
								$textline &= "[" & $TeamNamesFormatted[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditicon"
								$textline &= "[](" & $TeamReddits[$HomeIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditabbr"
								$textline &= "[" & $TeamNamesAbbr[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
						EndSelect
					EndIf
				Next

				$textblock &= $textline
				If $j < ($limitcount - 1) Then $textblock &= @CRLF
			Next

			If StringLen($homegoalies[$i + 1]) Then
				$file = StringReplace($file,"{home:goalies:" & $homegoalies[$i] & ":" & $homegoalies[$i + 1] & "}",$textblock)
			Else
				$file = StringReplace($file,"{home:goalies:" & $homegoalies[$i] & "}",$textblock)
			EndIf
		Next
	EndIf

	;Away Stats
	If StringInStr($file,"{away:players}") Then
		Local $Awayplayers,$i,$j,$player[14]
		For $i = 0 to 4
			For $j = 0 to 13
				$player[$j] = $AllPlayers[$AwayIndex][$i][$j]
			Next
			$awayplayers &= "|[](" & $TeamReddits[$AwayIndex] & ")|" & _ArrayToString($player,"|") & "|"
			If $i < 4 Then $awayplayers &= @CRLF
		Next
		$file = StringReplace($file,"{away:players}",$Awayplayers)
	EndIf

	;Away Stats with Fields and Options
	Local $awayplayers = StringRegExp($file,"{away:players:(?<fields>[\w\-+/=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline

		;_ArrayDisplay($awayplayers)

		For $i = 0 to UBound($awayplayers) - 1 Step 2
			$textblock = ""
			$textline = ""

			Local $statlist = StringSplit($awayplayers[$i],",",2)
			Local $optionlist = StringSplit($awayplayers[$i + 1],",",2)

			If FindArrayEntry($PlayerStats,$statlist[0]) = -1 And FindArrayEntry($SpecialFields,$statlist[0]) = -1 Then
				$optionlist = $statlist
				$statlist = $PlayerStats
			EndIf

			If FindArrayEntry($optionlist,"noheader") = -1 Then
				Local $tmpstatlist = $statlist
				Local $j
				For $j = 0 to UBound($tmpstatlist) - 1
					If FindArrayEntry($PlayerStats,$statlist[$j]) = -1 Then
						$tmpstatlist[$j] = ""
					EndIf
				Next

				$textblock &= "|" & _ArrayToString($tmpstatlist,"|") & "|" & @CRLF
				$textblock &= _ArrayToString($TableHeader,"|",0,UBound($statlist)-1) & @CRLF
			EndIf

			Local $j,$k

			$limitcount = 5
			For $j = 0 to UBound($optionlist) - 1
				If StringLower(StringLeft($optionlist[$j],5)) = "limit" Then
					$limitcount = Int(StringRight($optionlist[$j],StringLen($optionlist[$j]) - 6))
				EndIf
			Next

			For $j = 0 to $limitcount - 1
				$textline = "|"
				For $k = 0 to UBound($statlist) - 1
					If FindArrayEntry($PlayerStats,$statlist[$k]) > -1 Then
						$textline &= $AllPlayers[$awayIndex][$j][FindArrayEntry($PlayerStats,$statlist[$k])] & "|"
					Else
						Select
							Case StringLower($statlist[$k]) = "nameabbr"
								$textline &= $TeamNamesAbbr[$AwayIndex] & "|"
							Case StringLower($statlist[$k]) = "redditname"
								$textline &= "[" & $TeamNamesFormatted[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditicon"
								$textline &= "[](" & $TeamReddits[$AwayIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditabbr"
								$textline &= "[" & $TeamNamesAbbr[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
						EndSelect
					EndIf
				Next
				$textblock &= $textline
				If $j < ($limitcount - 1) Then $textblock &= @CRLF
			Next

			If StringLen($awayplayers[$i + 1]) Then
				$file = StringReplace($file,"{away:players:" & $awayplayers[$i] & ":" & $awayplayers[$i + 1] & "}",$textblock)
			Else
				$file = StringReplace($file,"{away:players:" & $awayplayers[$i] & "}",$textblock)
			EndIf
		Next
	EndIf

	;Away Goalie Stats
	If StringInStr($file,"{away:goalies}") Then
		Local $Awaygoalies,$i,$j,$player[16]
		For $i = 0 to $GoalieCount[$AwayIndex] - 1
			For $j = 0 to 15
				$player[$j] = $AllGoalies[$AwayIndex][$i][$j]
			Next
			$Awaygoalies &= "|[](" & $TeamReddits[$AwayIndex] & ")|" & _ArrayToString($player,"|") & "|"
			If $i < $GoalieCount[$AwayIndex] - 1 Then $awaygoalies &= @CRLF
		Next
		$file = StringReplace($file,"{away:goalies}",$Awaygoalies)
	EndIf

	;Away Goalie Stats with Fields and Options
	Local $awaygoalies = StringRegExp($file,"{away:goalies:(?<fields>[\w\-+/%=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline

		;_ArrayDisplay($awaygoalies)

		For $i = 0 to UBound($awaygoalies) - 1 Step 2
			$textblock = ""
			$textline = ""

			Local $statlist = StringSplit($awaygoalies[$i],",",2)
			Local $optionlist = StringSplit($awaygoalies[$i + 1],",",2)

			If FindArrayEntry($GoalieStats,$statlist[0]) = -1 And FindArrayEntry($SpecialFields,$statlist[0]) = -1 Then
				$optionlist = $statlist
				$statlist = $GoalieStats
			EndIf

			If FindArrayEntry($optionlist,"noheader") = -1 Then
				Local $tmpstatlist = $statlist
				Local $j
				For $j = 0 to UBound($tmpstatlist) - 1
					If FindArrayEntry($GoalieStats,$statlist[$j]) = -1 Then
						$tmpstatlist[$j] = ""
					EndIf
				Next

				$textblock &= "|" & _ArrayToString($tmpstatlist,"|") & "|" & @CRLF
				$textblock &= _ArrayToString($TableHeader,"|",0,UBound($statlist)-1) & @CRLF
			EndIf

			Local $j,$k

			$limitcount = $GoalieCount[$AwayIndex]
			For $j = 0 to UBound($optionlist) - 1
				If StringLower(StringLeft($optionlist[$j],5)) = "limit" Then
					$limitcount = Int(StringRight($optionlist[$j],StringLen($optionlist[$j]) - 6))
					If $limitcount > $GoalieCount[$AwayIndex] Then
						$limitcount = $Goaliecount[$AwayIndex]
					EndIf
				EndIf
			Next

			For $j = 0 to $limitcount - 1
				$textline = "|"
				For $k = 0 to UBound($statlist) - 1
					If FindArrayEntry($GoalieStats,$statlist[$k]) > -1 Then
						$textline &= $AllGoalies[$AwayIndex][$j][FindArrayEntry($GoalieStats,$statlist[$k])] & "|"
					Else
						Select
							Case StringLower($statlist[$k]) = "nameabbr"
								$textline &= $TeamNamesAbbr[$AwayIndex] & "|"
							Case StringLower($statlist[$k]) = "redditname"
								$textline &= "[" & $TeamNamesFormatted[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditicon"
								$textline &= "[](" & $TeamReddits[$AwayIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditabbr"
								$textline &= "[" & $TeamNamesAbbr[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
						EndSelect
					EndIf
				Next

				$textblock &= $textline
				If $j < ($limitcount - 1) Then $textblock &= @CRLF
			Next

			If StringLen($awaygoalies[$i + 1]) Then
				$file = StringReplace($file,"{away:goalies:" & $awaygoalies[$i] & ":" & $awaygoalies[$i + 1] & "}",$textblock)
			Else
				$file = StringReplace($file,"{away:goalies:" & $awaygoalies[$i] & "}",$textblock)
			EndIf
		Next
	EndIf

	#endregion

	#region TAGS - Lineup Tags
	;Home Players
	$file = StringReplace($file,"{home:goalie1}",GUICtrlRead($cmbHGoalie1))
	$file = StringReplace($file,"{home:goalie2}",GUICtrlRead($cmbHGoalie2))

	$file = StringReplace($file,"{home:oleft1}",GUICtrlRead($cmbHO[0][0]))
	$file = StringReplace($file,"{home:oleft2}",GUICtrlRead($cmbHO[1][0]))
	$file = StringReplace($file,"{home:oleft3}",GUICtrlRead($cmbHO[2][0]))
	$file = StringReplace($file,"{home:oleft4}",GUICtrlRead($cmbHO[3][0]))

	$file = StringReplace($file,"{home:ocenter1}",GUICtrlRead($cmbHO[0][1]))
	$file = StringReplace($file,"{home:ocenter2}",GUICtrlRead($cmbHO[1][1]))
	$file = StringReplace($file,"{home:ocenter3}",GUICtrlRead($cmbHO[2][1]))
	$file = StringReplace($file,"{home:ocenter4}",GUICtrlRead($cmbHO[3][1]))

	$file = StringReplace($file,"{home:oright1}",GUICtrlRead($cmbHO[0][2]))
	$file = StringReplace($file,"{home:oright2}",GUICtrlRead($cmbHO[1][2]))
	$file = StringReplace($file,"{home:oright3}",GUICtrlRead($cmbHO[2][2]))
	$file = StringReplace($file,"{home:oright4}",GUICtrlRead($cmbHO[3][2]))

	$file = StringReplace($file,"{home:dleft1}",GUICtrlRead($cmbHD[0][0]))
	$file = StringReplace($file,"{home:dleft2}",GUICtrlRead($cmbHD[1][0]))
	$file = StringReplace($file,"{home:dleft3}",GUICtrlRead($cmbHD[2][0]))

	$file = StringReplace($file,"{home:dright1}",GUICtrlRead($cmbHD[0][1]))
	$file = StringReplace($file,"{home:dright2}",GUICtrlRead($cmbHD[1][1]))
	$file = StringReplace($file,"{home:dright3}",GUICtrlRead($cmbHD[2][1]))

	;Away Players
	$file = StringReplace($file,"{away:goalie1}",GUICtrlRead($cmbAGoalie1))
	$file = StringReplace($file,"{away:goalie2}",GUICtrlRead($cmbAGoalie2))

	$file = StringReplace($file,"{away:oleft1}",GUICtrlRead($cmbAO[0][0]))
	$file = StringReplace($file,"{away:oleft2}",GUICtrlRead($cmbAO[1][0]))
	$file = StringReplace($file,"{away:oleft3}",GUICtrlRead($cmbAO[2][0]))
	$file = StringReplace($file,"{away:oleft4}",GUICtrlRead($cmbAO[3][0]))

	$file = StringReplace($file,"{away:ocenter1}",GUICtrlRead($cmbAO[0][1]))
	$file = StringReplace($file,"{away:ocenter2}",GUICtrlRead($cmbAO[1][1]))
	$file = StringReplace($file,"{away:ocenter3}",GUICtrlRead($cmbAO[2][1]))
	$file = StringReplace($file,"{away:ocenter4}",GUICtrlRead($cmbAO[3][1]))

	$file = StringReplace($file,"{away:oright1}",GUICtrlRead($cmbAO[0][2]))
	$file = StringReplace($file,"{away:oright2}",GUICtrlRead($cmbAO[1][2]))
	$file = StringReplace($file,"{away:oright3}",GUICtrlRead($cmbAO[2][2]))
	$file = StringReplace($file,"{away:oright4}",GUICtrlRead($cmbAO[3][2]))

	$file = StringReplace($file,"{away:dleft1}",GUICtrlRead($cmbAD[0][0]))
	$file = StringReplace($file,"{away:dleft2}",GUICtrlRead($cmbAD[1][0]))
	$file = StringReplace($file,"{away:dleft3}",GUICtrlRead($cmbAD[2][0]))

	$file = StringReplace($file,"{away:dright1}",GUICtrlRead($cmbAD[0][1]))
	$file = StringReplace($file,"{away:dright2}",GUICtrlRead($cmbAD[1][1]))
	$file = StringReplace($file,"{away:dright3}",GUICtrlRead($cmbAD[2][1]))
	#endregion

	#region TAGS - Schedule Tags
	;Home Schedule
	If StringInStr($file,"{schedule:home}") Then
		Local $sched,$i,$j,$game[5],$todaygame
		$sched = "|" & _ArrayToString($ScheduleFields,"|") & "|" & @CRLF
		$sched &= _ArrayToString($TableHeader,0,4) & @CRLF

		Local $today = @MON & "/" & @MDAY & "/" & @YEAR
		For $j = 0 to UBound($HomeSchedule) - 1
			If $HomeSchedule[$j][0] = $today Then
				$todaygame = $j
				ExitLoop
			EndIf
		Next

		For $i = $todaygame + 1 to $todaygame + 5
			$game[0] = $sched[$i][0]
			$game[1] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNHL,$sched[$i][1])] & "](" & $TeamReddits[FindArrayEntry($TeamNHL,$sched[$i][1])] & ")"
			$game[2] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNHL,$sched[$i][2])] & "](" & $TeamReddits[FindArrayEntry($TeamNHL,$sched[$i][2])] & ")"
			$game[3] = $sched[$i][3]
			$game[4] = $sched[$i][4]

			$sched &= "|" & _ArrayToString($game,"|") & "|"
			If $i < 4 Then $sched &= @CRLF
		Next
		$file = StringReplace($file,"{schedule:home}",$sched)
	EndIf

	;Home Schedule with Fields and Options
	Local $homesched = StringRegExp($file,"{schedule:home:(?<fields>[\w\-+/=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$j,$k,$sched,$todaygame,$startgame,$endgame,$limitcount,$gamecount,$useicons
		For $i = 0 to UBound($homesched) - 1 Step 2
			Local $fieldlist = StringSplit($homesched[$i],",",2)
			Local $optionlist = StringSplit($homesched[$i + 1],",",2)

			If FindArrayEntry($ScheduleFields,$fieldlist[0]) <> -1 Then
				$sched = "|" & _ArrayToString($fieldlist,"|") & "|" & @CRLF
				$sched &= _ArrayToString($TableHeader,"|",0,UBound($fieldlist)-1) & @CRLF
			Else
				$optionlist = $fieldlist
				$fieldlist = $ScheduleFields
				$sched = "|" & _ArrayToString($ScheduleFields,"|") & "|" & @CRLF
				$sched &= _ArrayToString($TableHeader,"|",0,4) & @CRLF
			EndIf

			Local $today = Int(@MON) & "/" & @MDAY & "/" & @YEAR
			For $j = 0 to UBound($HomeSchedule) - 1
				If $HomeSchedule[$j][0] = $today Then
					$todaygame = $j
					ExitLoop
				EndIf
			Next

			If FindArrayEntry($optionlist,"past") <> -1 Then
				$startgame = 0
				$endgame = $todaygame - 1
				$sched = StringReplace($sched,$ScheduleFields[4],"Result")
			ElseIf FindArrayEntry($optionlist,"future") <> -1 Then
				$startgame = $todaygame + 1
				$endgame = UBound($AwaySchedule) - 1
				$sched = StringReplace($sched,$ScheduleFields[4],"Network")
			EndIf

			If FindArrayEntry($optionlist,"icons") <> -1 Then
				$useicons = True
			Else
				$useicons = False
			EndIf

			$limitcount = 5
			For $j = 0 to UBound($optionlist) - 1
				If StringLower(StringLeft($optionlist[$j],5)) = "limit" Then
					$limitcount = Int(StringRight($optionlist[$j],StringLen($optionlist[$j]) - 6))
				EndIf
			Next

			For $j = $startgame to $endgame
				If IsArray($fieldlist) Then
					Local $game[UBound($fieldlist)]
					For $k = 0 to UBound($fieldlist) - 1
						If StringLower($fieldlist[$k]) = "home" Then
							If $useicons Then
								$game[$k] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][2])] & ")"
							Else
								$game[$k] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][2])]
							EndIf
						ElseIf StringLower($fieldlist[$k]) = "away" Then
							If $useicons Then
								$game[$k] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][1])] & ")"
							Else
								$game[$k] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][1])]
							EndIf
						Else
							$game[$k] = $HomeSchedule[$j][FindArrayEntry($ScheduleFields,$fieldlist[$k])]
						EndIf
					Next
				Else
					Local $game[5]
					$game[0] = $HomeSchedule[$j][0]
					If $useicons Then
						$game[1] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][1])] & ")"
						$game[2] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][2])] & ")"
					Else
						$game[1] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][1])]
						$game[2] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][2])]
					EndIf

					$game[3] = $HomeSchedule[$j][3]
					$game[4] = $HomeSchedule[$j][4]
				EndIf

				$sched &= "|" & _ArrayToString($game,"|") & "|" & @CRLF
				$gamecount += 1
				If $gamecount = $limitcount Then ExitLoop
			Next

			If StringLen($homesched[$i + 1]) Then
				$file = StringReplace($file,"{schedule:home:" & $homesched[$i] & ":" & $homesched[$i + 1] & "}",$sched)
			Else
				$file = StringReplace($file,"{schedule:home:" & $homesched[$i] & "}",$sched)
			EndIf
		Next
	EndIf


	;Away Schedule
	If StringInStr($file,"{schedule:away}") Then
		Local $sched,$i,$j,$game[5],$todaygame
		$sched = "|" & _ArrayToString($ScheduleFields,"|") & "|" & @CRLF
		$sched &= _ArrayToString($TableHeader,0,4) & @CRLF

		Local $today = @MON & "/" & @MDAY & "/" & @YEAR
		For $j = 0 to UBound($HomeSchedule) - 1
			If $HomeSchedule[$j][0] = $today Then
				$todaygame = $j
				ExitLoop
			EndIf
		Next

		For $i = $todaygame + 1 to $todaygame + 5
			$game[0] = $sched[$i][0]
			$game[1] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNHL,$sched[$i][1])] & "](" & $TeamReddits[FindArrayEntry($TeamNHL,$sched[$i][1])] & ")"
			$game[2] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNHL,$sched[$i][2])] & "](" & $TeamReddits[FindArrayEntry($TeamNHL,$sched[$i][2])] & ")"
			$game[3] = $sched[$i][3]
			$game[4] = $sched[$i][4]

			$sched &= "|" & _ArrayToString($game,"|") & "|"
			If $i < 4 Then $sched &= @CRLF
		Next
		$file = StringReplace($file,"{schedule:away}",$sched)
	EndIf

	;Away Schedule with Fields and Options
	Local $awaysched = StringRegExp($file,"{schedule:away:(?<fields>[\w\-+/=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$j,$k,$sched,$todaygame,$startgame,$endgame,$limitcount,$gamecount,$useicons
		For $i = 0 to UBound($awaysched) - 1 Step 2
			Local $fieldlist = StringSplit($awaysched[$i],",",2)
			Local $optionlist = StringSplit($awaysched[$i + 1],",",2)

			If FindArrayEntry($ScheduleFields,$fieldlist[0]) <> -1 Then
				$sched = "|" & _ArrayToString($fieldlist,"|") & "|" & @CRLF
				$sched &= _ArrayToString($TableHeader,"|",0,UBound($fieldlist)-1) & @CRLF
			Else
				$optionlist = $fieldlist
				$fieldlist = $ScheduleFields
				$sched = "|" & _ArrayToString($ScheduleFields,"|") & "|" & @CRLF
				$sched &= _ArrayToString($TableHeader,"|",0,4) & @CRLF
			EndIf

			Local $today = Int(@MON) & "/" & @MDAY & "/" & @YEAR
			For $j = 0 to UBound($AwaySchedule) - 1
				If $AwaySchedule[$j][0] = $today Then
					$todaygame = $j
					ExitLoop
				EndIf
			Next

			If FindArrayEntry($optionlist,"past") <> -1 Then
				$startgame = 0
				$endgame = $todaygame - 1
				$sched = StringReplace($sched,$ScheduleFields[4],"Result")
			ElseIf FindArrayEntry($optionlist,"future") <> -1 Then
				$startgame = $todaygame + 1
				$endgame = UBound($AwaySchedule) - 1
				$sched = StringReplace($sched,$ScheduleFields[4],"Network")
			EndIf

			If FindArrayEntry($optionlist,"icons") <> -1 Then
				$useicons = True
			Else
				$useicons = False
			EndIf

			$limitcount = 5
			For $j = 0 to UBound($optionlist) - 1
				If StringLower(StringLeft($optionlist[$j],5)) = "limit" Then
					$limitcount = Int(StringRight($optionlist[$j],StringLen($optionlist[$j]) - 6))
				EndIf
			Next

			$gamecount = 0
			For $j = $startgame to $endgame
				$gamecount += 1
				If IsArray($fieldlist) Then
					Local $game[UBound($fieldlist)]
					For $k = 0 to UBound($fieldlist) - 1
						If StringLower($fieldlist[$k]) = "home" Then
							If $useicons Then
								$game[$k] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][2])] & ")"
							Else
								$game[$k] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][2])]
							EndIf
						ElseIf StringLower($fieldlist[$k]) = "away" Then
							If $useicons Then
								$game[$k] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][1])] & ")"
							Else
								$game[$k] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][1])]
							EndIf
						Else
							$game[$k] = $AwaySchedule[$j][FindArrayEntry($ScheduleFields,$fieldlist[$k])]
						EndIf
					Next
				Else
					Local $game[5]
					$game[0] = $AwaySchedule[$j][0]

					If $useicons Then
						$game[1] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][1])] & ")"
						$game[2] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][2])] & ")"
					Else
						$game[1] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][1])]
						$game[2] = $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$AwaySchedule[$j][2])]
					EndIf

					$game[3] = $AwaySchedule[$j][3]
					$game[4] = $AwaySchedule[$j][4]
				EndIf

				$sched &= "|" & _ArrayToString($game,"|") & "|" & @CRLF
				If $gamecount = $limitcount Then ExitLoop
			Next

			If StringLen($awaysched[$i + 1]) Then
				$file = StringReplace($file,"{schedule:away:" & $awaysched[$i] & ":" & $awaysched[$i + 1] & "}",$sched)
			Else
				$file = StringReplace($file,"{schedule:away:" & $awaysched[$i] & "}",$sched)
			EndIf
		Next
	EndIf




	;Matchups Schedule
	If StringInStr($file,"{schedule:versus}") Then
		Local $sched,$i,$j,$game[5],$todaygame
		$sched = "|" & _ArrayToString($ScheduleFields,"|") & "|" & @CRLF
		$sched &= _ArrayToString($TableHeader,0,4) & @CRLF

		Local $today = @MON & "/" & @MDAY & "/" & @YEAR
		For $j = 0 to UBound($HomeSchedule) - 1
			If $HomeSchedule[$j][0] = $today Then
				$todaygame = $j
				ExitLoop
			EndIf
		Next

		For $i = $todaygame + 1 to $todaygame + 5
			If ($HomeSchedule[$i][1] = $TeamNHL[$HomeIndex] And $HomeSchedule[$i][2] = $TeamNHL[$AwayIndex]) Or ($HomeSchedule[$i][2] = $TeamNHL[$HomeIndex] And $HomeSchedule[$i][1] = $TeamNHL[$AwayIndex]) Then
				$game[0] = $HomeSchedule[$i][0]
				$game[1] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNHL,$HomeSchedule[$i][1])] & "](" & $TeamReddits[FindArrayEntry($TeamNHL,$HomeSchedule[$i][1])] & ")"
				$game[2] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNHL,$HomeSchedule[$i][2])] & "](" & $TeamReddits[FindArrayEntry($TeamNHL,$HomeSchedule[$i][2])] & ")"
				$game[3] = $HomeSchedule[$i][3]
				$game[4] = $HomeSchedule[$i][4]

				$sched &= "|" & _ArrayToString($game,"|") & "|" & @CRLF
			EndIf
		Next
		$file = StringReplace($file,"{schedule:versus}",$sched)
	EndIf

	Local $homesched = StringRegExp($file,"{schedule:versus:(?<fields>[\w\-+/, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$j,$k,$sched,$game[5],$todaygame,$startgame,$endgame,$limitcount,$gamecount,$useicons
		For $i = 0 to UBound($homesched) - 1 Step 2
			Local $fieldlist = StringSplit($homesched[$i],",",2)
			Local $optionlist = StringSplit($homesched[$i + 1],",",2)

			If FindArrayEntry($ScheduleFields,$fieldlist[0]) <> -1 Then
				$sched = "|" & _ArrayToString($fieldlist,"|") & "|" & @CRLF
				$sched &= _ArrayToString($TableHeader,"|",0,UBound($fieldlist)-1) & @CRLF
			Else
				$optionlist = $fieldlist
				$fieldlist = $ScheduleFields
				$sched = "|" & _ArrayToString($ScheduleFields,"|") & "|" & @CRLF
				$sched &= _ArrayToString($TableHeader,"|",0,4) & @CRLF
			EndIf

			Local $today = @MON & "/" & @MDAY & "/" & @YEAR
			For $j = 0 to UBound($HomeSchedule) - 1
				If $HomeSchedule[$j][0] = $today Then
					$todaygame = $j
					ExitLoop
				EndIf
			Next

			If FindArrayEntry($optionlist,"past") <> -1 Then
				$startgame = 0
				$endgame = $todaygame - 1
				$sched = StringReplace($sched,$ScheduleFields[4],"Result")
			ElseIf FindArrayEntry($optionlist,"future") <> -1 Then
				$startgame = $todaygame + 1
				$endgame = UBound($HomeSchedule) - 1
				$sched = StringReplace($sched,$ScheduleFields[4],"Network")
			Else
				$startgame = 0
				$endgame = UBound($HomeSchedule) - 1
			EndIf

			If FindArrayEntry($optionlist,"icons") <> -1 Then
				$useicons = True
			Else
				$useicons = False
			EndIf

			$limitcount = -1
			For $j = 0 to UBound($optionlist) - 1
				If StringLower(StringLeft($optionlist[$j],5)) = "limit" Then
					$limitcount = Int(StringRight($optionlist[$j],StringLen($optionlist[$j]) - 6))
				EndIf
			Next

			$gamecount = 0
			For $j = $startgame to $endgame
				Dim $game[UBound($fieldlist)]

				If ($HomeSchedule[$j][1] = $TeamNamesFormatted[$HomeIndex] And $HomeSchedule[$j][2] = $TeamNamesFormatted[$AwayIndex]) Or ($HomeSchedule[$j][2] = $TeamNamesFormatted[$HomeIndex] And $HomeSchedule[$j][1] = $TeamNamesFormatted[$AwayIndex]) Then
					$gamecount += 1
					If IsArray($fieldlist) Then
						For $k = 0 to UBound($fieldlist) - 1
							If StringLower($fieldlist[$k]) = "home" Then
								If $useicons Then
									$game[$k] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][2])] & ")"
								Else
									$game[$k] = $HomeSchedule[$j][2]
								EndIf
							ElseIf StringLower($fieldlist[$k]) = "away" Then
								If $useicons Then
									$game[$k] = "[](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][1])] & ")"
								Else
									$game[$k] = $HomeSchedule[$j][1]
								EndIf
							Else
								$game[$k] = $HomeSchedule[$j][FindArrayEntry($ScheduleFields,$fieldlist[$k])]
							EndIf
						Next
					Else
						$game[0] = $HomeSchedule[$j][0]
						$game[1] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][1])] & "](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][1])] & ")"
						$game[2] = "[" & $TeamNamesFormatted[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][2])] & "](" & $TeamReddits[FindArrayEntry($TeamNamesFormatted,$HomeSchedule[$j][2])] & ")"
						$game[3] = $HomeSchedule[$j][3]
						$game[4] = $HomeSchedule[$j][4]
					EndIf
					$sched &= "|" & _ArrayToString($game,"|") & "|" & @CRLF
				EndIf
				If $gamecount = $limitcount Then ExitLoop
			Next

			If StringLen($homesched[$i + 1]) Then
				$file = StringReplace($file,"{schedule:versus:" & $homesched[$i] & ":" & $homesched[$i + 1] & "}",$sched)
			Else
				$file = StringReplace($file,"{schedule:versus:" & $homesched[$i] & "}",$sched)
			EndIf
		Next
	EndIf

	#endregion

	#region TAGS - Injury Tags
	;Home Injury Table
	If StringInStr($file,"{home:injuries}") Then
		Local $homeinjuries,$i,$j,$player[4]
		If $TeamInjuryCount[$HomeIndex] Then
			For $i = 0 to $TeamInjuryCount[$HomeIndex] - 1
				For $j = 0 to UBound($InjuryFields) - 1
					$player[$j] = $TeamInjuries[$HomeIndex][$i][$j]
				Next
				$homeinjuries &= "|[](" & $TeamReddits[$HomeIndex] & ")|" & _ArrayToString($player,"|") & "|"
				If $i < $TeamInjuryCount[$HomeIndex] - 1 Then $homeinjuries &= @CRLF
			Next
		Else
			$homeinjuries = "|[](" & $TeamReddits[$HomeIndex] & ")|No injuries||||"
		EndIf
		$file = StringReplace($file,"{home:injuries}",$homeinjuries)
	EndIf

	;Home Injury Table with Fields and Options
	Local $homeinjuries = StringRegExp($file,"{home:injuries:(?<fields>[\w\-+/=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline,$limitcount

		;_ArrayDisplay($homeinjuries)

		For $i = 0 to UBound($homeinjuries) - 1 Step 2
			$textblock = ""
			$textline = ""

			Local $statlist = StringSplit($homeinjuries[$i],",",2)
			Local $optionlist = StringSplit($homeinjuries[$i + 1],",",2)

			If FindArrayEntry($InjuryFields,$statlist[0]) = -1 And FindArrayEntry($SpecialFields,$statlist[0]) = -1 Then
				$optionlist = $statlist
				$statlist = $InjuryFields
			EndIf

			If FindArrayEntry($optionlist,"noheader") = -1 Then
				Local $tmpstatlist = $statlist
				Local $j
				For $j = 0 to UBound($tmpstatlist) - 1
					If FindArrayEntry($InjuryFields,$statlist[$j]) = -1 Then
						$tmpstatlist[$j] = ""
					EndIf
				Next

				$textblock &= "|" & _ArrayToString($tmpstatlist,"|") & "|" & @CRLF
				$textblock &= _ArrayToString($TableHeader,"|",0,UBound($statlist)-1) & @CRLF
			EndIf

			Local $j,$k

			$limitcount = $TeamInjuryCount[$HomeIndex]

			If $limitcount Then
				For $j = 0 to $limitcount - 1
					$textline = "|"
					For $k = 0 to UBound($statlist) - 1
						If FindArrayEntry($InjuryFields,$statlist[$k]) > -1 Then
							$textline &= $TeamInjuries[$HomeIndex][$j][FindArrayEntry($InjuryFields,$statlist[$k])] & "|"
						Else
							Select
								Case StringLower($statlist[$k]) = "nameabbr"
									$textline &= $TeamNamesAbbr[$HomeIndex] & "|"
								Case StringLower($statlist[$k]) = "redditname"
									$textline &= "[" & $TeamNamesFormatted[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
								Case StringLower($statlist[$k]) = "redditicon"
									$textline &= "[](" & $TeamReddits[$HomeIndex] & ")" & "|"
								Case StringLower($statlist[$k]) = "redditabbr"
									$textline &= "[" & $TeamNamesAbbr[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
							EndSelect
						EndIf
					Next

					$textblock &= $textline
					If $j < ($limitcount - 1) Then $textblock &= @CRLF
				Next
			Else
				$textline = "|"
				For $k = 0 to UBound($statlist) - 1
					If FindArrayEntry($InjuryFields,$statlist[$k]) > -1 Then
						;$textline &= $TeamInjuries[$AwayIndex][$j][FindArrayEntry($InjuryFields,$statlist[$k])] & "|"
						If $statlist[$k] = "Player" Then
							$textline &= "No injuries |"
						Else
							$textline &= "|"
						EndIf
					Else
						Select
							Case StringLower($statlist[$k]) = "nameabbr"
								$textline &= $TeamNamesAbbr[$HomeIndex] & "|"
							Case StringLower($statlist[$k]) = "redditname"
								$textline &= "[" & $TeamNamesFormatted[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditicon"
								$textline &= "[](" & $TeamReddits[$HomeIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditabbr"
								$textline &= "[" & $TeamNamesAbbr[$HomeIndex] & "](" & $TeamReddits[$HomeIndex] & ")" & "|"
						EndSelect
					EndIf
				Next

				$textblock &= $textline
			EndIf

			If StringLen($homeinjuries[$i + 1]) Then
				$file = StringReplace($file,"{home:injuries:" & $homeinjuries[$i] & ":" & $homeinjuries[$i + 1] & "}",$textblock)
			Else
				$file = StringReplace($file,"{home:injuries:" & $homeinjuries[$i] & "}",$textblock)
			EndIf
		Next
	EndIf

	;Away Injury Table
	If StringInStr($file,"{away:injuries}") Then
		Local $awayinjuries,$i,$j,$player[4]
		If $TeamInjuryCount[$AwayIndex] Then
			For $i = 0 to $TeamInjuryCount[$AwayIndex] - 1
				For $j = 0 to UBound($InjuryFields) - 1
					$player[$j] = $TeamInjuries[$AwayIndex][$i][$j]
				Next
				$awayinjuries &= "|[](" & $TeamReddits[$AwayIndex] & ")|" & _ArrayToString($player,"|") & "|"
				If $i < $TeamInjuryCount[$AwayIndex] - 1 Then $awayinjuries &= @CRLF
			Next
		Else
			$homeinjuries = "|[](" & $TeamReddits[$AwayIndex] & ")|No injuries||||"
		EndIf
		$file = StringReplace($file,"{away:injuries}",$awayinjuries)
	EndIf

	;Away Injury Table with Fields and Options
	Local $awayinjuries = StringRegExp($file,"{away:injuries:(?<fields>[\w\-+/=, ]*):?(?<options>[\w\-/=, ]*)}",3)
	If Not @error Then
		Local $i,$textblock,$textline,$limitcount

		;_ArrayDisplay($awayinjuries)

		For $i = 0 to UBound($awayinjuries) - 1 Step 2
			$textblock = ""
			$textline = ""

			Local $statlist = StringSplit($awayinjuries[$i],",",2)
			Local $optionlist = StringSplit($awayinjuries[$i + 1],",",2)

			If FindArrayEntry($InjuryFields,$statlist[0]) = -1 And FindArrayEntry($SpecialFields,$statlist[0]) = -1 Then
				$optionlist = $statlist
				$statlist = $InjuryFields
			EndIf

			If FindArrayEntry($optionlist,"noheader") = -1 Then
				Local $tmpstatlist = $statlist
				Local $j
				For $j = 0 to UBound($tmpstatlist) - 1
					If FindArrayEntry($InjuryFields,$statlist[$j]) = -1 Then
						$tmpstatlist[$j] = ""
					EndIf
				Next

				$textblock &= "|" & _ArrayToString($tmpstatlist,"|") & "|" & @CRLF
				$textblock &= _ArrayToString($TableHeader,"|",0,UBound($statlist)-1) & @CRLF
			EndIf

			Local $j,$k

			$limitcount = $TeamInjuryCount[$AwayIndex]

			If $limitcount Then
				For $j = 0 to $limitcount - 1
					$textline = "|"
					For $k = 0 to UBound($statlist) - 1
						If FindArrayEntry($InjuryFields,$statlist[$k]) > -1 Then
							$textline &= $TeamInjuries[$AwayIndex][$j][FindArrayEntry($InjuryFields,$statlist[$k])] & "|"
						Else
							Select
								Case StringLower($statlist[$k]) = "nameabbr"
									$textline &= $TeamNamesAbbr[$AwayIndex] & "|"
								Case StringLower($statlist[$k]) = "redditname"
									$textline &= "[" & $TeamNamesFormatted[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
								Case StringLower($statlist[$k]) = "redditicon"
									$textline &= "[](" & $TeamReddits[$AwayIndex] & ")" & "|"
								Case StringLower($statlist[$k]) = "redditabbr"
									$textline &= "[" & $TeamNamesAbbr[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
							EndSelect
						EndIf
					Next

					$textblock &= $textline
					If $j < ($limitcount - 1) Then $textblock &= @CRLF
				Next
			Else
				$textline = "|"
				For $k = 0 to UBound($statlist) - 1
					If FindArrayEntry($InjuryFields,$statlist[$k]) > -1 Then
						;$textline &= $TeamInjuries[$AwayIndex][$j][FindArrayEntry($InjuryFields,$statlist[$k])] & "|"
						If $statlist[$k] = "Player" Then
							$textline &= "No injuries |"
						Else
							$textline &= "|"
						EndIf
					Else
						Select
							Case StringLower($statlist[$k]) = "nameabbr"
								$textline &= $TeamNamesAbbr[$AwayIndex] & "|"
							Case StringLower($statlist[$k]) = "redditname"
								$textline &= "[" & $TeamNamesFormatted[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditicon"
								$textline &= "[](" & $TeamReddits[$AwayIndex] & ")" & "|"
							Case StringLower($statlist[$k]) = "redditabbr"
								$textline &= "[" & $TeamNamesAbbr[$AwayIndex] & "](" & $TeamReddits[$AwayIndex] & ")" & "|"
						EndSelect
					EndIf
				Next

				$textblock &= $textline
			EndIf

			If StringLen($awayinjuries[$i + 1]) Then
				$file = StringReplace($file,"{away:injuries:" & $awayinjuries[$i] & ":" & $awayinjuries[$i + 1] & "}",$textblock)
			Else
				$file = StringReplace($file,"{away:injuries:" & $awayinjuries[$i] & "}",$textblock)
			EndIf
		Next
	EndIf

	#endregion

	Local $ThreadFileName = $TeamNamesFormatted[$AwayIndex] & " at " & $TeamNamesFormatted[$HomeIndex] & " " & @MON & "-" & @MDAY & "-" & @YEAR & ".txt"
	If FileExists(@ScriptDir & "\Generated\" & $ThreadFileName) Then
		FileDelete(@ScriptDir & "\Generated\" & $ThreadFileName)
	EndIf

	Local $GeneratedFile = FileOpen(@ScriptDir & "\Generated\" & $ThreadFileName,10)
	FileWrite($GeneratedFile,$file)
	FileClose($GeneratedFile)
	MsgBox(0,"Thread File","File Written:" & @CRLF & $ThreadFileName)
EndFunc

Func RefreshFileList()						; Refresh list of text files in directory
	; Shows the filenames of all files in the current directory.
	Local $search = FileFindFirstFile("*.txt")
	Local $filelist
	Local $firstfile

	; Check if the search was successful
	If $search = -1 Then
		Return
	EndIf

	While 1
		Local $file = FileFindNextFile($search)
		If @error Then
			ExitLoop
		ElseIf $file <> "changelog.txt" Then
			If StringLen($filelist) Then
				$filelist &= "|"
			Else
				$firstfile = $file
			EndIf
			$filelist &= $file
		EndIf
	WEnd

	; Close the search handle
	FileClose($search)

	GUICtrlSetData($cmbTemplate,"")
	GUICtrlSetData($cmbTemplate,$filelist,$firstfile)

EndFunc

Func CopyDailyTable()
	Local $table,$i
	$table = "|HOME|AWAY|TIME|POSTER|" & @CRLF & _ArraytoString($TableHeader,"|",0,3) & @CRLF
	For $i = 0 to UBound($TodaySchedule) - 1
		Local $timearray = StringRegExp($TodaySchedule[$i][4],"([\d]*):([\d]*) (AM|PM) ET",3)
		local $awayteam = FindArrayEntry($TeamCities,$TodaySchedule[$i][0])
		local $hometeam = FindArrayEntry($TeamCities,$TodaySchedule[$i][1])
		Local $GameTZ = $TeamTimeZone[$hometeam]
		Local $GameHour = $timearray[0]
		Local $GameMin = $timearray[1]
		Local $GameTime
		Select
			Case $GameTZ = "PT"
				$GameTime = $GameHour - 3 & ":" & $GameMin & " " & $timearray[2] & " PT"
			Case $GameTZ = "MT"
				$GameTime = $GameHour - 2 & ":" & $GameMin & " " & $timearray[2] & " MT"
			Case $GameTZ = "CT"
				$GameTime = $GameHour - 1 & ":" & $GameMin & " " & $timearray[2] & " CT"
			Case $GameTZ = "ET"
				$GameTime = $GameHour & ":" & $GameMin & " " & $timearray[2] & " ET"
		EndSelect
		$table &= "|" & $TeamNamesAbbr[$hometeam] & "|" & $TeamNamesAbbr[$awayteam] & "|" & $GameTime & "|  |" & @CRLF
	Next

	ClipPut($table)
	MsgBox(64,"Daily Table","Daily table has been copied to the clipboard.")
EndFunc

#region Standard Functions
Func FileGetTimeForDiff($file)
	Return StringRegExpReplace(FileGetTime($file,0,1),'([\d]{4})([\d]{2})([\d]{2})([\d]{2})([\d]{2})([\d]{2})','$1/$2/$3 $4:$5:$6')
EndFunc

Func FlipName($name)
	Local $First = StringRemove($name, " ")
	Local $Flipped = $name & ", " & $First
	Return $Flipped
EndFunc   ;==>FlipName

Func StringRemove(ByRef $string, $delim, $keepdelim = False)
	Local $i = StringInStr($string, $delim)
	Local $strtemp = $string
	If $i >= 1 Then
		If $keepdelim Then
			$string = StringRight($string, StringLen($string) - ($i - 1))
		Else
			$string = StringRight($string, StringLen($string) - ($i + StringLen($delim) - 1))
		EndIf

		Return StringLeft($strtemp, $i - 1)
	EndIf
	Return $string
EndFunc   ;==>StringRemove

Func FindArrayEntry($array, $string, $case = False)
	Local $i

	For $i = 0 To UBound($array) - 1
		If $case Then
			If $array[$i] = $string Then
				Return $i
			EndIf
		Else
			If StringLower($array[$i]) = StringLower($string) Then
				Return $i
			EndIf
		EndIf
	Next

	Return -1
EndFunc   ;==>FindArrayEntry

Func Debug($string)
	MsgBox(0,"Debug",$string)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _InetGet
; Description ...: Downloads a file from the internet using the HTTP, HTTPS or FTP protocol. This is done so in a new process spawned by the current process.
; Syntax ........: _InetGet($sURL, $sFilePath[, $iOptions = Default[, $sUserAgent = Default]])
; Parameters ....: $sURL                - See InetGet for details.
;                  $sFilePath           - See InetGet for details.
;                  $iOptions            - [optional] See InetGet for details.
;                  $sUserAgent          - [optional] Useragent string for the web server to identify the application. Default is AutoIt.
; Return values .: Success - True
;                   Failure - False
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _InetGet($sURL, $sFilePath, $iOptions = Default, $sUserAgent = Default)
    $iOptions = Int($iOptions)
    If $sUserAgent = Default Then ; Use the default useragent of AutoIt, which is AutoIt.
        $sUserAgent = ''
    EndIf
    Return RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteLine ' & '"Exit HttpSetUserAgent(""' & $sUserAgent & '"")*Int(InetGet(""' & $sURL & '"",""' & $sFilePath & '"",' & $iOptions & ',0)>0)"') == 1
EndFunc   ;==>_InetGet

#endregion