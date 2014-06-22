//=============================================================================
// MWeapon.
//
// Base SWWMZ Weapon class.
// Major parts of code based on previous ZWeapon work.
//=============================================================================
class MWeapon extends TournamentWeapon abstract;

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
}
var fRotator frAdditional, frRate;
var Rotator PreviousViewRotation, DrawnRot;
var Vector vAddRate, vAdditional, PreviousVelocity, ForExt;
var float passedtim, curdelta, ICur, IPhase, IPhaseX, IPhaseY, ISizX, ISizY;
var(Inertia) float HDampening, VDampening, Restitution, OffsetFactor, XDamp,
	YDamp, ZDamp, WavyFactor;
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
var ZWeaponBlock Hitbox;
var bool WasOwned;

// New weapon bobbing variables
float pase, psca, velsc;

Auto State Pickup
{
	function BeginState()
	{
		Super.BeginState();
		SetPickupSkins();
	}
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
	if ( Pawn(Owner).IsA('PlayerPawn') )
		Y *= (PlayerPawn(Owner).Handedness==2)?0
			:PlayerPawn(Owner).Handedness;
	else
		Y *= 0;
	if ( IsAlt )
		outf = X*AltRecoil.X+Y*AltRecoil.Y+Z*AltRecoilZ+VRand()
			*FRand()*RecoilFuzz;
	else
		outf = X*NormalRecoil.X+Y*NormalRecoil.Y+Z*NormalRecoilZ
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
			Overlayer.Multiskins[i] = (GlowSkins[i]!=None)
				?GlowSkins[i]:Texture'SWWMZ.Invisible';
		}
	}
	else if ( view == 1 )
	{
		for ( i=0; i<8; i++ )
		{
			Overlayer.Multiskins[i] = (FirstGlowSkins[i]!=None)
				?FirstGlowSkins[i]:Texture'SWWMZ.Invisible';
		}
	}
	else
	{
		for ( i=0; i<8; i++ )
		{
			Overlayer.Multiskins[i] = (ThirdGlowSkins[i]!=None)
				?ThirdGlowSkins[i]:Texture'SWWMZ.Invisible';
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
	P.JumpZ = P.Default.JumpZ;
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
	Drafset += PawnOwner.EyeHeight*vect(0,0,1);
	GetAxes(P.ViewRotation,X,Y,Z);
	SilentBob = 0.3*psca*(sin(pase)*Y*1.24*Abs(1-BobDamping)*FMin(40,
		velsc*0.08)+(abs(cos(pase))-1)*Z*0.87*Abs(1-BobDamping)
		*FMin(12,velsc*0.02)+(abs(cos(pase))-1)*X*0.68
		*Abs(1-BobDamping)*FMin(30,velsc*0.08));
	SilentBob += P.WalkBob;
	Drafset += SilentBob;
	return Drafset;
}

function Tick( float deltatime )
{
	local Vector X,Y,Z, XV,YV,ZV, HitL,HitN;
	local float SX,SY,SZ, dist, INresx, INresy;
	local int WT,WPT, ee;
	passedtim += deltatime;
	curdelta = deltatime;
	Super.Tick(deltatime);
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
	if ( VSize(Owner.Velocity < 40 )
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
	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
	XV = Owner.Velocity*X*(1/XDamp);
	YV = Owner.Velocity*Y*(1/YDamp);
	ZV = Owner.Velocity*Z*(1/ZDamp);
	SX = Normal(Owner.Velocity) dot X;
	SY = Normal(Owner.Velocity) dot Y;
	SZ = Normal(Owner.Velocity) dot Z;
	frAdditional -= frot(VSize(ZV)*SZ,VSize(XV)*SX*iSide+VSize(YV)*SY,0)
		*deltatime*150;
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
	// Conversion of vPVRec
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
	frPVRec *= (1-FMin(1,Restitution*10*deltatime));
	frRate = rot2frot(Normalize(Normalize(Pawn(Owner.ViewRotation)
		-Normalize(PreviousViewRotation)));
	frAdditional += frot(-AddVO.Z,AddVO.Y,0,0)*130000*deltatime;
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
	GetAxes(Pawn(Owner).ViewRotation(X,Y,Z);
	SetLocation(Location+vAdditional*OffsetFactor+AddVO.Y*Y+AddVO.Z*Z);
	Canvas.DrawActor(self,false);
	RenderLayers(Canvas);
	SetThirdSkins();
}

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
		MultiSkins[i] = (FirstGlowSkins[i]!=None)
			?FirstGlowSkins[i]:Texture'SWWMZ.Invisible';
	Canvas.DrawActor(self,false);
	DrawScale = OlScale;
	ScaleGlow = OlGlow;
	AmbientGlow = OlAmbGlow;
	Style = OlStyle;
	bUnlit = OlUnlit;
	bMeshEnviroMap = OlEnviroMap;
}

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
	int i;
	for ( i=0; i<8; i++ )
		MultiSkins[i] = Default.MultiSkins[i];
}

function SetViewSkins()
{
	int i;
	for ( i=0; i<8; i++ )
		MultiSkins[i] = FirstMultiSkins[i];
}

function SetThirdSkins()
{
	int i;
	for ( i=0; i<8; i++ )
		MultiSkins[i] = ThirdMultiSkins[i];
}

function Projectile FireBlast( bool IsAlt )
{
	local Vector X,Y,Z, FireLoc;
	local Rotator AdjustedAim;
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(DrawnRot,X,Y,Z);
	FireLoc = Owner.Location+NewCalcDrawOffset()+vAdditional*OffsetFactor
		+AddVO.Y*Y+AddVO.Z*Z+FireOffset.X*X+FireOffset.Y*Y
		+FireOffset.Z*Z;
	AdjustedAim = Pawn(Owner).AdjustAim(IsAlt
		?AltProjectileClass.Default.Speed
		:ProjectileClass.Default.Speed,FireLoc,AimError,True,
		bWarnTarget);
	return Spawn(IsAlt?AltProjectileClass:ProjectileClass,,,FireLoc,
		AdjustedAim+frot2rot(frAdditional*frot(1-FMin(1,VDampening),1
		-FMin(1,HDampening),0));
}

function VolatileFunction( bool PlayerDied )
{
	if ( bCarriedItem )
	{
		if ( Pawn(Owner) != None )
			Pawn(Owner).DeleteInventory(self);
		ResetChanges(Pawn(Owner));
		WasOwned = true;
	}
	else
		WasOwned = false;
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
}
