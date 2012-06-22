//
//  SecondViewController.m
//  RHFirstUserExperienceDemo
//
//  Created by Richard Heard on 23/06/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Nib Overlay", @"Nib Overlay");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        [self changeBGColour:self];
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

- (IBAction)changeBGColour:(id)sender {
    self.view.backgroundColor = [UIColor colorWithRed:(random()%100)/(float)100 green:(random()%100)/(float)100 blue:(random()%100)/(float)100 alpha:1];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"SecondTabOnScreen"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RHFirstUserExperienceManager sharedManager] passCheckpoint:@"SecondTabOffScreen"];

}

@end
