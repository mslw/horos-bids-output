//
//  OBOSeries.m
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

#import "OBOSeries.h"

@interface OBOSeries()

-(NSString*) createSubjectLabel;
-(NSString*) createTaskLabel;

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
        _acq = @"";
        _run = @"";
        
        _discard = NO;
        _comment = @"";
        
        _fieldmapParams = [[NSMutableDictionary alloc] init];
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
        _acq = @"";
        _run = @"";
        
        _discard = NO;
        _comment = @"";
        
        _fieldmapParams = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype)initWithSeries:(DicomSeries *)originalSeries params:(NSDictionary *)params {
    if (self = [super init]) {
        _series = originalSeries;
        _originalName = [originalSeries name];
        _participant = @""; // read from original series
        _suffix = [params valueForKey:@"suffix"];
        _session = @""; // set after initialisation
        _task = [params valueForKey:@"task"];
        _acq = [params valueForKey:@"acq"];
        _run = [params valueForKey:@"run"];
        
        _discard = NO;
        _comment = @"";
        
        _fieldmapParams = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSString*)getBidsPath {
    NSArray *anatSuffixList = @[@"T1w", @"T2w", @"T1rho", @"T1map", @"T2map", @"T2star", @"FLAIR", @"FLASH",
                                @"PD", @"PDmap", @"PDT2", @"inplaneT1", @"inplaneT2", @"angio", @"defacemask",
                                @"SWImagandphase"];
    NSArray *fmapSuffixList = @[@"phasediff", @"magnitude1", @"magnitude2"];
    NSMutableString *path = [[NSMutableString alloc] init];
    if ([self discard]){
        return path;
    }
    else if ([self.suffix isEqualToString:@"bold"]){
        
        // folders
        [path appendString:@"sub-"];
        [path appendString: [self createSubjectLabel]];
        [path appendString:@"/"];
        
        if ([self.session length] > 0){
            [path appendString:@"ses-"];
            [path appendString:self.session];
            [path appendString:@"/"];
        }
        
        [path appendString:@"func/"];
        
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
        [path appendString:[self createTaskLabel]];
        
        // acq (optional)
        if ([self.acq length] > 0){
            [path appendString:@"_acq-"];
            [path appendString:self.acq];
        }
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
        
        // folders
        [path appendString:@"sub-"];
        [path appendString: [self createSubjectLabel]];
        [path appendString:@"/"];
        
        if ([self.session length] > 0){
            [path appendString:@"ses-"];
            [path appendString:self.session];
            [path appendString:@"/"];
        }
        
        [path appendString:@"anat/"];
        
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
    else if ([fmapSuffixList containsObject:self.suffix]){
        
        // folders
        [path appendString:@"sub-"];
        [path appendString: [self createSubjectLabel]];
        [path appendString:@"/"];
        
        if ([self.session length] > 0){
            [path appendString:@"ses-"];
            [path appendString:self.session];
            [path appendString:@"/"];
        }
        
        [path appendString:@"fmap/"];
        
        //subject
        [path appendString:@"sub-"];
        [path appendString:[self createSubjectLabel]];
        
        // session (optional)
        if ([self.session length] > 0){
            [path appendString:@"_ses-"];
            [path appendString:self.session];
        }
        
        // ADD acq (optional) - not yet in nib
        
        // run (optional)
        if ([self.run length] > 0){
            [path appendString:@"_run-"];
            [path appendString:self.run];
        }
        
        [path appendString:@"_"];
        [path appendString:self.suffix];
    }
    
    return path;
}

-(NSString*) createSubjectLabel {
    // take participant and remove non-alphanumeric character
    NSCharacterSet *nonAlphanumericSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSArray *components = [self.participant componentsSeparatedByCharactersInSet:nonAlphanumericSet];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    return [components componentsJoinedByString:@""];
}

-(NSString*) createTaskLabel {
    NSCharacterSet *nonAlphanumericSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSArray *components = [self.task componentsSeparatedByCharactersInSet:nonAlphanumericSet];
    return [components componentsJoinedByString:@""];
}

@end
