//
//  OBOSeries.h
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

#import <Foundation/Foundation.h>
#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/DicomStudy.h>

@interface OBOSeries : NSObject

@property (nonatomic) DicomSeries *series;
@property (nonatomic) NSString *originalName;
@property (nonatomic) NSString *originalSubjectName;

@property (nonatomic) NSString *participant;
@property (nonatomic) NSString *suffix;
@property (nonatomic) NSString *session;
@property (nonatomic) NSString *task;
@property (nonatomic) NSString *acq;
@property (nonatomic) NSString *dir;
@property (nonatomic) NSString *run;

@property (nonatomic, assign) BOOL discard;
@property (nonatomic) NSString *comment;

@property (nonatomic) NSMutableDictionary *fieldmapParams;

-(instancetype)initWithSeries:(DicomSeries *) originalSeries;
-(instancetype)initWithSeries:(DicomSeries *) originalSeries params:(NSDictionary *)params;

-(NSString*) getBidsPath;

@end
