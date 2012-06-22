//
//  RHFirstUserExperienceManager.m
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

#import "RHFirstUserExperienceManager.h"
#import "RHFirstUserExperienceOverlayViewProtocol.h"


NSString * const kRHFirstUserExperienceViewClass = @"viewClass";
NSString * const kRHFirstUserExperienceViewNibName = @"viewNibName";
NSString * const kRHFirstUserExperienceAction = @"action";
NSString * const kRHFirstUserExperienceActionLimitCount = @"actionLimitCount";
NSString * const RHFirstUserExperienceDefaultsPrefix = @"RHFirstUserExperience-";

NSString* RHFirstUserExperienceStringForAction(RHFirstUserExperienceAction action){
    
    switch (action) {
        case RHFirstUserExperienceActionShow: return @"show";
        case RHFirstUserExperienceActionForward: return @"forward";
        case RHFirstUserExperienceActionHide: return @"hide";
        case RHFirstUserExperienceActionNone: return @"none";
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unknown RHFirstUserExperienceAction type. %i", action];
            return nil;
    }
}

RHFirstUserExperienceAction RHFirstUserExperienceActionForString(NSString* string){
    if ([string isEqualToString:@"show"]) return RHFirstUserExperienceActionShow;
    if ([string isEqualToString:@"forward"]) return RHFirstUserExperienceActionForward;
    if ([string isEqualToString:@"hide"]) return RHFirstUserExperienceActionHide;
    if ([string isEqualToString:@""]) return RHFirstUserExperienceActionNone;
    if ([string isEqualToString:@"none"]) return RHFirstUserExperienceActionNone;
    return RHFirstUserExperienceActionNone;
}


//private
@interface RHFirstUserExperienceManager ()

-(RHFirstUserExperienceAction)actionForCheckpointName:(NSString*)checkpointName;
-(id)experienceViewForCheckpointName:(NSString*)checkpointName loadIfNotFound:(BOOL)load;
-(NSInteger)actionLimitCountForCheckpointName:(NSString*)checkpointName;
-(void)incrementActionLimitCountForCheckpointName:(NSString*)checkpointName;
-(void)hideExperienceViewForCheckpointName:(NSString*)checkpointName;

//input validation
-(BOOL)isValidOverlayView:(id)view;
@end


@implementation RHFirstUserExperienceManager

@synthesize firstUserExperienceEnabled=_firstUserExperienceEnabled;

#pragma mark - Singleton

static RHFirstUserExperienceManager *_sharedManager = nil;

+(id)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[super allocWithZone:NULL] init];
    });
    
    return _sharedManager;
}

+(id)allocWithZone:(NSZone *)zone{
    return [[self sharedManager] retain];
}

-(id)init {
    self = [super init];
    if (self) {
        //setup serial queue
        _actionQueue = dispatch_queue_create("RHFirstUserExperienceManagerQueue", DISPATCH_QUEUE_SERIAL);
        
        //load the experience dictionary
        NSString *experiencePath = [[NSBundle mainBundle] pathForResource:@"FirstUserExperience" ofType:@"plist"];
        if (_customConfigPath){
            experiencePath = _customConfigPath;
        }
        if (_customConfigDictionary){
            _experienceDictionary = [_customConfigDictionary retain];
        }else{
            _experienceDictionary = [[NSDictionary dictionaryWithContentsOfFile:experiencePath] retain];
        }
        
        if (!_experienceDictionary){
            [NSException raise:NSInternalInconsistencyException format:@"The sharedManager failed to load the experience file at path: %@", experiencePath];
        }
        
        _experienceViews = [[NSMutableDictionary alloc] init];
        _firstUserExperienceEnabled = YES;
        
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

-(id)retain{
    return self;
}

-(NSUInteger)retainCount{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

-(oneway void)release{
    //do nothing
}

-(id)autorelease{
    return self;
}

-(void)dealloc {
    [_experienceDictionary release]; _experienceDictionary = nil;
    [_experienceViews release]; _experienceViews = nil;
    
    dispatch_release(_actionQueue);
    [super dealloc];
}


#pragma mark - Config

static NSString *_customConfigPath = nil;

+(void)useCustomConfigPath:(NSString*)customPath{
    if(_sharedManager){
        [NSException raise:NSInternalInconsistencyException format:@"The sharedManager has already been loaded. %@ must be called before +(void)sharedManager has been called for the first time.", NSStringFromSelector(_cmd)];
    }
    if (_customConfigPath != customPath){
        [_customConfigPath release];
        _customConfigPath = [customPath copy];
    }
    
    RHLog(@"RHFirstUserExperience custom config path specified: %@", customPath);
}

static NSDictionary *_customConfigDictionary = nil;

+(void)useCustomConfigDictionary:(NSDictionary*)customDictionary{
    if(_sharedManager){
        [NSException raise:NSInternalInconsistencyException format:@"The sharedManager has already been loaded. %@ must be called before +(void)sharedManager has been called for the first time.", NSStringFromSelector(_cmd)];
    }
    
    
    if (_customConfigDictionary != customDictionary){
        [_customConfigDictionary release];
        _customConfigDictionary = [customDictionary copy];
    }
    
    RHLog(@"RHFirstUserExperience custom config dictionary specified: %@", _customConfigDictionary);
}

#pragma mark - Public

//checkpoint reached

-(void)passCheckpoint:(NSString *)checkpointName{
    [self passCheckpoint:checkpointName withInfo:nil];
}

-(void)passCheckpoint:(NSString *)checkpointName withInfo:(NSDictionary*)info{
    
    //if disabled, bail
    if (!_firstUserExperienceEnabled) return;
    
    dispatch_async(_actionQueue, ^{
        
        RHFirstUserExperienceAction action = [self actionForCheckpointName:checkpointName];
        
        RHLog(@"checkpoint:%@ action: %i", checkpointName, action);
        
        if (action == RHFirstUserExperienceActionNone) return; //nothing to be done
        
        id <RHFirstUserExperienceOverlayViewProtocol> viewController = [self experienceViewForCheckpointName:checkpointName loadIfNotFound:(action == RHFirstUserExperienceActionShow)];
        
        if (action == RHFirstUserExperienceActionShow){
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController showWithCheckpoint:checkpointName withInfo:info];
            });
        }
        
        if (action == RHFirstUserExperienceActionForward) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController passedCheckpoint:checkpointName withInfo:info];
            });
        }
        
        if (action == RHFirstUserExperienceActionHide){
            [self hideExperienceViewForCheckpointName:checkpointName];
        }
        
    });
    
}


-(void)hideExperienceView:(id<RHFirstUserExperienceOverlayViewProtocol>)view{
    //where the meat of the op happens
    dispatch_async(_actionQueue, ^{
        //tell the view to hide
        dispatch_async(dispatch_get_main_queue(), ^{
            [view hide];
        });
        
        //remove the vc from our cache
        [_experienceViews removeObjectForKey:view.firstUserExperienceManagerIdentifier];
    });
    
}

-(IBAction)hideMyParentOverlayView:(id)sender{
    while ([sender respondsToSelector:@selector(superview)]) {
        if ([self isValidOverlayView:sender]){
            [self hideExperienceView:sender];
            break;
        }
        
        sender = [sender performSelector:@selector(superview)];
    }
}

-(void)hideAllExperienceViews{
    dispatch_async(_actionQueue, ^{
        
        NSArray *views = [_experienceViews allValues];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<RHFirstUserExperienceOverlayViewProtocol>view in views) {
                [view hide];
            }
        });
        
        [_experienceViews removeAllObjects];
    });
}


//can be used to turn off certain parts of an overlay view. eg: if you have 2 buttons, one of which has been pressed previously.
-(BOOL)haveReachedActionLimitForCheckpoint:(NSString*)checkpointName{
    NSDictionary *checkpoint = [_experienceDictionary objectForKey:checkpointName];
    NSInteger limit = [[checkpoint objectForKey:kRHFirstUserExperienceActionLimitCount] integerValue];
    NSInteger current = [self actionLimitCountForCheckpointName:checkpointName];
    
    BOOL result = !(checkpoint && (limit == 0 || current < limit));
    return result;
}


-(void)resetAllFirstUserExperienceActionLimits{
    
    [_experienceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@", RHFirstUserExperienceDefaultsPrefix, key]];
    }];
    
}


#pragma mark - Behind the curtain

//returns no action if there is nothing to be done, looks up checkpoint in action dictionary, also takes into account local plist stored counts
-(RHFirstUserExperienceAction)actionForCheckpointName:(NSString*)checkpointName{
    
    if (![self haveReachedActionLimitForCheckpoint:checkpointName]){
        NSDictionary *checkpoint = [_experienceDictionary objectForKey:checkpointName];
        
        //if we have a limit, increment
        NSInteger limit = [[checkpoint objectForKey:kRHFirstUserExperienceActionLimitCount] integerValue];
        if (limit) [self incrementActionLimitCountForCheckpointName:checkpointName];
        
        
        NSString *actionString = [checkpoint objectForKey:kRHFirstUserExperienceAction];
        return RHFirstUserExperienceActionForString(actionString);
        
        
    }
    
    
    return RHFirstUserExperienceActionNone;
    
}



//returns nil if not found
-(id)experienceViewForCheckpointName:(NSString*)checkpointName loadIfNotFound:(BOOL)performLoad{
    NSString *className = [[_experienceDictionary objectForKey:checkpointName] objectForKey:kRHFirstUserExperienceViewClass];
    NSString *nibName = [[_experienceDictionary objectForKey:checkpointName] objectForKey:kRHFirstUserExperienceViewNibName];
    
    
    //first try class name.
    if (className){
        //look it up in the dictionary
        __block id<RHFirstUserExperienceOverlayViewProtocol> view = [_experienceViews objectForKey:className];
        
        //if found, bail
        if (view) return view;
        
        //if dont load, bail
        if (!performLoad) return nil;
        
        // so we try and load it
        Class class = NSClassFromString(className);
        if (!class){
            RHErrorLog(@"Error: Failed to find FUE class with name %@!", className);
            return nil;
        }
        
        if ([NSThread isMainThread]) {
            view = [[class alloc] init];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                view = [[class alloc] init];
            });
        }
        
        if (![self isValidOverlayView:view]){
            RHErrorLog(@"Error: Class with name %@ is not a valid OverlayView!", className);
            [view release];
            return nil;
        }
        
        //set the internal load identifier
        view.firstUserExperienceManagerIdentifier = className;
        
        [_experienceViews setObject:[view autorelease] forKey:view.firstUserExperienceManagerIdentifier];
        return view;
        
    }
    
    //if no class name try nibName
    if(nibName){
        //look it up in the dictionary
        id <RHFirstUserExperienceOverlayViewProtocol> view = [_experienceViews objectForKey:nibName];
        
        //if found, bail
        if (view) return view;
        
        //if don't load, bail
        if (!performLoad) return nil;
        
        //try and load it
        __block NSArray *rootNibObjects = nil;
        if ([NSThread isMainThread]) {
            rootNibObjects = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] retain];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                rootNibObjects = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] retain];
            });
        }
        
        if (!rootNibObjects){
            RHErrorLog(@"Error: Failed to load FUE Nib with name %@!", nibName);
        }
        
        //try and locate a valid view, all other top level objects are autoreleased as per ios spec. http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/LoadingResources/CocoaNibs/CocoaNibs.html
        for (id rootObject in rootNibObjects) {
            if ([self isValidOverlayView:rootObject]){
                view = [rootObject retain];
                break;
            }
        }
        
        [rootNibObjects release];
        
        if (!view){
            RHErrorLog(@"Error: Failed to find a valid FUE view in Nib with name %@! Check that you have top level UIView subclass in your nib that implements the RHFirstUserExperienceOverlayViewProtocol.", nibName);
            [view release];
            return nil;
        }
        
        //set the internal load identifier
        view.firstUserExperienceManagerIdentifier = nibName;
        
        
        [_experienceViews setObject:[view autorelease] forKey:view.firstUserExperienceManagerIdentifier];
        return view;
    }
    
    
    //default
    RHErrorLog(@"Error: No class or nibName specified for checkpoint %@!", checkpointName);
    return nil;
    
}

-(void)hideExperienceViewForCheckpointName:(NSString*)checkpointName{
    id vc = [self experienceViewForCheckpointName:checkpointName loadIfNotFound:NO];
    if (vc) [self hideExperienceView:vc];
}

-(NSInteger)actionLimitCountForCheckpointName:(NSString*)checkpointName{
    NSString *defaultsKey = [NSString stringWithFormat:@"%@%@", RHFirstUserExperienceDefaultsPrefix, checkpointName];
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:defaultsKey];
}

-(void)incrementActionLimitCountForCheckpointName:(NSString*)checkpointName{
    NSString *defaultsKey = [NSString stringWithFormat:@"%@%@", RHFirstUserExperienceDefaultsPrefix, checkpointName];
    
    NSInteger current = [[NSUserDefaults standardUserDefaults] integerForKey:defaultsKey];
    [[NSUserDefaults standardUserDefaults] setInteger:(current + 1) forKey:defaultsKey];
}

-(BOOL)isValidOverlayView:(UIView*)view{
    //we need to ensure view implements the protocol in full
    return [view isKindOfClass:[UIView class]] && [view conformsToProtocol:@protocol(RHFirstUserExperienceOverlayViewProtocol)];
}


@end
