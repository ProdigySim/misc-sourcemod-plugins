#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdktools_functions> 
#include <sdkhooks>
#include <timers.inc>

#define REPETITION_CHECK_TIME   0.75
#define JOCKEY_KILL_TIME        0.1
#define TANK_INTEAM_DAMAGE      250.0
#define ZC_JOCKEY               5

enum TankOrSIWeapon
{
    TANKWEAPON,
    SIWEAPON
}

new Handle: hPluginEnabled;
new bool: bPluginEnabled;
new bool:bLateLoad;

new Handle: hTankPunchDamage = INVALID_HANDLE;                  // convar tank damage in vs
new Float: fTankPunchDamage;

new Float: fPlayerPreviousHit[MAXPLAYERS + 1][MAXPLAYERS + 1];  // when was the previous attack from the client (EngineTime)

new Handle: hInflictorTrie = INVALID_HANDLE; // Names to look up

/*
    -----------------------------------------------------------------------------------------------------------------------------------------------------

    Changelog
    ---------
        0.2c
            - kills jockey on survivor also if damage is unglitched, for consistency's sake
            
        0.2b
            - now behaves well with multi-punches on multiple jockey-ridden-survivors
            
        0.2a
            - used what Jahze did better in his jockey glitch fix (lateload, simpler 'jockey tracking', less inefficient OnTakeDamage spaghetti)
            - stripped further redundant code 
            
        0.1b
            - added in some safeguards to prevent false positives
            - fixed spit damage problems, only tests repetition damage on claws now
            
        0.1a
            - Tank: blocks any extra damage that punches/rocks do on jockeyed survivor, and kills jockey instead
            - other SI: blocks repeted attacks within a timeframe from a single attacker on a jockeyed survivor, to prevent the double hits

    -----------------------------------------------------------------------------------------------------------------------------------------------------
 */


public Plugin:myinfo = 
{
    name = "Jockey Glitch Fix",
    author = "Tabun, Jahze",
    description = "Fixes Valve's jockey-damage redirection glitch.",
    version = "0.2c",
    url = "nope"
}

/* -------------------------------
 *      Init
 * ------------------------------- */

public APLRes:AskPluginLoad2( Handle:plugin, bool:late, String:error[], errMax) {
    bLateLoad = late;
    return APLRes_Success;
}

public OnPluginStart()
{
    // hook already existing clients if loading late
    if (bLateLoad) {
        for (new i = 1; i < MaxClients+1; i++) {
            if (IsClientInGame(i)) {
                SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
            }
        }
    }
    
    // cvars
    hPluginEnabled = CreateConVar("sm_jockeyglitchfix_enabled", "1", "Enable the fix for the jockey-damage glitch.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    bPluginEnabled = GetConVarBool(hPluginEnabled);
    HookConVarChange(hPluginEnabled, ConVarChange_PluginEnabled);

    hTankPunchDamage = FindConVar("vs_tank_damage");
    if (hTankPunchDamage != INVALID_HANDLE)
    {
        fTankPunchDamage = GetConVarFloat(hTankPunchDamage);
        HookConVarChange(hTankPunchDamage, ConVarChange_TankPunchDamage);
    } else {
        fTankPunchDamage = 24.0;  // default
    }
    
    // hooks
    HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
    hInflictorTrie = BuildInflictorTrie();
}


/* -------------------------------
 *      General hooks / events
 * ------------------------------- */

public OnClientPostAdminCheck(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnMapStart()
{
    setCleanSlate();
}

public Action: RoundStart_Event (Handle:event, const String:name[], bool:dontBroadcast)
{
    setCleanSlate();
}


/* -------------------------------
 *      CONVAR CHANGES
 * ------------------------------- */

public ConVarChange_PluginEnabled(Handle:cvar, const String:oldValue[], const String:newValue[]) {
    if (StringToInt(newValue) == 0) { bPluginEnabled = false; } else { bPluginEnabled = true; }
}

public ConVarChange_TankPunchDamage(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    fTankPunchDamage = StringToFloat(newValue);
}


/* --------------------------------------
 *     GOT MY EYES ON YOU, DAMAGE
 * -------------------------------------- */

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damageType, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
    if (!bPluginEnabled) { return Plugin_Continue; }
    if (!inflictor || !attacker || !victim || !IsValidEdict(victim) || !IsValidEdict(inflictor)) { return Plugin_Continue; }
    
    // only check jockeyed survivors, don't check jockey's own damage
    new iJockeyAttacker = GetEntPropEnt(victim, Prop_Send, "m_jockeyAttacker");
    if (!IsClientAndInGame(iJockeyAttacker) || GetEntProp(iJockeyAttacker, Prop_Send, "m_zombieClass") != ZC_JOCKEY) { return Plugin_Continue; }
    
    // only check player-to-player damage
    decl String:classname[64];
    if (IsClientAndInGame(attacker) && IsClientAndInGame(victim))
    {
        if (attacker == inflictor)                                              // for claws
        {
            GetClientWeapon(inflictor, classname, sizeof(classname));
        }
        else
        {
            GetEdictClassname(inflictor, classname, sizeof(classname));         // for tank punch/rock
        }
    }
    else { return Plugin_Continue; }
    
    // only check tank punch/rock and SI claws (also rules out anything but infected-to-survivor damage)
    new TankOrSIWeapon:inflictorID;
    if(!GetTrieValue(hInflictorTrie, classname, inflictorID))
    {
        return Plugin_Continue;
    }
    
    new bool: bTankHit = (inflictorID == TANKWEAPON);
        
    // now we know that damage is done by infected, on a jockeyed survivor, by a potentially problematic inflictor
    // fix both (a) doubling of damage, and (b) tank damage

    // Repetition -- any class, including tank, track time
    new Float: oldTime = fPlayerPreviousHit[attacker][victim];
    fPlayerPreviousHit[attacker][victim] = GetEngineTime();
    
    if (oldTime != 0.0 && FloatSub((fPlayerPreviousHit[attacker][victim]), oldTime) < REPETITION_CHECK_TIME)
    {
        PrintToServer("[jgf] glitched damage prevented on jockeyed survivor (%s, doubled). (%.0f damage nullified).", classname, damage);
        fPlayerPreviousHit[attacker][victim] = 0.0;
        return Plugin_Handled;
    }
    
    // Tank rock/punch
    if (bTankHit && damage == TANK_INTEAM_DAMAGE && damage != fTankPunchDamage)
    {
        PrintToServer("[jgf] glitched damage prevented on jockeyed survivor (%s). (%.0f => %.0f damage).", classname, damage, fTankPunchDamage);
        CreateTimer(JOCKEY_KILL_TIME, destroyJockey, iJockeyAttacker);
        damage = fTankPunchDamage;
        return Plugin_Changed;
    }
    else if (bTankHit)
    {
        // kill jockey (the punch/rock dislodged it)
        CreateTimer(JOCKEY_KILL_TIME, destroyJockey, iJockeyAttacker);
    }
    
    return Plugin_Continue;
}

public Action:destroyJockey(Handle:timer, any:jockeyClient)
{
    ForcePlayerSuicide(jockeyClient);
}
    
    
/* --------------------------------------
 *     Shared function(s)
 * -------------------------------------- */

bool:IsClientAndInGame(index)
{
    return (index > 0 && index <= MaxClients && IsClientInGame(index));
}

// just a safeguard at round start / clear timer status
setCleanSlate()
{
    new i, j, maxplayers = MaxClients;
    for (i = 1; i <= maxplayers; i++)
    {
        for (j = 1; j <= maxplayers; j++)
        {
            fPlayerPreviousHit[i][j] = 0.0;
        }
    }
}

Handle:BuildInflictorTrie()
{
    new Handle:trie = CreateTrie();
    SetTrieValue(trie, "weapon_tank_claw", TANKWEAPON);
    SetTrieValue(trie, "tank_rock", TANKWEAPON);
    SetTrieValue(trie, "weapon_boomer_claw", SIWEAPON);
    SetTrieValue(trie, "weapon_charger_claw", SIWEAPON);
    SetTrieValue(trie, "weapon_hunter_claw", SIWEAPON);
    SetTrieValue(trie, "weapon_jockey_claw", SIWEAPON);
    SetTrieValue(trie, "weapon_smoker_claw", SIWEAPON);
    SetTrieValue(trie, "weapon_spitter_claw", SIWEAPON);
    return trie;    
}