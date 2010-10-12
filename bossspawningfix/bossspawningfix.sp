#include <sourcemod>
#include <sdktools>
#include <left4downtown>

public Plugin:myinfo = 
{
	name = "Versus Boss Spawn Persuasion",
	author = "ProdigySim",
	description = "Makes Versus Boss Spawns obey cvars",
	version = "1.0",
	url = "http://compl4d2.com/"
}

new Handle:hCvarEnabled;
new Handle:hCvarSkipC7M1;


public OnPluginStart()
{
	hCvarEnabled = CreateConVar("l4d_obey_boss_spawn_cvars", "0", "Enable forcing boss spawns to obey boss spawn cvars");
	hCvarSkipC7M1 = CreateConVar("l4d_obey_boss_spawn_except_c7m1", "0", "Don't override boss spawning rules on c7m1 (which has a tank spawn even with tank chance 0)");
}


public Action:L4D_OnGetScriptValueInt(const String:key[], &retVal)
{
	if(GetConVarBool(hCvarEnabled))
	{
		if(StrEqual(key, "DisallowThreatType"))
		{
			// Stop allowing threat types!
			retVal = 0;
			return Plugin_Handled;
		}
		
		if(StrEqual(key, "ProhibitBosses"))
		{
			// Fuck that!
			retVal = 0;
			return Plugin_Handled;		
		}
	}
	return Plugin_Continue;


}

public Action:L4D_OnGetMissionVSBossSpawning(&Float:spawn_pos_min, &Float:spawn_pos_max, &Float:tank_chance, &Float:witch_chance)
{
	if(GetConVarBool(hCvarEnabled))
	{
		if(GetConVarBool(hCvarSkipC7M1))
		{
			decl String:mapbuf[32];
			GetCurrentMap(mapbuf, sizeof(mapbuf));
			if(StrEqual(mapbuf, "c7m1_docks"))
			{
				return Plugin_Continue;
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
