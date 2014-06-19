//=============================================================================
// MQSE.
//
// Quick (and dirty) Sprite Explosion.
//=============================================================================
class MQSE extends Actor;

#exec TEXTURE IMPORT NAME=qse_a00 FILE=Textures\qse_a00.pcx
#exec TEXTURE IMPORT NAME=qse_a01 FILE=Textures\qse_a01.pcx
#exec TEXTURE IMPORT NAME=qse_a02 FILE=Textures\qse_a02.pcx
#exec TEXTURE IMPORT NAME=qse_a03 FILE=Textures\qse_a03.pcx
#exec TEXTURE IMPORT NAME=qse_a04 FILE=Textures\qse_a04.pcx
#exec TEXTURE IMPORT NAME=qse_a05 FILE=Textures\qse_a05.pcx
#exec TEXTURE IMPORT NAME=qse_a06 FILE=Textures\qse_a06.pcx
#exec TEXTURE IMPORT NAME=qse_a07 FILE=Textures\qse_a07.pcx
#exec TEXTURE IMPORT NAME=qse_a08 FILE=Textures\qse_a08.pcx
#exec TEXTURE IMPORT NAME=qse_a09 FILE=Textures\qse_a09.pcx
#exec TEXTURE IMPORT NAME=qse_a10 FILE=Textures\qse_a10.pcx
#exec TEXTURE IMPORT NAME=qse_a11 FILE=Textures\qse_a11.pcx
#exec TEXTURE IMPORT NAME=qse_a12 FILE=Textures\qse_a12.pcx
#exec TEXTURE IMPORT NAME=qse_a13 FILE=Textures\qse_a13.pcx
#exec TEXTURE IMPORT NAME=qse_a14 FILE=Textures\qse_a14.pcx
#exec TEXTURE IMPORT NAME=qse_a15 FILE=Textures\qse_a15.pcx
#exec TEXTURE IMPORT NAME=qse_a16 FILE=Textures\qse_a16.pcx
#exec TEXTURE IMPORT NAME=qse_a17 FILE=Textures\qse_a17.pcx
#exec TEXTURE IMPORT NAME=qse_a18 FILE=Textures\qse_a18.pcx
#exec TEXTURE IMPORT NAME=qse_a19 FILE=Textures\qse_a19.pcx
#exec TEXTURE IMPORT NAME=qse_a20 FILE=Textures\qse_a20.pcx
#exec TEXTURE IMPORT NAME=qse_a21 FILE=Textures\qse_a21.pcx
#exec TEXTURE IMPORT NAME=qse_a22 FILE=Textures\qse_a22.pcx
#exec TEXTURE IMPORT NAME=qse_a23 FILE=Textures\qse_a23.pcx
#exec TEXTURE IMPORT NAME=qse_a24 FILE=Textures\qse_a24.pcx
#exec TEXTURE IMPORT NAME=qse_a25 FILE=Textures\qse_a25.pcx
#exec TEXTURE IMPORT NAME=qse_a26 FILE=Textures\qse_a26.pcx
#exec TEXTURE IMPORT NAME=qse_a27 FILE=Textures\qse_a27.pcx
#exec TEXTURE IMPORT NAME=qse_a28 FILE=Textures\qse_a28.pcx
#exec TEXTURE IMPORT NAME=qse_a29 FILE=Textures\qse_a29.pcx
#exec TEXTURE IMPORT NAME=qse_a30 FILE=Textures\qse_a30.pcx
#exec TEXTURE IMPORT NAME=qse_a31 FILE=Textures\qse_a31.pcx
#exec TEXTURE IMPORT NAME=qse_a32 FILE=Textures\qse_a32.pcx
#exec TEXTURE IMPORT NAME=qse_a33 FILE=Textures\qse_a33.pcx
#exec TEXTURE IMPORT NAME=qse_a34 FILE=Textures\qse_a34.pcx
#exec TEXTURE IMPORT NAME=qse_a35 FILE=Textures\qse_a35.pcx

// conf
var() Texture Frames[40];
var() int NumFrames;
var() float LifeRange[2];
var() Sound SpawnSound;

var float DLifeSpan, SLifeSpan, FrameRate, fcnt;
var bool initit;
var int FrameN;

event PostBeginPlay()
{
	SetTimer(0.01,false);
}

event Timer()
{
	SLifeSpan = RandRange(LifeRange[0],LifeRange[1]);
	DLifeSpan = SLifeSpan;
	Texture = Frames[0];
	FrameRate = SLifeSpan/NumFrames;
	FrameN = 0;
	initit = true;
}

event Tick( float DeltaTime )
{
	if ( !initit )
		return;
	DLifeSpan -= DeltaTime;
	LightBrightness = FClamp((DLifeSpan/SLifeSpan)*254,0,255);
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
}

Auto State Exploding
{

Begin:
	MakeNoise(2.5);
	PlaySound(SpawnSound,SLOT_None,2.0,,2500,0.8+FRand()*0.4);
	SpawnChunkies(15,220,650);
	for ( i=0; i<5; i++ )
	{
		Spawn(class'MQsm',,,Location+VRand()*FRand()*8);
		Spawn(class'MQsm',,,Location+VRand()*FRand()*8);
		SpawnChunkies(2,220,650);
		Sleep(0.1);
	}
}

function SpawnChunkies( int num, float XYSpeed, float ZSpeed )
{
	local int i;
	local MChip c;
	for ( i=0; i<num; i++ )
	{
		c = Spawn(class'MChip',,,Location+VRand(),RotRand());
		if ( c == None )
			continue;
		c.Velocity = VRand()*FRand()*XYSpeed;
		c.Velocity.Z = ZSpeed*FRand();
	}
}

defaultproperties
{
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'SWWMZ.qse_a01'
	Frames(0)=Texture'SWWMZ.qse_a00'
	Frames(1)=Texture'SWWMZ.qse_a01'
	Frames(2)=Texture'SWWMZ.qse_a02'
	Frames(3)=Texture'SWWMZ.qse_a03'
	Frames(4)=Texture'SWWMZ.qse_a04'
	Frames(5)=Texture'SWWMZ.qse_a05'
	Frames(6)=Texture'SWWMZ.qse_a06'
	Frames(7)=Texture'SWWMZ.qse_a07'
	Frames(8)=Texture'SWWMZ.qse_a08'
	Frames(9)=Texture'SWWMZ.qse_a09'
	Frames(10)=Texture'SWWMZ.qse_a10'
	Frames(11)=Texture'SWWMZ.qse_a11'
	Frames(12)=Texture'SWWMZ.qse_a12'
	Frames(13)=Texture'SWWMZ.qse_a13'
	Frames(14)=Texture'SWWMZ.qse_a14'
	Frames(15)=Texture'SWWMZ.qse_a15'
	Frames(16)=Texture'SWWMZ.qse_a16'
	Frames(17)=Texture'SWWMZ.qse_a17'
	Frames(18)=Texture'SWWMZ.qse_a18'
	Frames(19)=Texture'SWWMZ.qse_a19'
	Frames(20)=Texture'SWWMZ.qse_a20'
	Frames(21)=Texture'SWWMZ.qse_a21'
	Frames(22)=Texture'SWWMZ.qse_a22'
	Frames(23)=Texture'SWWMZ.qse_a23'
	Frames(24)=Texture'SWWMZ.qse_a24'
	Frames(25)=Texture'SWWMZ.qse_a25'
	Frames(26)=Texture'SWWMZ.qse_a26'
	Frames(27)=Texture'SWWMZ.qse_a27'
	Frames(28)=Texture'SWWMZ.qse_a28'
	Frames(29)=Texture'SWWMZ.qse_a29'
	Frames(30)=Texture'SWWMZ.qse_a30'
	Frames(31)=Texture'SWWMZ.qse_a31'
	Frames(32)=Texture'SWWMZ.qse_a32'
	Frames(33)=Texture'SWWMZ.qse_a33'
	Frames(34)=Texture'SWWMZ.qse_a34'
	Frames(35)=Texture'SWWMZ.qse_a35'
	NumFrames=36
	LifeRange(0)=1.85
	LifeRange(1)=2.25
	DrawScale=2.2
	CollisionRadius=0.0
	CollisionHeight=0.0
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=15
	LightSaturation=64
	LightRadius=12
}
