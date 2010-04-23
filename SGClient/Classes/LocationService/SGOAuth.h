//
//  SGOAuth.h
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

#import <Foundation/Foundation.h>
#import "SGAuthorization.h"

@class SGLocationService;

/*!
 * @class SGOAuth 
 * @abstract ￼This class maintains a single 2-legged OAuth implementation.
 * @discussion ￼In order to use 2-legged OAuth @link //simplegeo/ooc/cl/SGLocationService SGLocationService @/link, you must set 
 * @link //simplegeo/ooc/instp/SGLocationService/HTTPAuthorizer HTTPAuthorizer @/link. All HTTP requests that come from
 * @link //simplegeo/ooc/cl/SGLocationService SGLLocationService @/link will be wrapped by this authorization protocol.
*/
@interface SGOAuth : NSObject <SGAuthorization> {

 
    NSString* secretKey;
    NSString* consumerKey;
 
    @private
    NSDictionary* oAuthParams;
}

/*!
 * @ property
 * @abstract The secret key.
 */
@property (nonatomic, readonly) NSString* secretKey;

/*!
 * @property
 * @abstract The consumer key.
 */
@property (nonatomic, readonly) NSString* consumerKey;

/*!
 * @method resume
 * @abstract ￼Initializes a new instance with the most recently used secret and consumer key.
 * @result ￼ A new instance of SGOAuth.
 */
+ (SGOAuth*) resume;

/*!
* @method save
* @abstract Stores the token in the user's standard defaults. ￼
*/
- (void) save;

/*!
* @method unSave
* @abstract Removes any token that is stored in the user's standard defaults.
*/
- (void) unSave;

/*!
 * @method initWithKey:secret:
 * @abstract ￼Initializes a new instance of SGOAuth with the proper credentials.
 * @param key ￼The consumer key.
 * @param secret ￼The secret key/
 * @result ￼A new instance of SGOAuth.
 */
- (id) initWithKey:(NSString *)key secret:(NSString *)secret;

@end
