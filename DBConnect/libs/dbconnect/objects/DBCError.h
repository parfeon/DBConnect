/**
 *
 * Copyright (c) 2011 Sergey Mamontov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <Foundation/Foundation.h>
#import "DBCAdditionalErrorCodes.h"
#import <sqlite3.h>

#define kSQLiteErrorDomain @"kSQLiteErrorDomain"
#define kDBCErrorDomain @"kDBCErrorDomain"
#define DBCAdditionalErrorInformation @"DBCAdditionalErrorInformation"

@interface DBCError : NSError {
    
}

/**
 * Return SQLite error description by error code
 * @parameters
 *      int errorCode - SQLite error code
 * @return stringified error code value
 */
+ (NSString*)errorDescriptionByCode:(int)errorCode;

#pragma mark DBCError instance initialization

/**
 * Initiate DBCError instance
 * @parameters
 *      NSInteger code - error code
 * @return initialized autoreleased DBCError instance
 */
+ (id)errorWithErrorCode:(NSInteger)code;

/**
 * Initiate DBCError instance
 * @parameters
 *      NSInteger code     - error code
 *      NSString *filePath - path to file, which was reason of the error
 * @return initialized autoreleased DBCError instance
 */
+ (id)errorWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath;

/**
 * Initiate DBCError instance
 * @parameters
 *      NSInteger code                  - error code
 *      NSString *filePath              - path to file, which was reason of the error
 *      NSString *additionalInformation - additional error information
 * @return initialized autoreleased DBCError instance
 */
+ (id)errorWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath 
   additionalInformation:(NSString*)additionalInformation;

/**
 * Initiate DBCError instance
 * @parameters
 *      NSInteger code - error code
 * @return initialized DBCError instance
 */
- (id)initWithErrorCode:(NSInteger)code;

/**
 * Initiate DBCError instance
 * @parameters
 *      NSInteger code     - error code
 *      NSString *filePath - path to file, which was reason of the error
 * @return initialized DBCError instance
 */
- (id)initWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath;

/**
 * Initiate DBCError instance
 * @parameters
 *      NSInteger code                  - error code
 *      NSString *filePath              - path to file, which was reason of the error
 *      NSString *additionalInformation - additional error information
 * @return initialized DBCError instance
 */
- (id)initWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath 
  additionalInformation:(NSString*)additionalInformation;

/**
 * Initiate DBCError instance
 * @parameters
 *      NSInteger code                  - error code
 *      NSString *errorDomain           - error domain
 *      NSString *filePath              - path to file, which was reason of the error
 *      NSString *additionalInformation - additional error information
 * @return initialized DBCError instance
 */
- (id)initWithErrorCode:(NSInteger)code errorDomain:(NSString*)errorDomain 
            forFilePath:(NSString*)filePath additionalInformation:(NSString*)additionalInformation;

#pragma mark DBCError for NSLog

/**
 * Stringify DBCError instance
 * @return stringified DBCError instance
 */
- (NSString*)description;

@end
