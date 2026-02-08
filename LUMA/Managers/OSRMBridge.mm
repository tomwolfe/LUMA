#import "OSRMBridge.h"

// OSRM Headers (Assume cross-compiled and in header search path)
#ifdef __cplusplus
#include <osrm/osrm.hpp>
#include <osrm/engine_config.hpp>
#include <osrm/route_parameters.hpp>
#include <osrm/status.hpp>
#include <osrm/coordinate.hpp>
#include <osrm/json_container.hpp>
#endif

@implementation OSRMBridge {
    std::unique_ptr<osrm::OSRM> _osrm;
}

- (instancetype)initWithOSRMFile:(NSString *)path {
    self = [super init];
    if (self) {
        osrm::EngineConfig config;
        config.storage_config = {path.UTF8String};
        config.use_shared_memory = false;
        // Optimization: Use Contraction Hierarchies (CH) for fast mobile routing
        config.algorithm = osrm::EngineConfig::Algorithm::CH;
        
        try {
            _osrm = std::make_unique<osrm::OSRM>(config);
        } catch (const std::exception& e) {
            NSLog(@"Failed to initialize OSRM: %s", e.what());
            return nil;
        }
    }
    return self;
}

- (NSDictionary *)calculateRouteFrom:(CLLocationCoordinate2D)start 
                                  to:(CLLocationCoordinate2D)end {
    if (!_osrm) return @{};

    osrm::RouteParameters params;
    // OSRM expects {longitude, latitude}
    params.coordinates.push_back({osrm::util::FloatCoordinate{start.longitude}, 
                                  osrm::util::FloatCoordinate{start.latitude}});
    params.coordinates.push_back({osrm::util::FloatCoordinate{end.longitude}, 
                                  osrm::util::FloatCoordinate{end.latitude}});
    
    // Request full geometry and steps for instructions
    params.geometries = osrm::RouteParameters::GeometriesType::GeoJSON;
    params.overview = osrm::RouteParameters::OverviewType::Full;
    params.steps = true;
    
    osrm::engine::api::ResultT result = osrm::json::Object();
    const auto status = _osrm->Route(params, result);
    
    if (status != osrm::Status::Ok) {
        return @{};
    }
    
    auto &json_result = std::get<osrm::json::Object>(result);
    auto &routes = json_result.values["routes"].get<osrm::json::Array>();
    
    if (routes.values.empty()) return @{};
    
    auto &route = routes.values[0].get<osrm::json::Object>();
    
    // Parse Coordinates
    auto &geometry = route.values["geometry"].get<osrm::json::Object>();
    auto &coordinates = geometry.values["coordinates"].get<osrm::json::Array>();
    
    NSMutableArray<NSValue *> *routePoints = [NSMutableArray array];
    for (const auto &coord : coordinates.values) {
        auto &point = coord.get<osrm::json::Array>();
        double lon = point.values[0].get<osrm::json::Number>().value;
        double lat = point.values[1].get<osrm::json::Number>().value;
        
        CLLocationCoordinate2D c = CLLocationCoordinate2DMake(lat, lon);
        [routePoints addObject:[NSValue valueWithBytes:&c objCType:@encode(CLLocationCoordinate2D)]];
    }
    
    // Parse Instructions
    NSMutableArray<NSString *> *instructions = [NSMutableArray array];
    auto &legs = route.values["legs"].get<osrm::json::Array>();
    for (const auto &leg_val : legs.values) {
        auto &leg = leg_val.get<osrm::json::Object>();
        auto &steps = leg.values["steps"].get<osrm::json::Array>();
        for (const auto &step_val : steps.values) {
            auto &step = step_val.get<osrm::json::Object>();
            auto &maneuver = step.values["maneuver"].get<osrm::json::Object>();
            
            // OSRM provides instructions in several ways. We'll try to find a descriptive one.
            // In a production app, you'd use osrm-text-instructions for localization.
            if (maneuver.values.count("instruction")) {
                std::string instr = maneuver.values.at("instruction").get<osrm::json::String>().value;
                [instructions addObject:[NSString stringWithUTF8String:instr.c_str()]];
            } else {
                // Fallback for demo: type and modifier
                std::string type = maneuver.values.at("type").get<osrm::json::String>().value;
                std::string modifier = "";
                if (maneuver.values.count("modifier")) {
                    modifier = maneuver.values.at("modifier").get<osrm::json::String>().value;
                }
                NSString *instr = [NSString stringWithFormat:@"%s %s", type.c_str(), modifier.c_str()];
                [instructions addObject:instr];
            }
        }
    }
    
    return @{
        @"coordinates": routePoints,
        @"instructions": instructions
    };
}

@end
