//
//  FUEFirstView.m
//  RHFirstUserExperience
//
//  Created by Richard Heard on 24/06/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "FUEFirstView.h"

@interface FUEFirstView ()

-(void)startAnimating;

@end

@implementation FUEFirstView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        _leftBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftBubble"]];
        _leftBubble.center = CGPointMake(100.0f, 285.0f);
        _leftBubble.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_leftBubble];
        
        _rightBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightBubble"]];
        _rightBubble.center = CGPointMake(220.0f, 285.0f);
        _rightBubble.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_rightBubble];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        [self updateVisibility];
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self startAnimating];
}

-(void)showWithCheckpoint:(NSString*)checkpointName withInfo:(NSDictionary*)info{
    [super showWithCheckpoint:checkpointName withInfo:info];
    [self startAnimating];
}

-(void)startAnimating{
    [_leftBubble stopAnimating];
    [_rightBubble stopAnimating];

    _leftBubble.center = CGPointMake(_leftBubble.center.x, self.bounds.size.height -  195.0f);
    _rightBubble.center = CGPointMake(_rightBubble.center.x, self.bounds.size.height -  195.0f);

    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionOverrideInheritedDuration animations:^{
        _leftBubble.center = CGPointMake(_leftBubble.center.x, _leftBubble.center.y - 12.0f);
        _rightBubble.center = CGPointMake(_rightBubble.center.x, _rightBubble.center.y - 12.0f);
    } completion:^(BOOL finished) {
        //NA
    }];
}

-(void)passedCheckpoint:(NSString*)checkpointName withInfo:(NSDictionary*)info{
    [super passedCheckpoint:checkpointName withInfo:info];
    [self updateVisibility];
}

-(void)updateVisibility{
    BOOL left = [[RHFirstUserExperienceManager sharedManager] haveReachedActionLimitForCheckpoint:@"FirstTabLeftButtonTapped"];
    BOOL right = [[RHFirstUserExperienceManager sharedManager] haveReachedActionLimitForCheckpoint:@"FirstTabRightButtonTapped"];

    [UIView animateWithDuration:0.5f animations:^{
        _leftBubble.alpha = left ? 0.0f : 1.0f;
        _rightBubble.alpha = right ? 0.0f : 1.0f;
    }];
    
}

-(IBAction)hideSelf:(id)sender{
    //use this method to hide self, so the system can cleanup overlay views etc
    [[RHFirstUserExperienceManager sharedManager] hideExperienceView:self];
}

- (void)dealloc
{
    [_leftBubble release];
    [_rightBubble release];

    [super dealloc];
}

@end
