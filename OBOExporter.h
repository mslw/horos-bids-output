//
//  OBOExporter.h
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 14.12.2017.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/DicomSeries.h>

@interface OBOExporter : NSObject

+(void) exportSeries:(DicomSeries*) series;

@end
