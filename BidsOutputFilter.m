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
    
    // see if it worked - display the series using a simple NSAlert
    NSMutableString *chainedStudies = [[NSMutableString alloc] init];
    for (NSString *name in uniqueStudyNames) {
        [chainedStudies appendString:name];
        [chainedStudies appendString:@"\n"];
    }
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Found the following study names"];
    [alert setInformativeText:chainedStudies];
    [alert runModal];

    return 0;
}

@end
