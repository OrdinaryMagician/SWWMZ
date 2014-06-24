//=============================================================================
// MQsm.
//
// Quick (and dirty) smoke.
//=============================================================================
class MQsm extends Actor;

// conf
var() float InitialSize, InitKick, DecelRate;
var() float GrowRange[2];
var() Texture Frames[20];
var() int NumFrames;
var() float LifeRange[2];
var() float Accels[2];

var float AccelZ, AccelAdd, DLifeSpan, SLifeSpan, FrameRate, fcnt;
var Vector RealVelocity, UpwardsVelocity;
var bool initit;
var int FrameN;

function PostBeginPlay()
{
	// delay startup a bit
	SetTimer(0.01,false);
}

function Timer()
{
	if ( Region.Zone.bWaterZone )
		Destroy();
	DrawScale = InitialSize;
	AccelAdd = Accels[1];
	SLifeSpan = RandRange(LifeRange[0],LifeRange[1]);
	DLifeSpan = SLifeSpan;
	Texture = Frames[0];
	Velocity += (InitKick*FRand())*VRand();
	RealVelocity = Velocity;
	FrameRate = SLifeSpan/NumFrames;
	FrameN = 0;
	initit = true;
	// Additions from QSM 1.4 (XGravity aka Znv_us)
	RotationRate.Roll = Rand(65536)-32768;
}

function AnimPass()
{
	FrameN++;
	if ( FrameN < NumFrames )
		Texture = Frames[FrameN];
}

function Tick( float DeltaTime )
{
	local Rotator FaceRot;	// That doesn't sound pretty
	local Vector ViewSpot;
	if ( !initit )
		return;
	AccelZ = FMin(Accels[0],AccelZ+AccelAdd*(0.8+0.4*FRand()*DeltaTime));
	UpwardsVelocity.Z = FMin(Accels[0],UpwardsVelocity.Z+AccelZ*(0.8+0.4
		*FRand())*DeltaTime);
	DLifeSpan -= DeltaTime;
	DrawScale = FMin(5.0,DrawScale+RandRange(GrowRange[0],GrowRange[1])
		*DeltaTime);
	RealVelocity *= DecelRate;
	Velocity = RealVelocity+UpwardsVelocity;
	fcnt += DeltaTime;
	if ( fcnt >= FrameRate )
	{
		fcnt = 0;
		AnimPass();
	}
	if ( DLifeSpan <= 0 )
		Destroy();
	// Additions from QSM 1.4 (XGravity aka Znv_us)
	ViewSpot = class'MUtil'.static.GetCameraSpot(self);
	FaceRot = Rotator(Location-ViewSpot);
	FaceRot.Roll = Rotation.Roll;
	SetRotation(FaceRot);
}

function HitWall( Vector HitNormal, Actor Wall )
{
	local Vector X,Y,Z;
	GetAxes(Rotator(Velocity),X,Y,Z);
	X = Y cross HitNormal;
	RealVelocity = VSize(RealVelocity)*X;
	UpwardsVelocity *= 0;
	if ( Wall != None )
		RealVelocity += 0.5*Wall.Velocity;
}

function ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
		Destroy();
	RealVelocity += NewZone.ZoneVelocity;
}

defaultproperties
{
	InitialSize=1.02
	GrowRange(0)=0.2335
	GrowRange(1)=0.4743
	InitKick=40.0
	Frames(0)=Texture'SWWMZ.qsm_00'
	Frames(1)=Texture'SWWMZ.qsm_01'
	Frames(2)=Texture'SWWMZ.qsm_02'
	Frames(3)=Texture'SWWMZ.qsm_03'
	Frames(4)=Texture'SWWMZ.qsm_04'
	Frames(5)=Texture'SWWMZ.qsm_05'
	Frames(6)=Texture'SWWMZ.qsm_06'
	Frames(7)=Texture'SWWMZ.qsm_07'
	Frames(8)=Texture'SWWMZ.qsm_08'
	Frames(9)=Texture'SWWMZ.qsm_09'
	Frames(10)=Texture'SWWMZ.qsm_10'
	Frames(11)=Texture'SWWMZ.qsm_11'
	Frames(12)=Texture'SWWMZ.qsm_12'
	Frames(13)=Texture'SWWMZ.qsm_13'
	Frames(14)=Texture'SWWMZ.qsm_14'
	Frames(15)=Texture'SWWMZ.qsm_15'
	Frames(16)=Texture'SWWMZ.qsm_16'
	Frames(17)=Texture'SWWMZ.qsm_17'
	Frames(18)=Texture'SWWMZ.qsm_18'
	Frames(19)=Texture'SWWMZ.qsm_19'
	NumFrames=20
	LifeRange(0)=0.95
	LifeRange(1)=1.59
	Accels(0)=68.0
	Accels(1)=33.0
	DecelRate=0.9945
	DrawType=DT_Mesh
	Mesh=Mesh'SWWMZ.qsm'
	Physics=PHYS_Projectile
	Style=STY_Translucent
	Texture=Texture'SWWMZ.qsm_00'
	CollisionRadius=8.0
	CollisionHeight=8.0
	bCollideWorld=True
	bBounce=True
	bFixedRotationDir=True
}
