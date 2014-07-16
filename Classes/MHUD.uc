//=============================================================================
// MHUD.
//
// SWWM Gold had a "HUD Addon", it was ugly and hacky.
// SWWM Z now has its own full standalone HUD that replaces the aged vanilla UT
// "ChallengeHUD". It has been designed specifically for minimal screen clutter
// and it's mostly transparent.
//=============================================================================
class MHUD extends HUD;

#exec TEXTURE IMPORT FILE=Textures\mh_dot.pcx NAME=mh_dot
#exec TEXTURE IMPORT FILE=Textures\mh_star.pcx NAME=mh_star
#exec TEXTURE IMPORT FILE=Textures\mh_flag.pcx NAME=mh_flag
#exec TEXTURE IMPORT FILE=Textures\mh_flagtk.pcx NAME=mh_flagtk
#exec TEXTURE IMPORT FILE=Textures\mh_flagdp.pcx NAME=mh_flagdp
#exec TEXTURE IMPORT FILE=Textures\mh_neutral.pcx NAME=mh_neutral
#exec TEXTURE IMPORT FILE=Textures\mh_red.pcx NAME=mh_red
#exec TEXTURE IMPORT FILE=Textures\mh_blue.pcx NAME=mh_blue
#exec TEXTURE IMPORT FILE=Textures\mh_green.pcx NAME=mh_green
#exec TEXTURE IMPORT FILE=Textures\mh_gold.pcx NAME=mh_gold

// Screen size tiers
enum EScreenSize
{
	SSZ_Tiny,	// Itty bitty kitty titties   <=  320 x  200
	SSZ_Small,	// Small bombs                <=  640 x  400
	SSZ_Smallish,	// Not really very small...   <=  960 x  600
	SSZ_Normal,	// Don't say normal!          <= 1280 x  800
	SSZ_Big,	// Full HD (where available)  <= 1920 x 1200
	SSZ_MegaMilk,	// SHUT UP YOU TITTY MONSTER! <= 2560 x 1600
	SSZ_Xbox,	// The joke tells itself      >  2560 x 1600
};
var EScreenSize ScreenSize;
var float ElementScale, ArialScale, TahomaScale;
var bool UseSmallFont;

// HUD type, better than having a shitload of separate classes
enum EHUDType
{
	HUD_Deathmatch,
	HUD_TeamDeathmatch,
	HUD_Domination,
	HUD_CaptureTheFlag,
	HUD_Assault,
	HUD_LastManStanding,
};
var EHUDType HUDType;

// Our current owner
var Pawn PO;

// Message queue
var HUDLocalizedMessage LocalMessages[10];
struct SmallMessage
{
	var Name Type;
	var PlayerReplicationInfo PRI;
	var float LifeTime;
	var string Message;
};
// events (traditionally "chat area" messages)
var SmallMessage EventMessages[4];
// current pickup message (item messages)
var SmallMessage CurrentPickup;
// current critical event (gameplay messages)
var SmallMessage CriticalMessage;

// Server info
var bool ShowInfo;
var ServerInfo ServerInfo;

// Timers
var float MOTDTime;

// Stats
var PlayerReplicationInfo Ranks[32];
var byte RanksTeam[4];

// Teamstuff
var() Color TeamColor[4];
var() Texture TeamIcon[4];

// String table
var() localized string GameString;
var() localized string TitleString;
var() localized string AuthorString;
var() localized string LoadString;
var() localized string ASFallbackName;
var() localized string FlagName[4];

// Projection utils (thank you Wormbo)
function bool MapToHUD( out Vector Res, Rotator ViewRotation, float FOV,
	Vector TargetDir, Canvas Canvas )
{
	local float TanFOVx,TanFOVy, TanX,TanY, dx,dy;
	local Vector X,Y, Dir, XY;
	TanFOVx = Tan(FOV*Pi/360);
	TanFOVY = (Canvas.ClipY/Canvas.ClipX)*TanFOVx;
	GetAxes(ViewRotation,Dir,X,Y);
	Dir *= TargetDir dot Dir;
	XY = TargetDir-Dir;
	dx = XY dot X;
	dy = XY dot Y;
	TanX = dx/VSize(dir);
	TanY = dy/VSize(dir);
	Res.X = Canvas.ClipX*0.5*(1+TanX/TanFOVx);
	Res.Y = Canvas.ClipY*0.5*(1-TanY/TanFOVy);
	return ((Dir dot Vector(ViewRotation) > 0) && (Res.X == FClamp(Res.X,
		Canvas.OrgX,Canvas.ClipX)) && (Res.Y == FClamp(Res.Y,
		Canvas.OrgY,Canvas.ClipY)));
}

function bool WorldToScreen( Canvas Canvas, Vector Spot, out Vector ScreenLoc )
{
	local Vector CamLoc;
	local Rotator CamRot;
	local Actor Camera;
	Canvas.Viewport.Actor.PlayerCalcView(Camera,CamLoc,CamRot);
	return MapToHUD(ScreenLoc,CamRot,Canvas.Viewport.Actor.FOVAngle,
		Normal(Spot-CamLoc),Canvas);
}

function Actor ScreenToWorld( Canvas Canvas, float PosX, float PosY )
{
	local Actor Other;
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, Direction;
	Direction.X = 1/Tan(PO.FOVAngle/2/180*Pi);
	Direction.Y = (PosX-Canvas.ClipX/2)/(Canvas.ClipX/2);
	Direction.Z = (PosY-Canvas.ClipY/2)/(Canvas.ClipY/2);
	Direction = Normal(Direction);
	StartTrace = PO.Location+PO.EyeHeight*vect(0,0,1);
	EndTrace = StartTrace+(Direction>>PO.ViewRotation)*10000.0;
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	return Other;
}

// UTLadder is actually Arial
function Font Arial( int Size )
{
	Size *= ArialScale;
	if ( (Size < 10) && UseSmallFont )
		return Font'Engine.SmallFont';
	if ( Size < 12 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder10",
			Class'Font'));
	else if ( Size < 14 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder12",
			Class'Font'));
	else if ( Size < 16 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder14",
			Class'Font'));
	else if ( Size < 18 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder16",
			Class'Font'));
	else if ( Size < 20 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder18",
			Class'Font'));
	else if ( Size < 22 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder20",
			Class'Font'));
	else if ( Size < 24 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder22",
			Class'Font'));
	else if ( Size < 30 )
		return Font(DynamicLoadObject("LadderFonts.UTLadder24",
			Class'Font'));
	return Font(DynamicLoadObject("LadderFonts.UTLadder30",Class'Font'));
}

// Good ol' Tahoma, that classic Windows UI font
function Font Tahoma( int Size, optional bool Bold )
{
	Size *= TahomaScale;
	if ( (Size < 10) && UseSmallFont )
		return Font'Engine.SmallFont';
	if ( Bold )
	{
		if ( Size < 20 )
			return Font(DynamicLoadObject("UWindowFonts.TahomaB10",
				Class'Font'));
		else if ( Size < 30 )
			return Font(DynamicLoadObject("UWindowFonts.TahomaB20",
				Class'Font'));
		return Font(DynamicLoadObject("UWindowFonts.TahomaB30",
			Class'Font'));
	}
	else
	{
		if ( Size < 20 )
			return Font(DynamicLoadObject("UWindowFonts.Tahoma10",
				Class'Font'));
		else if ( Size < 30 )
			return Font(DynamicLoadObject("UWindowFonts.Tahoma20",
				Class'Font'));
		return Font(DynamicLoadObject("UWindowFonts.Tahoma30",
			Class'Font'));
	}
}

// Maintenance
event Timer()
{
	local int i, j;
	// Clean up event messages
	for ( i=0; i<4; i++ )
	{
		if ( (EventMessages[i].Message == "") || (Level.TimeSeconds <
			EventMessages[i].LifeTime) )
			continue;
		ClearSmallMessage(EventMessages[i]);
	}
	// Compress queue
	for ( i=0; i<3; i++ )
	{
		if ( EventMessages[i].Message != "" )
			continue;
		for ( j=i; j<4; j++ )
		{
			if ( EventMessages[j].Message == "" )
				continue;
			CopySmallMessage(EventMessages[i],EventMessages[j]);
			ClearSmallMessage(EventMessages[j]);
			break;
		}
	}
	// Clean up localized messages
	for ( i=0; i<10; i++ )
	{
		if ( (LocalMessages[i].Message == None) || (Level.TimeSeconds <
			LocalMessages[i].EndOfLife) )
			continue;
		ClearMessage(LocalMessages[i]);
	}
	// Compress queue
	for ( i=0; i<9; i++ )
	{
		if ( LocalMessages[i].Message != None )
			continue;
		CopyMessage(LocalMessages[i],LocalMessages[i+1]);
		ClearMessage(LocalMessages[i+1]);
	}
}

event PostBeginPlay()
{
	MOTDTime = Level.TimeSeconds+6;
	SetTimer(1.0,true);
	Super.PostBeginPlay();
}

function SpawnServerInfo()
{
	if ( HUDType == HUD_TeamDeathmatch )
		Spawn(Class'Botpack.ServerInfoTeam',Owner);
	else if ( HUDType == HUD_Assault )
		Spawn(Class'Botpack.ServerInfoAS',Owner);
	else if ( HUDType == HUD_CaptureTheFlag )
		Spawn(Class'Botpack.ServerInfoCTF',Owner);
	else if ( HUDType == HUD_Domination )
		Spawn(Class'Botpack.ServerInfoDOM',Owner);
	else
		Spawn(Class'Botpack.ServerInfo',Owner);
}

exec function ShowServerInfo()
{
	ShowInfo = !ShowInfo;
	if ( !ShowInfo )
		PlayerPawn(Owner).bShowScores = False;
}

function SetupHUD( Canvas Canvas )
{
	PlayerOwner = PlayerPawn(Owner);
	if ( (PlayerOwner.ViewTarget != None)
		&& PlayerOwner.ViewTarget.IsA('Pawn') )
		PO = Pawn(PlayerOwner.ViewTarget);
	else
		PO = PlayerOwner;
	Canvas.Reset();
	Canvas.SpaceX = 0;
	Canvas.bNoSmooth = True;
	// Scaling
	if ( (Canvas.ClipX <= 320) || (Canvas.ClipY <= 200) )
	{
		ScreenSize = SSZ_Tiny;
		UseSmallFont = True;
		ElementScale = 0.5;
		ArialScale = 0.25;
		TahomaScale = 0.25;
	}
	else if ( (Canvas.ClipX <= 640) || (Canvas.ClipY <= 400) )
	{
		ScreenSize = SSZ_Small;
		UseSmallFont = True;
		ElementScale = 0.5;
		ArialScale = 0.5;
		TahomaScale = 0.5;
	}
	else if ( (Canvas.ClipX <= 960) || (Canvas.ClipY <= 600) )
	{
		ScreenSize = SSZ_Smallish;
		UseSmallFont = False;
		ElementScale = 0.75;
		ArialScale = 0.75;
		TahomaScale = 1.0;
	}
	else if ( (Canvas.ClipX <= 1280) || (Canvas.ClipY <= 800) )
	{
		ScreenSize = SSZ_Normal;
		UseSmallFont = False;
		ElementScale = 1.0;
		ArialScale = 1.0;
		TahomaScale = 1.0;
	}
	else if ( (Canvas.ClipX <= 1920) || (Canvas.ClipY <= 1200) )
	{
		ScreenSize = SSZ_Big;
		UseSmallFont = False;
		ElementScale = 1.25;
		ArialScale = 1.25;
		TahomaScale = 2.0;
	}
	else if ( (Canvas.ClipX <= 2560) || (Canvas.ClipY <= 1600) )
	{
		ScreenSize = SSZ_MegaMilk;
		UseSmallFont = False;
		ElementScale = 1.5;
		ArialScale = 1.5;
		TahomaScale = 2.0;
	}
	else
	{
		ScreenSize = SSZ_Xbox;
		UseSmallFont = False;
		ElementScale = 2.0;
		ArialScale = 2.0;
		TahomaScale = 3.0;
	}
	Canvas.Font = Tahoma(10);
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = WhiteColor;
}

// Message header
function bool MsgHeader( Canvas Canvas, int i, float Pos )
{
	local float XL, YL;
	local String PN, Str;
	if ( (EventMessages[i].Type != 'Say')
		&& (EventMessages[i].Type != 'TeamSay') )
		return false;
	if ( EventMessages[i].PRI != None )
		PN = EventMessages[i].PRI.PlayerName;
	else
		PN = "???";
	if ( Level.Game.bTeamGame && (EventMessages[i].PRI != None) )
		Canvas.DrawColor = TeamColor[EventMessages[i].PRI.Team]*0.3;
	else
		Canvas.DrawColor = WhiteColor*0.3;
	Canvas.SetPos(4,Pos);
	Str = PN;
	if ( EventMessages[i].PRI.PlayerLocation != None )
		Str = Str@"("$EventMessages[i].PRI.PlayerLocation
			.LocationName$")";
	else if ( (EventMessages[i].PRI.PlayerZone != None)
		&& (EventMessages[i].PRI.PlayerZone.ZoneName != "") )
		Str = Str@"("$EventMessages[i].PRI.PlayerZone.ZoneName$")";
	Str = Str$": ";
	Canvas.StrLen(Str,XL,YL);
	Canvas.DrawText(Str);
	Canvas.SetPos(4+XL,Pos);
	Canvas.DrawColor = WhiteColor*0.5;
	Canvas.DrawColor.R *= 0.75;
	Canvas.DrawColor.B *= 0.75;
	return true;
}

// Handle events, pickups and criticals
function DrawSmallMessages( Canvas Canvas )
{
	local int i;
	local float XL, YL, Col, Pos;
	if ( CurrentPickup.LifeTime > Level.TimeSeconds )
	{
		Canvas.bCenter = True;
		Canvas.Font = Arial(18);
		Col = 60.0*(CurrentPickup.LifeTime-Level.TimeSeconds);
		Canvas.DrawColor.R = Col*0.25;
		Canvas.DrawColor.G = Col*0.5;
		Canvas.DrawColor.B = Col;
		Canvas.SetPos(0,Canvas.ClipY*0.85);
		Canvas.DrawText(CurrentPickup.Message,True);
		Canvas.bCenter = False;
	}
	if ( CriticalMessage.LifeTime > Level.TimeSeconds )
	{
		Canvas.bCenter = True;
		Canvas.Font = Arial(20);
		Col = 60.0*(CriticalMessage.LifeTime-Level.TimeSeconds);
		Canvas.DrawColor.R = Col;
		Canvas.DrawColor.G = Col*0.25;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(0,Canvas.ClipY*0.65);
		Canvas.DrawText(CriticalMessage.Message,True);
		Canvas.bCenter = False;
	}
	Canvas.Font = Tahoma(10);
	Canvas.StrLen("M",XL,YL);
	Canvas.SetPos(0,0);
	Canvas.DrawColor = WhiteColor;
	Pos = 4;
	for ( i=3; i>=0; i-- )
	{
		if ( (EventMessages[i].Message == "")
			|| (EventMessages[i].LifeTime < Level.TimeSeconds) )
			continue;
		if ( !MsgHeader(Canvas,i,Pos) )
		{
			if ( EventMessages[i].Type == 'DeathMessage' )
			{
				Canvas.DrawColor = WhiteColor*0.6;
				Canvas.DrawColor.G *= 0.5;
				Canvas.DrawColor.B *= 0.5;
			}
			else
				Canvas.DrawColor = WhiteColor*0.8;
			Canvas.SetPos(4,Pos);
		}
		Canvas.DrawText(EventMessages[i].Message);
		Pos += YL;
	}
	Canvas.bNoSmooth = True;
}

// Console prompt
function DrawPrompt( Canvas Canvas, Console Console )
{
	local float XL, YL;
	local int mlen;
	local String Username, CWD;
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos(0,Canvas.ClipY-32);
	Canvas.bNoSmooth = False;
	Canvas.DrawTile(Texture'Gradient270',Canvas.ClipX,32,0,128,1,128);
	Canvas.bNoSmooth = True;
	Username = PlayerOwner.PlayerReplicationInfo.PlayerName;
	CWD = "/"$Left(Level.GetLocalURL(),InStr(Level.GetLocalURL(),".unr"));
	mlen = 0;
	Canvas.Font = Font'Engine.SmallFont';
	Canvas.StrLen("M",XL,YL);
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor.R = 16;
	Canvas.DrawColor.G = 96;
	Canvas.DrawColor.B = 16;
	Canvas.SetPos(2+XL*mlen,Canvas.ClipY-(YL+2));
	Canvas.DrawText(Username);
	mlen += Len(Username)+1;
	Canvas.DrawColor.R = 32;
	Canvas.DrawColor.G = 192;
	Canvas.DrawColor.B = 32;
	Canvas.SetPos(2+XL*mlen,Canvas.ClipY-(YL+2));
	Canvas.DrawText(CWD);
	mlen += Len(CWD)+1;
	Canvas.DrawColor.R = 64;
	Canvas.DrawColor.G = 128;
	Canvas.DrawColor.B = 64;
	Canvas.SetPos(2+XL*mlen,Canvas.ClipY-(YL+2));
	Canvas.DrawText("%");
	mlen += 2;
	Canvas.DrawColor.R = 128;
	Canvas.DrawColor.G = 192;
	Canvas.DrawColor.B = 128;
	Canvas.SetPos(2+XL*mlen,Canvas.ClipY-(YL+2));
	Canvas.DrawText(Console.TypedStr$"_");
}

// Localized messages
function DrawLocalizedMessages( Canvas Canvas )
{
	local int i, fs;
	local float XL, YL, YPos;
	local float FadeFactor;
	for ( i=0; i<10; i++ )
	{
		if ( LocalMessages[i].Message == None )
			continue;
		fs = Clamp(LocalMessages[i].Message.Static
			.GetFontSize(LocalMessages[i].Switch),1,2);
		Canvas.Font = Arial(16*fs);
		Canvas.DrawColor = LocalMessages[i].DrawColor;
		if ( LocalMessages[i].Message.Default.bFadeMessage )
		{
			Canvas.Style = ERenderStyle.STY_Translucent;
			FadeFactor = FMax(LocalMessages[i].EndOfLife
				-Level.TimeSeconds,0.0);
			Canvas.DrawColor = LocalMessages[i].DrawColor
				*(FadeFactor/LocalMessages[i].LifeTime);
		}
		else
			Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.StrLen(LocalMessages[i].StringMessage,XL,YL);
		YPos = LocalMessages[i].Message.Static
			.GetOffset(LocalMessages[i].Switch,YL,Canvas.ClipY);
		Canvas.SetPos(0.5*(Canvas.ClipX-XL),YPos);
		Canvas.DrawText(LocalMessages[i].StringMessage);
	}
	Canvas.Style = ERenderStyle.STY_Translucent;
}

// Progress (Game progress messages, such as "the match has begun")
function DrawProgress( Canvas Canvas )
{
	local int i;
	local float XL, YL, Pos;
	PlayerOwner.ProgressTimeOut = FMin(PlayerOwner.ProgressTimeOut,
		Level.TimeSeconds+8);
	Canvas.Font = Arial(20);
	Canvas.StrLen("M",XL,YL);
	Pos = -4*YL;
	Canvas.bCenter = True;
	for ( i=0; i<8; i++ )
	{
		Canvas.SetPos(0,Canvas.ClipY*0.5+Pos);
		Canvas.DrawColor = PlayerOwner.ProgressColor[i];
		Canvas.DrawText(PlayerOwner.ProgressMessage[i]);
		Pos += YL;
	}
	Canvas.bCenter = False;
}

// MOTD and Map Info
function DrawMOTD( Canvas Canvas )
{
	local GameReplicationInfo GRI;
	local float XL, YL, Pos;
	GRI = PlayerOwner.GameReplicationInfo;
	if ( GRI == None )
		return;
	Canvas.bCenter = True;
	Canvas.Font = Tahoma(10);
	Canvas.StrLen("M",XL,YL);
	Canvas.DrawColor = WhiteColor*((MOTDTime-Level.TimeSeconds)/10.0);
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText(GameString$":"@GRI.GameName,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText(TitleString$":"@Level.Title,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText(AuthorString$":"@Level.Author,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	if ( Level.IdealPlayerCount != "" )
		Canvas.DrawText(LoadString$":"@Level.IdealPlayerCount,True);
	Pos += 2*YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G /= 2;
	Canvas.DrawText(Level.LevelEnterText,True);
	Pos += 2*YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText(GRI.MOTDLine1,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText(GRI.MOTDLine2,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText(GRI.MOTDLine3,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText(GRI.MOTDLine4,True);
	Pos += YL;
	Canvas.bCenter = False;
}

// Player Health, Armor, Powerups... (and Score)
function DrawPlayerStatus( Canvas Canvas )
{
	// TODO
}

// Inventory (Weapon listings, current weapon)
function DrawInventory( Canvas Canvas )
{
	// TODO
}

// Deathmatch synopsis
function DrawDMSynopsis( Canvas Canvas )
{
	local int i, j, m, n;
	local float XL, YL, Pos;
	local Pawn P;
	local PlayerReplicationInfo temp;
	// Populate list
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( P.PlayerReplicationInfo == None )
			continue;
		Ranks[i] = P.PlayerReplicationInfo;
		i++;
	}
	n = i;
	// Sort list
	for ( i=0; i<n-1; i++ )
	{
		m = i;
		for ( j=i+1; j<n; j++ )
			if ( (Ranks[j].Score > Ranks[m].Score)
				|| ((Ranks[j].Score == Ranks[m].Score)
				&& (Ranks[j].Deaths < Ranks[m].Deaths))
				|| ((Ranks[j].Score == Ranks[m].Score)
				&& (Ranks[j].Deaths == Ranks[m].Deaths)
				&& (Ranks[j].PlayerID < Ranks[m].PlayerID)) )
				m = j;
		temp = Ranks[m];
		Ranks[m] = Ranks[i];
		Ranks[i] = temp;
	}
	Canvas.Font = Arial(16);
	Canvas.StrLen("M",XL,YL);
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.bNoSmooth = False;
	Canvas.SetPos(0,0.5*Canvas.ClipY-YL*1.5);
	Canvas.DrawTile(Texture'Gradient0',Canvas.ClipX*0.25,YL*5,0,0,128,1);
	Canvas.bNoSmooth = True;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Pos = -YL*1.5;
	for ( i=0; i<3; i++ )
	{
		// End of the line
		if ( Ranks[i] == None )
			return;
		Pos += YL;
		Canvas.DrawColor.R = 192-48*i;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(XL,0.5*Canvas.ClipY+Pos);
		Canvas.DrawText(Ranks[i].PlayerName@"("$int(Ranks[i].Score)
			$")");
	}
}

// TDM synopsis
function DrawTDMSynopsis( Canvas Canvas )
{
	local TournamentGameReplicationInfo GRI;
	local int i, nteams;
	local float XL, YL, Pos, Step;
	GRI = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo);
	if ( GRI == None )
		return;
	for ( i=0; i<4; i++ )
		if ( (GRI.Teams[i] != None) && (GRI.Teams[i].Size > 0) )
			nteams++;
	Step = 72*ElementScale;
	Pos = -Step*0.5*nteams+0.5*Step;
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.bNoSmooth = False;
	Canvas.SetPos(0,0.5*Canvas.ClipY-16-Step*0.5*nteams);
	Canvas.DrawTile(Texture'Gradient0',Canvas.ClipX*0.25,Step*nteams+32,0,
		0,128,1);
	Canvas.bNoSmooth = True;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.Font = Arial(24);
	Canvas.StrLen("M",XL,YL);
	for ( i=0; i<4; i++ )
	{
		if ( (GRI.Teams[i] == None) || (GRI.Teams[i].Size <= 0) )
			continue;
		Canvas.DrawColor = TeamColor[GRI.Teams[i].TeamIndex];
		Canvas.SetPos(4,0.5*Canvas.ClipY+Pos-0.5*Step);
		Canvas.bNoSmooth = False;
		Canvas.DrawIcon(TeamIcon[GRI.Teams[i].TeamIndex],ElementScale);
		Canvas.bNoSmooth = True;
		Canvas.SetPos(4+Step,0.5*Canvas.ClipY+Pos-0.5*YL);
		Canvas.DrawText(int(GRI.Teams[i].Score),False);
		Pos += Step;
	}
}

// Capture the Flag synopsis
function DrawCTFSynopsis( Canvas Canvas )
{
	local CTFReplicationInfo GRI;
	local int i, nteams, j;
	local float XL, YL, Pos, Step;
	local Texture CTex;
	GRI = CTFReplicationInfo(Level.Game.GameReplicationInfo);
	if ( GRI == None )
		return;
	for ( i=0; i<4; i++ )
		if ( GRI.FlagList[i] != None )
			nteams++;
	Step = 72*ElementScale;
	Pos = -Step*0.5*nteams+0.5*Step;
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.bNoSmooth = False;
	Canvas.SetPos(0,0.5*Canvas.ClipY-16-Step*0.5*nteams);
	Canvas.DrawTile(Texture'Gradient0',Canvas.ClipX*0.25,Step*nteams+32,0,
		0,128,1);
	Canvas.bNoSmooth = True;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.Font = Arial(24);
	Canvas.StrLen("M",XL,YL);
	for ( i=0; i<4; i++ )
	{
		if ( GRI.FlagList[i] == None )
			continue;
		Canvas.DrawColor = TeamColor[GRI.FlagList[i].Team];
		Canvas.SetPos(4,0.5*Canvas.ClipY+Pos-0.5*Step);
		Canvas.bNoSmooth = False;
		if ( GRI.FlagList[i].bHome )
			CTex = Texture'mh_flag';
		else if ( GRI.FlagList[i].bHeld )
			CTex = Texture'mh_flagtk';
		else
			CTex = Texture'mh_flagdp';
		Canvas.DrawIcon(CTex,ElementScale);
		Canvas.bNoSmooth = True;
		Canvas.SetPos(4+Step,0.5*Canvas.ClipY+Pos-0.5*YL);
		for ( j=0; j<4; j++ )
		{
			if ( GRI.Teams[j].TeamIndex != GRI.FlagList[i].Team )
				continue;
			Canvas.DrawText(int(GRI.Teams[j].Score),False);
			break;
		}
		Pos += Step;
	}
}

// Domination synopsis
function DrawDOMSynopsis( Canvas Canvas )
{
	local TournamentGameReplicationInfo GRI;
	local int i, nteams, j;
	local float XL, YL, Pos, Step;
	local NavigationPoint N;
	local ControlPoint C;
	GRI = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo);
	if ( GRI == None )
		return;
	for ( i=0; i<4; i++ )
		if ( (GRI.Teams[i] != None) && (GRI.Teams[i].Size > 0) )
			nteams++;
	Step = 80*ElementScale;
	Pos = -Step*0.5*nteams+0.5*Step;
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.bNoSmooth = False;
	Canvas.SetPos(0,0.5*Canvas.ClipY-16-Step*0.5*nteams);
	Canvas.DrawTile(Texture'Gradient0',Canvas.ClipX*0.25,Step*nteams+32,0,
		0,128,1);
	Canvas.bNoSmooth = True;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.Font = Arial(24);
	Canvas.StrLen("M",XL,YL);
	for ( i=0; i<4; i++ )
	{
		if ( (GRI.Teams[i] == None) || (GRI.Teams[i].Size <= 0) )
			continue;
		Canvas.DrawColor = TeamColor[GRI.Teams[i].TeamIndex];
		Canvas.SetPos(4,0.5*Canvas.ClipY+Pos-0.5*Step);
		Canvas.bNoSmooth = False;
		Canvas.DrawIcon(TeamIcon[GRI.Teams[i].TeamIndex],ElementScale);
		Canvas.bNoSmooth = True;
		Canvas.SetPos(4+Step,0.5*Canvas.ClipY+Pos-0.5*YL);
		Canvas.DrawText(int(GRI.Teams[i].Score),False);
		j = 1;
		Canvas.bNoSmooth = False;
		for ( N=Level.NavigationPointList; N!=None;
			N=N.NextNavigationPoint )
		{
			C = ControlPoint(N);
			if ( C == None )
				continue;
			if ( C.ControllingTeam != GRI.Teams[i] )
				continue;
			Canvas.SetPos(4+(j*8+4)*ElementScale,0.5*Canvas.ClipY
				+Pos+0.5*Step-12*ElementScale);
			Canvas.DrawIcon(Texture'mh_dot',ElementScale/8.0);
			j++;
		}
		Canvas.bNoSmooth = True;
		Pos += Step;
	}
}

// Assault synopsis (lol ASS)
function DrawASSynopsis( Canvas Canvas )
{
	// Nothing here (for now, maybe)
}

// LMS synopsis
function DrawLMSSynopsis( Canvas Canvas )
{
	// Still works
	DrawDMSynopsis(Canvas);
}

// Gametype synopsis
function DrawSynopsis( Canvas Canvas )
{
	if ( HUDType == HUD_Deathmatch )
		DrawDMSynopsis(Canvas);
	else if ( HUDType == HUD_TeamDeathmatch )
		DrawTDMSynopsis(Canvas);
	else if ( HUDType == HUD_CaptureTheFlag )
		DrawCTFSynopsis(Canvas);
	else if ( HUDType == HUD_Domination )
		DrawDOMSynopsis(Canvas);
	else if ( HUDType == HUD_Assault )
		DrawASSynopsis(Canvas);
	else if ( HUDType == HUD_LastManStanding )
		DrawLMSSynopsis(Canvas);
}

function bool CameraTrace( Vector TraceEnd )
{
	local Vector TraceStart;
	TraceStart = Class'Mutil'.Static.GetCameraSpot(self);
	return FastTrace(TraceEnd,TraceStart);
}

function bool ValidView( Actor Other )
{
	local PlayerReplicationInfo PRI1, PRI2;
	local bool bOldHidden;
	if ( Other.IsA('Pawn') )
	{
		PRI1 = PO.PlayerReplicationInfo;
		PRI2 = Pawn(Other).PlayerReplicationInfo;
		if ( (HUDType == HUD_LastManStanding)
			&& (PRI2 != None) && (PRI2.Score <= 0) )
			return false;
		if ( CameraTrace(Other.Location) )
			return true;
		if ( !Level.Game.bTeamGame )
			return false;
		if ( (PRI1 != None) && (PRI2 != None)
			&& (PRI1.Team == PRI2.Team) )
			return true;
	}
	if ( Other.IsA('Inventory') )
	{
		if ( !Other.IsInState('Pickup') )
			return false;
		if ( CameraTrace(Other.Location) )
			return true;
		if ( Other.IsA('MPowerup') || Other.IsA('MRefresher')
			|| (Other.IsA('MWeapon')
			&& MWeapon(Other).IsSuperWeapon)
			|| Other.IsA('WarheadLauncher')
			|| Other.IsA('EnhancedShockRifle')
			|| Other.IsA('HealthPack')
			|| Other.IsA('UT_ShieldBelt')
			|| Other.IsA('UT_JumpBoots') || Other.IsA('UDamage') )
			return true;
	}
	return false;
}

// Targeter visuals
function DrawTargetInfo( Canvas Canvas )
{
	local float XL, YL, Dist;
	local Pawn P;
	local PlayerReplicationInfo PRI;
	local Inventory I;
	local CTFFlag F;
	local ControlPoint CP;
	local FortStandard AS;
	local Actor A;
	local String PN;
	local Vector Pos;
	local MDamageCounter DC;
	Canvas.Font = Tahoma(10,True);
	// Pawns
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( P.IsA('FortStandard') || P.IsA('FlockMasterPawn')
			|| (P.IsA('FlockPawn') && !P.IsA('Bloblet')) )
			continue;
		PRI = P.PlayerReplicationInfo;
		if ( PRI != None )
			PN = PRI.PlayerName;
		else
			PN = P.NameArticle$P.MenuName;
		if ( !WorldToScreen(Canvas,P.Location+P.CollisionHeight
			*vect(0,0,1),Pos) || !ValidView(P) )
			continue;
		if ( Level.Game.bTeamGame && (PRI != None) )
			Canvas.DrawColor = TeamColor[PRI.Team];
		else
			Canvas.DrawColor = WhiteColor;
		Canvas.StrLen(PN,XL,YL);
		Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-(YL+16*ElementScale));
		Canvas.DrawText(PN);
		Canvas.SetPos(Pos.X-64*ElementScale,Pos.Y-16*ElementScale);
		Canvas.Style = ERenderStyle.STY_Modulated;
		Canvas.DrawTile(Texture'Gradient0',128*ElementScale,4
			*ElementScale,64,1,1,1);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor.R = 128;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(Pos.X-64*ElementScale,Pos.Y-16*ElementScale);
		Canvas.DrawTile(Texture'Whiteness',(128.0/P.Default.Health)
			*Clamp(P.Health,0,P.Default.Health)*ElementScale,
			4*ElementScale,1,1,1,1);
	}
	// Items
	ForEach AllActors(Class'Inventory',I)
	{
		if ( !WorldToScreen(Canvas,I.Location+I.CollisionHeight
			*vect(0,0,1),Pos) || !ValidView(I) )
			continue;
		if ( I.IsA('Ammo') )
		{
			Canvas.DrawColor.R = 128;
			Canvas.DrawColor.G = 64;
			Canvas.DrawColor.B = 0;
			PN = I.ItemName@"(+"$Ammo(I).AmmoAmount$")";
		}
		else if ( I.IsA('Weapon') )
		{
			Canvas.DrawColor.R = 128;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
			if ( I.IsA('EnhancedShockRifle')
				|| I.IsA('WarheadLauncher')
				|| (I.IsA('MWeapon')
				&& MWeapon(I).IsSuperWeapon) )
				Canvas.DrawColor.G = 128;
			if ( Weapon(I).AmmoType != None )
				PN = I.Itemname@"(+"$Weapon(I).AmmoType
					.AmmoAmount$")";
			else
				PN = I.Itemname@"(+"$Weapon(I)
					.PickupAmmoCount$")";
		}
		else if ( I.IsA('MArmor') || I.IsA('ThighPads')
			|| I.IsA('Armor2') )
		{
			Canvas.DrawColor.R = 64;
			Canvas.DrawColor.G = 128;
			Canvas.DrawColor.B = 0;
			PN = I.ItemName@"(+"$I.Charge$")";
		}
		else if ( I.IsA('MHealth') || I.IsA('TournamentHealth') )
		{
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = 128;
			Canvas.DrawColor.B = 0;
			if ( I.IsA('MRefresher') || I.IsA('HealthPack') )
			{
				Canvas.DrawColor.G = 64;
				Canvas.DrawColor.B = 128;
			}
			if ( I.IsA('MHealth') )
				PN = I.ItemName@"(+"$MHealth(I).HealingAmount
					$")";
			else
				PN = I.ItemName@"(+"$TournamentHealth(I)
					.HealingAmount$")";
		}
		else if ( I.IsA('MPowerup') || I.IsA('UT_ShieldBelt')
			|| I.IsA('UT_Invisibility') || I.IsA('UDamage')
			|| I.IsA('UT_JumpBoots') )
		{
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = 64;
			Canvas.DrawColor.B = 128;
			PN = I.ItemName;
		}
		Canvas.StrLen(PN,XL,YL);
		Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-0.5*YL);
		Canvas.DrawText(PN);
		if ( !I.IsA('MWeapon') )
			continue;
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = ERenderStyle.STY_Modulated;
		Canvas.SetPos(Pos.X-0.5*XL,Pos.Y+0.5*YL);
		Canvas.DrawTile(Texture'Gradient0',128*ElementScale,
			4*ElementScale,64,1,1,1);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor.R = 128;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(Pos.X-0.5*XL,Pos.Y+0.5*YL);
		Canvas.DrawTile(Texture'Whiteness',(128.0/MWeapon(I).Default
			.Health)*Clamp(MWeapon(I).Health,0,MWeapon(I)
			.Default.Health)*ElementScale,4*ElementScale,1,1,1,1);
	}
	// Gametype specials
	if ( HUDType == HUD_Domination )
	{
		ForEach AllActors(Class'ControlPoint',CP)
		{
			if ( !WorldToScreen(Canvas,CP.Location
				+CP.CollisionHeight*vect(0,0,1),Pos) )
				continue;
			if ( CP.ControllingTeam == None )
				Canvas.DrawColor = WhiteColor;
			else
				Canvas.DrawColor = TeamColor[CP
					.ControllingTeam.TeamIndex];
			Dist = VSize(CP.Location-PO.Location)/48.0;
			PN = CP.PointName@"("$int(Dist)$"m)";
			Canvas.StrLen(PN,XL,YL);
			Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-0.5*YL);
			Canvas.DrawText(PN);
		}
	}
	else if ( HUDType == HUD_CaptureTheFlag )
	{
		ForEach AllActors(Class'CTFFlag',F)
		{
			if ( !WorldToScreen(Canvas,F.Position().Location+F
				.Position().CollisionHeight*vect(0,0,1),Pos) )
				continue;
			Canvas.DrawColor = TeamColor[F.Team];
			Dist = VSize(F.Position().Location-PO.Location)/48.0;
			PN = FlagName[F.Team]@"("$int(Dist)$"m)";
			Canvas.StrLen(PN,XL,YL);
			Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-0.5*YL);
			Canvas.DrawText(PN);
		}
	}
	else if ( HUDType == HUD_Assault )
	{
		ForEach AllActors(Class'FortStandard',AS)
		{
			if ( (AS.FortName == AS.Default.FortName)
				|| (AS.FortName == "")
				|| (AS.FortName == " ") )
				PN = ASFallbackName;
			else
				PN = AS.FortName;
			if ( WorldToScreen(Canvas,AS.Location,Pos) )
			{
				Canvas.DrawColor.R = 128;
				Canvas.DrawColor.G = 64;
				Canvas.DrawColor.B = 64;
				Dist = VSize(AS.Location-PO.Location)/48.0;
				Canvas.StrLen(PN@"("$int(Dist)$"m)",XL,YL);
				Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-0.5*YL);
				Canvas.DrawText(PN@"("$int(Dist)$"m)");
			}
			ForEach AllActors(Class'Actor',A)
			{
				if ( A.Event != AS.Tag )
					continue;
				if ( A.IsA('FortStandard') )
					continue;
				if ( !WorldToScreen(Canvas,A.Location,Pos) )
					continue;
				Canvas.DrawColor.R = 160;
				Canvas.DrawColor.G = 128;
				Canvas.DrawColor.B = 128;
				Dist = VSize(A.Location-PO.Location)/48.0;
				Canvas.StrLen(PN@"("$int(Dist)$"m)",XL,YL);
				Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-0.5*YL);
				Canvas.DrawText(PN@"("$int(Dist)$"m)");
			}
		}
	}
	Canvas.Font = Arial(12);
	// Damage counters
	ForEach AllActors(Class'MDamageCounter',DC)
	{
		if ( !WorldToScreen(Canvas,DC.HitLocation,Pos)
			|| !ValidView(DC.Owner) )
			continue;
		Pos.Y -= (3.0-DC.LifeTime)*32.0*ElementScale;
		if ( DC.Factor > 0 )
		{
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = 255*FMin(DC.LifeTime,1.0);
			Canvas.DrawColor.B = 0;
			Canvas.StrLen("+"$DC.Factor,XL,YL);
			Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-0.5*YL);
			Canvas.DrawText("+"$DC.Factor);
		}
		else
		{
			Canvas.DrawColor.R = 255*FMin(DC.LifeTime,1.0);
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
			Canvas.StrLen(DC.Factor,XL,YL);
			Canvas.SetPos(Pos.X-0.5*XL,Pos.Y-0.5*YL);
			Canvas.DrawText(DC.Factor);
		}
	}
}

// "Minimap"
function DrawMinimap( Canvas Canvas )
{
	local Weapon W;
	local Pickup Pk;
	local Pawn P;
	local ControlPoint CP;
	local CTFFlag F;
	local FortStandard AS;
	local Actor A;
	local PlayerReplicationInfo PRI;
	local float MapX, MapY;
	local Vector RelPos;
	local Rotator FlatRot;
	local Texture CTex;
	Canvas.bNoSmooth = False;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX-128,0);
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.DrawTile(Texture'Gradient0',128,128,64,1,1,1);
	Canvas.Style = ERenderStyle.STY_Translucent;
	MapX = Canvas.ClipX-64;
	MapY = 64;
	FlatRot.Yaw = PO.ViewRotation.Yaw;
	// Weapons here
	Canvas.DrawColor.R = 128;
	Canvas.DrawColor.G = 128;
	Canvas.DrawColor.B = 0;
	foreach AllActors(Class'Weapon',W)
	{
		if ( !W.IsInState('Pickup') )
			continue;
		if ( (W.IsA('MWeapon') && !MWeapon(W).IsSuperWeapon)
			|| (!W.IsA('MWeapon') && !W.IsA('WarheadLauncher')
			&& !W.IsA('EnhancedShockRifle')) )
			continue;
		RelPos = ((W.Location-PO.Location)<<FlatRot)*0.02;
		if ( Max(Abs(RelPos.X),Abs(RelPos.Y)) > 60 )
			continue;
		Canvas.SetPos(MapX+RelPos.Y-4,MapY-RelPos.X-4);
		Canvas.DrawIcon(Texture'mh_star',1.0/8.0);
	}
	// Powerups here
	Canvas.DrawColor.R = 0;
	foreach AllActors(Class'Pickup',Pk)
	{
		if ( !Pk.IsInState('Pickup') )
			continue;
		if ( !Pk.IsA('MPowerup') && !Pk.IsA('Refresher')
			&& !Pk.IsA('UT_ShieldBelt')
			&& !Pk.IsA('UT_Invisibility') && !Pk.IsA('HealthPack')
			&& !Pk.IsA('UT_JumpBoots') && !Pk.IsA('UDamage') )
			continue;
		RelPos = ((Pk.Location-PO.Location)<<FlatRot)*0.02;
		if ( Max(Abs(RelPos.X),Abs(RelPos.Y)) > 60 )
			continue;
		Canvas.SetPos(MapX+RelPos.Y-4,MapY-RelPos.X-4);
		Canvas.DrawIcon(Texture'mh_star',1.0/8.0);
	}
	// Control Points
	if ( HUDType == HUD_Domination )
	{
		foreach AllActors(Class'ControlPoint',CP)
		{
			RelPos = ((CP.Location-PO.Location)<<FlatRot)*0.02;
			RelPos.X = FClamp(RelPos.X,-60,60);
			RelPos.Y = FClamp(RelPos.Y,-60,60);
			if ( CP.ControllingTeam == None )
			{
				Canvas.DrawColor = WhiteColor;
				CTex = Texture'mh_neutral';
			}
			else
			{
				Canvas.DrawColor = TeamColor[CP.ControllingTeam
					.TeamIndex];
				CTex = TeamIcon[CP.ControllingTeam.TeamIndex];
			}
			Canvas.SetPos(MapX+RelPos.Y-4,MapY-RelPos.X-4);
			Canvas.DrawIcon(CTex,1.0/8.0);
		}
	}
	// Flags
	else if ( HUDType == HUD_CaptureTheFlag )
	{
		foreach AllActors(Class'CTFFlag',F)
		{
			RelPos = ((F.Position().Location-PO.Location)<<FlatRot)
				*0.02;
			RelPos.X = FClamp(RelPos.X,-60,60);
			RelPos.Y = FClamp(RelPos.Y,-60,60);
			Canvas.DrawColor = TeamColor[F.Team];
			Canvas.SetPos(MapX+RelPos.Y-4,MapY-RelPos.X-4);
			Canvas.DrawIcon(Texture'mh_flag',1.0/8.0);
		}
	}
	// Assault targets
	else if ( HUDType == HUD_Assault )
	{
		foreach AllActors(Class'FortStandard',AS)
		{
			RelPos = ((AS.Location-PO.Location)<<FlatRot)*0.02;
			RelPos.X = FClamp(RelPos.X,-60,60);
			RelPos.Y = FClamp(RelPos.Y,-60,60);
			Canvas.DrawColor.R = 128;
			Canvas.DrawColor.G = 64;
			Canvas.DrawColor.B = 64;
			Canvas.SetPos(MapX+RelPos.Y-4,MapY-RelPos.X-4);
			Canvas.DrawIcon(Texture'mh_flag',1.0/8.0);
			foreach AllActors(Class'Actor',A)
			{
				if ( A.Event != AS.Tag )
					continue;
				if ( A.IsA('FortStandard') )
					continue;
				RelPos = ((A.Location-PO.Location)<<FlatRot)
					*0.02;
				RelPos.X = FClamp(RelPos.X,-60,60);
				RelPos.Y = FClamp(RelPos.Y,-60,60);
				Canvas.DrawColor.R = 160;
				Canvas.DrawColor.G = 128;
				Canvas.DrawColor.B = 128;
				Canvas.SetPos(MapX+RelPos.Y-4,MapY-RelPos.X-4);
				Canvas.DrawIcon(Texture'mh_flag',1.0/8.0);
			}
		}
	}
	// Pawns
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( (P == PO) || P.IsA('FortStandard')
			|| P.IsA('FlockMasterPawn') || (P.IsA('FlockPawn')
			&& !P.IsA('Bloblet')) )
			continue;
		RelPos = ((P.Location-PO.Location)<<FlatRot)*0.02;
		if ( Max(Abs(RelPos.X),Abs(RelPos.Y)) > 62 )
			continue;
		PRI = P.PlayerReplicationInfo;
		if ( (PRI == None) || !Level.Game.bTeamGame )
		{
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		}
		else
			Canvas.DrawColor = TeamColor[PRI.Team];
		Canvas.SetPos(MapX+RelPos.Y-2,MapY-RelPos.X-2);
		Canvas.DrawIcon(Texture'mh_dot',1.0/16.0);
	}
	// You are here
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(MapX-2,MapY-2);
	Canvas.DrawIcon(Texture'mh_dot',1.0/16.0);
	Canvas.bNoSmooth = True;
}

// Master HUD drawing function
event PostRender( Canvas Canvas )
{
	SetupHUD(Canvas);
	if ( (PO == None) || (PO.PlayerReplicationInfo == None) )
		return;
	// Weapon Post-render (usually crosshair is rendered here, but fuck
	// crosshairs, who needs them)
	if ( !PlayerOwner.bBehindView && (PO.Weapon != None) )
		PO.Weapon.PostRender(Canvas);
	if ( ShowInfo )
	{
		if ( ServerInfo == None )
			SpawnServerInfo();
		ServerInfo.RenderInfo(Canvas);
		return;
	}
	// Targeting Info
	DrawTargetInfo(Canvas);
	// Lesser messages
	DrawSmallMessages(Canvas);
	// Scores
	if ( PlayerOwner.bShowScores )
	{
		if ( (PlayerOwner.Scoring == None)
			&& (PlayerOwner.ScoringType != None) )
			PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType,
				PlayerOwner);
		if ( PlayerOwner.Scoring == None )
			return;
		PlayerOwner.Scoring.OwnerHUD = self;
		PlayerOwner.Scoring.ShowScores(Canvas);
		// Don't forget the prompt
		if ( PlayerOwner.Player.Console.bTyping )
			DrawPrompt(Canvas,PlayerOwner.Player.Console);
		return;
	}
	// Localized message loop
	DrawLocalizedMessages(Canvas);
	// Progress
	if ( PlayerOwner.ProgressTimeOut > Level.TimeSeconds )
		DrawProgress(Canvas);
	// MOTD, Map Info...
	if ( MOTDTime > Level.TimeSeconds )
		DrawMOTD(Canvas);
	// Player Status
	DrawPlayerStatus(Canvas);
	// Inventory Info
	DrawInventory(Canvas);
	// Synopsis
	DrawSynopsis(Canvas);
	// "Minimap"
	DrawMinimap(Canvas);
	// HUD mutators
	if ( HUDMutator != None )
		HUDMutator.PostRender(Canvas);
	// Console prompt
	if ( PlayerOwner.Player.Console.bTyping )
		DrawPrompt(Canvas,PlayerOwner.Player.Console);
}

function bool DisplayMessages( Canvas Canvas )
{
	return true;
}

// Horribly long function declaration
// Horribly deep nesting
// Horrible everything else
function LocalizedMessage( Class<LocalMessage> lMessage, optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, optional
	PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject,
	optional String CriticalString )
{
	local int i;
	local Name MT;
	if ( CriticalString == "" )
		CriticalString = lMessage.Static.GetString(Switch,RelatedPRI_1,
			RelatedPRI_2,OptionalObject);
	if ( !lMessage.Default.bIsSpecial )
	{
		if ( ClassIsChildOf(lMessage,Class'DeathMessagePlus') )
		{
			Message(RelatedPRI_1,CriticalString,'DeathMessage');
			return;
		}
		if ( ClassIsChildOf(lMessage,Class'SayMessagePlus') ||
			ClassIsChildOf(lMessage,Class'TeamSayMessagePlus') )
		{
			Message(RelatedPRI_1,CriticalString,'Say');
			return;
		}
		Message(RelatedPRI_1,CriticalString,lMessage.Class.Name);
		return;
	}
	else
	{
		if ( ClassIsChildOf(lMessage,Class'PickupMessagePlus') )
		{
			Message(RelatedPRI_1,CriticalString,'Pickup');
			return;
		}
		if( lMessage.Default.bIsUnique )
		{
			for ( i=0; i<10; i++ )
			{
				if ( LocalMessages[i].Message == None )
					continue;
				if ( (LocalMessages[i].Message == lMessage)
					|| (LocalMessages[i].Message.Static
					.GetOffset(LocalMessages[i].Switch,24,
					640) == lMessage.Static
					.GetOffset(Switch,24,640)) )
				{
					LocalMessages[i].Message = lMessage;
					LocalMessages[i].Switch = Switch;
					LocalMessages[i].RelatedPRI =
						RelatedPRI_1;
					LocalMessages[i].OptionalObject =
						OptionalObject;
					LocalMessages[i].LifeTime = lMessage
						.Default.LifeTime;
					LocalMessages[i].EndOfLife = lMessage
						.Default.LifeTime+Level
						.TimeSeconds;
					LocalMessages[i].StringMessage =
						CriticalString;
					LocalMessages[i].DrawColor = lMessage
						.Static.GetColor(Switch,
						RelatedPRI_1,RelatedPRI_2);
					return;
				}
			}
		}
		for ( i=0; i<10; i++ )
		{
			if ( LocalMessages[i].Message != None )
				continue;
			LocalMessages[i].Message = lMessage;
			LocalMessages[i].Switch = Switch;
			LocalMessages[i].RelatedPRI = RelatedPRI_1;
			LocalMessages[i].OptionalObject = OptionalObject;
			LocalMessages[i].LifeTime = lMessage.Default.LifeTime;
			LocalMessages[i].EndOfLife = lMessage.Default.LifeTime
				+Level.TimeSeconds;
			LocalMessages[i].StringMessage = CriticalString;
			LocalMessages[i].DrawColor = lMessage.Static
				.GetColor(Switch,RelatedPRI_1,RelatedPRI_2);
			return;
		}
		// No slots left, clear one
		for ( i=0; i<9; i++ )
			CopyMessage(LocalMessages[i],LocalMessages[i+1]);
		LocalMessages[9].Message = lMessage;
		LocalMessages[9].Switch = Switch;
		LocalMessages[9].RelatedPRI = RelatedPRI_1;
		LocalMessages[9].OptionalObject = OptionalObject;
		LocalMessages[9].LifeTime = lMessage.Default.LifeTime;
		LocalMessages[9].EndOfLife = lMessage.Default.LifeTime
			+Level.TimeSeconds;
		LocalMessages[9].StringMessage = CriticalString;
		LocalMessages[9].DrawColor = lMessage.Static.GetColor(Switch,
			RelatedPRI_1,RelatedPRI_2);
		return;
	}
}

// Lesser message handling
function Message( PlayerReplicationInfo PRI, coerce string Msg, Name N )
{
	local int i;
	if ( Msg == "" )
		return;
	if ( (N == 'SayMessagePlus') || (N == 'TeamSayMessagePlus') )
		N = 'Say';
	if ( N == 'Pickup' )
	{
		CurrentPickup.LifeTime = 3+Level.TimeSeconds;
		CurrentPickup.Message = Msg;
	}
	else if ( N == 'CriticalEvent' )
	{
		CriticalMessage.LifeTime = 3+Level.TimeSeconds;
		CriticalMessage.Message = Msg;
	}
	else
	{
		for ( i=2; i>=0; i-- )
		{
			if ( EventMessages[i].Message == "" )
				continue;
			CopySmallMessage(EventMessages[i+1],EventMessages[i]);
		}
		EventMessages[0].Type = N;
		EventMessages[0].Message = Msg;
		EventMessages[0].PRI = PRI;
		EventMessages[0].LifeTime = 5+Level.TimeSeconds;
	}
}

function ClearSmallMessage( out SmallMessage M )
{
	M.Message = "";
	M.LifeTime = 0;
	M.PRI = None;
	M.Type = '';
}

function CopySmallMessage ( out SmallMessage M1, SmallMessage M2 )
{
	M1.Message = M2.Message;
	M1.LifeTime = M2.LifeTime;
	M1.PRI = M2.PRI;
	M1.Type = M2.Type;
}

defaultproperties
{
	HUDConfigWindowType=None
	WhiteColor=(R=255,G=255,B=255)
	TeamColor(0)=(R=255,G=0,B=0)
	TeamColor(1)=(R=0,G=128,B=255)
	TeamColor(2)=(R=0,G=255,B=0)
	TeamColor(3)=(R=255,G=255,B=0)
	TeamIcon(0)=Texture'mh_red'
	TeamIcon(1)=Texture'mh_blue'
	TeamIcon(2)=Texture'mh_green'
	TeamIcon(3)=Texture'mh_gold'
	GameString="Game Type"
	TitleString="Map Title"
	AuthorString="Author"
	LoadString="Ideal Player Load"
	ASFallbackName="Objective"
	FlagName(0)="Red flag"
	FlagName(1)="Blue flag"
	FlagName(2)="Green flag"
	FlagName(3)="Gold flag"
}
