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

+ (id)rowWithStatement:(sqlite3_stmt*)statement dataStructureDelegate:(id<DBCDatabaseResultStructure>)dsDelegate;
- (id)initRowWithStatement:(sqlite3_stmt*)statement dataStructureDelegate:(id<DBCDatabaseResultStructure>)dsDelegate;

- (int)columnsCount;
- (Class)dataTypeClassAtColumnIndex:(int)columnIdx;
- (Class)dataTypeClassForColumn:(NSString*)columnName;

- (int)intForColumn:(NSString*)columnName;
- (int)intForColumnAtIndex:(int)columnIdx;

- (long)longForColumn:(NSString*)columnName;
- (long)longForColumnAtIndex:(int)columnIdx;

- (long long)longLongForColumn:(NSString*)columnName;
- (long long)longLongForColumnAtIndex:(int)columnIdx;

- (BOOL)boolForColumn:(NSString*)columnName;
- (BOOL)boolForColumnAtIndex:(int)columnIdx;

- (float)floatForColumn:(NSString*)columnName;
- (float)floatForColumnAtIndex:(int)columnIdx;

- (double)doubleForColumn:(NSString*)columnName;
- (double)doubleForColumnAtIndex:(int)columnIdx;

- (id)objectForColumn:(NSString*)columnName;
- (id)objectForColumnAtIndex:(int)columnIdx;

- (NSString*)stringForColumn:(NSString*)columnName;
- (NSString*)stringForColumnAtIndex:(int)columnIdx;

- (NSDate*)dateForColumn:(NSString*)columnName;
- (NSDate*)dateForColumnAtIndex:(int)columnIdx;

- (NSData*)dataForColumn:(NSString*)columnName;
- (NSData*)dataForColumnAtIndex:(int)columnIdx;

@end
