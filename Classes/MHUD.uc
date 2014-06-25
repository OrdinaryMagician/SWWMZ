//=============================================================================
// MHUD.
//
// SWWM Gold had a "HUD Addon", it was ugly and hacky.
// SWWM Z now has its own full standalone HUD that replaces the aged vanilla UT
// "ChallengeHUD". It has been designed specifically for minimal screen clutter
// and it's mostly transparent.
//=============================================================================
class MHUD extends HUD;

// HUD type, better than having a shitload of separate classes
enum EHUDType
{
	HUD_Deathmatch,
	HUD_TeamDeathmatch,
	HUD_Domination,
	HUD_CaptureTheFlag,
	HUD_Assault,
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
static function Font Arial( int Size )
{
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
static function Font Tahoma( int Size, optional bool Bold )
{
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

event PostBeginPlay()
{
	MOTDTime = Level.TimeSeconds+6;
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
	Canvas.DrawColor = WhiteColor*0.3;
	Canvas.SetPos(4,Pos);
	Str = PN;
	if ( EventMessages[i].PRI.PlayerLocation != None )
		Str = Str$"("$EventMessages[i].PRI.PlayerLocation
			.LocationName$")";
	else if ( (EventMessages[i].PRI.PlayerZone != None)
		&& (EventMessages[i].PRI.PlayerZone.ZoneName != "") )
		Str = Str$"("$EventMessages[i].PRI.PlayerZone.ZoneName$")";
	Str = Str$": ";
	Canvas.StrLen(Str,XL,YL);
	Canvas.DrawText(Str);
	Canvas.SetPos(4+XL,Pos);
	Canvas.DrawColor = WhiteColor*0.5;
	Canvas.DrawColor.R *= 0.5;
	Canvas.DrawColor.B *= 0.5;
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
	local String Username, CWD;
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos(0,Canvas.ClipY-32);
	Canvas.bNoSmooth = False;
	Canvas.DrawTile(Texture'Gradient270',Canvas.ClipX,32,0,128,1,128);
	Canvas.bNoSmooth = True;
	Username = PlayerOwner.PlayerReplicationInfo.PlayerName;
	CWD = "/"$Left(Level.GetLocalURL(),InStr(Level.GetLocalURL(),".unr"));
	Canvas.Font = Font'Engine.SmallFont';
	Canvas.StrLen("M",XL,YL);
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor.R = 16;
	Canvas.DrawColor.G = 96;
	Canvas.DrawColor.B = 16;
	Canvas.SetPos(2,Canvas.ClipY-(YL+2));
	Canvas.DrawText(Username);
	Canvas.DrawColor.R = 32;
	Canvas.DrawColor.G = 192;
	Canvas.DrawColor.B = 32;
	Canvas.SetPos(2+XL*(Len(Username)+1),Canvas.ClipY-(YL+2));
	Canvas.DrawText(CWD);
	Canvas.DrawColor.R = 64;
	Canvas.DrawColor.G = 128;
	Canvas.DrawColor.B = 64;
	Canvas.SetPos(2+XL*(Len(Username)+Len(CWD)+2),Canvas.ClipY-(YL+2));
	Canvas.DrawText("%");
	Canvas.DrawColor.R = 128;
	Canvas.DrawColor.G = 192;
	Canvas.DrawColor.B = 128;
	Canvas.SetPos(2+XL*(Len(Username)+Len(CWD)+4),Canvas.ClipY-(YL+2));
	Canvas.DrawText(Console.TypedStr$"_");
}

// Localized messages
function DrawLocalizedMessages( Canvas Canvas )
{
	local int i;
	local float FadeFactor;
	for ( i=0; i<10; i++ )
	{
		if ( LocalMessages[i].Message == None )
			continue;
		Canvas.Font = LocalMessages[i].StringFont;
		Canvas.DrawColor = LocalMessages[i].DrawColor;
		if ( LocalMessages[i].Message.Default.bFadeMessage )
		{
			FadeFactor = LocalMessages[i].EndOfLife
				-Level.TimeSeconds;
			Canvas.DrawColor.R *= (FadeFactor/LocalMessages[i]
				.LifeTime);
			Canvas.DrawColor.G *= (FadeFactor/LocalMessages[i]
				.LifeTime);
			Canvas.DrawColor.B *= (FadeFactor/LocalMessages[i]
				.LifeTime);
		}
		Canvas.SetPos(0.5*(Canvas.ClipX-LocalMessages[i].XL),
			LocalMessages[i].YPos);
		Canvas.DrawText(LocalMessages[i].StringMessage);
	}
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
	Canvas.DrawText("Game Type:"@GRI.GameName,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText("Map Title:"@Level.Title,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	Canvas.DrawText("Author:"@Level.Author,True);
	Pos += YL;
	Canvas.SetPos(0,Canvas.ClipY*0.1+Pos);
	if ( Level.IdealPlayerCount != "" )
		Canvas.DrawText("Ideal Player Load:"@Level.IdealPlayerCount,
			True);
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
}

// Inventory (Weapon listings, current weapon)
function DrawInventory( Canvas Canvas )
{
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
}

// Capture the Flag synopsis
function DrawCTFSynopsis( Canvas Canvas )
{
}

// Domination synopsis
function DrawDOMSynopsis( Canvas Canvas )
{
}

// Assault synopsis (lol ASS)
function DrawASSynopsis( Canvas Canvas )
{
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
}

// Targeter visuals
function DrawTargetInfo( Canvas Canvas )
{
	local float XL, YL;
	local Pawn P;
	local PlayerReplicationInfo PRI;
	local Vector Position;
	Canvas.Font = Tahoma(10,True);
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( P.PlayerReplicationInfo == None )
			continue;
		if ( !WorldToScreen(Canvas,P.Location+P.CollisionHeight
			*vect(0,0,1),Position) )
			continue;
		PRI = P.PlayerReplicationInfo;
		Canvas.DrawColor = WhiteColor;
		Canvas.StrLen(PRI.PlayerName,XL,YL);
		Canvas.SetPos(Position.X-0.5*XL,Position.Y-(YL+16));
		Canvas.DrawText(PRI.PlayerName);
		Canvas.SetPos(Position.X-64,Position.Y-16);
		Canvas.Style = ERenderStyle.STY_Modulated;
		Canvas.DrawTile(Texture'Gradient0',128,2,64,1,1,1);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor.R = 128;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(Position.X-64,Position.Y-16);
		Canvas.DrawTile(Texture'Whiteness',1.28*Clamp(P.Health,0,100),
			2,1,1,1,1);
		Canvas.DrawColor.G = 128;
		Canvas.SetPos(Position.X-64,Position.Y-16);
		Canvas.DrawTile(Texture'Whiteness',1.28*Clamp(P.Health-100,0,
			100),2,1,1,1,1);
		Canvas.DrawColor.R = 0;
		Canvas.SetPos(Position.X-64,Position.Y-16);
		Canvas.DrawTile(Texture'Whiteness',0.16*Clamp(P.Health-200,0,
			1000),2,1,1,1,1);
		Canvas.DrawColor.B = 128;
		Canvas.SetPos(Position.X-64,Position.Y-16);
		Canvas.DrawTile(Texture'Whiteness',0.128*Clamp(P.Health-1000,0,
			2000),2,1,1,1,1);
		Canvas.DrawColor.G = 0;
		Canvas.SetPos(Position.X-64,Position.Y-16);
		Canvas.DrawTile(Texture'Whiteness',0.427*Clamp(P.Health-2000,0,
			5000),2,1,1,1,1);
	}
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
	// Targeting Info
	DrawTargetInfo(Canvas);
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
	if ( !lMessage.Default.bIsSpecial )
	{
		if ( ClassIsChildOf(lMessage,Class'DeathMessagePlus') )
		{
			CriticalString = lMessage.Static.GetString(Switch,
				RelatedPRI_1,RelatedPRI_2,OptionalObject);
			Message(RelatedPRI_1,CriticalString,'DeathMessage');
		}
		return;
	}
	else
	{
		if ( CriticalString == "" )
			CriticalString = lMessage.Static.GetString(Switch,
				RelatedPRI_1,RelatedPRI_2,OptionalObject);
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
						.Default.LifeTime-Level
						.TimeSeconds;
					LocalMessages[i].StringMessage =
						CriticalString;
					LocalMessages[i].DrawColor = lMessage
						.Static.GetColor(Switch,
						RelatedPRI_1,RelatedPRI_2);
					LocalMessages[i].XL = 0;
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
				-Level.TimeSeconds;
			LocalMessages[i].StringMessage = CriticalString;
			LocalMessages[i].DrawColor = lMessage.Static
				.GetColor(Switch,RelatedPRI_1,RelatedPRI_2);
			LocalMessages[i].XL = 0;
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
			-Level.TimeSeconds;
		LocalMessages[9].StringMessage = CriticalString;
		LocalMessages[9].DrawColor = lMessage.Static.GetColor(Switch,
			RelatedPRI_1,RelatedPRI_2);
		LocalMessages[9].XL = 0;
		return;
	}
}

// Lesser message handling
function Message( PlayerReplicationInfo PRI, coerce string Msg, Name N )
{
	local int i;
	if ( Msg == "" )
		return;
	if ( N == 'PickupMessagePlus' )
		N = 'Pickup';
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
}
