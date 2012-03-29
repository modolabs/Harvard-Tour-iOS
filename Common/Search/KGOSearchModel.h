#import <UIKit/UIKit.h>
#import "KGOTableViewController.h"
#import "KGOTheme.h"

@protocol KGOListItem <NSObject> // compatible with MKAnnotation

- (NSString *)identifier;
- (NSString *)title;

@optional

- (NSString *)subtitle;

@end

#pragma mark -

@protocol KGOSearchResult <KGOListItem>

- (BOOL)isBookmarked;
- (void)addBookmark;
- (void)removeBookmark;

- (ModuleTag *)moduleTag;

@optional

- (UIView *)iconView;         // image to use in table/grid views
- (UIImage *)iconImage;
- (UIImage *)annotationImage; // image to use for map pin
- (NSString *)accessoryType;

- (BOOL)didGetSelected:(id)selector;

@end

#pragma mark -

@protocol KGOCategory <KGOListItem>

- (id<KGOCategory>)parent; // nil if this is top level category.
- (NSArray *)children;     // an array of id<KGOCategory> objects. may be nil.
- (NSArray *)items;        // an array of id<KGOSearchResult> objects. may be nil.

@optional

- (ModuleTag *)moduleTag;

@end

#pragma mark -

@protocol KGOSearchResultsHolder <NSObject>

- (void)receivedSearchResults:(NSArray *)results forSource:(ModuleTag *)source;
- (NSArray *)results;

@end
