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

#import "DBCDatabaseIndexedColumnInfo.h"
#import "DBCMacro.h"

@implementation DBCDatabaseIndexedColumnInfo

@synthesize colIdxInIndex, colIdxInTable, colName;

#pragma mark DBCDatabaseIndexedColumnInfo instance initialization

+ (id)indexedColumnInfoWithSequence:(int)columnIndexInIndex inTableSequenceNumber:(int)columnIndexInTable 
                               name:(NSString*)columnName {
    return [[[[self class] alloc] initIndexedColumnInfoWithSequence:columnIndexInIndex 
                                              inTableSequenceNumber:columnIndexInTable name:columnName] autorelease];
}

- (id)initIndexedColumnInfoWithSequence:(int)columnIndexInIndex inTableSequenceNumber:(int)columnIndexInTable 
                                   name:(NSString*)columnName {
    if((self = [super init])){
        colIdxInIndex = columnIndexInIndex;
        colIdxInTable = columnIndexInTable;
        colName = [columnName copy];
    }
    return self;
}

#pragma mark DBCDatabaseIndexedColumnInfo for NSLog

- (NSString*)description {
    return [NSString stringWithFormat:@"\nIn index column number: %i\nIn table column index: %i\nColumn name: %@", 
            colIdxInIndex, colIdxInTable, colName];
}

#pragma mark DBCDatabaseIndexedColumnInfo memory management

- (void)dealloc {
    DBCReleaseObject(colName);
    [super dealloc];
}

@end
