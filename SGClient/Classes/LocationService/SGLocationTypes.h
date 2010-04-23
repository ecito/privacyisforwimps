//
//  SGLocationTypes.h
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
* @defined kSGLocationType_Person
* @abstract A person type.
*/
#define kSGLocationType_Person @"person"

/*!
* @defined kSGLocationType_Place
* @abstract A place type.
*/
#define kSGLocationType_Place @"place"

/*!
* @defined kSGLocationType_Object
* @abstract A object type.
*/
#define kSGLocationType_Object @"object"

/*!
* @defined kSGLocationType_Note
* @abstract A note media type.
*/
#define kSGLocationType_Note @"note"

/*!
* @defined kSGLocationType_Audio
* @abstract An audio media type.
*/
#define kSGLocationType_Audio @"audio"

/*!
* @defined kSGLocationType_Video
* @abstract A video media type.
*/
#define kSGLocationType_Video @"video"

/*!
* @defined kSGLocationType_Image
* @abstract An image media type.
*/
#define kSGLocationType_Image @"image"


typedef NSString SGLocationType;

/*!
* @struct SGGeohash
* @field latitude The latitude.
* @field longitude The longitude. 
* @field precision
*/
typedef struct {

    double latitude;
    double longitude;
 
    int precision;

} SGGeohash;

/*!
* @function SGGeohashMake(double, double, SGLocationZoomLevel)
* @abstract Creates a new SGGeohash structure.
* @param latitude The latitude.
* @param longitude The longitude.
* @param precision The precision. 
* @result A new SGGeohash structure.
*/
extern SGGeohash SGGeohashMake(double latitude, double longitude, int precision);

/*!
* @defined kSpotRank_Monday 
* @abstract Representation of Monday used by SpotRank.
*/
#define kSpotRank_Monday    @"mon"

/*!
* @defined kSpotRank_Tuesday 
* @abstract Representation of Tuesday used by SpotRank.
*/
#define kSpotRank_Tuesday   @"tue"

/*!
* @defined kSpotRank_Wednesday 
* @abstract Representation of Wednesday used by SpotRank.
*/
#define kSpotRank_Wednesday @"wed"

/*!
* @defined kSpotRank_Thursday 
* @abstract Representation of Thursday used by SpotRank.
*/
#define kSpotRank_Thursday  @"thu"

/*!
* @defined kSpotRank_Friday 
* @abstract Representation of Friday used by SpotRank.
*/
#define kSpotRank_Friday    @"fri"

/*!
* @defined kSpotRank_Saturday 
* @abstract Representation of Saturday used by SpotRank.
*/
#define kSpotRank_Saturday  @"sat"

/*!
* @defined kSpotRank_Sunday 
* @abstract Representation of Sunday used by SpotRank.
*/
#define kSpotRank_Sunday    @"sun"
