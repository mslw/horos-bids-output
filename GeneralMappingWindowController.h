//
//  GeneralMappingWindowController.h
//  OsirixBidsOutput
//
//  Created by Michał Szczepanik on 30.08.2017.
//
//

#import <Foundation/Foundation.h>

@interface GeneralMappingWindowController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSWindowController *SummaryWindow;

- (IBAction)updateSuffix:(id)sender;
- (IBAction)itemTextFieldUpdated:(id)sender;
- (IBAction)saveMapping:(id)sender;

- (void) annotateAllSeries;

//@property(nonatomic) NSMutableArray *sequenceDescriptions;  // not sure if I want it - perhaps just run with the global one

@end
