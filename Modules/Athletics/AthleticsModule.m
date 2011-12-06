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

- (void)willLaunch {
    [self dataManager];
}

- (void)willTerminate {
    [_dataManager release];
    _dataManager = nil;
}

- (BOOL)requiresKurogoServer {
    return YES;
}


#pragma mark Navigation
- (NSArray *)registeredPageNames {
    return [NSArray arrayWithObjects:LocalPathPageNameHome, LocalPathPageNameSearch, LocalPathPageNameDetail, nil];
}

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params
{
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        vc = [[[AthleticsListController alloc] initWithNibName:@"AthleticsListController"
                                                    bundle:nil] autorelease];
    }
    return vc;
}

- (NSArray *)objectModelNames {
    return [NSArray arrayWithObject:@"Athletics"];
}

#pragma mark - Search
- (BOOL)supportsFederatedSearch {
    return YES;
}


- (void)performSearchWithText:(NSString *)searchText
                       params:(NSDictionary *)params
                     delegate:(id<KGOSearchResultsHolder>)delegate
{    
    self.searchDelegate = delegate;
    
    [_searchText release];
    _searchText = [searchText retain];
    
    self.dataManager.delegate = self;
    [self.dataManager fetchCategories];
}

- (void)didReceiveSearchResults:(NSArray *)results forSearchTerms:(NSString *)searchTerms
{
    //[self.searchDelegate receivedSearchResults:results forSource:self.tag];
    self.searchDelegate = nil;
}

#pragma mark - DataManager
- (AthleticsDataController *)dataManager
{
    if (!_dataManager) {
        _dataManager = [[AthleticsDataController alloc] init];
        _dataManager.moduleTag = self.tag;
    }
    return _dataManager;
}

- (void)dealloc {
    self.dataManager = nil;
    [_searchText release];_searchText = nil;
    [super dealloc];
}

#pragma mark NewsDataDelegate (to retrieve Categories)

- (void)dataController:(AthleticsDataController *)controller didRetrieveCategories:(NSArray *)categories
{
    if (self.searchDelegate) {
        self.dataManager.searchDelegate = self.searchDelegate;
        self.searchDelegate = nil;
        //[self.dataManager searchStories:_searchText];
        [_searchText release];
        _searchText = nil;
    }
}
@end
