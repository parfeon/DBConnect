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


@interface DBCDatabaseInfo : NSObject {
    int         dbSeqNumber;
    NSString    *dbName;
    NSString    *dbFilePath;
}
@property (nonatomic, readonly, getter = numberInSequence)int dbSeqNumber;
@property (nonatomic, readonly, getter = name)NSString *dbName;
@property (nonatomic, readonly, getter = filePath)NSString *dbFilePath;

#pragma mark DBCDatabaseInfo instance initialization

/**
 * Initiate DBCDatabaseInfo instance
 * @parameters
 *      int sequenceNumber           - database sequence number in list of other databases
 *      NSString* databaseName       - database name
 *      NSString* pathToDatabaseFile - path to database file
 * @return autoreleased DBCDatabaseInfo instance
 */
+ (id)databaseInfoWithSequence:(int)sequenceNumber name:(NSString*)databaseName filePath:(NSString*)pathToDatabaseFile;

/**
 * Initiate DBCDatabaseInfo instance
 * @parameters
 *      int sequenceNumber           - database sequence number in list of other databases
 *      NSString* databaseName       - database name
 *      NSString* pathToDatabaseFile - path to database file
 * @return DBCDatabaseInfo instance
 */
- (id)initDatabaseInfoWithSequence:(int)sequenceNumber name:(NSString*)databaseName 
                          filePath:(NSString*)pathToDatabaseFile;

#pragma mark DBCDatabaseInfo for NSLog

/**
 * Get formatted database connection description
 * @return formatted database connection description
 */
- (NSString*)description;

#pragma mark DBCDatabaseInfo memory management

/**
 * Deallocate database information and release all retained memory
 */
- (void)dealloc;

@end
