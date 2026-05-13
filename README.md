This branch includes newgrounds api integrations for game medals.

Building this branch requires the
[Newgrounds.io API addon](https://godotengine.org/asset-library/asset/2528)
to be installed in the `addons` folder.
This was done with the 2025-06-30 release.

For deployments, the `App ID` and `Aes 128 Key` need to be assigned in the
project settings.

# As Above So Below

A first person platformer with a grappling hook

An effort in making a slick movement system. Turns out doing that isn't trivial and copying the
physics from Quake / Half-Life is what most people start with. As such, the grappling leaves
something to be desired and is a little janky. I find it kind of charming though. Leaning into the
shittiness of it, the project turned into an asset flip frustration platformer.

This was made for a PSX game jam, which meant embodying Playstation 1 aesthetics. I used the lovely
[Godot PSX Style Demo](https://github.com/MenacingMecha/godot-psx-style-demo)
by MenacingMecha, a forced tiny resolution, and tiny textures to that end. Unfortunately, I
misunderstood the polycount limits of the hardware as being 90k per frame when it's actually 90k
per second, so the models used feel a little out of place.

## Assets

Assets for the project can be downloaded from
[here](https://github.com/swigof/lowpoly-winter/releases/download/1.0.1/assets.zip)

The `assets` folder of the archive should be placed in the project's top level directory

## Building

Open the project in Godot 4.6 and use the export dialog with preset Web (Runnable) to build

Build files will be placed in build/web/
