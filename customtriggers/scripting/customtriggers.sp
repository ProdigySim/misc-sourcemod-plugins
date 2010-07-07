// Thanks to Thraka 

#include <sourcemod>

#define CVAR_FLAGS FCVAR_PLUGIN
#define PLUGIN_VERSION "0.1"
#define CT_BUFFER_LENGTH 64

#define CT_KV_LOCATION "configs/customtriggers.txt"

enum CVAR_TYPE
{
	CVAR_INT = 1,
	CVAR_FLOAT,
	CVAR_STRING
};

new Handle:CT_kSettings;
new Handle:CT_kTriggers;
new Handle:CT_kCommands;
new Handle:CT_kConVars;


public Plugin:myinfo = 
{
	name = "Custom Triggers",
	author = "ProdigySim",
	description = "Provides an interface for custom triggers, commands, and hooks for cvars based on keyvalue files",
	version = PLUGIN_VERSION,
	url = "http://boner/"
}

public OnPluginStart()
{
	decl String:sBuffer[CT_BUFFER_LENGTH];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), CT_KV_LOCATION)
	CT_KV_LoadFile(sBuffer);
	CT_KV_InitAll();
}

public Action:CT_CommandHandler(client, args)
{
	decl String:sBuffer[CT_BUFFER_LENGTH];
	GetCmdArg(0, sBuffer, sizeof(sBuffer));
	
	if(KvJumpToKey(CT_kCommands, sBuffer))
	{
		KvGetString(CT_kCommands, "exec", sBuffer, sizeof(sBuffer))
		CT_KV_ExecuteSetting(sBuffer);
		KvGoBack(CT_kCommands);
	}
	else
	{
		LogError("[CustomTriggers] CommandHandler error: Could not find key for command %s", sBuffer);
	}
}

public CT_ConVarHandler(Handle:convar, const String:oldValue[], const String:newValue[])
{
	decl String:sBuffer[CT_BUFFER_LENGTH];
	
	GetConVarName(convar, sBuffer, sizeof(sBuffer));
	
	if(KvJumpToKey(CT_kConVars, sBuffer))
	{
		CT_KV_ParseConVar(newValue);
		KvGoBack(CT_kConVars);
	}
	else
	{
		LogError("[CustomTriggers] ConVarHandler error: Could not find key for cvar %s", sBuffer);
	}
}

CT_KV_ParseConVar(const String:cvarval[])
{
	new type = KvGetNum(CT_kConVars, ";type;", 3);
	decl String:sBuffer[CT_BUFFER_LENGTH];
	
	switch(CVAR_TYPE:type)
	{
		case CVAR_INT:
		{
			new val1 = StringToInt(cvarval);
			IntToString(val1, sBuffer, sizeof(sBuffer));
		}
		case CVAR_FLOAT:
		{
			new Float:val1 = StringToFloat(cvarval);
			FloatToString(val1, sBuffer, sizeof(sBuffer));
		}
		default:
		{
			strcopy(sBuffer, sizeof(sBuffer), cvarval);
		}
	}
	
	if(KvJumpToKey(CT_kConVars, sBuffer))
	{
		KvGetString(CT_kConVars, NULL_STRING, sBuffer, sizeof(sBuffer));
		if(strlen(sBuffer))
		{
			CT_KV_ExecuteSetting(sBuffer);
		}
		else
		{
			LogError("[CustomTriggers] ConVar Parser: No setting for convar value");
		}
		KvGoBack(CT_kConVars);
	}
}

CT_KV_ExecuteSetting(const String:setting[])
{
	if(KvJumpToKey(CT_kSettings, setting))
	{
		if(KvGotoFirstSubKey(CT_kSettings, false))
		{
			decl String:lhs[CT_BUFFER_LENGTH], String:rhs[CT_BUFFER_LENGTH];
			do
			{
				KvGetSectionName(CT_kSettings, lhs, sizeof(lhs));
				KvGetString(CT_kSettings, NULL_STRING, rhs, sizeof(rhs))
				if(strlen(rhs))
					ServerCommand("%s \"%s\"", lhs, rhs);
				else
					ServerCommand(lhs);
			}
			while(KvGotoNextKey(CT_kSettings, false));
			KvGoBack(CT_kSettings);
		}
		KvGoBack(CT_kSettings);
	}
	else
	{
		LogError("[CustomTriggers] ExecuteSettings: No such setting %s", setting);
	}

}

CT_KV_InitCommands()
{
	decl String:command[CT_BUFFER_LENGTH], String:sBuffer[CT_BUFFER_LENGTH], String:desc[CT_BUFFER_LENGTH*2];
	new flags;
	if(KvGotoFirstSubKey(CT_kCommands))
	do
	{
		KvGetSectionName(CT_kCommands, command, sizeof(command));
		if(strlen(command))
		{
			KvGetString(CT_kCommands, "exec", sBuffer, sizeof(sBuffer));
			if(strlen(sBuffer))
			{
				Format(desc, sizeof(desc), "CustomTrigger: Execute %s settings", sBuffer);
				KvGetString(CT_kCommands, "flags", sBuffer, sizeof(sBuffer));
				if(strlen(sBuffer))
					flags = FlagStringToFlags(sBuffer);							
				if(flags)
					RegAdminCmd(command, CT_CommandHandler, flags, desc);
				else
					RegConsoleCmd(command, CT_CommandHandler, desc);
			}
			else
			{
				LogError("[CustomTriggers] Command parse error: No exec specified for command %s", command);
			}
		}
		else
		{
			LogError("[CustomTriggers] Command parse error: No command specified in KV Entry");
		}
	} while (KvGotoNextKey(CT_kCommands));
	KvRewind(CT_kCommands);
}

CT_KV_InitConVars()
{
	decl String:convar[CT_BUFFER_LENGTH];
	new String:desc[] = "CustomTriggers: Hooked ConVar";
	new Handle:hCvar;
	if(KvGotoFirstSubKey(CT_kConVars))
	do
	{
		KvGetSectionName(CT_kConVars, convar, sizeof(convar));
		if(strlen(convar))
		{
			hCvar = FindConVar(convar);
			if(hCvar == INVALID_HANDLE)
				hCvar = CreateConVar(convar, "", desc);
			HookConVarChange(hCvar, CT_ConVarHandler);
		}
		else
		{
			LogError("[CustomTriggers] ConVars parse error: No cvar specified in KV Entry");
		}
	} while (KvGotoNextKey(CT_kConVars));
	KvRewind(CT_kConVars);
}
	
CT_KV_InitAll()
{
	CT_KV_CloseAll()
	CT_KV_InitCommands();
	CT_KV_InitConVars();
}

CT_KV_ResetAll()
{
	CT_KV_CloseAll();
	CT_kSettings = CreateKeyValues("settings");
	CT_kTriggers = CreateKeyValues("triggers");
	CT_kCommands = CreateKeyValues("commands");
	CT_kConVars = CreateKeyValues("convars");
}

CT_KV_CloseAll()
{
	if(CT_kSettings != INVALID_HANDLE) CloseHandle(CT_kSettings);
	if(CT_kTriggers != INVALID_HANDLE) CloseHandle(CT_kTriggers);
	if(CT_kCommands != INVALID_HANDLE) CloseHandle(CT_kCommands);
	if(CT_kConVars != INVALID_HANDLE) CloseHandle(CT_kConVars);
}

bool:CT_KV_LoadFile(const String:path[])
{
	new Handle:kFileKV = CreateKeyValues("CustomTriggers");
	if(!FileToKeyValues(kFileKV, path))
		return false;
	
	CT_KV_ResetAll();
	
	if(KvJumpToKey(kFileKV, "settings"))
	{
		KvCopySubkeys(kFileKV, CT_kSettings);
		KvGoBack(kFileKV);
	}
	if(KvJumpToKey(kFileKV, "triggers"))
	{
		KvCopySubkeys(kFileKV, CT_kTriggers);
		KvGoBack(kFileKV);
	}
	if(KvJumpToKey(kFileKV, "commands"))
	{
		KvCopySubkeys(kFileKV, CT_kCommands);
		KvGoBack(kFileKV);
	}
	if(KvJumpToKey(kFileKV, "convars"))
	{
		KvCopySubkeys(kFileKV, CT_kConVars);
		KvGoBack(kFileKV);
	}
	return true;
}
 /**
 * Converts a string of admin flag characters to a flag cell
 *
 * @param flagStr	String of flag characters to convert
 * @return 			Cell representation of the flags
 */
FlagStringToFlags(const String:flagStr[])
{
	new len = strlen(flagStr);
	new flags;
	new AdminFlag:flag;
	
	for (new i = 0; i < len; i++)
	{
		if (!FindFlagByChar(flagStr[i], flag))
		{
			LogError("[CustomTriggers] Invalid flag detected: %c", flagStr[i]);
		}
		else
		{
			flags |= FlagToBit(flag);
		}
	}
	return flags;
}