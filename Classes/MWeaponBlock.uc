//=============================================================================
// MWeaponBlock.
//
// A gross hack to make carried weapons shootable.
//=============================================================================

// Now seriously, this engine is complete shit to work with for things like
// these. I have only three possible ways to implement this properly.
// The first is the one I've been using in previous mods, and it is to use a
// "guessed" offset for the weapon at all times, which is far from perfect,
// the second would be to calculate the gravity center of the weapon on every
// frame, however that would be the hugest performance hog since Intensive
// Tracing. The third way would be to reverse-engineer the engine and find out
// how it handles Weapon positioning with special vertices (or bones in the
// case of skeletal meshes). There is a fourth way, and it's the one I've
// decided to use in the future, and that is to write my own engine from the
// ground up so I don't ever have to deal with stupid limitations ever again.
//
//   -- Marisa

var() Sound HitSound[3];
var MWeapon MyWeapon;
var Pawn PO;
var int Health;
var bool Initialized;

function Setup( MWeapon W, Pawn P )
{
	MyWeapon = W;
	if ( P != None )
		PO = P;
	Health = W.Health;
	Initialized = True;
	SetCollisionSize(W.CollisionRadius,W.CollisionHeight);
}

event Tick( float DeltaTime )
{
	if ( !Initialized )
		return;
	if ( (MyWeapon == None) || ((PO != None) && ((PO.Health < 0)
		|| (PO.Weapon != MyWeapon))) )
		Destroy();
	if ( PO != None )
	{
		GetAxes(PO.Rotation,X,Y,Z);
		// Ugly as fuck method, fuck you Unreal Engine
		// Offset guessed from Fighter animation of Soldier mesh
		Offset = (X*10+Y*10+Z*12)*PO.DrawScale;
		SetLocation(PO.Location+Offset);
		SetCollision(True);
		bProjTarget = True;
		return;
	}
	SetLocation(MyWeapon.Location);
	if ( MyWeapon.IsInState('Sleeping') )
	{
		Health = MyWeapon.Default.Health;
		SetCollision(False);
		bProjTarget = False;
		return;
	}
	SetCollision(True);
	bProjTarget = True;
}

event TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
	Vector Momentum, Name DamageType )
{
	if ( (MyWeapon == None) || MyWeapon.IsInState('Sleeping') )
		return;
	Health -= Damage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	PlaySound(HitSound[Rand(3)],SLOT_Interact,1.5,,,0.8+FRand()*0.4);
	Spawn(class'MQsm',,, HitLocation, Rotator(HitLocation-Location));
	Spawn(class'MSparks',,, HitLocation, Rotator(HitLocation-Location));
	if ( Health <= 0 )
	{
		Instigator = InstigatedBy;
		MyWeapon.VolatileFunction();
		Destroy();
	}
}

defaultproperties
{
	HitSound(0)=Sound'SWWMZ.WeaponHit1'
	HitSound(1)=Sound'SWWMZ.WeaponHit2'
	HitSound(2)=Sound'SWWMZ.WeaponHit3'
	bHidden=True
	bGameRelevant=True
	bIsKillGoal=True
	bTravel=True
	bCollideActors=True
	bProjTarget=True
}
