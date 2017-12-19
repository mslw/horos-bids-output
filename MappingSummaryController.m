//
//  MappingSummaryController.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 12.12.2017.
//

#import "MappingSummaryController.h"
#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>

#import "OBOCollectedData.h"
#import "OBOSeries.h"
#import "OBOExporter.h"

@implementation MappingSummaryController

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    return [sharedData.listOfSeries count];
}

-(NSView* )tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    
    OBOSeries *currentSeries = [[sharedData listOfSeries] objectAtIndex:row];
    
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"SubjectCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SubjectCell" owner:self];
        [cellView.textField setStringValue:[currentSeries participant]];
        return cellView;
    }
    else if ([identifier isEqualToString:@"NameCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"NameCell" owner:self];
        [cellView.textField setStringValue:[[currentSeries series] valueForKey:@"name"]];
        return cellView;
    }
    else if ([identifier isEqualToString:@"SidCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SidCell" owner:self];
        [cellView.textField setStringValue:[[currentSeries series] valueForKey:@"id"]];
        return cellView;
    }
    else if ([identifier isEqualToString:@"BidsCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"BidsCell" owner:self];
        [cellView.textField setStringValue:[currentSeries getBidsPath]];
        return cellView;
    }
    
    return nil;
}

-(IBAction)exportToBids:(id)sender{
    
    BOOL compress = ([[self gzCheckBox] state] == NSOnState);
    
    [[self spinner] startAnimation:self];
    
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    for (OBOSeries *currentSeries in [sharedData listOfSeries]) {
        if ( ![currentSeries discard] && [[currentSeries getBidsPath] length] > 0) {
            [OBOExporter exportSeries:currentSeries useCompression:&compress];
        }
    }
    
    [[self spinner] stopAnimation:self];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Finished"];
    [alert runModal];
    
}

@end
