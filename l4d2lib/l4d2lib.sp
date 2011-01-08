#include <sourcemod>
#include "rounds.inc"

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
	/* Plugin Forward Declarations */
	hFwdRoundStart = CreateGlobalForward("L4D2_OnRealRoundStart", ET_Ignore, Param_Cell);
	hFwdRoundEnd = CreateGlobalForward("L4D2_OnRealRoundEnd", ET_Ignore, Param_Cell);

	HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
	HookEvent("round_end", RoundEnd_Event, EventHookMode_PostNoCopy);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RegPluginLibrary(LIBRARYNAME);
}

public OnMapStart()
{
	Rounds_OnMapStart_Update();
}

public Action:RoundEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Rounds_OnRoundEnd_Update();
}

public Action:RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Rounds_OnRoundStart_Update();
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
