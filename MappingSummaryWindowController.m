//
//  MappingSummaryWindowController.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 08.01.2018.
//

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
