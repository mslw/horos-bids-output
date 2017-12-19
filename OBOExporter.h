//
//  OBOExporter.h
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 14.12.2017.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/DicomSeries.h>

#import "OBOSeries.h"

@interface OBOExporter : NSObject

+(void) exportSeries:(OBOSeries*) series useCompression:(BOOL*)answer;

@end
