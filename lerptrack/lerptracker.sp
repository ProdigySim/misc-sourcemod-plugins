#pragma semicolon 1
#include <sourcemod>

//#define clamp(%0, %1, %2) ( ((%0) < (%1)) ? (%1) : ( ((%0) > (%2)) ? (%2) : (%0) ) )
#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

public Plugin:myinfo = 
{
	name = "LerpTracker",
	author = "ProdigySim",
	description = "Keep track of players' lerp settings",
	version = "0.1",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
}

new Handle:hMinUpdateRate;
new Handle:hMaxUpdateRate;
new Handle:hMinInterpRatio;
new Handle:hMaxInterpRatio;

public OnPluginStart()
{
	hMinUpdateRate = FindConVar("sv_minupdaterate");
	hMaxUpdateRate = FindConVar("sv_maxupdaterate");
	hMinInterpRatio = FindConVar( "sv_client_min_interp_ratio" );
	hMaxInterpRatio= FindConVar( "sv_client_max_interp_ratio" );
}


/* Lerp calculation adapted from hl2sdk's CGameServerClients::OnClientSettingsChanged */
public OnClientSettingsChanged(client)
{
	new Float:lerp = GetLerpTime(client);
	PrintToChatAll("%N's lerp %fms", client, lerp);
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