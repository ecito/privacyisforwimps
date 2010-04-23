//
//  SGGeoJSONEncoder.h
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

#import "SGRecordAnnotation.h"
#import "GeoJSON+NSArray.h"
#import "GeoJSON+NSDictionary.h"

/*!
* @class SGGeoJSONEncoder 
* @abstract Converts annotations into GeoJSONObjects and vice-versa.
* @discussion Objects returned from SGLocationService are represented as GeoJSON object. A GeoJSON object
* is just an NSDictionary with specific key/values. For further information on
* GeoJSON See @link http://geojson.org/geojson-spec.html#point here @/link
*/
@interface SGGeoJSONEncoder : NSObject {

}

/*!
* @method recordsForGeoJSONObject:
* @abstract ￼Returns a list of @link //simplegeo/ooc/intf/SGRecord SGRecord @/link
* @param geojsonObject A valid GeoJSON object.
* @result ￼An array of newly allocated records that were constructed from the GeoJSONObject.
*/
+ (NSArray*) recordsForGeoJSONObject:(NSDictionary*)geojsonObject;

/*!
* @method recordForGeoJSONObject:
* @abstract ￼Creates a new //simplegeo/ooc/intf/SGRecord SGRecord @/link fromt a GeoJSON object.
* @param geojsonObject ￼ A valid GeoJSON object.
* @result ￼A new @link //simplegeo/ooc/intf/SGRecord SGRecord @/link created from the geoJSONObject.
*/
+ (id<SGRecordAnnotation>) recordForGeoJSONObject:(NSDictionary *)geojsonObject;

/*!
* @method geoJSONObjectForRecordAnnotations:
* @abstract ￼Returns a new GeoJSONObject that was constructed from the list of
* @link //simplegeo/ooc/intf/SGRecordAnnotation SGRecordAnnotation @/link objects.
* @param recordAnnotations The array of record annotations that help construct the GeoJSON object. ￼
* @result A new GeoJSON object.
*/
+ (NSDictionary*) geoJSONObjectForRecordAnnotations:(NSArray*)recordAnnotations;

+ (NSDictionary*) geoJSONObjectForRecordAnnotation:(id<SGRecordAnnotation>)recordAnnotation;

/*!
* @method layerNameFromLayerLink:
* @abstract Returns the layer name from the layer link of a GeoJSON object.
* @param layerLink ￼The link to the layer that stores a GeoJSON object.
* @result ￼The layer that was obtained from the layer link.
*/
+ (NSString*) layerNameFromLayerLink:(NSString*)layerLink;

                                      
@end
