## RHFirstUserExperience

A comprehensive First User Experience Manager for your next iOS Project.
Supporting custom overlay views loaded from classes and Nib files at runtime based on a plist of defined actions.


## Overview

All appearance behaviours are defined by a configuration plist that should be included in your apps resources at compile time.

Each entry in the top level of the config file is a key / value pair that defines the properties of a checkpoint.
Keys and values are described below. (see definitions)

The manager supports loading overlay view classes directly as well as pre-configured overlay views from Nib files.
If loading overlay views from a Nib, care should be taken to include exactly 1 top level view that implements the RHFirstUserExperienceOverlayViewProtocol. All other top level objects will be autoreleased and not be retained.

A generic overlay view (RHFirstUserExperienceGenericOverlayView) is included and should be subclassed or used directly as an instance in a Nib file.
The Nib file's "File's Owner" will be set to the +sharedManager that loads it. This allows for buttons etc. to directly call hideMyParentOverlayView: from the Nib.

Every checkpoint has an associated actionLimitCount which can be used to only display a given user interface element a small number of times.
These counts are stored in standardUserDefaults. Once a count is reached for a given checkpoint it will no longer be delivered.
Once all counts have been reached, the overlay view / manager will no longer be loaded.

## PList Keys

```objectivec
//keys for the FUE Config Dictionary
extern NSString * const kRHFirstUserExperienceViewClass;    	// viewClass (string)
extern NSString * const kRHFirstUserExperienceViewNibName;      // viewNibName (string)
extern NSString * const kRHFirstUserExperienceAction;           // action (string)
extern NSString * const kRHFirstUserExperienceActionLimitCount; // actionLimitCount (int)

```
### Notes for viewNibName key
* Only used if viewClass is not specified 
* Nib file's "File's Owner" will be set to +sharedManager
* You can load iPad vs iPhone specific Nibs using the standard ~ipad / ~iphone file specific modifiers. See https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html#//apple_ref/doc/uid/10000051i-CH1-SW2

## Action Values

```objectivec
//possible values for each checkpoints action
typedef enum {
    RHFirstUserExperienceActionNone = 0, // none (or empty string)
    RHFirstUserExperienceActionShow,     // show
    RHFirstUserExperienceActionForward,  // forward
    RHFirstUserExperienceActionHide      // hide
} RHFirstUserExperienceAction;

```

## Performing actions in your existing code
```objectivec
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"SecondTabOnScreen"];
}

- (IBAction)leftPressed:(id)sender{
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"FirstTabLeftButtonTapped"];
    //do other stuff
}

```

## Example Configuration File

![Example Property List Configuration File.](https://github.com/heardrwt/RHPreferences/raw/master/PList.png )

## Manager Interface

```objectivec
@interface RHFirstUserExperienceManager : NSObject 

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
```

## RHFirstUserExperienceOverlayViewProtocol

```objectivec
@protocol RHFirstUserExperienceOverlayViewProtocol <NSObject>

@property (nonatomic, retain) NSString *firstUserExperienceManagerIdentifier; //set automatically on the view when the view is loaded by the manager. (used internally by the manager)


//load and unload methods should know how to install and remove themselves using whatever animation they require.

//called after init, tells the controller to install its overlay view in the main window
-(void)showWithCheckpoint:(NSString*)checkpointName withInfo:(NSDictionary*)info;

//called whenever a checkpoint is passed, view can behave accordingly
-(void)passedCheckpoint:(NSString*)checkpointName withInfo:(NSDictionary*)info;

//hide should remove the overlay view from the main window.
//never call it directly from your code, instead use hideExperienceViewController: on the FUEManager so we can de-register the view
-(void)hide;

@end

```

## Example Screenshots

![Example Class Based Overlay View.](https://github.com/heardrwt/RHFirstUserExperience/raw/master/Class.png )

![Example Nib Based Overlay View.](https://github.com/heardrwt/RHPreferences/raw/master/Nib.png )

## Licence
Released under the Modified BSD License. 
(Attribution Required)
<pre>

Copyright (c) 2012 Richard Heard. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
</pre>

## iOS version support

This code works on and has been tested on 4.3+. 

Feel free to file issues for anything that doesn't work correctly, or you feel could be improved. 

## Appreciation 

If you find this project useful, buy me a beer the next time you see me, or grab me something from my [wishlist](http://www.amazon.com/gp/registry/wishlist/3FWPYC4SEU5QM ). 

