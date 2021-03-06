//
//  EPSMilsteinAlgorithm.m
//  EP Mobile
//
//  Created by David Mann on 10/19/12.
//  Copyright (c) 2012 EP Studios. All rights reserved.
//

#import "EPSMilsteinAlgorithm.h"
#import "EPSAccessoryPathwayLocations.h"

@implementation EPSMilsteinAlgorithm {
    NSString *message;
    NSString *location1;
    NSString *location2;
}


- (NSString *)name {
    return @"Milstein Algorithm";
}

- (NSString *)yesResult:(int *)step {
    [self adjustStepsForward:*step];
    switch (*step) {
		case 1:
			*step = 2;
			break;
		case 2:
			*step = 8;
			break;
		case 3:
			*step = 4;
			break;
		case 4:
			*step = 10;
			break;
		case 5:
			*step = 6;
			break;
		case 6:
			*step = 12;
			break;
		case 7:
			*step = 14;
			break;
    }
    if ([self checkForSuccess:*step])
        *step += SUCCESS_STEP;
    return [self getQuestion:*step];
}

- (NSString *)noResult:(int *)step {
    [self adjustStepsForward:*step];
    switch (*step) {
		case 1:
			*step = 3;
			break;
		case 2:
			*step = 9;
			break;
		case 3:
			*step = 5;
			break;
		case 4:
			*step = 11;
			break;
		case 5:
			*step = 7;
			break;
		case 6:
			*step = 13;
			break;
		case 7:
			*step = 15;
			break;

    }
    if ([self checkForSuccess:*step])
        *step += SUCCESS_STEP;
    return [self getQuestion:*step];
}


- (BOOL)checkForSuccess:(int)step {
    BOOL success = NO;
    switch (step) {
		case 8:
		case 9:
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:
		case 15:
            success = YES;
            break;
    }
    return success;
}


- (NSString *)getQuestion:(int)step {
    NSString *question = nil;
    switch (step) {
        case 1:
            question = @"Q or isoelectric delta wave in Leads I, aVL, or V6?";
            break;
        case 2:
        case 5:
            question = @"LBBB (+ QRS \u2265 90 msec in Lead I and rS in V1 and V2)?";
            break;
		case 3:
			question = @"Q or isoelectric delta wave two of Leads II, III, aVF?";
			break;
		case 4:
            question = @"Rs or RS in V1, V2, or V3?";
			break;
		case 6:
            question = @"QRS axis > +30°?";
			break;
		case 7:
            question = @"Rs or RS in V1 or V2?";
			break;

    }
    return question;
}

- (NSString *)outcome:(int)step {
    step %= SUCCESS_STEP;
    [self setMessageAndLocation:step];
    return self.message;
}

- (NSString *)outcomeLocation1:(int)step {
    step %= SUCCESS_STEP;
    [self setMessageAndLocation:step];
    return self.location1;
}

- (NSString *)outcomeLocation2:(int)step {
    step %= SUCCESS_STEP;
    [self setMessageAndLocation:step];
    return self.location2;
}

- (void)setMessageAndLocation:(int)step {
    // nillify lingering messages and locations
    self.message = nil;
    self.location1 = nil;
    self.location2 = nil;
    switch (step) {
		case 8:
		case 12:
			self.message = @"Anteroseptal";
			self.location1 = AS;
			break;
		case 9:
		case 14:
			self.message = @"Left Lateral";
			self.location1 = LL;
			break;
		case 10:
			self.message = @"Posteroseptal Tricuspid Annulus or Posteroseptal Mitral Annulus";
			self.location1 = PSTA;
			self.location2 = PSMA;
			break;
		case 11:
		case 13:
			self.message = @"Right Lateral";
			self.location1 = RL;
			break;
		case 15:
			self.message = @"Undetermined Location";
            self.location1 = nil;
            self.location2 = nil;
			break;
    }
    
}


@end
