class MWarArmor extends MArmor;

function int Reduce( int Damage, Name DamageType, Vector HitLocation )
{
	local int OutDamage, OldHealth;
	local MDamageCounter DC;
	if ( CurrentArmor <= 100 )
		OutDamage = Damage*(1.0-CurrentArmor*0.01);
	else
	{
		OutDamage = 0;
		OldHealth = Pawn(Owner).Health;
		if ( Pawn(Owner).Health < 500 )
			Pawn(Owner).Health = FMin(500,Pawn(Owner).Health
				+Damage*(CurrentArmor*0.01-1.0));
		DC = Spawn(Class'MDamageCounter',Pawn(Owner));
		DC.Factor = Pawn(Owner).Health-OldHealth;
		if ( HitLocation != vect(0,0,0) )
			HitLocation -= Pawn(Owner).Location;
		DC.RealHitLocation = HitLocation;
	}
	CurrentArmor -= 0.1*Damage;

	if ( CurrentArmor <= 0 )
		Destroy();
	return OutDamage;
}

defaultproperties
{
	ArmorAmount=5
	ArmorMax=500
}
