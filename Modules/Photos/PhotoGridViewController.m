#import "PhotoGridViewController.h"

@implementation PhotoGridViewController

@synthesize dataManager, album, photos;

- (void)layoutGridView
{
    NSMutableArray *views = [NSMutableArray array];
    for (Photo *aPhoto in self.photos) {
        MITThumbnailView *thumbView = [[[MITThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)] autorelease];
        thumbView.imageURL = aPhoto.thumbURL;
        thumbView.delegate = aPhoto;
        [thumbView loadImage];
        [views addObject:thumbView];
    }
    _iconGrid.icons = views;
}

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

- (void)dealloc
{
    self.album = nil;
    self.photos = nil;
    self.dataManager.delegate = nil;
    self.dataManager = nil;
    [pagerCollection release];
    [_gridPagerView release];
    [super dealloc];
}

- (void)photoDataManager:(PhotoDataManager *)manager didReceivePhotos:(NSArray *)photos
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
    self.photos = [self.album.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    [self layoutGridView];
}

- (void)iconGridFrameDidChange:(IconGrid *)iconGrid
{
    CGRect frame = _gridFooterContainer.frame;
    frame.origin.y = CGRectGetMinY(iconGrid.frame) + CGRectGetHeight(iconGrid.frame);
    _gridFooterContainer.frame = frame;

    // set scroll view content size
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"PhotoPagerControlView" owner:self options:nil];
    [_gridHeaderContainer addSubview:_gridPagerView];

    [[NSBundle mainBundle] loadNibNamed:@"PhotoPagerControlView" owner:self options:nil];
    [_gridFooterContainer addSubview:_gridPagerView];
    
    _iconGrid.padding = GridPaddingMake(16, 16, 16, 16);
    _iconGrid.spacing = GridSpacingMake(16, 16);
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
    self.photos = [self.album.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    if (self.photos.count < [self.album.totalItems integerValue]) {
        self.dataManager.delegate = self;
        [self.dataManager fetchPhotosForAlbum:self.album.identifier];
    }
    
    [self layoutGridView];
}

- (void)viewDidUnload
{
    [pagerCollection release];
    pagerCollection = nil;
    [_gridPagerView release];
    _gridPagerView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
