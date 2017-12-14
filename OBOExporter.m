//
//  OBOExporter.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 14.12.2017.
//

#import "OBOExporter.h"

@implementation OBOExporter

+(void)exportSeries:(DicomSeries*) series{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager createDirectoryAtPath:@"/Users/michal/Documents/test_horos/dicom" withIntermediateDirectories:YES attributes:nil error:nil]; // yolo
    
    for (NSString *path in [[series paths] objectEnumerator]) {
        [fileManager copyItemAtPath:path toPath:[NSString stringWithFormat:@"%@/%@", @"/Users/michal/Documents/test_horos/dicom", [path lastPathComponent]] error:NULL];
    }
    
    [fileManager createDirectoryAtPath:@"/Users/michal/Documents/test_horos/nifti" withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSTask *conversionTask = [[NSTask alloc] init];
    [conversionTask setLaunchPath:@"/Users/michal/tools/dcm2niix_19-Aug-2017_mac/dcm2niix"];
    //    NSArray *args = [NSArray arrayWithObjects:@"-o", @"/Users/michal/Documents/test_horos/nifti", @"/Users/michal/Documents/test_horos/dicom", nil];  // doesn't work with these arguments - must figure out
    NSArray *args = [NSArray arrayWithObject:@"/Users/michal/Documents/test_horos/dicom"];
    
    [conversionTask setArguments:args];
    
    [conversionTask launch];
    [conversionTask waitUntilExit];  // also see docs with example of getting status
    
    //    alternatively, can use path with components
    //    NSArray *components = [NSArray arrayWithObjects:@"foo", @"bar", @"baz.nii", nil];
    //    NSString *path = [NSString pathWithComponents:components];
    
}

@end
