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


@interface DBCDatabaseTableColumnInfo : NSObject {
    int         colIdx;
    NSString    *colName;
    NSString    *colType;
    BOOL        colNotNull;
    NSString    *colDefValue;
    BOOL        colIsPartOfPK;
}
@property (nonatomic, readonly, getter = numberInSequence)int colIdx;
@property (nonatomic, readonly, getter = name)NSString *colName;
@property (nonatomic, readonly, getter = type)NSString *colType;
@property (nonatomic, readonly, getter = isNotNull)BOOL colNotNull;
@property (nonatomic, readonly, getter = defaultValue)NSString *colDefValue;
@property (nonatomic, readonly, getter = isPartOfThePrimaryKey)BOOL colIsPartOfPK;

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
       isPartOfThePrimaryKey:(BOOL)isPartOfThePrimaryKey;

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
- (id)initColumnInfoWithSequence:(int)columnNumber columnName:(NSString*)columnName 
                 columnDataType:(NSString*)columnDataType isNotNull:(BOOL)isNotNull defaultValue:(NSString*)defaultVallue 
          isPartOfThePrimaryKey:(BOOL)isPartOfThePrimaryKey;

#pragma mark DBCDatabaseTableColumnInfo for NSLog

/**
 * Get formatted column description
 * @return formatted column description
 */
- (NSString*)description;

#pragma mark DBCDatabaseIndexedColumnInfo memory management

/**
 * Deallocate indexed column information and release all retained memory
 */
- (void)dealloc;

@end
