//=============================================================================
// MHUDNotify.
//
// Class to swap the HUD.
//=============================================================================
Class MHudNotify extends SpawnNotify;

event Actor SpawnNotification( Actor A )
{
	local MHUD N;
	if ( A.Class.Name == 'AssaultHUD' )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_Assault;
		return N;
	}
	if ( (A.Class.Name == 'ChallengeCTFHUD')
		|| (A.Class.Name == 'MultiCTFHUD') )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_CaptureTheFlag;
		return N;
	}
	if ( A.Class.Name == 'ChallengeDominationHUD' )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_Domination;
		return N;
	}
	if ( A.Class.Name == 'ChallengeTeamHUD' )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_TeamDeathmatch;
		return N;
	}
	if ( A.Class.Name == 'ChallengeHUD' )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_Deathmatch;
		return N;
	}
	if ( (A.Class.Name == 'MonsterHUD') || (A.Class.Name == 'KHMHUD') )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_MonsterHunt;
		return N;
	}
	if ( A.Class.Name == 'AppHUD' )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_Apprehension;
		return N;
	}
	// Nothing to change
	return A;
}
