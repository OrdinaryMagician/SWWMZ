class MResources extends Actor abstract;

// Basic textures
#exec TEXTURE IMPORT NAME=Invisible FILE=Textures\Invisible.pcx
#exec TEXTURE IMPORT NAME=Whiteness FILE=Textures\Whiteness.pcx

// QSE
#exec TEXTURE IMPORT NAME=qse_00 FILE=Textures\qse_a00.pcx
#exec TEXTURE IMPORT NAME=qse_01 FILE=Textures\qse_a01.pcx
#exec TEXTURE IMPORT NAME=qse_02 FILE=Textures\qse_a02.pcx
#exec TEXTURE IMPORT NAME=qse_03 FILE=Textures\qse_a03.pcx
#exec TEXTURE IMPORT NAME=qse_04 FILE=Textures\qse_a04.pcx
#exec TEXTURE IMPORT NAME=qse_05 FILE=Textures\qse_a05.pcx
#exec TEXTURE IMPORT NAME=qse_06 FILE=Textures\qse_a06.pcx
#exec TEXTURE IMPORT NAME=qse_07 FILE=Textures\qse_a07.pcx
#exec TEXTURE IMPORT NAME=qse_08 FILE=Textures\qse_a08.pcx
#exec TEXTURE IMPORT NAME=qse_09 FILE=Textures\qse_a09.pcx
#exec TEXTURE IMPORT NAME=qse_10 FILE=Textures\qse_a10.pcx
#exec TEXTURE IMPORT NAME=qse_11 FILE=Textures\qse_a11.pcx
#exec TEXTURE IMPORT NAME=qse_12 FILE=Textures\qse_a12.pcx
#exec TEXTURE IMPORT NAME=qse_13 FILE=Textures\qse_a13.pcx
#exec TEXTURE IMPORT NAME=qse_14 FILE=Textures\qse_a14.pcx
#exec TEXTURE IMPORT NAME=qse_15 FILE=Textures\qse_a15.pcx
#exec TEXTURE IMPORT NAME=qse_16 FILE=Textures\qse_a16.pcx
#exec TEXTURE IMPORT NAME=qse_17 FILE=Textures\qse_a17.pcx
#exec TEXTURE IMPORT NAME=qse_18 FILE=Textures\qse_a18.pcx
#exec TEXTURE IMPORT NAME=qse_19 FILE=Textures\qse_a19.pcx

#exec AUDIO IMPORT NAME=QuadShotExpl FILE=Sounds\QuadRocketExpl.wav

// Qsm
#exec MESH IMPORT MESH=qsm ANIVFILE=Models\Flat_a.3d DATAFILE=Models\Flat_d.3d
#exec MESH ORIGIN MESH=qsm YAW=64
#exec MESH SEQUENCE MESH=qsm SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=qsm MESH=qsm
#exec MESHMAP SCALE MESHMAP=qsm X=0.125 Y=0.01 Z=0.25

#exec TEXTURE IMPORT NAME=qsm_00 FILE=Textures\qsm_a00.pcx
#exec TEXTURE IMPORT NAME=qsm_01 FILE=Textures\qsm_a01.pcx
#exec TEXTURE IMPORT NAME=qsm_02 FILE=Textures\qsm_a02.pcx
#exec TEXTURE IMPORT NAME=qsm_03 FILE=Textures\qsm_a03.pcx
#exec TEXTURE IMPORT NAME=qsm_04 FILE=Textures\qsm_a04.pcx
#exec TEXTURE IMPORT NAME=qsm_05 FILE=Textures\qsm_a05.pcx
#exec TEXTURE IMPORT NAME=qsm_06 FILE=Textures\qsm_a06.pcx
#exec TEXTURE IMPORT NAME=qsm_07 FILE=Textures\qsm_a07.pcx
#exec TEXTURE IMPORT NAME=qsm_08 FILE=Textures\qsm_a08.pcx
#exec TEXTURE IMPORT NAME=qsm_09 FILE=Textures\qsm_a09.pcx
#exec TEXTURE IMPORT NAME=qsm_10 FILE=Textures\qsm_a10.pcx
#exec TEXTURE IMPORT NAME=qsm_11 FILE=Textures\qsm_a11.pcx
#exec TEXTURE IMPORT NAME=qsm_12 FILE=Textures\qsm_a12.pcx
#exec TEXTURE IMPORT NAME=qsm_13 FILE=Textures\qsm_a13.pcx
#exec TEXTURE IMPORT NAME=qsm_14 FILE=Textures\qsm_a14.pcx
#exec TEXTURE IMPORT NAME=qsm_15 FILE=Textures\qsm_a15.pcx
#exec TEXTURE IMPORT NAME=qsm_16 FILE=Textures\qsm_a16.pcx
#exec TEXTURE IMPORT NAME=qsm_17 FILE=Textures\qsm_a17.pcx
#exec TEXTURE IMPORT NAME=qsm_18 FILE=Textures\qsm_a18.pcx
#exec TEXTURE IMPORT NAME=qsm_19 FILE=Textures\qsm_a19.pcx

// Weapon hit sounds
#exec AUDIO IMPORT NAME=WeaponHit1 FILE=Sounds\hullhit.wav
#exec AUDIO IMPORT NAME=WeaponHit2 FILE=Sounds\hullhit2.wav
#exec AUDIO IMPORT NAME=WeaponHit3 FILE=Sounds\hullhit3.wav
#exec AUDIO IMPORT NAME=WeaponHit4 FILE=Sounds\hullhit4.wav
#exec AUDIO IMPORT NAME=WeaponHit5 FILE=Sounds\hullhit5.wav

// Dust
#exec TEXTURE IMPORT NAME=dust_00 FILE=Textures\dust_a00.pcx
#exec TEXTURE IMPORT NAME=dust_01 FILE=Textures\dust_a01.pcx
#exec TEXTURE IMPORT NAME=dust_02 FILE=Textures\dust_a02.pcx
#exec TEXTURE IMPORT NAME=dust_03 FILE=Textures\dust_a03.pcx
#exec TEXTURE IMPORT NAME=dust_04 FILE=Textures\dust_a04.pcx
#exec TEXTURE IMPORT NAME=dust_05 FILE=Textures\dust_a05.pcx
#exec TEXTURE IMPORT NAME=dust_06 FILE=Textures\dust_a06.pcx
#exec TEXTURE IMPORT NAME=dust_07 FILE=Textures\dust_a07.pcx
#exec TEXTURE IMPORT NAME=dust_08 FILE=Textures\dust_a08.pcx
#exec TEXTURE IMPORT NAME=dust_09 FILE=Textures\dust_a09.pcx
#exec TEXTURE IMPORT NAME=dust_10 FILE=Textures\dust_a10.pcx
#exec TEXTURE IMPORT NAME=dust_11 FILE=Textures\dust_a11.pcx
#exec TEXTURE IMPORT NAME=dust_12 FILE=Textures\dust_a12.pcx
#exec TEXTURE IMPORT NAME=dust_13 FILE=Textures\dust_a13.pcx
#exec TEXTURE IMPORT NAME=dust_14 FILE=Textures\dust_a14.pcx
#exec TEXTURE IMPORT NAME=dust_15 FILE=Textures\dust_a15.pcx
#exec TEXTURE IMPORT NAME=dust_16 FILE=Textures\dust_a16.pcx
#exec TEXTURE IMPORT NAME=dust_17 FILE=Textures\dust_a17.pcx
#exec TEXTURE IMPORT NAME=dust_18 FILE=Textures\dust_a18.pcx
#exec TEXTURE IMPORT NAME=dust_19 FILE=Textures\dust_a19.pcx

// HUD stuff
#exec TEXTURE IMPORT NAME=Gradient0 FILE=Textures\gradient0.pcx
#exec TEXTURE IMPORT NAME=Gradient90 FILE=Textures\gradient90.pcx
#exec TEXTURE IMPORT NAME=Gradient180 FILE=Textures\gradient180.pcx
#exec TEXTURE IMPORT NAME=Gradient270 FILE=Textures\gradient270.pcx
#exec TEXTURE IMPORT NAME=Gradient45 FILE=Textures\gradient45.pcx
#exec TEXTURE IMPORT NAME=Gradient135 FILE=Textures\gradient135.pcx
#exec TEXTURE IMPORT NAME=Gradient225 FILE=Textures\gradient225.pcx
#exec TEXTURE IMPORT NAME=Gradient315 FILE=Textures\gradient315.pcx
#exec TEXTURE IMPORT NAME=NGradient45 FILE=Textures\ngradient45.pcx
#exec TEXTURE IMPORT NAME=NGradient135 FILE=Textures\ngradient135.pcx
#exec TEXTURE IMPORT NAME=NGradient225 FILE=Textures\ngradient225.pcx
#exec TEXTURE IMPORT NAME=NGradient315 FILE=Textures\ngradient315.pcx

#exec TEXTURE IMPORT FILE=Textures\mh_dot.pcx NAME=mh_dot
#exec TEXTURE IMPORT FILE=Textures\mh_star.pcx NAME=mh_star
#exec TEXTURE IMPORT FILE=Textures\mh_flag.pcx NAME=mh_flag
#exec TEXTURE IMPORT FILE=Textures\mh_flagtk.pcx NAME=mh_flagtk
#exec TEXTURE IMPORT FILE=Textures\mh_flagdp.pcx NAME=mh_flagdp
#exec TEXTURE IMPORT FILE=Textures\mh_neutral.pcx NAME=mh_neutral
#exec TEXTURE IMPORT FILE=Textures\mh_red.pcx NAME=mh_red
#exec TEXTURE IMPORT FILE=Textures\mh_blue.pcx NAME=mh_blue
#exec TEXTURE IMPORT FILE=Textures\mh_green.pcx NAME=mh_green
#exec TEXTURE IMPORT FILE=Textures\mh_gold.pcx NAME=mh_gold

#exec TEXTURE IMPORT FILE=Textures\mh_boots.pcx NAME=mh_boots
#exec TEXTURE IMPORT FILE=Textures\mh_invis.pcx NAME=mh_invis
#exec TEXTURE IMPORT FILE=Textures\mh_shield.pcx NAME=mh_shield
#exec TEXTURE IMPORT FILE=Textures\mh_regen.pcx NAME=mh_regen
#exec TEXTURE IMPORT FILE=Textures\mh_reflect.pcx NAME=mh_reflect
#exec TEXTURE IMPORT FILE=Textures\mh_hide.pcx NAME=mh_hide
#exec TEXTURE IMPORT FILE=Textures\mh_rage.pcx NAME=mh_rage
#exec TEXTURE IMPORT FILE=Textures\mh_float.pcx NAME=mh_float
