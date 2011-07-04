#__DBCDatabase Aliases Category Reference__  
[SQLitews]:http://www.sqlite.org  
[MAS]:http://www.apple.com/mac/app-store/  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseInfoCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseInfo  
[DBCDatabaseIndexInfoCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseIndexInfo  
[DBCDatabaseTableColumnInfoCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseTableColumnInfo  
[DBCDatabaseIndexedColumnInfoCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseIndexedColumnInfo  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabase+Advanced]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Advanced  
[DBCErrorCR]:https://github.com/parfeon/DBConnect/wiki/DBCError  
[DBCDatabaseEncodingUTF8c]:https://github.com/parfeon/DBConnect/wiki/Constants#DBCDatabaseEncodingUTF8
[ConstantsEncoding]:https://github.com/parfeon/DBConnect/wiki/Constants#DBCDatabaseEncoding
<a name="top"/><font size="6">__Overview__</font>  
This category contains some basic alias methods for common tasks, but was separated into category to keep autocomplete from showing you methods, which you probably will use or may not.  
There are one more category for [DBCDatabase][DBCDatabaseCR] [Advanced][DBCDatabase+Advanced], this categories was created thematically on their purposes.  
Aliases category adds mostly information aliases and few DML and DDL aliases methods, which can be evaluated to [sqlite][SQLitews] database.  
  
##__Tasks__  
###__Database misc alias methods__  
<a href="#m1">- attachDatabase:databaseAttachName:error:</a>  
<a href="#m2">- detachDatabase:error:</a>  
<a href="#m3">- setDatabaseEncoding:error:</a>  
<a href="#m4">- databaseEncodingError:</a>  
<a href="#m5">- setUseCaseSensitiveLike:error</a>  
###__DDL and DML alias methods__  
<a href="#m7">- dropTable:inDatabase:error:</a>  
<a href="#m8">- dropAllTablesInDatabase:error:</a>  
###__Database information alias methods__  
<a href="#m9">- tablesCountError:</a>  
<a href="#m10">- tablesCountInDatabase:error:</a>  
<a href="#m11">- tablesListError:</a>  
<a href="#m12">- tablesListForDatabase:error:</a>  
<a href="#m13">- tableInformation:error:</a>  
<a href="#m14">- tableInformation:forDatabase:error:</a>  
<a href="#m15">- databasesListError:</a>  
<a href="#m16">- indicesList:forTable:error:</a>  
<a href="#m17">- indexedColumnsList:index:error:</a>  

##__Instance methods__  
  
<font size="4"><a name="m1"/>attachDatabase:databaseAttachName:error:</font>  
  
Method allows you to attach database from file or temporary database to _main_ database w/o writing SQL statements.  
  
<pre>- (BOOL)attachDatabase:(NSString*)<i>dbFilePath</i> databaseAttachName:(NSString*)<i>dbAttachName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_dbFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] database source can be specified as: `path`, `file`, `":memory:"`, `""` or `nil`.  
_dbAttachName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name for attached database. You will use this name, when you need to query or update data in specified database.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database was successfully attached, otherwise `NO`.  
  
__Discussion__  
It is possible to use `in-memory` or temporary stored databases for attachment. If provided file path don't exists, than it will be created.  
If _main_ database was opened with _read-only_/_read-write_ access, than all attached databases will have same access level.  
All attached databases must have same encoding as _main_ or you'll get an error.  
After attachment, all access to attached database should be done via provided _database name_ which was used when attached.  
If [sqlite][SQLitews] database connection was opened in _read-write_ access mode and database file for attachment placed in folder, where it can't be accessed for _read-write_ access mode (application bundle for example) than you'' get an error.  
  
<a name="m1e"/>__How to use__  
In this example we will attach existing database to database, created in this [example][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR] into newly created database.  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSError</font> *fmError = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSFileManager</font> *fileManager = [<font color="#7243a4">NSFileManager</font> <font color="#43277c">defaultManager</font>];
<font color="#7243a4">NSString</font> *docDir = [<font color="#43277c">NSSearchPathForDirectoriesInDomains</font>(<font color="#43277c">NSDocumentDirectory</font>, <font color="#43277c">NSUserDomainMask</font>, <font color="#b7359d">YES</font>)
                    <font color="#43277c">objectAtIndex</font>:0];
if (![fileManager <font color="#43277c">fileExistsAtPath</font>:[docDir <font color="#43277c">stringByAppendingPathComponent</font>:<font color="#cb3229">@"test.sqlite"</font>]]) {
    [fileManager <font color="#43277c">copyItemAtPath</font>:[[<font color="#7243a4">NSBundle</font> <font color="#43277c">mainBundle</font>] <font color="#43277c">pathForResource</font>:<font color="#cb3229">@"test"</font> <font color="#43277c">ofType</font>:<font color="#cb3229">@"sqlite"</font>] 
                          <font color="#43277c">toPath</font>:[docDir <font color="#43277c">stringByAppendingPathComponent:</font><font color="#cb3229">@"test.sqlite"</font>] <font color="#43277c">error</font>:&fmError];
}
[db <font color="#38595d">attachDatabase</font>:[docDir <font color="#43277c">stringByAppendingPathComponent</font>:<font color="#cb3229">@"test.sqlite"</font>] <font color="#38595d">databaseAttachName</font>:<font color="#cb3229">@"aTest"</font> 
             <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- detachDatabase:error:</a>  
<a href="#m3">- setDatabaseEncoding:error:</a>  
<a href="#m4">- databaseEncodingError:</a>  
<a href="#m5">- setUseCaseSensitiveLike:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m2"/>detachDatabase:error:</font>  
  
Method allows you to detach attached earlier database w/o writing SQL statements.  
  
<pre>- (BOOL)detachDatabase:(NSString*)<i>attachedDatabaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_attachedDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name which was used to attach desired database file to _main_ database.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database was successfully detached, otherwise `NO`.  
  
__Discussion__  
This method simply detach attached earlier database w/o writing SQL statements. In case of temporary databases, all data will be lost.
Don't try to issue detach method inside transaction or you'll get an error.  
  
__How to use__  
In this example, we will use results from <a href="#m1e">example</a>, shown earlier and detach `aTest` database:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">detachDatabase</font>:<font color="#cb3229">@"aTest"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m1">- attachDatabase:databaseAttachName:error:</a>  
<a href="#m3">- setDatabaseEncoding:error:</a>  
<a href="#m4">- databaseEncodingError:</a>  
<a href="#m5">- setUseCaseSensitiveLike:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m3"/>setDatabaseEncoding:error:</font>  
  
Method allows you to change _main_ database encoding w/o writing SQL statements.  
  
<pre>- (BOOL)setDatabaseEncoding:(DBCDatabaseEncoding)<i>encoding</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_encoding_  
&nbsp;&nbsp;&nbsp;&nbsp;New [sqlite][SQLitews] database encoding. [DBCDatabaseEncodingUTF8][DBCDatabaseEncodingUTF8c] preferred encoding.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database encoding was successfully changed, otherwise `NO`.  
  
__Discussion__  
Method allows you to change _main_ database connection encoding w/o writing SQL statements. You can set encodings only for _main_ database and only before database was initialized.  
This method can't be called on database with _read-only_ access.  
Encoding controls how strings are encoded and stored in a database.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show how to set new encoding for database, we will set default [DBCDatabaseEncodingUTF8][DBCDatabaseEncodingUTF8c] encoding:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setDatabaseEncoding</font>:<font color="#38595d">DBCDatabaseEncodingUTF8</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
error = <font color="#b7359d">nil</font>;
<font color="#38595d">DBCDatabaseEncoding</font> encoding = [db <font color="#38595d">databaseEncodingError</font>:&error];
</pre>

__See Also__  
<a href="#m1">- attachDatabase:databaseAttachName:error:</a>  
<a href="#m2">- detachDatabase:error:</a>  
<a href="#m4">- databaseEncodingError:</a>  
<a href="#m5">- setUseCaseSensitiveLike:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m4"/>databaseEncodingError:</font>  
  
Method allows you to retrieve _main_ database encoding w/o writing SQL statements.   
  
<pre>- (DBCDatabaseEncoding)databaseEncodingError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
_Main_ [sqlite][SQLitews] database [encoding][ConstantsEncoding].  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show how to retrieve database encoding:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#38595d">DBCDatabaseEncoding</font> encoding = [db <font color="#38595d">databaseEncodingError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m1">- attachDatabase:databaseAttachName:error:</a>  
<a href="#m2">- detachDatabase:error:</a>  
<a href="#m3">- setDatabaseEncoding:error:</a>  
<a href="#m5">- setUseCaseSensitiveLike:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m5"/>setUseCaseSensitiveLike:error:</font>  
  
Method allows you to change case-sensitivity behavior for built-in LIKE expression w/o writing SQL statements.  
  
<pre>- (BOOL)setUseCaseSensitiveLike:(BOOL)<i>use</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_use_  
&nbsp;&nbsp;&nbsp;&nbsp;If set to `YES` than built-in LIKE will take into account string case, otherwise will ignore it.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if case-sensitivity flag was successfully changed, otherwise `NO`.  
  
__Discussion__  
Method allows you to change built-in LIKE expression behavior with case-sensitivity when comparing strings w/o writing SQL statements.  
This method can't be called on database with _read-only_ access.  
By default value set to `NO` and this means what comparator will ignore letter case.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to set this flag and how it affect on queries with text matching:
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#008123">// This select will return result</font>
<font color="#547f85">DBCDatabaseResult</font> *result = [db <font color="#38595d">executeQuery</font>:<font color="#cb3229">@"SELECT * FROM test WHERE pTitle LIKE ?1"</font>
                                       error</font>:&error, <font color="#cb3229">@"cupertino"</font>, <font color="#b7359d">nil</font>];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, result);
}

<font color="#008123">/* Output:
    Result for: SELECT * FROM test WHERE pTitle LIKE ?1;
    Query execution done in 0.000000s
    Found: 1 records
    Column names: pid | ptype | ptitle | loc_lat | loc_lon
    Result rows: (
        "1 | City | Cupertino | 37.3261 | -122.032"
    )
*/</font>

error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setUseCaseSensitiveLike</font>:<font color="#b7359d">YES</font> <font color="#38595d">error</font>:&error];
<font color="#008123">// This select won't return any result because it can't math 'cupertino' to 'Cupertino'</font>
<font color="#547f85">DBCDatabaseResult</font> *result = [db <font color="#38595d">executeQuery</font>:<font color="#cb3229">@"SELECT * FROM test WHERE pTitle LIKE ?1"</font>
                                       error</font>:&error, <font color="#cb3229">@"cupertino"</font>, <font color="#b7359d">nil</font>];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, result);
}

<font color="#008123">/* Output:
    Result for: SELECT * FROM test WHERE pTitle LIKE ?1;
    Query execution done in 0.000000s
    Found: 0 records
    Column names: pid | ptype | ptitle | loc_lat | loc_lon
    Result rows: (
    )
*/</font>
</pre>

__See Also__  
<a href="#m1">- attachDatabase:databaseAttachName:error:</a>  
<a href="#m2">- detachDatabase:error:</a>  
<a href="#m3">- setDatabaseEncoding:error:</a>  
<a href="#m4">- databaseEncodingError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m7"/>dropTable:inDatabase:error:</font>  
  
Method allows you to drop table in specified database w/o writing SQL statements.  
  
<pre>- (BOOL)dropTable:(NSString*)<i>tableName</i> inDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_tableName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of the table, which should be dropped.  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database from which will be dropped table. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if table was successfully dropped, otherwise `NO`.  
  
__Discussion__  
This method allows you to remove specific table from specified database w/o writing SQL statements. In case of [sqlite][SQLitews] after something was removed from database, database file won't reduce in size. So if you simply remove table with large number of records, database file will still the same size as before removing. This method solves this problem, but in some cases it may lead to ROWID reset. Cleanup can be executed only on _main_ database, but if _main_ is `in memory` database, than cleanup won't be done.    
This method can't be called on database with _read-only_ access.  
    
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
This is an example of how we can drop table in _main_ database:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">dropTable</font>:<font color="#cb3229">@"test"</font> <font color="#38595d">inDatabase</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m8">- dropAllTablesInDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m8"/>dropAllTablesInDatabase:error:</font>  
  
Method allows you to drop all tables in specified database w/o writing SQL statements.  
  
<pre>- (BOOL)dropAllTablesInDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database from which will be dropped all tables. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if all tables was successfully dropped, otherwise `NO`.
  
__Discussion__  
This method allows you to drop all tables from specified database w/o writing SQL statements. In case of [sqlite][SQLitews] after something was removed from database, database file won't reduce in size. So if you simply remove all tables from database with large number of records, database file will still the same size as before removing. This method solves this problem, but in some cases it may lead to ROWID reset. Cleanup can be executed only on _main_ database, but if _main_ is `in memory` database, than cleanup won't be done.  
This method can't be called on database with _read-only_ access.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will drop all tables in _main_ database: 
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">dropAllTablesInDatabase</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m7">- dropTable:inDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m9"/>tablesCountError:</font>  
  
Method allows you to retrieve number of tables in all attached databases w/o writing SQL statements.  
  
<pre>- (int)tablesCountError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Number of tables in all attached databases.  
  
__Discussion__  
This method won't take into account [sqlite][SQLitews] service tables for indices and so on.  
  
__How to use__  
In this example, we will use results from one of the <a href="#m1e">example</a>, shown earlier and retrieve number of tables across all attached databases:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#b7359d">int</font> tablesCount = [db <font color="#38595d">tablesCountError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Number of tables: %i"</font>, tablesCount);
}
</pre>

__See Also__  
<a href="#m10">- tablesCountInDatabase:error:</a>  
<a href="#m11">- tablesListError:</a>  
<a href="#m12">- tablesListForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m10"/>tablesCountInDatabase:error:</font>  
  
Method allows you to retrieve number of tables in specified [sqlite][SQLitews] database w/o writing SQL statements.  
  
<pre>- (int)tablesCountInDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database tables count of which you want to retrieve. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Number of tables in specified [sqlite][SQLitews] database.  
  
__Discussion__  
This method won't take into account [sqlite][SQLitews] service tables for indices and so on.  
  
__How to use__  
In this example, we will use results from one of the <a href="#m1e">example</a>, shown earlier and retrieve number of tables in specified database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#b7359d">int</font> tablesCount = [db <font color="#38595d">tablesCountInDatabase</font>:<font color="#cb3229">@"aTest"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Number of tables: %i"</font>, tablesCount);
}
</pre>

__See Also__  
<a href="#m9">- tablesCountError:</a>  
<a href="#m11">- tablesListError:</a>  
<a href="#m12">- tablesListForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m11"/>tablesListError:</font>  

Method allows you to retrieve list of tables name in _main_ database w/o writing SQL statements.  
  
<pre>- (NSArray*)tablesListError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
List of tables name in _main_ database.  
  
__Discussion__  
This method won't take into account [sqlite][SQLitews] service tables for indices and so on.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will retrieve tables name for _main_ database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSArray</font> *tablesList = [db <font color="#38595d">tablesListError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Tables list: %@"</font>, tablesList);
}
</pre>

__See Also__  
<a href="#m9">- tablesCountError:</a>  
<a href="#m10">- tablesCountInDatabase:error:</a>  
<a href="#m12">- tablesListForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m12"/>tablesListForDatabase:error:</font>  
  
Method allows you to retrieve list of tables name in specified database w/o writing SQL statements.  
  
<pre>- (NSArray*)tablesListForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which will be retrieved tables name list. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
List of tables name in specified database.  
  
__Discussion__  
This method won't take into account [sqlite][SQLitews] service tables for indices and so on.  
  
__How to use__  
In this example, we will use results from one of the <a href="#m1e">example</a>, shown earlier.  
In this example we will retrieve tables name for specified database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSArray</font> *tablesList = [db <font color="#38595d">tablesListForDatabase</font>:<font color="#cb3229">@"aTest"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Tables list: %@"</font>, tablesList);
}
</pre>

__See Also__  
<a href="#m9">- tablesCountError:</a>  
<a href="#m10">- tablesCountInDatabase:error:</a>  
<a href="#m11">- tablesListError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m13"/>tableInformation:error:</font>  
  
Method allows you to retrieve table structure (columns information) for _main_ database w/o writing SQL statements.  
  
<pre>- (NSArray*)tableInformation:(NSString*)<i>tableName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_tableName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of table in _main_ database for which will be returned columns information.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
List of [DBCDatabaseTableColumnInfo][DBCDatabaseTableColumnInfoCR] for specified _tableName_ in _main_ database.  
  
__Discussion__  
Return list of [DBCDatabaseTableColumnInfo][DBCDatabaseTableColumnInfoCR] instances, which holds information about table column.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show how to retrieve table structure information from _main_ database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSArray</font> *tableColumnsList = [db <font color="#38595d">tableInformation</font>:<font color="#cb3229">@"test"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#b7359d">for</font>(<font color="#547f85">DBCDatabaseTableColumnInfo</font> *colInfo <font color="#b7359d">in</font> columnsList) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, colInfo);
}

<font color="#008123">/* Output:
    In sequence column number: 0
    Column name: pid
    Column data type: INTEGER
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: YES

    In sequence column number: 1
    Column name: pType
    Column data type: TEXT
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: NO

    In sequence column number: 2
    Column name: pTitle
    Column data type: TEXT
    Column is NOT NULL: NO
    Column default value: (null)
    Column is part of the primary key: NO

    In sequence column number: 3
    Column name: loc_lat
    Column data type: FLOAT
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: NO

    In sequence column number: 4
    Column name: loc_lon
    Column data type: FLOAT
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: NO
*/</font>
</pre>

__See Also__  
<a href="#m14">- tableInformation:forDatabase:error:</a>  
<a href="#m15">- databasesListError:</a>  
<a href="#m16">- indicesList:forTable:error:</a>  
<a href="#m17">- indexedColumnsList:index:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m14"/>tableInformation:forDatabase:error:</font>  
  
Method allows you to retrieve table structure (columns information) for specified database w/o writing SQL statements.  
  
<pre>- (NSArray*)tableInformation:(NSString*)<i>tableName</i> forDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_tableName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of table in specified database for which will be returned columns information.
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database in which specified table stored. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
List of [DBCDatabaseTableColumnInfo][DBCDatabaseTableColumnInfoCR] for specific table in specified database.  
  
__Discussion__  
Return list of [DBCDatabaseTableColumnInfo][DBCDatabaseTableColumnInfoCR] instances, which holds information about table column.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show how to retrieve table structure information from specified database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSArray</font> *tableColumnsList = [db <font color="#38595d">tableInformation</font>:<font color="#cb3229">@"test"</font> <font color="#38595d">forDatabase</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#b7359d">for</font>(<font color="#547f85">DBCDatabaseTableColumnInfo</font> *colInfo <font color="#b7359d">in</font> columnsList) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, colInfo);
}

<font color="#008123">/* Output:
    In sequence column number: 0
    Column name: pid
    Column data type: INTEGER
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: YES

    In sequence column number: 1
    Column name: pType
    Column data type: TEXT
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: NO

    In sequence column number: 2
    Column name: pTitle
    Column data type: TEXT
    Column is NOT NULL: NO
    Column default value: (null)
    Column is part of the primary key: NO

    In sequence column number: 3
    Column name: loc_lat
    Column data type: FLOAT
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: NO

    In sequence column number: 4
    Column name: loc_lon
    Column data type: FLOAT
    Column is NOT NULL: YES
    Column default value: (null)
    Column is part of the primary key: NO
*/</font>
</pre>

__See Also__  
<a href="#m13">- tableInformation:error:</a>  
<a href="#m15">- databasesListError:</a>  
<a href="#m16">- indicesList:forTable:error:</a>  
<a href="#m17">- indexedColumnsList:index:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m15"/>databasesListError:</font>  
  
Method allows you to retrieve list of databases (_main_ and _attached_) from current database connection w/o writing SQL statements.  
  
<pre>- (NSArray*)databasesListError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
List of [DBCDatabaseInfo][DBCDatabaseInfoCR] instances from current database connection.  
  
__Discussion__  
Return list of [DBCDatabaseInfo][DBCDatabaseInfoCR] instances, which holds information about databases. Databases like `in-memory` or temporary don't have file path in this objects.  
  
__How to use__  
In this example, we will use results from <a href="#m1e">example</a>, shown earlier and retrieve list of databases:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSArray</font> *databasesList = [db <font color="#38595d">databasesListError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#b7359d">for</font>(<font color="#547f85">DBCDatabaseInfo</font> *dbInfo <font color="#b7359d">in</font> databasesList) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, dbInfo);
}

<font color="#008123">/* Output:
    Sequence number: 0
    Database name: main
    Database file path: 

    Sequence number: 2
    Database name: aTest
    Database file path: .../Documents/test.sqlite
*/</font>
</pre>

__See Also__  
<a href="#m13">- tableInformation:error:</a>  
<a href="#m14">- tableInformation:forDatabase:error:</a>  
<a href="#m16">- indicesList:forTable:error:</a>  
<a href="#m17">- indexedColumnsList:index:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m16"/>indicesList:forTable:</font>  
  
Method allows you to retrieve list of indices for specific table in specified database w/o writing SQL statements.  
  
<pre>- (NSArray*)indicesList:(NSString*)<i>databaseName</i> forTable:(NSString*)<i>tableName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database in which specified table stored. If _nil_ than _main_ database will be used.  
_tableName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of table in specified database for which will be returned list of [DBCDatabaseIndexInfo][DBCDatabaseIndexInfoCR].  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
List of [DBCDatabaseIndexInfo][DBCDatabaseIndexInfoCR] instances defined in specific table from specified database.  
  
__Discussion__  
Return list of [DBCDatabaseIndexInfo][DBCDatabaseIndexInfoCR] instances, which holds information about indices in specified table.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will retrieve list of indices for tables in specified database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSArray</font> *indicesList = [db <font color="#38595d">indicesList</font>:<font color="#b7359d">nil</font> <font color="#38595d">forTable</font>:<font color="#cb3229">@"test"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#b7359d">for</font>(<font color="#547f85">DBCDatabaseIndexInfo</font> *indexInfo <font color="#b7359d">in</font> indicesList) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, indexInfo);
}

<font color="#008123">/* Output:
    Sequence number: 0
    Index name: locationIndex
    Index is unique: YES
*/</font>
</pre>

__See Also__  
<a href="#m13">- tableInformation:error:</a>  
<a href="#m14">- tableInformation:forDatabase:error:</a>  
<a href="#m15">- databasesListError:</a>  
<a href="#m17">- indexedColumnsList:index:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m17"/>indexedColumnsList:index:</font>  
  
Method allows you to retrieve index information (information of columns which is part of index) in specified database w/o writing SQL statements.  
  
<pre>- (NSArray*)indexedColumnsList:(NSString*)<i>databaseName</i> index:(NSString*)<i>indexName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database in which specified index defined. If _nil_ than _main_ database will be used.  
_indexName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of index for which will be returned list of [DBCDatabaseIndexedColumnInfo][DBCDatabaseIndexedColumnInfoCR].  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
List of [DBCDatabaseIndexedColumnInfo][DBCDatabaseIndexedColumnInfoCR] instances.  
  
__Discussion__  
Return list of [DBCDatabaseIndexedColumnInfo][DBCDatabaseIndexedColumnInfoCR] instances, which holds information about columns which are the part of index.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will retrieve index information for specific table in specified database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSArray</font> *indicedColumnsList = [db <font color="#38595d">indexedColumnsList</font>:<font color="#b7359d">nil</font> <font color="#38595d">index</font>:<font color="#cb3229">@"locationIndex"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    <font color="#b7359d">for</font>(<font color="#547f85">DBCDatabaseIndexedColumnInfo</font> *indexColInfo <font color="#b7359d">in</font> indicedColumnsList) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, indexColInfo);
}

<font color="#008123">/* Output:
    In index column number: 0
    In table column index: 3
    Column name: loc_lat

    In index column number: 1
    In table column index: 4
    Column name: loc_lon
*/</font>
</pre>

__See Also__  
<a href="#m13">- tableInformation:error:</a>  
<a href="#m14">- tableInformation:forDatabase:error:</a>  
<a href="#m15">- databasesListError:</a>  
<a href="#m16">- indicesList:forTable:error:</a>  
  
<a href="#top">Top</a>  