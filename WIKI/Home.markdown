[wikiMain]:https://github.com/parfeon/DBConnect/wiki
[DBCDatabasewiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase
[DBCDatabaseResultwiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseResult
[DBCDatabaseRowwiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseRow
[DBCDatabase+Aliaseswiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Aliases
[DBCDatabase+Advancedwiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Advancedwiki
[DBCDatabaseInfowiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseInfo
[DBCDatabaseIndexInfowiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseIndexInfo
[DBCDatabaseIndexedColumnInfowiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseIndexedColumnInfo
[DBCDatabaseTableColumnInfowiki]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseTableColumnInfo
[SQLitews]:http://www.sqlite.org
__Welcome to the DBConnect Wiki!__  
I will reveal some information, in this Wiki section, about this wrapper and it's classes, also will show you with example, why you probably would like to use wrappers (maybe mine or maybe some other).

<a name="top" />  

#Wiki content:  
* <a href="#what-for">What's all bout this wrappers</a>
* <a href="#threadsafe">Thread-safe</a>
* <a href="#howtos">How-to's</a>  
* <a href="#classes">Classes</a>  
<a name="what-for" />  
  
##What's all bout this wrappers  

I'm sure, what all newcomers ask themselves: _"why do we need all these wrappers to work with SQLite?"_.  
Ummm emmmm let's see what you will have to do, to insert one row of data into new table:  
<pre>
<font color="#008123">// Let's open some sqlite database connection</font>  
<font color="#7243a4">sqlite3</font> *connection = <font color="#b7359d">NULL</font>;  
<font color="#b7359d">int</font> returnCode = <font color="#43277c">sqlite3_open</font>(<font color="#cb3229">':memory:'</font>, &connection);  
<font color="#b7359d">if</font>(returnCode == <font color="#754931">SQLITE_OK</font>){  <font color="#008123">// Check if connection was opened</font>  
    <font color="#008123">// Compile SQLite statement for table creation and evaluate SQL query to SQLite database</font>  
    <font color="#7243a4">sqlite3_stmt</font> *createStatement = <font color="#b7359d">NULL</font>;  
    returnCode = <font color="#43277c">sqlite3_prepare_v2</font>(connection, <font color="#cb3229">"CREATE TABLE IF NOT EXISTS someTable (id INTEGER, 
                                                        fieldName1 TEXT, fieldName2 TEXT NOT NULL);"</font>, 
                                                -1, &createStatement, <font color="#b7359d">NULL</font>);  
    <font color="#b7359d">if</font>(returnCode == <font color="#754931">SQLITE_OK</font>){  
        returnCode = <font color="#43277c">sqlite3_step</font>(createStatement);  
        <font color="#b7359d">if</font>(returnCode == <font color="#754931">SQLITE_DONE</font>){  <font color="#008123">// Check whether database was created or not</font>  
            <font color="#008123">// Compile SQLite statement for data insertion and evaluate SQL query to SQLite database</font>  
            <font color="#7243a4">sqlite3_stmt</font> *insertStatement = <font color="#b7359d">NULL</font>;  
            returnCode = <font color="#43277c">sqlite3_prepare_v2</font>(connection, <font color="#cb3229">"INSERT INTO someTable (id, fieldName1, fieldName2)  
                                                                        VALUES (?1, ?2, ?3);"</font>, 
                                                        -1, &insertStatement, <font color="#b7359d">NULL</font>);  
        <font color="#b7359d">if</font>(returnCode == <font color="#754931">SQLITE_DONE</font>){  <font color="#008123">// Check whether table was created or not</font>  
            <font color="#008123">// Now we need to bind some data and it will be placed instead of indexed tokens</font>  
            <font color="#43277c">sqlite3_bind_int</font>(insertStatement, 1, 1);  
            <font color="#43277c">sqlite3_bind_text</font>(insertStatement, 2, [[<font color="#cb3229">@"First field value"</font>] <font color="#43277c">UTF8String</font>], -1, <font color="#754931">SQLITE_STATIC</font>);  
            <font color="#43277c">sqlite3_bind_text</font>(insertStatement, 3, [[<font color="#cb3229">@"Second field value"</font>] <font color="#43277c">UTF8String</font>], -1, <font color="#754931">SQLITE_STATIC</font>);  
            returnCode = <font color="#43277c">sqlite3_step</font>(insertStatement);  
            <font color="#b7359d">if</font>(returnCode == <font color="#754931">SQLITE_OK</font>){  <font color="#008123">// Check whether row was inserted or not</font>  
                <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Hurray!!! We finally inserted values into new table and it was made \  
                      only with 28 lines of code o_O"</font>);  
            } <font color="#b7359d">else</font> {  
                <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Damn, we wrote 28 lines of code and failed to insert value into new table"</font>);  
            }
        } <font color="#b7359d">else</font> {
            <font color="#008123">// Do something with table creation error</font>
        }
    } <font color="#b7359d">else</font> {  
        <font color="#008123">// Do something with error</font>  
    }  	
    <font color="#43277c">sqlite3_finalize</font>(createStatement);  
    createStatement = <font color="#b7359d">NULL</font>;  
    <font color="#43277c">sqlite3_finalize</font>(insertStatement);  
    insertStatement = <font color="#b7359d">NULL</font>;  
    <font color="#43277c">sqlite3_close</font>(connection);  
    connection = <font color="#b7359d">NULL</font>;  
}
</pre>

Phew, you see, we have to write not so much of code to add a single row into database in which only 3 data fields. Code above uses __16 lines of code__, __which produces some changes to database and cleanup after it completed__. But what if you need to add data into a table with 20 fields? It's already sounds like a real problem.  
So here you will find, what using wrappers is not just make code cleaner, also it's fun ;)  
  
For example, here same code as above, but performed with __DBConnect__:  
<pre>  
<font color="#008123">// Let's open some sqlite database connection</font>  
<font color="#547f85">DBCDatabase</font> *db = [[<font color="#547f85">DBCDatabase</font> <font color="#43277c">alloc</font>] <font color="#38595d">initWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>([db <font color="#38595d">open</font>]){  <font color="#008123">// Check if connection was opened</font>  
    <font color="#008123">// Create new table</font>
    <font color="#b7359d">BOOL</font> creationSuccessfull = [db <font color="#38595d">evaluateUpdate</font>:<font color="#cb3229">@"CREATE TABLE IF NOT EXISTS someTable (id INTEGER, 
                                                    fieldName1 TEXT, fieldName2 TEXT NOT NULL);"</font>, <font color="#b7359d">nil</font>];
    <font color="#b7359d">if</font>(creationSuccessfull){  <font color="#008123">// Check whether table was created or not</font>  
        <font color="#b7359d">BOOL</font> insertionSuccessfull = [db <font color="#38595d">evaluateUpdate</font>:<font color="#cb3229">@"CREATE TABLE IF NOT EXISTS someTable (?1, ?2, ?3);"</font>, 
                                                                                  [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithInt</font>:1],  
                                                                                  <font color="#cb3229">@"First field value"</font>,  
                                                                                  <font color="#cb3229">@"Second field value"</font>,
                                                                                  <font color="#b7359d">nil</font>];
        <font color="#b7359d">if</font>(insertionSuccessfull){
            <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Hurray!!! We finally inserted values into new table and it was made \  
                  only with 12 lines of code. It look's much better and really human-readable"</font>);
        } <font color="#b7359d">else</font> {
            <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Damn, we wrote 12 lines of code and failed to insert value into new table"</font>);  
        }
    } <font color="#b7359d">else</font> {
       <font color="#008123">// Do something with table creation error</font>
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// Handle database connection open error</font>
}
<font color="#b7359d">if</font>([db <font color="#38595d">close</font>]){
    <font color="#008123">// Database closed and released resources, used while performed requests</font>
} <font color="#b7359d">else</font> {
    <font color="#008123">// Look's like we can't close database connection, probably someone holds database file</font>
}
</pre>  
  
Code above shows, what wrappers (__DBConnect__ in this case) make it really easy-to-use [SQLite][SQLitews] databases with Objective-C. In shown example, there is only __4 lines of code__, __which do something with database__, other lines is condition check and most of time you probably won't use part of those conditions.  

So, if you still interested with my wrapper, you can proceed to Wiki content and head to interested class or section from there.  
<a href="#top">Top</a>  

<a name="threadsafe" />  

##Thread-safe  
As we all know, threads basically used to perform some _heavy_ operations outside from main thread, to keep application interface to be responsive for user.
Well, this is [SQLite][SQLitews] _Achilles heel_ and thats why they wrote this in their documentation: _"Threads are evil. Avoid them"_.  
So main problem with [SQLite][SQLitews], what you can't safely pass database connection handler from thread which created it to another thread. As they say, if [sqlite3][SQLitews] binary compiled with __SQLITE_THREADSAFE__ everything will be fine. But thats not our case, because on Mac OS X and iOS [sqlite3][SQLitews] binary __compiled without this flag__, so we need to do something with this issue.  
We can solve it by placing locks around thread-sensitive code and make sure, what you using same lock instance to lock/unlock. This is really annoying to place this locks almost everywhere and control to release lock, so all this stuff I've made for you.
You can freely pass __DBCDatabase__ instance to other threads or create one in other thread and perform queries. Fill free with threads now.  
<a href="#top">Top</a>  

<a name="howtos" />  
  
##How-to's  
There are not so much classes, which was provided to use by programmer, so all of them have description in implementation files for each of methods. But usually it's really hard to tech on methods description only, so I will provide some small examples in each class section (all classes have their Wiki page with exampled and description).  
<a href="#top">Top</a>  

<a name="classes" />  

##Classes  
As was said before on main page of the project, __DBConnect__ consist from three basic classes: [DBCDatabase][DBCDatabasewiki], [DBCDatabaseResult][DBCDatabaseResultwiki], [DBCDatabaseRow][DBCDatabaseRowwiki]  
There are also few extension categories for users, which would like to have easier way to adjust some database settings or get some SQL queries shortcut for some tasks. To be more precise there are 2 categories: [DBCDatabase+Aliases][DBCDatabase+Aliaseswiki] and [DBCDatabase+Advanced][DBCDatabase+Advancedwiki].  
And we also have some objects, which will help represent retrieved information from some methods of [DBCDatabase+Aliases][DBCDatabase+Aliaseswiki] category: [DBCDatabaseInfo][DBCDatabaseInfowiki], [DBCDatabaseIndexInfo][DBCDatabaseIndexInfowiki], [DBCDatabaseIndexedColumnInfo][DBCDatabaseIndexedColumnInfowiki], [DBCDatabaseTableColumnInfo][DBCDatabaseTableColumnInfowiki].  
  
  
__That's all what I want to tell you in this section__  
<a href="#top">Top</a>  