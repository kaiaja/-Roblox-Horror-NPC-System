# Installation

1. Open Roblox Studio and create or open an experience.
2. Add an NPC Model named **Shopkeeper** to `Workspace`. The model must have a `Humanoid`, `HumanoidRootPart`, and preferably a `Head`. Ensure NPC body parts are not anchored so the Humanoid can move.
3. In `ReplicatedStorage`, create a **ModuleScript** named `HorrorNPCConfig`. Paste the contents of `src/Config.lua`.
4. In `ServerScriptService`, create a **Script** named `NPCController`. Paste the contents of `src/NPCController.server.lua`.
5. In `StarterPlayer > StarterPlayerScripts`, create a **LocalScript** named `Dialogue`. Paste the contents of `src/Dialogue.client.lua`.
6. Press Play, approach the NPC, and press the ProximityPrompt key to talk.
7. Optionally customize dialogue, audio IDs and settings in the scripts. The jumpscare is triggered randomly only when choosing “Anything strange?”.

## Troubleshooting
- No NPC? Check its model name matches `NPCName` in config.
- Not walking? Check HumanoidRootPart, unanchored body parts, map navigation, and Studio Output.
- No dialogue? Check the RemoteEvent is created by the server script and no script errors appear in Output.
- No sound? Add an audio ID your experience has permission to use.

## Roadmap
- Optional custom walk/idle animations
- Improved NPC lip-sync and dialogue audio
- More horror encounters and NPC personalities
- Automated testing and Rojo project support
