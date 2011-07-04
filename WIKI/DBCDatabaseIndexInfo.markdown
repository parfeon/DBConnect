#__DBCDatabaseIndexInfo Class Reference__  
[SQLitews]:http://www.sqlite.org  
[APPLFastEnumerationProtocol]:http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html
[DBCDatabaseResultCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseResult  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseIndicesInfo]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Aliases#m16  
<a name="top"/><font size="6">__Overview__</font>  
This class holds information about table index which was retrieved as result of [indicesList:forTable:][DBCDatabaseIndicesInfo].  
This class holds information about:
<ul>
<li>index sequence number</li>
<li>index name</li>
<li>whether index is unique or not</li>
</ul>
  
##__Tasks__  
###__DBCDatabaseIndexInfo initialization__  
<a href="#m1">+ indexInfoWithSequence:name:unique:</a>  
<a href="#m2">- initIndexInfoWithSequence:name:unique:</a>  
###__DBCDatabaseIndexInfo properties__  
<a href="#p1">numberInSequence</a>  
<a href="#p2">name</a>  
<a href="#p3">isUnique</a>  

##__Properties__  

<font size="4"><a name="p1"/>numberInSequence</font>  
  
This property stores information about index sequence number among other indices.  
  
<pre>@property (nonatomic, readonly, getter = indexInIndex)int colIdxInIndex</pre>   
  
__Return value__  
Index sequence number among other indices.  
  
__See Also__  
<a href="#p2">name</a>  
<a href="#p3">isUnique</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p2"/>name</font>  
  
This property stores information about index name.  
  
<pre>@property (nonatomic, readonly, getter = name)NSString *idxName</pre>   
  
__Return value__  
Index name.  
  
__See Also__  
<a href="#p1">numberInSequence</a>  
<a href="#p3">isUnique</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p3"/>isUnique</font>  
  
This property stores information about index is unique.  
  
<pre>@property (nonatomic, readonly, getter = isUnique)BOOL idxUnique</pre>   
  
__Return value__  
`YES` if index is unique, otherwise `NO`.  
  
__See Also__  
<a href="#p1">numberInSequence</a>  
<a href="#p2">name</a>  
  
<a href="#top">Top</a>  

##__Class methods__  

<font size="4"><a name="m1"/>indexInfoWithSequence:name:unique:</font>  
  
Create and initialize __DBCDatabaseIndexInfo__ instance with sequence number, name and flag whether this index is unique or not.  
  
<pre>+ (id)indexInfoWithSequence:(int)sequenceNumber name:(NSString*)indexName unique:(BOOL)isUnique</pre>  
__Parameters__  
_sequenceNumber_  
&nbsp;&nbsp;&nbsp;&nbsp;Index sequence order among other indices.  
_indexName_  
&nbsp;&nbsp;&nbsp;&nbsp;Index name.  
_isUnique_  
&nbsp;&nbsp;&nbsp;&nbsp;Whether index is unique.  
  
__Return value__  
Autoreleased __DBCDatabaseIndexInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseIndexInfo__ instance which stored information about about table index.  
  
__See Also__  
<a href="#m2">- initIndexInfoWithSequence:name:unique:</a>  
  
<a href="#top">Top</a>  

##__Instance methods__  

<font size="4"><a name="m2"/>initIndexInfoWithSequence:name:unique:</font>  
  
Initialize __DBCDatabaseIndexInfo__ instance with sequence number, name and flag whether this index is unique or not.  
  
<pre>- (id)initIndexInfoWithSequence:(int)sequenceNumber name:(NSString*)indexName unique:(BOOL)isUnique</pre>  
__Parameters__  
_sequenceNumber_  
&nbsp;&nbsp;&nbsp;&nbsp;Index sequence order among other indices.  
_indexName_  
&nbsp;&nbsp;&nbsp;&nbsp;Index name.  
_isUnique_  
&nbsp;&nbsp;&nbsp;&nbsp;Whether index is unique.  
  
__Return value__  
Initialized __DBCDatabaseIndexInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseIndexInfo__ instance which stored information about table index.  
  
__See Also__  
<a href="#m1">+ indexInfoWithSequence:name:unique:</a>  
  
<a href="#top">Top</a>  