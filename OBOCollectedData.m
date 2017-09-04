//
//  OBOCollectedData.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 31.08.2017.
//
//

#import "OBOCollectedData.h"

@implementation OBOCollectedData

@synthesize listOfStudies;
@synthesize seriesDescription;
@synthesize listOfSeries;

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
    }
    return self;
}

@end

// should be able to reference it from anywhere this way:
// OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
