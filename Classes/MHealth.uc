//=============================================================================
// MHealth.
//
// Base class of all healing items.
//=============================================================================
class MHealth extends TournamentPickup abstract;

var() int HealingAmount
var() int HealingMax;

// TODO make healing undesirable if a nearby teammate has less health
event float BotDesireability( Pawn Bot )
{
	local float desire;
	// We don't need this
	if ( Bot.Health >= HealingMax )
		return -1.0;
	desire = Min(HealingAmount,HealingMax-Bot.Health);
	// I don't even know what's the reasoning for this one, but it's
	// vanilla behavior so I better leave it alone
	if ( (Bot.Weapon != None) && (Bot.Weapon.AIRating > 0.5) )
		desire *= 1.7;
	// In combat? more reasons to want this
	if ( Bot.Enemy != None )
		desire *= 1.3;
	// Underwhelmed? even more reasons
	if ( (Bot.Enemy != None) && (Bot.Weapon != None)
		&& (Bot.Enemy.Weapon != None)
		&& (Bot.Weapon.AIRating < Bot.Enemy.Weapon.AIRating) )
		desire *= 1.8;
	// Come on, you really need this
	if ( Bot.Health < 45 )
		return FMin(0.03*desire,2.2);
	return FMin(0.017*FMax(desire,25),2.0);
}

Auto State Pickup
{
	event Touch( Actor Other )
	{
		local Pawn P;
		if ( !ValidTouch(Other) )
			return;
		// no need to actually check if toucher is pawn, ValidTouch()
		// already does that
		P = Pawn(Other);
		if ( P.Health >= HealingMax )
			return;
		if ( Level.Game.LocalLog != None )
			Level.Game.LocalLog.LogPickup(self,P);
		if ( Level.Game.WorldLog != None )
			Level.Game.WorldLog.LogPickup(self,P);
		if ( PickupMessageClass == None )
			P.ClientMessage(PickupMessage,'Pickup');
		else
			P.ReceiveLocalizedMessage(PickupMessageClass,0,None,
				None,self.Class);
		PlaySound(PickupSound,,2.5);
		P.MakeNoise(0.2);
		P.Health = Max(P.Health+HealingAmount,HealingMax);
		SetRespawn();
	}
}

defaultproperties
{
}
