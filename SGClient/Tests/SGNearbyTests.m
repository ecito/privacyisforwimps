//
//  SGBenchMarkTests.m
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
//

#import "SGLocationServiceTests.h"

@interface SGNearbyTests : SGLocationServiceTests
{
    
}

@end

@implementation SGNearbyTests

- (void) testNearbyResponseTime
{
    CLLocationCoordinate2D coord = {10.0, 10.0};
    NSMutableArray* records = [NSMutableArray array];
    SGRecord* record = nil;
    for(int i = 0; i < 10; i++) 
    {
        record = [self createRandomRecord];
        record.latitude = coord.latitude;
        record.longitude = coord.longitude;
        [records addObject:record];
    }

    [self addRecord:records responseId:[self.locatorService updateRecordAnnotations:records]];    
    WAIT_FOR_WRITE();
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    for(int i = 0; i < 10; i++) {
    
        recentReturnObject = nil;
        [self retrieveRecord:records responseId:[self.locatorService retrieveRecordsForCoordinate:coord
                                                                                           radius:10
                                                                                           layer:kSGTesting_Layer
                                                                                            types:nil
                                                                                            limit:100]];     
        [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
        STAssertNotNil(recentReturnObject, @"Return object should not be nil");
        
        NSArray* features = [(NSDictionary*)recentReturnObject features];
        STAssertNotNil(features, @"Features should be returned");
        
        int size = [features count];
        for(int j = 1; j < size; j++) {
            
            double d1 = [[[features objectAtIndex:j - 1] objectForKey:@"distance"] doubleValue];
            double d2 = [[[features objectAtIndex:j] objectForKey:@"distance"] doubleValue];
            
            STAssertTrue(d1 <= d2, @"Distance should be ordered ( %f > %f )", d1, d2);
        }
        
        STAssertTrue([(NSArray*)recentReturnObject count] > 0, @"Return amount should be greater than zero.");
    }
    
    [self deleteRecord:records responseId:[self.locatorService deleteRecordAnnotations:records]];
}


- (void) testNearbyTime
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - 5.0;
    NSTimeInterval weekLater = [[NSDate date] timeIntervalSince1970] + 60 * 40;

    CLLocationCoordinate2D coord = {10.0, 10.0};
    NSMutableArray* records = [NSMutableArray array];
    SGRecord* record = nil;
    for(int i = 0; i < 10; i++) 
    {
        record = [self createRandomRecord];
        record.latitude = coord.latitude;
        record.longitude = coord.longitude;
        [records addObject:record];
    }    
        
    [self addRecord:records responseId:[self.locatorService updateRecordAnnotations:records]];    
    WAIT_FOR_WRITE();
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    [self retrieveRecord:records responseId:[self.locatorService retrieveRecordsForCoordinate:coord
                                                                                       radius:10
                                                                                       layer:kSGTesting_Layer
                                                                                        types:nil
                                                                                        limit:100
                                                                                        start:currentTime
                                                                                       end:weekLater]];     
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    STAssertNotNil(recentReturnObject, @"Return object should not be nil");
    NSArray* features = (NSArray*)[recentReturnObject features];
    STAssertNotNil(features, @"Features should be returned");
    STAssertTrue([features count] >= 1, @"There should be more than 10 records that are returned.");
    
    [self retrieveRecord:records responseId:[self.locatorService retrieveRecordsForCoordinate:coord
                                                                                       radius:10
                                                                                       layer:kSGTesting_Layer
                                                                                        types:nil
                                                                                        limit:100
                                                                                        start:currentTime*2.0
                                                                                    end:weekLater*2.0]];     
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    features = [recentReturnObject features];
    STAssertTrue([features count] == 0, @"No features should be returned");
    
    [self retrieveRecord:records responseId:[self.locatorService retrieveRecordsForCoordinate:coord
                                                                                       radius:10
                                                                                       layer:kSGTesting_Layer
                                                                                        types:nil
                                                                                        limit:100
                                                                                        start:currentTime
                                                                                          end:currentTime+120]];     
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    STAssertNotNil(recentReturnObject, @"Return object should not be nil");
    features = (NSArray*)[recentReturnObject features];
    STAssertNotNil(features, @"Features should be returned");
    STAssertTrue([features count] >= 1, @"There should be more than 10 records that are returned.");
    
    [self deleteRecord:records responseId:[self.locatorService deleteRecordAnnotations:records]];
}

- (void) testReverseGeocoder
{
    CLLocationCoordinate2D coords = {40.017294990861913, -105.27759999949176};
    NSString* responseId = [self.locatorService reverseGeocode:coords];
    
    [self.requestIds setObject:[self expectedResponse:YES message:@"Should return a reverse geocode object." record:[NSNull null]]
                        forKey:responseId];
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];

    STAssertNotNil(recentReturnObject, @"Reverse geocoder should return an object.");
    NSDictionary* properties = [(NSDictionary*)recentReturnObject objectForKey:@"properties"];
    STAssertNotNil(properties, @"GeoJSON object should contain a properties field.");
    STAssertTrue([properties count] == 9, @"There should be 9 key/value pairs in the properties dictionary.");
    STAssertTrue([[properties objectForKey:@"country"] isEqualToString:@"US"], @"The country code should be US.");
}

@end
