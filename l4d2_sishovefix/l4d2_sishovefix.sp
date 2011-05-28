#pragma semicolon 1
#include <sourcemod>
#include <left4downtown>


#define TEAM_INFECTED 3
#define ZOMBIECLASS_HUNTER	3
#define ZOMBIECLASS_JOCKEY 	5

static const ARRAY_SURVIVOR = 0;
static const ARRAY_INFECTED = 1;
static const ARRAY_TIMESTAMP = 2;
static const ARRAY_VECTOR = 3;
static const ARRAY_COUNT = 4;

static const MoSSF_shoveSaveInterval = 3;
static const Float:MoSSF_shoveDifference = 350.0;
static const Float:MoSSF_shoveModifyAngle = 90.0;

static Handle:MoSSF_lastShovesArray;

public Plugin:myinfo = 
{
	name = "L4D2 SI Shove Fix",
	author = "DieTeetasse, ProdigySim",
	description = "Re-inforce shoves on hunters and jockeys to stop instant repounces.",
	version = "1.0",
	url = "http://bitbucket.org/ProdigySim/misc-sourcemod-plugins/"
}

public OnPluginStart() {
	/*
	 * Array indices:
	 * 0	survivor player
	 * 1	infected player
	 * 2	timestamp
	 * 3	vector
	 */
	MoSSF_lastShovesArray = CreateArray(3);
}
 
public Action:L4D_OnShovedBySurvivor(client, victim, const Float:vector[3]) {
	new bool:oldShove;
	new Float:newVector[3], Float:oldVector[3];
	new currentTimestamp = GetTime();
	
	// get zombie class
	if (!IsClientInGame(victim)) return Plugin_Continue;
	if (GetClientTeam(victim) != TEAM_INFECTED) return Plugin_Continue;	
	new zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
	// check it (only apply the new shove to hunter and jockey)
	if (!((zombieClass == ZOMBIECLASS_HUNTER) || (zombieClass == ZOMBIECLASS_JOCKEY))) {
		return Plugin_Continue;
	}
	
	// find an old shove
	new deleteIndex = -1;
	for (new i = 0; i < (GetArraySize(MoSSF_lastShovesArray) / ARRAY_COUNT); i++) {
		if (client != GetArrayCell(MoSSF_lastShovesArray, (i * ARRAY_COUNT) + ARRAY_SURVIVOR)) continue;
		if (victim != GetArrayCell(MoSSF_lastShovesArray, (i * ARRAY_COUNT) + ARRAY_INFECTED)) continue;
		
		if ((currentTimestamp - GetArrayCell(MoSSF_lastShovesArray, (i * ARRAY_COUNT) + ARRAY_TIMESTAMP)) <= MoSSF_shoveSaveInterval) {
			GetArrayArray(MoSSF_lastShovesArray, (i * ARRAY_COUNT) + ARRAY_VECTOR, oldVector);
			
			if (FloatCompare(GetVectorDistance(vector, oldVector), MoSSF_shoveDifference) < 1) {
				oldShove = true;
			}
		}
		
		// mark for deletion
		deleteIndex = i;
	}
	
		// delete old entry
	if (deleteIndex > -1) {
		for (new i = 0; i < ARRAY_COUNT; i++) RemoveFromArray(MoSSF_lastShovesArray, deleteIndex);
	}
	
	if (oldShove) {
		// get positions of client and victim
		decl Float:posCl[3], Float:posVic[3], Float:diffVec[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", posCl);
		GetEntPropVector(victim, Prop_Send, "m_vecOrigin", posVic);
		
		/*
		// get position behind infected
		SubtractVectors(posVic, posCl, diffVec);
		AddVectors(posVic, diffVec, newVector);
		*/
		
		// calc diff vector
		SubtractVectors(posCl, posVic, diffVec);
		
		// random if left or right
		new Float:angleDeg = MoSSF_shoveModifyAngle;
		if (GetRandomInt(0, 1) == 0) {
			angleDeg *= -1.0;
		}

		// calculate current angle
		new Float:curAngleRad = ArcTangent2(diffVec[0], diffVec[1]) + DegToRad(angleDeg);
		
		// calculate new vector
		new Float:length = GetVectorLength(diffVec);
		diffVec[0] = Sine(curAngleRad)*length;
		diffVec[1] = Cosine(curAngleRad)*length;
		diffVec[2] = 0.0;

		// calculate source vector
		AddVectors(posVic, diffVec, newVector);
	}
	else {
		newVector = vector;
	}
	
	// add new shove
	PushArrayCell(MoSSF_lastShovesArray, client);
	PushArrayCell(MoSSF_lastShovesArray, victim);
	PushArrayCell(MoSSF_lastShovesArray, currentTimestamp);
	PushArrayArray(MoSSF_lastShovesArray, newVector);
	
	if (oldShove) {
		// save data inside stack
		new Handle:tempStack = CreateStack(3);
		PushStackCell(tempStack, victim);
		PushStackArray(tempStack, newVector);
		
		// delay to apply new shove
		CreateTimer(0.1, MoSSF_Timer_StaggerVictim, tempStack);
	}
	return Plugin_Continue;
}

public Action:MoSSF_Timer_StaggerVictim(Handle:timer, any:tempStack) {
	decl Float:vector[3], victim;
	PopStackArray(tempStack, vector);
	PopStackCell(tempStack, victim);
	
	L4D_StaggerPlayer(victim, 0, vector);
}