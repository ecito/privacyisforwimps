//
//  SGLocationServiceTests.h
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

#import <SenTestingKit/SenTestingKit.h>

#import "SGClient.h"
#import "SGTestingMacros.h"

// Delay requests after writes to give them a chance to be 
// registered.
#define WAIT_FOR_WRITE()              sleep(5)

@interface SGLocationServiceTests : SenTestCase <SGLocationServiceDelegate> {
    
    SGLocationService* locatorService;
    NSMutableDictionary* requestIds;
    NSDictionary* recentReturnObject;
}

@property (nonatomic, retain) SGLocationService* locatorService;
@property (nonatomic, retain) NSMutableDictionary* requestIds;
@property (nonatomic, retain) NSObject* recentReturnObject;

- (NSDictionary*) expectedResponse:(BOOL)succeed message:(NSString*)message record:(NSObject*)record;

- (SGRecord*) createCopyOfRecord:(SGRecord *)record;
- (SGRecord*) createRandomRecord;

- (void) deleteRecord:(NSObject*)record responseId:(NSString*)responseId;
- (void) addRecord:(NSObject*)record responseId:(NSString*)responseId;
- (void) retrieveRecord:(NSObject*)record responseId:(NSString*)responseId;

@end
