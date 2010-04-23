//
//  SGLocationService.m
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
//  Created by Derek Smith.
//

#import "SGLocationTypes.h"
#import "SGLocationService.h"

#import "SGOAuth.h"
#import "SGRecord.h"

#import "SGAdditions.h"

#import "geohash.h"
#import "CJSONSerializer.h"
#import "NSDictionary_JSONExtensions.h"
#import "SGGeoJSONEncoder.h"

enum SGHTTPRequestParamater {
 
    kSGHTTPRequestParameter_Method = 0,
    kSGHTTPRequestParameter_File,
    kSGHTTPRequestParameter_Body,
    kSGHTTPRequestParameter_Params,
    kSGHTTPRequestParameter_ResponseId
    
};

typedef NSInteger SGHTTPRequestParamater;

static SGLocationService* sharedLocationService = nil;
static int requestIdNumber = 0;
static BOOL callbackOnMainThread = NO;

static id<SGAuthorization> _dummyAuthorizer = nil;

//static NSString* mainURL = @"http://ec2-204-236-158-42.us-west-1.compute.amazonaws.com";
static NSString* mainURL = @"http://api.simplegeo.com";
static NSString* apiVersion = @"0.1";

@interface SGLocationService (Private) <SGAuthorization>

- (NSString*) _getNextResponseId;

- (void) _pushInvocationWithArgs:(NSArray*)args;
- (void) _pushMultiInvovationWithArgs:(NSArray *)args;

- (NSObject*) _deleteRecord:(NSString*)recordId layer:(NSString*)layer push:(BOOL)push;
- (NSObject*) _retrieveRecord:(NSString*)recordId layer:(NSString*)layer push:(BOOL)push;
- (NSObject*) _updateRecord:(NSString*)recordId layer:(NSString*)layer coord:(CLLocationCoordinate2D)coord properties:(NSDictionary*)properties push:(BOOL)push;

- (NSArray*) _allTypes;

- (void) succeeded:(NSDictionary*)responseDictionary;
- (void) failed:(NSDictionary*)responseDictionary;

- (NSDictionary*) sendHTTPRequest:(NSString*)requestType 
                            toURL:(NSString*)file 
                             body:(NSData*)body
                       withParams:(NSDictionary*)params 
                        requestId:(NSString*)requestId
                         callback:(NSNumber*)callback;

- (void) sendMultipleHTTPRequest:(NSArray*)requestList
                       requestId:(NSString*)requestId;

@end

@implementation SGLocationService

@synthesize operationQueue;
@dynamic HTTPAuthorizer;

- (id) init
{
    if(self = [super init]) {
                
        operationQueue = [[NSOperationQueue alloc] init];
        
        _delegates = [[NSMutableArray alloc] init];
        
        if(!_dummyAuthorizer)
            _dummyAuthorizer = [[SGOAuth alloc] initWithKey:@"key" secret:@"secret"];
        
        [self setHTTPAuthorizer:_dummyAuthorizer];
        
        callbackOnMainThread = YES;
        
    }
    
    return self;
}

+ (SGLocationService*) sharedLocationService
{
    if(!sharedLocationService)
        sharedLocationService = [[[SGLocationService alloc] init] retain];
    
    return sharedLocationService;
}

+ (void) callbackOnMainThread:(BOOL)callback
{
    callbackOnMainThread = callback;
}

- (void) addDelegate:(id<SGLocationServiceDelegate>)delegate
{
    if([_delegates indexOfObject:delegate] == NSNotFound &&
                    [delegate conformsToProtocol:@protocol(SGLocationServiceDelegate)])
        [_delegates addObject:delegate];
}

- (void) removeDelegate:(id<SGLocationServiceDelegate>)delegate
{
    [_delegates removeObject:delegate];
}

- (NSArray*) _delegates
{
    return _delegates;
}

- (id<SGAuthorization>) HTTPAuthorizer
{
    return HTTPAuthorizer;
}

- (void) setHTTPAuthorizer:(id<SGAuthorization>)authorizer
{
    if(authorizer && [authorizer conformsToProtocol:@protocol(SGAuthorization)])
        HTTPAuthorizer = authorizer;
}

#pragma mark -
#pragma mark Record Information 
 

- (NSString*) deleteRecordAnnotation:(id<SGRecordAnnotation>)record
{
    return record ? [self deleteRecord:record.recordId layer:record.layer] : nil;
}

- (NSString*) deleteRecordAnnotations:(NSArray*)records
{
    NSMutableArray* requests = [NSMutableArray array];
    NSArray* request = nil;
    for(id<SGRecordAnnotation> recordAnnotation in records) {
        
        request = (NSArray*)[self _deleteRecord:recordAnnotation.recordId
                                layer:recordAnnotation.layer
                                 push:NO];
        
        if(!request)
            return nil;
        else
            [requests addObject:request];
        
    }
    
    NSString* requestId = nil;
    
    if([requests count]) {
        
        requestId = [self _getNextResponseId];
        [self _pushMultiInvovationWithArgs:[NSArray arrayWithObjects:requests, requestId, nil]];
        
    }
    
    return requestId;    
}

- (NSString*) deleteRecord:(NSString*)recordId layer:(NSString*)layer
{
    return (NSString*)[self _deleteRecord:recordId layer:layer push:YES];
}

- (NSObject*) _deleteRecord:(NSString*)recordId layer:(NSString*)layer push:(BOOL)push
{
    NSString* requestId = nil;
    NSArray* params = nil;
    if(recordId && ![recordId isKindOfClass:[NSNull class]] &&
       layer && ![layer isKindOfClass:[NSNull class]]) {
        
        requestId = [self _getNextResponseId];
        
        SGLog(@"SGLocationService - Deleting record <%@, %@> with response %@", recordId, layer, requestId);
        
        params = [NSArray arrayWithObjects:
                           @"DELETE",
                           [NSString stringWithFormat:@"/records/%@/%@.json", layer, recordId],
                           [NSNull null],
                           [NSNull null],
                           requestId,
                           nil];
        
        if(push)
            [self _pushInvocationWithArgs:params];
    }
    
    return push ? requestId : (NSObject*)params;    
}

- (NSString*) retrieveRecordAnnotation:(id<SGRecordAnnotation>)record
{
    return record ? [self retrieveRecordAnnotations:[NSArray arrayWithObject:record]] : nil;
}

- (NSString*) retrieveRecordAnnotations:(NSArray*)records
{
    if(!records || (records && ![records count]))
       return nil;

    NSMutableArray* recordIds = [NSMutableArray array];
    for(id<SGRecordAnnotation> annotation in records)
        [recordIds addObject:[annotation recordId]];
    
    NSString* responseId = nil;
    if([recordIds count]) {
        
        responseId = [self _getNextResponseId];
        
        NSString* layerId = [((id<SGRecordAnnotation>)[records lastObject]) layer];
     
        NSArray* params = [NSArray arrayWithObjects:
                           @"GET",
                           [NSString stringWithFormat:@"/records/%@/%@.json", layerId, [recordIds componentsJoinedByString:@","]],
                           [NSNull null],
                           [NSNull null],
                           responseId,
                           nil];
        
        SGLog(@"SGLocationService - Retrieving information for %i records with response %@", [records count], responseId);
        
        [self _pushInvocationWithArgs:params];
    }
    
    return responseId;    
}

- (NSString*) retrieveRecord:(NSString*)recordId layer:(NSString*)layer
{
    return (NSString*)[self _retrieveRecord:recordId layer:layer push:YES];
}

- (NSObject*) _retrieveRecord:(NSString*)recordId layer:(NSString*)layer push:(BOOL)push
{
    NSString* requestId = nil;
    NSArray* params = nil;
    if(recordId && ![recordId isKindOfClass:[NSNull class]] &&
       layer && ![layer isKindOfClass:[NSNull class]]) {
        
        requestId = [self _getNextResponseId];
        
        SGLog(@"SGLocationService - Retrieving record <%@, %@> with response %@", recordId, layer, requestId);
        
        params = [NSArray arrayWithObjects:
                           @"GET",
                           [@"/records" stringByAppendingFormat:@"/%@/%@.json", layer, recordId],
                           [NSNull null],
                            [NSNull null],
                           requestId,
                           nil];
        
        if(push)
            [self _pushInvocationWithArgs:params];
        
    }
    
    return push ? requestId : (NSObject*)params;    
}

- (NSString*) updateRecordAnnotation:(id<SGRecordAnnotation>)record
{
    NSString* requestId = nil;

    if(record)
        requestId = [self updateRecordAnnotations:[NSArray arrayWithObject:record]];
    
    return requestId;
}

- (NSString*) updateRecordAnnotations:(NSArray*)records
{
    // Bail if we have nothing.
    if(!records || (records && ![records count]))
        return nil;
    
    NSDictionary* geoJSONDictionary = [SGGeoJSONEncoder geoJSONObjectForRecordAnnotations:records];

    NSString* responseId = nil;
    if(geoJSONDictionary) {
     
        responseId = [self _getNextResponseId];
        NSData* body = [[[CJSONSerializer serializer] serializeObject:geoJSONDictionary] dataUsingEncoding:NSASCIIStringEncoding];
        
        NSString* layer = [((id<SGRecordAnnotation>)[records lastObject]) layer];
        
        NSArray* params = [NSArray arrayWithObjects:
                                                  @"POST",
                                                  [@"/records/" stringByAppendingFormat:@"%@.json",  layer],
                                                  body,
                                                  [NSNull null],
                                                  responseId,
                                                  nil];
        
        SGLog(@"SGLocationService - Updating %i records with response %@", [records count], responseId);
                                
        [self _pushInvocationWithArgs:params];
    }
    
    return responseId;
}

- (NSString*) updateRecord:(NSString*)recordId layer:(NSString*)layer coord:(CLLocationCoordinate2D)coord properties:(NSDictionary*)properties
{
    return (NSString*)[self _updateRecord:recordId layer:layer coord:coord properties:properties push:YES];   
}

- (NSObject*) _updateRecord:(NSString*)recordId layer:(NSString*)layer coord:(CLLocationCoordinate2D)coord properties:(NSDictionary*)properties push:(BOOL)push       
{
    NSArray* params = nil;
    NSString* requestId = nil;
    if(recordId && ![recordId isKindOfClass:[NSNull class]] &&
       layer && ![layer isKindOfClass:[NSNull class]]) {
        
        requestId = [self _getNextResponseId];
        
        SGLog(@"SGLocationService - Updating record <%@, %@> with response %@", recordId, layer, requestId);
        SGRecord* record = [[SGRecord alloc] init];
        record.recordId = recordId;
        record.layer = layer;
        record.properties = [NSMutableDictionary dictionaryWithDictionary:properties];
        record.latitude = coord.latitude;
        record.longitude = coord.longitude;
        
        NSDictionary* geoJSONObject = [SGGeoJSONEncoder geoJSONObjectForRecordAnnotation:record];
        
        NSData* body = [[[CJSONSerializer serializer] serializeObject:geoJSONObject] dataUsingEncoding:NSASCIIStringEncoding];
        
        params = [NSArray arrayWithObjects:
                           @"PUT",
                           [@"/records" stringByAppendingFormat:@"/%@/%@.json", layer, recordId],
                           body,
                           [NSNull null],
                           requestId,
                           nil];
        [record release];
        
        if(push)
            [self _pushInvocationWithArgs:params];
    }    
    
    return push ? requestId : (NSObject*)params;
}


- (NSString*) retrieveRecordAnnotationHistory:(id<SGRecordAnnotation>)record
{
    return [self retrieveRecordHistory:record.recordId layer:record.layer];
}

- (NSString*) retrieveRecordHistory:(NSString*)recordId layer:(NSString*)layer
{
    NSString* requestId = nil;
    
    if(recordId && ![recordId isKindOfClass:[NSNull class]] &&
       layer && ![layer isKindOfClass:[NSNull class]]) {
        
        requestId = [self _getNextResponseId];
        
        SGLog(@"SGLocationService - Retrieving history for record <%@, %@> with response %@", recordId, layer, requestId);        
        
        NSArray* params = [NSArray arrayWithObjects:
                           @"GET",
                           [NSString stringWithFormat:@"/records/%@/%@/history.json", layer, recordId],
                           [NSNull null],
                           [NSNull null],
                           requestId,
                           nil];
        
        [self _pushInvocationWithArgs:params];
    }
    
    return requestId;
}

#pragma mark -
#pragma mark Layer

- (NSString*) layerInformation:(NSString*)layerName
{
    NSString* responseId = [self _getNextResponseId];
    
    NSArray* params = [NSArray arrayWithObjects:
                       @"GET",
                       [NSString stringWithFormat:@"/layer/%@.json", layerName],
                       [NSNull null],
                       [NSNull null],
                       responseId,
                       nil];
    
    [self _pushInvocationWithArgs:params];
    
    return responseId;
}

#pragma mark -
#pragma mark Nearby
 

- (NSString*) retrieveRecordsForGeohash:(SGGeohash)region 
                                layer:(NSString*)layer
                                 types:(NSArray*)types
                                 limit:(NSInteger)limit
{
    return [self retrieveRecordsForGeohash:region 
                                    layer:layer
                                     types:types
                                     limit:limit
                                     start:0.0
                                    end:0.0];
}

- (NSString*) retrieveRecordsForGeohash:(SGGeohash)region 
                                 layer:(NSString*)layer
                                  types:(NSArray*)types
                                  limit:(NSInteger)limit
                                  start:(double)start
                                 end:(double)end;
{
    NSString* requestId = [self _getNextResponseId];
    
    if(!layer)
        return nil;
    
    char* geohash = geohash_encode(region.latitude, region.longitude, region.precision);
        
    if(![NSArray isValidNonEmptyArray:types])
        types = [self _allTypes];
    
    SGLog(@"SGLocationService - Retrieving records nearby %s with response %@ and layer %@", geohash, requestId, layer);
    
    NSMutableArray* params = [NSMutableArray arrayWithObjects:
                       @"GET",
                       [NSString stringWithFormat:@"/records/%@/nearby/%s.json", layer, geohash],
                       [NSNull null],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%i", limit], @"limit",
                        [types componentsJoinedByString:@","], @"types",
                        nil],
                       requestId,
                       nil];
    
    if(start > 0 && end > 0) {
        NSMutableDictionary* httpParams = [params objectAtIndex:kSGHTTPRequestParameter_Params];
        [httpParams setObject:[NSString stringWithFormat:@"%f", start] forKey:@"start"];
        [httpParams setObject:[NSString stringWithFormat:@"%f", end] forKey:@"end"];
    }    
    
    [self _pushInvocationWithArgs:params];
    
    return requestId;
    
}

- (NSString*) retrieveRecordsForCoordinate:(CLLocationCoordinate2D)coord
                                   radius:(double)radius
                                   layer:(NSString*)layer
                                    types:(NSArray*)types
                                    limit:(NSInteger)limit
{ 
    return [self retrieveRecordsForCoordinate:coord
                                       radius:radius
                                       layer:layer
                                        types:types
                                        limit:limit
                                        start:0.0
                                       end:0.0];
}

- (NSString*) retrieveRecordsForCoordinate:(CLLocationCoordinate2D)coord
                                    radius:(double)radius
                                    layer:(NSString*)layer
                                     types:(NSArray*)types
                                     limit:(NSInteger)limit
                                     start:(double)start
                                    end:(double)end
{
    if(!layer)
        return nil;
    
    if(![NSArray isValidNonEmptyArray:types])
        types = [self _allTypes];
    
    NSString* responseId = [self _getNextResponseId];   
    SGLog(@"SGLocationService - Retrieving records nearby %f,%f from %@ with response %@", coord.latitude, coord.longitude, 
                layer, responseId);
    
    NSArray* params = [NSArray arrayWithObjects:
                       @"GET",
                       [NSString stringWithFormat:@"/records/%@/nearby/%f,%f.json", layer, coord.latitude, coord.longitude],
                       [NSNull null],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%f", radius], @"radius",
                        [NSString stringWithFormat:@"%i", limit], @"limit",
                        [types componentsJoinedByString:@","], @"types",
                        nil],
                       responseId,
                       nil];
    
    if(start > 0 && end > 0) {
        NSMutableDictionary* httpParams = [params objectAtIndex:kSGHTTPRequestParameter_Params];
        [httpParams setObject:[NSString stringWithFormat:@"%f", start] forKey:@"start"];
        [httpParams setObject:[NSString stringWithFormat:@"%f", end] forKey:@"end"];
    }    
    
    [self _pushInvocationWithArgs:params];
    
    return responseId;        
}

#pragma mark -
#pragma mark Features


- (NSString*) reverseGeocode:(CLLocationCoordinate2D)coord
{
    NSString* responseId = [self _getNextResponseId];
    
    SGLog(@"SGLocationService - Reverse geocoding %f,%f with response %@", coord.latitude, coord.longitude, responseId);
    
    NSArray* params = [NSArray arrayWithObjects:
                       @"GET",
                       [NSString stringWithFormat:@"/nearby/address/%f,%f.json", coord.latitude, coord.longitude],
                       [NSNull null],
                       [NSNull null],
                       responseId,
                       nil];
    [self _pushInvocationWithArgs:params];
    
    return responseId;
}

- (NSString*) densityForCoordinate:(CLLocationCoordinate2D)coord day:(NSString*)day hour:(int)hour
{
    if(hour < 0 || hour > 24)
        return [self densityForCoordinate:coord day:day];
    
    if(!day)
        day = kSpotRank_Monday;
    
    NSString* responseId = [self _getNextResponseId];
    
    SGLog(@"SGLocationService - SpotRank %f,%f on day %@ with response %@", coord.latitude, coord.longitude, day, responseId);
    NSArray* params = [NSArray arrayWithObjects:
                            @"GET",
                            [NSString stringWithFormat:@"/density/%@/%i/%f,%f.json", day, hour, coord.latitude, coord.longitude],
                            [NSNull null],
                            [NSNull null],
                            responseId,
                       nil];
    
    [self _pushInvocationWithArgs:params];
    
    return responseId;                   
}

- (NSString*) densityForCoordinate:(CLLocationCoordinate2D)coord day:(NSString*)day
{
    NSString* responseId = [self _getNextResponseId];
    
    if(!day)
        day = kSpotRank_Monday;

    SGLog(@"SGLocationService - SpotRank %f,%f on day %@ with response %@", coord.latitude, coord.longitude, day, responseId);    
    NSArray* params = [NSArray arrayWithObjects:
                       @"GET",
                       [NSString stringWithFormat:@"/density/%@/%f,%f.json", day, coord.latitude, coord.longitude],
                       [NSNull null],
                       [NSNull null],
                       responseId,
                       nil];
    
    [self _pushInvocationWithArgs:params];
    
    return responseId;                   
}

#pragma mark -
#pragma mark HTTP Request methods 
 

- (void) succeeded:(NSDictionary*)responseDictionary
{
    NSString* requestId = [[responseDictionary objectForKey:@"requestId"] retain];
    NSObject* responseObject = [[responseDictionary objectForKey:@"responseObject"] retain];

    SGLog(@"SGLocationService - Request %@ succeeded with %i queued operations", requestId, [self.operationQueue.operations count]);
    
    NSArray* delegates = [NSArray arrayWithArray:_delegates];
    for(id<SGLocationServiceDelegate> delegate in delegates)
        [delegate locationService:self succeededForResponseId:requestId responseObject:responseObject];
    
    [requestId release];
    [responseObject release];
}

- (void) failed:(NSDictionary*)responseDictionary
{
    NSString* requestId = [[responseDictionary objectForKey:@"requestId"] retain];
    NSError* error = [[responseDictionary objectForKey:@"error"] retain];
    
    SGLog(@"SGLocationService - Request failed: %@ Error: %@", requestId, [error description]);

    NSArray* delegates = [NSArray arrayWithArray:_delegates];
    for(id<SGLocationServiceDelegate> delegate in delegates)
        [delegate locationService:self failedForResponseId:requestId error:error];
    
    [requestId release];
    [error release];
}

- (void) sendMultipleHTTPRequest:(NSArray*)requestList
                                requestId:(NSString*)requestId
{
    
    NSMutableArray* responses = [NSMutableArray array];
    NSArray* request = nil;
    NSDictionary* response = nil;
    for(int i = 0; i < [requestList count]; i++) {

        request = [requestList objectAtIndex:i];
        
       response=  [self sendHTTPRequest:[request objectAtIndex:kSGHTTPRequestParameter_Method]
                                  toURL:[request objectAtIndex:kSGHTTPRequestParameter_File]
                                   body:[request objectAtIndex:kSGHTTPRequestParameter_Body]
                             withParams:[request objectAtIndex:kSGHTTPRequestParameter_Params]
                              requestId:[request objectAtIndex:kSGHTTPRequestParameter_ResponseId]
                               callback:[NSNumber numberWithBool:NO]];

        if([response objectForKey:@"error"])
            break;
        else
            [responses addObject:[response objectForKey:@"responseObject"]];
    }
    
    
    NSMutableDictionary* responseObject = [NSMutableDictionary dictionary];
    [responseObject setObject:requestId forKey:@"requestId"];
    
    // If the response is not equal to the amount of requests sent,
    // then there was an error and the delegate should be notified.
    if([responses count] != [requestList count]) {
        
        [responseObject setObject:[response objectForKey:@"error"] forKey:@"error"];
                        
        if(callbackOnMainThread)
            [self performSelectorOnMainThread:@selector(failed:) withObject:responseObject waitUntilDone:NO];
        else
            [self failed:responseObject];
        
        
    } else {
        
        [responseObject setObject:responses forKey:@"responseObject"];
        
        if(callbackOnMainThread)
            [self performSelectorOnMainThread:@selector(succeeded:) withObject:responseObject waitUntilDone:NO];
        else
            [self succeeded:responseObject];                
        
    }
}

- (NSDictionary*) sendHTTPRequest:(NSString*)requestType
                            toURL:(NSString*)file 
                             body:(NSData*)body
                       withParams:(NSDictionary*)params 
                        requestId:(NSString*)requestId
                         callback:(NSNumber*)callback
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    if(!HTTPAuthorizer)
        HTTPAuthorizer = self;
    
    if(params && [params isKindOfClass:[NSNull class]])
        params = nil;
    
    if(body && [body isKindOfClass:[NSNull class]])
        body = nil;
    
    file = [NSString stringWithFormat:@"/%@%@", apiVersion, file];

    NSDictionary* returnDictionary = [HTTPAuthorizer dataAtURL:mainURL
                                                         file:file
                                                          body:body
                                                   parameters:params
                                                   httpMethod:requestType];
    

    NSData* data = [returnDictionary objectForKey:@"data"];
    NSHTTPURLResponse* response = [returnDictionary objectForKey:@"response"];
    NSError* error = [returnDictionary objectForKey:@"error"];
    
    NSDictionary* jsonObject = nil;;
        
    if(data && ![data isKindOfClass:[NSNull class]]) {
        
        NSError* error = nil;
        jsonObject = [NSDictionary dictionaryWithJSONData:data error:&error];
                
        if(error)
            SGLog(@"SGLocationService - Error occurred while parsing GeoJSON object: %@", [error description]);
    }
    

    if(jsonObject && error && ![error isKindOfClass:[NSNull class]])
        error = [NSError errorWithDomain:[jsonObject objectForKey:@"message"]
                                    code:[[jsonObject objectForKey:@"code"] intValue]
                                userInfo:nil];

    if((!error || (error && [error isKindOfClass:[NSNull class]])) && response && ![response isKindOfClass:[NSNull class]]) {
        
        NSInteger responseCode = [response statusCode];

        // Make sure we get 20x
        if((responseCode - 200) >= 0 && (responseCode - 200) < 100) {

            NSDictionary* responseObject = [NSDictionary dictionaryWithObjectsAndKeys:
                                      requestId, @"requestId",
                                      jsonObject ? jsonObject : (NSObject*)[NSDictionary dictionary], @"responseObject",
                                            [NSNumber numberWithDouble:time], @"time", nil];

            
            if([callback boolValue]) {
            
                if(callbackOnMainThread)
                    [self performSelectorOnMainThread:@selector(succeeded:) withObject:responseObject waitUntilDone:NO];
                else
                    [self succeeded:responseObject];
            }

            return responseObject;
        }                 
    }
    
    if(!error || (error && [error isKindOfClass:[NSNull class]]))
       error = [NSError errorWithDomain:jsonObject ? [jsonObject objectForKey:@"message"] : @"Unknown"
                                   code:jsonObject ? [[jsonObject objectForKey:@"code"] intValue] : -1
                               userInfo:nil];
    
    
    NSDictionary* responseObject = [NSDictionary dictionaryWithObjectsAndKeys:requestId, @"requestId", error, @"error", nil];
     
    if([callback boolValue]) {
        
        if(callbackOnMainThread)
            [self performSelectorOnMainThread:@selector(failed:) withObject:responseObject waitUntilDone:NO];
        else
            [self failed:responseObject];
    }
    
    return responseObject;
}

- (void) _pushMultiInvovationWithArgs:(NSArray*)args
{
    
    NSMethodSignature* methodSignature = [self methodSignatureForSelector:@selector(sendMultipleHTTPRequest:requestId:)];
    NSInvocation* httpRequestInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [httpRequestInvocation setSelector:@selector(sendMultipleHTTPRequest:requestId:)];
    [httpRequestInvocation setTarget:self];    
    
    NSString* arg;
	for(int i = 0; i < [args count]; i++) {
        
        arg = [args objectAtIndex:i];
		[httpRequestInvocation setArgument:&arg atIndex:i + 2];
    }
	
	NSInvocationOperation* opertaion = [[[NSInvocationOperation alloc] initWithInvocation:httpRequestInvocation] autorelease];
	[operationQueue addOperation:opertaion];			
    
}

- (void) _pushInvocationWithArgs:(NSArray*)args 
{	
    
    NSMethodSignature* methodSignature = [self methodSignatureForSelector:@selector(sendHTTPRequest:toURL:body:withParams:requestId:callback:)];
    NSInvocation* httpRequestInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [httpRequestInvocation setSelector:@selector(sendHTTPRequest:toURL:body:withParams:requestId:callback:)];
    [httpRequestInvocation setTarget:self];    

    NSString* arg;
	for(int i = 0; i < [args count]; i++) {
        
        arg = [args objectAtIndex:i];
		[httpRequestInvocation setArgument:&arg atIndex:i + 2];
    }
    
    NSNumber* no = [NSNumber numberWithBool:YES];
    [httpRequestInvocation setArgument:&no atIndex:[args count] + 2];

	NSInvocationOperation* opertaion = [[[NSInvocationOperation alloc] initWithInvocation:httpRequestInvocation] autorelease];
	[operationQueue addOperation:opertaion];			
}

#pragma mark -
#pragma mark Helper methods 

- (NSArray*) _allTypes
{
    return [NSArray arrayWithObjects:kSGLocationType_Place, kSGLocationType_Person, kSGLocationType_Object,
            kSGLocationType_Note, kSGLocationType_Audio, kSGLocationType_Video, nil];
}


- (NSString*) _getNextResponseId
{
    requestIdNumber++;
    return [NSString stringWithFormat:@"%i", requestIdNumber];
}

- (void) dealloc
{
    [_delegates release];
    [operationQueue release];
    
    [super dealloc];
}

@end
