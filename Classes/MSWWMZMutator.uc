//=============================================================================
// MSWWMZMutator.
//
// The heart of SWWM Z.
//=============================================================================
class MSWWMZMutator extends Mutator;

var bool Initialized;

function UpdateDamage( Pawn P, int D, Vector HL )
{
	local MDamageCounter DC;
	DC = Spawn(Class'MDamageCounter',P);
	DC.Factor = -D;
	if ( HL != vect(0,0,0) )
		HL -= P.Location;
	DC.RealHitLocation = HL;
}

function AddWeapon( String WN, Pawn P )
{
	local Class<Weapon> WC;
	local Weapon W;
	WC = Class<Weapon>(DynamicLoadObject(WN,Class'Class',True));
	if ( WC == None )
		return;
	if ( P.FindInventoryType(WC) != None )
		return;
	W = Spawn(WC,,,P.Location);
	W.Instigator = P;
	W.bHeldItem = True;
	W.GiveTo(P);
	W.bTossedOut = False;
	W.GiveAmmo(P);
	W.SetSwitchPriority(P);
	if ( !P.bNeverSwitchOnPickup )
		W.WeaponSet(P);
	W.AmbientGlow = 0;
}

function AddPickup( String PN, Pawn P )
{
	local Class<Pickup> PC;
	local Pickup Pu;
	PC = Class<Pickup>(DynamicLoadObject(PN,Class'Class',True));
	if ( PC == None )
		return;
	if ( P.FindInventoryType(PC) != None )
		return;
	Pu = Spawn(WC,,,P.Location);
	Pu.RespawnTime = 0.0;
	Pu.bHeldItem = True;
	Pu.GiveTo(P);
	if ( Pu.bActivatable && (P.SelectedItem == None) )
		P.SelectedItem = Pu;
	if ( Pu.bActivatable && Pu.bAutoActivate && P.bAutoActivate )
		Pu.Activate();
	Pu.PickupFunction(P);
}

event PostBeginPlay()
{
	if ( Initialized )
		return;
	Initialized = True;
	Spawn(class'MHUDNotify');
	Level.Game.RegisterDamageMutator(self);
	SetTimer(1.0,True);
}

function ModifyPlayer( Pawn Other )
{
	local Inventory I;
	I = Other.FindInventoryType(Class'Enforcer');
	if ( I != None )
	{
		Other.DeleteInventory(I);
		I.Destroy();
	}
	I = Other.FindInventoryType(Class'ImpactHammer');
	if ( I != None )
	{
		Other.DeleteInventory(I);
		I.Destroy();
	}
	I = Other.FindInventoryType(Class'Chainsaw');
	if ( I != None )
	{
		Other.DeleteInventory(I);
		I.Destroy();
	}
	AddWeapon("SWWMZ.MDeepImpact",Other);
	AddWeapon("SWWMZ.MZapper",Other);
	AddWeapon("SWWMZ.MExplodeGun",Other);
	AddWeapon("SWWMZ.MSpreadGun",Other);
	if ( Level.Game.IsA('LastManStanding') )
	{
		AddWeapon("SWWMZ.MUCW",Other);
		AddWeapon("SWWMZ.MBiorifle",Other);
		AddWeapon("SWWMZ.MFlamer",Other);
		AddWeapon("SWWMZ.MSparksterOld",Other);
		AddWeapon("SWWMZ.MSparkster",Other);
		AddWeapon("SWWMZ.MPROWEL",Other);
		AddWeapon("SWWMZ.MCloneMachine",Other);
		AddWeapon("SWWMZ.MGravity",Other);
		AddWeapon("SWWMZ.MBetaPulse",Other);
		AddWeapon("SWWMZ.MSplatter",Other);
		AddWeapon("SWWMZ.MEviscerator",Other);
		AddWeapon("SWWMZ.MSpamGun",Other);
		AddWeapon("SWWMZ.MNeutralizer",Other);
		AddWeapon("SWWMZ.MChaosCannon",Other);
		AddWeapon("SWWMZ.MFireCannon",Other);
		AddWeapon("SWWMZ.MHellraiser",Other);
		AddWeapon("SWWMZ.MQuadShot",Other);
		AddWeapon("SWWMZ.MMortalRifle",Other);
		AddWeapon("SWWMZ.MSilverBullet",Other);
		AddInventory("SWWMZ.MBlastSuit",Other);
		AddInventory("SWWMZ.MWarArmor",Other);
	}
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim,
	Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum,
	Name DamageType )
{
	local MGhost Invis;
	local MReflector Refl;
	local MArmor Armor;
	if ( Victim != None )
	{
		Refl = MReflector(Victim.FindInventoryType(class'MReflector'));
		if ( Refl != None )
		{
			Refl.GetHit();
			ActualDamage = 0;
		}
		Invis = MGhost(Victim.FindInventoryType(class'MGhost'));
		if ( Invis != None )
			Invis.bShotWeapon = True;
		Armor = MArmor(Victim.FindInventoryType(class'MArmorBonus'));
		if ( Armor != None )
			ActualDamage = Armor.Reduce(ActualDamage,DamageType,
				HitLocation);
		Armor = MArmor(Victim.FindInventoryType(class'MBlastSuit'));
		if ( Armor != None )
			ActualDamage = Armor.Reduce(ActualDamage,DamageType,
				HitLocation);
		Armor = MArmor(Victim.FindInventoryType(class'MWarArmor'));
		if ( Armor != None )
			ActualDamage = Armor.Reduce(ActualDamage,DamageType,
				HitLocation);
	}
	UpdateDamage(Victim,ActualDamage,HitLocation);
	if ( NextDamageMutator != None )
		NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,
			InstigatedBy,HitLocation,Momentum,DamageType);
}

function bool CheckNear( Actor A, Actor B )
{
	if ( VSize(B.Location-A.Location) < 0.5*(B.CollisionRadius
		+A.CollisionRadius) )
		return true;
	return false;
}

function bool CheckNearPawn( Actor A )
{
	local Pawn P;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( VSize(P.Location-A.Location) < 0.5*(P.CollisionRadius
			+A.CollisionRadius) )
			return true;
	return false;
}

function AutoAddInventory()
{
	local Pawn P;
	local Weapon W;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		ForEach AllActors(Class'Weapon',W)
		{
			if ( !CheckNear(P,W) || (W.Owner != None) )
				continue;
			if ( !P.IsA('SkaarjTrooper')
				&& !P.IsA('WeaponHolder') )
				continue;
			W.Instigator = P;
			W.bHeldItem = True;
			W.GiveTo(P);
			W.bTossedOut = False;
			W.GiveAmmo(P);
			W.SetSwitchPriority(P);
			if ( !P.bNeverSwitchOnPickup )
				W.WeaponSet(P);
			W.AmbientGlow = 0;
		}
	}
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	// Weapons
	if ( Other.IsA('ImpactHammer') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti1");
		return false;
	}
	if ( Other.IsA('Chainsaw') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MUCW");
		return false;
	}
	if ( Other.IsA('Enforcer') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti2");
		return false;
	}
	if ( Other.IsA('UT_BioRifle') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti3");
		return false;
	}
	if ( Other.IsA('ShockRifle') && !Other.IsA('SuperShockRifle')
		&& !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti4");
		return false;
	}
	if ( Other.IsA('SuperShockRifle') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiE");
		return false;
	}
	if ( Other.IsA('PulseGun') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti5");
		return false;
	}
	if ( Other.IsA('Ripper') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti6");
		return false;
	}
	if ( Other.IsA('Minigun2') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti7");
		return false;
	}
	if ( Other.IsA('UT_FlakCannon') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti8");
		return false;
	}
	if ( Other.IsA('UT_Eightball') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti9");
		return false;
	}
	if ( Other.IsA('SniperRifle') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMulti10");
		return false;
	}
	if ( Other.IsA('WarheadLauncher') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiS");
		return false;
	}
	if ( Other.IsA('QuadShot') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MQuadShot");
		return false;
	}
	// Ammo
	if ( Other.IsA('EClip') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA2");
		return false;
	}
	if ( Other.IsA('BioAmmo') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA3");
		return false;
	}
	if ( Other.IsA('ShockCore') && !Other.IsA('SuperShockCore')
		&& !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA4");
		return false;
	}
	if ( Other.IsA('SuperShockCore') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiAE");
		return false;
	}
	if ( Other.IsA('PAmmo') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA5");
		return false;
	}
	if ( Other.IsA('BladeHopper') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA6");
		return false;
	}
	if ( Other.IsA('MiniAmmo') && !Other.IsA('EClip')
		&& !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA7");
		return false;
	}
	if ( Other.IsA('FlakAmmo') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA8");
		return false;
	}
	if ( Other.IsA('RocketPack') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA9");
		return false;
	}
	if ( Other.IsA('BulletBox') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiA10");
		return false;
	}
	if ( Other.IsA('WarheadAmmo') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiAS");
		return false;
	}
	if ( Other.IsA('Shells') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MQuadAmmo");
		return false;
	}
	// Pickups
	if ( Other.IsA('Armor2') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MWarArmor");
		return false;
	}
	if ( Other.IsA('ThighPads') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MBlastSuit");
		return false;
	}
	if ( Other.IsA('UT_ShieldBelt') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MReflector");
		return false;
	}
	if ( Other.IsA('UT_Invisibility') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MGhost");
		return false;
	}
	if ( Other.IsA('UDamage') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiDMG");
		return false;
	}
	if ( Other.IsA('HealthPack') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MRegen");
		return false;
	}
	if ( Other.IsA('MedBox') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MHealthCube");
		return false;
	}
	if ( Other.IsA('HealthVial') && !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MMultiHV");
		return false;
	}
	if ( Other.IsA('UT_JumpBoots') && !Other.IsA('MyBoots')
		&& !CheckNearPawn(Other) )
	{
		ReplaceWith(Other,"SWWMZ.MFloat");
		return false;
	}
	SetTimer(0.01,False);
	bSuperRelevant = 0;
	return true;
}

event Timer()
{
	AutoAddInventory();
}

defaultproperties
{
	DefaultWeapon=Class'SWWMZ.MDeepImpact'
}
