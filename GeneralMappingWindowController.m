//
//  GeneralMappingWindowController.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 30.08.2017.
//
//

#import "GeneralMappingWindowController.h"
#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/BrowserController.h>

#import "OBOCollectedData.h"
#import "OBOSeries.h"

@implementation GeneralMappingWindowController

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    return [sharedData.seriesDescription count];
}

-(NSView* )tableView:(NSTableView*)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    
    NSArray *sequenceNames = [sharedData.seriesDescription allKeys];
    NSString *currentName = [sequenceNames objectAtIndex:row];
    
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"NameCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"NameCell" owner:self]; // will give us back the view that we created in the gui editor; identifier refers to TableCellView
        
        [cellView.textField setStringValue:currentName];
        return cellView;
    }
    // suffix - T1w, bold, ... - will also determine anat, func, fmap
    else if ([identifier isEqualToString:@"SuffixCol"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SuffixCell" owner:self];
        return cellView;
    }
    //session
    else if ([identifier isEqualToString:@"SessionCol"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SessionCell" owner:self];
        [cellView.textField setEditable:TRUE];
        return cellView;
    }
    // run
    else if ([identifier isEqualToString:@"RunCol"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"RunCell" owner:self];
        [cellView.textField setEditable:TRUE];
        return cellView;
    }
    // task
    else if ([identifier isEqualToString:@"TaskCol"]){
        
        NSString *currentSuffix = [[sharedData.seriesDescription objectForKey:currentName] objectForKey:@"suffix"];
        
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"TaskCell" owner:self];

        if ([currentSuffix isEqualToString:@"bold"]) {
            [cellView.textField setEditable:TRUE];
        } else {
            [cellView.textField setEditable:FALSE];
            [cellView.textField setStringValue:@""];
        }
        return cellView;
    }
    return nil;

}


-(IBAction)itemTextFieldUpdated:(id)sender{
    NSInteger selectedRow = [self.tableView rowForView:sender];
    NSString *newValue = [sender stringValue];
    NSInteger columnIndex = [self.tableView columnForView:sender];
    
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    NSArray *sequenceNames = [sharedData.seriesDescription allKeys]; // this prob should be class variable
    NSString *currentName = [sequenceNames objectAtIndex:selectedRow];
    
    if (columnIndex == 2){
        // session
        [[sharedData.seriesDescription objectForKey:currentName] setValue:newValue forKey:@"session"];
    }
    else if (columnIndex == 3){
        // task
        [[sharedData.seriesDescription objectForKey:currentName] setValue:newValue forKey:@"task"];
    }
    else if (columnIndex == 4){
        //run
        [[sharedData.seriesDescription objectForKey:currentName] setValue:newValue forKey:@"run"];
    }
    
}

- (IBAction)updateSuffix:(id)sender {
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    
    NSInteger selectedRow = [self.tableView rowForView:sender];
    NSString *selectedSuffix = [sender titleOfSelectedItem];  // WOW that worked
    
    NSArray *sequenceNames = [sharedData.seriesDescription allKeys];  // may move to class variable
    NSString *currentName = [sequenceNames objectAtIndex:selectedRow];
    
    NSDictionary * currentItem = [sharedData.seriesDescription objectForKey:currentName];
    [currentItem setValue:selectedSuffix forKey:@"suffix"];
    
    // TODO: set run to empty if non-BOLD was chosen - probably has to be done here

    [self.tableView abortEditing]; // in case editing of a text field was not finished
    [self.tableView reloadData];
}

-(IBAction)saveMapping:(id)sender{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    [sharedData.listOfSeries removeAllObjects];
    
    [self annotateAllSeries];
    
    _SummaryWindow = [[NSWindowController alloc] initWithWindowNibName:@"MappingSummaryWindow" owner:self];
    // not sure about who should be the owner, but for now it's this class
    [_SummaryWindow showWindow:self];
    
}

-(void) annotateAllSeries {
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    NSPredicate *takeOnlyMR = [NSPredicate predicateWithFormat:@"modality = %@", @"MR"];
    NSMutableArray *decoratedFromCurrentStudy = [[NSMutableArray alloc] init];
    NSCountedSet *namesFromCurrentStudy = [[NSCountedSet alloc] init];  // to keep track of repetitions
    
    for (DicomStudy *currentStudy in sharedData.listOfStudies) {
        [decoratedFromCurrentStudy removeAllObjects];
        [namesFromCurrentStudy removeAllObjects];
        for (DicomSeries *currentSeries in [[currentStudy imageSeries] filteredArrayUsingPredicate:takeOnlyMR]) {

            OBOSeries *decoratedSeries = [[OBOSeries alloc] initWithSeries:currentSeries params:[sharedData.seriesDescription objectForKey:currentSeries.name]];
            [decoratedSeries setValue:currentStudy.name forKey:@"participant"];
            // ENH: possibly store in originalName field and allow changing participant field
            //[sharedData.listOfSeries addObject:decoratedSeries];
            [decoratedFromCurrentStudy addObject:decoratedSeries];
            [namesFromCurrentStudy addObject:currentSeries.name];  // probably should treat fmaps separately
        }
        
        // handle series which had the same series name: add run numbers (if not given) or discard all but the last
        for (NSString *seriesName in [namesFromCurrentStudy objectEnumerator]) {
            if ([namesFromCurrentStudy countForObject:seriesName] > 1) { // series with this name has been repeated
                // get (decorated) series matching this name
                NSArray *repeated = [decoratedFromCurrentStudy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"originalName=%@", seriesName]];
                // sort them by acquisition date
                repeated = [repeated sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    NSDate *first = [[(OBOSeries*)obj1 series] date];
                    NSDate *second = [[(OBOSeries*)obj2 series] date];
                    return [first compare:second];
                }];
                
                if ([[[sharedData.seriesDescription objectForKey:seriesName] objectForKey:@"run"] length] > 0) {
                    // run number was specified for this study name, assume it's a repeat and discard all but latest
                    for (int i = 0; i < [repeated count] - 1; i++){
                        [[repeated objectAtIndex:i] setDiscard:YES];  // turns out this is the way to set bool flag :/
                        [[repeated objectAtIndex:i] setValue:@"Discard - repeated" forKey:@"comment"];
                    }
                }
                else {
                    // create and insert run numbers
                    for (int i = 0; i < [repeated count]; i++){
                        [[repeated objectAtIndex:i] setValue:[@(i+1) stringValue] forKey:@"run"];
                    }
                }
            }
        }
        
        [sharedData.listOfSeries addObjectsFromArray:decoratedFromCurrentStudy];
    }
}

@end
