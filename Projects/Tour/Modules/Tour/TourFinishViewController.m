//
//  TourFinishViewController.m
//  Tour
//
//  Created by Jim Kang on 6/14/11.
//  Copyright 2011 Modo Labs. All rights reserved.
//

#import "TourFinishViewController.h"
#import "TourDataManager.h"

@implementation TourFinishViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    NSArray *finishTextArray = [[TourDataManager sharedManager] finishText];
    NSString *message = @"";
    if (finishTextArray.count > 0) {
        message = [finishTextArray objectAtIndex:0];
    }
    thankYouLabel.text = [TourDataManager stripHTMLTagsFromString:message];
    [thankYouLabel sizeToFit];
    
    // Add links.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
