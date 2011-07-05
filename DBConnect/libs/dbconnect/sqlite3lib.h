/**
 * The original code was taken from SQLite site http://www.sqlite.org
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#import <sqlite3.h>
#import "DBCTypesAndStructs.h"

#ifdef HAVE_EDITLINE
# include <editline/editline.h>
#endif
#if defined(HAVE_READLINE) && HAVE_READLINE==1
# include <readline/readline.h>
# include <readline/history.h>
#endif

#pragma mark SQL dump file import routine

/**
 * Execute SQL update commands list from file on opened database connection
 * @prameters
 *     sqlite3 *targetDB      - opened database connection handler
 *     const char *pathToFile - full path to file with SQL update commands list
 * @return sqlite exec result code and error information via structure
 */
int executeQueryFromFile(sqlite3 *targetDB, const char *pathToFile, int continueOnErrors, struct sqlite3lib_error *error);