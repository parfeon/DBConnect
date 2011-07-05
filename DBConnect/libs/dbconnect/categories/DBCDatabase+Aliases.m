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

#import "DBCDatabase+Aliases.h"
#import "DBCDatabase+Advanced.h"

@implementation DBCDatabase (DBCDatabase_Aliases)

#pragma mark SQLite database misc

- (BOOL)attachDatabase:(NSString*)dbFilePath databaseAttachName:(NSString*)dbAttachName error:(DBCError**)error {
    return [self executeUpdate:[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS %@", dbFilePath, dbAttachName] 
                         error:error, nil];
}

- (BOOL)detachDatabase:(NSString*)attachedDatabaseName error:(DBCError**)error {
    return [self executeUpdate:[NSString stringWithFormat:@"DETACH DATABASE %@", attachedDatabaseName] error:error, nil];
}

- (BOOL)setDatabaseEncoding:(DBCDatabaseEncoding)encoding error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    NSString *enc = encoding==DBCDatabaseEncodingUTF8?@"UTF-8":encoding==DBCDatabaseEncodingUTF16?@"UTF-16":@"UTF-8";
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA encoding = '%@';", enc] error:error, nil];
}

- (DBCDatabaseEncoding)databaseEncodingError:(DBCError**)error {
    if(!dbConnectionOpened) return DBCDatabaseEncodingUTF8;
    DBCDatabaseResult *result = [self executeQuery:@"PRAGMA encoding;" error:error, nil];
    if([result count] > 0) {
        NSString *rowEncoding = [[[result rowAtIndex:0] stringForColumn:@"encoding"] lowercaseString];
        return [@"utf-8" isEqualToString:rowEncoding]?DBCDatabaseEncodingUTF8:DBCDatabaseEncodingUTF16;
    }
    return DBCDatabaseEncodingUTF8;
}

- (BOOL)setUseCaseSensitiveLike:(BOOL)use error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA case_sensitive_like = %d;", (use?1:0)] 
                         error:error, nil];
}

#pragma mark DDL and DML methods

- (BOOL)dropTable:(NSString*)tableName inDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    if(inMemoryDB) return [self executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@.%@;", databaseName, 
                                               tableName] error:error, nil];
    return [self executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@.%@; VACUUM;", databaseName, tableName]
                         error:error, nil];
}

- (BOOL)dropAllTablesInDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    NSArray *listOfTables = [self tablesListForDatabase:databaseName error:error];
    NSMutableString *sqlStatement = [NSMutableString string];
    int i, count = [listOfTables count];
    if(count == 0) return YES;
    for (i = 0; i < count; i++) [sqlStatement appendFormat:@"DROP TABLE IF EXISTS %@.%@;", databaseName, 
                                 [listOfTables objectAtIndex:i]];
    BOOL dropped = [self executeUpdate:sqlStatement error:error, nil];
    if(!inMemoryDB && [self freePagesCountInDatabase:databaseName error:error] > 0) [self freeUnusedPagesError:NULL];
    return dropped;
}

#pragma mark Database information

- (int)tablesCountError:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    NSMutableString *selectStatement = [NSMutableString stringWithString:@"SELECT "];
    NSArray *listOfDatabases = [self databasesListError:error];
    int i, count = [listOfDatabases count];
    for (i = 0; i < count; i++) {
        DBCDatabaseInfo *dbInfo = [listOfDatabases objectAtIndex:i];
        [selectStatement appendFormat:@"(SELECT count(*) AS count FROM %@.sqlite_master WHERE type IN ('table','view') \
AND name NOT LIKE 'sqlite_%%') %@", 
         [dbInfo name], (i==(count-1)?@"":@"+ ")];
    }
    [selectStatement appendString:@"AS count;"];
    DBCDatabaseResult *result = [self executeQuery:selectStatement error:error, nil, nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"count"];
    return -1;
}

- (int)tablesCountInDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"SELECT count(*) AS count FROM \
%@.sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%%';", databaseName] error:error, nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"count"];
    return -1;
}

- (NSArray*)tablesListError:(DBCError**)error {
    if(!dbConnectionOpened) return nil;
    NSMutableArray *listOfTables = nil;
    DBCDatabaseResult *result = [self executeQuery:@"SELECT name FROM sqlite_master WHERE type IN ('table','view') AND \
name NOT LIKE 'sqlite_%%';" error:error, nil];
    if(result != nil){
        listOfTables = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            NSString *tableName = [row stringForColumn:@"name"];
            if(tableName != nil) [listOfTables addObject:tableName];
        }
    }
    return listOfTables;
}

- (NSArray*)tablesListForDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return nil;
    NSMutableArray *listOfTables = nil;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"SELECT name FROM %@.sqlite_master WHERE \
type IN ('table','view') AND name NOT LIKE 'sqlite_%%';", databaseName] error:error, nil];
    if(result != nil){
        listOfTables = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            NSString *tableName = [row stringForColumn:@"name"];
            if(tableName != nil) [listOfTables addObject:tableName];
        }
    }
    return listOfTables;
}

- (NSArray*)tableInformation:(NSString*)tableName error:(DBCError**)error {
    return [self tableInformation:tableName forDatabase:nil error:error];
}

- (NSArray*)tableInformation:(NSString*)tableName forDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return nil;
    if(databaseName == nil) databaseName = @"main";
    NSMutableArray *listOfColumns = nil;
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.table_info(%@);", databaseName, 
                                                    tableName] error:error, nil];
    if(result != nil){
        listOfColumns = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
           [listOfColumns addObject:[DBCDatabaseTableColumnInfo columnInfoWithSequence:[row intForColumn:@"cid"]
                                                                            columnName:[row stringForColumn:@"name"]
                                                                        columnDataType:[row stringForColumn:@"type"]
                                                                             isNotNull:[row boolForColumn:@"notnull"]
                                                                          defaultValue:[row stringForColumn:@"dflt_value"]
                                                                 isPartOfThePrimaryKey:[row boolForColumn:@"pk"]]];
        }
    }
    return listOfColumns;
}

- (NSArray*)databasesListError:(DBCError**)error {
    if(!dbConnectionOpened) return nil;
    DBCDatabaseResult *result = [self executeQuery:@"PRAGMA database_list" error:error, nil];
    NSMutableArray *listOfDatabases = nil;
    if (result != nil) {
        listOfDatabases = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            [listOfDatabases addObject:[DBCDatabaseInfo databaseInfoWithSequence:[row intForColumn:@"seq"] 
                                                                            name:[row stringForColumn:@"name"] 
                                                                        filePath:[row stringForColumn:@"file"]]];
        }
    }
    return listOfDatabases;
}

- (NSArray*)indicesList:(NSString*)databaseName forTable:(NSString*)tableName error:(DBCError**)error {
    if(!dbConnectionOpened) return nil;
    if(tableName == nil) return nil;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.index_list(%@)", databaseName, 
                                                    tableName] error:error, nil];
    NSMutableArray *listOfIndices = nil;
    if (result != nil) {
        listOfIndices = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            [listOfIndices addObject:[DBCDatabaseIndexInfo indexInfoWithSequence:[row intForColumn:@"seq"] 
                                                                            name:[row stringForColumn:@"name"] 
                                                                          unique:[row boolForColumn:@"unique"]]];
        }
    }
    return listOfIndices;
}

- (NSArray*)indexedColumnsList:(NSString*)databaseName index:(NSString*)indexName error:(DBCError**)error {
    if(!dbConnectionOpened) return nil;
    if(indexName == nil) return nil;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.index_info(%@)", databaseName, 
                                                    indexName] error:error, nil];
    NSMutableArray *listOfIndixedColumns = nil;
    if (result != nil) {
        listOfIndixedColumns = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            [listOfIndixedColumns addObject:[DBCDatabaseIndexedColumnInfo 
                                             indexedColumnInfoWithSequence:[row intForColumn:@"seqno"]
                                             inTableSequenceNumber:[row intForColumn:@"cid"]
                                             name:[row stringForColumn:@"name"]]];
        }
    }
    return listOfIndixedColumns;
}

@end
