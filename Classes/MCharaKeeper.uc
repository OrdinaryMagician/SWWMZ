//=============================================================================
// MCharaKeeper.
//
// Small hack to revert player properties in case of sudden death.
//=============================================================================
class MCharaKeeper extends Mutator;

var bool Initialized;

event PostBeginPlay()
{
	local Mutator M;
	if ( !Initialized )
	{
		Initialized = True;
		for ( M=Level.Game.BaseMutator; M!=None; M=M.NextMutator )
			if ( M.IsA('MCharaKeeper') )
				Destroy();
		Level.Game.BaseMutator.AddMutator(self);
	}
}

function ModifyPlayer( Pawn Other )
{
	Other.GroundSpeed = Other.Default.GroundSpeed;
	Other.WaterSpeed = Other.Default.WaterSpeed;
	Other.Mass = Other.Default.Mass;
	Other.Buoyancy = Other.Default.Buoyancy;
	Other.JumpZ = Other.Default.JumpZ*Level.Game.PlayerJumpZScaling();
	Other.bRun = 0;
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

defaultproperties
{
}
