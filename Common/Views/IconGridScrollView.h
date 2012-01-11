#import <UIKit/UIKit.h>
#import "IconGrid.h"

@protocol IconGridScrollViewDataSource;

@interface IconGridScrollView : UIScrollView
{
    UIView *_headerView;
    UIView *_footerView;
    
    NSInteger _iconsPerRow;
    NSRange _visibleIcons;
}

@property (nonatomic, assign) id<IconGridScrollViewDataSource> dataSource;

@property (nonatomic) GridPadding padding;
@property (nonatomic) GridSpacing spacing;
@property (nonatomic) CGSize iconSize;
@property (nonatomic) NSInteger maxColumns; // specify 0 to fit as many columns as possible
@property (nonatomic) GridIconAlignment alignment;

@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) UIView *headerView;

- (void)reloadData;

@end

@protocol IconGridScrollViewDataSource <NSObject>

- (NSUInteger)numberOfIconsInGrid:(IconGridScrollView *)gridView;
- (UIView *)gridView:(IconGridScrollView *)gridView viewForIconAtIndex:(NSUInteger)index;

@optional

- (void)gridView:(IconGridScrollView *)gridView didTapOnIconAtIndex:(NSUInteger)index;

@end


