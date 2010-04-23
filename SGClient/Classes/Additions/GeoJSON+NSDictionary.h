//
//  SGGeoJSONNSDictionary.h
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
* @category NSDictionary(SGGeoJSONObject)
* @abstract Ease the pain of accessing SimpleGeo GeoJSON values.
*/
@interface NSDictionary (SGGeoJSONObject)

/*!
* @method type
* @abstract Retrieves the type value for this GeoJSONObject. ￼
* @result The type value for the object.
*/
- (NSString*) type;

/*!
* @method geometry
* @abstract Returns the GeoJSONObject associated with the key at geometry. ￼
* @result ￼The geometry GeoJSONObject.
*/
- (NSDictionary*) geometry;

/*!
* @method coordinates
* @abstract Returns the GeoJSONObject associated with the key coordinates. ￼
* @result ￼The coordinates GeoJSONObject.
*/
- (NSArray*) coordinates;

/*!
* @method properties
* @abstract Returns the GeoJSONObject associated with the key properties.
* @result ￼The properties GeoJSONObject.
*/
- (NSDictionary*) properties;

/*!
* @method created
* @abstract ￼Returns the value associated with the key created.
* @discussion This is a value specific to SimpleGeo. The GeoJSON spec (http://geojson.org/geojson-spec.html)
* allows key/values to be defined at the top-level of the object.
* @result ￼The created value.
*/
- (double) created;

/*!
* @method expires
* @abstract Returns the value associated with the key expires
* @discussion This is a value specific to SimpleGeo. The GeoJSON spec (http://geojson.org/geojson-spec.html)
* allows key/values to be defined at the top-level of the object.
* @result ￼The expires value.
*/
- (double) expires;

/*!
* @method id
* @abstract Returns the value associated ￼with the key id.
* @discussion This is a value specific to SimpleGeo. The GeoJSON spec (http://geojson.org/geojson-spec.html)
* allows key/values to be defined at the top-level of the object.
* @result ￼The id value.
*/
- (NSString*) id;

/*!
* @method features
* @abstract Returns the GeoJSONObject associated with the key features.
* @result ￼The features GeoJSONObject.
*/
- (NSArray*) features;

/*!
* @method layerLink
* @abstract Use this URL string to obtain information about the layer
* this GeoJSON object resides in.
* @result ￼The URL string of this object's layer.
*/
- (NSString*) layerLink;

/*!
* @method selfLink
* @abstract ￼The URL used to retrieve information about this GeoJSON
* object.
* @result A URL string. ￼
*/
- (NSString*) selfLink;

/*!
* @method isFeature
* @abstract Determines whether this GeoJSON object is a feature. 
* @result YES if the object is a feature; otherwise NO.
*/
- (BOOL) isFeature;

/*!
* @method isFeatureCollection
* @abstract Determines whether this GeoJSON object is a collection
* of features.￼
* @result ￼YES if the object is a collection of features; otherwise
* NO.
*/
- (BOOL) isFeatureCollection;

/*!
* @method isPoint
* @abstract Determines whether this GeoJSON object is a point. ￼
* @result ￼YES if the object is a point; otherwise NO.
*/
- (BOOL) isPoint;

@end

/*!
* @category NSMutableDictionary(SGGeoJSONObject)
* @abstract Ease the pain of storing SimpleGeo GeoJSON values.
*/
@interface NSMutableDictionary (SGGeoJSONObject)

/*!
* @method setType:
* @abstract Sets the value stored at key type.
* @param type ￼The value to store.
*/
- (void) setType:(NSString*)type;

/*!
* @method setGeometry:
* @abstract Sets the GeoJSONObject stored at key geometry.
* @param geometry ￼The GeoJSONObject to store.
*/
- (void) setGeometry:(NSDictionary*)geometry;

/*!
* @method setCoordinates:
* @abstract Sets the GeoJSONObject stored at key coordinates.
* @param coordinates ￼The GeoJSONObject to store.
*/
- (void) setCoordinates:(NSArray*)coordinates;

/*!
* @method setProperties:
* @abstract Sets the GeoJSONObject stored at key properties.
* @param properties The GeoJSONObject to store.
*/
- (void) setProperties:(NSDictionary*)properties;

/*!
* @method setCreated:
* @abstract Sets the value stored at key created.
* @discussion This is a value specific to SimpleGeo. The GeoJSON spec (http://geojson.org/geojson-spec.html)
* allows key/values to be defined at the top-level of the object.
* @param created The value to store.
*/
- (void) setCreated:(double)created;

/*!
* @method setId:
* @abstract Sets the value stored at key id.
* @discussion This is a value specific to SimpleGeo. The GeoJSON spec (http://geojson.org/geojson-spec.html)
* allows key/values to be defined at the top-level of the object.
* @param id ￼The value to store.
*/
- (void) setId:(NSString*)id;

/*!
* @method setFeatures:
* @abstract Sets the GeoJSONObject stored at key features.
* @discussion This is a value specific to SimpleGeo. The GeoJSON spec (http://geojson.org/geojson-spec.html)
* allows key/values to be defined at the top-level of the object.
* @param features ￼The value to store.
*/
- (void) setFeatures:(NSArray*)features;

/*!
* @method setExpires:
* @abstract Sets the value stored at key expires.
* @discussion This is a value specific to SimpleGeo. The GeoJSON spec (http://geojson.org/geojson-spec.html)
* allows key/values to be defined at the top-level of the object.
* @param expires ￼The value to store.
*/
- (void) setExpires:(double)expires;

@end

