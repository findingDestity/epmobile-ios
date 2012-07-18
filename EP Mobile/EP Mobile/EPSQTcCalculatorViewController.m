//
//  EPSQTcCalculatorViewController.m
//  EP Mobile
//
//  Created by David Mann on 7/16/12.
//  Copyright (c) 2012 EP Studios. All rights reserved.
//

#import "EPSQTcCalculatorViewController.h"

#define BAZETT 0
#define FRIDERICIA 1
#define SAGIE 2
#define HODGES 3

@interface EPSQTcCalculatorViewController ()

@end

@implementation EPSQTcCalculatorViewController
{
    BOOL inputIsRate;
}
@synthesize formulaPicker;
@synthesize formulaData;
@synthesize inputField;
@synthesize qtField;
@synthesize resultLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *array = [[NSArray alloc] initWithObjects:@"Bazett", @"Fridericia", @"Sagie", @"Hodges", nil];
    self.formulaData = array;
    inputIsRate = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setInputField:nil];
    [self setQtField:nil];
    [self setResultLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.formulaPicker = nil;
    self.formulaData = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender {
    [self.inputField resignFirstResponder];
    [self.qtField resignFirstResponder];
}

- (IBAction)calculateButtonPressed:(id)sender {
    NSString *input = self.inputField.text;
    double inputNumber = [input doubleValue];
    NSLog(@"The value of inputNumber is %f", inputNumber);
    NSString *qt = self.qtField.text;
    double qtNumber = [qt doubleValue];
    NSLog(@"The value of qtNumber is %f", qtNumber);
    if (inputNumber == 0 || qtNumber == 0) {
        self.resultLabel.text = @"INVALID ENTRY";
        return;
    }
    if (inputIsRate) {
        inputNumber = 60000.0 / inputNumber;
        NSLog(@"Converted to RR interval in msec is %f", inputNumber);
    }
    double intervalSec = inputNumber / 1000.0;
    double qtSec = qtNumber / 1000.0;
    NSInteger row = [formulaPicker selectedRowInComponent:0];
    NSString *formula = [formulaData objectAtIndex:row];
    NSLog(@"Formula is %@", formula);
    NSLog(@"Row is %d", row);
    double qtc = [self qtcFromQt:qtSec AndInterval:intervalSec UsingFormula:row];
    NSLog(@"QTc = %f", qtc);
    if (qtc == 0.0)
        self.resultLabel.text = @"INVALID ENTRY";
    else {
        // convert back to msec, no decimals
        int qtcMsec = (int) round(qtc * 1000);
        self.resultLabel.text = [[NSString alloc] initWithFormat:@"QTc is %i msec (%@ formula)", qtcMsec, formula];
    }
    //self.resultLabel.text = resultString;
}

- (IBAction)clearButtonPressed:(id)sender {
    self.inputField.text = nil;
    self.qtField.text = nil;
}

- (double)qtcFromQt:(double)qt AndInterval:(double)interval UsingFormula:(NSInteger)formula {
    if (interval == 0)
        return 0;   // no divide by zero
    double result;
    switch (formula) {
        case BAZETT:
            result = qt / sqrt(interval);
            break;
        case FRIDERICIA:
            result = qt / cbrt(interval);
            break;
        case SAGIE:
            result = qt + 0.154 * (1.0 - interval);
            break;
        case HODGES:
            // change interval back into secs
            interval = (60000 / (interval * 1000));
            result = qt + ((1.75 * (interval - 60) / 1000));
            break;
        default:
            result = 0;
            break;
    }
    return result;
}

- (IBAction)toggleInputType:(id)sender {
    self.inputField.text = nil;
    self.resultLabel.text = nil;
    // 0 == Rate
    if ((inputIsRate = [sender selectedSegmentIndex] == 0)) {
        self.inputField.placeholder = @"Heart Rate (bpm)";
    }
    else {
        self.inputField.placeholder = @"RR Interval (msec)";
    }
}


#pragma mark - Formula Picker Data Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [formulaData count];
}


# pragma mark - Formula Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [formulaData objectAtIndex:row];
}
@end
