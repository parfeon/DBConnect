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
#import <sqlite3.h>

@protocol DBCDatabaseResultStructure;

@interface DBCDatabaseRow : NSObject {
@private
    id<DBCDatabaseResultStructure>  dataStructureDelegate;
    NSMutableArray                  *data;
    int                             columnsCount;
}

#pragma mark DBCDatabaseRow instance creation/initialization

/**
 * Initiate result row
 * @parameters
 *      sqlite3_stmt *statement - statement which used for query
 *      int colCount            - count of columns
 * @return autoreleased DBCDatabaseRow instance
 */
+ (id)rowWithStatement:(sqlite3_stmt*)statement dataStructureDelegate:(id<DBCDatabaseResultStructure>)dsDelegate;

/**
 * Initiate result row
 * @parameters
 *      sqlite3_stmt *statement - statement which used for query
 *      int colCount            - count of columns
 * @return DBCDatabaseRow instance
 */
- (id)initRowWithStatement:(sqlite3_stmt*)statement dataStructureDelegate:(id<DBCDatabaseResultStructure>)dsDelegate;

#pragma mark DBCDatabaseRow for NSLog

/**
 * Return formated DBCDatabaseRow instance description
 * @return formated DBCDatabaseRow instance description
 */
- (NSString *)description;

#pragma mark DBCDatabaseRow setters/getters

/**
 * Retrieve number of columns in response
 * @return number of columns in response
 */
- (int)columnsCount;

/**
 * Retrieve data type holder class
 * @parameters
 *      NSString* columnName - target column name
 * @return column data type holder Class
 */
- (Class)dataTypeClassAtColumnIndex:(int)columnIdx;

/**
 * Retrieve data type holder class
 * @parameters
 *      int columnIdx - target column index
 * @return column data type holder Class
 */
- (Class)dataTypeClassForColumn:(NSString*)columnName;

/**
 * Retrieve int value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return int value from object stored in column
 */
- (int)intForColumn:(NSString*)columnName;

/**
 * Retrieve int value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return int value from object stored in column
 */
- (int)intForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve integer value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return integer value from object stored in column
 */
- (NSInteger)integerForColumn:(NSString*)columnName;

/**
 * Retrieve integer value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return integer value from object stored in column
 */
- (NSInteger)integerForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve unsigned integer value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return unsigned integer value from object stored in column
 */
- (NSUInteger)unsignedIntegerForColumn:(NSString*)columnName;

/**
 * Retrieve unsigned integer value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return unsigned integer value from object stored in column
 */
- (NSUInteger)unsignedIntegerForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve long value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return long value from object stored in column
 */
- (long)longForColumn:(NSString*)columnName;

/**
 * Retrieve long value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return long value from object stored in column
 */
- (long)longForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve long long value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return long long value from object stored in column
 */
- (long long)longLongForColumn:(NSString*)columnName;

/**
 * Retrieve long long value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return long long value from object stored in column
 */
- (long long)longLongForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve bool value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return bool value from object stored in column
 */
- (BOOL)boolForColumn:(NSString*)columnName;

/**
 * Retrieve bool value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return bool value from object stored in column
 */
- (BOOL)boolForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve float value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return float value from object stored in column
 */
- (float)floatForColumn:(NSString*)columnName;

/**
 * Retrieve float value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return float value from object stored in column
 */
- (float)floatForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve double value from column
 * @parameters
 *      NSString *columnName - target column name
 * @return double value from object stored in column
 */
- (double)doubleForColumn:(NSString*)columnName;

/**
 * Retrieve double value from column
 * @parameters
 *      NSString *columnName - target column index
 * @return double value from object stored in column
 */
- (double)doubleForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve object from column
 * @parameters
 *      NSString *columnName - target column name
 * @return object from object stored in column
 */
- (id)objectForColumn:(NSString*)columnName;

/**
 * Retrieve object from column
 * @parameters
 *      NSString *columnName - target column index
 * @return object from object stored in column
 */
- (id)objectForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve NSString* from column
 * @parameters
 *      NSString *columnName - target column name
 * @return NSString* from object stored in column
 */
- (NSString*)stringForColumn:(NSString*)columnName;

/**
 * Retrieve NSString* from column
 * @parameters
 *      NSString *columnName - target column index
 * @return NSString* from object stored in column
 */
- (NSString*)stringForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve NSDate* from column
 * @parameters
 *      NSString *columnName - target column name
 * @return NSDate* from double value stored in column
 */
- (NSDate*)dateForColumn:(NSString*)columnName;

/**
 * Retrieve NSDate* from column
 * @parameters
 *      NSString *columnName - target column index
 * @return NSDate* from double value stored in column
 */
- (NSDate*)dateForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve NSData* from column
 * @parameters
 *      NSString *columnName - target column name
 * @return NSData* from blob value stored in column
 */
- (NSData*)dataForColumn:(NSString*)columnName;

/**
 * Retrieve NSData* from column
 * @parameters
 *      NSString *columnName - target column index
 * @return NSData* from blob stored in column
 */
- (NSData*)dataForColumnAtIndex:(int)columnIdx;

#pragma mark DBCDatabaseRow memory management

/**
 * Deallocate result instance and release all retained memory
 */
- (void)dealloc;

@end
