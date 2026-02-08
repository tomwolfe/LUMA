#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSRMBridge : NSObject

/**
 * Initializes the OSRM engine with a bundled .osrm file.
 * @param path The absolute path to the .osrm base file.
 */
- (nullable instancetype)initWithOSRMFile:(NSString *)path;

/**
 * Calculates a route between two coordinates.
 * @param start Starting coordinate.
 * @param end Destination coordinate.
 * @return A dictionary containing 'coordinates' (NSArray<NSValue *>) and 'instructions' (NSArray<NSString *>).
 */
- (NSDictionary *)calculateRouteFrom:(CLLocationCoordinate2D)start 
                                  to:(CLLocationCoordinate2D)end;

@end

NS_ASSUME_NONNULL_END
