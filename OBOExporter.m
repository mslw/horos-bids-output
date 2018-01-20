//
//  OBOExporter.m
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

#import "OBOExporter.h"

@implementation OBOExporter

+(void)exportSeries:(OBOSeries*) series usingConverterAt:(NSString *)converterPath toFolder:(NSString *)bidsRoot withCompression:(BOOL)answer {
    
    NSString *bidsPath = [series getBidsPath];
    NSString *bidsFolder = [bidsPath stringByDeletingLastPathComponent];  // deletes separator as well
    NSString *bidsFileName = [bidsPath lastPathComponent];
    
    // bidsFolder starts with sub-label/... Trailing separator is removed.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // create bids-like directory within folder called dicom
    [fileManager createDirectoryAtPath:[NSString pathWithComponents:@[bidsRoot, @".dicom", bidsPath]] withIntermediateDirectories:YES attributes:nil error:nil];
    
    // copy dicom files there
    for (NSString *path in [[[series series] paths] objectEnumerator]) {
        [fileManager copyItemAtPath:path toPath:[NSString pathWithComponents:@[bidsRoot, @".dicom", bidsPath, [path lastPathComponent]]] error:nil];
        // here I am using bids path (since it has no extension) as dicom folder name
    }
    
    // create actual bids directory within destinationFolder
    NSString *outputDirectory = [NSString pathWithComponents:@[bidsRoot, bidsFolder]];
    [fileManager createDirectoryAtPath:outputDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *compression;
    NSString *ext;  // used for fieldmap file name manipulations, not by dcm2niix
    if (answer){
        compression = @"y";  // y - pigz, i - internal
        ext = @"nii.gz";
    }
    else {
        compression = @"n";
        ext = @"nii";
    }
    
    // convert DICOM into that directory
    NSTask *conversionTask = [[NSTask alloc] init];
    
    [conversionTask setLaunchPath:converterPath];
    
    NSArray *args = [NSArray arrayWithObjects:
                     @"-o", outputDirectory,
                     @"-f", bidsFileName,
                     @"-z", compression,
                     [NSString pathWithComponents:@[bidsRoot, @".dicom", bidsPath]],
                     nil];
    
    [conversionTask setArguments:args];
    
    [conversionTask launch];
    [conversionTask waitUntilExit];  // also see docs with example of getting status
    
    // fix path for field maps
    // dcm2niix always appends _e2 to the series with longer echo
    // we accounted for that with BIDS "_magnitude2" suffix, so we have to remove _e2
    NSString *correctPath;
    NSString *incorrectPath;
    NSString *incorrectSuffix;
    if ([series.suffix isEqualToString:@"phasediff"] || [series.suffix isEqualToString:@"magnitude1"] || [series.suffix isEqualToString:@"magnitude2"]) {
        
        incorrectSuffix = [series.suffix stringByAppendingString:@"_e2"];
        
        for (NSString *extension in @[ext, @"json"]) {
            correctPath = [[NSString pathWithComponents:@[outputDirectory, bidsFileName]] stringByAppendingPathExtension:extension];
            incorrectPath = [correctPath stringByReplacingOccurrencesOfString:series.suffix withString:incorrectSuffix];
            
            if ([fileManager fileExistsAtPath:incorrectPath]) {
                [fileManager moveItemAtPath:incorrectPath toPath:correctPath error:nil];
            }
        }
        
    }
    
    // remove the dicoms copied for this series to avoid bloating disk usage for large studies
    [fileManager removeItemAtPath:[NSString pathWithComponents:@[bidsRoot, @".dicom", bidsPath]] error:nil];
    
}

+(BOOL) createTemporaryDicomDirectoryAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dicomPath = [NSString pathWithComponents:@[path, @".dicom"]];
    
    if ([fileManager fileExistsAtPath:dicomPath]) {
        return NO;
    } else {
        return [fileManager createDirectoryAtPath:dicomPath
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
        // createDirectoryAtPath should return YES if the directory was created and NO if an error occurred
    }
}

+(void) removeTemporaryDicomDirectoryAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dicomPath = [NSString pathWithComponents:@[path, @".dicom"]];
    [fileManager removeItemAtPath:dicomPath error:nil];
}

@end
