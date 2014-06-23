//=============================================================================
// MWeaponBlock.
//
// A gross hack to make carried weapons shootable.
//=============================================================================
class MWeaponBlock extends Actor;

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

var MWeapon MyWeapon;
var Pawn PO;
var bool Initialized;

function Setup( MWeapon W, Pawn P )
{
	MyWeapon = W;
	if ( P != None )
		PO = P;
	Initialized = True;
	SetCollisionSize(W.CollisionRadius,W.CollisionHeight);
}

event Tick( float DeltaTime )
{
	local Vector X,Y,Z, Offset;
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
		MyWeapon.Health = MyWeapon.Default.Health;
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
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	MyWeapon.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,
		DamageType);
	if ( MyWeapon.Health <= 0 )
		Destroy();
}

defaultproperties
{
	bHidden=True
	bGameRelevant=True
	bIsKillGoal=True
	bTravel=True
	bCollideActors=True
	bProjTarget=True
}
