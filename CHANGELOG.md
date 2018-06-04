#  Changelog
All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project versioning is based on [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Mapping summary (which series was exported to which file) is saved in a csv file

### Changed
- Dicom files are symlinked rather than copied (thanks @malywladek for the suggestion)  
- Mapping table scales with the window

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
