//
//  OBOExporter.h
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

#import "OBOSeries.h"

@interface OBOExporter : NSObject

+(BOOL) exportSeries:(OBOSeries*) series usingConverterAt:(NSString*) converterPath toFolder:(NSString*) bidsRoot withCompression:(BOOL)answer withScansFile:(BOOL)createScans error:(NSError**)outError;

+(void) addScansEntryDescribingSeries:(OBOSeries*) series withBidsRoot:(NSString*) bidsRoot;

+(BOOL) createTemporaryDicomDirectory;
/** Create a temporary folder for dicom files (symlinks) if it didn't exist before
 *
 * The folder is created in ~/HorosBidsOutput
 *
 * @return YES if the directory was created, NO if it existed before
 */

+(void) removeTemporaryDicomDirectory;
/** Remove the temporary dicom folder
 */

@end
