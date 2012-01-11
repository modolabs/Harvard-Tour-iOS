#import "IconGridScrollView.h"

@implementation IconGridScrollView

@synthesize dataSource, padding, spacing, maxColumns, alignment, iconSize;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.padding = GridPaddingZero;
        self.spacing = GridSpacingZero;
        self.maxColumns = 0;
        self.alignment = GridIconAlignmentLeft;
        self.iconSize = CGSizeMake(50, 50);

        _headerView = nil;
        _footerView = nil;
        _visibleIcons = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.padding = GridPaddingZero;
        self.spacing = GridSpacingZero;
        self.maxColumns = 0;
        self.alignment = GridIconAlignmentLeft;
        self.iconSize = CGSizeMake(50, 50);
        
        _headerView = nil;
        _footerView = nil;
        _visibleIcons = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

- (void)reloadData
{
    NSUInteger iconCount = [self.dataSource numberOfIconsInGrid:self];
    
    // calculate icons per row
    CGFloat maxRowWidth = CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right;
    CGFloat iconWidthPlusSpacing = self.iconSize.width + self.spacing.width;
    _iconsPerRow = (NSInteger)floorf(maxRowWidth / iconWidthPlusSpacing);
    if (maxRowWidth - _iconsPerRow * iconWidthPlusSpacing >= self.iconSize.width) {
        _iconsPerRow++;
    }
    
    // calculate how tall we are
    NSInteger numRows = iconCount / _iconsPerRow;
    if (iconCount % _iconsPerRow > 0) {
        numRows++;
    }
    CGFloat height = self.iconSize.height * numRows + self.spacing.height * (numRows - 1) + self.padding.top + self.padding.bottom;
    
    if (self.headerView) {
        height += CGRectGetHeight(self.headerView.frame);
    }
    
    if (self.footerView) {
        height += CGRectGetHeight(self.footerView.frame);
    }
    self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), height);

    [self setNeedsLayout];
}

- (void)iconTapped:(id)sender
{
    if ([sender isKindOfClass:[UIControl class]] && [self.dataSource respondsToSelector:@selector(gridView:didTapOnIconAtIndex:)]) {
        [self.dataSource gridView:self didTapOnIconAtIndex:[(UIControl *)sender tag] - 1];
    }
}
   
- (void)didMoveToSuperview
{
    if ([self superview]) {
        [self reloadData];
    }
}

- (void)layoutSubviews
{
    // figure out which icons need to be shown
    // create a buffer of 50%
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat skipHeight = self.contentOffset.y - self.padding.top - floor(viewHeight / 2);
    if (self.headerView) {
        skipHeight += CGRectGetHeight(self.headerView.frame);
    }
    CGFloat bottomY = skipHeight + CGRectGetHeight(self.bounds) + floor(viewHeight / 2);
    skipHeight = MAX(skipHeight, 0);
    
    CGFloat iconWidthPlusSpacing = self.iconSize.width + self.spacing.width;
    CGFloat iconHeightPlusSpacing = self.iconSize.height + self.spacing.height;
    NSInteger firstRow = (NSInteger)floorf(skipHeight / iconHeightPlusSpacing);
    NSInteger lastRow = (NSInteger)floorf(bottomY / iconHeightPlusSpacing);

    NSInteger startIndex = firstRow * _iconsPerRow;
    NSInteger numIcons = startIndex;
    NSInteger maxIcons = [self.dataSource numberOfIconsInGrid:self];
    NSInteger maxRows = maxIcons / _iconsPerRow + (maxIcons % _iconsPerRow > 0 ? 1 : 0);
    lastRow = MIN(lastRow, maxRows);
    
    CGFloat xOrigin = self.padding.left;
    if (self.alignment == GridIconAlignmentRight) {
        xOrigin = CGRectGetWidth(self.bounds) - self.padding.right - numIcons * iconWidthPlusSpacing + self.spacing.width;
    } else if (self.alignment == GridIconAlignmentCenter) {
        xOrigin = floor((CGRectGetWidth(self.bounds) - numIcons * iconWidthPlusSpacing + self.spacing.width) / 2);
    }
    
    CGFloat yOrigin = self.padding.top + iconHeightPlusSpacing * firstRow;
    if (self.headerView) {
        yOrigin += CGRectGetHeight(self.headerView.frame);
    }
    for (NSInteger row = firstRow; row <= lastRow; row++) {
        for (NSInteger i = 0; i < _iconsPerRow; i++) {
            NSInteger iconIndex = row * _iconsPerRow + i;
            if (iconIndex >= maxIcons) {
                break;
            }
            UIView *view = [self viewWithTag:iconIndex + 1]; // don't clash with other views
            if (!view) {
                CGRect frame = CGRectMake(xOrigin + iconWidthPlusSpacing * i,
                                          yOrigin,
                                          self.iconSize.width, self.iconSize.height);
                UIControl *control = [[[UIControl alloc] initWithFrame:frame] autorelease];
                UIView *view = [self.dataSource gridView:self viewForIconAtIndex:iconIndex];
                view.userInteractionEnabled = NO;
                [control addSubview:view];
                [control addTarget:self action:@selector(iconTapped:) forControlEvents:UIControlEventTouchUpInside];
                control.tag = iconIndex + 1;
                [self addSubview:control];
            }
            numIcons++;
        }
        yOrigin += iconHeightPlusSpacing;
    }
    
    if (_visibleIcons.location != NSNotFound) {
        // clear out non-visible views
        NSInteger startRemove = MIN(startIndex, _visibleIcons.location);
        NSInteger endRemove = MAX(startIndex, _visibleIcons.location);
        for (NSInteger i = startRemove; i < endRemove; i++) {
            UIView *view = [self viewWithTag:i];
            if (view) {
                [view removeFromSuperview];
            }
        }
        
        startRemove = MIN(startIndex + numIcons, _visibleIcons.location + _visibleIcons.length);
        endRemove = MAX(startIndex + numIcons, _visibleIcons.location + _visibleIcons.length);
        for (NSInteger i = startRemove; i < endRemove; i++) {
            UIView *view = [self viewWithTag:i];
            if (view) {
                [view removeFromSuperview];
            }
        }
    }

    if (numIcons) {
        _visibleIcons = NSMakeRange(startIndex, numIcons);
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (UIView *)headerView
{
    return _headerView;
}

- (UIView *)footerView
{
    return _footerView;
}

- (void)setHeaderView:(UIView *)headerView
{
    [_headerView release];
    _headerView = [headerView retain];
}

- (void)setFooterView:(UIView *)footerView
{
    [_footerView release];
    _footerView = [footerView retain];
}

- (void)dealloc {
    [super dealloc];
}


@end
