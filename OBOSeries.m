//
//  OBOSeries.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 04.09.2017.
//
//

#import "OBOSeries.h"

@interface OBOSeries()

-(NSString*) createSubjectLabel;

@end

@implementation OBOSeries

- (instancetype)init {
    if (self = [super init]) {
        _series = nil;
        _originalName = @"";
        _participant = @"";
        _suffix = @"";
        _session = @"";
        _task = @"";
        _run = @"";
        
        _discard = NO;
        _comment = @"";
    }
    return self;
}

- (instancetype)initWithSeries:(DicomSeries *)originalSeries {
    if (self = [super init]) {
        _series = originalSeries;
        _originalName = [originalSeries name];
        _participant = @""; // read from original series
        _suffix = @"";
        _session = @"";
        _task = @"";
        _run = @"";
        
        _discard = NO;
        _comment = @"";
    }
    return self;
}

-(instancetype)initWithSeries:(DicomSeries *)originalSeries params:(NSDictionary *)params {
    if (self = [super init]) {
        _series = originalSeries;
        _originalName = [originalSeries name];
        _participant = @""; // read from original series
        _suffix = [params valueForKey:@"suffix"];
        _session = [params valueForKey:@"session"];
        _task = [params valueForKey:@"task"];
        _run = [params valueForKey:@"run"];
        
        _discard = NO;
        _comment = @"";
    }
    return self;
}

-(NSString*)getBidsPath {
    NSArray *anatSuffixList = @[@"T1w", @"T2w", @"T1rho", @"T1map", @"T2map", @"T2star", @"FLAIR", @"FLASH",
                                @"PD", @"PDmap", @"PDT2", @"inplaneT1", @"inplaneT2", @"angio", @"defacemask",
                                @"SWImagandphase"];
    NSMutableString *path = [[NSMutableString alloc] init];
    if ([self discard]){
        return path;
    }
    else if ([self.suffix isEqualToString:@"bold"]){
        
        [path appendString:@"func/"];
        if ([self.session length] > 0){
            [path appendString:@"ses-"];
            [path appendString:self.session];
            [path appendString:@"/"];
        }
        
        // subject
        [path appendString:@"sub-"];
        [path appendString: [self createSubjectLabel]];
        
        // session (optional)
        if ([self.session length] > 0){
            [path appendString:@"_ses-"];
            [path appendString:self.session];
        }
        
        // task
        [path appendString:@"_task-"];
        [path appendString:self.task];
        
        // ADD acq (optional) - not yet in nib
        // ADD rec (optional) - not yet in nib
        
        // run (optional)
        if ([self.run length] > 0){
            [path appendString:@"_run-"];
            [path appendString:self.run];
        }
        
        // ADD echo (optional) - not yet in nib
        
        [path appendString:@"_bold"];
    }
    else if ([anatSuffixList containsObject:self.suffix]){
        
        [path appendString:@"anat/"];
        if ([self.session length] > 0){
            [path appendString:@"ses-"];
            [path appendString:self.session];
            [path appendString:@"/"];
        }
        
        //subject
        [path appendString:@"sub-"];
        [path appendString:[self createSubjectLabel]];
        
        // session (optional)
        if ([self.session length] > 0){
            [path appendString:@"_ses-"];
            [path appendString:self.session];
        }
        
        // ADD acq (optional) - not yet in nib
        // ADD ce (optional) - not yet in nib
        // ADD rec (optional) - not yet in nib
        
        // run (optional)
        if ([self.run length] > 0){
            [path appendString:@"_run-"];
            [path appendString:self.run];
        }
        // ADD mod (optional) - not yet in nib
        
        // modality label
        [path appendString:@"_"];
        [path appendString:self.suffix];
    }
    
    return path;
}

-(NSString*)createSubjectLabel{
    // take participant and remove non-alphanumeric character
    NSCharacterSet *nonAlphanumericSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSArray *components = [self.participant componentsSeparatedByCharactersInSet:nonAlphanumericSet];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    return [components componentsJoinedByString:@""];
}

@end
