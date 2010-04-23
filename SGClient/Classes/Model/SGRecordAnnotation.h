//
//  SGRecordAnnotation.h
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

#import <MapKit/MapKit.h>

/*!
* @protocol SGAnnotation
* @abstract Just a simple re-definition of MKAnnotation for the sake of notation.
* @discussion In order for an object to become displayable in an @link //simplegeo/ooc/cl/SGARView SGARView @/link,
* the object must implement this protocol. Each object serves as a data source for a view within the AR enviornment.
* The AR view requires, at a minimum, a lat/long coordinate in order
* to display an object. @link //simplegeo/ooc/cl/SGRecordAnnotationView SGRecordAnnotationViews @/link will use title and subtitle
* properties if they are provided.
*/
@protocol SGAnnotation <MKAnnotation>

@end

/*!
* @protocol SGRecordAnnotation    
* @abstract This protocol helps with the retrieval and updating process of records used in @link //simplegeo/ooc/cl/SGLocationService SGLocationService @/link.
* @discussion The SGRecordAnnotation is used to provide annotation-related information for both the @link //simplegeo/ooc/cl/SGLocationService SGLocationService @/link
* and the @link //simplegeo/ooc/cl/SGARView SGARView @/link. Using the @link //simplegeo/ooc/cl/SGGeoJSONCode SGGeoJSONEncoder @/link, the location service
* is able to create a simple GeoJSON representation of the record and update or retain information about it.
*/
@protocol SGRecordAnnotation <SGAnnotation>

/*!
* @method recordId
* @abstract￼ Returns the unique identifer for the record.
* @result￼ The unique identifier for the record.
*/
- (NSString*) recordId;

/*!
* @method layer
* @abstract The layer where the record is registered.
* @discussion The convention for layers is a reverse URL  (e.g com.simplgeo.tree). 
* @result￼ The name of the layer.
*/
- (NSString*) layer;

@optional

/*!
* @method type
* @abstract￼ The type of record. Default is object.
* @discussion￼ A list of types can be found in SGLocationTypes.h.
* @result￼ The type for the record.
*/
- (NSString*) type;

/*!
* @method properties
* @abstract￼ The properties associated with the record.
* @result￼ Extra properties that help define the record.
*/
- (NSDictionary*) properties;

/*!
* @method created
* @abstract￼ The time at which the record was created, in Unix time. Default is a current timestamp.
* @result The time interval.
*/
- (double) created;

/*!
* @method expires
* @abstract￼ The time at which the record will expire, in Unix time. Default is 24 hours from creation.
* @result￼ The time interval.
*/
- (double) expires;

/*!
* @method updateRecordWithGeoJSONObject:
* @abstract￼ Updates the annotation with the contents of a GeoJSON Object.
* @param dictionary ￼The GeoJSON dictionary.
*/
- (void) updateRecordWithGeoJSONObject:(NSDictionary*)dictionary;

@end