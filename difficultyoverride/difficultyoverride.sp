#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>

public Plugin:myinfo = 
{
	name = "L4D2 Difficulty Override",
	author = "ProdigySim",
	description = "Overrides game difficulty",
	version = "1.0",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
}

enum L4D_Difficulty {
	Diff_Easy=0,
	Diff_Normal,
	Diff_Hard,
	Diff_Impossible
}

new Handle:ghDifficultyTrie;
new Handle:ghCvarEnabled;
new L4D_Difficulty:giDifficulty = Diff_Normal;

public OnPluginStart()
{
	ghCvarEnabled = CreateConVar("l4d2_force_difficulty", "0", "Enforce z_difficulty in all game modes");
	ghDifficultyTrie = CreateDifficultyTrie();
	new Handle:CvarDifficulty = FindConVar("z_difficulty");
	
	decl String:difficulty[32];
	GetConVarString(CvarDifficulty, difficulty, sizeof(difficulty));
	
	giDifficulty = GetDifficultyFromString(difficulty);
	
	HookConVarChange(CvarDifficulty, CvarDifficultyChanged);
	
}

public CvarDifficultyChanged(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
	giDifficulty = GetDifficultyFromString(newvalue);
}

public Action:L4D_OnGetDifficulty(&retVal)
{
	if(GetConVarBool(ghCvarEnabled))
	{
		retVal = _:giDifficulty;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

Handle:CreateDifficultyTrie()
{
	new Handle:myTrie = CreateTrie();
	SetTrieValue(myTrie, "easy", Diff_Easy);
	SetTrieValue(myTrie, "normal", Diff_Normal);
	SetTrieValue(myTrie, "hard", Diff_Hard);
	SetTrieValue(myTrie, "impossible", Diff_Impossible);
	return myTrie;	
}

L4D_Difficulty:GetDifficultyFromString(const String:difficulty[])
{
	decl L4D_Difficulty:diff;
	
	new len=strlen(difficulty);
	
	new String:lowdiff[len+1];
	for(new i; i < len; i++)
		lowdiff[i] = CharToLower(difficulty[i]);
	
	lowdiff[len] = 0;
	
	return GetTrieValue(ghDifficultyTrie, lowdiff, diff) ? diff : Diff_Normal;
}


