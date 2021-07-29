/*
[L4D] Delator


+-------------------------------+
|           FEATURES            |
+-------------------------------+

- Quem encostou no carro com alarme.
- Quem atirou no carro com alarme.
- Quem queimou o Tank.
- Quem ativou a Witch.
- Quem fechou a porta da Safe-Room.
- Quem usou mais de um kit médico.
- Quem explodiu o boomer.
- Quem roubou meus itens quando morri (primary weapon, secondary weapon, pain pills, first aid kit, pipe bomb, molotov etc).
- Quem iniciou qualquer EVENTO OFICIAL.


+-------------------------------+
|            CONVARS            |
+-------------------------------+

l4d_delator_version
l4d_delator_enable

l4d_delator_car_alarm_touch
l4d_delator_car_alarm_shot
l4d_delator_burned_tank
l4d_delator_woke_up_witch
l4d_delator_closed_door
l4d_delator_selfish_medkit
l4d_delator_exploded_boomer
l4d_delator_stole_medkit
l4d_delator_stole_primary
l4d_delator_stole_secondary
l4d_delator_stole_pills
l4d_delator_stole_pipe
l4d_delator_stole_molotov

l4d_delator_hospital2_gate
l4d_delator_hospital3_lift
l4d_delator_hospital4_elevator
l4d_delator_hospital5_radio1
l4d_delator_hospital5_radio2

l4d_delator_garage1_barricade
l4d_delator_garage2_generator

l4d_delator_smalltown2_bridge
l4d_delator_smalltown3_church
l4d_delator_smalltown4_forklift
l4d_delator_smalltown5_radio1
l4d_delator_smalltown5_radio2

l4d_delator_airport2_crane
l4d_delator_airport3_barricade
l4d_delator_airport4_van
l4d_delator_airport4_detector
l4d_delator_airport5_radio
l4d_delator_airport5_fuel

l4d_delator_farm2_door
l4d_delator_farm3_bridge
l4d_delator_farm5_cornfield
l4d_delator_farm5_radio1
l4d_delator_farm5_radio2

l4d_delator_river1_train
l4d_delator_river2_crows
l4d_delator_river3_generator1
l4d_delator_river3_generator2
l4d_delator_river3_generator3

*/


/************************************************************************
  [L4D] Delator (v0.1.0, 2019-01-25)

  DESCRIPTION:

    Displays the name of the survivor who started a panic event, 
    among other things.

  CHANGELOG:

  2019-01-25 (v0.1.0)
    - Initial release.

 ************************************************************************/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

/**
 * Compiler requires semicolons and the new syntax.
 */
#pragma semicolon 	1
#pragma newdecls 	required

/**
 * Semantic versioning <https://semver.org/>
 */
#define PLUGIN_VERSION	"0.1.0"

public Plugin myinfo = {
	name 			= "[L4D] Delator",
	author 			= "samuelviveiros a.k.a Dartz8901",
	description 	= "Displays the name of the survivor who started a panic event, among other things.",
	version 		= PLUGIN_VERSION,
	url 			= "https://github.com/samuelviveiros/l4d_delator"
};

#define CL_DEFAULT 		"\x01"
#define CL_LIGHTGREEN 	"\x03"
#define CL_YELLOW 		"\x04"
#define CL_GREEN 		"\x05"


#define SURVIVOR_TEAM 	2
#define WORLDSPAWN_INDEX 0


#define NOMERCY_SUBWAY_GATE_ID                              6912133
#define NOMERCY_SEWERS_LIFT_ID                              8066368
#define NOMERCY_INTERIOR_ELEVATOR_ID                        1199249
#define NOMERCY_ROOFTOP_FIRST_RADIO_ID                      3906743
#define NOMERCY_ROOFTOP_SECOND_RADIO_ID                     3086885

#define CRASHCOURSE_ALLEYS_BIG_ASS_GUN_ID                   66959
#define CRASHCOURSE_LOTS_GENERATOR_FIRST_ACTIVATION_ID      384820

#define DEATHTOLL_DRAINAGE_BRIDGE_ID                        1295167
#define DEATHTOLL_RANCHHOUSE_CHURCH_ID                      2570933
#define DEATHTOLL_MAINSTREET_FORKLIFT_ID                    4782801
#define DEATHTOLL_HOUSEBOAT_FIRST_RADIO_ID                  1748302
#define DEATHTOLL_HOUSEBOAT_SECOND_RADIO_ID                 1748305

#define DEADAIR_OFFICES_CRANE_ID                            6599820
#define DEADAIR_GARAGE_BARRICADE_ID                         7082739
#define DEADAIR_TERMINAL_VAN_ID                             5592473
#define DEADAIR_TERMINAL_METAL_DETECTOR1_ID                 4455334
#define DEADAIR_TERMINAL_METAL_DETECTOR2_ID                 4455909
#define DEADAIR_RUNWAY_RADIO_ID                             4147290
#define DEADAIR_RUNWAY_FUEL_ID                              4116780

#define BLOODHARVEST_TRAINTUNNEL_EMERGENCY_DOOR_ID          1121791
#define BLOODHARVEST_BRIDGE_VALVE_ID                        1706068
#define BLOODHARVEST_CORNFIELD_CROWS_ID                     1044909
#define BLOODHARVEST_CORNFIELD_FIRST_RADIO_ID               861175
#define BLOODHARVEST_CORNFIELD_SECOND_RADIO_ID              238321

#define THESACRIFICE_DOCKS_TRAIN_ID                         188736
#define THESACRIFICE_BARGE_CROWS_ID                         1142335
#define THESACRIFICE_PORT_FIRST_GENERATOR_ID                2054672
#define THESACRIFICE_PORT_SECOND_GENERATOR_ID               1512662
#define THESACRIFICE_PORT_THIRD_GENERATOR_ID                2052608


bool        g_ChurchActivated                   = false;
bool        g_GameplayAlreadyBegun              = false;
bool        g_AlarmStarted                      = false;
ArrayList   g_TanksOnFire                       = null;
int         g_BoomersExploded[MAXPLAYERS+1]     = { -1, ... };

//
// Ripped directly from the "[L4D & L4D2] Flashlight Package" plugin (by SilverShot)
// http://forums.alliedmods.net/showthread.php?t=173257
//
public APLRes AskPluginLoad2(Handle mySelf,
                             bool late,
                             char[] error,
                             int errorMax) {
	EngineVersion engine = GetEngineVersion();
	if (engine != Engine_Left4Dead) {
		strcopy(error, errorMax, "Plugin only supports Left 4 Dead 1");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart() {
	CreateConVar(
        "l4d_delator_version",
        PLUGIN_VERSION,
        "[L4D] Delator version",
        FCVAR_REPLICATED | FCVAR_NOTIFY
    );
	CreateConVar(
        "l4d_delator_enable",
        "1",
        "Enable or disable this plugin.",
        FCVAR_NOTIFY,
        true, 0.0,
        true, 1.0
    );
	AutoExecConfig(true, "l4d_delator");

    HookEvent("witch_harasser_set", Event_WitchIsPissedOff);
    HookEvent("player_use", Event_PlayerUse);
    HookEvent("mission_lost", Event_MissionLost);
    HookEvent("map_transition", Event_MapTransition);
    HookEvent("zombie_ignited", Event_TankBurned);
    HookEvent("player_now_it", Event_PlayerVomited);
    HookEvent("boomer_exploded", Event_BoomerExploded);
    HookEvent("player_first_spawn", Event_PlayerFirstSpawn);

    RegConsoleCmd ("dtest", Command_Test123);
    HookEvent("item_pickup", Event_MainHandler);
}

/*
public void OnMapStart()
{
    g_ChurchActivated = false;
    g_GameplayAlreadyBegun = false;
}
*/

public void OnClientDisconnect(int client) {
    // Who blew the Boomer
    g_BoomersExploded[client] = -1;

    // Who burned the Tank
    if (g_TanksOnFire != null) {
        int index = g_TanksOnFire.FindValue(client);
        if (index != -1) {
            g_TanksOnFire.Erase(index);
        }
    }
    
    // Who stole my stuffs
	SDKUnhook(client, SDKHook_WeaponEquip, onItemPickup);
}

public Action Event_MainHandler(Event event,
                                const char[] name,
                                bool dontBroadcast) {
    /*
    LogMessage("Event_MainHandler: name: %s", name);
    char dateTime[64];
    FormatTime(dateTime, sizeof(dateTime), "%d-%m-%Y - %H:%M:%S");
    PrintToChatAll("%s | Event_MainHandler: name: %s", dateTime, name);
    */
    return Plugin_Continue;
}

#define MAX_INT 4294967295
public Action Command_Test123(int client, int args) {
    /*
    char buffer[64];
    FormatTime(buffer, 64, "%d-%m-%Y - %H:%M:%S");
    PrintToChatAll("%s", buffer);
    */

    
    PrintToChatAll("%u", GetRandomInt(MAX_INT-500, MAX_INT));
    //PrintToChatAll("%u", 18446744073709551615);

    return Plugin_Handled;
}




/*---------------------------------------+
|                                        |
|     WHO FIRED CAR ALARM                |
|                                        |
+---------------------------------------*/

// Snippet adapted from https://forums.alliedmods.net/showthread.php?t=210782
public void OnEntityCreated(int index, const char[] className) {
    if (isPluginEnabled()) {
        // car alarm
        if (StrEqual(className, "prop_car_alarm")) {
            SDKHook(index, SDKHook_Spawn, onCarAlarmSpawn);
            SDKHook(index, SDKHook_StartTouch, onCarAlarmTouch);
        }
    }
}

public Action onCarAlarmSpawn(int entityIndex) {
	HookSingleEntityOutput(entityIndex, "OnCarAlarmStart", onCarAlarmStart);
	HookSingleEntityOutput(entityIndex, "OnTakeDamage", onCarAlarmTakeDamage);
    //SDKUnhookTimer(2.5, entityIndex, SDKHook_Spawn, onCarAlarmSpawn);
}

public Action onCarAlarmTouch(int carAlarmIndex, int trollIndex) {
    if (g_AlarmStarted) {
        g_AlarmStarted = false;
        char trollName[MAX_NAME_LENGTH];
        if (isValidSurvivor(trollIndex) &&
            GetClientName(trollIndex, trollName, sizeof(trollName))) {
            
            PrintToChatAll(
                "%s%s leaned in the car and fired the alarm.%s",
                CL_YELLOW, trollName, CL_DEFAULT
            );
            //SDKUnhookTimer(2.5, carAlarmIndex, SDKHook_StartTouch, onCarAlarmTouch);
        }
    }
}

public void onCarAlarmTakeDamage(const char[] output,
                                 int caller,
                                 int trollIndex,
                                 float delay) {
    if (g_AlarmStarted) {
        g_AlarmStarted = false;
        char trollName[MAX_NAME_LENGTH];
        if (isValidSurvivor(trollIndex) &&
            GetClientName(trollIndex, trollName, sizeof(trollName))) {
            
            PrintToChatAll(
                "%s%s shot the car and fired the alarm.%s",
                CL_YELLOW, trollName, CL_DEFAULT
            );
            //unhookSingleEntityOutputTimer(2.5, caller, "OnTakeDamage", onCarAlarmTakeDamage);
        }
    }
}

public void onCarAlarmStart(const char[] output,
                            int caller,
                            int trollIndex,
                            float delay) {
    g_AlarmStarted = true;
    //unhookSingleEntityOutputTimer(2.5, caller, "OnCarAlarmStart", onCarAlarmStart);
}

stock bool isValidSurvivor(int survivorIndex) {
    return (
        IsValidEntity(survivorIndex) && 
        survivorIndex > 0 && survivorIndex <= MaxClients && 
        IsClientInGame(survivorIndex) && 
        GetClientTeam(survivorIndex) == SURVIVOR_TEAM 
    );
}




/*---------------------------------------+
|                                        |
|     WHO BOTHERED THE WITCH             |
|                                        |
+---------------------------------------*/

public Action Event_WitchIsPissedOff(Event event,
                                     const char[] name,
                                     bool dontBroadcast) {
    char trollName[MAX_NAME_LENGTH];
    int trollIndex = GetClientOfUserId(event.GetInt("userid"));
    if (GetClientName(trollIndex, trollName, sizeof(trollName))) {
        PrintToChatAll(
            "%s%s%s woke up the witch.",
            CL_YELLOW, trollName, CL_DEFAULT
        );
    }
    return Plugin_Continue;
}




/*---------------------------------------+
|                                        |
|     MAIN EVENTS                        |
|                                        |
+---------------------------------------*/

public Action Event_PlayerUse(Event event,
                              const char[] name,
                              bool dontBroadcast) {
    /*
    return Plugin_Continue;
    char classname[128];
    int entity = event.GetInt("targetid");
    if ( entity > 0 && GetEntityClassname(entity, classname, sizeof(classname)) )
    {
        char targetname[128];
        if ( HasEntProp(entity, Prop_Data, "m_iName") )
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetname, sizeof(targetname));
		}
        int hammerid = 0;
        if ( HasEntProp(entity, Prop_Data, "m_iHammerID") )
		{
			hammerid = GetEntProp(entity, Prop_Data, "m_iHammerID");
		}
        PrintToChatAll("player: %i, entity: %i, classname: %s, targetname: %s, hammerid: %i", 
            GetClientOfUserId(event.GetInt("userid")), entity, classname, targetname, hammerid);
    }
    PrintToChatAll("------------");
    */

    int entityIndex = event.GetInt("targetid");

    if (entityIndex <= WORLDSPAWN_INDEX) {
        return Plugin_Continue;
    }

    if (!entityHasProperty(entityIndex, "m_iHammerID")) {
        return Plugin_Continue;
    }
    int hammerID = getEntityHammerId(entityIndex);

    char trollName[MAX_NAME_LENGTH];
    int trollIndex = GetClientOfUserId(event.GetInt("userid"));
    if (!GetClientName(trollIndex, trollName, sizeof(trollName))) {
        LogError("Event_PlayerUse: Failed to retrieve survivor name");
        return Plugin_Continue;
    }

    char announcement[256] = { '\0', ... };

    switch (hammerID) {
        case NOMERCY_SUBWAY_GATE_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s opened the gate.%s"
            );
        }
        case NOMERCY_SEWERS_LIFT_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s activated the lift.%s"
            );
        }
        case NOMERCY_INTERIOR_ELEVATOR_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s activated the elevator.%s"
            );
        }
        case NOMERCY_ROOFTOP_FIRST_RADIO_ID: {            
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s%s contacted the pilot."
            );
        }
        case NOMERCY_ROOFTOP_SECOND_RADIO_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%sPilot contacted second time by %s.%s"
            );
        }
        case CRASHCOURSE_ALLEYS_BIG_ASS_GUN_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s fired the big ass gun.%s"
            );
        }
        case CRASHCOURSE_LOTS_GENERATOR_FIRST_ACTIVATION_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s turned on the generator.%s"
            );
        }
        case DEATHTOLL_DRAINAGE_BRIDGE_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s activated the bridge.%s"
            );
        }
        case DEATHTOLL_RANCHHOUSE_CHURCH_ID: {
            if (!g_ChurchActivated) {
                g_ChurchActivated = true;
                strcopy(
                    announcement,
                    sizeof(announcement),
                    "%s%s provoked the church guy.%s"
                );
            }
        } 
        case DEATHTOLL_MAINSTREET_FORKLIFT_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s started the forklift.%s"
            );
        }
        case DEATHTOLL_HOUSEBOAT_FIRST_RADIO_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s contacted the boat.%s"
            );
        }
        case DEATHTOLL_HOUSEBOAT_SECOND_RADIO_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%sBoat contacted second time by %s.%s"
            );
        }
        case DEADAIR_OFFICES_CRANE_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s turned on the crane.%s"
            );
        }
        case DEADAIR_TERMINAL_VAN_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s started the van.%s"
            );
        }
        case DEADAIR_RUNWAY_RADIO_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s contacted the C-130 pilot.%s"
            );
        }
        case DEADAIR_RUNWAY_FUEL_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s started the fuel truck pump.%s"
            );
        }
        case BLOODHARVEST_TRAINTUNNEL_EMERGENCY_DOOR_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s walked through the emergency door.%s"
            );
        }
        case BLOODHARVEST_BRIDGE_VALVE_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s lowered the bridge.%s"
            );
        }
        case BLOODHARVEST_CORNFIELD_FIRST_RADIO_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s contacted the army.%s"
            );
        }
        case BLOODHARVEST_CORNFIELD_SECOND_RADIO_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%sArmy contacted second time by %s.%s"
            );
        }
        case THESACRIFICE_DOCKS_TRAIN_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s opened the train door.%s"
            );
        }
        case THESACRIFICE_PORT_FIRST_GENERATOR_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s turned on the FIRST generator.%s"
            );
        }
        case THESACRIFICE_PORT_SECOND_GENERATOR_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s turned on the SECOND generator.%s"
            );
        }
        case THESACRIFICE_PORT_THIRD_GENERATOR_ID: {
            strcopy(
                announcement,
                sizeof(announcement),
                "%s%s turned on the THIRD generator.%s"
            );
        }
    }

    if (strlen(announcement) > 0) {
        PrintToChatAll(announcement, CL_YELLOW, trollName, CL_DEFAULT);
    }

    return Plugin_Continue;
}

// for coop mode
public Action Event_MissionLost(Event event,
                                const char[] name,
                                bool dontBroadcast) {
    CreateTimer(7.0, Timer_CallGameplayStart);
    return Plugin_Continue;
}

// for versus mode
public Action Event_MapTransition(Event event,
                                  const char[] name,
                                  bool dontBroadcast) {
    g_GameplayAlreadyBegun = false;
    return Plugin_Continue;
}

public Action Event_PlayerFirstSpawn(Event event,
                                     const char[] name,
                                     bool dontBroadcast) {
    if (g_GameplayAlreadyBegun) {
        return Plugin_Continue;
    }
    g_GameplayAlreadyBegun = true;

    // Esse delay garante que a barricada seja 
    // encontrada (modo versus, segunda rodada).
    CreateTimer(5.0, Timer_CallGameplayStart);

    return Plugin_Continue;
}

public Action Timer_CallGameplayStart(Handle timer) {
    onGameplayStart();
    return Plugin_Stop;
}

void onGameplayStart() {
    char mapName[128];
    if (GetCurrentMap(mapName, sizeof(mapName)) > 0) {
        if (StrEqual(mapName, "l4d_airport03_garage")) {
            performHookEntOutput(
                DEADAIR_GARAGE_BARRICADE_ID,
                "prop_physics",
                "OnBreak",
                hookSingleEntityOutputCallback
            );
        } else if (StrEqual(mapName, "l4d_airport04_terminal")) {
            performHookEntOutput(
                DEADAIR_TERMINAL_METAL_DETECTOR1_ID,
                "trigger_multiple",
                "OnStartTouch",
                hookSingleEntityOutputCallback
            );
            performHookEntOutput(
                DEADAIR_TERMINAL_METAL_DETECTOR2_ID,
                "trigger_multiple",
                "OnStartTouch",
                hookSingleEntityOutputCallback
            );
        } else if (StrEqual(mapName, "l4d_farm05_cornfield")) {
            performHookEntOutput(
                BLOODHARVEST_CORNFIELD_CROWS_ID,
                "trigger_once",
                "OnTrigger",
                hookSingleEntityOutputCallback
            );
        } else if (StrEqual(mapName, "l4d_river02_barge")) {
            performHookEntOutput(
                THESACRIFICE_BARGE_CROWS_ID,
                "trigger_once",
                "OnTrigger",
                hookSingleEntityOutputCallback
            );
        } else if (StrEqual(mapName, "l4d_smalltown03_ranchhouse")) {
            g_ChurchActivated = false;
        }
    }

    PrintToChatAll("GAMEPLAY ALREADY BEGUN!");
}

void performHookEntOutput(int hammerID,
                          const char[] className,
                          const char[] output,
                          EntityOutput callback) {
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, className)) != -1) {
        if (getEntityHammerId(entity) == hammerID) {
            HookSingleEntityOutput(entity, output, callback);
            break;
        }
    }
}

public void hookSingleEntityOutputCallback(const char[] output,
                                           int caller,
                                           int trollIndex,
                                           float delay) {
    char trollName[MAX_NAME_LENGTH];
    if (!GetClientName(trollIndex, trollName, sizeof(trollName))) {
        LogError(
            "hookSingleEntityOutputCallback: Failed to retrieve survivor name"
        );
        return;
    }

    int hammerID = getEntityHammerId(caller);
    switch (hammerID) {
        case DEADAIR_GARAGE_BARRICADE_ID: {
            PrintToChatAll(
                "%s%s blew up the barricade.%s",
                CL_YELLOW, trollName, CL_DEFAULT
            );
        }
        case DEADAIR_TERMINAL_METAL_DETECTOR1_ID: {
            PrintToChatAll(
                "%s%s walked through the metal detector.%s",
                CL_YELLOW, trollName, CL_DEFAULT
            );
        }
        case DEADAIR_TERMINAL_METAL_DETECTOR2_ID: {
            PrintToChatAll(
                "%s%s walked through the metal detector.%s",
                CL_YELLOW, trollName, CL_DEFAULT
            );
        }
        case BLOODHARVEST_CORNFIELD_CROWS_ID: {
            PrintToChatAll(
                "%s%s shooed the crows in the cornfield.%s",
                CL_YELLOW, trollName, CL_DEFAULT
            );
        }
        case THESACRIFICE_BARGE_CROWS_ID: {
            PrintToChatAll(
                "%s%s shooed the crows.%s",
                CL_YELLOW, trollName, CL_DEFAULT
            );
        }
    }
}




/*---------------------------------------+
|                                        |
|     WHO BURNED THE TANK                |
|                                        |
+---------------------------------------*/

public Action Event_TankBurned(Event event,
                               const char[] name, 
                               bool dontBroadcast) {
    char victimName[32];
    event.GetString("victimname", victimName, sizeof(victimName));
    if (!StrEqual(victimName, "Tank")) {
        return Plugin_Continue;
    }

    char trollName[MAX_NAME_LENGTH];
    int attacker = GetClientOfUserId(event.GetInt("userid"));
    if (!GetClientName(attacker, trollName, sizeof(trollName))) {
        LogError("Event_ZombieIgnited: Failed to retrieve attacker name");
        return Plugin_Continue;
    }

    if (g_TanksOnFire == null) {
        g_TanksOnFire = new ArrayList();
    }
    
    int tank = event.GetInt("entityid");
    if (g_TanksOnFire.FindValue(tank) != -1) {
        return Plugin_Continue;
    } else {
        g_TanksOnFire.Push(tank);
        PrintToChatAll(
            "%s%s burned the Tank's ass.%s",
            CL_YELLOW, trollName, CL_DEFAULT
        );
    }

    return Plugin_Continue;
}

public void OnMapEnd() {
    if (g_TanksOnFire != null) {
        CloseHandle(g_TanksOnFire);
        g_TanksOnFire = null;
    }
}




/*---------------------------------------+
|                                        |
|     WHO BLEW THE BOOMER                |
|                                        |
+---------------------------------------*/

public Action Event_PlayerVomited(Event event,
                                  const char[] name,
                                  bool dontBroadcast) {
    if (event.GetInt("exploded")) {
        int victim = GetClientOfUserId(event.GetInt("userid"));
        int boomer = GetClientOfUserId(event.GetInt("attacker"));
        int troll = g_BoomersExploded[boomer];

        if (troll != -1 && troll != victim) {
            char trollName[MAX_NAME_LENGTH];
            char victimName[MAX_NAME_LENGTH];

            if (GetClientName(troll, trollName, sizeof(trollName)) &&
                GetClientName(victim, victimName, sizeof(victimName))) {

                PrintToChatAll(
                    "%s%s%s spread the infection to %s%s%s",
                    CL_YELLOW, trollName, CL_DEFAULT,
                    CL_YELLOW, victimName, CL_DEFAULT
                );
            }
        }
    }
    return Plugin_Continue;
}

public Action Event_BoomerExploded(Event event,
                                   const char[] name,
                                   bool dontBroadcast) {
    int troll = GetClientOfUserId(event.GetInt("attacker"));
    if (troll > 0) {
        int boomer = GetClientOfUserId(event.GetInt("userid"));
        g_BoomersExploded[boomer] = troll;
    }
    return Plugin_Continue;
}




/*---------------------------------------+
|                                        |
|     WHO STOLE MY STUFFS                |
|                                        |
+---------------------------------------*/

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_WeaponEquip, onItemPickup);
}

public Action onItemPickup(int client, int item) {
    // client cannot be the Worldspawn or an invalid index (-1).
    if (client <= WORLDSPAWN_INDEX) {
        return Plugin_Continue;
    }

    // client must be a survivor.
    if (GetClientTeam(client) != SURVIVOR_TEAM) {
        return Plugin_Continue;
    }

    // item cannot be the Worldspawn, invalid index (-1), or a player index.
    if (item <= MaxClients) {
        return Plugin_Continue;
    }

    // Sets a friendly name for the item.
    char itemName[32];
    char itemClass[64];
    GetEntityClassname(item, itemClass, sizeof(itemClass));
    if (StrEqual("weapon_autoshotgun", itemClass)) {
        strcopy(itemName, sizeof(itemName), "automatic shotgun");
    } else if (StrEqual("weapon_rifle", itemClass)) {
        strcopy(itemName, sizeof(itemName), "rifle");
    } else if (StrEqual("weapon_hunting_rifle", itemClass)) {
        strcopy(itemName, sizeof(itemName), "hunting rifle");
    } else if (StrEqual("weapon_first_aid_kit", itemClass)) {
        strcopy(itemName, sizeof(itemName), "first aid kit");
    } else if (StrEqual("weapon_pain_pills", itemClass)) {
        strcopy(itemName, sizeof(itemName), "pain pills");
    } else if (StrEqual("weapon_molotov", itemClass)) {
        strcopy(itemName, sizeof(itemName), "molotov");
    } else if (StrEqual("weapon_pipe_bomb", itemClass)) {
        strcopy(itemName, sizeof(itemName), "pipe bomb");
    } else {
        return Plugin_Continue;
    }

    // Get the entity's global name.
    char ownerSteamID[64];
    GetEntPropString(
        item,
        Prop_Data,
        "m_iGlobalname",
        ownerSteamID,
        sizeof(ownerSteamID)
    );

    // If the item's global name contains a SteamID, this code will attempts to retrieve 
    // the index and name of the item's owner from that SteamID, and displays the name of 
    // the thief (client parameter) that stole the item.
    if (contains(ownerSteamID, "STEAM_")) {
        int thief = client;
        int owner = getClientBySteamID(ownerSteamID);
        char thiefName[MAX_NAME_LENGTH];
        char ownerName[MAX_NAME_LENGTH];
        if (owner != -1 &&                                          // Owner index must be valid.
            owner != thief &&                                       // Owner can't steal from himself.
            !IsPlayerAlive(owner) &&                                // Owner must be dead.
            GetClientName(owner, ownerName, sizeof(ownerName)) &&   // Owner's name.
            IsClientConnected(thief) &&                             // Thief must be connected.
            GetClientName(thief, thiefName, sizeof(thiefName))      // Thief's name.
        ) {
            PrintToChatAll(
                "Looks like %s stole %s's %s",
                thiefName,
                ownerName,
                itemName
            );
        }
    }

    // Associates the SteamID of the client with the item, making the client 
    // the "owner" of the item, even if the client is a thief.
    if (getClientSteamID(client, ownerSteamID, sizeof(ownerSteamID))) {
        SetEntPropString(item, Prop_Data, "m_iGlobalname", ownerSteamID);
    }

	return Plugin_Continue;
}

/**
 * Returns the client index from the SteamID (bots are ignored).
 *
 * @author          Dartz8901
 *
 * @param steamID   The game-specific auth string as returned
 *                  from the engine, ex "STEAM_1:0:12345678".
 * @return          A client index, or -1 on failure.
 */
stock int getClientBySteamID(const char[] steamID) {
    char id[64];
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientConnected(client) &&
            IsClientInGame(client) &&
            !IsFakeClient(client) &&
            getClientSteamID(client, id, sizeof(id)) &&
            StrEqual(id, steamID)
        ) {
            return client;
        }
    }
    return -1;
}

stock bool getClientSteamID(int client, char[] auth, int maxlen) {	
    if (GetClientAuthId(client, AuthId_Engine, auth, maxlen, true)) {
        if (StrEqual(auth, "STEAM_ID_PENDING") ||
            StrEqual(auth, "STEAM_ID_LAN") ||
            StrEqual(auth, "BOT")
        ) {
            return false;
        }
        return true;
    }
	return false;
}

stock bool contains(const char[] str, const char[] substr) {
    return (StrContains(str, substr, false) != -1);
}

stock void SDKUnhookTimer(float interval,
                          int entity,
                          SDKHookType type,
                          SDKHookCB callback) {
    DataPack pack;
    CreateDataTimer(interval, Timer_SDKUnhook, pack);
    pack.WriteCell(entity);
    pack.WriteCell(type);
    pack.WriteFunction(callback);
}

public Action Timer_SDKUnhook(Handle timer, DataPack pack) {
    pack.Reset();
    int entity = view_as<int>(pack.ReadCell());
    if (isInvalidEntity(entity)) {
        return Plugin_Stop;
    }
    SDKUnhook(
        entity,
        view_as<SDKHookType>(pack.ReadCell()),
        view_as<SDKHookCB>(pack.ReadFunction())
    );
    return Plugin_Stop;
}

stock void unhookSingleEntityOutputTimer(float interval,
                                         int entity,
                                         const char[] output,
                                         EntityOutput callback) {
    DataPack pack;
    CreateDataTimer(interval, Timer_UnhookSingleEntityOutput, pack);
    pack.WriteCell(entity);
    pack.WriteString(output);
    pack.WriteFunction(callback);
}

public Action Timer_UnhookSingleEntityOutput(Handle timer, DataPack pack) {
    pack.Reset();
    int entity = view_as<int>(pack.ReadCell());
    if (isInvalidEntity(entity)) {
        return Plugin_Stop;
    }
    char output[64];
    pack.ReadString(output, sizeof(output));
    UnhookSingleEntityOutput(
        entity,
        output,
        view_as<EntityOutput>(pack.ReadFunction())
    );
    return Plugin_Stop;
}

stock bool isInvalidEntity(int entityIndex) {
    return !IsValidEntity(entityIndex);
}

stock bool entityHasProperty(int entityIndex, const char[] propertyName) {
    return HasEntProp(entityIndex, Prop_Data, propertyName);
}

stock int getEntityHammerId(int entityIndex) {
    return GetEntProp(entityIndex, Prop_Data, "m_iHammerID");
}

stock bool isPluginEnabled() {
    return (GetConVarInt(FindConVar("l4d_delator_enable")) != 0);
}
