//=============================================================================
// MDust.
//
// Dust particles.
//=============================================================================
class MDust extends Actor;

var() float InitKick, LifeTime, StartVel, RandVelAdd, StartSize, RandSizeAdd,
	Deviation, LifeTimeFuzz, Decel, GrowRate, MoveFuzz, FrameRate;
var() Texture Frames[20];
var float MySize, DLifeTime, fcnt;
var int FrameN;

event PostBeginPlay()
{
	Velocity = Vector(Rotation)*InitKick;
	Velocity += VRand()*RandVelAdd*FRand()+VRand()*StartVel;
	MySize = FRand()*RandSizeAdd+StartSize;
	DrawScale = MySize;
	LifeTime *= LifeTimeFuzz+FRand()*(LifeTimeFuzz*2);
	DLifeTime = LifeTime;
	FrameN = 0;
	FrameRate = DLifeTime/20;
	if ( Region.Zone.bWaterZone )
		Destroy();
	RotationRate.Roll = Rand(16384)-8192;
}

function AnimPass()
{
	FrameN++;
	if ( FrameN < 20 )
		Texture = Frames[FrameN];
}

event Tick( float deltatime )
{
	local float MagnitudeVel;
	local Rotator FaceRot;
	local Vector NewMoveDir, NewMoveLoc, ViewSpot;
	NewMoveDir = Normal(Normal(Velocity)+MoveFuzz*VRand());
	if ( (NewMoveDir dot Normal(Velocity)) < 0 )
		NewMoveDir *= -0.5;
	NewMoveLoc = Location+Normal(NewMoveDir);
	MagnitudeVel = VSize(Velocity);
	Velocity = Decel*MagnitudeVel*Normal(Normal(NewMoveLoc-Location)
		*MagnitudeVel*deltatime*Deviation+Velocity);
	LifeTime -= deltatime;
	DrawScale += GrowRate*deltatime;
	fcnt += deltatime;
	if ( fcnt >= FrameRate )
	{
		fcnt = 0.0;
		AnimPass();
	}
	if ( LifeTime <= 0.0 )
		Destroy();
	ViewSpot = Class'MUtil'.static.GetCameraSpot(self);
	FaceRot = Rotator(Location-ViewSpot);
	FaceRot.Roll = Rotation.Roll;
	SetRotation(FaceRot);
}

event ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
		Destroy();
	Velocity += NewZone.ZoneVelocity;
}

event HitWall( Vector HitNormal, Actor Wall )
{
	local Vector X,Y,Z;
	GetAxes(Rotator(Velocity),X,Y,Z);
	X = Y cross HitNormal;
	Velocity = VSize(Velocity)*X;
	if ( Wall != None )
		Velocity += 0.5*Wall.Velocity;
}

defaultproperties
{
	MoveFuzz=0.37
	GrowRate=0.84
	Decel=0.9975
	InitKick=80.0
	LifeTime=5.0
	StartVel=15.0
	RandVelAdd=20.0
	StartSize=0.6
	RandSizeAdd=1.2
	Frames(0)=Texture'SWWMZ.dust_00'
	Frames(1)=Texture'SWWMZ.dust_01'
	Frames(2)=Texture'SWWMZ.dust_02'
	Frames(3)=Texture'SWWMZ.dust_03'
	Frames(4)=Texture'SWWMZ.dust_04'
	Frames(5)=Texture'SWWMZ.dust_05'
	Frames(6)=Texture'SWWMZ.dust_06'
	Frames(7)=Texture'SWWMZ.dust_07'
	Frames(8)=Texture'SWWMZ.dust_08'
	Frames(9)=Texture'SWWMZ.dust_09'
	Frames(10)=Texture'SWWMZ.dust_10'
	Frames(11)=Texture'SWWMZ.dust_11'
	Frames(12)=Texture'SWWMZ.dust_12'
	Frames(13)=Texture'SWWMZ.dust_13'
	Frames(14)=Texture'SWWMZ.dust_14'
	Frames(15)=Texture'SWWMZ.dust_15'
	Frames(16)=Texture'SWWMZ.dust_16'
	Frames(17)=Texture'SWWMZ.dust_17'
	Frames(18)=Texture'SWWMZ.dust_18'
	Frames(19)=Texture'SWWMZ.dust_19'
	Deviation=0.5
	LifeTimeFuzz=0.4
	DrawType=DT_Mesh
	Mesh=Mesh'SWWMZ.qsm'
	Physics=PHYS_Projectile
	Style=STY_Translucent
	Texture=Texture'SWWMZ.dust_00'
	CollisionRadius=8.0
	CollisionHeight=8.0
	bCollideWorld=True
	bBounce=True
	bFixedRotationDir=True
}
