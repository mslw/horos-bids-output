//
//  PluginTemplateFilter.m
//  PluginTemplate
//
//  Copyright (c) CURRENT_YEAR YOUR_NAME. All rights reserved.
//

#import "BidsOutputFilter.h"

#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/BrowserController.h>

#import "OBOCollectedData.h"
#import "OBOSeries.h"

@interface BidsOutputFilter()

@property (nonatomic, strong) NSWindowController *TableWindow;

@end

@implementation BidsOutputFilter

- (void) initPlugin
{
}

- (long) filterImage:(NSString*) menuName
{
    
    // just predicates for filtering
    NSPredicate *takeOnlyStudies = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:[DicomStudy class]];
    }];
    NSPredicate *takeOnlyMR = [NSPredicate predicateWithFormat:@"modality = %@", @"MR"];
    
    // get the selection
    BrowserController *currentBrowser = [BrowserController currentBrowser];
    NSArray *currentSelection = [currentBrowser databaseSelection];
    
    // take only studies (ignore selected series)
    NSArray *selectedStudies = [currentSelection filteredArrayUsingPredicate:takeOnlyStudies];
    
    // find out what are the unique study names
    NSMutableSet *uniqueStudyNames = [[NSMutableSet alloc] init];
    
    for (DicomStudy *currentStudy in selectedStudies) {
        NSArray *listOfSeries = [[currentStudy imageSeries] filteredArrayUsingPredicate:takeOnlyMR ];
        for (DicomSeries *currentSeries in listOfSeries) {
            NSString *seriesName = [currentSeries valueForKey:@"name"];
            [uniqueStudyNames addObject:seriesName];
        }
    }
    
    // initialise the singleton shared data storage
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    
    // store the selected studies for later access
    [sharedData.listOfStudies addObjectsFromArray:selectedStudies];
    
    // create a "template" description (empty strings in all fields)
    NSMutableDictionary *descriptionTemplate = [NSMutableDictionary dictionary];
    
    [descriptionTemplate setValue:@"" forKey:@"suffix"];
    [descriptionTemplate setValue:@"" forKey:@"session"];
    [descriptionTemplate setValue:@"" forKey:@"task"];
    [descriptionTemplate setValue:@"" forKey:@"run"];
    
    // Add series descriptions to the dictionary
    for (NSString *name in uniqueStudyNames) {
        [sharedData.seriesDescription setObject:[NSMutableDictionary dictionaryWithDictionary:descriptionTemplate] forKey:name];
    }
    
    // show the general mapping window
    _TableWindow = [[NSWindowController alloc] initWithWindowNibName:@"GeneralMappingWindow" owner:self];
    [_TableWindow showWindow:self];
    
//    // check if that worked
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert addButtonWithTitle:@"OK"];
//    [alert setMessageText:@"Created so many entries"];
//    [alert setInformativeText:[@([sharedData.seriesDescription count]) stringValue]];
//    [alert runModal];

    return 0;
}

-(void) annotateAllSeries {
    // TODO: account for runs in case of repeated series names
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    for (DicomStudy *currentStudy in sharedData.listOfStudies) {
        for (DicomSeries *currentSeries in [currentStudy imageSeries]) {
            
            OBOSeries *decoratedSeries = [[OBOSeries alloc] initWithSeries:currentSeries params:[sharedData.seriesDescription objectForKey:currentSeries.name]];
            [decoratedSeries setValue:currentStudy.patientID forKey:@"participant"];
            [sharedData.listOfSeries addObject:decoratedSeries];
        }
    }
}

@end
