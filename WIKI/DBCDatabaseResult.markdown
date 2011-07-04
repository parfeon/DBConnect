#__DBCDatabaseResult Class Reference__  
[SQLitews]:http://www.sqlite.org  
[APPLFastEnumerationProtocol]:http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html
[DBCDatabaseRowCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseRow  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseExecuteQuery]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#m12  
<a name="top"/><font size="6">__Overview__</font>  
This class holds all information retrieved from query execution with [executeQuery:error:][DBCDatabaseExecuteQuery].  
This class holds information about:
<ul>
<li>column names</li>
<li>SQL query which was used</li>
<li>rows with data</li>
<li>count of rows with data</li>
</ul>
This class implements [NSFastEnumeration protocol][APPLFastEnumerationProtocol] so it can be easily used in `for..in` cycles.  
  
##__Tasks__  
###__DBCDatabaseResult initialization__  
<a href="#m1">+ resultWithPreparedStatement:encoding:</a>  
<a href="#m2">- initWidthPreparedSatetement:encoding:</a>  
###__DBCDatabaseResult rows manipulation__  
<a href="#m3">- addRowFromStatement:</a>  
<a href="#m4">- rowAtIndex:</a>  
###__DBCDatabaseResult properties__  
<a href="#p1">count</a>  
<a href="#p2">columnNames</a>  
<a href="#p3">queryExecutionDuration</a>  
<a href="#p4">query</a>  
  
##__Properties__  
  
<font size="4"><a name="p1"/>count</font>  
  
This property stores count of [DBCDatabaseRow][DBCDatabaseRowCR] instance entries.  
  
<pre>@property (nonatomic, readonly)int count</pre>  
  
__Discussion__  
This parameters stores information about how much rows was retrieved from last query.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR] and retrieve rows count:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabaseResult</font> *result = [db <font color="#38595d">executeQuery</font>:<font color="#cb3229">@"SELECT * FROM test"</font> <font color="#38595d">error</font>:&error, <font color="#b7359d">nil</font>];
<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    <font color="#b7359d">int</font> rowsCount = [result <font color="#38595d">count</font>];
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Rows count: %i"</font>, rowsCount);
} <font color="#b7359d">else</font> {
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}

<font color="#008123">/* Output:
    Rows count: 4
*/</font>
</pre>
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p2"/>columnNames</font>  
  
This property stores column names from recent SQL statement.  
  
<pre>@property (nonatomic, readonly, getter = columnNames)NSArray *colNames</pre>  
  
__Discussion__  
This parameters stores column names list.  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p3"/>queryExecutionDuration</font>  
  
This property stores duration of SQL query statement execution.  
  
<pre>@property (nonatomic, assign)NSTimeInterval queryExecutionDuration</pre>  
  
__Discussion__  
If DBCShouldProfileQuery enabled in DBCConfiguration.h, than this parameter will store time, which was spent for query execution.  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p4"/>query</font>  
  
This property stores SQL statement for recent query execution.  
  
<pre>@property (nonatomic, readonly, getter = query)NSString *querySQL</pre>  
  
__Discussion__  
This property stores SQL query statement, which was used for last query execution.  
  
<a href="#top">Top</a>  

##__Class methods__  

<font size="4"><a name="m1"/>resultWithPreparedStatement:encoding:</font>  
  
Create and initialize __DBCDatabaseResult__ instance with specified SQL statement and encoding.  
  
<pre>+ (id)resultWithPreparedStatement:(sqlite3_stmt*)<i>statement</i> encoding:(DBCDatabaseEncoding)<i>databaseEncoding</i></pre>  
__Parameters__  
_statement_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] statement which used for query.  
_databaseEncoding_  
&nbsp;&nbsp;&nbsp;&nbsp;current encoding used for opened database connection.  
  
__Return value__  
Autoreleased __DBCDatabaseResult__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseResult__ instance, which is ready to use by __DBCDatabase__.  
  
__See Also__  
<a href="#m2">- initWidthPreparedSatetement:encoding:</a>  
  
<a href="#top">Top</a>  

##__Instance methods__  

<font size="4"><a name="m2"/>initWidthPreparedSatetement:encoding:</font>  
  
Initialize __DBCDatabaseResult__ instance with specified SQL statement and encoding.  
  
<pre>- (id)initWidthPreparedSatetement:(sqlite3_stmt*)<i>statement</i> encoding:(DBCDatabaseEncoding)<i>databaseEncoding</i></pre>  
__Parameters__  
_statement_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] statement which used for query.  
_databaseEncoding_  
&nbsp;&nbsp;&nbsp;&nbsp;current encoding used for opened database connection.  
  
__Return value__  
Initialized __DBCDatabaseResult__ instance.  
  
__Discussion__  
This method initialize __DBCDatabaseResult__ instance, which is ready to use by __DBCDatabase__.  
  
__See Also__  
<a href="#m1">+ resultWithPreparedStatement:encoding:</a>  
  
<a href="#top">Top</a>  