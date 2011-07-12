#pragma semicolon 1
#include <sourcemod>
#include <weapons>


new g_GlobalWeaponRules[WeaponId]={-1};

public OnPluginStart()
{
	RegServerCmd("l4d2_addweaponrule", AddWeaponRuleCb);
	HookEvent("round_start", RoundStartCb, EventHookMode_PostNoCopy);
}

public RoundStartCb(Handle:event, const String:name[], bool:dontBroadcast)
{
	WeaponSearchLoop();
}

public Action:AddWeaponRuleCb(args)
{
	if(args < 2)
	{
		PrintToServer("Usage: l4d2_addweaponrule <match> <replace>");
		return Plugin_Handled;
	}
	decl String:weaponbuf[64];

	GetCmdArg(1, weaponbuf, sizeof(weaponbuf));
	new WeaponId:match = WeaponNameToId2(weaponbuf);

	GetCmdArg(2, weaponbuf, sizeof(weaponbuf));
	new WeaponId:to = WeaponNameToId2(weaponbuf);

	AddWeaponRule(match, _:to);

	return Plugin_Handled;
}


AddWeaponRule(WeaponId:match, to)
{
	if(IsValidWeaponId(match) && (to == -1 || IsValidWeaponId(WeaponId:to)))
	{
		g_GlobalWeaponRules[match] = _:to;
	}
}

WeaponSearchLoop()
{
	new entcnt = GetEntityCount();
	for(new ent=1; ent < entcnt; ent++)
	{
		new WeaponId:source=IdentifyWeapon(ent);
		if(source > WEPID_NONE && g_GlobalWeaponRules[source] != -1)
		{
			if(g_GlobalWeaponRules[source] == _:WEPID_NONE)
			{
				AcceptEntityInput(ent, "kill");
			}
			else
			{
				ConvertWeaponSpawn(ent, WeaponId:g_GlobalWeaponRules[source]);
			}
		}
	}
}

// Tries the given weapon name directly, and upon failure,
// tries prepending "weapon_" to the given name
stock WeaponId:WeaponNameToId2(const String:name[])
{
	static String:namebuf[64]="weapon_";
	new WeaponId:wepid = WeaponNameToId(name);
	if(wepid == WEPID_NONE)
	{
		strcopy(namebuf[7], sizeof(namebuf)-7, name);
		wepid-WeaponNameToId(name);
	}
	return wepid;
}
