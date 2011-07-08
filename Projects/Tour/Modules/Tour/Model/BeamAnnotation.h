//
//  BeamAnnotation.h
//  Tour
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BeamAnnotation : NSObject <MKAnnotation>  {
    CLLocationCoordinate2D coordinate;
    CGFloat latitude;
    CGFloat longitude;
}

@property (assign) CGFloat latitude;
@property (assign) CGFloat longitude;

@end
