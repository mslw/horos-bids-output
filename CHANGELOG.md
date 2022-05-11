#  Changelog
All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project versioning is based on [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2022-05-11
### Added
- Enabled blip-up & blip-down fieldmap EPI (dir-AP_epi & dir-PA_epi)
- Internal: added dir to OBOSeries

## [1.0.0] - 2018-08-10
### Added
- Optional scans.tsv file (containing relative path, scan date and time for all scans within a subject/session) can be optionally created
- Limited error handling: when dcm2niix exits with non-zero code (fails to convert dicoms for whatever reason), report this in a log file and move on to the next series
- When the plugin is unable to properly rename a field map file, also report this in a log file and move on to the next series

### Fixed
- Position of buttons added in 0.5.0 is now properly adjusted when the window is resized
- Files with _e2_ph suffix added by dcm2niix (field map phasediff file) are now handled properly (prior to April 2018, dcm2niix versions added only _e2)

## [0.5.0] - 2018-06-10

### Added
- General mapping (sequence name to BIDS meaning) can be stored in json files and reused
- Mapping summary (which dicom series was exported to which file) is automatically saved in a csv file

### Changed
- Dicom files are symlinked rather than copied (thanks @malywladek for the suggestion)
- Bold and fmap jsons have keys sorted alphabetically for better readability (only available on MacOS 10.13 and later, so on older systems the keys will not be sorted)
- Mapping table scales with the window
- A different widget (ComboBox) is used for choosing BIDS suffix. It's scrollable, with most common options at the top
- Build target changed to MacOS 10.12

### Fixed
- General mapping window is more closely tied to its data structure. As a result, labels shouldn't swap places any more when there are so many sequences that the table becomes scrollable.

## [0.4.1] - 2018-03-07
### Added
- Exporting dwi files is now possible

### Changed
- PD and dwi were added to suffix list in the GUI

### Fixed
- Fix setting session label from sequence name
- Include acq label in fmap and anat file names
- Properly format paths to dcm2niix and BIDS root (specified through the file selection window) if they contain spaces

## [0.4.0] - 2018-02-10
### Added
- Dataset description now has a dedicated popover, where all fields can be filled
- Some tooltips & window titles

### Changed
- Setting subject and session rules is now done in one sweep (simpler and more intuitive)

## [0.3.1] - 2018-02-02
### Changed
- Updated the version number
- Updated this changelog

## [0.3.0] - 2018-02-02
### Added
- Session label can be entered by user or taken from ether subject name or series name using regular expressions.
- Subjects can be renamed using regular expressions.
- Acq label can be added

### Changed
- Session label no longer can be filled in the table, but it now has a dedicated popover.
- T2map was added to suffix list in the GUI

## [0.2.0] - 2018-01-21
### Added
- New input field for the dataset name in the GUI.
- Creation of the `dataset_description.json` file with basic (obligatory) contents.
- Removal of JSON sidecars for fieldmap magnitude images.

### Changed
- Fieldmap files now don't have the _e2 suffix from dcm2niix.
- General Mapping Window task column was changed to task name column, and the task label is now derived from its content by removing non-alphanumeric characters (rather than taken literally).

## [0.1.1] - 2018-01-18
### Added
- Make the temporary folder hidden (bids_root/.dicom), clear it during use and remove after export ends.
- Fix links in README.

## [0.1] - 2018-01-10
### Added
- All the functionality in its first released version.
