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

+(id)resultWithPreparedStatement:(sqlite3_stmt*)statement encoding:(DBCDatabaseEncoding)databaseEncoding;
- (id)initWidthPreparedSatetement:(sqlite3_stmt*)statement encoding:(DBCDatabaseEncoding)databaseEncoding;

- (int)count;
- (NSArray*)columnNames;
- (void)addRowFromStatement:(sqlite3_stmt*)statement;
- (DBCDatabaseRow*)rowAtIndex:(int)rowIdx;

@end
