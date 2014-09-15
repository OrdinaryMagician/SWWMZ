//=============================================================================
// MArmor.
//
// Base SWWMZ Armor class.
//=============================================================================
class MArmor extends TournamentPickup abstract;

var() int ArmorAmount;
var() int ArmorMax;
var int CurrentArmor;

event float BotDesireability( Pawn Bot )
{
	local Inventory i;
	for ( i=Bot.Inventory; i!=None; i=i.Inventory )
		if ( i.Class == Class )
			return ArmorDesireability(Bot,MArmor(i));
	return ArmorDesireability(Bot,None);
}

function float ArmorDesireability( Pawn Bot, MArmor A )
{
	local float desire;
	local int Current;
	if ( A == None )
		Current = 0;
	else
		Current = A.CurrentArmor;
	if ( Current >= ArmorMax )
		return -1.0;
	desire = Min(ArmorAmount,ArmorMax-Current);
	if ( (Bot.Weapon != None) && (Bot.Weapon.AIRating > 0.5) )
		desire *= 1.7;
	if ( Bot.Enemy != None )
		desire *= 1.3;
	if ( (Bot.Enemy != None) && (Bot.Weapon != None)
		&& (Bot.Enemy.Weapon != None)
		&& (Bot.Weapon.AIRating < Bot.Enemy.Weapon.AIRating) )
		desire *= 1.8;
	return FMin(0.02*(ArmorMax-Current),2.0);
}

function int Reduce( int Damage, Name DamageType,
	Vector HitLocation )
{
	return Damage;
}

Auto State Pickup
{
	function Touch( Actor Other )
	{
		local Inventory copy, i;
		local Pawn P;
		local bool SkipCopy;
		if ( !ValidTouch(Other) )
			return;
		SkipCopy = False;
		P = Pawn(Other);
		for ( i=P.Inventory; i!=None; i=i.Inventory )
		{
			if ( i.Class == Class )
			{
				if ( MArmor(i).CurrentArmor >= ArmorMax )
					return;
				MArmor(i).CurrentArmor = Max(MArmor(i)
					.CurrentArmor+ArmorAmount,ArmorMax);
				SkipCopy = True;
			}
		}
		if ( Level.Game.LocalLog != None )
			Level.Game.LocalLog.LogPickup(self,P);
		if ( Level.Game.WorldLog != None )
			Level.Game.WorldLog.LogPickup(self,P);
		if ( PickupMessageClass == None )
			P.ClientMessage(PickupMessage,'Pickup');
		else
			P.ReceiveLocalizedMessage(PickupMessageClass,0,None,
				None,self.Class);
		PlaySound(PickupSound,,2.0);
		P.MakeNoise(0.3);
		if ( !SkipCopy )
		{
			copy = SpawnCopy(P);
			copy.GiveTo(P);
			MArmor(copy).CurrentArmor = ArmorAmount;
		}
		SetRespawn();
	}
}

defaultproperties
{
}
