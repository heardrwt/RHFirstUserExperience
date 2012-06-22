//
//  FUEFirstView.h
//  RHFirstUserExperience
//
//  Created by Richard Heard on 24/06/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "RHFirstUserExperienceGenericOverlayView.h"

@interface FUEFirstView : RHFirstUserExperienceGenericOverlayView {
    UIImageView *_leftBubble;
    UIImageView *_rightBubble;
}

-(void)updateVisibility;
-(IBAction)hideSelf:(id)sender;


@end
