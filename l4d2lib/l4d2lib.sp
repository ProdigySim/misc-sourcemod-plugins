#pragma semicolon 1

#include <sourcemod>
#include "rounds.inc"
#include "mapinfo.inc"

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
	CreateNative("L4D2_IsMapDataAvailable", _native_IsMapDataAvailable);
	CreateNative("L4D2_IsEntityInSaferoom", _native_IsEntityInSaferoom);
	CreateNative("L4D2_GetMapStartOrigin", _native_GetMapStartOrigin);
	CreateNative("L4D2_GetMapEndOrigin", _native_GetMapEndOrigin);
	CreateNative("L4D2_GetMapStartDistance", _native_GetMapStartDist);
	CreateNative("L4D2_GetMapStartExtraDistance", _native_GetMapStartExtraDist);
	CreateNative("L4D2_GetMapEndDistance", _native_GetMapEndDist);
	CreateNative("L4D2_GetMapValueInt", _native_GetMapValueInt);
	CreateNative("L4D2_GetMapValueFloat", _native_GetMapValueFloat);
	CreateNative("L4D2_GetMapValueVector", _native_GetMapValueVector);
	CreateNative("L4D2_GetMapValueString", _native_GetMapValueString);
	CreateNative("L4D2_CopyMapSubsection", _native_CopyMapSubsection);
	
	/* Plugin Forward Declarations */
	hFwdRoundStart = CreateGlobalForward("L4D2_OnRealRoundStart", ET_Ignore, Param_Cell);
	hFwdRoundEnd = CreateGlobalForward("L4D2_OnRealRoundEnd", ET_Ignore, Param_Cell);

	HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
	HookEvent("round_end", RoundEnd_Event, EventHookMode_PostNoCopy);
	HookEvent("player_disconnect", PlayerDisconnect_Event);
	MapInfo_Init();
}

public OnPluginEnd()
{
	MapInfo_OnPluginEnd();
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RegPluginLibrary(LIBRARYNAME);
}

public OnMapStart()
{
	MapInfo_OnMapStart_Update();
	Rounds_OnMapStart_Update();
}

public OnMapEnd()
{
	MapInfo_OnMapEnd_Update();
}

/* Events */
public Action:RoundEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Rounds_OnRoundEnd_Update();
}

public Action:RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	Rounds_OnRoundStart_Update();
}

public Action:PlayerDisconnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	MapInfo_PlayerDisconnect_Event(event);
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

public _native_IsMapDataAvailable(Handle:plugin, numParams)
{
	return IsMapDataAvailable();
}

public _native_IsEntityInSaferoom(Handle:plugin, numParams)
{
	return _:IsEntityInSaferoom(GetNativeCell(1), GetNativeCell(2));
}

public _native_GetMapStartOrigin(Handle:plugin, numParams)
{
	decl Float:origin[3];
	GetNativeArray(1, origin, 3);
	GetMapStartOrigin(origin);
	SetNativeArray(1, origin, 3);
}

public _native_GetMapEndOrigin(Handle:plugin, numParams)
{
	decl Float:origin[3];
	GetNativeArray(1, origin, 3);
	GetMapEndOrigin(origin);
	SetNativeArray(1, origin, 3);
}

public _native_GetMapStartDist(Handle:plugin, numParams)
{
	return _:GetMapStartDist();
}

public _native_GetMapStartExtraDist(Handle:plugin, numParams)
{
	return _:GetMapStartExtraDist();
}

public _native_GetMapEndDist(Handle:plugin, numParams)
{
	return _:GetMapEndDist();
}

public _native_GetMapValueInt(Handle:plugin, numParams)
{
	decl len, defval;
	
	GetNativeStringLength(1, len);
	new String:key[len+1];
	GetNativeString(1, key, len+1);
	
	defval = GetNativeCellRef(2);
	
	return GetMapValueInt(key, defval);
}
public _native_GetMapValueFloat(Handle:plugin, numParams)
{
	decl len, Float:defval;
	
	GetNativeStringLength(1, len);
	new String:key[len+1];
	GetNativeString(1, key, len+1);
	
	defval = GetNativeCellRef(2);
	
	return _:GetMapValueFloat(key, defval);
}

public _native_GetMapValueVector(Handle:plugin, numParams)
{
	decl len, Float:defval[3], Float:value[3];
	
	GetNativeStringLength(1, len);
	new String:key[len+1];
	GetNativeString(1, key, len+1);
	
	GetNativeArray(3, defval, 3);
	
	GetMapValueVector(key, value, defval);
	
	SetNativeArray(2, value, 3);
}

public _native_GetMapValueString(Handle:plugin, numParams)
{
	decl len;
	GetNativeStringLength(1, len);
	new String:key[len+1];
	GetNativeString(1, key, len+1);
	
	GetNativeStringLength(4, len);
	new String:defval[len+1];
	GetNativeString(4, defval, len+1);
	
	len = GetNativeCell(3);
	new String:buf[len+1];
	
	GetMapValueString(key, buf, len, defval);
	
	SetNativeString(2, buf, len);
}

public _native_CopyMapSubsection(Handle:plugin, numParams)
{
	decl len, Handle:kv;
	GetNativeStringLength(2, len);
	new String:key[len+1];
	GetNativeString(2, key, len+1);
	
	kv = GetNativeCell(1);
	
	CopyMapSubsection(kv, key);
}

