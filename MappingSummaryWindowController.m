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
    if ( [openDlg runModal] == NSOKButton ) {
        converterPath = [[openDlg URL] relativeString];
        converterPath = [converterPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
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
    if ( [openDlg runModal] == NSOKButton ) {
        bidsRootPath = [[openDlg URL] relativeString];
        bidsRootPath = [bidsRootPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        [_bidsRootTextField setStringValue:bidsRootPath];
    }
}

-(IBAction)exportToBids:(id)sender{
    
    // get parameters from the UI
    BOOL compress = ([[self gzCheckBox] state] == NSOnState);
    NSString *converterPath = [_converterTextField stringValue];
    NSString *bidsRootPath = [_bidsRootTextField stringValue];
    
    // check if paths seem ok
    if ([bidsRootPath length] == 0 || ![[NSFileManager defaultManager] isExecutableFileAtPath:converterPath]){
        NSAlert *warningAlert = [[NSAlert alloc] init];
        [warningAlert addButtonWithTitle:@"OK"];
        [warningAlert setAlertStyle:NSWarningAlertStyle];
        
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
    createdDicomDir = [OBOExporter createTemporaryDicomDirectoryAtPath:bidsRootPath];
    
    if (!createdDicomDir) {
        // run an NSAlert asking for permission to delete .dicom and create it again
        NSAlert *warningAlert = [[NSAlert alloc] init];
        [warningAlert setAlertStyle:NSWarningAlertStyle];
        [warningAlert addButtonWithTitle:@"Clear .dicom and proceed"];
        [warningAlert addButtonWithTitle:@"Cancel"];
        [warningAlert setMessageText:@"Error when creating temporary .dicom directory"];
        [warningAlert setInformativeText:@"It appears that .dicom directory in your Bids Root already exists and may cause export conflicts. Make sure to remove it before converting.\n This error may also occur if the directory didn't exist, but could not be created."];
        
        if ([warningAlert runModal] == NSAlertFirstButtonReturn) {
            // user chose to remove dicomdir, try removing & creating again
            [OBOExporter removeTemporaryDicomDirectoryAtPath:bidsRootPath];
            createdDicomDir = [OBOExporter createTemporaryDicomDirectoryAtPath:bidsRootPath];
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
    
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    for (OBOSeries *currentSeries in [sharedData listOfSeries]) {
        if ( ![currentSeries discard] && [[currentSeries getBidsPath] length] > 0) {
            [OBOExporter exportSeries:currentSeries
                     usingConverterAt:converterPath
                             toFolder:bidsRootPath
                      withCompression:compress];
        }
    }
    
    [OBOExporter removeTemporaryDicomDirectoryAtPath:bidsRootPath];
    
    // write dataset_description.json
    NSMutableDictionary *datasetDescription = [[NSMutableDictionary alloc] init];
    if ([sharedData.datasetName length] > 0){
        [datasetDescription setValue:sharedData.datasetName forKey:@"Name"];
    } else {
        [datasetDescription setValue:@"Horos Exported Dataset" forKey:@"Name"];
    }
    [datasetDescription setValue:@"1.0.2" forKey:@"BIDSVersion"];
    
    if ([NSJSONSerialization isValidJSONObject:datasetDescription]){
        NSString *jsonPath = [NSString pathWithComponents:@[bidsRootPath, @"dataset_description.json"]];
        NSData *datasetDescriptionData = [NSJSONSerialization dataWithJSONObject:datasetDescription options:NSJSONWritingPrettyPrinted error:nil];
        [datasetDescriptionData writeToFile:jsonPath atomically:NO];
    }
    
    // report the export as finished
    
    [[self spinner] stopAnimation:self];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Finished exporting files."];
    [alert runModal];
    
}

@end
