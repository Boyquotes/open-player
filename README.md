# OpenPlayer - Music that doesn't waste your time.

![Devices using OpenPlayer](https://raw.githubusercontent.com/nathanfranke/open-player/main/App/Press/Devices/devices.png)

* Import MP3 and OGG Vorbis music from your computer.
* Stream audio from [YouTube](https://www.youtube.com/).

## Compiling:

1) Clone the [Godot Engine](https://github.com/godotengine/godot/) repository, and checkout the `3.x` branch. Alternatively, [download it as a zip](https://github.com/godotengine/godot/archive/refs/heads/3.x.zip).
2) Clone the [gdaudioyt](https://github.com/nathanfranke/gdaudioyt/) repository. Alternatively, [download it as a zip](https://github.com/nathanfranke/gdaudioyt/archive/refs/heads/main.zip). Copy it to the `modules` directory inside the Godot Engine source code.
3) _(Optional: For Discord Rich Presence)_ Clone the [godotcord](https://github.com/Drachenfrucht1/godotcord) repository. Alternatively, [download it as a zip](https://github.com/Drachenfrucht1/godotcord/archive/refs/heads/master.zip). Copy it to the `modules` directory inside the Godot Engine source code. [Follow the setup guide here](https://github.com/Drachenfrucht1/godotcord).
4) Clone the [open-player](https://github.com/nathanfranke/open-player) repository. Alternatively, [download it as a zip](https://github.com/nathanfranke/open-player/archive/refs/heads/main.zip).
5) [Compile tools for your current platform](https://docs.godotengine.org/en/stable/development/compiling/index.html).
6) [Compile export templates for your target platform](https://docs.godotengine.org/en/stable/development/compiling/index.html).
7) Using your build of the godot editor, import the `open-player` project.
8) Create a new export preset for your desired platform, and export the project.

## License:

- The primary license of OpenPlayer is `GPL-3.0+`.
- Some icons are public domain.

See [COPYRIGHT](https://github.com/nathanfranke/open-player/blob/main/COPYRIGHT) for comprehensive licensing information.
