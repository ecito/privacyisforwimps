//
//  SGLocationService.h
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
#import "SGLocationTypes.h"
#import "SGAuthorization.h"

@protocol SGLocationServiceDelegate;

/*!
* @class SGLocationService 
* @abstract ￼Update and retrieve records from SimpleGeo.
* @discussion ￼All methods that create an HTTP request return a response identifier. The response identifier is used
* to identify which response is being returned when either @link locationService:succeededForResponseId:responseObject: locationService:succeededForResponseId:responseObject: @/link
* or @link locationService:failedForResponseId:error: locationService:failedForResponseId:error: @/link is called for all delegates. The class
* allows multiple records to be registered using @link addDelegate: addDelegate: @/link. Delegates will continue recieving notifications
* so it is important to @link removeDelegate: removeDelegate: @/link when that object no longer wants to recieve notifications.
*
* The location service requires that @link HTTPAuthorizer HTTPAuthorizer @/link be set with a valid instance of @link //simplegeo/ooc/cl/SGOAuth SGOAuth @/link. Since
* the only type of authorization supported by SimpleGeo is OAuth, this property must be set or all HTTP requests will result in an error.
*
* All HTTP requests are sent as NSInvocationOperations. Currently, the SimpleGeo API only offers get/add/delete methods for only a single
* record. When using a method like @link updateRecordAnnotations: updateRecordAnnotations: @/link, a single NSInvocationOperation is used
* to update all of the records. It does not create a new operation for each @link //simplegeo/ooc/cl/SGRecordAnnotation SGRecordAnnotation @/link
* that is passed through.
*
* This interface provides two different avenues when it comes to storing and retrieving records. The first is using the standard
* NSString parameratized methods like @link retrieveRecord:layer: retrieveRecord:layer: @/link. Calling this method
* only requires the knowledge of the desired recordId and the layer to which it belongs to. The alternative method would be to use
* @link retrieveRecordAnnotation: retrieveRecordAnnotation: @/link which requires an NSObject that implements 
* @link //simplegeo/ooc/intf/SGRecordAnnotation SGRecordAnnotation @/link. @link //simplegeo/ooc/cl/SGRecord SGRecord @/link is provided
* as a standard class that implements the protocol. The advantage to using the second method is that everytime a response succeeds,
* the delegate can use the responseObject that is passed in via @link locationService:succeededForResponseId:responseObject: locationService:succeededForResponseId:responseObject: @/link
* to update the SGRecord by calling @link //simplegeo/ooc/instm/SGRecord/updateRecordWithGeoJSONObject: updateRecordWithGeoJSONObject: @/link.
*/
@interface SGLocationService : NSObject {

    NSOperationQueue* operationQueue;
 
    id<SGAuthorization> HTTPAuthorizer;
 
    @private
    NSMutableArray* _requestIds;
    NSMutableArray* _delegates;
 
}

/*!
* @property
* @abstract The operation queue that is used to send HTTP requests.
*/
@property (nonatomic, readonly) NSOperationQueue* operationQueue;

/*!
* @property
* @abstract The type of authorization to apply to all HTTP requests.
*/
@property (nonatomic, assign) id<SGAuthorization> HTTPAuthorizer;

/*!
* @method sharedLocationService
* @abstract The shared instance of @link SGLocationService SGLocationService @/link.
* @result The shared instance of @link SGLocationService SGLocationService @/link.
*/
+ (SGLocationService*) sharedLocationService;

/*!
* @method callbackOnMainThread:
* @abstract Determines whether or not to use the main thread to call delegate methods. Default is YES.
* @discussion Since NSOpertaionQueue spawns new threads in order to fulfill its purpose, there are instances
* where it might be benefical to extend the life of that thread (e.g. loading objects into CoreData).
*
* There are only two delegate methods defined by @link SGLocationServiceDelegate SGLocationServiceDelegate @/link.
* If you plan on updating any UIViews, Apple recomends to us the main thread. So be careful. If you plan on updating
* a UITableView within your implementation of the delegate methods, be sure that this value is set to YES.
* @param callback YES to have the delegate methods be called on the main thread; otherwise NO.
*/
+ (void) callbackOnMainThread:(BOOL)callback;

/*!
* @method addDelegate:
* @abstract Adds an instance of @link SGLocationServiceDelegate SGLocationServiceDelegate @/link to be notified
* when a HTTP request fails or succeeds.
* @param delegate The delegate to add.
*/
- (void) addDelegate:(id<SGLocationServiceDelegate>)delegate;

/*!
* @method removeDelegate:
* @abstract Removes the @link SGLocationServiceDelegate SGLocationServiceDelegate @/link from the group
* of delegates.
* @param delegate The delegate to remove.
*/
- (void) removeDelegate:(id<SGLocationServiceDelegate>)delegate;


#pragma mark -
#pragma mark Record Information 
 

/*!
* @method retrieveRecordAnnotation:
* @abstract Retrieves information about a @link //simplegeo/ooc/intf/SGRecordAnnotation SGRecordAnnotation @/link from 
* SimpleGeo.
* @discussion See @link retrieveRecord:layer: retrieveRecord:layer: @/link
* @param record The record.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) retrieveRecordAnnotation:(id<SGRecordAnnotation>)record;

/*!
* @method retrieveRecordAnnotations:
* @abstract Retreives information about an array of @link //simplegeo/ooc/intf/SGRecordAnnotation SGRecordAnnotation @/link
* from Simplegeo.
* @discussion See @link retrieveRecord:layer: retrieveRecord:layer: @/link
* @param records ￼
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) retrieveRecordAnnotations:(NSArray*)records;

/*!
* @method retrieveRecord:layer:
* @abstract Retrieves information about a record within a layer.
* @discussion Use this method to retrieve information about a single record that is already stored in SimpleGeo. 
* @param recordId The id of the record.
* @param layer The layer in which the record is located in.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) retrieveRecord:(NSString*)recordId layer:(NSString*)layer;

/*!
* @method updateRecordAnnotation:
* @abstract Updates a record a @link //simplegeo/ooc/intf/SGRecordAnnotation SGRecordAnnotation @/link in
* SimpleGeo.
* @discussion See @link updateRecord:layer:properites: updateRecord:layer:properites: @/link
* @param record The record to update.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) updateRecordAnnotation:(id<SGRecordAnnotation>)record;

/*!
* @method updateRecordAnnotations:
* @abstract Updates an array of @link //simplegeo/ooc/intf/SGRecordAnnotation SGRecordAnnotations @/link in
* SimpleGeo.
* @discussion See @link updateRecord:layer:properties: updateRecord:layer:properties: @/link
* @param records ￼An array of records.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) updateRecordAnnotations:(NSArray*)records;

/*!
* @method updateRecord:layer:properties:
* @abstract Updates a record with the given properties.
* @discussion Use this method to update records in SimpleGeo. If the record id is not found in the layer
* then a new record will be created. 
* @param recordId The id of the record.
* @param layer The layer in which the record is located in.
* @param properties The new properties for the record.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) updateRecord:(NSString*)recordId layer:(NSString*)layer coord:(CLLocationCoordinate2D)coord properties:(NSDictionary*)properties;

/*!
* @method deleteRecordAnnotation:
* @abstract ￼Deletes a @link //simplegeo/ooc/intf/SGAnnotationRecord SGAnnotationRecord @/link from SimpleGeo.
* @discussion ￼See @link deleteRecord:layer: deleteRecord:layer: @/link
* @param record ￼The record to delete.
* @result ￼A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) deleteRecordAnnotation:(id<SGRecordAnnotation>)record;

/*!
* @method deleteRecordAnnotations:
* @abstract ￼Deletes an array of @link //simplegeo/ooc/intf/SGAnnotationRecord SGAnnotationRecord @/link from SimpleGeo.
* @discussion ￼See @link deleteRecord:layer: deleteRecord:layer: @/link
* @param records ￼The records to delete.
* @result ￼A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) deleteRecordAnnotations:(NSArray*)records;

/*!
* @method deleteRecord:layer:
* @abstract￼Deletes a single record from SimpleGeo.
* @discussion￼Use this method to delete a record from SimpleGeo.
* @param recordId The id of the record to delete.
* @param layer The layer in which the record is located.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) deleteRecord:(NSString*)recordId layer:(NSString*)layer;

/*!
* @method retrieveRecordAnnotationHistory:
* @abstract￼Retrieve the record history of a @/link //simplegeo/ooc/intf/SGAnnotationRecord SGAnnotationRecord @/link.
* @discussion￼See @link retrieveHistory:layer: retrieveHistory:layer: @/link
* @param record The record 
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) retrieveRecordAnnotationHistory:(id<SGRecordAnnotation>)record;

/*!
* @method retrieveHistory:layer:
* @abstract￼Retrieves the history of a single record.
* @discussion This method allows retrieve the history of a record.
* @param recordId￼The id of the record that wants to know about its history.
* @param layer The layer in which the record is located in.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) retrieveRecordHistory:(NSString*)recordId layer:(NSString*)layer;

#pragma mark -
#pragma mark Layer

/*!
 * @method layerInformation:
 * @abstract ￼Retrieves information for a given layer.
 * @param layerName ￼The layer.
 * @result A response id that is used to identifier the return value from SimpleGeo. 
 * You can use this value in @link SGLocationServiceDelegate delegate @/link. 
 */
- (NSString*) layerInformation:(NSString*)layerName;

#pragma mark -
#pragma mark Nearby
 
/*!
* @method retrieveRecordsForGeohash:layer:types:limit:
* @abstract Gets records that are located in a specific geohash.
* @param geohash The geohash that should be searched.
* @param layer The layer to search in.
* @param types An array of types that will help filter the search.
* @param limit The amount of records to obtain. 
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) retrieveRecordsForGeohash:(SGGeohash)geohash 
                                layer:(NSString*)layer
                                 types:(NSArray*)types
                                 limit:(NSInteger)limit;

/*!
* @method retrieveRecordsForGeohash:layer:type:limit:
* @abstract Gets records that are located in a specific geohash and within 
* a given interval. To make use of our time based index,
* the difference between start and end must not be greater than 60 minutes.
* @param geohash The geohash that should be searched.
* @param layer The layer to search in.
* @param types An array of types that will help filter the search.
* @param start An Epoch timestamp that is the beginning of the time interval in seconds.
* @param end An Epoch timestamp that is the end of the time interval in seconds.
* @param limit The amount of records to obtain. 
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link.
*/
- (NSString*) retrieveRecordsForGeohash:(SGGeohash)geohash 
                                 layer:(NSString*)layer
                                  types:(NSArray*)types
                                  limit:(NSInteger)limitend
                                  start:(double)start
                                 end:(double)end;


/*!
* @method retrieveRecordsForCoordinate:radius:layer:types:limit:
* @abstract Get records that are located within a radius of coordinate.
* @param coord The origin of the radius.
* @param radius The radius of the search space. (km)
* @param layer The layer to search in.
* @param types An array of types that will help filter the search.
* @param limit￼The amount of records to obtain. 
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link. 
*/
- (NSString*) retrieveRecordsForCoordinate:(CLLocationCoordinate2D)coord
                                   radius:(double)radius
                                   layer:(NSString*)layer
                                    types:(NSArray*)types
                                    limit:(NSInteger)limit;

/*!
* @method retrieveRecordsForCoordinate:radius:layer:types:limit:
* @abstract Get records that are located within a radius of a coordinate and within
* a given interval. To make use of our time based index, the difference between
* start and end must not be greater than 60 minutes.
* @param coord The origin of the radius.
* @param radius The radius of the search space. (km)
* @param layer The layer to search in.
* @param types An array of types that will help filter the search.
* @param limit￼The amount of records to obtain. 
* @param start An Epoch timestamp that is the beginning of the time interval in seconds.
* @param end An Epoch timestamp that is the end of the time interval in seconds.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link. 
*/
- (NSString*) retrieveRecordsForCoordinate:(CLLocationCoordinate2D)coord
                                    radius:(double)radius
                                    layer:(NSString*)layer
                                     types:(NSArray*)types
                                     limit:(NSInteger)limit
                                     start:(double)start
                                    end:(double)end;


#pragma mark -
#pragma mark Features

/*!
* @method reverseGeocode:
* @abstract Returns resource information for a given pair lat/lon coordinate.
* @discussion This method does not use MapKit's reverse geocoding methods. SimpleGeo
* offers its own reverse geocoding endpoint. The response object is a GeoJSON dictionary
* where the properties key contains a dictionary with the following keys:
*
*  street_number, country, street, postal_code, county_name, county_code, state_code, place_name
*
* Reverse geocoding is only supported within the US; however, other countries will
* be offered in the coming months.
* @param coord The coordinate to use for reverse geocoding.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link. 
*/
- (NSString*) reverseGeocode:(CLLocationCoordinate2D)coord;

/*!
* @method densityForCoordinate:day:hour:
* @abstract Returns a GeoJSON Feature that contains SpotRank data for a specific point.
* @discussion ￼See @link http://www.skyhookwireless.com/spotrank/index.php SpotRank @/link for
* information about the data set. If @link hour hour @/link is not specified, then a collection of
* of tiles, bounding boxes with density data, will be returned for the entire day.
* @param coord ￼The desired location.
* @param day See the defined SpotRank days in @link //simplegeo/ooc/intf/SGLocationTypes SGLocationTypes @/link.
* (e.g. @"mon")￼. Default is nil.s
* @param hour ￼An integer value between 0 and 24. The timezone depends on the location of the coord. Deafault is 12.
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link. 
*/
- (NSString*) densityForCoordinate:(CLLocationCoordinate2D)coord day:(NSString*)day hour:(int)hour;

/*!
* @method densityForCoordinate:day:hour:
* @abstract Returns a GeoJSON FeatureCollection that contains SpotRank data for a specific point. 
* @discussion ￼See @link http://www.skyhookwireless.com/spotrank/index.php SpotRank @/link for
* information about the data set. The data returned is a collection of tiles, bounding boxes with density data.
* @param coord ￼The desired location.
* @param day See the defined SpotRank days in @link //simplegeo/ooc/intf/SGLocationTypes SGLocationTypes @/link.
* (e.g. @"mon")￼. Default is nil.s
* @result A response id that is used to identifier the return value from SimpleGeo. 
* You can use this value in @link SGLocationServiceDelegate delegate @/link. 
*/
- (NSString*) densityForCoordinate:(CLLocationCoordinate2D)coord day:(NSString*)day;

@end

/*!
* @protocol SGLocationServiceDelegate
* @abstract Recieves notifications when @link SGLocationService SGLocationService @/link returns from 
* sending an HTTP request.
* @discussion This is a simple delegate that allows notifications for when a request to SimpleGeo's API
* succeeds or fails. In the case that a request succeeds a responseObject is returned. The responseObject
* can take on the identity of either NSDictionary or NSArray. 
*
* If the responseObject is of type NSDictionary, then the dictoinary is the GeoJSON representation of the 
* of a record. If the responseObject is of type NSArray, then each element within the array will be
* a dictionary that is aGeoJSON representation of a record. See @link //simplegeo/ooc/cl/SGGeoJSONEncoder SGGeoJSONEncoder @/link
* for a specific guide to the GeoJSON objects that returned from SimpleGeo.
*/
@protocol SGLocationServiceDelegate <NSObject>

/*!
* @method locationService:succeededForResponseId:responseObject:
* @abstract In the case that an HTTP request succeeds, this method is called.
* @discussion It is up to the delegate to decide how to interpret the responseObject. The object can take on two identities, either
* as a NSDictionary or as a NSArray. If the responseObject matches an instance of NSDictionary then the key/values of
* the NSDictionary will match that of the GeoJSON representation of the record that was either created, updated or retrieved.
* 
* If the responseObject matches an instance of NSArray, then every element in the array will be a NSDictionary with its
* key-value pair matching the GeoJSON representaiton of a particular record. 
* @param service￼The @link SGLocationService SGLocationService @/link recieved a successful HTTP response.
* @param requestId￼The response id that was used to create the request.
* @param responseObject The response object.
*/
- (void) locationService:(SGLocationService*)service succeededForResponseId:(NSString*)requestId responseObject:(NSObject*)responseObject;

/*!
* @method locationService:failedForResponseId:error:
* @abstract In the case that an HTTP request fails, this method is called.
* @param service The @link SGLocationService SGLocationService @/link that produced the error.
* @param requestId￼The request id that was used to generate the error.
* @param error The error that was generated.
*/
- (void) locationService:(SGLocationService*)service failedForResponseId:(NSString*)requestId error:(NSError*)error;

@end