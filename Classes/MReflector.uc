class MReflector extends MPowerup;

var MReflectorSphere S;
var int DamageCounter;

function PickupFunction( Pawn Other )
{
	GotoState('Activated');
}

function GetHit()
{
	if ( S != None )
		S.Flash();
	DamageCounter--;
}

State Activated
{
	event BeginState()
	{
		S = Spawn(Class'MReflectorSphere',Owner,,Owner.Location);
		SetTimer(1.0,True);
		DamageCounter = 5000;
	}

	event Tick( float DeltaTime )
	{
		local Projectile P;
		local Vector X,Y,Z, HitNormal, HitLocation, BounceDir;
		if ( Owner == None )
		{
			Destroy();
			return;
		}
		if ( S == None )
			S = Spawn(Class'MReflectorSphere',Owner,,
				Owner.Location);
		ForEach AllActors(Class'Projectile',P)
		{
			if ( (P.Instigator == Pawn(Owner))
				|| (P.Default.Speed == 0)
				|| (P.Physics == PHYS_None)
				|| (VSize(P.Velocity) <= 40) )
				continue;
			if ( !AtRange(P,S) )
				continue;
			GetAxes(Rotator(P.Velocity),X,Y,Z);
			HitNormal = Normal(S.Location-P.Location);
			BounceDir = (X-2.0*HitNormal*(X dot HitNormal));
			P.Velocity = 5.0*VSize(P.Velocity)*BounceDir;
			P.SetRotation(Rotator(BounceDir));
			P.Acceleration = VSize(P.Acceleration)*BounceDir;
			P.Instigator = Pawn(Owner);
			S.Flash();
			DamageCounter--;
		}
		if ( DamageCounter <= 0 )
		{
			Pawn(Owner).ClientMessage(ExpireMessage);
			Destroy();
		}
	}

	event Timer()
	{
		Charge -= 1;
		if ( Charge > 3 )
			return;
		Owner.PlaySound(DeActivateSound);
		if ( Charge > 0 )
			return;
		Pawn(Owner).ClientMessage(ExpireMessage);
		Destroy();
	}
}

event Destroyed()
{
	if ( S != None )
		S.Destroy();
	Super.Destroyed();
}

function bool AtRange( Actor A, Actor B )
{
	local vector Dist2D;
	local float DistXY;
	local float DistZ;
	DistXY = VSize(A.Location*vect(1,1,0)-B.Location*vect(1,1,0));
	DistZ = Abs(A.Location.Z-B.Location.Z);
	if ( DistXY > (A.CollisionRadius+B.CollisionRadius) )
		return false;
	if ( DistZ > (A.CollisionHeight+B.CollisionHeight) )
		return false;
	return true;
}

defaultproperties
{
	bCanActivate=True
	ExpireMessage="The Deflector has drained."
	bAutoActivate=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You have the Deflector!"
	RespawnTime=60.000000
	PickupViewMesh=LodMesh'UnrealShare.SuperHealthMesh'
	Charge=180
	MaxDesireability=3.000000
	CollisionRadius=16.000000
	CollisionHeight=32.000000
	Mesh=LodMesh'UnrealShare.SuperHealthMesh'
	MultiSkins(0)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'
	bFixedRotationDir=True
	RotationRate=(Pitch=0,Yaw=32768,Roll=0)
}
