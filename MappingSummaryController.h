//
//  MappingSummaryController.h
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 12.12.2017.
//

#import <Foundation/Foundation.h>

@interface MappingSummaryController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSProgressIndicator *spinner;

- (IBAction)exportToBids:(id)sender;

@end
