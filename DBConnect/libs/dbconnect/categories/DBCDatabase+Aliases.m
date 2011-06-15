//
//  DBCDatabase+Aliases.m
//  DBConnect
//
//  Created by Sergey Mamontov on 6/11/11.
//  Copyright 2011 Tattooed Orange. All rights reserved.
//

#import "DBCDatabase+Aliases.h"


@implementation DBCDatabase (DBCDatabase_Aliases)

#pragma mark SQLite database misc

/**
 * Attach sqlite database from file with defined database name to current 
 * database connection
 * @parameters
 *      NSString *dbFilePath    - slqite database file path
 *      NSString *dbAttachName  - name for attached database
 * @return whether attach was successfull or not
 */
- (BOOL)attachDatabase:(NSString*)dbFilePath databaseAttachName:(NSString*)dbAttachName {
    return [self evaluateUpdate:[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS %@", dbFilePath, dbAttachName], nil];
}

/**
 * Detach sqlite database from current database connection
 * @parameters
 *      NSString *attachedDatabaseName  - name of attached database
 * @return whether detach was successfull or not
 */
- (BOOL)detachDatabase:(NSString*)attachedDatabaseName {
    return [self evaluateUpdate:[NSString stringWithFormat:@"DETACH DATABASE %@", attachedDatabaseName], nil];
}

/**
 * Set encoding which used by database for data encoding or store
 * @parameters
 *      NSString *dbEncoding - new encoding
 * @return whether set was successfull or not
 */
- (BOOL)setDatabaseEncoding:(DBCDatabaseEncoding)encoding {
    if(!dbConnectionOpened) return NO;
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA encoding = '%@';", 
                                 encoding==DBCDatabaseEncodingUTF8?@"UTF-8":encoding==DBCDatabaseEncodingUTF16?@"UTF-16":@"UTF-8"], nil];
}

/**
 * Get current database connection encoding
 * @return current database connection encoding
 */
- (DBCDatabaseEncoding)databaseEncoding {
    if(!dbConnectionOpened) return DBCDatabaseEncodingUTF8;
    DBCDatabaseResult *result = [self evaluateQuery:@"PRAGMA encoding;", nil];
    if([result count] > 0) {
        NSString *rowEncoding = [[[result rowAtIndex:0] stringForColumn:@"encoding"] lowercaseString];
        return [@"utf-8" isEqualToString:rowEncoding]?DBCDatabaseEncodingUTF8:DBCDatabaseEncodingUTF16;
    }
    return DBCDatabaseEncodingUTF8;
}

/**
 * Set whether use case-sensitive behaviour of built-in LIKE expression or not
 * @parameters
 *      BOOL use - condition flag
 * @default default state is set to NO
 * @return whether set was successfull or not
 */
- (BOOL)setUseCaseSensitiveLike:(BOOL)use {
    if(!dbConnectionOpened) return NO;
    return [self evaluateUpdate:@"PRAGMA case_sensitive_like = %d;", (use?1:0), nil];
}

/**
 * Get whether should use case-sensitive behaviour of built-in LIKE expression or not
 * @return should use case-sensitive behaviour of built-in LIKE expression or not
 */
- (BOOL)useCaseSensitiveLike {
    if(!dbConnectionOpened) return NO;
    DBCDatabaseResult *result = [self evaluateQuery:@"PRAGMA case_sensitive_like;", nil];
    if([result count] > 0){
        return [[result rowAtIndex:0] boolForColumn:@"case_sensitive_like"];
    }
    return NO;
}

#pragma mark DDL and DML methods

/**
 * Drop specified table in provided database and clean up space after table
 * @parameters
 *      NSString *tableName    - table which will be removed
 *      NSString *databaseName - target database
 * WARNING: ROWID values may be reset
 * @return whether table was dropped or not
 */
- (BOOL)dropTable:(NSString*)tableName inDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return NO;
    return [self evaluateUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@.%@; VACUUM;", databaseName, tableName], nil];
}

/**
 * Drop all tables in specified database
 * @parameters
 *      NSString *databaseName - target database
 * WARNING: ROWID values may be reset
 * @return whether tables was dropped or not
 */
- (BOOL)dropAllTablesInDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return NO;
    NSArray *listOfTables = [self tablesListForDatabase:databaseName];
    NSMutableString *sqlStatement = [NSMutableString string];
    int i, count = [listOfTables count];
    if(count == 0) return YES;
    for (i = 0; i < count; i++) [sqlStatement appendFormat:@"DROP TABLE IF EXISTS %@.%@;", databaseName, [listOfTables objectAtIndex:i]];
    [sqlStatement appendString:@"VACUUM;"];
    return [self evaluateUpdate:sqlStatement, nil];
}

#pragma mark Database information

/**
 * Get number of tables in current and attached databases
 * @return number of tables in current and attached databases
 */
- (int)tablesCount {
    if(!dbConnectionOpened) return -1;
    NSMutableString *selectStatement = [NSMutableString stringWithString:@"SELECT "];
    NSArray *listOfDatabases = [self databasesList];
    int i, count = [listOfDatabases count];
    for (i = 0; i < count; i++) {
        DBCDatabaseInfo *dbInfo = [listOfDatabases objectAtIndex:i];
        [selectStatement appendFormat:@"(SELECT count(*) FROM %@.sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%%') %@", 
         [dbInfo name], (i==(count-1)?@"":@"+ ")];
    }
    [selectStatement appendString:@"AS count;"];
    DBCDatabaseResult *result = [self evaluateQuery:selectStatement, nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"count"];
    return -1;
}

/**
 * Get number of tables in database by it's name
 * @parameters
 *      NSString *databaseName - database name
 * @return number of tables in provided database
 */
- (int)tablesCountInDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"SELECT count(*) AS count FROM %@.sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%%';", databaseName], nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"count"];
    return -1;
}

/**
 * Get list of tables for current database connection
 * @return list of tables stored in main database of current database connection
 */
- (NSArray*)tablesList {
    if(!dbConnectionOpened) return nil;
    NSMutableArray *listOfTables = nil;
    DBCDatabaseResult *result = [self evaluateQuery:@"SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%%';", nil];
    if(result != nil){
        listOfTables = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            NSString *tableName = [row stringForColumn:@"name"];
            if(tableName != nil) [listOfTables addObject:tableName];
        }
    }
    return listOfTables;
}

/**
 * Get list of tables in database by it's name
 * @parameters
 *      NSString *databaseName - database name
 * @return list of tables stored in provided database
 */
- (NSArray*)tablesListForDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return nil;
    NSMutableArray *listOfTables = nil;
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"SELECT name FROM %@.sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%%';", databaseName], nil];
    if(result != nil){
        listOfTables = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            NSString *tableName = [row stringForColumn:@"name"];
            if(tableName != nil) [listOfTables addObject:tableName];
        }
    }
    return listOfTables;
}

/**
 * Get list of columns information for specified table in current database connection
 * @parameters
 *      NSString *tableName - target table name
 * @return list of columns information for specified table in main database of 
 * current database connection
 */
- (NSArray*)tableInformation:(NSString*)tableName {
    if(!dbConnectionOpened) return nil;
    NSMutableArray *listOfColumns = nil;
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@);", tableName], nil];
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

/**
 * Get list of columns information for specified table in database by it's name
 * @parameters
 *      NSString *tableName    - target table name
 *      NSString *databaseName - database name
 * @return list of columns information for specified table in provided database
 */
- (NSArray*)tableInformation:(NSString*)tableName forDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return nil;
    NSMutableArray *listOfColumns = nil;
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.table_info(%@);", databaseName, tableName], nil];
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

/**
 * Get databases list
 * @return array of databases
 */
- (NSArray*)databasesList {
    if(!dbConnectionOpened) return nil;
    DBCDatabaseResult *result = [self evaluateQuery:@"PRAGMA database_list", nil];
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

/**
 * Get indices list
 * @parameters
 *      NSString *databaseName - target database name
 *      NSString *tableName    - target table name
 * @return array of indices for specified table
 */
- (NSArray*)indicesList:(NSString*)databaseName forTable:(NSString*)tableName {
    if(!dbConnectionOpened) return nil;
    if(tableName == nil) return nil;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.index_list(%@)", databaseName, tableName], nil];
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

/**
 * Get indexed columns list
 * @parameters
 *      NSString *databaseName - target database name
 *      NSString *indexName    - target index name
 * @return array of indexed columns for specified table
 */
- (NSArray*)indexedColumnsList:(NSString*)databaseName index:(NSString*)indexName {
    if(!dbConnectionOpened) return nil;
    if(indexName == nil) return nil;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.index_info(%@)", databaseName, indexName], nil];
    NSMutableArray *listOfIndixedColumns = nil;
    if (result != nil) {
        listOfIndixedColumns = [NSMutableArray arrayWithCapacity:[result count]];
        for (DBCDatabaseRow *row in result) {
            [listOfIndixedColumns addObject:[DBCDatabaseIndexedColumnInfo indexedColumnInfoWithSequence:[row intForColumn:@"seqno"] 
                                                                                  inTableSequenceNumber:[row intForColumn:@"cid"] 
                                                                                                   name:[row stringForColumn:@"name"]]];
        }
    }
    return listOfIndixedColumns;
}

@end
