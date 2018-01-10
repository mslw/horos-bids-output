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
    
    [[self spinner] stopAnimation:self];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Finished"];
    [alert runModal];
    
}

@end
