//
//  OBOExporter.m
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 14.12.2017.
//

#import "OBOExporter.h"

@implementation OBOExporter

+(void)exportSeries:(OBOSeries*) series usingConverterAt:(NSString *)converterPath toFolder:(NSString *)bidsRoot withCompression:(BOOL)answer {
    
    NSString *bidsPath = [series getBidsPath];
    NSString *bidsFolder = [bidsPath stringByDeletingLastPathComponent];  // deletes separator as well
    NSString *bidsFileName = [bidsPath lastPathComponent];
    
    // bidsFolder starts with sub-label/... Trailing separator is removed.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // create bids-like directory within folder called dicom
    [fileManager createDirectoryAtPath:[NSString pathWithComponents:@[bidsRoot, @"dicom", bidsPath]] withIntermediateDirectories:YES attributes:nil error:nil];
    
    // copy dicom files there
    for (NSString *path in [[[series series] paths] objectEnumerator]) {
        [fileManager copyItemAtPath:path toPath:[NSString pathWithComponents:@[bidsRoot, @"dicom", bidsPath, [path lastPathComponent]]] error:nil];
        // here I am using bids path (since it has no extension) as dicom folder name
    }
    
    // create actual bids directory within destinationFolder
    NSString *outputDirectory = [NSString pathWithComponents:@[bidsRoot, bidsFolder]];
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
    
    [conversionTask setLaunchPath:converterPath];
    
    NSArray *args = [NSArray arrayWithObjects:
                     @"-o", outputDirectory,
                     @"-f", bidsFileName,
                     @"-z", compression,
                     [NSString pathWithComponents:@[bidsRoot, @"dicom", bidsPath]],
                     nil];
    
    [conversionTask setArguments:args];
    
    [conversionTask launch];
    [conversionTask waitUntilExit];  // also see docs with example of getting status
    
}

@end
