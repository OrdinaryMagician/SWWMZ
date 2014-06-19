//=============================================================================
// MQsm.
//
// Quick (and dirty) smoke.
//=============================================================================
class MQsm extends Actor;

#exec MESH IMPORT MESH=qsm ANIVFILE=Models\Flat_a.3d DATAFILE=Models\Flat_d.3d
#exec MESH ORIGIN MESH=qsm YAW=0
#exec MESH SEQUENCE MESH=qsm SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=qsm MESH=qsm
#exec MESHMAP SCALE MESHMAP=qsm X=1.0 Y=1.0 Z=1.0

#exec TEXTURE IMPORT NAME=qsm_a00 FILE=Textures\qsm_a00.pcx
#exec TEXTURE IMPORT NAME=qsm_a01 FILE=Textures\qsm_a01.pcx
#exec TEXTURE IMPORT NAME=qsm_a02 FILE=Textures\qsm_a02.pcx
#exec TEXTURE IMPORT NAME=qsm_a03 FILE=Textures\qsm_a03.pcx
#exec TEXTURE IMPORT NAME=qsm_a04 FILE=Textures\qsm_a04.pcx
#exec TEXTURE IMPORT NAME=qsm_a05 FILE=Textures\qsm_a05.pcx
#exec TEXTURE IMPORT NAME=qsm_a06 FILE=Textures\qsm_a06.pcx
#exec TEXTURE IMPORT NAME=qsm_a07 FILE=Textures\qsm_a07.pcx
#exec TEXTURE IMPORT NAME=qsm_a08 FILE=Textures\qsm_a08.pcx
#exec TEXTURE IMPORT NAME=qsm_a09 FILE=Textures\qsm_a09.pcx
#exec TEXTURE IMPORT NAME=qsm_a10 FILE=Textures\qsm_a10.pcx
#exec TEXTURE IMPORT NAME=qsm_a11 FILE=Textures\qsm_a11.pcx
#exec TEXTURE IMPORT NAME=qsm_a12 FILE=Textures\qsm_a12.pcx
#exec TEXTURE IMPORT NAME=qsm_a13 FILE=Textures\qsm_a13.pcx
#exec TEXTURE IMPORT NAME=qsm_a14 FILE=Textures\qsm_a14.pcx
#exec TEXTURE IMPORT NAME=qsm_a15 FILE=Textures\qsm_a15.pcx
#exec TEXTURE IMPORT NAME=qsm_a16 FILE=Textures\qsm_a16.pcx
#exec TEXTURE IMPORT NAME=qsm_a17 FILE=Textures\qsm_a17.pcx
#exec TEXTURE IMPORT NAME=qsm_a18 FILE=Textures\qsm_a18.pcx
#exec TEXTURE IMPORT NAME=qsm_a19 FILE=Textures\qsm_a19.pcx

// conf
var() float InitialSize, InitKick, InitGlow, DecelRate;
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
	SLifeSpan = RandRange(LifeRange[0],LifeRange[1];
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

function Tick( float DeltaTime )
{
	local Rotator FaceRot;	// That doesn't sound pretty
	local Vector ViewSpot;
	if ( !initit )
		return;
	AccelZ = FMin(Accels[0],AccelZ+AccelAdd*(0.8+0.4*FRand()*DeltaTime);
	UpwardsVelocity.Z = FMin(Accels[0],UpwardsVelocity.Z+AccelZ*(0.8+0.4
		*FRand())*DeltaTime);
	ScaleGlow = (DLifeSpan/SLifeSpan)*InitGlow;
	DLifeSpan -= DeltaTime;
	DrawScale = FMin(5.0,DrawScale+RandRange(GrowRange[0],GrowRange[1])
		*DeltaTime);
	RealVelocity *= DecelRate;
	Velocity = RealVelocity+UpwardsVelocity;
	fcnt += DeltaTime;
	if ( fcnt >= FrameRate )
	{
		fcnt = 0;
		FrameN++;
		if ( FrameN < NumFrames )
			Texture = Frames[FrameN];
	}
	if ( DLifeSpan <= 0 )
		Destroy();
	// Additions from QSM 1.4 (XGravity aka Znv_us)
	ViewSpot = class'MUtil'.static.GetCameraSpot(self);
	FaceRot = Rotator(Location-ViewSpot);
	FaceRot.Roll = Rotation.Roll;
	SetRotation(temprot);
}

function HitWall( Vector HitNormal, Actor Wall )
{
	RealVelocity *= 0;
	UpwardsVelocity *= 0;
	if ( Wall != None )
		RealVelocity += 0.5*Wall.Velocity;
	if ( FRand() < 0.2 )
		Destroy();
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
	InitKick=24.0
	InitGlow=2.2
	Frames(0)=Texture'SWWMZ.qsm_a00'
	Frames(1)=Texture'SWWMZ.qsm_a01'
	Frames(2)=Texture'SWWMZ.qsm_a02'
	Frames(3)=Texture'SWWMZ.qsm_a03'
	Frames(4)=Texture'SWWMZ.qsm_a04'
	Frames(5)=Texture'SWWMZ.qsm_a05'
	Frames(6)=Texture'SWWMZ.qsm_a06'
	Frames(7)=Texture'SWWMZ.qsm_a07'
	Frames(8)=Texture'SWWMZ.qsm_a08'
	Frames(9)=Texture'SWWMZ.qsm_a09'
	Frames(10)=Texture'SWWMZ.qsm_a10'
	Frames(11)=Texture'SWWMZ.qsm_a11'
	Frames(12)=Texture'SWWMZ.qsm_a12'
	Frames(13)=Texture'SWWMZ.qsm_a13'
	Frames(14)=Texture'SWWMZ.qsm_a14'
	Frames(15)=Texture'SWWMZ.qsm_a15'
	Frames(16)=Texture'SWWMZ.qsm_a16'
	Frames(17)=Texture'SWWMZ.qsm_a17'
	Frames(18)=Texture'SWWMZ.qsm_a18'
	Frames(19)=Texture'SWWMZ.qsm_a19'
	NumFrames=20
	LifeRange(0)=0.95
	LifeRange(1)=1.59
	Accels(0)=68.0
	Accels(1)=33.0
	DecelRate=0.9835
	DrawType=DT_Mesh
	Mesh=Mesh'SWWMZ.qsm'
	Physics=PHYS_Projectile
	Style=STY_Translucent
	Texture=Texture'SWWMZ.qsm_a00'
	CollisionRadius=8.0
	CollisionHeight=8.0
	bCollideWorld=True
	bBounce=True
}
