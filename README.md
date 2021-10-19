# OpenPlayer - Music player that doesn't waste your time.

![Devices using OpenPlayer](https://raw.githubusercontent.com/nathanfranke/open-player/main/App/Branding/Screenshots/devices.png)

OpenPlayer is a free and open source music player that can import audio from your device and easily search and stream from YouTube.

## Compiling:

1) Clone the [Godot Engine](https://github.com/godotengine/godot/) repository, and checkout the `3.x` branch. Alternatively, [download it as a zip](https://github.com/godotengine/godot/archive/refs/heads/3.x.zip).
2) Clone the [gdaudioyt](https://github.com/nathanfranke/gdaudioyt/) repository. Alternatively, [download it as a zip](https://github.com/nathanfranke/gdaudioyt/archive/refs/heads/main.zip). Copy it to the `modules` directory inside the Godot Engine source code.
3) _(Optional: For Discord Rich Presence)_ Clone the [godotcord](https://github.com/Drachenfrucht1/godotcord) repository. Alternatively, [download it as a zip](https://github.com/Drachenfrucht1/godotcord/archive/refs/heads/master.zip). Copy it to the `modules` directory inside the Godot Engine source code. [Follow the setup guide here](https://github.com/Drachenfrucht1/godotcord).
4) Clone the [open-player](https://github.com/nathanfranke/open-player) repository. Alternatively, [download it as a zip](https://github.com/nathanfranke/open-player/archive/refs/heads/main.zip).
5) [Compile tools for your current platform](https://docs.godotengine.org/en/stable/development/compiling/index.html).
6) _(Optional: For optimized build)_ Create a file named `custom.py` in the Godot Engine source code.
	<details>
	<summary>File Content</summary>

	```
	disable_3d = "yes"
	production = "yes"
	deprecated = "no"
	minizip = "no"
	module_arkit_enabled = "no"
	module_bmp_enabled = "no"
	module_bullet_enabled = "no"
	module_camera_enabled = "no"
	module_csg_enabled = "no"
	module_dds_enabled = "no"
	module_enet_enabled = "no"
	module_etc_enabled = "no"
	module_gdnative_enabled = "no"
	module_gdnavigation_enabled = "no"
	module_gridmap_enabled = "no"
	module_hdr_enabled = "no"
	module_jpg_enabled = "no"
	module_jsonrpc_enabled = "no"
	module_ogg_enabled = "no"
	module_opensimplex_enabled = "no"
	module_tga_enabled = "no"
	module_theora_enabled = "no"
	module_tinyexr_enabled = "no"
	module_upnp_enabled = "no"
	module_visual_script_enabled = "no"
	module_vorbis_enabled = "no"
	module_webm_enabled = "no"
	module_webp_enabled = "no"
	```
	</details>
7) [Compile export templates for your target platform](https://docs.godotengine.org/en/stable/development/compiling/index.html).
8) Using your build of the godot editor tools:
	- Import the `open-player` project.
	- Make a new export preset for your desired platform.
	- Set the custom release/debug templates.
	
		<details>
		<summary>Extra Steps: Windows</summary>

		- Set `application/icon` to `res://App/Branding/Logos/logo_bg.ico`.
		</details>

		<details>
		<summary>Extra Steps: Android</summary>

		- Set the debug and/or release keystore.
		- Set `launcher_icons/main_192x192` to `res://App/Branding/Logos/logo_bg_192.png`.
		- Set `launcher_icons/adaptive_foreground_432x432` to `res://App/Branding/Logos/adaptive_fg.png`.
		- Set `launcher_icons/adaptive_background_432x432` to `res://App/Branding/Logos/adaptive_bg.png`.
		- Set `screen/immersive_mode` to `false`.
		- Set `permissions/internet` to `true`.
		- Set `permissions/vibrate` to `true`.
		- Set these extra parameters if desired:
			- `version/code`
			- `version/name`
			- `package/unique_name`
			- `package/name`
		</details>
9)  Export the project.

## License:

- The primary license of OpenPlayer is `GPL-3.0+`.
- Some icons are public domain.

See [COPYRIGHT](https://github.com/nathanfranke/open-player/blob/main/COPYRIGHT) for comprehensive licensing information.
