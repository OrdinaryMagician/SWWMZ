//=============================================================================
// MAmmo.
//
// The basic SWWMZ ammo class, now with more volatility and less dropper.
//=============================================================================
class MAmmo extends TournamentAmmo abstract;

#exec TEXTURE IMPORT NAME=Invisible FILE=Textures\Invisible.pcx

var(Display) texture GlowSkins[8];
var() bool CanExplode;

var MLayer Overlayer;
var bool AlreadyDropped;

function Tick( float DeltaTime )
{
	bProjTarget = (IsInState('Pickup') && !bHidden);
}

function SetOverlay()
{
	local int i;
	if ( Overlayer == None )
		return;
	if ( Owner != None )
		return;
	for ( i=0; i<8; i++ )
	{
		if ( GlowSkins[i] != None )
			Overlayer.MultiSkins[i] = GlowSkins[i];
		else
			Overlayer.MultiSkins[i] = Texture'SWWMZ.Invisible';
	}
}

Auto State Pickup
{
	function BeginState()
	{
		Super.BeginState();
		if ( Overlayer == None )
			Overlayer = Spawn(class'MLayer',self);
		SetOverlay();
	}

	function EndState()
	{
		Super.EndState();
		if ( Overlayer != None )
			Overlayer.Destroy();
	}

	function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
		Vector Momentum, Name DamageType )
	{
		if ( CanExplode )
			GotoState('VolatileAmmo');
	}
}

// Base template - fill up in subclasses
State VolatileAmmo
{
	function Touch( Actor Other )
	{
		// ignore touching
	}

	function BeginState()
	{
		bHidden = True;
	}

	function EndExplosion()
	{
		if ( RespawnTime > 0 )
			GotoState('Sleeping');
		else
			Destroy();
	}

Begin:
	EndExplosion();
}

defaultproperties
{
	PickupSound=Sound'SWWMZ.AmmoPick'
	bCollideActors=True
	bProjTarget=False
	CanExplode=False
}
