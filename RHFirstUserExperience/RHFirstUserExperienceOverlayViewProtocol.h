//
//  RHFirstUserExperienceOverlayViewProtocol.h
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

#import <Foundation/Foundation.h>


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
