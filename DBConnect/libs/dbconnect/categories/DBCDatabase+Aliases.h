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

@interface DBCDatabase (DBCDatabase_Aliases)

#pragma mark SQLite database misc

- (BOOL)attachDatabase:(NSString*)dbFilePath databaseAttachName:(NSString*)dbAttachName;
- (BOOL)detachDatabase:(NSString*)attachedDatabaseName;
- (BOOL)setDatabaseEncoding:(DBCDatabaseEncoding)encoding;
- (DBCDatabaseEncoding)databaseEncoding;
- (BOOL)setUseCaseSensitiveLike:(BOOL)use;
- (BOOL)useCaseSensitiveLike;

#pragma mark DDL and DML methods

- (BOOL)dropTable:(NSString*)tableName inDatabase:(NSString*)databaseName;
- (BOOL)dropAllTablesInDatabase:(NSString*)databaseName;

#pragma mark Database information

- (int)tablesCount;
- (int)tablesCountInDatabase:(NSString*)databaseName;
- (NSArray*)tablesList;
- (NSArray*)tablesListForDatabase:(NSString*)databaseName;
- (NSArray*)tableInformation:(NSString*)tableName;
- (NSArray*)tableInformation:(NSString*)tableName forDatabase:(NSString*)databaseName;
- (NSArray*)databasesList;
- (NSArray*)indicesList:(NSString*)databaseName forTable:(NSString*)tableName;
- (NSArray*)indexedColumnsList:(NSString*)databaseName index:(NSString*)indexName;

@end
