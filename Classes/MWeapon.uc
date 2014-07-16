//=============================================================================
// MWeapon.
//
// Base SWWMZ Weapon class.
// Major parts of code based on previous ZWeapon work.
//=============================================================================
class MWeapon extends TournamentWeapon abstract;

// Stuff
var() bool IsSuperWeapon;

// Multiskinning
var(Display) Texture FirstMultiSkins[8];
var(Display) Texture ThirdMultiSkins[8];

// Glowmap
var(Overlay) Texture GlowSkins[8];
var(Overlay) Texture FirstGlowSkins[8];
var(Overlay) Texture ThirdGlowSkins[8];
var MLayer Overlayer;

// Weighting
var(Weight) bool SlowDown, AddMass, ForceWalk;
var(Weight) float SpeedModifier, JumpModifier;

// Inertia (yay for trying to imitate modern games)
struct fRotator
{
	var() float Pitch, Yaw, Roll;
};
var fRotator frAdditional, frRate;
var Rotator PreviousViewRotation, DrawnRot;
var Vector vAddRate, vAdditional, PreviousVelocity, ForExt, AddVO;
var float passedtim, curdelta, ICur, IPhase, IPhaseX, IPhaseY, ISizX, ISizY;
var(Inertia) float HDampening, VDampening, Restitution, OffsetFactor, XDamp,
	YDamp, ZDamp, MinY, MaxY, MinP, MaxP, WavyFactor;
var bool FirstSkip;

// Knockback/Recoil
var(Recoil) Vector NormalRecoil, AltRecoil;
var(Recoil) float VisualRecoilR, VisualRecoilV;
var(Recoil) bool ViewRotationRecoil;
var Vector vPVRec;
var fRotator frPVRec;
var(Recoil) float RecoilFuzz;

// Volatility variables
var(Volatility) int Health;
var(Volatility) Sound HitSound[5];
var MWeaponBlock Hitbox;
var bool WasOwned;
var Pawn OldOwner;

// New weapon bobbing variables
var float pase, psca, velsc;

// These here are "floatrot" operators and functions needed for some stuff
static final function fRotator frot( float Pitch, float Yaw, float Roll )
{
	local fRotator outs;
	outs.Pitch = Pitch;
	outs.Yaw = Yaw;
	outs.Roll = Roll;
	return outs;
}

static final function Rotator frot2rot( fRotator in )
{
	local Rotator outs;
	outs.Pitch = int(in.Pitch);
	outs.Yaw = int(in.Yaw);
	outs.Roll = int(in.Roll);
	return outs;
}

static final function fRotator rot2frot( Rotator in )
{
	local fRotator outs;
	outs.Pitch = float(in.Pitch);
	outs.Yaw = float(in.Yaw);
	outs.Roll = float(in.Roll);
	return outs;
}


static final operator(16) fRotator * ( fRotator A, fRotator B )
{
	local fRotator otter;
	otter = B;
	otter.Pitch *= A.Pitch;
	otter.Yaw *= A.Yaw;
	otter.Roll *= A.Roll;
	return otter;
}

static final operator(16) fRotator * ( fRotator A, coerce float B )
{
	local fRotator otter;
	otter = A;
	otter.Pitch *= B;
	otter.Yaw *= B;
	otter.Roll *= B;
	return otter;
}

static final operator(34) fRotator *= ( out fRotator A, coerce float B )
{
	A.Pitch *= B;
	A.Yaw *= B;
	A.Roll *= B;
	return A;
}

static final operator(34) fRotator -= ( out fRotator A, fRotator B )
{
	A.Pitch -= B.Pitch;
	A.Yaw -= B.Yaw;
	A.Roll -= B.Roll;
	return A;
}

static final operator(34) fRotator += ( out fRotator A, fRotator B )
{
	A.Pitch += B.Pitch;
	A.Yaw += B.Yaw;
	A.Roll += B.Roll;
	return A;
}

event TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
	Vector Momentum, Name DamageType )
{
	local MDamageCounter DC;
	if ( HitBox != None )
	{
		DC = Spawn(Class'MDamageCounter',HitBox);
		DC.Factor = -Damage;
		if ( HitLocation == vect(0,0,0) )
			DC.RealHitLocation = HitBox.Location;
		else
			DC.RealHitLocation = HitLocation-HitBox.Location;
	}
	else
	{
		DC = Spawn(Class'MDamageCounter',self);
		DC.Factor = -Damage;
		if ( HitLocation == vect(0,0,0) )
			DC.RealHitLocation = Location;
		else
			DC.RealHitLocation = HitLocation-Location;
	}
	if ( HitLocation == vect(0,0,0) )
	Health -= Damage;
	ForExt += Momentum;
	PlaySound(HitSound[Rand(3)],SLOT_Interact,1.5,,,0.8+FRand()*0.4);
	Spawn(class'MQsm',,, HitLocation, Rotator(HitLocation-Location));
	Spawn(class'MSparks',,, HitLocation, Rotator(HitLocation-Location));
	if ( Health <= 0 )
	{
		Instigator = InstigatedBy;
		VolatileFunction();
	}
}

Auto State Pickup
{
	function BeginState()
	{
		Super.BeginState();
		if ( IsSuperWeapon )
			bWeaponStay = False; // Always
		SetPickupSkins();
	}

	function VolatileFunction()
	{
		WasOwned = False;
		OldOwner = None;
		GotoState('VolatileWeapon');
	}
}

State VolatileWeapon
{
	function Touch( Actor Other )
	{
		// Ignore
	}

	function BeginState()
	{
		bHidden = True;
	}

	function EndExplosion()
	{
		if ( !WasOwned && (RespawnTime > 0) )
			GotoState('Sleeping');
		else
			Destroy();
	}

Begin:
	EndExplosion();
}

function SetOwnerDisplay()
{
	Super.SetOwnerDisplay();
	SetThirdSkins();
}

function BecomeItem()
{
	Super.BecomeItem();
	SetThirdSkins();
}

function BecomePickup()
{
	Super.BecomePickup();
	SetPickupSkins();
}

function Kickback( bool IsAlt )
{
	local Vector X,Y,Z, outf;
	GetAxes(DrawnRot,X,Y,Z);
	if ( Pawn(Owner).IsA('PlayerPawn')
		&& (PlayerPawn(Owner).Handedness!=2) )
		Y *= PlayerPawn(Owner).Handedness;
	else
		Y *= 0;
	if ( IsAlt )
		outf = X*AltRecoil.X+Y*AltRecoil.Y+Z*AltRecoil.Z+VRand()
			*FRand()*RecoilFuzz;
	else
		outf = X*NormalRecoil.X+Y*NormalRecoil.Y+Z*NormalRecoil.Z
			+VRand()*FRand()*RecoilFuzz;
	if ( ViewRotationRecoil )
	{
		vAdditional += outf*VisualRecoilV*0.005;
		ForExt += outf*VisualRecoilR;
		vPVRec += vAdditional;
	}
	Pawn(Owner).Falling();
	Owner.Velocity += outf/(Owner.Mass/100);
}

function SetOverlaySkins( int view )
{
	local int i;
	if ( view == 0 )
	{
		for ( i=0; i<8; i++ )
		{
			if ( GlowSkins[i]!=None )
			{
				Overlayer.Multiskins[i] = GlowSkins[i];
			}
			else
			{
				Overlayer.Multiskins[i] =
					Texture'SWWMZ.Invisible';
			}
		}
	}
	else
	{
		for ( i=0; i<8; i++ )
		{
			if ( ThirdGlowSkins[i]!=None )
			{
				Overlayer.Multiskins[i] = ThirdGlowSkins[i];
			}
			else
			{
				Overlayer.Multiskins[i] =
					Texture'SWWMZ.Invisible';
			}
		}
	}
}

event PostBeginPlay()
{
	// safeguard because nobody's perfect
	Spawn(class'MCharaKeeper');
	Super.PostBeginPlay();
}

function ApplyChanges( Pawn P )
{
	if ( AddMass )
	{
		P.Mass += Mass;
		P.Buoyancy += Buoyancy;
	}
	if ( SlowDown )
	{
		P.GroundSpeed *= SpeedModifier;
		P.JumpZ *= JumpModifier;
		P.WaterSpeed *= SpeedModifier;
	}
	if ( ForceWalk )
		P.bRun = 1;
}

function ResetChanges( Pawn P )
{
	P.GroundSpeed = P.Default.GroundSpeed;
	P.Mass = P.Default.Mass;
	P.Buoyancy = P.Default.Buoyancy;
	P.JumpZ = P.Default.JumpZ*Level.Game.PlayerJumpZScaling();
	P.WaterSpeed = P.Default.WaterSpeed;
	if ( ForceWalk )
		P.bRun = 0;
}

function PlaySelect()
{
	ApplyChanges(Pawn(Owner));
	Super.PlaySelect();
}

function TweenDown()
{
	ResetChanges(Pawn(Owner));
	Super.TweenDown();
}

// yay for new bobbing!
function Vector NewCalcDrawOffset()
{
	local Vector Drafset, SilentBob, X,Y,Z;
	local Pawn P;
	P = Pawn(Owner);
	Drafset = ((0.9/P.FOVAngle*PlayerViewOffset)>>P.ViewRotation);
	Drafset += P.EyeHeight*vect(0,0,1);
	GetAxes(P.ViewRotation,X,Y,Z);
	// Yes I don't remember how I came up with this
	SilentBob = 0.3*psca*(sin(pase)*Y*1.24*Abs(1-BobDamping)*FMin(40,
		velsc*0.08)+(abs(cos(pase))-1)*Z*0.87*Abs(1-BobDamping)
		*FMin(12,velsc*0.02)+(abs(cos(pase))-1)*X*0.68
		*Abs(1-BobDamping)*FMin(30,velsc*0.08));
	SilentBob += P.WalkBob;
	Drafset += SilentBob;
	return Drafset;
}

// So here on Tick() I have a lot of stuff going on, and I can't really
// remember how it all works together
function Tick( float deltatime )
{
	local Vector X,Y,Z, XV,YV,ZV;
	local float SX,SY,SZ, IResX, IResY;
	local int iSide;
	passedtim += deltatime;
	curdelta = deltatime;
	Super.Tick(deltatime);
	bProjTarget = (IsInState('Pickup') && !bHidden);
	if ( (HitBox == None) && (Pawn(Owner) != None)
		&& (Pawn(Owner).Weapon == self) )
	{
		HitBox = Spawn(class'MWeaponBlock');
		HitBox.Setup(self,Pawn(Owner));
	}
	if ( (HitBox != None) && (Owner == None) )
		HitBox.Destroy();
	if ( (Pawn(Owner) == None) || (Pawn(Owner).Weapon != self) )
		return;
	if ( Owner.IsA('PlayerPawn') && (PlayerPawn(Owner).Handedness!=2) )
		iSide = PlayerPawn(Owner).Handedness;
	else
		iSide = 0;
	// Update bobbing parameters
	// psca -> based on time moving, affects amplitude
	// pase -> phase, influence from both time and velocity
	// velsc -> based on overall velocity, affects frequency
	if ( (VSize(Owner.Velocity) < 0.1) || (Owner.Physics != PHYS_Walking) )
	{
		if ( psca > 0.0 )
		{
			psca -= 0.8*deltatime;
			pase += deltatime*velsc*0.026*psca;
		}
		else
		{
			psca = 0.0;
			pase = 0.0;
		}
	}
	else
	{
		psca = FMin(1.0,psca+1.1*deltatime);
		pase += deltatime*velsc*0.026;
	}
	velsc = velsc-(velsc+VSize(Owner.Velocity))*deltatime*4;
	// Inertia fuzziness (wavy motion)
	if ( VSize(Owner.Velocity) < 40 )
		ICur = FMax(WavyFactor*0.2,ICur-WavyFactor*5.6*deltatime);
	else if ( ICur < (WavyFactor*8) )
		ICur = FMin(WavyFactor*8,ICur+WavyFactor*3.8*(0.01
			*VSize(Owner.Velocity))*deltatime);
	IPhase += deltatime*FRand()*5.0;
	IPhaseX += deltatime*FRand()*1.2;
	IPhaseY += deltatime*FRand()*2.3;
	ISizX = sin(IPhaseX)*0.2;
	ISizY = cos(IPhasey)*0.2;
	IResX = sin(IPhase)*abs(ISizX)*ICur;
	IResY = cos(IPhase)*abs(ISizY)*ICur;
	AddVO.Y = IResX*0.035;
	AddVO.Z = IResY*0.035;
	if ( ForceWalk )
		Pawn(Owner).bRun = 1;
	// First step just ignores everything, only gather parameters
	if( !FirstSkip )
	{
		PreviousViewRotation = Pawn(Owner).ViewRotation;
		PreviousVelocity = Owner.Velocity;
		frRate *= 0;
		frAdditional *= 0;
		vAddRate *= 0;
		vAdditional *= 0;
		FirstSkip = true;
		return;
	}
	// inertia based on velocity
	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
	XV = Owner.Velocity*X*(1/XDamp);
	YV = Owner.Velocity*Y*(1/YDamp);
	ZV = Owner.Velocity*Z*(1/ZDamp);
	SX = Normal(Owner.Velocity) dot X;
	SY = Normal(Owner.Velocity) dot Y;
	SZ = Normal(Owner.Velocity) dot Z;
	frAdditional -= frot(VSize(ZV)*SZ,VSize(XV)*SX*iSide+VSize(YV)*SY,0)
		*deltatime*150;
	// recoil (rotation)
	if ( VSize(ForExt) > 0 )
	{
		XV = ForExt*X*(1/XDamp);
		YV = ForExt*Y*(1/YDamp);
		ZV = ForExt*Z*(1/ZDamp);
		SX = Normal(ForExt) dot X;
		SY = Normal(ForExt) dot Y;
		SZ = Normal(ForExt) dot Z;
		frAdditional += frot(VSize(ZV)*SZ,VSize(XV)*SX*iSide+VSize(YV)
			*SY,0)*deltatime*900;
		XV /= (1/XDamp);
		YV /= (1/YDamp);
		ZV /= (1/ZDamp);
		frPVRec += frot(VSize(ZV)*SZ,VSize(XV)*SX*iSide+VSize(YV)*SY,0)
			*deltatime*5;
		ForExt *= 0;
	}
	// recoil (location)
	if ( VSize(vPVRec) > 0 )
	{
		XV = vPVRec*X;
		YV = vPVRec*Y;
		ZV = vPVRec*Z;
		SX = Normal(vPVRec) dot X;
		SY = Normal(vPVRec) dot Y;
		SZ = Normal(vPVRec) dot Z;
		frPVRec += frot(VSize(ZV)*SZ,VSize(XV)*SX*iSide+VSize(YV)*SY,0)
			*deltatime*8;
		vPVRec *= 0;
	}
	// Transfer to ViewRotation
	if ( ViewRotationRecoil )
	{
		PlayerPawn(Owner).ViewRotation.Yaw += frPVRec.Yaw;
		PlayerPawn(Owner).ViewRotation.Pitch += frPVRec.Pitch;
	}
	// capping
	frAdditional = frot(FClamp(frAdditional.Pitch,MinP,MaxP),
		FClamp(frAdditional.Yaw,MinY,MaxY),0);
	// dampening
	frPVRec *= (1-FMin(1,Restitution*10*deltatime));
	// apply everything
	frRate = rot2frot(Normalize(Normalize(Pawn(Owner).ViewRotation)
		-Normalize(PreviousViewRotation)));
	frAdditional += frot(-AddVO.Z,AddVO.Y,0)*130000*deltatime;
	frAdditional.Roll = 0;
	vAddRate = (PreviousVelocity-Owner.Velocity);
	vAdditional += vAddRate*deltatime;
	frAdditional *= (1-FMin(1,Restitution*deltatime));
	vAdditional *= (1-FMin(1,Restitution*deltatime));
	PreviousViewRotation = Pawn(Owner).ViewRotation;
	PreviousVelocity = Owner.Velocity;
}

function RenderOverlays( Canvas Canvas )
{
	local Rotator NewRot;
	local bool PlayerOwner;
	local int Hand;
	local PlayerPawn PO;
	local Vector X,Y,Z;
	PO = PlayerPawn(Owner);
	if ( ((PO != None) && (PO.ViewTarget == None) && !PO.bBehindView)
		|| ((Owner != None) && IsPlayerViewTarget(Owner)) )
		SetViewSkins();
	if ( bHideWeapon || (Owner == None) )
		return;
	if( PO != None )
	{
		if ( PO.Handedness == 2 )
		{
			bHideWeapon = true;
			return;
		}
		Hand = PO.Handedness;
	}
	SetLocation(Owner.Location+NewCalcDrawOffset());
	NewRot = Pawn(Owner).ViewRotation;
	if ( Hand == 0 )
		newRot.Roll = -2*Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll*Hand;
	newRot += frot2rot(frAdditional*frot(1-FMin(1,VDampening),1-FMin(1,
		HDampening),0));
	SetRotation(newRot);
	DrawnRot = newRot;
	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
	SetLocation(Location+vAdditional*OffsetFactor+AddVO.Y*Y+AddVO.Z*Z);
	Canvas.DrawActor(self,false);
	RenderLayers(Canvas);
	SetThirdSkins();
}

// This renders the glowmap in first person mode
function RenderLayers( Canvas Canvas )
{
	local ERenderStyle OlStyle;
	local float OlScale, OlGlow;
	local bool OlUnlit, OlEnviroMap;
	local byte OlAmbGlow;
	local int i;
	OlStyle = Style;
	OlScale = DrawScale;
	OlGlow = ScaleGlow;
	OlUnlit = bUnlit;
	OlEnviroMap = bMeshEnviroMap;
	OlAmbGlow = AmbientGlow;
	DrawScale = OlScale+0.004;
	ScaleGlow = 1.0;
	bMeshEnviroMap = false;
	AmbientGlow = 255;
	Style = STY_Translucent;
	bUnlit = true;
	for ( i=0; i<8; i++ )
	{
		if ( FirstGlowSkins[i]!=None )
			MultiSkins[i] = FirstGlowSkins[i];
		else
			MultiSkins[i] = Texture'SWWMZ.Invisible';
	}
	Canvas.DrawActor(self,false);
	DrawScale = OlScale;
	ScaleGlow = OlGlow;
	AmbientGlow = OlAmbGlow;
	Style = OlStyle;
	bUnlit = OlUnlit;
	bMeshEnviroMap = OlEnviroMap;
}

// Check if a local player is viewing through an actor in first person mode
function bool IsPlayerViewTarget( Actor A )
{
	local Pawn P;
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.IsA('PlayerPawn') && (PlayerPawn(P).ViewTarget == A)
			&& !PlayerPawn(P).bBehindView )
			return true;
	return false;
}

function SetPickupSkins()
{
	local int i;
	for ( i=0; i<8; i++ )
		MultiSkins[i] = Default.MultiSkins[i];
	SetOverlaySkins(0);
}

function SetViewSkins()
{
	local int i;
	for ( i=0; i<8; i++ )
		MultiSkins[i] = FirstMultiSkins[i];
}

function SetThirdSkins()
{
	local int i;
	for ( i=0; i<8; i++ )
		MultiSkins[i] = ThirdMultiSkins[i];
	SetOverlaySkins(2);
}

// A very general projectile fire
function Projectile FireBlast( bool IsAlt )
{
	local Vector X,Y,Z, FireLoc;
	local Rotator AdjustedAim;
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(DrawnRot,X,Y,Z);
	FireLoc = Owner.Location+NewCalcDrawOffset()+vAdditional*OffsetFactor
		+AddVO.Y*Y+AddVO.Z*Z+FireOffset.X*X+FireOffset.Y*Y
		+FireOffset.Z*Z;
	if ( IsAlt )
	{
		AdjustedAim = Pawn(Owner).AdjustAim(AltProjectileClass.Default
			.Speed,FireLoc,AimError,True,bWarnTarget);
		return Spawn(AltProjectileClass,,,FireLoc,AdjustedAim
			+frot2rot(frAdditional*frot(1-FMin(1,VDampening),1
			-FMin(1,HDampening),0)));
	}
	else
	{
		AdjustedAim = Pawn(Owner).AdjustAim(ProjectileClass.Default
			.Speed,FireLoc,AimError,True,bWarnTarget);
		return Spawn(ProjectileClass,,,FireLoc,AdjustedAim
			+frot2rot(frAdditional*frot(1-FMin(1,VDampening),1
			-FMin(1,HDampening),0)));
	}
}

function VolatileFunction()
{
	if ( Pawn(Owner) != None )
		Pawn(Owner).DeleteInventory(self);
	ResetChanges(Pawn(Owner));
	WasOwned = True;
	OldOwner = Pawn(Owner);
	GotoState('VolatileWeapon');
}

function DropFrom( Vector StartLocation )
{
	if ( !SetLocation(StartLocation) )
		return;
	ResetChanges(Pawn(Owner));
	Super.DropFrom(StartLocation);
}

defaultproperties
{
	SpeedModifier=1.0
	JumpModifier=1.0
	HDampening=0.91
	VDampening=0.89
	Restitution=1.9
	OffsetFactor=0.036
	XDamp=1.4
	YDamp=0.9
	ZDamp=1.8
	MinY=-40000.0
	MaxY=40000.0
	MinP=-20000.0
	MaxP=70000.0
	WavyFactor=0.7
	Health=100
	HitSound(0)=Sound'SWWMZ.WeaponHit1'
	HitSound(1)=Sound'SWWMZ.WeaponHit2'
	HitSound(2)=Sound'SWWMZ.WeaponHit3'
	HitSound(3)=Sound'SWWMZ.WeaponHit4'
	HitSound(4)=Sound'SWWMZ.WeaponHit5'
	bNoSmooth=False
}
