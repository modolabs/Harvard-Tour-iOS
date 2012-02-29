#import "AthleticsCategory.h"
#import "AthleticsMenu.h"
#import "AthleticsSchedule.h"
#import "AthleticsStory.h"
#import "CoreDataManager.h"

NSString * const AthleticsCategoryEntityName = @"AthleticsCategory";
@implementation AthleticsCategory

@dynamic category;
@dynamic category_id;
@dynamic isMainCategory;
@dynamic ivar;
@dynamic key;
@dynamic lastUpdated;
@dynamic moduleTag;
@dynamic moreStories;
@dynamic nextSeekId;
@dynamic path;
@dynamic sortOrder;
@dynamic title;
@dynamic url;
@dynamic menu;
@dynamic bookmarked;
@dynamic stories;
@dynamic schedules;

- (BOOL)isBookmarked {
    return [self.bookmarked boolValue];
}

- (void)addBookmark {
    if (![self isBookmarked]) {
        self.bookmarked = [NSNumber numberWithBool:YES];
        [[CoreDataManager sharedManager] saveDataWithTemporaryMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
}

- (void)removeBookmark {
    if ([self isBookmarked]) {
        self.bookmarked = [NSNumber numberWithBool:NO];
        [[CoreDataManager sharedManager] saveDataWithTemporaryMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
}

@end


