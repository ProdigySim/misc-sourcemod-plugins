#pragma semicolon 1
#include <sourcemod>

//#define clamp(%0, %1, %2) ( ((%0) < (%1)) ? (%1) : ( ((%0) > (%2)) ? (%2) : (%0) ) )
#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

public Plugin:myinfo = 
{
	name = "LerpTracker",
	author = "ProdigySim",
	description = "Keep track of players' lerp settings",
	version = "0.2",
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

bool:ShouldFixLerp() { return GetConVarBool(hFixLerpValue); }

bool:ShouldAnnounceLerp() { return GetConVarBool(hAnnounceLerp); }

bool:ShouldLogLerp() { return GetConVarBool(hLogLerp); }

bool:IsCurrentLerpValid(client) { return (g_fCurrentLerps[client] >= 0.0); }

InvalidateCurrentLerp(client) { g_fCurrentLerps[client] = -1.0; }

Float:GetCurrentLerp(client) { return g_fCurrentLerps[client]; }
SetCurrentLerp(client, Float:lerp) {  g_fCurrentLerps[client] = lerp; }

public OnPluginStart()
{
	hMinUpdateRate = FindConVar("sv_minupdaterate");
	hMaxUpdateRate = FindConVar("sv_maxupdaterate");
	hMinInterpRatio = FindConVar("sv_client_min_interp_ratio");
	hMaxInterpRatio= FindConVar("sv_client_max_interp_ratio");
	hLogLerp = CreateConVar("sm_log_lerp", "1", "Log changes to client lerp");
	hAnnounceLerp = CreateConVar("sm_announce_lerp", "1", "Announce changes to client lerp");
	hFixLerpValue = CreateConVar("sm_fixlerp", "0", "Fix Lerp values clamping incorrectly when interp_ratio 0 is allowed");
	
	ScanAllPlayersLerp();
}

public OnClientDisconnect_Post(client)
{
		InvalidateCurrentLerp(client);
}

/* Lerp calculation adapted from hl2sdk's CGameServerClients::OnClientSettingsChanged */
public OnClientSettingsChanged(client)
{
	ProcessPlayerLerp(client);
}

ScanAllPlayersLerp()
{
	new maxclients = GetMaxClients();
	for(new client=1; client < maxclients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			ProcessPlayerLerp(client);
		}
	}
}

ProcessPlayerLerp(client)
{
	if(IsFakeClient(client)) return;
	
	new Float:lerp = GetLerpTime(client);
	new Float:m_fLerpTime = GetEntPropFloat(client, Prop_Data, "m_fLerpTime");
	
	if(ShouldFixLerp())
	{
		SetEntPropFloat(client, Prop_Data, "m_fLerpTime", lerp);
		m_fLerpTime = lerp;
	}
	
	if(IsCurrentLerpValid(client) && m_fLerpTime != GetCurrentLerp(client))
	{
		if(ShouldAnnounceLerp())
		{
			PrintToChatAll("%N's LerpTime Changed from %.02f to %.02f", client, GetCurrentLerp(client)*100, m_fLerpTime*100);
		}
		if(ShouldLogLerp())
		{
			LogMessage("%N's LerpTime Changed from %.02f to %.02f", client, GetCurrentLerp(client)*100, m_fLerpTime*100);
		}
	}
	else
	{
		if(ShouldAnnounceLerp())
		{
			PrintToChatAll("%N's LerpTime set to %.02f", client, m_fLerpTime*100);
		}
		if(ShouldLogLerp())
		{
			LogMessage("%N's LerpTime set to %.02f", client, m_fLerpTime*100);
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