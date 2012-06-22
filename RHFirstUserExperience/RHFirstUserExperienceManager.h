//
//  RHFirstUserExperienceManager.h
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

// OVERVIEW: A comprehensive First User Experience Manager for your next iOS Project.
// All appearance behaviours are defined by a configuration plist that should be included in your apps resources at compile time.

// Each entry in the top level of the config file is a key / value pair that defines the properties of a checkpoint.
// Keys and values are described below. (see definitions)

// The manager supports loading overlay view classes directly as well as pre-configured overlay views from Nib files.
// If loading overlay views from a Nib, care should be taken to include exactly 1 top level view that implements the RHFirstUserExperienceOverlayViewProtocol. All other top level objects will not be retained.

// A generic overlay view (RHFirstUserExperienceGenericOverlayView) is included and should be subclassed or used directly as an instance in a Nib file.
// The Nib file's "File's Owner" will be set to the +sharedManager that loads it. This allows for buttons etc. to directly call hideMyParentOverlayView: from the Nib.

// Every checkpoint has an associated actionLimitCount which can be used to only display a given user interface element a small number of times.
// These counts are stored in standardUserDefaults. Once a count is reached for a given checkpoint it will no longer be delivered.
// Once all counts have been reached, the overlay view / manager will no longer be loaded.

#import <Foundation/Foundation.h>
#import "RHFirstUserExperienceOverlayViewProtocol.h"

//enable framework debug logging (by default, enabled if DEBUG is defined, change FALSE to TRUE to enable always)
#define RH_FUE_ENABLE_DEBUG_LOGGING  ( defined(DEBUG) || FALSE )


extern NSString * const RHFirstUserExperienceDefaultsPrefix;

//keys for the FUE Config Dictionary
extern NSString * const kRHFirstUserExperienceViewClass;    // viewClass (string)
extern NSString * const kRHFirstUserExperienceViewNibName;      // viewNibName (string) (Only used if viewClass is not specified) (Nib file's "File's Owner" will be +sharedManager) (you can load ipad vs iphone specific Nibs using the standard ~ipad / ~iphone file specific modifiers. See:https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html#//apple_ref/doc/uid/10000051i-CH1-SW2 )
extern NSString * const kRHFirstUserExperienceAction;           // action (string)
extern NSString * const kRHFirstUserExperienceActionLimitCount; // actionLimitCount (int)


//possible values for each checkpoints action
typedef enum {
    RHFirstUserExperienceActionNone = 0, // none (or empty string)
    RHFirstUserExperienceActionShow,     // show
    RHFirstUserExperienceActionForward,  // forward
    RHFirstUserExperienceActionHide      // hide
} RHFirstUserExperienceAction;

NSString* RHFirstUserExperienceStringForAction(RHFirstUserExperienceAction action);
RHFirstUserExperienceAction RHFirstUserExperienceActionForString(NSString* string);

@interface RHFirstUserExperienceManager : NSObject {
@private
    dispatch_queue_t _actionQueue;
    
    NSDictionary *_experienceDictionary; //loaded from bundle
    NSMutableDictionary *_experienceViews; //cache of loaded overlay views.
    
    BOOL _firstUserExperienceEnabled;
}

//singleton
//by default the shared manager loads its config dictionary from [[NSBundle mainBundle] pathForResource:@"FirstUserExperience" ofType:@"plist"]
+(id)sharedManager;

//Before calling sharedManger for the first time, you can specify a custom config dictionary / path that will be used instead of the default.
+(void)useCustomConfigPath:(NSString*)customPath;
+(void)useCustomConfigDictionary:(NSDictionary*)customDictionary;


//action checkpoint reached
-(void)passCheckpoint:(NSString *)checkpointName;
-(void)passCheckpoint:(NSString *)checkpointName withInfo:(NSDictionary*)info;

//for overlay views to request their own hiding
-(void)hideExperienceView:(id<RHFirstUserExperienceOverlayViewProtocol>)view;
-(IBAction)hideMyParentOverlayView:(id)sender; // We walk up the senders superview chain until we find a parent overlay view, which we then pass to -hideExperienceView:. This allows a button in a Nib to directly dismiss its overlay view.

//for system settings / logout etc
-(void)hideAllExperienceViews;
@property (assign) BOOL firstUserExperienceEnabled;

//can be used to turn off certain parts of an overlay view. eg: if you have 2 buttons, one of which has been pressed previously.
//see demo for an example
-(BOOL)haveReachedActionLimitForCheckpoint:(NSString*)checkpointName;

//debug method that allows for reseting of all action counts
-(void)resetAllFirstUserExperienceActionLimits;

@end


//define the debug logging macros
#if RH_FUE_ENABLE_DEBUG_LOGGING
#define RHLog(format, ...) NSLog( @"%s:%i %@ ", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat: format, ##__VA_ARGS__])
#else
#define RHLog(format, ...)
#endif

#define RHErrorLog(format, ...) NSLog( @"%s:%i %@ ", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat: format, ##__VA_ARGS__])

