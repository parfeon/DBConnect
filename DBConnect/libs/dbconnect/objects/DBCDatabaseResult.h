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
#import "DBCDatabase.h"
#import "sqlite3lib.h"
#import <sqlite3.h>

@protocol DBCDatabaseResultStructure <NSObject>

@required
- (int)columnsCount;
- (DBCDatabaseEncoding)databaseEncoding;
- (NSString*)nameForColumnAtIndex:(int)columnIdx;
- (int)indexForColumn:(NSString*)columnName;
- (NSString*)stringifiedTypeForColumn:(NSString*)columnName;
- (int)typeForColumn:(NSString*)columnName;
- (NSString*)stringifiedTypeForColumnAtIndex:(int)columnIdx;
- (int)typeForColumnAtIndex:(int)columnIdx;

@end

@class DBCDatabaseRow;

@interface DBCDatabaseResult : NSObject <NSFastEnumeration, DBCDatabaseResultStructure> {
@private
    NSString            *querySQL;
    NSMutableArray      *colNames;
    NSMutableArray      *colTypes;
    NSMutableArray      *rows;
    NSTimeInterval      queryExecutionDuration;
    DBCDatabaseEncoding dbEncoding;
}
@property (nonatomic, assign)NSTimeInterval queryExecutionDuration;
@property (nonatomic, readonly, getter = query)NSString *querySQL;
@property (nonatomic, readonly, getter = columnNames)NSArray *colNames;
@property (nonatomic, readonly)int count;

#pragma mark DBCDatabaseResult instance creation/initialization

/**
 * Initiate and return DBCDatabaseResult instance
 * @parameters
 *      sqlite3_stmt *statement              - statement which used for query
 *      DBCDatabaseEncoding databaseEncoding - current encoding used for opened 
 *                                             database connection
 * @return autoreleased DBCDatabaseResult instance
 */
+(id)resultWithPreparedStatement:(sqlite3_stmt*)statement encoding:(DBCDatabaseEncoding)databaseEncoding;

/**
 * Initiate and return DBCDatabaseResult instance
 * @parameters
 *      sqlite3_stmt *statement              - statement which used for query
 *      DBCDatabaseEncoding databaseEncoding - current encoding used for opened 
 *                                             database connection
 * @return DBCDatabaseResult instance
 */
- (id)initWidthPreparedSatetement:(sqlite3_stmt*)statement encoding:(DBCDatabaseEncoding)databaseEncoding;

#pragma mark DBCDatabaseResults setters/getters

/**
 * Retrieve count of result rows
 * @return result rows count
 */
- (int)count;

#pragma mark Result row management

/**
 * Create row instance from data stored in statement after step iteration
 * @parameters
 *      sqlite3_stmt *statement - statement which used for query
 */
- (void)addRowFromStatement:(sqlite3_stmt*)statement;

/**
 * Retrieve row data instance from specific index
 * @parameters
 *      int rowIdx - target row index
 * @return row instance at specified index
 */
- (DBCDatabaseRow*)rowAtIndex:(int)rowIdx;

#pragma mark Fast enumeration protocol support

/**
 * Support method for fast enumeration protocol
 * @parameters
 *      NSFastEnumerationState *state - Context information that is used in the 
 *                                      enumeration to, in addition to other 
 *                                      possibilities
 *      id *stackbuf                  - A C array of objects over which the 
 *                                      sender is to iterate
 *      NSUInteger len                - The maximum number of objects to return 
 *                                      in stackbuf
 * @return number of objects returned in stackbuf
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

#pragma mark DBCDatabaseResult for NSLog

/**
 * Return formated DBCDatabaseResults instance description
 * @return formated DBCDatabaseResults instance description
 */
- (NSString *)description;

#pragma mark DBCDatabaseResultStructure protocol support 

/**
 * Retrieve number of columns in response
 * @return number of columns in response
 */
- (int)columnsCount;

/**
 * Retrieve database database encoding
 * @return database encoding
 */
- (DBCDatabaseEncoding)databaseEncoding;

/**
 * Retrieve name for column
 * @parameters
 *      int columnIdx - target column index
 * @return name of column at specified index
 */
- (NSString*)nameForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve column index
 * @parameters
 *      NSString *columnName - target column name
 * @return index of column with specified name
 */
- (int)indexForColumn:(NSString*)columnName;

/**
 * Retrieve stringified column data type
 * @parameters
 *      NSString *columnName - target column name
 * @return stringified data type declared in table structure
 */
- (NSString*)stringifiedTypeForColumn:(NSString*)columnName;

/**
 * Retrieve column data type
 * @parameters
 *      NSString *columnName - target column name
 * @return data type declared in table structure
 */
- (int)typeForColumn:(NSString*)columnName;

/**
 * Retrieve stringified column data type
 * @parameters
 *      int columnIdx - target column index
 * @return stringified data type declared in table structure
 */
- (NSString*)stringifiedTypeForColumnAtIndex:(int)columnIdx;

/**
 * Retrieve column data type
 * @parameters
 *      int columnIdx - target column index
 * @return data type declared in table structure
 */
- (int)typeForColumnAtIndex:(int)columnIdx;

#pragma mark DBCDatabaseResult memory management

/**
 * Deallocating result instance and release all retained memory
 */
- (void)dealloc;

@end
