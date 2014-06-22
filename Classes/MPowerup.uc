//=============================================================================
// MPowerup.
//
// Base SWWMZ Powerup class.
//=============================================================================
class MPowerup extends TournamentPickup abstract;

event float BotDesireability( Pawn Bot )
{
	// GIMME GIMME GIMME
	return 2.0;
}

defaultproperties
{
}
