#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
	name = "L4D Inaudible Ghosts",
	author = "AtomicStryker, DieTeeTasse, ProdigySim",
	description = "Keep survivors from hearing jumping infected ghosts.",
	version = "1.0",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
}


new isGhostOffset;
public OnPluginStart() {
	isGhostOffset = FindSendPropInfo("CTerrorPlayer", "m_isGhost"); // daHURRDURR
	AddNormalSoundHook(NormalSHook:SoundHook);
}

public Action:SoundHook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity) {
	// infected fall sound?
	if (!StrEqual(sample, "player/jumplanding_zombie.wav")) return Plugin_Continue;
	// infected in ghost mode?
	if (GetEntData(entity, isGhostOffset) != 0) return Plugin_Continue;
	
	// add infected and spectators to array
	numClients = 0;
	for (new i = 1; i < MaxClients+1; i++) {
		if (!IsClientInGame(i)) continue;
		if (IsFakeClient(i)) continue;
		if (GetClientTeam(i) != 3) continue; // team infected
		
		clients[numClients] = i;
		numClients++;
	}
		
	return Plugin_Changed;
}