# Osirix Bids Output Extension
OsiriX plugin for BIDS output. Created during Stanford Center for Reproducible Neuroscience coding sprint 2017.
Work in progress.

## Things to change after cloning
1. OsiriXAPI.framework is not included in this repository (the folder is just a placeholder).
Use the API taken from [here](https://github.com/pixmeo/osirixplugins/tree/develop/_help/MyNewPluginTemplate)
2. In Xcode, choose Edit Scheme.
   1. In the Info tab, set Executable to OsiriX.
   2. In the Arguments tab, add the following argument passed on launch: `--LoadPlugin $(BUILT_PRODUCTS_DIR)/$(PRODUCT_NAME).$(WRAPPER_EXTENSION)`

## Useful resources
* http://mrkonrad.github.io/MRKonrad/Horos-Plugin (tips on setting up the project)
* https://github.com/pixmeo/osirixplugins (plugin template and multiple plugins)
* https://github.com/pixmeo/osirix
