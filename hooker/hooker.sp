#pragma semicolon 1
#include <sourcemod>

#define PLUGIN_VERSION "v.dongues"

public Plugin:myinfo =
{
	name = "Sourcemod Hooker Plugin",
	author = "Lindsey Lohan",
	description = " Brothel ",
	version = PLUGIN_VERSION,
	url = "http://prodigysim.com/l4d2/plugins/"
};

public OnPluginStart()
{
	RegAdminCmd("sm_hookevent", _Hooker_HookCmdCallback, ADMFLAG_CONFIG, "[Hooker] Hook an event");
	RegAdminCmd("sm_unhookevent", _Hooker_UnhookCmdCallback, ADMFLAG_CONFIG, "[Hooker] Unhook an event");
	
}

public Action:_Hooker_HookCmdCallback(client, args)
{
	if (args <1)
	{
		ReplyToCommand(client, "[Hooker] Need an event name plz");
		return Plugin_Handled;
	}
	decl String:buf[64];
	GetCmdArg(1, buf, sizeof(buf));
	if(strlen(buf))
	{
		if(HookEventEx(buf, _Hooker_HookCallBack))
			ReplyToCommand(client, "[Hooker] Event %s hooked successfully", buf);
		else
			ReplyToCommand(client, "[Hooker] Couldn't hook event %s", buf);
	}
	else
	{
		ReplyToCommand(client, "[Hooker] Couldn't read command argument. sry");
	}
	return Plugin_Handled;
}

public Action:_Hooker_UnhookCmdCallback(client, args)
{
	if (args <1)
	{
		ReplyToCommand(client, "[Hooker] Need an event name plz");
		return Plugin_Handled;
	}
	decl String:buf[64];
	GetCmdArg(1, buf, sizeof(buf));
	if(strlen(buf))
	{
		UnhookEvent(buf, _Hooker_HookCallBack);
		ReplyToCommand(client, "[Hooker] Unhooked Event %s", buf);
	}
	else
	{
		ReplyToCommand(client, "[Hooker] Couldn't read command argument. sry");
	}
	return Plugin_Handled;
}

public _Hooker_HookCallBack(Handle:event, const String:name[], bool:dontBroadcast)
{
	PrintToChatAll("[Hooker] EventFired: %s", name);
	PrintToServer("[Hooker] EventFired: %s", name);
}
