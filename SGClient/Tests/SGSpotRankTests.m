//
//  SGGeoJsonEncoderTests.m
//  SGClient
//
//  Copyright (c) 2009-2010, SimpleGeo
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, 
//  this list of conditions and the following disclaimer. Redistributions 
//  in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution.
//  
//  Neither the name of the SimpleGeo nor the names of its contributors may
//  be used to endorse or promote products derived from this software 
//  without specific prior written permission.
//   
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
#import "SGLocationServiceTests.h"

#import "SGLocationService.h"
#import "SGLocationTypes.h"

@interface SGSpotRankTests : SGLocationServiceTests {
    
}

- (void) assertValidTile:(NSDictionary *)geoJSONTile;

@end


@implementation SGSpotRankTests

- (void) testDayDensity
{
    CLLocationCoordinate2D coords = {40.017294990861913, -105.27759999949176};
    NSString* responseId = [self.locatorService densityForCoordinate:coords day:kSpotRank_Monday];
    
    [self.requestIds setObject:[self expectedResponse:YES message:@"Should return a colleciton of tiles." record:[NSNull null]]
                        forKey:responseId];
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    STAssertNotNil(recentReturnObject, @"Reverse geocoder should return an object.");
    STAssertTrue([recentReturnObject isFeatureCollection], @"Return object should be a collection of features");
    
                                                                                 
    NSArray* features = [recentReturnObject objectForKey:@"features"];
    for(NSDictionary* feature in features)
        [self assertValidTile:feature];    
}

- (void) testDayHourDensity
{
    CLLocationCoordinate2D coords = {40.017294990861913, -105.27759999949176};
    NSString* responseId = [self.locatorService densityForCoordinate:coords day:kSpotRank_Thursday hour:4];
    
    [self.requestIds setObject:[self expectedResponse:YES message:@"Should return a colleciton of tiles." record:[NSNull null]]
                        forKey:responseId];
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    STAssertNotNil(recentReturnObject, @"Reverse geocoder should return an object.");
    STAssertTrue([recentReturnObject isFeature], @"Return object should be a features");
    [self assertValidTile:recentReturnObject];
}

- (void) assertValidTile:(NSDictionary*)geoJSONTile
{
    STAssertTrue([geoJSONTile isFeature], @"Tile should be a feature");
    NSDictionary* properties = (NSDictionary*)[geoJSONTile properties];
    STAssertNotNil([properties objectForKey:@"worldwide_rank"], @"worldwide_rank should be a key in the properties dictionary");
    STAssertNotNil([properties objectForKey:@"trending_rank"], @"trending_rank should be a key in the properties dictionary");
}


@end
