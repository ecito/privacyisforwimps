//
//  SGOAuth.m
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

#import "SGOAuth.h"

#import "SGLocationService.h"

#import "SGAdditions.h"

#import "hmac.h"
#import "Base64Transcoder.h"

@interface SGOAuth (Private) 

- (NSString*) _signatureBaseStringFromRequest:(NSURLRequest*)request params:(NSDictionary*)params;
- (NSString*) _normalizeRequestParams:(NSDictionary*)params;
- (NSString*) _generateTimestamp;
- (NSString*) _generateNonce;
- (NSString*) signText:(NSString *)text withSecret:(NSString *)secret;

@end

@implementation SGOAuth 

@synthesize consumerKey, secretKey;

- (id) initWithKey:(NSString*)key secret:(NSString*)secret
{
    if(!key || !secret)
        return nil;
    
    if(self = [super init]) {
        
        SGLog(@"SGOAuth - creating token with secret %@ and consumer %@", secret, key);
        consumerKey = [key retain];
        secretKey = [secret retain];
        
        oAuthParams = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                key, @"oauth_consumer_key",
                                                @"HMAC-SHA1", @"oauth_signature_method", 
                                                @"1.0", @"oauth_version", nil] retain];
        
                
    }
    
    return self;
}

+ (SGOAuth*) resume
{
    SGOAuth* oauth = nil;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* key = [defaults objectForKey:@"SGOAuthKey"];
    NSString* secret = [defaults objectForKey:@"SGOAuthSecret"];
    if(key && secret)
        oauth = [[[SGOAuth alloc] initWithKey:key secret:secret] autorelease];
    
    return oauth;
}

- (void) save
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:consumerKey forKey:@"SGOAuthKey"];
    [defaults setValue:secretKey forKey:@"SGOAuthSecret"];            
    [defaults synchronize];
}

- (void) unSave
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"SGOAuthKey"];
    [defaults removeObjectForKey:@"SGOAuthSecret"];
    [defaults synchronize];
}

#pragma mark -
#pragma mark SGAuthorization methods 
 
- (NSDictionary*) dataAtURL:(NSString*)url 
                       file:(NSString*)file
                       body:(NSData*)body
                 parameters:(NSDictionary*)params
                 httpMethod:(NSString*)method
{
	NSURL *requestURL = [NSURL URLWithString:file relativeToURL:[NSURL URLWithString:url]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:requestURL];    
    if(method)
        request.HTTPMethod = method;
    
    if(body)        
        [request setHTTPBody:body];
    
    NSMutableDictionary* newOAuthParams = [NSMutableDictionary dictionary];
    [newOAuthParams addEntriesFromDictionary:oAuthParams];
    [newOAuthParams setValue:[self _generateTimestamp] forKey:@"oauth_timestamp"];
    [newOAuthParams setValue:[self _generateNonce] forKey:@"oauth_nonce"];
    
    if(params)
        [newOAuthParams addEntriesFromDictionary:params];

    NSString* baseString = [self _signatureBaseStringFromRequest:request params:newOAuthParams];
    NSString* signature = [self signText:baseString withSecret:[NSString stringWithFormat:@"%@&", secretKey]];
    [newOAuthParams setValue:signature forKey:@"oauth_signature"];
                           
    NSString* newURL = [NSString stringWithFormat:@"%@?%@", [requestURL absoluteString], [self _normalizeRequestParams:newOAuthParams]];
    [request setURL:[NSURL URLWithString:newURL]];
    
    SGLog(@"SGOAuth - %@ method being sent to %@ at %@", method, newURL , file);
    NSError* error = nil;
    NSURLResponse* response = nil;  
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    time = [[NSDate date] timeIntervalSince1970] - time;
    
    SGLog(@"SGOAuth - Response recieved after %f seconds.", time); 
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                response ? response : (NSObject*)[NSNull null], @"response",
                                error ? error : (NSObject*)[NSNull null], @"error",
                                data ? data : (NSObject*)[NSNull null], @"data",
                                nil];
    
	[request release];
    
    return dictionary;
}

#pragma mark -
#pragma mark Helper methods 

- (NSString*) _signatureBaseStringFromRequest:(NSURLRequest*)request params:(NSDictionary*)params
{
    return [NSString stringWithFormat:@"%@&%@&%@",
            [request HTTPMethod],
            [[[request URL] absoluteString] URLEncodedString],
            [[self _normalizeRequestParams:params] URLEncodedString]];
}

- (NSString*) _normalizeRequestParams:(NSDictionary*)params
{
    NSMutableArray *parameterPairs = [NSMutableArray arrayWithCapacity:([params count])];
    
    NSString* value;
    for(NSString* param in params) {
        
        value = [params objectForKey:param];
        param = [NSString stringWithFormat:@"%@=%@", [param URLEncodedString], [value URLEncodedString]];
        [parameterPairs addObject:param];
    }
    
    NSArray* sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    return [sortedPairs componentsJoinedByString:@"&"];
}

- (NSString*) _generateTimestamp
{
    return [NSString stringWithFormat:@"%d", time(NULL)];
}

- (NSString *) _generateNonce
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    
    return  (NSString*)string;
}

- (NSString*) signText:(NSString*)text withSecret:(NSString*)secret 
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char*)[secretData bytes], [secretData length], result);
    
    //Base64 Encoding
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    return [base64EncodedResult autorelease];
}

- (void) dealloc
{
    [secretKey release];
    [consumerKey release];
    [oAuthParams release];
    
    [super dealloc];
}

@end
