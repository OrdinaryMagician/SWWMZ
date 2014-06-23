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
	HUD_Spectator,
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
var float MOTDFade;

event Timer()
{
	if ( MOTDFade > 0.0 )
		MOTDFade -= 0.05;
	Super.Timer();
}

event PostBeginPlay()
{
	MOTDFade = 1.0;
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
	Canvas.Font = Font'Engine.SmallFont';
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = WhiteColor;
}

// Targeter special visuals (eg: mesh overlays)
function DrawTargetSpecial( Canvas Canvas )
{
}

// Handle events, pickups and criticals
function DrawSmallMessages( Canvas Canvas )
{
}

// Console prompt
function DrawPrompt( Canvas Canvas, Console Console )
{
}

// Localized messages
function DrawLocalizedMessages( Canvas Canvas )
{
}

// Progress (?)
function DrawProgress( Canvas Canvas )
{
}

// MOTD and Map Info
function DrawMOTD( Canvas Canvas )
{
}

// Player Health, Armor, Powerups...
function DrawPlayerStatus( Canvas Canvas )
{
}

// Inventory (Weapon listings, current weapon)
function DrawInventory( Canvas Canvas )
{
}

// Score counter (usually frags)
function DrawScoring( Canvas Canvas )
{
}

// Special gametype-specific info
function DrawGameSpecial( Canvas Canvas )
{
}

// Gametype synopsis
function DrawSynopsis( Canvas Canvas )
{
}

// Targeter visuals
function DrawTargetInfo( Canvas Canvas )
{
}

// Master HUD drawing function
event PostRender( Canvas Canvas )
{
	SetupHUD(Canvas);
	if ( (PO == None) || (PO.PlayerReplicationInfo == None) )
		return;
	if ( ShowInfo )
	{
		if ( ServerInfo == None )
			SpawnServerInfo();
		ServerInfo.RenderInfo(Canvas);
		return;
	}
	// Targeting Specials
	DrawTargetSpecial(Canvas);
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
	// Weapon Post-render (usually crosshair is rendered here, but fuck
	// crosshairs, who needs them)
	if ( !PlayerOwner.bBehindView && (PO.Weapon != None) )
		PO.Weapon.PostRender(Canvas);
	// Progress
	if ( PlayerOwner.ProgressTimeOut > Level.TimeSeconds )
		DrawProgress(Canvas);
	// MOTD, Map Info...
	if ( MOTDFade > 0.0 )
		DrawMOTD(Canvas);
	// Player Status
	DrawPlayerStatus(Canvas);
	// Inventory Info
	DrawInventory(Canvas);
	// Scoring
	DrawScoring(Canvas);
	// Gamemode specials
	DrawGameSpecial(Canvas);
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
		CurrentPickup.LifeTime = 6+Level.TimeSeconds;
		CurrentPickup.Message = Msg;
	}
	else if ( N == 'CriticalEvent' )
	{
		CriticalMessage.LifeTime = 6+Level.TimeSeconds;
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
		EventMessages[0].LifeTime = 6+Level.TimeSeconds;
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
