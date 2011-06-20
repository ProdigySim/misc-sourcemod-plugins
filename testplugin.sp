#pragma semicolon 1
#include <sourcemod>
#include <weapons.inc>
#include <survivors.inc>
#include "gamemodes.inc"

public OnPluginStart()
{
	L4D2Survivors_Init();
	L4D2Weapons_Init();
	HookEvent("item_pickup", EventItemPickup);
	RegConsoleCmd("parse_gamemode", ParseGameModeCmd);
	HookEvent("round_start", RoundStartEvent);
}

public RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new entcnt = GetEntityCount();
	for(new i=1; i < entcnt;i++)
	{
		if(IdentifyWeapon(i) == WEPID_RIFLE_AK47)
		{
			new ent = ConvertWeaponSpawn(i, WEPID_SMG);
			PrintToChatAll("AK47 %d converted to SMG %d", i,ent);
			PrintToServer("AK47 %d converted to SMG %d", i, ent);
		}
	}
}

public EventItemPickup(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:buf[64], client;
	GetEventString(event, "item", buf, sizeof(buf));
	client = GetClientOfUserId(GetEventInt(event, "userid"));
	new WeaponId:wepid= WeaponNameToId(buf);
	PrintToChatAll("Weapon %s Id %d picked up by survivor %d", buf, wepid, IdentifySurvivor(client));
	PrintToServer("Weapon %s Id %d picked up by survivor %d", buf, wepid, IdentifySurvivor(client));

}

public Action:ParseGameModeCmd(client, args)
{
	new L4D2GameMode:id, L4D2GameMode:base;
	decl String:buf[64];
	GetConVarString(FindConVar("mp_gamemode"), buf, sizeof(buf));
	id=GameModeStringToId(buf);
	base=GetBaseGameMode(id);
	ReplyToCommand(client, "Gamemode: %s Id: %d Base: %d", buf, id, base);

	DoExperiment(client);
	return Plugin_Handled;
}

DoExperiment(client)
{
	if(FileExists("scripts/gamemodes.txt"))
	{
		ReplyToCommand(client, "On Normal: yes");
	}
	if(FileExists("scripts/gamemodes.txt", true))
	{
		ReplyToCommand(client, "On ValveFS: yes");
	}
	new Handle:kv=CreateKeyValues("GameModes");
	if(FileToKeyValues(kv, "scripts/gamemodes.txt"))
	{
		ReplyToCommand(client, "Got the KV thx");
	}
	CloseHandle(kv);

}
