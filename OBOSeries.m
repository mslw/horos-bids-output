//
//  OBOSeries.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 04.09.2017.
//
//

#import "OBOSeries.h"

@implementation OBOSeries

- (instancetype)init {
    if (self = [super init]) {
        _series = nil;
        _participant = @"";
        _suffix = @"";
        _session = @"";
        _task = @"";
        _run = @"";
    }
    return self;
}

- (instancetype)initWithSeries:(DicomSeries *)originalSeries {
    if (self = [super init]) {
        _series = originalSeries;
        _participant = @""; // read from original series
        _suffix = @"";
        _session = @"";
        _task = @"";
        _run = @"";
    }
    return self;
}

-(instancetype)initWithSeries:(DicomSeries *)originalSeries params:(NSDictionary *)params {
    if (self = [super init]) {
        _series = originalSeries;
        _participant = @""; // read from original series
        _suffix = [params valueForKey:@"suffix"];
        _session = [params valueForKey:@"session"];
        _task = [params valueForKey:@"task"];
        _run = [params valueForKey:@"run"];
    }
    return self;
}

-(NSString*)getBidsPath {
    NSArray *anatSuffixList = @[@"T1w", @"T2w", @"T1rho", @"T1map", @"T2map", @"T2star", @"FLAIR", @"FLASH",
                                @"PD", @"PDmap", @"PDT2", @"inplaneT1", @"inplaneT2", @"angio", @"defacemask",
                                @"SWImagandphase"];
    NSMutableString *path = [[NSMutableString alloc] init];
    if ([self.suffix isEqualToString:@"bold"]){
        [path appendString:@"func/"];
        [path appendString:@"sub-"];
        [path appendString:@"<label>"]; // work out label
        // ADD ses
        [path appendString:@"_task-"];
        [path appendString:self.task];
        // ADD acq
        // ADD rec
        // ADD run
        // ADD echo
        [path appendString:@"_bold"];
    }
    else if ([anatSuffixList containsObject:self.suffix]){
        [path appendString:@"anat/"];
        [path appendString:@"sub-"];
        [path appendString:@"<label>"]; // work out label
        // ADD ses
        // ADD acq
        // ADD ce
        // ADD rec
        // ADD run
        // ADD mod
        [path appendString:@"_"];
        [path appendString:self.suffix];
    }
    
    return path;
}

@end
