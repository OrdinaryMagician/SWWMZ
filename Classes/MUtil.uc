//=============================================================================
// MUtil.
//
// Small utility class used by some things.
//=============================================================================
class MUtil extends Object;

var Player LastReply;
var Vector LastCamPos;
var float LastTimestamp;

static function Player GetPlayer( Actor Checker )
{
	local PlayerPawn PP;
	local Pawn P;
	if ( Default.LastReply != None )
		return Default.LastReply;
	if ( Checker.Level.NetMode == NM_Client )
	{
		foreach Checker.AllActors(class'PlayerPawn',PP)
		{
			if ( (PP.Player != None)
				&& (PP.Player.Console != None) )
			{
				Default.LastReply = PP.Player;
				return PP.Player;
			}
		}
	}
	else
	{
		for ( P=Checker.Level.PawnList; P!=None; P=P.NextPawn )
		{
			if ( P.IsA('PlayerPawn')
				&& (PlayerPawn(P).Player != None)
				&& (PlayerPawn(P).Player.Console != None) )
			{
				Default.LastReply = PlayerPawn(P).Player;
				return PlayerPawn(P).Player;
			}
		}
	}
}

static function Vector GetCameraSpot( Actor Checker )
{
	local Rotator TempRot;
	local Actor TempActor;
	local Player P;
	P = GetPlayer(Checker);
	if ( P.Actor.Level.TimeSeconds != Default.LastTimeStamp )
	{
		Default.LastTimeStamp = P.Actor.Level.TimeSeconds;
		P.Actor.PlayerCalcView(TempActor,Default.LastCamPos,TempRot);
	}
	return Default.LastCamPos;
}
