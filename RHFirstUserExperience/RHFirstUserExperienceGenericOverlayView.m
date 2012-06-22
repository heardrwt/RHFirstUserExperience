//
//  RHFirstUserExperienceGenericOverlayView.m
//  RHFirstUserExperience
//
//  Created by Richard Heard on 23/06/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "RHFirstUserExperienceGenericOverlayView.h"
#import "RHFirstUserExperienceOverlayViewProtocol.h"

@implementation RHFirstUserExperienceGenericOverlayView

@synthesize firstUserExperienceManagerIdentifier=_firstUserExperienceManagerIdentifier;

@synthesize showing=_showing;

@synthesize showAnimationDuration=_showAnimationDuration;
@synthesize hideAnimationDuration=_hideAnimationDuration;

@synthesize touchHandlingMode=_touchHandlingMode;
@synthesize dismissOnTouchEvent=_dismissOnTouchEvent;


- (void)dealloc{
	[super dealloc];
}

-(id)init{
    return [self initWithFrame:[[self findVisibleViewForDisplay] bounds]];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    RHLog(@"");
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        _touchHandlingMode = RHFirstUserExperienceTouchHandlingModeAllPassThrough; //default to all, we are overlay views after all :)
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        RHLog(@"");
        self.backgroundColor = [UIColor clearColor]; //default to clear for subclasses, nibs can take care of themselves.
        _touchHandlingMode = RHFirstUserExperienceTouchHandlingModeAllPassThrough; //default to all, we are overlay views after all :)
        
    }
    return self;
}


/*
 
 #pragma mark - UIResponder
 
 //optionally intercept touches
 // if you want to respond to touches be sure to set _passThroughTouches to NO
 
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
 }
 - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
 }
 - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
 }
 - (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
 }
 
 */



//subclass hitTest:withEvent so we can make ourselves transparent to taps if we so desire
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    if (_dismissOnTouchEvent){
        dispatch_once(&_dismissOnTouchEventOnceToken, ^{
            [[RHFirstUserExperienceManager sharedManager] hideExperienceView:self];
        });
    }
    
    if (_touchHandlingMode == RHFirstUserExperienceTouchHandlingModeAllPassThrough){
        //nil means the point is not inside ourselves or any of our subviews.
        return nil;
    }
    
    
    UIView *hitView = [super hitTest:point withEvent:event];

    if (_touchHandlingMode == RHFirstUserExperienceTouchHandlingModeSelfPassThrough){
        //see if one of our subviews can handle the touch, if so, return them, otherwise return nil; (exclude self)
        if (hitView == self) return nil;
    }
    
    //default, call super == RHFirstUserExperienceTouchHandlingModeNoPassThrough
    return hitView;
}


#pragma mark - DBFirstUserExperienceProtocol

//called after init, tells the controller to install its overlay view in the main window
-(void)showWithCheckpoint:(NSString*)checkpointName withInfo:(NSDictionary*)info{
    RHLog(@"");
    //put the view on screen if not already loaded
    if (!_showing) {
        _showing = YES;
        UIView *installView = [self findVisibleViewForDisplay];
        [installView addSubview:self];
        self.frame = installView.bounds; //set the views bounds for display.
        [self setNeedsLayout];
        
        self.alpha = 0.0f;
        [UIView animateWithDuration:_showAnimationDuration delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.alpha = 1.0f;
        } completion:nil];
        
    }
    
}
//override, so we can add an animation delay


-(UIView*)findVisibleViewForDisplay{
    
    //first try the windows root view controllers view
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *installView =  [rootViewController view];
    
    //if that's not currently visible, lets see if we can find the view that is currently presented
    if (installView.isHidden || !installView.superview){
        
        SEL selector = @selector(modalViewController); //pre iOS5
        if ([UIViewController instancesRespondToSelector:@selector(presentedViewController)]) selector = @selector(presentedViewController); //iOS5+
        
        //loop down until we find the final presented view controller
        UIViewController *controller = rootViewController;
        while ([controller performSelector:selector] != nil) {
            controller = [controller performSelector:selector];
        }
        
        installView = controller.view;
    }
    
    
    //if that failed, add it directly to the key window. (this wont support rotation)
    if (!installView || installView.isHidden || !installView.superview) installView = [[UIApplication sharedApplication] keyWindow];
    
    return installView;
    
}

//called whenever a checkpoint is passed that specifies RHFirstUserExperienceActionForward, view can behave accordingly
-(void)passedCheckpoint:(NSString*)checkpointName withInfo:(NSDictionary*)info{
    RHLog(@"");
    
    /*
     //perform some action based on the checkpoint action
     self.backgroundColor = [UIColor redColor];
     
     
     //to unload as a result of a tap or a checkpoint you can do this... (Never call [self hide] directly.)
     if ([checkpointName isEqualToString:@"genericDismiss"]){
     [[DBFirstUserExperienceManager sharedManager] hideExperienceView:self];
     return;
     }
     */
    
}


//hide should remove the overlay view from the main window.
//!!!!! never call hide yourself. !!!!!
-(void)hide{
    RHLog(@"");
    //remove the view from screen
    [UIView animateWithDuration:_hideAnimationDuration delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _showing = NO;
        [self removeFromSuperview];
    }];
    
    
}

//support accessibility
-(BOOL)accessibilityElementsHidden{
    return _touchHandlingMode != RHFirstUserExperienceTouchHandlingModeNoPassThrough;
}

@end
