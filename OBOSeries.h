//
//  OBOSeries.h
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 04.09.2017.
//
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/DicomSeries.h>

@interface OBOSeries : NSObject

@property (nonatomic) DicomSeries *series;
@property (nonatomic) NSString *participant;
@property (nonatomic) NSString *suffix;
@property (nonatomic) NSString *session;
@property (nonatomic) NSString *task;
@property (nonatomic) NSString * run;

-(NSString*) getBidsPath;

@end
