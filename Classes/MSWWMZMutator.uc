//=============================================================================
// MSWWMZMutator.
//
// The heart of SWWM Z.
//=============================================================================
class MSWWMZMutator extends Mutator;

var bool Initialized;

event PostBeginPlay()
{
	if ( !Initialized )
	{
		Initialized = True;
		Spawn(class'MHUDNotify');
	}
}
