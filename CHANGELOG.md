#  Changelog
All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project versioning is based on [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Session label can be entered by user or taken from ether subject name or series name using regular expressions.
- Subjects can be renamed using regular expressions.

### Changed
- Session label no longer can be filled in the table, but it now has a dedicated popover.

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
