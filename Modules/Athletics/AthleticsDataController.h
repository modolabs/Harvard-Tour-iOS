//
//  AthleticsDataController.h
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGORequestManager.h"
#define ATHLETICS_CATEGORY_EXPIRES_TIME 7200.0
static NSString * const FeedListModifiedDateKey = @"feedListModifiedDateArray";
@class AthleticsDataController,AthleticsCategory,AthleticsStory,AthleticsMenu;
@protocol KGOSearchResultsHolder;
@protocol AthleticsDataDelegate <NSObject>

@optional

- (void)dataController:(AthleticsDataController *)controller didRetrieveCategories:(NSArray *)categories;
- (void)dataController:(AthleticsDataController *)controller didRetrieveStories:(NSArray *)stories;
- (void)dataController:(AthleticsDataController *)controller didRetrieveMenuCategories:(NSArray *)menuCategories;

- (void)dataController:(AthleticsDataController *)controller didMakeProgress:(CGFloat)progress;

- (void)dataController:(AthleticsDataController *)controller didFailWithCategoryId:(NSString *)categoryId;
- (void)dataController:(AthleticsDataController *)controller didReceiveSearchResults:(NSArray *)results;

- (void)dataController:(AthleticsDataController *)controller didPruneStoriesForCategoryId:(NSString *)categoryId;

@end

@interface AthleticsDataController : NSObject <KGORequestDelegate>{
    NSMutableArray *_currentStories;
    NSArray *_currentCategories;
    NSMutableSet *_searchRequests;
    NSMutableArray *_searchResults;
}


@property (nonatomic, retain) NSArray *currentCategories;
@property (nonatomic, retain) NSMutableArray *currentStories;
@property (nonatomic, assign) id<AthleticsDataDelegate> delegate;
@property (nonatomic, assign) id<KGOSearchResultsHolder> searchDelegate;
@property (nonatomic, retain) ModuleTag *moduleTag;
@property (nonatomic, retain) AthleticsCategory *currentCategory;

@property (nonatomic, copy) NSDate *feedListModifiedDate;

@property (nonatomic, retain) KGORequest *storiesRequest;
@property (nonatomic, retain) KGORequest *menuCategoryStoriesRequest;
@property (nonatomic, retain) NSMutableSet *searchRequests;

- (NSArray *)latestCategories;
- (BOOL)requiresKurogoServer;
- (void)fetchCategories;
- (NSArray *)bookmarkedStories;
- (void)fetchStoriesForCategory:(NSString *)categoryId
                        startId:(NSString *)startId;
- (void)fetchMenusForCategory:(NSString *)categoryId
                        startId:(NSString *)startId;
- (void)fetchMenuCategoryStories:(AthleticsCategory *)menuCategory 
                         startId:(NSString *)startId;
- (void)requestStoriesForCategory:(NSString *)categoryId afterId:(NSString *)afterId;
- (void)requestMenuCategoryStoriesForCategory:(AthleticsCategory *)menuCategory 
                                      afterId:(NSString *)afterId;
- (void)requestMenusForCategory:(NSString *)categoryID afterID:(NSString *)afterId;

- (AthleticsCategory *)categoryWithDictionary:(NSDictionary *)categoryDict;
- (AthleticsStory *)storyWithDictionary:(NSDictionary *)storyDict;
- (AthleticsMenu *)menuWithDictionary:(NSDictionary *)menuDict;
@end
