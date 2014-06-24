//=============================================================================
// MChip.
//
// A lil' chunk.
//=============================================================================
class MChip extends Actor;

var() Name Positions[4];
var float notseen;

event HitWall( Vector HitNormal, Actor Wall )
{
	local Vector RealHitNormal;
	RealHitNormal = HitNormal;
	HitNormal = Normal(HitNormal+0.4*VRand());
	if ( (HitNormal dot RealHitNormal) < 0  )
		HitNormal *= -0.5;
	Velocity = 0.25*(Velocity-2*HitNormal*(Velocity dot HitNormal));
	RandSpin(200000);
	if ( VSize(Velocity) > 20 )
		return;
	SetPhysics(PHYS_None);
	if ( Wall != None )
		SetBase(Wall);
}

event PostBeginPlay()
{
	PlayAnim(Positions[Rand(4)]);
	Velocity += VRand()*(680*FRand())+Vector(Rotation)*220;
	RandSpin(200000);
	DrawScale = Default.DrawScale*(0.5+FRand());
}

event Tick( float deltatime )
{
	if ( !PlayerCanSeeMe() )
		notseen += deltatime;
	if ( (notseen > 20) || (Level.bDropDetail && (FRand() < 0.1)) )
		Destroy();
}

final function RandSpin( float SpinRate )
{
	DesiredRotation = RotRand();
	RotationRate.Pitch = 2.0*SpinRate*(0.5-FRand());
	RotationRate.Yaw = 2.0*SpinRate*(0.5-FRand());
}

event TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
	Vector Momentum, Name DamageType )
{
	Velocity += Momentum/Mass;
	if ( Physics != PHYS_None )
		return;
	SetBase(None);
	SetPhysics(PHYS_Falling);
	RandSpin(200000);
}

defaultproperties
{
	Positions(0)='Position1'
	Positions(1)='Position2'
	Positions(2)='Position3'
	Positions(3)='Position4'
	Physics=PHYS_Falling
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.ChipM'
	DrawScale=0.5
	bGameRelevant=True
	CollisionRadius=0.0
	CollisionHeight=0.0
	Buoyancy=8
	Mass=10
	bCollideActors=True
	bCollideWorld=True
	bProjTarget=True
	bBounce=True
	bFixedRotationDir=True
}
