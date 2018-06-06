//
//  GeneralMappingWindowController.m
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

#import "GeneralMappingWindowController.h"
//#import <OsiriXAPI/DicomStudy.h>
//#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/BrowserController.h>

#import "OBOCollectedData.h"
#import "OBOSeries.h"
#import "MappingSummaryWindowController.h"

#import "DCM Framework/DCMObject.h"
#import "DCM Framework/DCMAttribute.h"
#import "DCM Framework/DCMAttributeTag.h"

@implementation GeneralMappingWindowController

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    return [sharedData.seriesDescription count];
}

-(NSView* )tableView:(NSTableView*)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    
    NSArray *sequenceNames = [sharedData.seriesDescription allKeys];
    NSString *currentName = [sequenceNames objectAtIndex:row];
    
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"NameCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"NameCell" owner:self]; // will give us back the view that we created in the gui editor; identifier refers to TableCellView
        
        [cellView.textField setStringValue:currentName];
        return cellView;
    }
    // suffix - T1w, bold, ... - will also determine anat, func, fmap
    else if ([identifier isEqualToString:@"SuffixCol"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SuffixCell" owner:self];
        return cellView;
    }
    // run
    else if ([identifier isEqualToString:@"RunCol"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"RunCell" owner:self];
        [cellView.textField setEditable:TRUE];
        return cellView;
    }
    // task
    else if ([identifier isEqualToString:@"TaskCol"]){
        
        NSString *currentSuffix = [[sharedData.seriesDescription objectForKey:currentName] objectForKey:@"suffix"];
        
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"TaskCell" owner:self];

        if ([currentSuffix isEqualToString:@"bold"]) {
            [cellView.textField setEditable:TRUE];
        } else {
            [cellView.textField setEditable:FALSE];
            [cellView.textField setStringValue:@""];
        }
        return cellView;
    }
    // acq
    else if ([identifier isEqualToString:@"AcqCol"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"AcqCell" owner:self];
        [cellView.textField setEditable:TRUE];
        return cellView;
    }
    return nil;

}


-(IBAction)itemTextFieldUpdated:(id)sender{
    NSInteger selectedRow = [self.tableView rowForView:sender];
    NSString *newValue = [sender stringValue];
    NSInteger columnIndex = [self.tableView columnForView:sender];
    
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    NSArray *sequenceNames = [sharedData.seriesDescription allKeys]; // this prob should be class variable
    NSString *currentName = [sequenceNames objectAtIndex:selectedRow];
    
    if (columnIndex == 2){
        // task
        [[sharedData.seriesDescription objectForKey:currentName] setValue:newValue forKey:@"task"];
    }
    else if (columnIndex == 3){
        // run
        [[sharedData.seriesDescription objectForKey:currentName] setValue:newValue forKey:@"run"];
    }
    else if (columnIndex == 4){
        // acq
        [[sharedData.seriesDescription objectForKey:currentName] setValue:newValue forKey:@"acq"];
    }
    
}

- (IBAction)updateSuffix:(id)sender {
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    
    NSInteger selectedRow = [self.tableView rowForView:sender];
    NSString *selectedSuffix = [sender titleOfSelectedItem];  // WOW that worked
    
    NSArray *sequenceNames = [sharedData.seriesDescription allKeys];  // may move to class variable
    NSString *currentName = [sequenceNames objectAtIndex:selectedRow];
    
    NSDictionary * currentItem = [sharedData.seriesDescription objectForKey:currentName];
    [currentItem setValue:selectedSuffix forKey:@"suffix"];
    
    // TODO: set run to empty if non-BOLD was chosen - probably has to be done here

    [self.tableView abortEditing]; // in case editing of a text field was not finished
    [self.tableView reloadData];
}

-(IBAction)saveMapping:(id)sender{
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    [sharedData.listOfSeries removeAllObjects];
    
    [self annotateAllSeries];
    [self createDatasetDescription];
    
    _SummaryWindow = [[MappingSummaryWindowController alloc] initWithWindowNibName:@"MappingSummaryWindow"];
    [_SummaryWindow showWindow:self];
    
}

- (IBAction)showSessionPopover:(id)sender {
    [_sessionPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (IBAction)showDescriptionPopover:(id)sender {
    [_descriptionPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
}


- (IBAction)storeMappingForLater:(id)sender {
    
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    NSData *mappingJson = [NSJSONSerialization dataWithJSONObject:sharedData.seriesDescription options:NSJSONWritingPrettyPrinted error:nil];

    NSSavePanel *saveDlg = [NSSavePanel savePanel];
    [saveDlg setTitle:@"Store mapping for later"];
    [saveDlg setAllowedFileTypes:@[@"json"]];
    
    if ( [saveDlg runModal] == NSOKButton ) {
        [mappingJson writeToURL:[saveDlg URL] atomically:YES];
    }
    
}

- (IBAction)useStoredMapping:(id)sender {
    
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setTitle:@"Select mapping to be used"];
    [openDlg setAllowedFileTypes:@[@"json"]];
    
    if ( [openDlg runModal] == NSOKButton ) {
        NSData *mappingData = [NSData dataWithContentsOfURL:[openDlg URL]];
        sharedData.seriesDescription = [NSJSONSerialization JSONObjectWithData:mappingData
                                                                       options:NSJSONReadingMutableContainers error:nil];
        
        // do the same things as save mapping would do
        [sharedData.listOfSeries removeAllObjects];
        [self annotateAllSeries];
        [self createDatasetDescription];
        _SummaryWindow = [[MappingSummaryWindowController alloc] initWithWindowNibName:@"MappingSummaryWindow"];
        [_SummaryWindow showWindow:self];
    }
}

-(void) annotateAllSeries {
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    NSPredicate *takeOnlyMR = [NSPredicate predicateWithFormat:@"modality = %@", @"MR"];
    NSMutableArray *decoratedFromCurrentStudy = [[NSMutableArray alloc] init];
    NSCountedSet *namesFromCurrentStudy = [[NSCountedSet alloc] init];  // to keep track of repetitions
    NSString *sessionLabel = [[NSString alloc] init];
    NSString *subjectName = [[NSString alloc] init];
    
    for (DicomStudy *currentStudy in sharedData.listOfStudies) {
        [decoratedFromCurrentStudy removeAllObjects];
        [namesFromCurrentStudy removeAllObjects];
        sessionLabel = [self createSessionLabelForStudy:currentStudy];
        subjectName = [self createSubjectNameForStudy:currentStudy];
        
        for (DicomSeries *currentSeries in [[currentStudy imageSeries] filteredArrayUsingPredicate:takeOnlyMR]) {
            OBOSeries *decoratedSeries = [[OBOSeries alloc] initWithSeries:currentSeries params:[sharedData.seriesDescription objectForKey:currentSeries.name]];
            [decoratedSeries setValue:subjectName forKey:@"participant"];
            [decoratedSeries setValue:sessionLabel forKey:@"session"];
            [decoratedFromCurrentStudy addObject:decoratedSeries];
            [namesFromCurrentStudy addObject:currentSeries.name];
        }
        
        // discard BOLD series from current study if they have less volumes than requested minimum
        NSNumber *minimum = [NSNumber numberWithInteger:[[self minimumBoldField] integerValue]];
        for (OBOSeries *decoratedSeries in decoratedFromCurrentStudy){
            if ([[decoratedSeries suffix] isEqualToString:@"bold"]){
                if ([[[decoratedSeries series] numberOfImages] isLessThan:minimum]){
                    [decoratedSeries setDiscard:YES];
                    [decoratedSeries setValue:@"TooShort" forKey:@"comment"];
                }
            }
        }
        
        // handle series which had the same series name: add run numbers (if not given) or discard all but the last
        NSNumber *runNumber;
        for (NSString *seriesName in [namesFromCurrentStudy objectEnumerator]) {
            if ([namesFromCurrentStudy countForObject:seriesName] > 1) { // series with this name has been repeated
                // get (decorated) series matching this name
                NSArray *repeated = [decoratedFromCurrentStudy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"originalName=%@", seriesName]];
                // sort them by acquisition date
                repeated = [repeated sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    NSDate *first = [[(OBOSeries*)obj1 series] date];
                    NSDate *second = [[(OBOSeries*)obj2 series] date];
                    return [first compare:second];
                }];
                
                if ([[[sharedData.seriesDescription objectForKey:seriesName] objectForKey:@"suffix"] isEqualToString:@"(fmap)"]) {
                    // give field maps special treatment (they come in threes, at least from our Siemens)
                    if ([[[sharedData.seriesDescription objectForKey:seriesName] objectForKey:@"run"] length] > 0) {
                        // if run number was specified, assume it's a repeat
                        // discard all but the last three, leave last three for further work
                        for(int i = 0; i < [repeated count] - 3; i++){
                            [[repeated objectAtIndex:i] setDiscard:YES];
                            [[repeated objectAtIndex:i] setValue:@"Discard - repeated" forKey:@"comment"];
                        }
                        repeated = [repeated subarrayWithRange:NSMakeRange([repeated count]-3, 3)];
                    }
                    // handle them by threes
                    for (int i = 0; i < [repeated count]; i=i+3) {
                        NSArray *triplet = [repeated subarrayWithRange:NSMakeRange(i, 3)];
                        [self assignFieldMapSuffixes:triplet];
                        for (OBOSeries *series in triplet){
                            if ([repeated count] == 3) {
                                // run number was given or there was only one run
                                [series setValue:[[sharedData.seriesDescription objectForKey:seriesName] objectForKey:@"run"] forKey:@"run"];
                            }
                            else {
                                [series setValue:[@(i/3 + 1) stringValue] forKey:@"run"];
                            }
                        }
                    }
                }
                else if ([[[sharedData.seriesDescription objectForKey:seriesName] objectForKey:@"run"] length] > 0) {
                    // run number was specified for this study name, assume it's a repeat and discard all but latest
                    for (int i = 0; i < [repeated count] - 1; i++){
                        [[repeated objectAtIndex:i] setDiscard:YES];  // turns out this is the way to set bool flag :/
                        [[repeated objectAtIndex:i] setValue:@"Discard - repeated" forKey:@"comment"];
                    }
                }
                else {
                    // create and insert run numbers
                    runNumber = [NSNumber numberWithInt:1];  // keep it separate from iterator because some runs may have been discarded for different reasons
                    for (int i = 0; i < [repeated count]; i++){
                        if (! [[repeated objectAtIndex:i] discard]) {
                            [[repeated objectAtIndex:i] setValue:[runNumber stringValue] forKey:@"run"];
                            runNumber = [NSNumber numberWithInt:[runNumber intValue]+1];
                        }
                    }
                }
            }
        }
        
        [sharedData.listOfSeries addObjectsFromArray:decoratedFromCurrentStudy];
    }
}

-(void)assignFieldMapSuffixes:(NSArray*)fieldMapTriplet{
    
    DCMAttributeTag *echoTimeTag  = [DCMAttributeTag tagWithTagString:@"0018, 0081"]; // EchoTime
    DCMAttributeTag *imageTypeTag = [DCMAttributeTag tagWithTagString:@"0008, 0008"]; // ImageType
    
    // ORIGINAL, PRIMARY, M, ND - Magnitude
    // ORIGINAL, PRIMARY, P, ND - Phasediff
    
    double shorterTE = 0;
    double longerTE = 0;
    
    double echoTime;
    NSString *imageType;
    
    DCMAttribute *attr;
    
    // first run - get shorter and longer TE
    for (OBOSeries *fieldMapSeries in fieldMapTriplet){
        DicomSeries *series = [fieldMapSeries series];
        NSArray *imagesArray = [[[series paths] allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSString *firstImagePath = [imagesArray objectAtIndex:0];
        DCMObject *dcmObj = [DCMObject objectWithContentsOfFile:firstImagePath decodingPixelData:NO];
        
        attr = [dcmObj attributeForTag:imageTypeTag];
        imageType = [[attr values] objectAtIndex:2];
        
        attr = [dcmObj attributeForTag:echoTimeTag];
        echoTime = [[attr value] doubleValue];
        
        if ([imageType isEqualToString:@"M"]){
            if (echoTime > shorterTE){
                shorterTE = longerTE;
                longerTE = echoTime;
            }
            else {
                shorterTE = echoTime;
            }
        }
    }
    
    // second run - assign suffix
    for (OBOSeries *fieldMapSeries in fieldMapTriplet){
        DicomSeries *series = [fieldMapSeries series];
        NSArray *imagesArray = [[[series paths] allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSString *firstImagePath = [imagesArray objectAtIndex:0];
        DCMObject *dcmObj = [DCMObject objectWithContentsOfFile:firstImagePath decodingPixelData:NO];
        
        attr = [dcmObj attributeForTag:imageTypeTag];
        imageType = [[attr values] objectAtIndex:2];
        
        attr = [dcmObj attributeForTag:echoTimeTag];
        echoTime = [[attr value] doubleValue];
        
        if ([imageType isEqualToString:@"P"]){
            [fieldMapSeries setValue:@"phasediff" forKey:@"suffix"];
            // also store TE in seconds (DICOM values are in ms) to be written in json sidecar
            [[fieldMapSeries fieldmapParams] setObject:[NSNumber numberWithDouble:shorterTE*0.001] forKey:@"EchoTime1"];
            [[fieldMapSeries fieldmapParams] setValue:[NSNumber numberWithDouble:longerTE*0.001] forKey:@"EchoTime2"];
        }
        else if ([imageType isEqualToString:@"M"]){
            if (echoTime == shorterTE){
                [fieldMapSeries setValue:@"magnitude1" forKey:@"suffix"];
            }
            else {
                [fieldMapSeries setValue:@"magnitude2" forKey:@"suffix"];
            }
        }
    }
}

-(NSString*) createSessionLabelForStudy:(DicomStudy *)study {
    
    NSString *pattern = [_studyNameRegexpField stringValue];
    NSString *template = [_sessionLabelTemplateField stringValue];
    NSString *result;
    
    if (!_seriesCheckBoxIsEnabled) {
        // derive from subject name
        NSString *subjectName = study.name;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:subjectName options:0 range:NSMakeRange(0, [subjectName length])];
        
        if (match) {
            result = [regex replacementStringForResult:match inString:subjectName offset:0 template:template];
        } else {
            result = template;
        }
        
    } else {
        // derive from series name
        NSTextCheckingResult *match;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_ses-([a-zA-Z0-9]*)" options:0 error:nil];
        for (DicomSeries *currentSeries in [study imageSeries]) {
            match = [regex firstMatchInString:[currentSeries name] options:0 range:NSMakeRange(0, [[currentSeries name] length])];
            if (match) {
                result = [[currentSeries name] substringWithRange:[match rangeAtIndex:1]];
                break;
            }
        }
        
        if ([result length] == 0) {
            result = @"unknown";
        }
    }
    
    return result;
}

-(NSString*) createSubjectNameForStudy:(DicomStudy *)study {
    NSString *result;
    NSString *subjectName = study.name;
    NSString *pattern = [_studyNameRegexpField stringValue];
    NSString *template = [_subjectLabelTemplateField stringValue];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    NSTextCheckingResult *match = [regex firstMatchInString:subjectName options:0 range:NSMakeRange(0, [subjectName length])];
    
    if (match) {
        result = [regex replacementStringForResult:match inString:subjectName offset:0 template:template];
    } else {
        result = subjectName;
    }
    
    return result;
    
}

-(void) createDatasetDescription {
    OBOCollectedData *sharedData = [OBOCollectedData sharedManager];
    [sharedData.datasetDescription removeAllObjects];

    // Name
    if ([[_datasetNameField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[_datasetNameField stringValue] forKey:@"Name"];
    } else {
        [sharedData.datasetDescription setValue:@"Unnamed experiment" forKey:@"Name"];
    }
    // BIDSVersion
    if ([[_bidsVersionField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[_bidsVersionField stringValue] forKey:@"BIDSVersion"];
    } else {
        [sharedData.datasetDescription setValue:@"1.0.2" forKey:@"BIDSVersion"];
    }
    // License
    if ([[_licenseField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[_licenseField stringValue] forKey:@"License"];
    }
    // Authors
    if ([[_authorsField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[[_authorsField stringValue] componentsSeparatedByString:@";"] forKey:@"Authors"];
    }
    // Acknowledgements
    if ([[_acknowledgementsField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[_acknowledgementsField stringValue] forKey:@"Acknowledgements"];
    }
    // HowToAcknowledge
    if ([[_howToAcknowledgeField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[_howToAcknowledgeField stringValue] forKey:@"HowToAcknowledge"];
    }
    // Funding
    if ([[_fundingField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[_fundingField stringValue] forKey:@"Funding"];
    }
    // ReferencesAndLinks
    if ([[_referencesAndLinksField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[[_referencesAndLinksField stringValue] componentsSeparatedByString:@";"] forKey:@"ReferencesAndLinks"];
    }
    // DatasetDOI
    if ([[_datasetDoiField stringValue] length] > 0) {
        [sharedData.datasetDescription setValue:[_datasetDoiField stringValue] forKey:@"DatasetDOI"];
    }
    
    // write or not
    if ([_noDescriptionCheckBox state] == NSOnState) {
        [sharedData setWriteDatasetDescription:NO];
    } else {
        [sharedData setWriteDatasetDescription:YES];
    }
}

@end
