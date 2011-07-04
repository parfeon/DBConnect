#__DBCDatabaseRow Class Reference__  
[SQLitews]:http://www.sqlite.org  
[APPLFastEnumerationProtocol]:http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html
[DBCDatabaseResultCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseResult  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseExecuteQuery]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#m12  
<a name="top"/><font size="6">__Overview__</font>  
This class holds data from single database entry returned as result of [executeQuery:error:][DBCDatabaseExecuteQuery].  
This class holds information about:
<ul>
<li>columns count</li>
<li>list of values for each one of columns</li>
</ul>
  
##__Tasks__  
###__DBCDatabaseRow initialization__  
<a href="#m1">+ rowWithStatement:dataStructureDelegate:</a>  
<a href="#m2">- initRowWithStatement:dataStructureDelegate:</a>  
###__DBCDatabaseRow misc__  
<a href="#m3">- columnsCount</a>  
<a href="#m4">- dataTypeClassAtColumnIndex:</a>  
<a href="#m5">- dataTypeClassForColumn:</a>  
###__DBCDatabaseResult data getters__  
<a href="#m6">- intForColumn:</a>  
<a href="#m7">- intForColumnAtIndex:</a>  
<a href="#m8">- integerForColumn:</a>  
<a href="#m9">- integerForColumnAtIndex:</a>  
<a href="#m10">- unsignedIntegerForColumn:</a>  
<a href="#m11">- unsignedIntegerForColumnAtIndex:</a>  
<a href="#m12">- longForColumn:</a>  
<a href="#m13">- longForColumnAtIndex:</a>  
<a href="#m14">- longLongForColumn:</a>  
<a href="#m15">- longLongForColumnAtIndex:</a>  
<a href="#m16">- boolForColumn:</a>  
<a href="#m17">- boolForColumnAtIndex:</a>  
<a href="#m18">- floatForColumn:</a>  
<a href="#m19">- floatForColumnAtIndex:</a>  
<a href="#m20">- doubleForColumn:</a>  
<a href="#m21">- doubleForColumnAtIndex:</a>  
<a href="#m22">- objectForColumn:</a>  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m28">- dataForColumn:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  

##__Class methods__  

<font size="4"><a name="m1"/>rowWithStatement:dataStructureDelegate:</font>  
  
Create and initialize __DBCDatabaseRow__ instance with specified SQL statement and data structure delegate.  
  
<pre>+ (id)rowWithStatement:(sqlite3_stmt*)<i>statement</i> dataStructureDelegate:(id<DBCDatabaseResultStructure>)<i>dsDelegate</i></pre>  
__Parameters__  
_statement_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] statement which used for query.  
_dsDelegate_  
&nbsp;&nbsp;&nbsp;&nbsp;Delegate which implements `DBCDatabaseResultStructure` protocol which is part of [DBCDatabaseResult][DBCDatabaseResultCR].  
  
__Return value__  
Autoreleased __DBCDatabaseRow__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseRow__ instance, which is ready to use by __DBCDatabaseResult__.  
This method as <a href="#m2">initRowWithStatement:dataStructureDelegate:</a> also do type checking to determine real data type for value stored in columns and compare it with one provided by [structure delegate][DBCDatabaseResultCR]. This class always will use real data type for data stored in columns.  
  
__See Also__  
<a href="#m2">- initRowWithStatement:dataStructureDelegate:</a>  
  
<a href="#top">Top</a>  

##__Instance methods__  

<font size="4"><a name="m2"/>initRowWithStatement:dataStructureDelegate:</font>  
  
Initialize __DBCDatabaseRow__ instance with specified SQL statement and data structure delegate.  
  
<pre>- (id)initRowWithStatement:(sqlite3_stmt*)<i>statement</i> dataStructureDelegate:(id<DBCDatabaseResultStructure>)<i>dsDelegate</i></pre>  
__Parameters__  
_statement_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] statement which used for query.  
_dsDelegate_  
&nbsp;&nbsp;&nbsp;&nbsp;Delegate which implements `DBCDatabaseResultStructure` protocol which is part of [DBCDatabaseResult][DBCDatabaseResultCR].  
  
__Return value__  
Initialized __DBCDatabaseRow__ instance.  
  
__Discussion__  
This method initialize __DBCDatabaseRow__ instance, which is ready to use by __DBCDatabaseResult__.  
This method as <a href="#m1">rowWithStatement:dataStructureDelegate:</a> also do type checking to determine real data type for value stored in columns and compare it with one provided by [structure delegate][DBCDatabaseResultCR]. This class always will use real data type for data stored in columns.  
  
__See Also__  
<a href="#m1">+ rowWithStatement:dataStructureDelegate:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m3"/>columnsCount</font>  
  
This method allows you to retrieve number of columns returned as response for last query execution.  
  
<pre>- (int)columnsCount</pre>  
  
__Return value__  
Number of columns returned as response for last query execution.  
  
__See Also__  
<a href="#m4">- dataTypeClassAtColumnIndex:</a>  
<a href="#m5">- dataTypeClassForColumn:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m4"/>dataTypeClassAtColumnIndex:</font>  
  
This method allows you to retrieve real data type for data stored in specific column by it's index.  
  
<pre>- (Class)dataTypeClassAtColumnIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which holds data.  
  
__Return value__  
Class which represents stored data object.  
  
__See Also__  
<a href="#m3">- columnsCount</a>  
<a href="#m5">- dataTypeClassForColumn:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m5"/>dataTypeClassForColumn:</font>  
  
This method allows you to retrieve real data type for data stored in specific column by it's name.  
  
<pre>- (Class)dataTypeClassForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which hold data.  
  
__Return value__  
Class which represents stored data object.  
  
__See Also__  
<a href="#m3">- columnsCount</a>  
<a href="#m4">- dataTypeClassAtColumnIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m6"/>intForColumn:</font>  
  
This method allows you to retrieve `int` value for column by its name.  
  
<pre>- (int)intForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`int` value for value stored in specified column.  
  
__See Also__  
<a href="#m7">- intForColumnAtIndex:</a>  
<a href="#m8">- integerForColumn:</a>  
<a href="#m9">- integerForColumnAtIndex:</a>  
<a href="#m10">- unsignedIntegerForColumn:</a>  
<a href="#m11">- unsignedIntegerForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m7"/>intForColumnAtIndex:</font>  
  
This method allows you to retrieve `int` value for column by its index.  
  
<pre>- (int)intForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`int` value for value stored in specified column.  
  
__See Also__  
<a href="#m6">- intForColumn:</a>  
<a href="#m8">- integerForColumn:</a>  
<a href="#m9">- integerForColumnAtIndex:</a>  
<a href="#m10">- unsignedIntegerForColumn:</a>  
<a href="#m11">- unsignedIntegerForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m8"/>integerForColumn:</font>  
  
This method allows you to retrieve `integer` value for column by its name.  
  
<pre>- (NSInteger)integerForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`integer` value for value stored in specified column.  
  
__See Also__  
<a href="#m6">- intForColumn:</a>  
<a href="#m7">- intForColumnAtIndex:</a>  
<a href="#m9">- integerForColumnAtIndex:</a>  
<a href="#m10">- unsignedIntegerForColumn:</a>  
<a href="#m11">- unsignedIntegerForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m9"/>integerForColumnAtIndex:</font>  
  
This method allows you to retrieve `integer` value for column by its index.  
  
<pre>- (NSInteger)integerForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`integer` value for value stored in specified column.  
  
__See Also__  
<a href="#m6">- intForColumn:</a>  
<a href="#m7">- intForColumnAtIndex:</a>  
<a href="#m8">- integerForColumn:</a>  
<a href="#m10">- unsignedIntegerForColumn:</a>  
<a href="#m11">- unsignedIntegerForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m10"/>unsignedIntegerForColumn:</font>  
  
This method allows you to retrieve `unsigned integer` value for column by its name.  
  
<pre>- (NSUInteger)unsignedIntegerForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`unsigned integer` value for value stored in specified column.  
  
__See Also__  
<a href="#m6">- intForColumn:</a>  
<a href="#m7">- intForColumnAtIndex:</a>  
<a href="#m8">- integerForColumn:</a>  
<a href="#m9">- integerForColumnAtIndex:</a>  
<a href="#m11">- unsignedIntegerForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m11"/>unsignedIntegerForColumnAtIndex:</font>  
  
This method allows you to retrieve `unsigned integer` value for column by its index.  
  
<pre>- (NSUInteger)unsignedIntegerForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`unsigned integer` value for value stored in specified column.  
  
__See Also__  
<a href="#m6">- intForColumn:</a>  
<a href="#m7">- intForColumnAtIndex:</a>  
<a href="#m8">- integerForColumn:</a>  
<a href="#m9">- integerForColumnAtIndex:</a>  
<a href="#m10">- unsignedIntegerForColumn:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m12"/>longForColumn:</font>  
  
This method allows you to retrieve `long` value for column by its name.  
  
<pre>- (long)longForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`long` value for value stored in specified column.  
  
__See Also__  
<a href="#m13">- longForColumnAtIndex:</a>  
<a href="#m14">- longLongForColumn:</a>  
<a href="#m15">- longLongForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m13"/>longForColumnAtIndex:</font>  
  
This method allows you to retrieve `long` value for column by its index.  
  
<pre>- (long)longForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`long` value for value stored in specified column.  
  
__See Also__  
<a href="#m12">- longForColumn:</a>  
<a href="#m14">- longLongForColumn:</a>  
<a href="#m15">- longLongForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m14"/>longLongForColumn:</font>  
  
This method allows you to retrieve `long long` value for column by its name.  
  
<pre>- (long long)longLongForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`long long` value for value stored in specified column.  
  
__See Also__  
<a href="#m12">- longForColumn:</a>  
<a href="#m13">- longForColumnAtIndex:</a>  
<a href="#m15">- longLongForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m15"/>longLongForColumnAtIndex:</font>  
  
This method allows you to retrieve `long long` value for column by its index.  
  
<pre>- (long long)longLongForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`long long` value for value stored in specified column.  
  
__See Also__  
<a href="#m12">- longForColumn:</a>  
<a href="#m13">- longForColumnAtIndex:</a>  
<a href="#m14">- longLongForColumn:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m16"/>boolForColumn:</font>  
  
This method allows you to retrieve `bool` value for column by its name.  
  
<pre>- (BOOL)boolForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`bool` value for value stored in specified column.  
  
__See Also__  
<a href="#m17">- boolForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m17"/>boolForColumnAtIndex:</font>  
  
This method allows you to retrieve `bool` value for column by its index.  
  
<pre>- (BOOL)boolForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`bool` value for value stored in specified column.  
  
__See Also__  
<a href="#m16">- boolForColumn:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m18"/>floatForColumn:</font>  
  
This method allows you to retrieve `bool` value for column by its name.  
  
<pre>- (float)floatForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`float` value for value stored in specified column.  
  
__See Also__  
<a href="#m19">- floatForColumnAtIndex:</a>  
<a href="#m20">- doubleForColumn:</a>  
<a href="#m21">- doubleForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m19"/>floatForColumnAtIndex:</font>  
  
This method allows you to retrieve `float` value for column by its index.  
  
<pre>- (float)floatForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`float` value for value stored in specified column.  
  
__See Also__  
<a href="#m18">- floatForColumn:</a>  
<a href="#m20">- doubleForColumn:</a>  
<a href="#m21">- doubleForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m20"/>doubleForColumn:</font>  
  
This method allows you to retrieve `double` value for column by its name.  
  
<pre>- (double)doubleForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`double` value for value stored in specified column.  
  
__See Also__  
<a href="#m18">- floatForColumn:</a>  
<a href="#m19">- floatForColumnAtIndex:</a>  
<a href="#m21">- doubleForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m21"/>doubleForColumnAtIndex:</font>  
  
This method allows you to retrieve `double` value for column by its index.  
  
<pre>- (double)doubleForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`double` value for value stored in specified column.  
  
__See Also__  
<a href="#m18">- floatForColumn:</a>  
<a href="#m19">- floatForColumnAtIndex:</a>  
<a href="#m20">- doubleForColumn:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m22"/>objectForColumn:</font>  
  
This method allows you to retrieve `id` value for column by its name.  
  
<pre>- (id)objectForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`id` value for value stored in specified column.  
  
__See Also__  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m28">- dataForColumn:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m23"/>objectForColumnAtIndex:</font>  
  
This method allows you to retrieve `id` value for column by its index.  
  
<pre>- (id)objectForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`id` value for value stored in specified column.  
  
__See Also__  
<a href="#m22">- objectForColumn:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m28">- dataForColumn:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m24"/>stringForColumn:</font>  
  
This method allows you to retrieve `NSString` value for column by its name.  
  
<pre>- (NSString*)stringForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`NSString` value for value stored in specified column.  
  
__See Also__  
<a href="#m22">- objectForColumn:</a>  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m28">- dataForColumn:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m25"/>stringForColumnAtIndex:</font>  
  
This method allows you to retrieve `NSString` value for column by its index.  
  
<pre>- (NSString*)stringForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`NSString` value for value stored in specified column.  
  
__See Also__  
<a href="#m22">- objectForColumn:</a>  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m28">- dataForColumn:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m26"/>dateForColumn:</font>  
  
This method allows you to retrieve `NSDate` value for column by its name.  
  
<pre>- (NSDate*)dateForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`NSDate` value for value stored in specified column.  
  
__See Also__  
<a href="#m22">- objectForColumn:</a>  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m28">- dataForColumn:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m27"/>dateForColumnAtIndex:</font>  
  
This method allows you to retrieve `NSDate` value for column by its index.  
  
<pre>- (NSDate*)dateForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`NSDate` value for value stored in specified column.  
  
__See Also__  
<a href="#m22">- objectForColumn:</a>  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m28">- dataForColumn:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m28"/>dataForColumn:</font>  
  
This method allows you to retrieve `NSData` value for column by its name.  
  
<pre>- (NSData*)dataForColumn:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of column which stores data.  
  
__Return value__  
`NSData` value for value stored in specified column.  
  
__See Also__  
<a href="#m22">- objectForColumn:</a>  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m29">- dataForColumnAtIndex:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m29"/>dataForColumnAtIndex:</font>  
  
This method allows you to retrieve `NSData` value for column by its index.  
  
<pre>- (NSData*)dataForColumnAtIndex:(int)<i>columnIdx</i></pre>  
__Parameters__  
_columnIdx_  
&nbsp;&nbsp;&nbsp;&nbsp;The index of column which stores data.  
  
__Return value__  
`NSData` value for value stored in specified column.  
  
__See Also__  
<a href="#m22">- objectForColumn:</a>  
<a href="#m23">- objectForColumnAtIndex:</a>  
<a href="#m24">- stringForColumn:</a>  
<a href="#m25">- stringForColumnAtIndex:</a>  
<a href="#m26">- dateForColumn:</a>  
<a href="#m27">- dateForColumnAtIndex:</a>  
<a href="#m28">- dataForColumn:</a>  
  
<a href="#top">Top</a>  