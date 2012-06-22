//
//  FirstViewController.m
//  RHFirstUserExperienceDemo
//
//  Created by Richard Heard on 23/06/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Custom Overlay", @"Custom Overlay");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"FirstTabOnScreen"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"FirstTabOffScreen"];
}

- (IBAction)leftPressed:(id)sender{
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"FirstTabLeftButtonTapped"];
    //do other stuff
}

- (IBAction)rightPressed:(id)sender{
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"FirstTabRightButtonTapped"];
    //do other stuff
}
@end
