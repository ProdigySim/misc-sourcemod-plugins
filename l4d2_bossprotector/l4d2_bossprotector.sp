#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>

// global definitions
#define DATA_COUNT 2
#define ZOMBIECLASS_TANK 8
#define TEAM_INFECTED 3

public Plugin:myinfo = 
{
	name = "L4D2 Infected Boss Protect",
	author = "Blade, ProdigySim, DieTeetasse",
	description = "Negate damage taken from the environment.",
	version = "1.0",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
}
 
// 0 = map, 1 = attacker entityclassname
static String:dataStrings[DATA_COUNT][2][] = {
	{ "c2m3_coaster", "trigger_hurt" },
	{ "c5m3_cemetery", "point_hurt" }};
// 0 = inflictor, 1 = damagetype, 2 = (min) dmg
static dataValues[DATA_COUNT][3] = {
	{ 4095, 1, 500 },
	{ 4095, 64, 10000 }};
static numEnabled = -1;
	
public OnPluginStart() {
	HookEvent("witch_spawn", Event_WitchSpawn);
}
	
public Event_WitchSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
	new witchEntity = GetEventInt(event, "witchid");
	
	// valid witch?
	if (!IsValidEdict(witchEntity)) return;
	// hook her
	SDKHook(witchEntity, SDKHook_OnTakeDamage, SDKHooks_OnTakeDamage);
}
	
public OnMapStart() {
	decl String:mapName[64];
	GetCurrentMap(mapName, 64);
	
	// current map in array?
	for (new i = 0; i < DATA_COUNT; i++) {
		if (StrEqual(mapName, dataStrings[i][0])) {
			numEnabled = i;
			return;
		}
	}
	
	numEnabled = -1;
}

public Action:SDKHooks_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	// enabled?
	if (numEnabled == -1) return Plugin_Continue;
	
	// victim is a valid tank/witch?
	if (!IsValidEdict(victim)) return Plugin_Continue;
	
	// a witch bitch?
	new bool:isWitch = false;
	decl String:victimClass[64];
	GetEdictClassname(victim, victimClass, 64);
		
	if (StrEqual(victimClass, "witch")) {
		// ok, its a witch... skip next three checks
		isWitch = true;
	}
	
	// skip if witch
	if (!isWitch) {
		if (!IsClientInGame(victim)) return Plugin_Continue;
		if (GetClientTeam(victim) != TEAM_INFECTED) return Plugin_Continue;	
		if (GetEntProp(victim, Prop_Send, "m_zombieClass") != ZOMBIECLASS_TANK) return Plugin_Continue;
	}
	
	// attacker is valid?
	if (!IsValidEdict(attacker)) return Plugin_Continue;
	
	// attacker got right class?
	decl String:attackerClass[64];
	GetEdictClassname(attacker, attackerClass, 64);
	if (!StrEqual(attackerClass, dataStrings[numEnabled][1])) return Plugin_Continue;
	
	// inflictor, damagetype and mindamage?
	if (inflictor != dataValues[numEnabled][0]) return Plugin_Continue;
	if (damagetype != dataValues[numEnabled][1]) return Plugin_Continue;
	if (RoundToNearest(damage) < dataValues[numEnabled][2]) return Plugin_Continue;
	
	return Plugin_Handled;
}