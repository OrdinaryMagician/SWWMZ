//=============================================================================
// MSWWMZMutator.
//
// The heart of SWWM Z.
//=============================================================================
class MSWWMZMutator extends Mutator;

var bool Initialized;

function UpdateDamage( Pawn P, int D, Vector HL )
{
	local MDamageCounter DC;
	DC = Spawn(Class'MDamageCounter',P);
	DC.Factor = -D;
	if ( HL != vect(0,0,0) )
		HL -= P.Location;
	DC.RealHitLocation = HL;
}

event PostBeginPlay()
{
	if ( Initialized )
		return;
	Initialized = True;
	Spawn(class'MHUDNotify');
	Level.Game.RegisterDamageMutator(self);
	SetTimer(1.0,True);
}

function ModifyPlayer( Pawn Other )
{
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim,
	Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum,
	Name DamageType )
{
	UpdateDamage(Victim,ActualDamage,HitLocation);
	if ( NextDamageMutator != None )
		NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,
			InstigatedBy,HitLocation,Momentum,DamageType);
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
}
