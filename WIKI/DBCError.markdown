#__DBCError Class Reference__  
[SQLitews]:http://www.sqlite.org  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseExecuteQuery]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#m12  
<a name="top"/><font size="6">__Overview__</font>  
This class wraps error codes and provide some additional information about code itself and information from [SQLite][SQLitews] or [DBCDatabase][DBCDatabaseCR].  
  
##__Tasks__  
###__DBCError initialization__  
<a href="#m1">+ errorWithErrorCode:</a>  
<a href="#m2">+ errorWithErrorCode:forFilePath:</a>  
<a href="#m3">+ errorWithErrorCode:forFilePath:additionalInformation:</a>  
<a href="#m4">- initWithErrorCode:</a>  
<a href="#m5">- initWithErrorCode:forFilePath:</a>  
<a href="#m6">- initWithErrorCode:forFilePath:additionalInformation:</a>  
<a href="#m7">- initWithErrorCode:errorDomain:forFilePath:additionalInformation:</a>  
###__DBCDatabaseRow misc__  
<a href="#m8">+ errorDescriptionByCode:</a>  

##__Class methods__  

<font size="4"><a name="m1"/>errorWithErrorCode:</font>  
  
Create and initialize __DBCError__ instance for specified error code.  
  
<pre>+ (NSString*)errorWithErrorCode:(int)<i>errorCode</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
  
__Return value__  
Autoreleased __DBCError__ instance.  
  
__See Also__  
<a href="#m2">+ errorWithErrorCode:forFilePath:</a>  
<a href="#m3">+ errorWithErrorCode:forFilePath:additionalInformation:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m2"/>errorWithErrorCode:forFilePath:</font>  
  
Create and initialize __DBCError__ instance for specified error code and path to file which probably caused an error.  
  
<pre>+ (NSString*)errorWithErrorCode:(int)<i>errorCode</i> forFilePath:(NSString*)<i>filePath</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
_filePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Path to file, which was reason of the error.  
  
__Return value__  
Autoreleased __DBCError__ instance.  
  
__See Also__  
<a href="#m1">+ errorWithErrorCode:</a>  
<a href="#m3">+ errorWithErrorCode:forFilePath:additionalInformation:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m3"/>errorWithErrorCode:forFilePath:additionalInformation:</font>  
  
Create and initialize __DBCError__ instance for specified error code, path to file which probably caused an error and some additional information.  
  
<pre>+ (NSString*)errorWithErrorCode:(int)<i>errorCode</i> forFilePath:(NSString*)<i>filePath</i>
          additionalInformation:(NSString*)<i>additionalInformation</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
_filePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Path to file, which was reason of the error.  
_additionalInformation_  
&nbsp;&nbsp;&nbsp;&nbsp;Additional information about an error.  
  
__Return value__  
Autoreleased __DBCError__ instance.  
  
__See Also__  
<a href="#m1">+ errorWithErrorCode:</a>  
<a href="#m2">+ errorWithErrorCode:forFilePath:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m8"/>errorDescriptionByCode:</font>  
  
Return string equivalent of error code.  
  
<pre>+ (NSString*)errorDescriptionByCode:(int)<i>errorCode</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
  
__Return value__  
Translated into string error code.  
  
<a href="#top">Top</a>  
  
##__Instance methods__  

<font size="4"><a name="m4"/>initWithErrorCode:</font>  
  
Initialize __DBCError__ instance for specified error code.  
  
<pre>- (id)initWithErrorCode:(NSInteger)<i>code</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
  
__Return value__  
Initialized __DBCError__ instance.  
  
__See Also__  
<a href="#m5">- initWithErrorCode:forFilePath:</a>  
<a href="#m6">- initWithErrorCode:forFilePath:additionalInformation:</a>  
<a href="#m7">- initWithErrorCode:errorDomain:forFilePath:additionalInformation:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m5"/>initWithErrorCode:forFilePath:</font>  
  
Initialize __DBCError__ instance for specified error code and path to file which probably caused an error.  
  
<pre>- (id)initWithErrorCode:(NSInteger)<i>code</i> forFilePath:(NSString*)<i>filePath</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
_filePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Path to file, which was reason of the error.  
  
__Return value__  
Initialized __DBCError__ instance.  
  
__See Also__  
<a href="#m4">- initWithErrorCode:</a>  
<a href="#m6">- initWithErrorCode:forFilePath:additionalInformation:</a>  
<a href="#m7">- initWithErrorCode:errorDomain:forFilePath:additionalInformation:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m6"/>initWithErrorCode:forFilePath:additionalInformation:</font>  
  
Initialize __DBCError__ instance for specified error code, path to file which probably caused an error and some additional information.  
  
<pre>- (id)initWithErrorCode:(NSInteger)<i>code</i> forFilePath:(NSString*)<i>filePath</i> 
  additionalInformation:(NSString*)<i>additionalInformation</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
_filePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Path to file, which was reason of the error.  
_additionalInformation_  
&nbsp;&nbsp;&nbsp;&nbsp;Additional information about an error.  
  
__Return value__  
Initialized __DBCError__ instance.  
  
__See Also__  
<a href="#m4">- initWithErrorCode:</a>  
<a href="#m5">- initWithErrorCode:forFilePath:</a>  
<a href="#m7">- initWithErrorCode:errorDomain:forFilePath:additionalInformation:</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="m7"/>initWithErrorCode:errorDomain:forFilePath:additionalInformation:</font>  
  
Initialize __DBCError__ instance for specified error code, error domain, path to file which probably caused an error and some additional information.  
  
<pre>- (id)initWithErrorCode:(NSInteger)<i>code</i> errorDomain:(NSString*)<i>errorDomain</i> forFilePath:(NSString*)<i>filePath</i> 
  additionalInformation:(NSString*)<i>additionalInformation</i></pre>  
__Parameters__  
_errorCode_  
&nbsp;&nbsp;&nbsp;&nbsp;Error code which allow to identify reasons caused an error.  
_errorDomain_  
&nbsp;&nbsp;&nbsp;&nbsp;Error domain.  
_filePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Path to file, which was reason of the error.  
_additionalInformation_  
&nbsp;&nbsp;&nbsp;&nbsp;Additional information about an error.  
  
__Return value__  
Initialized __DBCError__ instance.  
  
__See Also__  
<a href="#m4">- initWithErrorCode:</a>  
<a href="#m5">- initWithErrorCode:forFilePath:</a>  
<a href="#m6">- initWithErrorCode:forFilePath:additionalInformation:</a>  
  
<a href="#top">Top</a>  