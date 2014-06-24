//=============================================================================
// MSWWMZMutator.
//
// The heart of SWWM Z.
//=============================================================================
class MSWWMZMutator extends Mutator;

var bool Initialized;

event PostBeginPlay()
{
	if ( Initialized )
		return;
	Initialized = True;
	Spawn(class'MHUDNotify');
	Level.Game.RegisterDamageMutator(self);
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
