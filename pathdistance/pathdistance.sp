new pathclient=-1;
new fPathLength;
new Float:fLastPoint[3]; // vector

public Plugin:myinfo = 
{
	name = "Path Distance Calculator",
	author = "ProdigySim",
	description = "Tracks path distance for a client",
	version = "1.0",
	url = "http://confogl.googlecode.com"
}

public OnPluginStart()
{
	RegConsoleCmd("sm_path_addpoint", AddPoint_Cmd, "Add a point to the current path being measured");
	RegConsoleCmd("sm_path_reset", ResetPath_Cmd, "Resets the path length");
	RegConsoleCmd("sm_path_display", Display_Cmd, "Display the current path data");
	RegAdminCmd("sm_path_hardreset", AdmResetPath_Cmd, ADMFLAG_GENERIC, "Resets the path length");
}

public OnMapStart()
{
	ResetPath();
}

public Action:Display_Cmd(client, args)
{
	if(client > 0)
		DisplayPath(client);
	else
		DisplayPath();
}

public Action:ResetPath_Cmd(client, args)
{
	if(pathclient == -1)
	{
		PrintToChat(client, "Path Already Reset!")
	}
	else if(pathclient == client)
	{
		ResetPath();
		PrintToChat(client, "Path Reset!");
	}
	else
	{
		PrintToChat(client, "Someone else is building a path. Ask them to reset.");
	}
}
public Action:AdmResetPath_Cmd(client, args)
{
	ResetPath();
	PrintToChat(client, "Path Reset!");
}

public Action:AddPoint_Cmd(client, args)
{
	static Float:clientOrigin[3];
	new bool:bInitialPoint = false;
	if(pathclient == -1)
	{
		bInitialPoint = true;
		pathclient = client;
		PrintToChat(client, "Starting new path...");
	}
	else if (client != pathclient)
	{
		PrintToChat(client, "Sorry, someone else is making a path.");
		return Plugin_Continue;
	}
	GetClientAbsOrigin(client, clientOrigin);
	AddPoint(clientOrigin, bInitialPoint);
	DisplayPath(client);
	return Plugin_Continue;
}

ResetPath()
{
	pathclient=-1
	fPathLength = 0;
	fLastPoint[0]=fLastPoint[1]=fLastPoint[2]=0.0;
}

DisplayPath(client=-1)
{
	if(client == -1)
	{
		PrintToChatAll("Path Length: %f Last Point: {%f, %f %f}", fPathLength, 
			fLastPoint[0], fLastPoint[1], fLastPoint[2]);
	}
	else
	{
		PrintToChat(client, "Path Length: %f Last Point: {%f, %f %f}", fPathLength, 
			fLastPoint[0], fLastPoint[1], fLastPoint[2]);
	}

}

stock CopyVector(Float:dest[3], Float:source[3])
{
	dest[0]=source[0];
	dest[1]=source[1];
	dest[2]=source[2];
}

AddPoint(Float:fNewPoint[3], bool:initialpoint)
{
	if(initialpoint)
		fPathLength += GetVectorDistance(fLastPoint, fNewPoint);
	CopyVector(fLastPoint, fNewPoint);
}