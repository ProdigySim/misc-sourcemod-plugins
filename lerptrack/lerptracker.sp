#pragma semicolon 1
#include <sourcemod>

//#define clamp(%0, %1, %2) ( ((%0) < (%1)) ? (%1) : ( ((%0) > (%2)) ? (%2) : (%0) ) )
#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

public Plugin:myinfo = 
{
	name = "LerpTracker",
	author = "ProdigySim",
	description = "Keep track of players' lerp settings",
	version = "0.6",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
};

/* Global Vars */
new Float:g_fCurrentLerps[MAXPLAYERS+1];

/* My CVars */
new Handle:hLogLerp;
new Handle:hAnnounceLerp;
new Handle:hFixLerpValue;

/* Valve CVars */
new Handle:hMinUpdateRate;
new Handle:hMaxUpdateRate;
new Handle:hMinInterpRatio;
new Handle:hMaxInterpRatio;

// psychonic made me do it

#define ShouldFixLerp() (GetConVarBool(hFixLerpValue))

#define ShouldAnnounceLerp() (GetConVarBool(hAnnounceLerp))

#define ShouldLogLerp() (GetConVarBool(hLogLerp))

#define IsCurrentLerpValid(%0) (g_fCurrentLerps[(%0)] >= 0.0)

#define InvalidateCurrentLerp(%0) (g_fCurrentLerps[(%0)] = -1.0)

#define GetCurrentLerp(%0) (g_fCurrentLerps[(%0)])
#define SetCurrentLerp(%0,%1) (g_fCurrentLerps[(%0)] = (%1))

public OnPluginStart()
{
	hMinUpdateRate = FindConVar("sv_minupdaterate");
	hMaxUpdateRate = FindConVar("sv_maxupdaterate");
	hMinInterpRatio = FindConVar("sv_client_min_interp_ratio");
	hMaxInterpRatio= FindConVar("sv_client_max_interp_ratio");
	hLogLerp = CreateConVar("sm_log_lerp", "1", "Log changes to client lerp", FCVAR_PLUGIN);
	hAnnounceLerp = CreateConVar("sm_announce_lerp", "1", "Announce changes to client lerp", FCVAR_PLUGIN);
	hFixLerpValue = CreateConVar("sm_fixlerp", "0", "Fix Lerp values clamping incorrectly when interp_ratio 0 is allowed", FCVAR_PLUGIN);
	
	RegConsoleCmd("sm_lerps", Lerps_Cmd, "List the Lerps of all players in game", FCVAR_PLUGIN);
	
	ScanAllPlayersLerp();
}

public OnClientDisconnect_Post(client)
{
	InvalidateCurrentLerp(client);
}

/* Lerp calculation adapted from hl2sdk's CGameServerClients::OnClientSettingsChanged */
public OnClientSettingsChanged(client)
{
	if(IsValidEntity(client) &&  !IsFakeClient(client))
	{
		ProcessPlayerLerp(client);
	}
}

public Action:Lerps_Cmd(client, args)
{
	new lerpcnt;
	for(new rclient=1; client <= MaxClients; rclient++)
	{
		if(IsClientInGame(rclient) && !IsFakeClient(rclient))
		{
			ReplyToCommand(client, "%02d. %N Lerp: %.01f", ++lerpcnt, rclient, (GetCurrentLerp(rclient)*1000));
		}
	}
	return Plugin_Handled;
}

ScanAllPlayersLerp()
{
	for(new client=1; client <= MaxClients; client++)
	{
		InvalidateCurrentLerp(client);
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			ProcessPlayerLerp(client);
		}
	}
}

ProcessPlayerLerp(client)
{	
	new Float:m_fLerpTime = GetEntPropFloat(client, Prop_Data, "m_fLerpTime");
	
	if(ShouldFixLerp())
	{
		m_fLerpTime = GetLerpTime(client);
		SetEntPropFloat(client, Prop_Data, "m_fLerpTime", m_fLerpTime);
	}
	
	if(IsCurrentLerpValid(client))
	{
		if(m_fLerpTime != GetCurrentLerp(client))
		{
			if(ShouldAnnounceLerp())
			{
				PrintToChatAll("%N's LerpTime Changed from %.01f to %.01f", client, GetCurrentLerp(client)*1000, m_fLerpTime*1000);
			}
			if(ShouldLogLerp())
			{
				LogMessage("%N's LerpTime Changed from %.01f to %.01f", client, GetCurrentLerp(client)*1000, m_fLerpTime*1000);
			}
		}
	}
	else
	{
		if(ShouldAnnounceLerp())
		{
			PrintToChatAll("%N's LerpTime set to %.01f", client, m_fLerpTime*1000);
		}
		if(ShouldLogLerp())
		{
			LogMessage("%N's LerpTime set to %.01f", client, m_fLerpTime*1000);
		}
	}
	SetCurrentLerp(client, m_fLerpTime);
}



stock Float:GetLerpTime(client)
{
	decl String:buf[64], Float:lerpTime;
	
#define QUICKGETCVARVALUE(%0) (GetClientInfo(client, (%0), buf, sizeof(buf)) ? buf : "")
	
	new updateRate = StringToInt( QUICKGETCVARVALUE("cl_updaterate") );
	updateRate = RoundFloat(clamp(float(updateRate), GetConVarFloat(hMinUpdateRate), GetConVarFloat(hMaxUpdateRate)));
	
	/*new bool:useInterpolation = StringToInt( QUICKGETCVARVALUE("cl_interpolate") ) != 0;
	if ( useInterpolation )
	{*/
	new Float:flLerpRatio = StringToFloat( QUICKGETCVARVALUE("cl_interp_ratio") );
	/*if ( flLerpRatio == 0 )
		flLerpRatio = 1.0;*/
	new Float:flLerpAmount = StringToFloat( QUICKGETCVARVALUE("cl_interp") );

	
	if ( hMinInterpRatio != INVALID_HANDLE && hMaxInterpRatio != INVALID_HANDLE && GetConVarFloat(hMinInterpRatio) != -1.0 )
	{
		flLerpRatio = clamp( flLerpRatio, GetConVarFloat(hMinInterpRatio), GetConVarFloat(hMaxInterpRatio) );
	}
	else
	{
		/*if ( flLerpRatio == 0 )
			flLerpRatio = 1.0;*/
	}
	lerpTime = MAX( flLerpAmount, flLerpRatio / updateRate );
	/*}
	else
	{
		lerpTime = 0.0;
	}*/
	
#undef QUICKGETCVARVALUE
	return lerpTime;
}

stock Float:clamp(Float:in, Float:low, Float:high)
{
	return in > high ? high : (in < low ? low : in);
}