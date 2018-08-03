//
//  MappingSummaryWindowController.h
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

#import <Cocoa/Cocoa.h>

@interface MappingSummaryWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *converterTextField;
@property (weak) IBOutlet NSTextField *bidsRootTextField;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSButton *gzCheckBox;
@property (weak) IBOutlet NSButton *scansCheckBox;

- (IBAction)changeConverterPath:(id)sender;
- (IBAction)changeBidsRoot:(id)sender;
- (IBAction)exportToBids:(id)sender;

-(void)saveSummary;
-(void)saveErrors: (NSMutableArray*) errorList;

@end
