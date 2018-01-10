# Horos (Osirix) Bids Output Extension
OsiriX / Horos plugin for BIDS output. Created during Stanford Center for Reproducible Neuroscience coding sprint 2017.
Work in progress.

## Information for users

### Installation
Download the HorosBidsOutput.horosplugin from releases page (not available yet). If you have Horos installed, double-clicking the .horosplugin file should launch horos with a prompt and install the plugin for the current user.

Alternatively, the file can be manually placed in: `~/Library/Application Support/OsiriX/Plugins/`. Regardless of the installation method, the plugin can then be made available to all users through Horos' Plugins Manager.

### Dependencies: dcm2niix
Bids Output Extension works by launching [dcm2niix](https://github.com/rordenlab/dcm2niix), which has to be available. To install dcm2niix, go to its releases page and download the executable. 

The dcm2niix executable can be placed anywhere on your computer. The location has to specified in the GUI before exporting. If an executable file named dcm2niix is found in your home directory, Bids Output Extension will use it by default.

### Usage
For usage instructions, see the [project wiki](https://github.com/mslw/osirix-bids-output/wiki).

### About Osirix / Horos
OsiriX and Horos are DICOM image viewers / database browsers. Horos is based upon OsiriX. The plugin development switched from OsiriX to Horos, but it should be compatible with both.

**Horos**: [website](https://www.horosproject.org), [github](https://github.com/horosproject/horos)

**OsiriX**: [website](http://www.osirix-viewer.com), [github](https://github.com/pixmeo/osirix)

## Information for developers

### Things to change after cloning
1. OsiriXAPI.framework is not included in this repository (the folder is just a placeholder).
Use the API taken from [here](https://github.com/pixmeo/osirixplugins/tree/develop/_help/MyNewPluginTemplate).
2. In Xcode, choose Edit Scheme.
   1. In the Info tab, set Executable to Horos (or OsiriX).
   2. In the Arguments tab, add the following argument passed on launch: `--LoadPlugin $(BUILT_PRODUCTS_DIR)/$(PRODUCT_NAME).$(WRAPPER_EXTENSION)`

### Useful resources
* http://mrkonrad.github.io/MRKonrad/Horos-Plugin (tips on setting up the project)
* https://github.com/pixmeo/osirixplugins (plugin template and multiple plugins)
* https://github.com/horosproject/horosplugins (as above)
