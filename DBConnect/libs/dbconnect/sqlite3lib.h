/**
 * The original code was taken from SQLite site http://www.sqlite.org
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#import <sqlite3.h>
#import "sqlite3lib_ext.h"


#ifndef SQLITE_OOM
#define SQLITE_OOM 2000
#endif
#define SQLITE_SYNTAX_ERROR 2001
#define SQLITE_INCOMPLETE_REQUEST 2002

#ifdef HAVE_EDITLINE
# include <editline/editline.h>
#endif
#if defined(HAVE_READLINE) && HAVE_READLINE==1
# include <readline/readline.h>
# include <readline/history.h>
#endif

#pragma mark SQL dump file import routine

#if !defined(HAVE_EDITLINE) && (!defined(HAVE_READLINE) || HAVE_READLINE!=1)
# define readline(p) local_getline(p,stdin)
# define add_history(X)
# define read_history(X)
# define write_history(X)
# define stifle_history(X)
#endif

struct sqlite3lib_error {
    char    errorDescription[400];
    int     errorLine;
    int     errorCode;
};

int evaluateQueryFromFile(sqlite3 *targetDB, const char *pathToFile, int continueOnErrors, struct sqlite3lib_error *error);