#import "PhotosModule.h"
#import "AlbumListViewController.h"
#import "PhotoDataManager.h"

@implementation PhotosModule

- (PhotoDataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [[PhotoDataManager alloc] init];
        _dataManager.moduleTag = self.tag;
    }
    return _dataManager;
}

- (NSArray *)objectModelNames {
    return [NSArray arrayWithObject:@"Photos"];
}

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params
{
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        //AlbumListViewController *albumVC = [[[AlbumListViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        AlbumListViewController *albumVC = [[[AlbumListViewController alloc] initWithNibName:@"AlbumListViewController"
                                                                                      bundle:nil] autorelease];
        albumVC.dataManager = [self dataManager];
        vc = albumVC;
    }
    return vc;
}

@end
