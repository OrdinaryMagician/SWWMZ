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
	n = 3+Rand(5);
	for ( i=0; i<n; i++ )
		Spawn(Class'MSpark',,,Location,Rotation);
}
