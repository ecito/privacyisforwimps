//
//  SGLayerTest.m
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
#import "SGClient.h"

static NSString* testingLayer = kSGTesting_Layer;

@interface SGLayerTest : SGLocationServiceTests {
    
}

@end


@implementation SGLayerTest


- (void) testLayerCreation
{
    SGLayer* layer = [[SGLayer alloc] initWithLayerName:testingLayer];
    STAssertTrue([layer.layerId isEqualToString:testingLayer], @"Layer names should be equal");
    STAssertTrue([[layer recordAnnotations] count] == 0, @"Records should be empty");
}

- (void) testLayerFetching
{
    SGLayer* layer = [[SGLayer alloc] initWithLayerName:kSGTesting_Layer];
    [self.locatorService addDelegate:layer];
    
    SGRecord* r = [self createRandomRecord];
    [layer addRecordAnnotation:r];
    STAssertTrue([[layer recordAnnotations] count] == 1, @"Should be one record in the layer.");
    
    [self addRecord:r responseId:[layer updateAllRecords]];
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];    
    WAIT_FOR_WRITE();
    
    double oldLat = r.latitude;
    r.latitude = 1000.0;

    [self retrieveRecord:r responseId:[layer retrieveAllRecords]];
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished]; 
    
    STAssertEquals(r.latitude, oldLat, @"The expected lat should be %f, but was %f", oldLat, r.latitude);
    [self deleteRecord:r responseId:[self.locatorService deleteRecordAnnotation:r]];
    
    
    [layer removeAllRecordAnnotations];
    STAssertNil([layer retrieveAllRecords], @"No records means no response id");

}

- (void) testAddingRecords
{
    SGLayer* layer = [[SGLayer alloc] initWithLayerName:testingLayer];
    
    int amount = 20;
    NSMutableArray* records = [NSMutableArray array];
    SGRecord* record = nil;
    for(int i = 0; i < amount; i++) {
        record = [self createRandomRecord];
        record.recordId = [NSString stringWithFormat:@"sg-%i", i];
        [records addObject:record];
    }
        
    [layer addRecordAnnotations:records];
    STAssertTrue([[layer recordAnnotations] count] == amount, @"The layer should have %i records registered.", amount);
    [self addRecord:records responseId:[layer updateAllRecords]];
    
    WAIT_FOR_WRITE();
    WAIT_FOR_WRITE();
    
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    [self retrieveRecord:records responseId:[self.locatorService retrieveRecordAnnotations:records]];
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    NSDictionary* geoJSONObject = (NSDictionary*)recentReturnObject;
    STAssertNotNil(geoJSONObject, @"Return object should not be nil.");
    
    NSArray* features = [geoJSONObject features];
    STAssertNotNil(features, @"Features should be defined.");
    STAssertTrue([records count] == 20, @"There should be 20 records returned.");
    
    [self deleteRecord:records responseId:[self.locatorService deleteRecordAnnotations:records]];
    
    STAssertFalse([layer recordAnnotationCount] == amount - 1, @"There should be %i records.", amount - 1);
    [layer removeRecordAnnotation:[records lastObject]];
    STAssertTrue([layer recordAnnotationCount] == amount - 1, @"There should be %i records.", amount - 1);
    
    [layer removeAllRecordAnnotations];
    STAssertTrue([[layer recordAnnotations] count] == 0, @"There should be no records.");
    STAssertNil([layer updateAllRecords], @"No records means no response id");
    
}

- (void) testLayerInformation
{
    NSString* layerName = kSGTesting_Layer;

    [self.requestIds setObject:[self expectedResponse:YES message:@"Should be able to retrieve layer information" record:[NSNull null]]
                        forKey:[self.locatorService layerInformation:layerName]];

    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    NSDictionary* jsonObject = (NSDictionary*)recentReturnObject;
    
    STAssertNotNil(jsonObject, @"There should be information about the layer.");
    STAssertTrue([layerName isEqualToString:[jsonObject objectForKey:@"name"]], @"The JSON object should not be missing a name.");
    
    
}

- (void) testNearby
{
    SGLayer* layer = [[SGLayer alloc] initWithLayerName:testingLayer];
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - 5.0;
    NSTimeInterval weekLater = [[NSDate date] timeIntervalSince1970] + 60 * 40;
    
    CLLocationCoordinate2D coords = {54.0,54.0};
    int amount = 20;
    NSMutableArray* records = [NSMutableArray array];
    SGRecord* record = nil;
    for(int i = 0; i < amount; i++) {
        record = [self createRandomRecord];
        record.recordId = [NSString stringWithFormat:@"sg-%i", i];
        
        if(i % 2) {
         
            record.latitude = coords.latitude;
            record.longitude = coords.longitude;
        }
        
        [records addObject:record];
    }
    
    [layer addRecordAnnotations:records];
    STAssertTrue([[layer recordAnnotations] count] == amount, @"The layer should have %i records registered.", amount);
    [self addRecord:records responseId:[layer updateAllRecords]];
    
    WAIT_FOR_WRITE();
    WAIT_FOR_WRITE();
    
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    
    [self retrieveRecord:records responseId:[layer retrieveRecordsForCoordinate:coords
                                                                         radius:10
                                                                          types:nil
                                                                          limit:25
                                                                          start:currentTime
                                                                            end:weekLater]];     
    
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    STAssertNotNil(recentReturnObject, @"Return object should not be nil");
    NSArray* features = (NSArray*)[recentReturnObject features];
    STAssertNotNil(features, @"Features should be returned");
    STAssertTrue([features count] >= 1, @"There should be more than 10 records that are returned.");
    
    [self retrieveRecord:records responseId:[layer retrieveRecordsForCoordinate:coords
                                                                         radius:10
                                                                          types:nil
                                                                          limit:25
                                                                          start:currentTime*2.0
                                                                            end:weekLater*2.0]];     
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
    features = [recentReturnObject features];
    STAssertTrue([features count] == 0, @"No features should be returned");
    
    [self deleteRecord:records responseId:[self.locatorService deleteRecordAnnotations:records]];
    [self.locatorService.operationQueue waitUntilAllOperationsAreFinished];
}

@end
