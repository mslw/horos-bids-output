//
//  GeneralMappingWindowController.h
//  OsirixBidsOutput
//
//  Copyright (c) 2018 Michał Szczepanik.
//
//  This file is part of Osirix / Horos BIDS Output Extension.
//
//  BIDS Output Extension is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BIDS Output Extension is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with BIDS Output Extension. If not, see <http://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>

#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>

@interface GeneralMappingWindowController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *minimumBoldField;
@property (weak) IBOutlet NSTextField *datasetNameField;

@property (weak) IBOutlet NSPopover *sessionPopover;
@property (weak) IBOutlet NSTextField *sessionPattern;
@property (weak) IBOutlet NSPopUpButton *sessionMethod;
@property (weak) IBOutlet NSTextFieldCell *sessionMethodLabel;
@property (weak) IBOutlet NSTextField *subjectReplaceLabel1;
@property (weak) IBOutlet NSTextField *subjectReplaceLabel2;

@property (nonatomic, strong) NSWindowController *SummaryWindow;


- (IBAction)updateSuffix:(id)sender;
- (IBAction)itemTextFieldUpdated:(id)sender;
- (IBAction)saveMapping:(id)sender;
- (IBAction)showSessionPopover:(id)sender;
- (IBAction)sessionMethodChanged:(id)sender;

- (void) annotateAllSeries;
- (void) assignFieldMapSuffixes:(NSArray*)fieldMapTriplet;
- (NSString*) createSessionLabelForStudy:(DicomStudy*)study;
- (NSString*) createSubjectNameForStudy:(DicomStudy*)study;

@end
