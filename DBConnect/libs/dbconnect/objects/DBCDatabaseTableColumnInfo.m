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


#import "DBCDatabaseTableColumnInfo.h"
#import "DBCMacro.h"

@implementation DBCDatabaseTableColumnInfo

@synthesize colIdx, colName, colType, colNotNull, colDefValue, colIsPartOfPK;

#pragma mark DBCDatabaseTableColumnInfo instance initialization

/**
 * Initiate DBCDatabaseTableColumnInfo instance
 * @parameters
 *      int columnNumber           - column number inside columns sequence
 *      NSString *columnName       - column name
 *      NSString *columnDataType   - column data type
 *      BOOL isNotNull             - whether column in NOT NULL
 *      NSString *defaultVallue    - default column value
 *      BOOL isPartOfThePrimaryKey - whether column is part of the primary key
 * @return autoreleased DBCDatabaseTableColumnInfo instance
 */
+ (id)columnInfoWithSequence:(int)columnNumber columnName:(NSString*)columnName 
              columnDataType:(NSString*)columnDataType isNotNull:(BOOL)isNotNull defaultValue:(NSString*)defaultVallue 
       isPartOfThePrimaryKey:(BOOL)isPartOfThePrimaryKey {
    return [[[[self class] alloc] initolumnInfoWithSequence:columnNumber columnName:columnName 
                                             columnDataType:columnDataType isNotNull:isNotNull defaultValue:defaultVallue
                                      isPartOfThePrimaryKey:isPartOfThePrimaryKey] autorelease];
}

/**
 * Initiate DBCDatabaseTableColumnInfo instance
 * @parameters
 *      int columnNumber           - column number inside columns sequence
 *      NSString *columnName       - column name
 *      NSString *columnDataType   - column data type
 *      BOOL isNotNull             - whether column in NOT NULL
 *      NSString *defaultVallue    - default column value
 *      BOOL isPartOfThePrimaryKey - whether column is part of the primary key
 * @return DBCDatabaseTableColumnInfo instance
 */
- (id)initolumnInfoWithSequence:(int)columnNumber columnName:(NSString*)columnName 
                 columnDataType:(NSString*)columnDataType isNotNull:(BOOL)isNotNull defaultValue:(NSString*)defaultVallue
          isPartOfThePrimaryKey:(BOOL)isPartOfThePrimaryKey {
    if((self = [super init])){
        colIdx = columnNumber;
        colName = [columnName copy];
        colType = [columnDataType copy];
        colNotNull = isNotNull;
        colDefValue = [defaultVallue copy];
        colIsPartOfPK = isPartOfThePrimaryKey;
    }
    return self;
}

/**
 * Get formatted column description
 * @return formatted column description
 */
- (NSString*)description {
    return [NSString stringWithFormat:@"\nIn sequence column number: %i\nColumn name: %@\nColumn data type: %@\nColumn is\
 NOT NULL: %@\nColumn default value: %@\nColumn is part of the primary key: %@", colIdx, colName, colType, 
            colNotNull?@"YES":@"NO", colDefValue, colIsPartOfPK?@"YES":@"NO"];
}

#pragma mark DBCDatabaseIndexedColumnInfo memory management

/**
 * Deallocate indexed column information and release all retained memory
 */
- (void)dealloc {
    DBCReleaseObject(colName);
    DBCReleaseObject(colType);
    DBCReleaseObject(colDefValue);
    [super dealloc];
}

@end
