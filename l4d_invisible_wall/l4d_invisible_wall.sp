#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.1.0"

public Plugin myinfo = {
    name = "[L4D] Invisible Wall",
    author = "samuelviveiros a.k.a Dartz8901",
    description = "Invisible Wall",
    version = PLUGIN_VERSION,
    url = "https://github.com/samuelviveiros/"
};

#define TEAM_SURVIVOR 2
#define DUMMY_MODEL "models/error.mdl"

Handle g_PluginEnabled = null;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    EngineVersion engine = GetEngineVersion();

    if (engine != Engine_Left4Dead) {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

public void OnPluginStart() {
    CreateConVar(
        "l4d_invisible_wall_version",
        PLUGIN_VERSION,
        "[L4D] Invisible Wall version",
        FCVAR_REPLICATED | FCVAR_NOTIFY
    );

    g_PluginEnabled = CreateConVar(
        "l4d_invisible_wall_enable",
        "1",
        "Enable or disable this plugin.",
        FCVAR_NOTIFY,
        true, 0.0,
        true, 1.0
    );

    AutoExecConfig(true, "l4d_invisible_wall");
    RegConsoleCmd("test123", Command_Test123);
}

public void OnMapStart() {
    PrecacheModel(DUMMY_MODEL);
}

public Action Command_Test123(int client, int args) {
    float pos[3] = { 0.00, 0.00, 0.00 };
    float mins[3] = { -50.0, -50.0, -50.0 };
    float maxs[3] = { 50.0, 50.0, 50.0 };

    GetClientAimPosition(client, pos);
    PrintToChatAll("Pos: %f, %f, %f", pos[0], pos[1], pos[2]);

    int entity = CreateFuncBrush(pos, mins, maxs);
    PrintToChatAll("func_brush: %i", entity);

    return Plugin_Handled;
}


stock int CreateFuncBrush(float pos[3], float mins[3], float maxs[3]) {
    int entity = CreateEntityByName("func_brush");
    if (entity == -1) {
        LogError("Could not create func_brush.");
        return -1;
    }

    if (!DispatchSpawn(entity)) {
        LogError("Could not spawn func_brush.");
        DestroyEntity(entity);
        return -1;
    }

    // A model is necessary here, otherwise game will crashes
    if (!IsModelPrecached(DUMMY_MODEL)) {
        LogError("Could not apply model to func_brush.");
        DestroyEntity(entity);
        return -1;
    }
    DispatchKeyValue(entity, "model", DUMMY_MODEL);

    // mins and maxs must be configured after model
    DispatchKeyValueVector(entity, "mins", mins);  // Min. bounding box size
    DispatchKeyValueVector(entity, "maxs", maxs);  // Max. bounding box size

    DispatchKeyValueVector(entity, "origin", pos);  // Perform teleport
    DispatchKeyValue(entity, "solid", "2");  // 2 = Bounding Box

    // Avoiding console error: "ERROR: Can't draw studio model
    // models/error.mdl because CFuncBrush is not derived from
    // C_BaseAnimating"
    DispatchKeyValue(entity, "rendermode", "10");  // 10 = Don't render

    return entity;
}

stock void DestroyEntity(const int entity) {
    if (IsValidEntity(entity)) {
        AcceptEntityInput(entity, "Kill");
    }
}

stock bool GetClientAimPosition(int client, float aimPosition[3]) {
    float angles[3];
    float origin[3];
    float buffer[3];
    float start[3];
    float distance;

    GetClientEyePosition(client, origin);
    GetClientEyeAngles(client, angles);

    // Get endpoint.
    Handle trace = TR_TraceRayFilterEx(
        origin,
        angles,
        MASK_SHOT,
        RayType_Infinite,
        Callback_TraceEntityFilter
    );
        
    if (TR_DidHit(trace)) {   	 
        TR_GetEndPosition(start, trace);
        GetVectorDistance(origin, start, false);
        distance = -35.0;
        GetAngleVectors(angles, buffer, NULL_VECTOR, NULL_VECTOR);
        aimPosition[0] = start[0] + (buffer[0] * distance);
        aimPosition[1] = start[1] + (buffer[1] * distance);
        aimPosition[2] = start[2] + (buffer[2] * distance);
    } else {
        // Could not get end point.
        CloseHandle(trace);
        return false;
    }

    CloseHandle(trace);
    return true;
}
public bool Callback_TraceEntityFilter(int entity, int contentsMask) {
	return entity > GetMaxClients() || !entity;
}
