//=============================================================================
// MHUDNotify.
//
// Class to swap the HUD.
//=============================================================================
Class MHudNotify extends SpawnNotify;

event Actor SpawnNotification( Actor A )
{
	local MHUD N;
	if ( A.Owner.IsA('Spectator') )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_Spectator;
		return N;
	}
	if ( A.Class.Name == 'AssaultHUD' )
	{
		A.Destroy();
		N = Spawn(Class'SWWMZ.MHUD',A.Owner);
		N.HUDType = HUD_Assault;
		return N;
	}
	if ( A.Class.Name == 'ChallengeCTFHUD' )
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
	// Nothing to change
	return A;
}
