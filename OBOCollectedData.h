//
//  OBOCollectedData.h
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 31.08.2017.
//
//

#import <Foundation/Foundation.h>

@interface OBOCollectedData : NSObject

@property (nonatomic, retain) NSMutableArray *listOfStudies;
@property (nonatomic, retain) NSMutableDictionary *seriesDescription;
@property (nonatomic, retain) NSMutableArray *listOfSeries;

@property (nonatomic, retain) NSString *datasetName;

+(id) sharedManager;

@end
