//=============================================================================
// MMultiItem.
//
// Spawn spot that cycles through various things on every respawn.
//=============================================================================
class MMultiItem extends Inventory abstract;

var() class<Inventory> Items[10];
var() float Durations[10];
var() Vector Offsets[10];
var() bool WeaponStay;
var() int UsedSlots;
var bool Startup;
var Inventory Current;
var Vector SpawnedLoc;
var() Sound SpawnSound;
var int i;

function BecomePickup()
{
	SetCollision(false,false,false);
}

function BecomeItem()
{
}

function GiveTo( Pawn Other )
{
}

function Inventory SpawnCopy( Pawn Other )
{
	return None;
}

function SetRespawn()
{
}

function Touch( Actor Other )
{
}

Auto State ItemsSpawn
{

Begin:
	if ( !Startup )
	{
		Startup = True;
		i = Rand(UsedSlots);
	}
	PlaySound(SpawnSound);
	Current = Spawn(Items[i],,, Location+Offsets[i]+vect(0,0,1)
		*Items[i].Default.CollisionHeight);
	if ( Current == None )
	{
		Sleep(Durations[i]);
		i++;
		if ( i >= UsedSlots )
			i = 0;
		Goto('Begin');
	}
	if ( Current.IsA('MWeapon') && WeaponStay )
		MWeapon(Current).bWeaponStay = MWeapon(Current).IsSuperWeapon;
	Sleep(Durations[i]);
	i++;
	if ( i >= UsedSlots )
		i = 0;
	if ( Current != None )
		Current.Destroy();
	Goto('Begin');
}

defaultproperties
{
	SpawnSound=Sound'Botpack.Generic.RespawnSound2'
	PickupMessage="You shouldn't see this message"
	MaxDesireability=0.0
	bHidden=True
	DrawType=DT_Sprite
	bIsItemGoal=False
	CollisionRadius=0.0
	CollisionHeight=0.0
	bCollideActors=False
}
