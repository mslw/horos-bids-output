//
//  OBOExporter.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 14.12.2017.
//

#import "OBOExporter.h"

@implementation OBOExporter

+(void)exportSeries:(OBOSeries*) series useCompression:(BOOL)answer{
    
    NSString *bidsPath = [series getBidsPath];
    NSString *bidsFolder = [bidsPath stringByDeletingLastPathComponent];  // deletes separator as well
    NSString *bidsFileName = [bidsPath lastPathComponent];
    
    // bidsFolder starts with sub-label/... Trailing separator is removed.
    
    NSString *destinationFolder = @"/Users/michal/Documents/test_horos";  // TODO get it
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // create bids-like directory within folder called dicom
    [fileManager createDirectoryAtPath:[NSString pathWithComponents:@[destinationFolder, @"dicom", bidsPath]] withIntermediateDirectories:YES attributes:nil error:nil];
    
    // copy dicom files there
    for (NSString *path in [[[series series] paths] objectEnumerator]) {
        [fileManager copyItemAtPath:path toPath:[NSString pathWithComponents:@[destinationFolder, @"dicom", bidsPath, [path lastPathComponent]]] error:nil];
        // here I am using bids path (since it has no extension) as dicom folder name
    }
    
    // create actual bids directory within destinationFolder
    NSString *outputDirectory = [NSString pathWithComponents:@[destinationFolder, bidsFolder]];
    [fileManager createDirectoryAtPath:outputDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    // append slash - probably not necessary
    // outputDirectory = [outputDirectory stringByAppendingString:@"/"];
    
    NSString *compression;
    if (answer){
        compression = @"y";  // y - pigz, i - internal
    }
    else {
        compression = @"n";
    }
    
    // convert DICOM into that directory
    NSTask *conversionTask = [[NSTask alloc] init];
    
    // TODO: let choose path to dcm2niix
    // [conversionTask setLaunchPath:@"/Users/michal/tools/dcm2niix_19-Aug-2017_mac/dcm2niix"];  // iMac
    [conversionTask setLaunchPath:@"/Users/michal/tools/MRIcroGL/dcm2niix"];  // MacBook
    
    NSArray *args = [NSArray arrayWithObjects:
                     @"-o", outputDirectory,
                     @"-f", bidsFileName,
                     @"-z", compression,
                     [NSString pathWithComponents:@[destinationFolder, @"dicom", bidsPath]],
                     nil];
    // todo: allow toggling conversion, for now using -z n (dcm2niix default)
    
    [conversionTask setArguments:args];
    
    [conversionTask launch];
    [conversionTask waitUntilExit];  // also see docs with example of getting status
    
    /*
     // hardcoded paths that were tested (to be removed)
     NSArray *args = [NSArray arrayWithObject:@"/Users/michal/Documents/test_horos/dicom"];  // this works
     
     NSArray *args = [NSArray arrayWithObjects:@"-o", @"/Users/michal/Documents/test_horos/nifti/", @"/Users/michal/Documents/test_horos/dicom", nil];  // now it works as well :0
     
     NSArray *args = [NSArray arrayWithObjects:@"-o", @"/Users/michal/Documents/test_horos/nifti/",
     @"-f", @"sub-test_task-rest_bold",
     @"/Users/michal/Documents/test_horos/dicom",
     nil];  // yup, that worked
     // You can use the sh -c trick to feed a shell a command and let it parse it
     // launchPath: /bin/sh, arguments @"-c", @"all the commands"
     */
    
}

@end
