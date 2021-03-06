//
//  EPSStepAlgorithmProtocol.h
//  EP Mobile
//
//  Created by David Mann on 10/15/12.
//  Copyright (c) 2012 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

// any step this or higher means algorithm has reached its endpoint
#define SUCCESS_STEP 1000

@protocol EPSStepAlgorithmProtocol <NSObject>
- (NSString *)yesResult:(int *)step;
- (NSString *)noResult:(int *)step;
- (NSString *)backResult:(int *)step;
- (NSString *)outcome:(int)step;
- (NSString *)name;
- (BOOL)showInstructionsButton;
- (BOOL)showMap;
- (NSString *)step1;
- (void)resetSteps:(int *)step;
- (NSString *)resultDialogTitle;

@end
