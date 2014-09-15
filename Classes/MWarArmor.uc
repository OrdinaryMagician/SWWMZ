class MWarArmor extends MArmor;

function int Reduce( int Damage, Name DamageType, Vector HitLocation )
{
	local int OutDamage;
	OutDamage = Damage;
	if ( (DamageType == 'Burned') || (DamageType == 'Frozen')
		|| (DamageType == 'Incinerated') || (DamageType == 'Corroded')
		|| (DamageType == 'zapped') || (DamageType == 'jolted') )
	{
		CurrentArmor -= Damage;
		OutDamage *= 0;
	}
	else if ( (DamageType == 'Exploded') || (DamageType == 'RocketDeath')
		|| (DamageType == 'GrenadeDeath') )
	{
		CurrentArmor -= 0.8*Damage;
		OutDamage *= 0.2;
	}
	else if ( DamageType == 'shot' )
	{
		CurrentArmor -= 0.5*Damage;
		OutDamage *= 0.5;
	}
	else
	{
		CurrentArmor -= 0.4*Damage;
		OutDamage *= 0.6;
	}

	if ( CurrentArmor <= 0 )
		Destroy();
	return OutDamage;
}

defaultproperties
{
	ArmorAmount=10000
	ArmorMax=10000
}
