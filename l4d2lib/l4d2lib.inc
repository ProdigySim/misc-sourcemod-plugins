/* *
 * =============================================================================
 * L4D2Lib.inc 
 * L4D2Lib (C)2011 Confogl Team
 * =============================================================================
 *
 * This file is part of the Lgofnoc competitive L4D2 plugin suite.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, Lgofnoc Team gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, Lgofnoc Team grants
 * this exception to all derivative works. Lgofnoc defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 */
 
 
/**
 * @brief Returns the current round number
 * @remarks Updated on round_start events
 * 
 * @return 	0 for pre first round, round number otherwise
 */
native L4D2_GetCurrentRound();

/**
 * @brief Tells if we're actually in a round or in between rounds
 * @remarks Updated on first round_start/end
 * 
 * @return 	True if within an actual round, false otherwise.
 */
native bool:L4D2_CurrentlyInRound();


/**
 * Called on a real L4D2 round_start
 *
 * @param roundNumber			The round number for the round that is starting
 * @noreturn
 */
forward L4D2_OnRealRoundStart(roundNumber);

/**
 * Called on a real L4D2 round_end
 *
 * @param roundNumber			The round number for the round that has ended
 * @noreturn
 */
forward L4D2_OnRealRoundEnd(roundNumber);



/**
 * @Called when a tank is first spawned into the game
 * 
 * @param tankClient		The client index of the tank
 * @noreturn
 */
forward L4D2_OnTankFirstSpawn(tankClient);

/**
 * @Called when a tank passes from one client to another
 * 
 * @param oldTank			The client index of the previous tank
 * @param newTank			The client index of the new tank
 * @param passCount			The number of times this tank has been passed
 * @noreturn
 */
forward L4D2_OnTankPassControl(oldTank, newTank, passCount);

/**
 * @Called 0.5s after a tank death
 * 
 * @param tankClient		The client index of the tank that died
 * @noreturn
 */
forward L4D2_OnTankDeath(tankClient);
