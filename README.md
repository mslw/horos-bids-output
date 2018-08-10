# Horos (Osirix) Bids Output Extension
OsiriX / Horos plugin for BIDS output. Created during Stanford Center for Reproducible Neuroscience coding sprint 2017. The plugin allows creation of fundamental BIDS structure from within Horos GUI, based on a mapping between sequence name and BIDS terms entered by user.

![Plugin interface](/images/BOE_screenshot.png)

## Information for users

### Installation
Download the HorosBidsOutput.horosplugin from the [releases](https://github.com/mslw/osirix-bids-output/releases) page above. If you have Horos installed, double-clicking the .horosplugin file should launch horos with a prompt and install the plugin for the current user.

Alternatively, the file can be manually placed in: `~/Library/Application Support/Horos/Plugins/`. Regardless of the installation method, the plugin can then be made available to all users through Horos' Plugins Manager.

### Dependencies: dcm2niix
Bids Output Extension works by launching [dcm2niix](https://github.com/rordenlab/dcm2niix), which has to be available. To install dcm2niix, go to [dcm2niix releases page](https://github.com/rordenlab/dcm2niix/releases) and download the executable.

The dcm2niix executable can be placed anywhere on your computer. However, if an executable file named dcm2niix is found in your home directory, Bids Output Extension will use it by default.

### Usage
For usage instructions, see the [project wiki](https://github.com/mslw/osirix-bids-output/wiki).

### Caveats
1. Please keep in mind that the aim of the plugin is to create the fundamental BIDS structure, and the resulting dataset will most likely require some manual tweaks to become complete. This may include filling in some JSON fields (only the strictly obligatory ones are present) and adding stimulus information.
2. Field maps are handled only in the case of one phasediff and two magnitude images (based on the Siemens Trio output).
3. Not all BIDS suffixes are available in the GUI.
For more details, see the [known limitations](https://github.com/mslw/horos-bids-output/wiki#known-limitations) section of project wiki.

### About Osirix / Horos
OsiriX and Horos are DICOM image viewers / database browsers. Horos is based upon OsiriX. The plugin development switched from OsiriX to Horos prior to 0.1 release, but it is likely that the plugin will be compatible with both.

**Horos**: [website](https://www.horosproject.org), [github](https://github.com/horosproject/horos)

**OsiriX**: [website](http://www.osirix-viewer.com), [github](https://github.com/pixmeo/osirix)

### About Brain Imaging Data Structure
See [bids.neuroimaging.io](http://bids.neuroimaging.io)

## Information for developers

### Things to change after cloning
1. OsiriXAPI.framework is not included in this repository (the folder is just a placeholder).
Use the API taken from [here](https://github.com/pixmeo/osirixplugins/tree/develop/_help/MyNewPluginTemplate).
2. In Xcode, choose Edit Scheme.
   1. In the Info tab, set Executable to Horos (or OsiriX).
   2. In the Arguments tab, add the following argument passed on launch: `--LoadPlugin $(BUILT_PRODUCTS_DIR)/$(PRODUCT_NAME).$(WRAPPER_EXTENSION)`

### Useful resources
This materials helped me start writing the plugin and I am immensely grateful to their creators.
* http://mrkonrad.github.io/MRKonrad/Horos-Plugin (tips on setting up the Xcode project by Konrad Werys)
* https://github.com/pixmeo/osirixplugins (plugin template and multiple plugins)
* https://github.com/horosproject/horosplugins (as above)
* Excellent [video tutorials](https://www.youtube.com/watch?v=X_MJd8wqTBM&list=PLE83F832121568D36) on Cocoa Programing by Lucas Derraugh, with a [matching GitHub repository](https://github.com/lucasderraugh/AppleProg-Cocoa-Tutorials).
