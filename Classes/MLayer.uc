//=============================================================================
// MLayer.
//
// Good ol' glowmap overlay hack. If only the engine could do this natively...
//=============================================================================
class MLayer extends Actor;

function Tick( float DeltaTime )
{
	if ( Owner == None )
		Destroy();
	if ( Base != None )
		SetBase(None);
	if ( Owner.DrawType == DT_Mesh )
	{
		Mesh = Owner.Mesh;
		PrePivot = Owner.PrePivot;
		Fatness = Owner.Fatness;
		AnimRate = Owner.AnimRate;
		AnimFrame = Owner.AnimFrame;
		AnimSequence = Owner.AnimSequence;
		DrawScale = Owner.DrawScale+0.005;
		SetLocation(Owner.Location);
		SetRotation(Owner.Rotation);
		return;
	}
	bHidden = true;
}

event FellOutOfWorld()
{
}

defaultproperties
{
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'SWWMZ.Invisible'
	ScaleGlow=1000.0
	AmbientGlow=254
	bUnlit=True
	bGameRelevant=True
	bTravel=True
	CollisionRadius=0.0
	CollisionHeight=0.0
}
