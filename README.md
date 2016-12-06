# max-gen-skeleton

This is a skeleton for creating Max gen~ based plugins.

It's intended to be used in scripts, in an automated way.<br/>
But it's also possible to be used manually.

Just follow these steps:
* Copy gen_exported.cpp and gen_exported.h into the plugin folder
* Run ./setup.sh and enter the desired plugin name
* Compile the plugin using 'make'

By default you get a LV2 and VST2.4 plugin.<br/>
If you have Linux and JACK installed, you'll get a JACK standalone too.

This plugin skeleton does not provide support for custom UIs.<br/>
For LV2 plugins this is not an issue as you can create UIs without modifying the original DSP object.
