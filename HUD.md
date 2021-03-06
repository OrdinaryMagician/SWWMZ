### The HUD

One of the newest features in this project is a full HUD replacement.

Since this HUD is designed specifically for SWWM Z, it can't handle other
custom content well. There's support for some custom gametypes like Multi-CTF
or Monster Hunt.

The HUD has been designed specifically for minimal screen clutter, thus it is
mostly just text and little colored bars.

The different sections are described in detail below...

#### Top left corner

As usual, the chat area is here, where things like player messages shows up,
along with funky obituaries and various minor world messages.

#### Top border

Nothing here yet.

#### Top right corner

A quick and dirty minimap. Marks players as cyan-ish dots on teamless games, or
as their team color on team ones.
On some gametypes you'll also see the locations of control points, flags, or
assault targets (including remote triggers in a lighter color, if any).
Placement of assault targets might be off, but that depends on the map author.
There is no actual "map", so I guess this is more like a radar.

#### Left border

Depending on the gametype, you will see various things here.

##### Deathmatch

The three top ranking players of the match with their scores.

##### Team Deathmatch

Team scores (duh).

##### Capture the Flag

The scores for each team along with the status of each flag (on base, carried,
dropped).

##### Domination

Team scores and their currently dominated control points.

##### Assault

Nothing shows up here.

##### Last Man Standing

The top three players and their remaining lives, also your own lives.

##### Various mods

Currently supported custom gametypes are Monster Hunt (shows nothing),
Oldskool Amp'd (shows usable inventory items), MultiCTF (behaves the same
exact way as normal CTF) and Apprehension (shows team scores).

#### Right border

Your current powerups (if any) and their status.

#### Bottom left corner

Your "score", health and armor levels.

Also, a tiny little *nix-like shell prompt if you opened the console. :3

#### Bottom border

Weapon slots, shows ammo and health for each carried weapon.

#### Bottom right corner

Current equipped weapon stats.

#### Other

This HUD has restored the old Unreal "introductory message" showing map info
and MOTD. It'll show up at the beginning of each match and then fade out.

Various other things are scattered acros the screen, like pickup messages,
appearing near the bottom in blue-ish text, critical messages in red, slightly
higher and last but not least... the TARGETER!

#### Targeter

Because in the middle of the chaos that is this mod you might have a hard time
trying to figure out where is everything in between explosions and massive
smoke clouds, a targeter has been implemented, the following things are shown:

* Pawns: Basically everything that is sentient, not just players. Draws an
  identificative label and a health bar. The bar only measures their health up
  to default limits, so overhealed players will show up with a full bar until
  their health drops down below 100. When they take damage or get healed, a
  number (either negative or positive) will show up below the health bar
  indicating the cumulative increase/decrease in health. The targeter only
  picks up creatures in your direct line of sight, unless they are teammates.
* Gametype specials: These always show up. Things such as flags, control points
  assault objectives, or mod-specific stuff. They all come with a little
  distance meter (in meters, fuck you imperial system).
