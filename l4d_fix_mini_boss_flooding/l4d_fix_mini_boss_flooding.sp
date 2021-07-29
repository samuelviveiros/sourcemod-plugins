/************************************************************************
  [L4D] Fix Mini Boss Flooding - A Sourcemod Left 4 Dead plugin

  DESCRIPTION:

  Corrects overload of connections (from unknown origin), from the
  infected team. This was made for my friend Kurama's server.

  CHANGELOG:

  2019-05-18 (v1.0.1)
    - Fixed counter issue that was not being decremented when a Tank died.

  2019-05-18 (v1.0.0)
    - Initial version.

 ************************************************************************/

#include <sourcemod>
#include <sdktools>

/**
 * Compiler requires semicolons and the new syntax.
 */
#pragma semicolon 1
#pragma newdecls required

/**
 * Semantic versioning <https://semver.org/>
 */
#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = {
    name = "[L4D] Fix Mini Boss Flooding",
    author = "samuelviveiros a.k.a Dartz8901",
    description = "Corrects overload of connections from the \
        infected team. This is for my friend Kurama's server.",
    version = PLUGIN_VERSION,
    url = "https://github.com/samuelviveiros/l4d_fix_mini_boss_flooding"
};

#define TEAM_SURVIVOR 2

Handle g_PluginEnabled = null;
int g_TotalAliveTanks = 0;

public APLRes AskPluginLoad2(Handle myself,
                             bool late,
                             char[] error,
                             int err_max) {
    EngineVersion engine = GetEngineVersion();
    if (engine != Engine_Left4Dead) {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1");
        return APLRes_SilentFailure;
    }
    return APLRes_Success;
}

public void OnPluginStart() {
    CreateConVar(
        "l4d_fix_mini_boss_flooding_version",
        PLUGIN_VERSION,
        "[L4D] Fix Mini Boss Flooding version",
        FCVAR_REPLICATED | FCVAR_NOTIFY
    );
    g_PluginEnabled = CreateConVar(
        "l4d_fix_mini_boss_flooding_enable",
        "1",
        "Enable or disable this plugin.",
        FCVAR_NOTIFY,
        true, 0.0,
        true, 1.0
    );
    CreateConVar(
        "l4d_fix_mini_boss_flooding__max_allowed",
        "4",
        "Maximum allowed tanks.",
        FCVAR_NOTIFY,
        true, 1.0,
        true, 18.0
    );

    RegConsoleCmd("totaltanks", Command_ShowTotalTanks);
    HookEvent("tank_spawn", Event_TankSpawn);
    HookEvent("tank_killed", Event_TankKilled);
    AutoExecConfig(true, "l4d_fix_mini_boss_flooding");
}

public Action Event_MapTransition(Handle event,
                                  const char[] name,
                                  bool dontBroadcast) {
    if (!(GetConVarInt(g_PluginEnabled) != 0))
        return Plugin_Continue;

    g_TotalAliveTanks = 0;

	return Plugin_Continue;
}

public Action Event_TankSpawn(Handle event,
                              const char[] name,
                              bool dontBroadcast) {
    if (!(GetConVarInt(g_PluginEnabled) != 0))
        return Plugin_Continue;

    g_TotalAliveTanks++;

    ConVar hMaxAllowed = null;
    hMaxAllowed = FindConVar("l4d_fix_mini_boss_flooding__max_allowed");
	if (hMaxAllowed != null) {
        if (g_TotalAliveTanks > GetConVarInt(hMaxAllowed))
            CreateTimer(
                2.0,
                Timer_KillTank,
                GetEventInt(event, "userid")
            );
    } else {
        ThrowError("ConVar 'l4d_fix_mini_boss_flooding__max_allowed' not found.");
    }    

	return Plugin_Continue;
}

public Action Event_TankKilled(Handle event,
                               const char[] name,
                               bool dontBroadcast) {
    if (!(GetConVarInt(g_PluginEnabled) != 0))
        return Plugin_Continue;

    g_TotalAliveTanks--;

	return Plugin_Continue;
}

public Action Timer_KillTank(Handle timer, any userid) {
    int tank = GetClientOfUserId(view_as<int>(userid));

    if (!isValidClientIndex(tank))
        return Plugin_Stop;

    if (!IsClientConnected(tank))
        return Plugin_Stop;

    if (!IsClientInGame(tank))
        return Plugin_Stop;

    if (!IsPlayerAlive(tank))
        return Plugin_Stop;

    ForcePlayerSuicide(tank);

    return Plugin_Stop;
}

public Action Command_ShowTotalTanks(int client, int args) {
    if (!(GetConVarInt(g_PluginEnabled) != 0))
        return Plugin_Continue;

    PrintToChatAll("Total alive tanks: %i", g_TotalAliveTanks);

    return Plugin_Handled;
}

/**
 * Checks whether the given index is a valid client index.
 *
 * @param index            Index of the alleged client.
 * @return                 True if index is a valid client index,
 *                         false otherwise.
 */
stock bool isValidClientIndex(int index) {
    return index > 0 && index <= MaxClients;
}
