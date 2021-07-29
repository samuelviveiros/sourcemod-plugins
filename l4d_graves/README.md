# [L4D & L4D2] Graves

## DESCRIPTION: 

This is a SourceMod plugin.

When a survivor dies, a grave appears near his body, and this grave glows through the objects on the map, allowing a quick location from where the survivor died. 

And when the survivor respawn, the grave associated with him disappears.

In addition, there are six types of grave that are chosen randomly.

Maybe can be useful for use with a defibrillator (L4D2), or even for those who use the "Emergency Treatment With First Aid Kit Revive And CPR" (L4D) plugin, for example. 

Anyway, I made this more for fun than for some utility.

This plugin is also based on the Tuty plugin (CSS Graves), which can be found here:

https://forums.alliedmods.net/showthread.php?p=867275

And this is my post on the AlliedModders forum:

https://forums.alliedmods.net/showthread.php?p=2631187

Do not forget to update the CFG file with the new CVARs.

For Left 4 Dead, the file is located in left4dead/cfg/sourcemod/l4d_graves.cfg.

And for Left 4 Dead 2, the file is located in left4dead2/cfg/sourcemod/l4d_graves.cfg

## CHANGELOG:

2018-12-27 (v1.1.1)
- Added the l4d_graves_delay CVAR that determines how long it will take for the grave to spawn. This delay is necessary to avoid cases, for example, where a Tank has just killed a survivor and the grave appears instantly, and Tank immediately breaks the grave.
- Added the l4d_graves_not_solid CVAR that allows you to turn grave solidity on or off. The reason is that some players have said that they sometimes get stuck on the grave when it spawns. In such cases, the admin may prefer to disable solidity.
- Fixed client index issue when calling GetClientTeam function.

2018-12-27 (v1.0.1)
- Function RemoveEntity has been replaced by function AcceptEntityInput, passing the "Kill" parameter, so that it work with the online compiler.

2018-12-26 (v1.0.0)
- Initial release.
