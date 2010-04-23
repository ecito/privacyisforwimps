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
#import <SenTestingKit/SenTestingKit.h>

#import <Foundation/Foundation.h>
#import "SGClient.h"

@interface SGGeoJsonEncoderTests : SenTestCase {
    
}

@end


@implementation SGGeoJsonEncoderTests

- (void) validateJSONObject:(NSDictionary*)dictionary record:(SGRecord*)record
{
    STAssertTrue([[dictionary type] isEqualToString:@"FeatureCollection"], @"Initial record should be of type FeatureCollection.");
    
    NSDictionary* feature = [[dictionary features] objectAtIndex:0];
    NSLog([[feature geometry] description]);
    double value = [[[feature geometry] coordinates] latitude];
    STAssertTrue(value == record.latitude, @"Latitude should be %f, but was %f.", record.latitude, value);
    value = [[[feature geometry] coordinates] longitude];
    STAssertTrue(value == record.longitude, @"Longitude should be %f, but was %f.", record.longitude, value);
        
    value = [feature expires];
    STAssertTrue([feature expires] == record.expires, @"Expiration date should be %f, but was %f", record.expires, value);
    
    value = [feature created];
    STAssertTrue(value == record.created, @"Creation date should be %f, but was %f", record.created, value);
    
    STAssertTrue([[feature id] isEqualToString:record.recordId], @"Record ID should be %@", record.recordId);
    
    NSDictionary* properties = [feature properties];
    STAssertTrue([[properties objectForKey:@"me"] isEqualToString:@"you"], @"Me should map to you.");
    STAssertTrue([[properties objectForKey:@"number"] intValue] == 2, @"number should map to the integer value 2");    
}

- (void) testRecordAnnotationToGeoJSONObject
{
    SGRecord* record = [[SGRecord alloc] init];
    record.recordId = @"12345";
    record.layer = @"com.you.complete.me";
    record.latitude = 99.0;
    record.longitude = 90.0;
    record.expires = 99.0;
    record.created = 199.0;
    [record.properties setObject:@"you" forKey:@"me"];
    [record.properties setObject:[NSNumber numberWithInt:2] forKey:@"number"];
    
    NSDictionary* dictionary = [SGGeoJSONEncoder geoJSONObjectForRecordAnnotations:[NSArray arrayWithObject:record]];
    [self validateJSONObject:dictionary record:record];    
}

- (void) testGetRecordIdFromGeoJSONObject
{
    SGRecord* record = [[[SGRecord alloc] init] retain];
    record.recordId = @"sup123";

    NSDictionary* dictionary = [[SGGeoJSONEncoder geoJSONObjectForRecordAnnotations:[NSArray arrayWithObject:record]] retain];
    NSString* recordId = [[[dictionary features] objectAtIndex:0] id];
    STAssertTrue([recordId isEqualToString:record.recordId], @"The record id should be equal to %@, but was %@", record.recordId, recordId);
    [dictionary release];
}

@end
