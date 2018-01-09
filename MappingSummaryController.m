//
//  MappingSummaryController.m
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

#import "MappingSummaryController.h"
#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>

#import "OBOCollectedData.h"
#import "OBOSeries.h"

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
    else if ([identifier isEqualToString:@"CommentCol"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"CommentCell" owner:self];
        [cellView.textField setStringValue:[currentSeries comment]];
        return cellView;
    }
    else if ([identifier isEqualToString:@"BidsCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"BidsCell" owner:self];
        [cellView.textField setStringValue:[currentSeries getBidsPath]];
        return cellView;
    }
    
    return nil;
}

@end
