#include <sourcemod>
#include <sdktools>

new g_bUseAutoHops[MAXPLAYERS+1];

#define UseAutoHops(%0) (g_bUseAutoHops[(%0)])

public OnPluginStart()
{
	RegConsoleCmd("sm_autohop", AutohopCmd);
}

public OnClientDisconnect(client)
{
	g_bUseAutoHops[client] = false;
}

public Action:AutohopCmd(client, args)
{
		g_bUseAutoHops[client]=!g_bUseAutoHops[client];
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(UseAutoHops(client))
	{
		new flags = GetEntityFlags(client);
		if(!(flags & FL_ONGROUND))
		{
			buttons &= ~IN_JUMP;
		}
	}
	return Plugin_Continue;
}