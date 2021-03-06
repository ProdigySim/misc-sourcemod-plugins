/**
 * vim: set ts=4 :
 * =============================================================================
 * KvFunctions.inc (C)2010 Michael "ProdigySim" Busby
 * =============================================================================
 *
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
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */
 
 
 /**
 * Counts the number of subkeys under a current KeyValue key
 *
 * @param kv		KeyValues Handle
 * @param keyOnly	If false, non-keys will be traversed (values).
 * @return 			Number of subkeys under the current KeyValue key
 */
 stock KvCountSubKeys(Handle:kv, bool:keyOnly=true)
 {
	new count;
	if(KvGotoFirstSubKey(kERData, keyOnly))
	{
		do 
		{
			++count;
		} while (KvGotoNextKey(kERData, keyOnly));
		KvGoBack(kERData);
	}
	return count;
 }
 
 