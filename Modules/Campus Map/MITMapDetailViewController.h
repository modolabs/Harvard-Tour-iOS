#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TabViewControl.h"
#import "JSONAPIRequest.h"
#import "ConnectionWrapper.h"


@class ArcGISMapAnnotation;
@class CampusMapViewController;

@interface MITMapDetailViewController : UIViewController <ConnectionWrapperDelegate, TabViewControlDelegate, JSONAPIDelegate> {

	// tab controller for which we are a delegate.
	IBOutlet TabViewControl* _tabViewControl;
	
	IBOutlet UIButton* _bookmarkButton;
	
	// label for the name
	IBOutlet UILabel* _nameLabel;
	
	// label for the second line of the name;
	IBOutlet UILabel* _nameLabel2;
	
	// label for the location
	IBOutlet UILabel* _locationLabel;

	// label for the query
	IBOutlet UILabel* _queryLabel;
	
	// container view for the tabbed contents. 
	IBOutlet UIView* _tabViewContainer;
	
	// map view
	IBOutlet MKMapView* _mapView;
	IBOutlet UIButton* _mapViewContainer;

	//
	// BUILDING IMAGE
	//
	
	// view for the building image info
	IBOutlet UIView* _buildingView;
	
	// image view for the building
	IBOutlet UIImageView* _buildingImageView;
	
	// label describing the image
	IBOutlet UILabel* _buildingImageDescriptionLabel;
	
	
	//
	// WHAT's HERE
	// 
	// view for what's here info
	IBOutlet UIView* _whatsHereView;
	
	//
	// LOADING IMAGE VIEW
	//
	IBOutlet UIView* _loadingImageView;
	
	//
	// LOADING RESULT VIEW
	//
	IBOutlet UIView* _loadingResultView;
	
	//
	// MAIN CONTENT SCROLL VIEW
	//
	IBOutlet UIScrollView* _scrollView;
	
	// array of views that appear in our tabs, indexed by tab index. 
	NSMutableArray* _tabViews;
	
	// the search result we are attempting to display
	ArcGISMapAnnotation *_annotation;
	
	// updated search result details. Not the annotation we started with, but based on its ID. 
	ArcGISMapAnnotation *_annotationDetails;
	
	CampusMapViewController* _campusMapVC;
	
	NSString* _queryText;
	
	CGFloat _tabViewContainerMinHeight;
	
	// Connection Wrapper used for loading building images
	ConnectionWrapper *imageConnectionWrapper;
	
	// network activity status for loading building image
	BOOL networkActivity;
	
	// to persist saved state
	int _startingTab;
}

@property (nonatomic, retain) ArcGISMapAnnotation *annotation;
@property (nonatomic, retain) ArcGISMapAnnotation *annotationDetails;

@property (nonatomic, assign) CampusMapViewController* campusMapVC;

@property (nonatomic, retain) NSString* queryText;

@property (nonatomic, retain) ConnectionWrapper *imageConnectionWrapper;
@property int startingTab;

// user tapped on the map thumbnail
-(IBAction) mapThumbnailPressed:(id)sender;

// user tapped the bookmark/favorite button
-(IBAction) bookmarkButtonTapped;

@end
