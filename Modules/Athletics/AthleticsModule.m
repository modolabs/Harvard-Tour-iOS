//
//  AthleticsModule.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsModule.h"
#import "AthleticsListController.h"
#import "AthleticsDataController.h"
@implementation AthleticsModule
@synthesize dataManager = _dataManager;


- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params
{
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        vc = [[[AthleticsListController alloc] initWithNibName:@"AthleticsListController"
                                                    bundle:nil] autorelease];
    }
    return vc;
}

#pragma mark Search

- (BOOL)supportsFederatedSearch {
    return YES;
}

- (void)performSearchWithText:(NSString *)searchText
                       params:(NSDictionary *)params
                     delegate:(id<KGOSearchResultsHolder>)delegate
{
    self.dataManager.searchDelegate = delegate;
}

- (void)dealloc {
    self.dataManager = nil;
    [super dealloc];
}
@end
