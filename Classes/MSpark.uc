//=============================================================================
// MSpark.
//
// A flashy spark.
//=============================================================================
class MSpark extends Actor;

event PostBeginPlay()
{
	DrawScale *= RandRange(0.8,1.2);
	Velocity += (Vector(Rotation)+VRand()*0.3)*RandRange(50,200);
}

event Tick( float deltatime )
{
	ScaleGlow -= 2*deltatime;
	if ( ScaleGlow <= 0.0 )
		Destroy();
	Velocity += Region.Zone.ZoneGravity*0.4*deltatime;
}

event HitWall( Vector HitNormal, Actor Wall )
{
	Velocity = 0.4*(Velocity-2*HitNormal*(Velocity dot HitNormal));
}

defaultproperties
{
	bHidden=False
	bCollideWorld=True
	CollisionRadius=1.0
	CollisionHeight=1.0
	Texture=Texture'Botpack.Sparky'
	DrawScale=0.2
	ScaleGlow=3.0
	Style=STY_Translucent
	Physics=PHYS_Projectile
	Mass=1.0
	Buoyancy=0.0
	bBounce=True
}
