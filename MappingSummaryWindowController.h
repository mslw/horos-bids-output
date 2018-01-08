//
//  MappingSummaryWindowController.h
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 08.01.2018.
//

#import <Cocoa/Cocoa.h>

@interface MappingSummaryWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *converterTextField;
@property (weak) IBOutlet NSTextField *bidsRootTextField;

- (IBAction)changeConverterPath:(id)sender;
- (IBAction)changeBidsRoot:(id)sender;

@end
