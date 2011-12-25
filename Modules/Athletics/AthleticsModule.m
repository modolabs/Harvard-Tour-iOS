//
//  AthleticsModule.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsModule.h"
#import "AthleticsListController.h"
#import "AthleticsModel.h"
#import "AthleticsSportDetailViewController.h"
#import "AthleticsSportsViewController.h"
#import "AthleticsScheduleDetailViewController.h"
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
//    UIViewController *vc = nil;
//    if ([pageName isEqualToString:LocalPathPageNameHome]) {
//        vc = [[[AthleticsListController alloc] initWithNibName:@"AthleticsListController"
//                                                    bundle:nil] autorelease];
//    }
//    return vc;
    
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        AthleticsListController *athleticsListVC = [[[AthleticsListController alloc] initWithNibName:@"AthleticsListController"
                                                                                      bundle:nil] autorelease];
        athleticsListVC.dataManager = self.dataManager;
        vc = athleticsListVC;
        
        if ([params objectForKey:@"category"]) {
            AthleticsCategory *category = [params objectForKey:@"category"];
            [(AthleticsListController *)vc setActiveCategoryId:category.category_id];
        }
        
    } else if ([pageName isEqualToString:LocalPathPageNameSearch]) {
        AthleticsListController *athleticsListVC = [[[AthleticsListController alloc] initWithNibName:@"AthleticsListController"
                                                                                      bundle:nil] autorelease];
        athleticsListVC.dataManager = self.dataManager;
        self.dataManager.delegate = athleticsListVC;
        vc = athleticsListVC;
        
        NSString *searchText = [params objectForKey:@"q"];
        if (searchText) {
            athleticsListVC.federatedSearchTerms = searchText;
        }
        
        NSArray *searchResults = [params objectForKey:@"searchResults"];
        if (searchResults) {
            athleticsListVC.federatedSearchResults = searchResults;
        }
        
    } else if ([pageName isEqualToString:LocalPathPageNameDetail]) {
        if ([[params objectForKey:@"type"] isEqualToString:@"schedule"]) {
            AthleticsScheduleDetailViewController *scheduleDetailVC = [[[AthleticsScheduleDetailViewController alloc] init] autorelease];
            scheduleDetailVC.currentSchedule = [params objectForKey:@"schedule"];
            vc = scheduleDetailVC;
        } else {
            AthleticsSportDetailViewController *detailVC = [[[AthleticsSportDetailViewController alloc] init] autorelease];
            detailVC.dataManager = self.dataManager;
            vc = detailVC;
            
            AthleticsStory *story = [params objectForKey:@"story"];
            if (story) { // show only one story
                [detailVC setStory:story];
                [detailVC setMultiplePages:NO];
                
            } else {
                NSArray *stories = [params objectForKey:@"stories"];
                if (stories) {
                    [detailVC setStories:stories]; 
                    
                    NSIndexPath *indexPath = [params objectForKey:@"indexPath"];
                    [detailVC setInitialIndexPath:indexPath];
                    [detailVC setMultiplePages:YES];
                }
            }
            
            // TODO: figure out why this (defined in detail vc class) is AthleticsStory
            AthleticsStory *category = [params objectForKey:@"category"];
            if (category) {
                [detailVC setCategory:category];
            }
        }
    } else if ([pageName isEqualToString:LocalPathPageNameItemList]) {
        AthleticsSportsViewController *athleticsSportsVC = [[AthleticsSportsViewController alloc] 
                                                            initWithNibName:@"AthleticsSportsViewController" 
                                                            bundle:nil];
        athleticsSportsVC.dataManager = self.dataManager;
        vc = athleticsSportsVC;
    
        if ([params objectForKey:@"category"]) {
            AthleticsCategory *category = [params objectForKey:@"category"];
            NSIndexPath *indexPath = [params objectForKey:@"indexPath"];
            NSArray *menuCategories = [params objectForKey:@"menuCategories"];
            
            athleticsSportsVC.dataManager.currentCategory = [menuCategories objectAtIndex:indexPath.row];
            [(AthleticsSportsViewController *)vc setActiveCategoryId:category.category_id];
            [(AthleticsSportsViewController *)vc setActieveMenuCategoryIdx:indexPath.row];
            [(AthleticsSportsViewController *)vc setCategories:menuCategories];
        }
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

#pragma mark AthleticsDataDelegate (to retrieve Categories)

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
