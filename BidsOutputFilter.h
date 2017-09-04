//
//  PluginTemplateFilter.h
//  PluginTemplate
//
//  Copyright (c) CURRENT_YEAR YOUR_NAME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>

@interface BidsOutputFilter : PluginFilter {

}

- (long) filterImage:(NSString*) menuName;
- (void) annotateAllSeries;

@end
