#include <sourcemod>
#include "rounds.inc"
#include "tanks.inc"
#include "survivors.inc"

#define LIBRARYNAME "l4d2lib"

public Plugin:myinfo = 
{
	name = "L4D2Lib",
	author = "Confogl Team",
	description = "Useful natives and fowards for L4D2 Plugins",
	version = "1.0",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
}

public OnPluginStart()
{
	/* Plugin Native Declarations */
	CreateNative("L4D2_GetCurrentRound", _native_GetCurrentRound);
	CreateNative("L4D2_CurrentlyInRound", _native_CurrentlyInRound);
	CreateNative("L4D2_GetSurvivorCount", _native_GetSurvivorCount);
	CreateNative("L4D2_GetSurvivorOfIndex", _native_GetSurvivorOfIndex);
	/* Plugin Forward Declarations */
	hFwdRoundStart = CreateGlobalForward("L4D2_OnRealRoundStart", ET_Ignore, Param_Cell);
	hFwdRoundEnd = CreateGlobalForward("L4D2_OnRealRoundEnd", ET_Ignore, Param_Cell);
	hFwdFirstTankSpawn = CreateGlobalForward("L4D2_OnTankFirstSpawn", ET_Ignore, Param_Cell);
	hFwdTankPassControl = CreateGlobalForward("L4D2_OnTankPassControl", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	hFwdTankDeath = CreateGlobalForward("L4D2_OnTankDeath", ET_Ignore, Param_Cell);
	
	HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
	HookEvent("round_end", RoundEnd_Event, EventHookMode_PostNoCopy);
	HookEvent("tank_spawn", TankSpawn_Event);
	HookEvent("item_pickup", ItemPickup_Event);
	HookEvent("player_death", PlayerDeath_Event);
	HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
	HookEvent("player_spawn" , PlayerSpawn_Event, EventHookMode_PostNoCopy);
	HookEvent("player_disconnect" , PlayerDisconnect_Event, EventHookMode_PostNoCopy);
	HookEvent("player_bot_replace" , PlayerBotReplace_Event, EventHookMode_PostNoCopy);
	HookEvent("bot_player_replace" , BotPlayerReplace_Event, EventHookMode_PostNoCopy);
	HookEvent("defibrillator_used" , DefibrillatorUsed_Event, EventHookMode_PostNoCopy);
	HookEvent("player_team" , PlayerTeam_Event, EventHookMode_PostNoCopy);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RegPluginLibrary(LIBRARYNAME);
}

public OnMapStart()
{
	Rounds_OnMapStart_Update();
	Tanks_OnMapStart();
}

public Action:RoundEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Rounds_OnRoundEnd_Update();
}

public Action:RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Rounds_OnRoundStart_Update();
	Tanks_RoundStart();
	Survivors_RebuildArray();
}

public Action:TankSpawn_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Tanks_TankSpawn(event);
}

public Action:ItemPickup_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Tanks_ItemPickup(event);
}

public Action:PlayerDeath_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Tanks_PlayerDeath(event);
	Survivors_RebuildArray();
}

public Action:PlayerSpawn_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Survivors_RebuildArray();
}

public Action:PlayerDisconnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Survivors_RebuildArray();
}

public Action:PlayerBotReplace_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Survivors_RebuildArray();
}

public Action:BotPlayerReplace_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Survivors_RebuildArray();
}

public Action:DefibrillatorUsed_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Survivors_RebuildArray();
}

public Action:PlayerTeam_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Survivors_RebuildArray_Delay();
}


/* Plugin Natives */
public _native_GetCurrentRound(Handle:plugin, numParams)
{
	return GetCurrentRound();
}

public _native_CurrentlyInRound(Handle:plugin, numParams)
{
	return _:CurrentlyInRound();
}

public _native_GetSurvivorCount(Handle:plugin, numParams)
{
	return GetSurvivorCount();
}

public _native_GetSurvivorOfIndex(Handle:plugins, numParams)
{
	return GetSurvivorOfIndex(GetNativeCell(1));
}