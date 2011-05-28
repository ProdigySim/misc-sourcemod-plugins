#include <adt_trie>

#if defined __l4d2_survivors_inc__
#endinput
#endif
#define __l4d2_survivors_inc__

// Indexes are arbitrary at this point.
enum SurvivorCharacter {
	SC_NONE=-1,
	SC_COACH=0,
	SC_NICK, //1
	SC_ROCHELLE, //2
	SC_ELLIS, //3
	SC_LOUIS, //4
	SC_ZOEY, //5
	SC_BILL, //6
	SC_FRANCIS //7
};
new const String:SurvivorModels[SurvivorCharacter][] = {
	"models/survivors/survivor_coach.mdl",
	"models/survivors/survivor_gambler.mdl",
	"models/survivors/survivor_producer.mdl",
	"models/survivors/survivor_mechanic.mdl",
	"models/survivors/survivor_manager.mdl",
	"models/survivors/survivor_teenangst.mdl",
	"models/survivors/survivor_namvet.mdl",
	"models/survivors/survivor_biker.mdl"
};


static Handle:hSurvivorModelsTrie;


/**
 * Initializes internal structure necessary for survivors.inc functions
 * @remark It is recommended that you run this function on plugin start, but not necessary
 *
 * @noreturn
 */
stock L4D2Survivors_Init()
{
	if(hSurvivorModelsTrie == INVALID_HANDLE)
	{
		InitSurvivorModelTrie();
	}
}

static InitSurvivorModelTrie()
{
	hSurvivorModelsTrie = CreateTrie();
	for(new i = 0; i < _:SurvivorCharacter; i++)
	{
		SetTrieValue(hSurvivorModelsTrie, SurvivorModels[SurvivorCharacter:i], i);
	}
}

stock SurvivorCharacter:IdentifySurvivor(const client)
{
	if (!client || !IsClientInGame(client) || GetClientTeam(client) != 2)
	{
		return SC_NONE;
	}
	decl String:clientModel[42];
	GetClientModel(client, clientModel, sizeof(clientModel));
	return ClientModelToSC(clientModel);
}

stock SurvivorCharacter:ClientModelToSC(const String:model[])
{
	if(hSurvivorModelsTrie == INVALID_HANDLE)
	{
		InitSurvivorModelTrie();
	}
	new SurvivorCharacter:sc;
	if(GetTrieValue(hSurvivorModelsTrie, model, sc))
	{
		return sc;
	}
	return SC_NONE;
}
