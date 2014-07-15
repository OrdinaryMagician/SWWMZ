//=============================================================================
// MDamageCounter.
//
// Cute little numbers floating on the screen.
//=============================================================================
class MDamageCounter extends Info;

var Vector HitLocation, RealHitLocation, LastOwnerLocation;
var int Factor;
var float LifeTime;

event PostBeginPlay()
{
	LifeTime = 3.0;
}

event Tick( float deltatime )
{
	if ( Owner != None )
		LastOwnerLocation = Owner.Location;
	HitLocation = LastOwnerLocation+RealHitLocation;
	LifeTime -= deltatime;
	if ( LifeTime <= 0 )
		Destroy();
}
