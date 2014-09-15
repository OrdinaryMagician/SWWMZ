class MBlastSuit extends MArmor;

function int Reduce( int Damage, Name DamageType, Vector HitLocation )
{
	local int OutDamage;
	OutDamage = Damage;
	if ( (DamageType == 'Burned') || (DamageType == 'Frozen')
		|| (DamageType == 'Incinerated') || (DamageType == 'Corroded')
		|| (DamageType == 'zapped') || (DamageType == 'jolted') )
	{
		CurrentArmor -= 0.75*Damage;
		OutDamage *= 0.25;
	}
	else if ( (DamageType == 'Exploded') || (DamageType == 'RocketDeath')
		|| (DamageType == 'GrenadeDeath') )
	{
		CurrentArmor -= 0.5*Damage;
		OutDamage *= 0.5;
	}

	if ( CurrentArmor <= 0 )
		Destroy();
	return OutDamage;
}

defaultproperties
{
	ArmorAmount=5000
	ArmorMax=5000
}
