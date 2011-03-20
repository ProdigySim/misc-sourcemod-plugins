#pragma semicolon 1

#include <sourcemod>
#include <l4d2lib>


public Plugin:myinfo =
{
	name = "L4D2Lib Test Plugin",
	author = "Confogl Team",
	description = "Test L4DLib's functionality",
	version = "1.0",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_getround", GetRoundCmd, "L4D2 GetCurrentRound(), L4D2_CurrentlyInRound()");
}

public L4D2_OnRealRoundStart(roundNumber)
{
	PrintToChatAll("RealRoundStart(%d)", roundNumber);

}

public L4D2_OnRealRoundEnd(roundNumber)
{
	PrintToChatAll("RealRoundEnd(%d)", roundNumber);
}


public Action:GetRoundCmd(client, args)
{
	ReplyToCommand(client, "Current Round: %d Currently in round? %s", L4D2_GetCurrentRound(), L4D2_CurrentlyInRound() ? "Yes" : "No");
	return Plugin_Handled;
}