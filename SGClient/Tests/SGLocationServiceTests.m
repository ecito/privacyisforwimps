//
//  SGLocationServiceTests.m
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

@implementation SGLocationServiceTests

@synthesize locatorService, requestIds, recentReturnObject;

- (void) setUp
{
        
    locatorService = [SGLocationService sharedLocationService];
    STAssertNotNil(locatorService, @"Shared locator service should be created.");
    
    requestIds = [[NSMutableDictionary alloc] init];
    
    [locatorService addDelegate:self];
    [locatorService setHTTPAuthorizer:[[SGOAuth alloc] initWithKey:kSGOAuth_Key secret:kSGOAuth_Secret]];
    [SGLocationService callbackOnMainThread:NO];
}

- (void) addRecord:(NSObject*)record responseId:(NSString*)responseId
{
    [self.requestIds setObject:[self expectedResponse:YES message:@"Should be able to add the record" record:record]
                        forKey:responseId];

}

- (void) deleteRecord:(NSObject*)record responseId:(NSString*)responseId
{
    [self.requestIds setObject:[self expectedResponse:YES
                                              message:@"Record should be deleted."
                                               record:record]
                        forKey:responseId];    
}

- (void) retrieveRecord:(NSObject*)record responseId:(NSString*)responseId
{
    [self.requestIds setObject:[self expectedResponse:YES message:@"Should be able to retrieve the record" record:record]
                        forKey:responseId];
}


#pragma mark -
#pragma mark SGLocationService delegate methods 
 

- (void) locationService:(SGLocationService*)service succeededForResponseId:(NSString*)responseId responseObject:(NSDictionary*)objects
{
    NSDictionary* expectedResponse = [requestIds objectForKey:responseId];

    if(expectedResponse && objects) {
        
        recentReturnObject = [objects retain];
        
        SGRecord* record = [expectedResponse objectForKey:@"record"];
        if(record) {
            
            BOOL success = [[expectedResponse objectForKey:@"success"] boolValue];
            NSString* message = [expectedResponse objectForKey:@"message"];
            STAssertTrue(success, message);

        }
        
        [requestIds removeObjectForKey:responseId];
    } 
}

- (void) locationService:(SGLocationService*)service failedForResponseId:(NSString*)requestId error:(NSError*)error
{
    NSDictionary* expectedResponse = [requestIds objectForKey:requestId];
    if(expectedResponse && error) {
    
        recentReturnObject = nil;
        BOOL success = [[expectedResponse objectForKey:@"success"] boolValue];
        NSString* message = [expectedResponse objectForKey:@"message"];
        STAssertFalse(success, @"%@ %@", message, error);
                      
        [requestIds removeObjectForKey:requestId];
    }
}


#pragma mark -
#pragma mark Helper methods 
 

- (NSDictionary*) expectedResponse:(BOOL)succeed message:(NSString*)message record:(NSObject*)record
{
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:succeed], @"success",
                                message, @"message",
                                record, @"record",
                                nil];
    
    return dictionary;
}
- (SGRecord*) createRandomRecord
{
    SGRecord* record = [[SGRecord alloc] init];
    record.type = kSGLocationType_Object;
    record.layer = kSGTesting_Layer;
    record.expires = [[NSDate distantFuture] timeIntervalSince1970];
    record.created = [[NSDate date] timeIntervalSince1970]; 
    record.longitude = rand() % 50 * (0.1231) + (double)(rand() % 50);
    record.latitude = rand() % 50 * (0.1721) + (double)(rand() % 50);
    record.recordId = [NSString stringWithFormat:@"%i", rand() % 10000000000];

    return record;
}

- (SGRecord*) createCopyOfRecord:(SGRecord*)record
{
    SGRecord* copy = [[SGRecord alloc] init];
    
    copy.type = record.type;
    copy.layer = record.layer;
    copy.expires = record.expires;
    copy.created = record.created;
    copy.longitude = record.longitude;
    copy.latitude = record.latitude;
    copy.recordId = record.recordId;    
    
    return copy;
}

- (BOOL) isRecord:(SGRecord*)firstRecord equalToRecord:(SGRecord*)secondRecord
{
    BOOL areEqual = YES;
    
    areEqual &= [firstRecord.recordId isEqualToString:secondRecord.recordId];
    areEqual &= firstRecord.longitude == secondRecord.longitude;
    areEqual &= firstRecord.latitude == secondRecord.latitude;    
    areEqual &= firstRecord.expires == secondRecord.expires;    
    areEqual &= firstRecord.created == secondRecord.created; 
    areEqual &= [firstRecord.type isEqualToString:secondRecord.type];
    areEqual &= [firstRecord.layer isEqualToString:secondRecord.layer];
        
    return areEqual;
}

- (void) tearDown
{
    
    [locatorService.operationQueue waitUntilAllOperationsAreFinished];
    STAssertTrue([[locatorService.operationQueue operations] count] == 0, @"There should be 0 operations in the queue");
    
    STAssertTrue([requestIds count] == 0, @"Tearing down tests too soon");
    [requestIds removeAllObjects];
    
    if(recentReturnObject) {
        
        [recentReturnObject release];
        recentReturnObject = nil;
        
    }
}

@end
