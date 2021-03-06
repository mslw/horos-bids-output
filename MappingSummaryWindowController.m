//
//  MappingSummaryWindowController.m
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

#import "MappingSummaryWindowController.h"

#import "OBOCollectedData.h"
#import "OBOSeries.h"
#import "OBOExporter.h"

@interface MappingSummaryWindowController ()

@end

@implementation MappingSummaryWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString* defaultConverterPath = [NSHomeDirectory() stringByAppendingPathComponent:@"dcm2niix"];
    
    if ( [[NSFileManager defaultManager] isExecutableFileAtPath:defaultConverterPath] )
    {
        [_converterTextField setStringValue:defaultConverterPath];
    }
    
}

-(IBAction)changeConverterPath:(id)sender{
    NSString *converterPath;
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    if ( [openDlg runModal] == NSModalResponseOK ) {
        converterPath = [[openDlg URL] relativeString];
        converterPath = [converterPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        converterPath = [converterPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        [_converterTextField setStringValue:converterPath];
    }
}

-(IBAction)changeBidsRoot:(id)sender{
    NSString *bidsRootPath;
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    if ( [openDlg runModal] == NSModalResponseOK ) {
        bidsRootPath = [[openDlg URL] relativeString];
        bidsRootPath = [bidsRootPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        bidsRootPath = [bidsRootPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        [_bidsRootTextField setStringValue:bidsRootPath];
    }
}

-(IBAction)exportToBids:(id)sender{
    
    // get parameters from the UI
    BOOL compress = ([[self gzCheckBox] state] == NSOnState);
    BOOL createScans = ([[self scansCheckBox] state] == NSOnState);
    NSString *converterPath = [_converterTextField stringValue];
    NSString *bidsRootPath = [_bidsRootTextField stringValue];
    
    // check if paths seem ok
    if ([bidsRootPath length] == 0 || ![[NSFileManager defaultManager] isExecutableFileAtPath:converterPath]){
        NSAlert *warningAlert = [[NSAlert alloc] init];
        [warningAlert addButtonWithTitle:@"OK"];
        [warningAlert setAlertStyle:NSAlertStyleWarning];
        
        if ([bidsRootPath length] == 0){
            [warningAlert setMessageText:@"Empty BIDS root path"];
            [warningAlert setInformativeText:@"Specify the path where BIDS root should be."];
        } else {
            [warningAlert setMessageText:@"Invalid dcm2niix executable"];
            [warningAlert setInformativeText:@"Either path is incorrect or the chosen file can't be executed by the user."];
        }
        
        [warningAlert runModal];
        return;
    }
    
    // create a temporary directory for dicoms, do not run conversion if directory already exists
    BOOL createdDicomDir;
    createdDicomDir = [OBOExporter createTemporaryDicomDirectory];
    
    if (!createdDicomDir) {
        // run an NSAlert asking for permission to delete temporary dicom folder and create it again
        NSAlert *warningAlert = [[NSAlert alloc] init];
        [warningAlert setAlertStyle:NSAlertStyleWarning];
        [warningAlert addButtonWithTitle:@"Clear dicom and proceed"];
        [warningAlert addButtonWithTitle:@"Cancel"];
        [warningAlert setMessageText:@"Error when creating temporary dicom directory"];
        [warningAlert setInformativeText:@"It appears that temporary dicom directory in ~/HorosBidsOutput folder already exists and may cause export conflicts. Make sure to remove the dicom folder before converting.\n This error may also occur if the directory didn't exist, but could not be created."];
        
        if ([warningAlert runModal] == NSAlertFirstButtonReturn) {
            // user chose to remove dicomdir, try removing & creating again
            [OBOExporter removeTemporaryDicomDirectory];
            createdDicomDir = [OBOExporter createTemporaryDicomDirectory];
            if (!createdDicomDir) {
                // still unable to create directory, possibly because of access rights
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Could not proceed"];
                [alert runModal];
                return;
            }
        } else {
            // user chose not to proceed, do nothing
            return;
        }
    }
    
    [[self spinner] startAnimation:self];

    // prepare for error handling
    BOOL convertSuccessful;
    NSError *conversionError;
    NSMutableArray *errorList = [[NSMutableArray alloc] init];
    
    // run the conversion for each file
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    for (OBOSeries *currentSeries in [sharedData listOfSeries]) {
        conversionError = nil;
        if ( ![currentSeries discard] && [[currentSeries getBidsPath] length] > 0) {
            convertSuccessful = [OBOExporter exportSeries:currentSeries
                                         usingConverterAt:converterPath
                                                 toFolder:bidsRootPath
                                          withCompression:compress
                                            withScansFile:createScans
                                                    error:&conversionError ];
            if (!convertSuccessful) {
                // if an error occurs, just store file name and error description (but we could also break out of the loop here)
                [errorList addObject:@[currentSeries.getBidsPath, conversionError.localizedDescription]];
            }
        }
    }

    [OBOExporter removeTemporaryDicomDirectory];

    // save summary table to a csv file
    [self saveSummary];
    
    // log errors if found
    if ([errorList count] > 0) {
        [self saveErrors:errorList];
    }
    
    // write dataset_description.json
    NSMutableDictionary *datasetDescription = [sharedData datasetDescription];
    
    if ([sharedData writeDatasetDescription] && [NSJSONSerialization isValidJSONObject:datasetDescription]){
        NSString *jsonPath = [NSString pathWithComponents:@[bidsRootPath, @"dataset_description.json"]];
        NSData *datasetDescriptionData = [NSJSONSerialization dataWithJSONObject:datasetDescription options:NSJSONWritingPrettyPrinted error:nil];
        [datasetDescriptionData writeToFile:jsonPath atomically:NO];
    }
    
    // report the export as finished
    
    [[self spinner] stopAnimation:self];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Finished exporting files."];
    if ([errorList count] > 0) {
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert setInformativeText:@"Export finished with errors.\nCheck errors_(datetime).txt file in ~/HorosBidsOutput folder."];
    }
    [alert runModal];
    
}

-(void)saveSummary {
  OBOCollectedData *sharedData = [OBOCollectedData sharedManager];

  // create file name containing date
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd_HHmmss"];
  NSString *fileName = [NSString stringWithFormat:@"export_%@.csv", [dateFormatter stringFromDate:now]];
  NSString *filePath = [NSString pathWithComponents:@[NSHomeDirectory(), @"HorosBidsOutput", fileName]];

  // prepare strings for csv content and row
  NSMutableString * csvRep = [NSMutableString new];
  NSString *row;

  // add header
    row = [NSString stringWithFormat:@"%@;%@;%@;%@;%@\n",
		  @"Subject Name",
		  @"Series Name",
		  @"Series ID",
		  @"Comment",
		  @"BIDS path"];
  [csvRep appendString:row];

  // add contents
  for (OBOSeries *currentSeries in [sharedData listOfSeries])
    {
        row = [NSString stringWithFormat:@"%@;%@;%@;%@;%@\n",
		      [currentSeries originalSubjectName],
		      [[currentSeries series] valueForKey:@"name"],
		      [[currentSeries series] valueForKey:@"id"],
		      [currentSeries comment],
		      [currentSeries getBidsPath]];
      [csvRep appendString:row];
    }

  // write the file
  [csvRep writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) saveErrors: (NSMutableArray*) errorList {
        
    // create file name containing date
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"errors_%@.txt", [dateFormatter stringFromDate:now]];
    NSString *filePath = [NSString pathWithComponents:@[NSHomeDirectory(), @"HorosBidsOutput", fileName]];
    
    // prepare strings for csv content and row
    NSMutableString * tsvRep = [NSMutableString new];
    NSString *row;
    
    // add contents
    for (NSArray *entry in errorList) {
        row = [NSString stringWithFormat:@"%@\t%@\n", [entry objectAtIndex:0], [entry objectAtIndex:1]];
        [tsvRep appendString:row];
    }
    
    // write the file
    [tsvRep writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

}

@end
