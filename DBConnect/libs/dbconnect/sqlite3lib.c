/**
 * The original code was taken from SQLite site http://www.sqlite.org
 */

#include "sqlite3lib.h"
#import "DBCAdditionalErrorCodes.h"

#if !defined(HAVE_EDITLINE) && (!defined(HAVE_READLINE) || HAVE_READLINE!=1)
# define readline(p) local_getline(p,stdin)
# define add_history(X)
# define read_history(X)
# define write_history(X)
# define stifle_history(X)
#endif

static char mainPrompt[20];    
static char continuePrompt[20];

#pragma mark SQL dump file import routine

/**
 * Compute a string length that is limited to what can be stored in
 * lower 30 bits of a 32-bit signed integer.
 * @parameters
 *      const char *z - string for computation
 * @return computed string length
 */
static int strlen30(const char *z){
    const char *z2 = z;
    while(*z2){z2++;}
    return 0x3fffffff&(int)(z2-z);
}

/**
 * Test to see if a line consists entirely of whitespace
 * @parameters
 *      const char *z - examination string
 * @return examination result
 */
static int _all_whitespace(const char *z){
    for(; *z; z++){
        if(isspace(*(unsigned char*)z)) continue;
        if(*z=='/' && z[1]=='*'){
            z+=2;
            while(*z&&(*z!='*'||z[1]!='/')){ z++; }
            if(*z==0)return 0;
            z++;
            continue;
        }
        if(*z=='-'&&z[1]=='-'){
            z+=2;
            while(*z&&*z!='\n'){ z++; }
            if(*z==0) return 1;
            continue;
        }
        return 0;
    }
    return 1;
}

/**
 * Return TRUE if the line typed in is an SQL command terminator other
 * than a semi-colon. The SQL Server style "go" command is understood
 * as is the Oracle "/".
 * @parameters
 *      const char *zLine - examination string
 * @return examination result
 */
static int _is_command_terminator(const char *zLine){
    while(isspace(*(unsigned char*)zLine) ){ zLine++; };
    if(zLine[0]=='/'&&_all_whitespace(&zLine[1])) return 1; // Oracle
    if(tolower(zLine[0])=='g'&&tolower(zLine[1])=='o'&&_all_whitespace(&zLine[2])) return 1; // SQL Server
    return 0;
}

/**
 * Return TRUE if a semicolon occurs anywhere in the first N characters
 * of string z[].
 * @prameters
 *     const char *z - string in which semicoln will be searched
 *     int N         - how much characters to check in string
 * @return semicolon search result
 */
static int _contains_semicolon(const char *z, int N){
    int i;
    for(i=0; i<N; i++){if(z[i]==';') return 1;}
    return 0;
}

/**
 * Return true if zSql is a complete SQL statement. Return false if it
 * ends in the middle of a string literal or C-style comment.
 * @parameters
 *      char *zSql - examination string
 *      int nSql - SQL line length
 * @return examination result
 */
static int _is_complete(char *zSql, int nSql){
    int rc;
    if(zSql==0) return 1;
    zSql[nSql] = ';';
    zSql[nSql+1] = 0;
    rc = sqlite3_complete(zSql);
    zSql[nSql] = 0;
    return rc;
}

/**
 * This routine reads a line of text from FILE dumpFile, stores
 * the text in memory obtained from malloc() and returns a pointer
 * to the text. NULL is returned at end of file, or if malloc()
 * fails.
 *
 * The interface is like "readline" but no command-line editing
 * is done.
 */
static char *local_getline(char *zPrompt, FILE *dumpFile){
    char *zLine;
    int nLine;
    int n;
    int eol;
    if(zPrompt&&*zPrompt ){
        printf("%s",zPrompt);
        fflush(stdout);
    }
    nLine = 100;
    zLine = malloc(nLine);
    if(zLine==0) return 0;
    n = 0;
    eol = 0;
    while(!eol){
        if(n+100>nLine){
            nLine = nLine*2 + 100;
            zLine = realloc(zLine, nLine);
            if(zLine==0) return 0;
        }
        if(fgets(&zLine[n], nLine - n, dumpFile)==0 ){
            if(n==0){
                free(zLine);
                return 0;
            }
            zLine[n] = 0;
            eol = 1;
            break;
        }
        while(zLine[n]){ n++; }
        if(n>0 && zLine[n-1]=='\n'){
            n--;
            if( n>0 && zLine[n-1]=='\r' ) n--;
            zLine[n] = 0;
            eol = 1;
        }
    }
    zLine = realloc( zLine, n+1 );
    return zLine;
}

/**
 * Retrieve a single line of input text.
 * @parameters
 *      const char *zPrior - is a string of prior text retrieved.  If not the 
 *                           empty string, then issue a continuation prompt.
 * @return single string from input file
 */
static char *one_input_line(const char *zPrior, FILE *dumpFile){
    char *zPrompt;
    char *zResult;
    if(dumpFile!=0) return local_getline(0, dumpFile);
    if(zPrior&&zPrior[0]) zPrompt = continuePrompt;
    else zPrompt = mainPrompt;
    zResult = readline(zPrompt);
#if defined(HAVE_READLINE) && HAVE_READLINE==1
    if( zResult && *zResult ) add_history(zResult);
#endif
    return zResult;
}

/**
 * Allocate space and save off current error string.
 * @prameters
 *     sqlite3 *targetDB - opened database connection to retrieve error from
 */
static char *save_err_msg(sqlite3 *targetDB){
    int nErrMsg = 1+strlen30(sqlite3_errmsg(targetDB));
    char *zErrMsg = sqlite3_malloc(nErrMsg);
    if(zErrMsg) memcpy(zErrMsg, sqlite3_errmsg(targetDB), nErrMsg);
    return zErrMsg;
}

/**
 * Execute a statement or set of statements.
 *
 * This is very similar to SQLite's built-in sqlite3_exec() 
 * function except it takes a slightly different callback 
 * and callback data argument.
 * @parameters
 *      sqlite3 *targetDB - opened database connection handler
 *      const char *sql  - SQL to be executed
 *      char **pzErrMsg   - Error message will be written here
 * @return SQL request execution result code
 */
static int sql_exec(sqlite3 *targetDB, const char *sql, char **pzErrMsg){
    sqlite3_stmt *statement = NULL;
    int returnCode = SQLITE_OK;
    const char *unusedSQLPortion = 0;
    
    if(pzErrMsg) *pzErrMsg = NULL;
    while(sql[0]&&returnCode==SQLITE_OK){
        returnCode = sqlite3_prepare_v2(targetDB, sql, -1, &statement, &unusedSQLPortion);
        if(returnCode != SQLITE_OK){
            if(pzErrMsg) *pzErrMsg = save_err_msg(targetDB);
        } else {
            if(!statement){
                sql = unusedSQLPortion;
                while(isspace(sql[0])) sql++;
                continue;
            }
            returnCode = sqlite3_step(statement);
            if(returnCode == SQLITE_ROW){
                do {
                    returnCode = sqlite3_step(statement);
                } while(returnCode == SQLITE_ROW);
            }
            returnCode = sqlite3_finalize(statement);
            if(returnCode==SQLITE_OK){
                sql = unusedSQLPortion;
                while(isspace(sql[0])) sql++;
            } else if(pzErrMsg){
                *pzErrMsg = save_err_msg(targetDB);
            }
        }
    }
    return returnCode;
}

/**
 * Execute SQL update commands list from file on opened database connection
 * @prameters
 *     sqlite3 *targetDB      - opened database connection handler
 *     const char *pathToFile - full path to file with SQL update commands list
 * @return sqlite exec result code and error information via structure
 */
int executeQueryFromFile(sqlite3 *targetDB, const char *pathToFile, int continueOnErrors, struct sqlite3lib_error *error){
    FILE *dumpFile = fopen(pathToFile, "rb");
    char *line = 0;
    char *sql = 0;
    int nSql = 0;
    int nSqlPrior = 0;
    char *zErrMsg;
    int lineNumber = 0;
    int startLine = 0;
    int errorCount = 0;
    int returnCode = SQLITE_ERROR;
    if(dumpFile==0) {
        error->errorLine = -1;
        error->errorCode = DBC_TARGET_FILE_MISSED;
        returnCode = SQLITE_ERROR;
        return returnCode;
    }
    while(errorCount==0||continueOnErrors){
        free(line);
        line = local_getline(0, dumpFile);
        if(line==0) break; // Reached EOF
        lineNumber++;
        if((sql==0 || sql[0]==0) && _all_whitespace(line)) continue;
        if(line&&line[0]=='.') continue;
        if(_is_command_terminator(line) && _is_complete(sql, nSql)) memcpy(line,";",2);
        nSqlPrior = nSql;
        if(sql==0){
            int i = 0;
            for(i=0;line[i]&&isspace((unsigned char)line[i]);i++){};
            if(line[i]!=0){
                nSql = strlen30(line);
                sql = malloc(nSql+3);
                if(sql==0){
                    error->errorCode = SQLITE_OOM;
                    free(sql);
                    free(line);
                    returnCode = SQLITE_ERROR;
                    fclose(dumpFile);
                    return returnCode;
                }
                memcpy(sql, line, nSql+1);
                startLine = lineNumber;
            }
        } else {
            int lenght = strlen30(line);
            sql = realloc(sql, nSql+lenght+4);
            if(sql==0){
                error->errorCode = SQLITE_OOM;
                free(sql);
                free(line);
                returnCode = SQLITE_ERROR;
                fclose(dumpFile);
                return returnCode;
            }
            sql[nSql++] = '\n';
            memcpy(&sql[nSql], line, lenght+1);
            nSql += lenght;
        }
        if(sql&&_contains_semicolon(&sql[nSqlPrior], nSql-nSqlPrior)&&sqlite3_complete(sql)){
            returnCode = sql_exec(targetDB, sql, &zErrMsg);
            if(returnCode||zErrMsg){
                if(dumpFile!=0){
                    error->errorLine = startLine;
                    error->errorCode = SQLITE_SYNTAX_ERROR;
                } else {
                    error->errorLine = -1;
                    error->errorCode = SQLITE_GENERAL_PROCESSING_ERROR;
                }
                if(zErrMsg!=0){
                    if(dumpFile!=0) 
                        snprintf(error->errorDescription, sizeof(error->errorDescription), "Error near line %d: %s", 
                                 error->errorLine, zErrMsg);
                    else snprintf(error->errorDescription, sizeof(error->errorDescription), "Error: %s", zErrMsg);
                    if(zErrMsg) sqlite3_free(zErrMsg);
                    zErrMsg = 0;
                } else {
                    if(dumpFile!=0) 
                        snprintf(error->errorDescription, sizeof(error->errorDescription), "Error near line %d: %s", 
                                 error->errorLine, sqlite3_errmsg(targetDB));
                    else 
                        snprintf(error->errorDescription, sizeof(error->errorDescription), "Error: %s", 
                                 sqlite3_errmsg(targetDB));
                }
                errorCount++;
            }
            if(sql) free(sql);
            sql = 0;
            nSql = 0;
        }
    }
    if(sql){
        if(!_all_whitespace(sql)) {
            snprintf(error->errorDescription, sizeof(error->errorDescription), "Error: incomplete SQL: %s", sql);
            error->errorCode = SQLITE_INCOMPLETE_REQUEST;
        }
        free(sql);
        errorCount++;
        returnCode = SQLITE_ERROR;
    }
    if(line) free(line);
    fclose(dumpFile);
    return returnCode;
}