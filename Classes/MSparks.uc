//=============================================================================
// MSparks.
//
// Multiple sparks.
//=============================================================================
class MSparks extends MSpark;

event PostBeginPlay()
{
	local int i, n;
	Super.PostBeginPlay();
	n = 4+Rand(9);
	for ( i=0; i<n; i++ )
		Spawn(Class'MSpark',,,Location,Rotation);
}
