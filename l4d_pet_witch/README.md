# [L4D] Pet Witch (v1.0.0, 2019-08-08)

## DESCRIPTION: 

This is a SourceMod plugin for Left 4 Dead 1.

This plugin allows an admin to spawn a "pet witch" and attack a selected player.

Only admins with the **slay flag** can use it.

I will explain how the menu works.

In option 1 of the menu you can spawn one or more pet witches. The pet is totally harmless (unless you or another player shoves her). Other players cannot cause damage to the pet (but you, the owner, can). This prevents other players from killing your pet witch, unless, of course, she is ordered to attack. If you shove, shoot or burn your own pet witch, this will cause damage to her, but you will not suffer any damage when she attacks you.

In option 2 you can select the target (only survivors) and immediately start the attack.

Finally, in option 3, you can kill all your pets at once.

As an admin, you can use this plugin to apply a differentiated and yet fun punishment to some other badly behaved player.

[This](https://forums.alliedmods.net/showthread.php?t=318010) is my post on the AlliedModders forum:

And [here](https://youtu.be/59huDdHSRXc) a demo video.


## COMMANDS:

**sm_petwitch** - Opens the plugin menu.


## CVARS:

- **l4d_pet_witch_enable** - Enable or disable this plugin. Default: "1". Minimum: "0.000000". Maximum: "1.000000".
- **l4d_pet_witch_version** - Plugin version. Default: "1.0.0".


## COMPILATION ISSUE:

This plugin uses functions like SDKHook, SDKUnhook and HasEntProp which cause compilation errors with the web compiler. You must to compile the source code by yourself using the latest sourcemod compiler version.


## CHANGELOG:

### 2018-08-08 (v1.0.0)
- Initial release.
