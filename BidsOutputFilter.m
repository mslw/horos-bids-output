//
//  BidsOutputFilter.m
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
    
    // clean up possible leftovers from previous usages
    // (closing plugin window doesn't clear the underlying data, possibly should implement a delegate
    if ([sharedData.listOfStudies count] > 0) {
        [sharedData.listOfStudies removeAllObjects];
        [sharedData.seriesDescription removeAllObjects];
        [sharedData.listOfSeries removeAllObjects];
    }
    
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

@end
