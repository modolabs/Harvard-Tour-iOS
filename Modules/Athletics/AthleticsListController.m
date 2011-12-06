//
//  AthleticsListController.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsListController.h"

@implementation AthleticsListController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [_navScrollView release];
    _navScrollView = nil;
    [_loadingLabel release];
    _loadingLabel = nil;
    [_lastUpdateLabel release];
    _lastUpdateLabel = nil;
    [_progressView release];
    _progressView = nil;
    [_storyTable release];
    _storyTable = nil;

    [_athleticsCell release];
    _athleticsCell = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_navScrollView release];
    [_loadingLabel release];
    [_lastUpdateLabel release];
    [_progressView release];
    [_storyTable release];

    [_athleticsCell release];
    [super dealloc];
}
@end
