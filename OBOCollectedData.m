//
//  OBOCollectedData.m
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

#import "OBOCollectedData.h"

@implementation OBOCollectedData

@synthesize listOfStudies;
@synthesize seriesDescription;
@synthesize listOfSeries;
@synthesize datasetName;

+(id)sharedManager{
    static OBOCollectedData *sharedCollectedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCollectedData = [[self alloc] init];
    });
    return sharedCollectedData;
}

-(id) init{
    if (self = [super init]) {
        listOfStudies = [[NSMutableArray alloc] init];
        seriesDescription = [NSMutableDictionary dictionary];
        listOfSeries = [[NSMutableArray alloc] init];
        
        datasetName = [[NSString alloc] init];
    }
    return self;
}

@end

// should be able to reference it from anywhere this way:
// OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
