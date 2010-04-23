//
//  SGGeoJSONNSArray.h
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

/*!
* @category NSArray(SGGeoJSONObject)
* @abstract Ease the pain of accessing SimpleGeo GeoJSON values.
*/
@interface NSArray (GeoJSONObject)

/*!
* @method x
* @abstract Retrieve the x coordinate of the point.
* @result The x value for the point.
*/
- (double) x;

/*!
* @method y
* @abstract Retrieve the y coordinate of the point. ￼
* @result ￼The y value for the point.
*/
- (double) y;

/*!
* @method latitude
* @abstract ￼Retrieve the latitude of the point (y)
* @result The latitude value for the point.
*/
- (double) latitude;

/*!
* @method longitude
* @abstract Retrieve the longitude of the point (x)
* @result ￼The longitude value for the point.
*/
- (double) longitude;

@end

/*!
* @category NSMutableArray(SGGeoJSONObject)
* @abstract Ease the pain of storing SimpleGeo GeoJSON values.
*/
@interface NSMutableArray (GeoJSONObject)

/*!
* @method setX:
* @abstract Stores the new x value at index 0.
* @param x The new x value.
*/
- (void) setX:(double)x;

/*!
* @method setY:
* @abstract Stores the new y value at index 1.
* @param x The new y value.
*/
- (void) setY:(double)y;

/*!
* @method setLatitude:
* @abstract Stores the new latitude value at index 1.
* @param x The new latitude value.
*/
- (void) setLatitude:(double)latitude;

/*!
* @method setLongitude:
* @abstract Stores the new longitude value at index 0.
* @param x The new longitude value.
*/
- (void) setLongitude:(double)longitude;

@end

