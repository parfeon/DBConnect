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

// Supported sqlite database encodings
typedef enum _DBCDatabaseEncoding {
    DBCDatabaseEncodingUTF8,
    DBCDatabaseEncodingUTF16
} DBCDatabaseEncoding;

// Supported sqlite database journaling modes
typedef enum _DBCDatabaseJournalingMode {
    DBCDatabaseJournalingModeDelete,
    DBCDatabaseJournalingModeTruncate,
    DBCDatabaseJournalingModePersist,
    DBCDatabaseJournalingModeMemory,
    DBCDatabaseJournalingModeOff
} DBCDatabaseJournalingMode;

// Supported sqlite database locking modes
typedef enum _DBCDatabaseLockingMode {
    DBCDatabaseLockingModeNormal,
    DBCDatabaseLockingModeExclusive
} DBCDatabaseLockingMode;

// Supported sqlite database transaction locks
typedef enum _DBCDatabaseTransactionLock {
    DBCDatabaseAutocommitModeDeferred,
    DBCDatabaseAutocommitModeImmediate,
    DBCDatabaseAutocommitModeExclusive
} DBCDatabaseTransactionLock;

// SQL statement parameters token format
typedef enum _SQLStatementFromat {
    SQLStatementFromatUnknown,
    SQLStatementFromatNSStringFormat,
    SQLStatementFromatAnonymousToken,
    SQLStatementFromatIndexedToken,
    SQLStatementFromatNamedToken
} SQLStatementFromat;

// SQLite lib error structure
struct sqlite3lib_error {
    char    errorDescription[400];
    int     errorLine;
    int     errorCode;
};