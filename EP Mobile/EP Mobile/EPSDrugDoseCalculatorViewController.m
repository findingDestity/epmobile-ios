//
//  EPSDrugDoseCalculatorViewController.m
//  EP Mobile
//
//  Created by David Mann on 7/14/12.
//  Copyright (c) 2012 EP Studios. All rights reserved.
//

#import "EPSDrugDoseCalculatorViewController.h"

#define DABIGATRAN @"Dabigatran"
#define DOFETILIDE @"Dofetilide"
#define RIVAROXABAN @"Rivaroxaban"
#define SOTALOL @"Sotalol"
// for the future
#define APIXABAN @"Apixaban"

#define DO_NOT_USE @"DO NOT USE! "

@interface EPSDrugDoseCalculatorViewController ()

@end

@implementation EPSDrugDoseCalculatorViewController
{
    BOOL weightIsPounds;
}
@synthesize sexSegmentedControl;
@synthesize ageField;
@synthesize weightField;
@synthesize weightUnitsSegmentedControl;
@synthesize creatinineField;
@synthesize resultLabel;
@synthesize drug;



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
	// Do any additional setup after loading the view.
    self.navigationItem.title = drug;
    weightIsPounds = YES;
    
}

- (void)viewDidUnload
{

    [self setSexSegmentedControl:nil];
    [self setAgeField:nil];
    [self setWeightField:nil];
    [self setWeightUnitsSegmentedControl:nil];
    [self setCreatinineField:nil];
    [self setResultLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)toggleWeightUnits:(id)sender {
    //self.weightField.text  = nil;  this is bad if people enter weight first and then units, so it's gone.
    self.resultLabel.text = nil;
    if ((weightIsPounds = [sender selectedSegmentIndex] == 0)) 
        self.weightField.placeholder = @"Weight (lb)";
        
    else 
        self.weightField.placeholder = @"Weight (kg)";
}

- (IBAction)toggleSex:(id)sender {
    self.resultLabel.text = nil;
}


- (IBAction)calculate:(id)sender {
    NSString *weightText = self.weightField.text;
    double weight = [weightText doubleValue];
    NSLog(@"Weight is %f", weight);
    NSString *ageText = self.ageField.text;
    double age = [ageText doubleValue];
    NSLog(@"Age is %f", age);
    NSString *creatinineText = self.creatinineField.text;
    double creatinine = [creatinineText doubleValue];
    NSLog(@"Creatinine is %f", creatinine);
    // make sure all entries ok
    if (weight == 0.0 || age == 0.0 || creatinine == 0.0) {
        self.resultLabel.text = @"INVALID ENTRY";
        return;
    }
    if (weightIsPounds) {
        NSLog(@"Weight is in pounds (%f lb)", weight);
        weight = [self lbsToKgs:weight];
        NSLog(@"Converted weight in kgs is %f", weight);
    }
    BOOL isMale = ([sexSegmentedControl selectedSegmentIndex] == 0);
    int cc = [self creatinineClearanceForAge:age isMale:isMale forWeightInKgs:weight forCreatinine:creatinine]; 

    NSString *result = [[NSString alloc] init];
    result = [result stringByAppendingString:[self getDose:cc]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@"\nCreatinine Clearance = %i ml/min.", cc]];
    self.resultLabel.text = result;
    if ([self hasWarning:cc]) {
        NSString *alertTitle = @"Warning";
        NSString *details = result;
        details = [details stringByAppendingString:@"\n"];
        details = [details stringByAppendingString:[self getDetails:cc]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:details delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)clear:(id)sender {
    self.ageField.text = nil;
    self.weightField.text = nil;
    self.creatinineField.text = nil;
    self.resultLabel.text = nil;
}

- (int)creatinineClearanceForAge:(double)age isMale:(BOOL)isMale forWeightInKgs:(double)weight forCreatinine:(double)creatinine {
    double crClr = 0.0;
    crClr = (140 - age) * weight;
    crClr = crClr / (72 * creatinine);
    if (!isMale)
        crClr = crClr * 0.85;
    int result = (int) (crClr + 0.5);
    NSLog(@"Unrounded crClr = %f, Rounded = %i", crClr, result);
    return result;
}


- (double)lbsToKgs:(double)weight{
    double CONVERSION_FACTOR = 0.45359237;
    return weight * CONVERSION_FACTOR;
}
              
- (NSString *)getDose:(int)crCl {
    int dose;
    NSString *message = [[NSString alloc] init];
    if ([drug isEqualToString:DABIGATRAN]) {
        if (crCl > 30)
            dose = 150;
        else if (crCl >= 15)
            dose = 75;
        else {
            dose = 0;
        }
        if (dose == 0)
            return [message stringByAppendingString:DO_NOT_USE];
        return [message stringByAppendingString:[NSString stringWithFormat:@"Dose = %i mg BID. ", dose]];
        
    }
    if ([drug isEqualToString:DOFETILIDE]) {
 		if (crCl > 60)
			dose = 500;
		else if (crCl > 40)
			dose = 250;
		else if (crCl > 20)
			dose = 125;
		else 
            dose = 0;
        if (dose == 0)
            return [message stringByAppendingString:DO_NOT_USE];
        return [message stringByAppendingString:[NSString stringWithFormat:@"Dose = %i mcg BID. ", dose]];
    }
    if ([drug isEqualToString:RIVAROXABAN]) {
        if (crCl > 50)
            dose = 20;
        else if (crCl >= 15)
            dose = 15;
        else
            dose = 0;
        if (dose == 0)
            return [message stringByAppendingString:DO_NOT_USE];
        return [message stringByAppendingString:[NSString stringWithFormat:@"Dose = %i mg daily. ", dose]];        
        }
    if ([drug isEqualToString:SOTALOL]) {
        if (crCl >= 40)
            dose = 80;
        else 
            dose = 0;
        if (dose == 0)
            return [message stringByAppendingString:DO_NOT_USE];
        if (crCl > 60)
            return [message stringByAppendingString:[NSString stringWithFormat:@"Dose = %i mg BID. ", dose]];
        if (crCl >= 40)
            return [message stringByAppendingString:[NSString stringWithFormat:@"Dose = %i mg daily. ", dose]];  
    }
    return @"Unknown Dose";
}

- (BOOL)hasWarning:(int)crCl {
    if ([drug isEqualToString:DABIGATRAN])
        return crCl <= 50;
    if ([drug isEqualToString:DOFETILIDE])
        return crCl < 20;
    if ([drug isEqualToString:RIVAROXABAN])
        return crCl < 15;
    if ([drug isEqualToString:SOTALOL])
        return crCl < 40;
    return NO;
}

- (NSString *)getDetails:(int)crCl {
    if ([drug isEqualToString:DABIGATRAN]) {
        if (crCl < 15)
            return @"";
        else if (crCl <= 30)
            return @"Avoid concomitant use of P-gp inhibitors (e.g. dronedarone).";
        else if (crCl <= 50)
            return @"Consider reducing dose of dabigatran to 75 mg twice a day " 
                "when dronedarone or systemic ketoconazole is administered with dabigatran.";
    }
    if ([drug isEqualToString:DOFETILIDE]) {
        if (crCl <= 20)
            return @"";
    }
    if ([drug isEqualToString:RIVAROXABAN]) {
        if (crCl < 15)
            return @"";
        else 
            return @"Take dose with evening meal.";
    }
    if ([drug isEqualToString:SOTALOL]) {
        if (crCl < 40)
            return @"";
        else {
            NSString * msg = @"This is the recommended starting dose for treatment of atrial fibrillation. "
                "Initial QT should be < 450 msec (package insert specifies QT, not QTc). "
                "If QT remains < 500 msec dose can be increased to 120 mg or 160 mg ";
            if (crCl > 60)
                return [msg stringByAppendingString:@"BID."];
            else 
                return [msg stringByAppendingString:@"daily."];
        }
    }
        
    return @"";
}


- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender {
    [ageField resignFirstResponder];
    [weightField resignFirstResponder];
    [creatinineField resignFirstResponder];
}



@end
