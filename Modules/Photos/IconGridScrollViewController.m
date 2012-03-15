#import "IconGridScrollViewController.h"
#import "UIKit+KGOAdditions.h"
#import "PhotoAlbum.h"
#import "KGOTheme.h"
#import "KGOAppDelegate+ModuleAdditions.h"

@implementation IconGridScrollViewController

@synthesize gridView;
@synthesize albums = _albums;
@synthesize dataManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gridView.dataSource = self;
    self.gridView.iconSize = CGSizeMake(100, 150);
    self.gridView.spacing = CGSizeMake(20, 20);
    self.gridView.padding = GridPaddingMake(20, 20, 20, 20);
    
    self.dataManager.delegate = self;
    [self.dataManager fetchAlbums];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return IS_IPAD_OR_PORTRAIT(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

#pragma mark -

- (NSUInteger)numberOfIconsInGrid:(IconGridScrollView *)gridView
{
    return self.albums.count;
}

- (UIView *)gridView:(IconGridScrollView *)gridView viewForIconAtIndex:(NSUInteger)index
{
    PhotoAlbum *album = [self.albums objectAtIndex:index];
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 150)] autorelease];
    MITThumbnailView *thumbView = [[[MITThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
    thumbView.imageURL = album.thumbURL;
    thumbView.imageData = album.thumbData;
    thumbView.delegate = album;
    [thumbView loadImage];
    [view addSubview:thumbView];
    
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(2, 102, 96, 18)] autorelease];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = album.title;
    titleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyMediaListSubtitle];
    [view addSubview:titleLabel];

    UILabel *subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(2, 120, 96, 30)] autorelease];
    subtitleLabel.textAlignment = UITextAlignmentCenter;
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyMediaListSubtitle];
    subtitleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertyMediaListSubtitle];
    subtitleLabel.numberOfLines = 2;
    subtitleLabel.text = [album subtitle];
    [view addSubview:subtitleLabel];
    
    return view;
}

- (void)gridView:(IconGridScrollView *)gridView didTapOnIconAtIndex:(NSUInteger)index
{
    PhotoAlbum *album = [self.albums objectAtIndex:index];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:album, @"album", nil];
    [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameItemList
                           forModuleTag:self.dataManager.moduleTag
                                 params:params];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)photoDataManager:(PhotoDataManager *)manager didReceiveAlbums:(NSArray *)albums
{
    self.albums = albums;
    [self.gridView reloadData];
}

@end
