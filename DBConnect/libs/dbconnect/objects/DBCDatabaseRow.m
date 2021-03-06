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

#import "DBCDatabaseRow.h"
#import "DBCDatabaseResult.h"
#import "DBCDatabase.h"
#import "DBCMacro.h"

@implementation DBCDatabaseRow

#pragma mark DBCDatabaseRow instance creation/initialization

+ (id)rowWithStatement:(sqlite3_stmt*)statement dataStructureDelegate:(id<DBCDatabaseResultStructure>)dsDelegate {
    return [[[[self class] alloc] initRowWithStatement:statement dataStructureDelegate:dsDelegate] autorelease];
}

- (id)initRowWithStatement:(sqlite3_stmt*)statement dataStructureDelegate:(id<DBCDatabaseResultStructure>)dsDelegate {
    if((self = [super init])){
        dataStructureDelegate = dsDelegate;
        columnsCount = [dataStructureDelegate columnsCount];
        if(columnsCount <= 0 ) columnsCount = sqlite3_column_count(statement);
        data = [[NSMutableArray alloc] initWithCapacity:columnsCount];
        int i = 0;
        for (i = 0; i < columnsCount; i++) {
            int columnType = sqlite3_column_type(statement, i);
            if(columnType != [dataStructureDelegate typeForColumnAtIndex:i]) {
               DBCDebugLogger(@"[DBC:WARNING] Column '%@' data type (%@) don't match to decalred in table structure (%@)",
                              [dataStructureDelegate nameForColumnAtIndex:i], DBCDatabaseDataTypeStringify(columnType),
                              [dataStructureDelegate stringifiedTypeForColumnAtIndex:i]);
            }
            if(columnType == SQLITE_INTEGER) {
                sqlite_int64 value = sqlite3_column_int64(statement, i);
                if(value >= INT32_MIN && value <= INT32_MAX) [data addObject:[NSNumber numberWithInt:value]];
                else [data addObject:[NSNumber numberWithLongLong:value]];
            } else if(columnType == SQLITE_FLOAT) {
                [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(statement, i)]];
            } else if(columnType == SQLITE_TEXT) {
                if([dataStructureDelegate databaseEncoding] == DBCDatabaseEncodingUTF16){
                    const void *value = sqlite3_column_text16(statement, i);
                    if(value != NULL) [data addObject:[NSString stringWithCString:(char*)value 
                                                                         encoding:NSUTF16StringEncoding]];
                    else [data addObject:[NSNull null]];
                }else {
                    const char *value = (const char*)sqlite3_column_text(statement, i);
                    if(value != NULL) [data addObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding]];
                    else [data addObject:[NSNull null]];
                }
            } else if(columnType == SQLITE_BLOB) {
                const void *value = sqlite3_column_blob(statement, i);
                int blobSize = sqlite3_column_bytes(statement, i);
                if(value != NULL) [data addObject:[NSData dataWithBytes:value length:blobSize]];
                else [data addObject:[NSNull null]];
            } else if(columnType == SQLITE_NULL) [data addObject:[NSNull null]];
        }
    }
    return self;
}

#pragma mark DBCDatabaseRow for NSLog

- (NSString *)description {
    return [data componentsJoinedByString:@" | "];
}

#pragma mark DBCDatabaseRow setters/getters

- (int)columnsCount {
    return [data count];
}

- (Class)dataTypeClassForColumn:(NSString*)columnName {
    if(dataStructureDelegate == nil) return nil;
    return [self dataTypeClassAtColumnIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (Class)dataTypeClassAtColumnIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return nil;
    if([[data objectAtIndex:columnIdx] isMemberOfClass:[NSNumber class]]) return [NSNumber class];
    if([[data objectAtIndex:columnIdx] isMemberOfClass:[NSString class]]) return [NSString class];
    if([[data objectAtIndex:columnIdx] isMemberOfClass:[NSData class]]) return [NSData class];
    if([[data objectAtIndex:columnIdx] isKindOfClass:[NSNumber class]]) return [NSNumber class];
    if([[data objectAtIndex:columnIdx] isKindOfClass:[NSString class]]) return [NSString class];
    if([[data objectAtIndex:columnIdx] isKindOfClass:[NSData class]]) return [NSData class];
    return nil;
}

- (int)intForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return -1;
    return [self intForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (int)intForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return -1;
    return [[data objectAtIndex:columnIdx] intValue];
}

- (NSInteger)integerForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return -1;
    return [self integerForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (NSInteger)integerForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return -1;
    return [[data objectAtIndex:columnIdx] integerValue];
}

- (NSUInteger)unsignedIntegerForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return 0;
    return [self unsignedIntegerForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (NSUInteger)unsignedIntegerForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return 0;
    return [[data objectAtIndex:columnIdx] unsignedIntegerValue];
}

- (long)longForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return -1;
    return [self longForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (long)longForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return -1;
    return [[data objectAtIndex:columnIdx] longValue];
}

- (long long)longLongForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return -1;
    return [self longLongForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (long long)longLongForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return -1;
    return [[data objectAtIndex:columnIdx] longLongValue];
}

- (BOOL)boolForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return NO;
    return [self boolForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (BOOL)boolForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return NO;
    return [[data objectAtIndex:columnIdx] intValue] != 0;
}

- (float)floatForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return -1.0f;
    return [self floatForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (float)floatForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return -1.0f;
    return [[data objectAtIndex:columnIdx] floatValue];
}

- (double)doubleForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return -1.0f;
    return [self doubleForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (double)doubleForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return -1.0f;
    return [[data objectAtIndex:columnIdx] doubleValue];
}

- (id)objectForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return nil;
    return [self objectForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (id)objectForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return nil;
    return [data objectAtIndex:columnIdx];
}

- (NSString*)stringForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return nil;
    return [self stringForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (NSString*)stringForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return nil;
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSString class]) 
        return [data objectAtIndex:columnIdx];
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSNull class]) 
        return @"null";
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSData class]) 
        return [[[NSString alloc] initWithBytes:(NSData*)[data objectAtIndex:columnIdx] 
                                        length:[(NSData*)[data objectAtIndex:columnIdx] length] 
                                      encoding:NSUTF8StringEncoding] autorelease];
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSNumber class]) 
        return [(NSNumber*)[data objectAtIndex:columnIdx] stringValue];
    return nil;
}

- (NSDate*)dateForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return nil;
    return [self dateForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (NSDate*)dateForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return nil;
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSNull class]) return nil;
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnAtIndex:columnIdx]];
}

- (NSData*)dataForColumn:(NSString*)columnName {
    // This condition should not happen
    if(dataStructureDelegate == nil) return nil;
    return [self dataForColumnAtIndex:[dataStructureDelegate indexForColumn:columnName]];
}

- (NSData*)dataForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [data count]) return nil;
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSNull class]) return nil;
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSData class]) return [data objectAtIndex:columnIdx];
    if([self dataTypeClassAtColumnIndex:columnIdx] == [NSString class]) {
        if([[data objectAtIndex:columnIdx] canBeConvertedToEncoding:NSUTF8StringEncoding])
            return [[data objectAtIndex:columnIdx] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark DBCDatabaseRow memory management

- (void)dealloc{
    dataStructureDelegate = nil;
    DBCReleaseObject(data);
    [super dealloc];
}

@end
