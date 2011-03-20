#pragma semicolon 1
#include <sourcemod>
#include <sdktools>


public Plugin:myinfo = 
{
	name = "SetRates",
	author = "ProdigySim",
	description = "Set Player Rates (EXPERIMENTAL)",
	version = "0.1",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
};

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_setrate", SetRate_Cmd, ADMFLAG_ROOT, "Set a player's rate", "", FCVAR_PLUGIN);
}

public Action:SetRate_Cmd(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "Not enough arguments");
		ReplyToCommand(client, "Usage: sm_setrate <target> <rate>");
		return Plugin_Handled;
	}

	decl String:argbuf[32];
	decl rate;
	GetCmdArg(2, argbuf, sizeof(argbuf));
	if(StringToIntEx(argbuf, rate) == 0)
	{
		ReplyToCommand(client, "Rate must be integer");
		ReplyToCommand(client, "Usage: sm_setrate <target> <rate>");
	}
	GetCmdArg(1, argbuf, sizeof(argbuf));
	new target = FindTarget(client, argbuf);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	IntToString(rate, argbuf, sizeof(argbuf));
	
	SetClientInfo(target, "rate", argbuf);
	ShowActivity2(client, "[SM]", "Set rate %d on %N", rate, target);
	return Plugin_Handled;
}
