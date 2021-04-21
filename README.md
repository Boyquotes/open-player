# OpenPlayer - Music that doesn't waste your time.

![Devices using OpenPlayer](https://raw.githubusercontent.com/nathanfranke/open-player/main/App/Branding/Press/devices.png)

* Import MP3 and OGG Vorbis music from your computer.
* Stream audio from [YouTube](https://www.youtube.com/).

### Exporting

1) Clone the [Godot Engine](https://github.com/godotengine/godot/) repository, and checkout the `3.x` branch. Alternatively, [download and extract the zip](https://github.com/godotengine/godot/archive/refs/heads/3.x.zip).
2) Clone the [gdaudioyt](https://github.com/nathanfranke/gdaudioyt/) repository. Alternatively, [download and extract the zip](https://github.com/nathanfranke/gdaudioyt/archive/refs/heads/main.zip). Copy it to the `modules` directory inside the Godot Engine source code.
3) Clone the [open-player](https://github.com/nathanfranke/open-player) repository. Alternatively, [download it as a zip](https://github.com/nathanfranke/open-player/archive/refs/heads/main.zip).
4) [Compile for your current platform](https://docs.godotengine.org/en/stable/development/compiling/index.html).
5) [Compile export templates for your target platform](https://docs.godotengine.org/en/stable/development/compiling/index.html).
6) Using your build of the godot editor, import the `open-player` project.
7) Create a new export preset for your desired platform, and export the project.
