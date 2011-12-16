#import "AlbumListViewController.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "PhotoTableViewCell.h"
#import "MITThumbnailView.h"


@implementation AlbumListViewController

@synthesize albums = _albums, dataManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    self.albums = nil;
    self.dataManager.delegate = nil;
    self.dataManager = nil;
    [super dealloc];
}

- (void)photoDataManager:(PhotoDataManager *)manager didReceiveAlbums:(NSArray *)albums
{
    self.albums = albums;
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.rowHeight = 72;
    
    self.dataManager.delegate = self;
    [self.dataManager fetchAlbums];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PhotoTableViewCell" owner:self options:nil];
        cell = _photoCell;
    }
    
    PhotoAlbum *album = [self.albums objectAtIndex:indexPath.row];
    cell.thumbView.imageURL = album.thumbURL;
    cell.thumbView.delegate = album;
    [cell.thumbView loadImage];

    cell.titleLabel.text = album.title;
    NSInteger count = [album.totalItems integerValue];
    if (count) {
        // TODO: localize string
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@\n%d photos", album.type, count];
    } else {
        cell.subtitleLabel.text = album.type;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoAlbum *album = [self.albums objectAtIndex:indexPath.row];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:album, @"album", nil];
    [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameItemList
                           forModuleTag:self.dataManager.moduleTag
                                 params:params];
}

@end
