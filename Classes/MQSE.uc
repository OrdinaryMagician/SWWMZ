//=============================================================================
// MQSE.
//
// Quick (and dirty) Sprite Explosion.
//=============================================================================
class MQSE extends Actor;

// conf
var() Texture Frames[20];
var() int NumFrames;
var() float LifeRange[2];
var() Sound SpawnSound;

var float DLifeSpan, SLifeSpan, FrameRate, fcnt;
var bool initit;
var int FrameN, i, j, n;

event PostBeginPlay()
{
	SLifeSpan = RandRange(LifeRange[0],LifeRange[1]);
	DLifeSpan = SLifeSpan;
	FrameRate = SLifeSpan/NumFrames;
	Texture = Frames[0];
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
	SpawnChunkies(6,820,350);
	for ( i=0; i<5; i++ )
	{
		n = 10;
		if ( !Level.bDropDetail )
			n *= 2;
		for ( j=0; j<n; j++ )
			Spawn(class'MDust',,,Location+VRand()*FRand()*32,
				RotRand());
		SpawnChunkies(2,820,350);
		Sleep(0.05);
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
	SpawnSound=Sound'SWWMZ.QuadShotExpl'
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'SWWMZ.qse_00'
	Frames(0)=Texture'SWWMZ.qse_00'
	Frames(1)=Texture'SWWMZ.qse_01'
	Frames(2)=Texture'SWWMZ.qse_02'
	Frames(3)=Texture'SWWMZ.qse_03'
	Frames(4)=Texture'SWWMZ.qse_04'
	Frames(5)=Texture'SWWMZ.qse_05'
	Frames(6)=Texture'SWWMZ.qse_06'
	Frames(7)=Texture'SWWMZ.qse_07'
	Frames(8)=Texture'SWWMZ.qse_08'
	Frames(9)=Texture'SWWMZ.qse_09'
	Frames(10)=Texture'SWWMZ.qse_10'
	Frames(11)=Texture'SWWMZ.qse_11'
	Frames(12)=Texture'SWWMZ.qse_12'
	Frames(13)=Texture'SWWMZ.qse_13'
	Frames(14)=Texture'SWWMZ.qse_14'
	Frames(15)=Texture'SWWMZ.qse_15'
	Frames(16)=Texture'SWWMZ.qse_16'
	Frames(17)=Texture'SWWMZ.qse_17'
	Frames(18)=Texture'SWWMZ.qse_18'
	Frames(19)=Texture'SWWMZ.qse_19'
	NumFrames=20
	LifeRange(0)=0.45
	LifeRange(1)=0.75
	DrawScale=1.85
	CollisionRadius=0.0
	CollisionHeight=0.0
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=15
	LightSaturation=64
	LightRadius=12
}
