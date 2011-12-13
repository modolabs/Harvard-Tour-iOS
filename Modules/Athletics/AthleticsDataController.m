//
//  AthleticsDataController.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//
#import "Foundation+KGOAdditions.h"
#import "AthleticsDataController.h"
#import "CoreDataManager.h"
#import "AthleticsModel.h"
#import "KGORequest.h"

#define REQUEST_CATEGORIES_CHANGED 1
#define REQUEST_CATEGORIES_UNCHANGED 2
#define LOADMORE_LIMIT 10
#define CATEGORIES_COUNT 4
NSString * const AthleticsTagItem            = @"item";
NSString * const AthleticsTagTitle           = @"title";
NSString * const AthleticsTagAuthor          = @"author";
NSString * const AthleticsTagLink            = @"link";
NSString * const AthleticsTagStoryId         = @"GUID";
NSString * const AthleticsTagImage           = @"image";
NSString * const AthleticsTagSummary         = @"description";
NSString * const AthleticsTagPostDate        = @"pubDate";
NSString * const AthleticsTagHasBody         = @"hasBody";
NSString * const AthleticsTagBody            = @"body";

@implementation AthleticsDataController
@synthesize delegate;
@synthesize searchDelegate;
@synthesize moduleTag;
@synthesize currentStories = _currentStories;
@synthesize currentCategories = _currentCategories;
@synthesize currentCategory;
@synthesize storiesRequest;
@synthesize searchRequests = _searchRequests;

- (BOOL)requiresKurogoServer {
    return YES;
}

#pragma mark - KGORequestDelegate
- (void)requestWillTerminate:(KGORequest *)request {
    
}

- (void)request:(KGORequest *)request didFailWithError:(NSError *)error {
    if (request == self.storiesRequest) {
        //NSString *categoryID = [request.getParams objectForKey:@"categoryID"];
        
        //if ([self.delegate respondsToSelector:@selector(storiesDidFailWithCategoryId:)]) {
        //    [self.delegate storiesDidFailWithCategoryId:categoryID];
        //}
        
        if ([self.delegate respondsToSelector:@selector(dataController:didFailWithCategoryId:)]) {
            [self.delegate dataController:self didFailWithCategoryId:self.currentCategory.category_id];
        }
        
        [[KGORequestManager sharedManager] showAlertForError:error request:request];
        
    } else if ([request.path isEqualToString:@"categories"]) {
        [[KGORequestManager sharedManager] showAlertForError:error request:request];
        
        // don't call -fetchCategories since it may issue another request
        NSArray *existingCategories = [self latestCategories];
        if (existingCategories && [self.delegate respondsToSelector:@selector(dataController:didRetrieveCategories:)]) {
            [self.delegate dataController:self didRetrieveCategories:existingCategories];
        }
    }
}

- (void)request:(KGORequest *)request didHandleResult:(NSInteger)returnValue {
    NSString *path = request.path;
    
    if (request == self.storiesRequest) {
//        NSString *categoryId = [request.getParams objectForKey:@"categoryID"];
//        NSString *startId = [request.getParams objectForKey:@"start"];
        NSString *categoryId = self.currentCategory.category_id;
        [self fetchStoriesForCategory:categoryId startId:nil];
        
    } else if ([path isEqualToString:@"categories"]) {    
        switch (returnValue) {
            case REQUEST_CATEGORIES_CHANGED:
            {
                self.currentCategories = nil;
                [self fetchCategories];
                break;
            }
            default:
                break;
        }
    }
}

- (void)request:(KGORequest *)request didReceiveResult:(id)result {
    if ([self.searchRequests containsObject:request]) {
        for (NSDictionary *storyDict in (NSArray *)result) {
            AthleticsStory *story = [self storyWithDictionary:storyDict]; 
            story.searchResult = [NSNumber numberWithInt:1];
            if([_searchResults indexOfObject:story] == NSNotFound) {
                [_searchResults addObject:story];
            }
        }
    }
}

- (void)request:(KGORequest *)request didMakeProgress:(CGFloat)progress {
    if (request == self.storiesRequest) {
        //NSString *categoryID = [request.getParams objectForKey:@"categoryID"];
        
        // TODO: see if progress value needs tweaking
        
        if ([self.delegate respondsToSelector:@selector(dataController:didMakeProgress:)]) {
            [self.delegate dataController:self didMakeProgress:progress];
        }
    }
}

- (void)requestDidReceiveResponse:(KGORequest *)request {
    
}

- (void)requestResponseUnchanged:(KGORequest *)request {
    [request cancel];
    
    NSDate *date = [self feedListModifiedDate];
    if (!date || [date timeIntervalSinceNow] + ATHLETICS_CATEGORY_EXPIRES_TIME < 0) {
        self.feedListModifiedDate = [NSDate date];
    }
    
    [self fetchCategories];
}

- (NSArray *)bookmarkedStories
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"bookmarked == YES AND ANY categories.moduleTag = %@", self.moduleTag];
    return [[CoreDataManager sharedManager] objectsForEntity:AthleticsStoryEntityName matchingPredicate:pred];
}


#pragma mark - Serach

- (NSDate *)feedListModifiedDate
{
    NSDictionary *modDates = [[NSUserDefaults standardUserDefaults] dictionaryForKey:FeedListModifiedDateKey];
    NSDate *result = [modDates dateForKey:self.moduleTag];
    if ([result isKindOfClass:[NSDate class]]) {
        return result;
    }
    return nil;
}

- (void)setFeedListModifiedDate:(NSDate *)date
{
    NSDictionary *modDates = [[NSUserDefaults standardUserDefaults] dictionaryForKey:FeedListModifiedDateKey];
    NSMutableDictionary *mutableModDates = modDates ? [[modDates mutableCopy] autorelease] : [NSMutableDictionary dictionary];
    if (self.moduleTag) {
        [mutableModDates setObject:date forKey:self.moduleTag];
    } else {
        NSLog(@"Warning: AthleticsDataController moduleTag not set, cannot save preferences");
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableModDates forKey:FeedListModifiedDateKey];
}

- (NSArray *)latestCategories
{
    if (!_currentCategories) {    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isMainCategory = YES AND moduleTag = %@", self.moduleTag];
        NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES] autorelease];
        NSSortDescriptor *catSort = [[[NSSortDescriptor alloc] initWithKey:@"category_id" ascending:YES] autorelease]; // compat
        NSArray *results = [[CoreDataManager sharedManager] objectsForEntity:AthleticsCategoryEntityName
                                                           matchingPredicate:predicate
                                                             sortDescriptors:[NSArray arrayWithObjects:sort, catSort, nil]];
        if (results.count) {
            self.currentCategories = results;
        }
    }
    
    return _currentCategories;
}

- (void)fetchCategories
{
    if (!_currentCategories) {
        NSMutableArray *categories = [NSMutableArray array];
        
        NSMutableArray *newCategories = [NSMutableArray array];
        [newCategories addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"0", @"id", 
                                  @"Top News", @"title", 
                                  @"news", @"path",
                                  @"sport", @"category",
                                  @"topnews", @"ivar",
                                  nil]];
        [newCategories addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"id", 
                                  @"Men", @"title", 
                                  @"news", @"path",
                                  @"gender", @"category",
                                  @"men", @"ivar",
                                  nil]];
        [newCategories addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"2", @"id", 
                                  @"Women", @"title", 
                                  @"news", @"path",
                                  @"gender", @"category",
                                  @"women", @"ivar",
                                  nil]];
        [newCategories addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"3", @"id", 
                                  @"Schedule", @"title", 
                                  @"schedule", @"path",
                                  @"sport", @"category",
                                  @"baseball", @"ivar",
                                  nil]];

        for (NSDictionary *enumerator in newCategories) {
           [categories addObject:[self categoryWithDictionary:enumerator]];
        }
        [[CoreDataManager sharedManager] saveDataWithTemporaryMergePolicy:NSOverwriteMergePolicy];
        self.currentCategories = categories;
        if (_currentCategories && _currentCategories.count > 0) {
            if ([self.delegate respondsToSelector:@selector(dataController:didRetrieveCategories:)]) {
                [self.delegate dataController:self didRetrieveCategories:_currentCategories];
            }
        }
    }
}

- (AthleticsCategory *)categoryWithId:(NSString *)categoryId {
    if ([self.currentCategory.category_id isEqualToString:categoryId]) {
        return self.currentCategory;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"category_id like %@", categoryId];
    NSArray *matches = [[self latestCategories] filteredArrayUsingPredicate:pred];
    if (matches.count > 1) {
        NSLog(@"warning: duplicate categories found for id %@", categoryId);
    }
    
    return [matches lastObject];
}

- (void)fetchStoriesForCategory:(NSString *)categoryId
                        startId:(NSString *)startId
{
    if (categoryId && ![categoryId isEqualToString:self.currentCategory.category_id]) {
        self.currentCategory = [self categoryWithId:categoryId];
    }
    
    NSManagedObjectContext *context = [[CoreDataManager sharedManager] managedObjectContext];
    if ([self.currentCategory managedObjectContext] != context) {
        self.currentCategory = (AthleticsCategory *)[context objectWithID:[self.currentCategory objectID]];
    }
    [[[CoreDataManager sharedManager] managedObjectContext] refreshObject:self.currentCategory mergeChanges:NO];
    
    if (!self.currentCategory.lastUpdated
        || [self.currentCategory.lastUpdated timeIntervalSinceNow] > ATHLETICS_CATEGORY_EXPIRES_TIME
        // TODO: make sure the following doesn't result an infinite loop if stories legitimately don't exist
        || !self.currentCategory.stories.count)
    {
        DLog(@"last updated: %@", self.currentCategory.lastUpdated);
        [self requestStoriesForCategory:categoryId afterId:nil];
        return;
    }
    
    NSSortDescriptor *dateSort = [[[NSSortDescriptor alloc] initWithKey:@"postDate" ascending:NO] autorelease];
    NSSortDescriptor *idSort = [[[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:dateSort, idSort, nil];
    
    NSArray *results = [self.currentCategory.stories sortedArrayUsingDescriptors:sortDescriptors];
    
    if ([self.delegate respondsToSelector:@selector(dataController:didRetrieveStories:)]) {
        [self.delegate dataController:self didRetrieveStories:results];
    }
}

//- (void)requestCategoriesFromServer {
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"topnews" forKey:@"sport"];
//    KGORequest *request = [[KGORequestManager sharedManager] requestWithDelegate:self
//                                                                          module:self.moduleTag
//                                                                            path:@"news"
//                                                                         version:1
//                                                                          params:dict];
//    
//    NSDate *date = self.feedListModifiedDate;
//    if (date) {
//        request.ifModifiedSince = date;
//    }
//    
//    __block AthleticsDataController *blockSelf = self;
//    __block NSArray *oldCategories = self.currentCategories;
//    
//    [request connectWithResponseType:[NSDictionary class] callback:^(id result) {
//        
//        int retVal = REQUEST_CATEGORIES_UNCHANGED;
//        NSInteger retval;
//        NSDictionary *newCategoryDicts = (NSDictionary *)result;
//
//        //[[CoreDataManager sharedManager] deleteObjects:cachedNotices];
//        
//        NSArray *newCategoryArray = [newCategoryDicts objectForKey:@"stories"];
//        if(newCategoryArray) {
//        
//        
////        NSArray *newCategoryIds = [newCategoryDicts mappedArrayUsingBlock:^id(id element) {
////            return [(NSDictionary *)element nonemptyStringForKey:@"id"];
////        }];
//        
////        for (AthleticsCategory *oldCategory in oldCategories) {
////            if (![newCategoryIds containsObject:oldCategory.category_id]) {
////                [[CoreDataManager sharedManager] deleteObject:oldCategory];
////                retVal = REQUEST_CATEGORIES_CHANGED;
////            }
////        }
//        
//        for (NSInteger i = 0; i < newCategoryArray.count; i++) {
//            NSDictionary *categoryDict = [newCategoryArray dictionaryAtIndex:i];
//            NSString *categoryId = [categoryDict nonemptyStringForKey:@"id"];
//            AthleticsCategory *category = [blockSelf categoryWithId:categoryId];
//            if (!category) {
//                retVal = REQUEST_CATEGORIES_CHANGED;
//                category = [blockSelf categoryWithDictionary:categoryDict];
//            }
//            if (!category.sortOrder || ![category.sortOrder isEqualToNumber:[NSNumber numberWithInt: i]]) {
//                category.sortOrder = [NSNumber numberWithInt: i];
//                retVal = REQUEST_CATEGORIES_CHANGED;
//            }
//        }
//        
//        [[CoreDataManager sharedManager] saveDataWithTemporaryMergePolicy:NSOverwriteMergePolicy];
//        
//        blockSelf.feedListModifiedDate = [NSDate date];
//        
//        
//    }
//        return retVal;
//    }];
//}

- (AthleticsCategory *)categoryWithDictionary:(NSDictionary *)categoryDict
{
    AthleticsCategory *category = nil;
    NSString *categoryId = [categoryDict nonemptyStringForKey:@"id"];
    if (categoryId) {
        category = [self categoryWithId:categoryId];
        if (!category) {
            category = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:AthleticsCategoryEntityName];
            category.moduleTag = self.moduleTag;
            category.category_id = categoryId;
        }
        category.title = [categoryDict nonemptyStringForKey:@"title"];
        category.category = [categoryDict nonemptyStringForKey:@"category"];
        category.path = [categoryDict nonemptyStringForKey:@"path"];
        category.ivar = [categoryDict nonemptyStringForKey:@"ivar"];
        category.isMainCategory = [NSNumber numberWithBool:YES];
        category.moreStories = [NSNumber numberWithInt:-1];
        category.nextSeekId = [NSNumber numberWithInt:0];
    }
    return category;
}

- (void)requestStoriesForCategory:(NSString *)categoryId afterId:(NSString *)afterId
{
    // TODO: signal that loading progress is 0
    if (![categoryId isEqualToString:self.currentCategory.category_id]) {
        self.currentCategory = [self categoryWithId:categoryId];
    }
    
    NSInteger start = 0;
    if (afterId) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier = %@", afterId];
        AthleticsStory *story = [[self.currentStories filteredArrayUsingPredicate:pred] lastObject];
        if (story) {
            NSInteger index = [self.currentStories indexOfObject:story];
            if (index != NSNotFound) {
                start = index;
            }
        }
    }
    
//    NSInteger moreStories = [self.currentCategory.moreStories integerValue];
//    NSInteger limit = (moreStories && moreStories < LOADMORE_LIMIT) ? moreStories : LOADMORE_LIMIT;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.currentCategory.ivar, self.currentCategory.category,nil];
    
    KGORequest *request = [[KGORequestManager sharedManager] requestWithDelegate:self
                                                                          module:self.moduleTag
                                                                            path:self.currentCategory.path
                                                                         version:1
                                                                          params:params];
    self.storiesRequest = request;
    
    __block AthleticsDataController *blockSelf = self;
    __block AthleticsCategory *category = self.currentCategory;
    [request connectWithCallback:^(id result) {
        NSDictionary *resultDict = (NSDictionary *)result;
        NSArray *stories = [resultDict arrayForKey:@"stories"];
        // need to bring category to local context
        // http://stackoverflow.com/questions/1554623/illegal-attempt-to-establish-a-relationship-xyz-between-objects-in-different-co
        AthleticsCategory *mergedCategory = nil;
        
        for (NSDictionary *storyDict in stories) {
            AthleticsStory *story = [blockSelf storyWithDictionary:storyDict];
//            NSMutableSet *mutableCategories = [story mutableSetValueForKey:@"categories"];
//            if (!mergedCategory) {
//                mergedCategory = (AthleticsCategory *)[[story managedObjectContext] objectWithID:[category objectID]];
//            }
//            if (mergedCategory) {
//                [mutableCategories addObject:mergedCategory];
//            }
//            story.categories = mutableCategories;
            story.categories = nil;
        }
        
        mergedCategory.moreStories = [resultDict numberForKey:@"moreStories"];
        mergedCategory.lastUpdated = [NSDate date];
        [[CoreDataManager sharedManager] saveData];
        
        return (NSInteger)[stories count];
    }];
}

- (AthleticsStory *)storyWithDictionary:(NSDictionary *)storyDict {
    // use existing story if it's already in the db
    NSString *GUID = [storyDict nonemptyStringForKey:AthleticsTagStoryId];
    AthleticsStory *story = [[CoreDataManager sharedManager] uniqueObjectForEntity:AthleticsStoryEntityName 
                                                                    attribute:@"identifier" 
                                                                        value:GUID];
    // otherwise create new
    if (!story) {
        story = (AthleticsStory *)[[CoreDataManager sharedManager] insertNewObjectForEntityForName:AthleticsStoryEntityName];
        story.identifier = GUID;
    }
    
    story.moduleTag = self.moduleTag;
    
    double unixtime = [[storyDict objectForKey:@"pubDate"] doubleValue];
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:unixtime];
    
    story.postDate = postDate;
    story.title = [storyDict nonemptyStringForKey:AthleticsTagTitle];
    story.link = [storyDict nonemptyStringForKey:AthleticsTagLink];
    story.author = [storyDict nonemptyStringForKey:AthleticsTagAuthor];
    story.summary = [storyDict nonemptyStringForKey:AthleticsTagSummary];
    story.hasBody = [NSNumber numberWithBool:[storyDict boolForKey:AthleticsTagHasBody]];
    story.body = [storyDict nonemptyStringForKey:AthleticsTagBody];
    NSDictionary *imageDict = [storyDict dictionaryForKey:AthleticsTagImage];
    if (imageDict) {
        // an old thumb may already exist
        // in which case do not create a new one
        if (!story.thumbImage) {
            story.thumbImage = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:AthleticsImageEntityName];
        }
        story.thumbImage.url = [imageDict nonemptyStringForKey:@"src"];
        story.thumbImage.thumbParent = story;
    } else {
        story.thumbImage = nil;
    }
    return story;
}



- (void)dealloc {
    self.moduleTag = nil;

    [super dealloc];
}
@end
