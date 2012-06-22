//
//  RHFirstUserExperienceGenericOverlayView.h
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

#import <UIKit/UIKit.h>
#import "RHFirstUserExperienceOverlayViewProtocol.h"
#import "RHFirstUserExperienceManager.h"

typedef enum _RHFirstUserExperienceTouchHandlingMode {
    RHFirstUserExperienceTouchHandlingModeNoPassThrough = 0, // default for stock UIView instances
    RHFirstUserExperienceTouchHandlingModeSelfPassThrough,  // Touches that would otherwise be handled by self, are outside our bounds, however subviews still block & recieve touches.
    RHFirstUserExperienceTouchHandlingModeAllPassThrough    //default; We tell the system that any touches are outside our bounds even if they are not. This results in touches being passed to views below us. Overlay View Defaults to this option. (UIView defaults to RHFirstUserExperienceTouchHandlingModeNoPassThrough)
} RHFirstUserExperienceTouchHandlingMode;

@interface RHFirstUserExperienceGenericOverlayView : UIView <RHFirstUserExperienceOverlayViewProtocol>{
@protected
    
    NSString *_firstUserExperienceManagerIdentifier;
    
    BOOL _showing;
    
    NSTimeInterval _showAnimationDuration;
    NSTimeInterval _hideAnimationDuration;
    
    RHFirstUserExperienceTouchHandlingMode _touchHandlingMode;
    dispatch_once_t _dismissOnTouchEventOnceToken;
    BOOL _dismissOnTouchEvent;
    
}

@property (readonly, nonatomic) BOOL showing;

//config
@property (nonatomic) NSTimeInterval showAnimationDuration; //default is 0.0f; Immediate
@property (nonatomic) NSTimeInterval hideAnimationDuration; //default is 0.0f; Immediate

@property (nonatomic) RHFirstUserExperienceTouchHandlingMode touchHandlingMode; //default is RHFirstUserExperienceTouchHandlingModeAllPassThrough; To set the touchHandlingMode from a nib, either subclass the controller and set in awakeFromNib or set a runtime attribute on the view eg [touchHandlingMode | Number | 1] == RHFirstUserExperienceTouchHandlingModeSelfPassThrough

@property (nonatomic) BOOL dismissOnTouchEvent; //default is NO; If the user touches the current view, or one of our subviews, the overlay is dismissed. If RHFirstUserExperienceTouchHandlingModeNoPassThrough is not set the touch is propagated to the underlying view, if it is, the touch will be eaten.


@end
