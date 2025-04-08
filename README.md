# nfXml

Project developer: Marco Plaza  [GitHub/nfoxdev](https://github.com/nfoxdev)

## Basic Usage

    oVfp = nfXMLRead(cXMLstring | fileName [, cArraysList, cXpath,@cObjectMap ])
        && creates a vfp object from xml.
 
    cXml = nfXmlCreate( oVfp )
        && creates XML from a VFP empty-based object

    cXpaths = nfxPaths( cXml )
        && Parse XML w/o schema and show all
        && object paths - please check notes
        && below for important notes about
        && arrays in XML.


## IMPORTANT NOTES

oVfp = nfXMLRead( cXMLstring , cArraysList, @cXpath)

pass xml string, returns a vfp object. ( empty based, requires vfp9 )

**ARRAYS**  ( cArraysList )

Unlike Json, XML does not identify object arrays on the XML document itself, it does it on the XML Schema.

To gain simplicity and ease of use, nfXmlRead uses no XML Schema.

nfXmlRead identifies arrays by counting the child nodes with identical names; so any node with more than one child node with identical name is identified as array, as no object can contain more than 2 properties with the same name.

If you're sure your XML contains no arrays and any contained array will have at least more than one member, you don't need to worry.

For any other situation, you can pass a comma separated list of all the xpaths that must be treated as arrays: a excel workbook contains the following arrays:

"/Workbook/Styles/Style[],/Workbook/Worksheet[]/Table/Row[]/Cell[]"


**NAME PROPERTIES WITH SPECIAL CHARACTERS OR SPACES**  

XML allows node names with spaces and special characters; nfXml safely converts them to valid vfp property names by replacing them on the following way:
* ':' -> '\_'
* '(' -> '\_l\_'
* ')' -> '\_r\_'
* '-' -> '\_h\_'
* '.' -> '\_d\_'

**RESERVERD WORDS OR NON CHARACTER PROPERTY NAMES**  
will be prepended with '\_'
for example, you can't have an array called "row" since "row()" is a vfp function, then it gets renamed to _row also names starting with numbers and so on.

**NODE ATTRIBUTES**  
node attributes are listed in a property called \_attr\_ 

**NAMESPACES**  
Namespaces are prepended to node names, separated by "\_"
this way ss:Styles gets the vfp property name ss\_styles;

object properties with "\_" should be escaped with additional "\_" 

this way:

- oxml.customer\_id gets serialized as: &lt;customer:id&gt;

- oxml.customer\_\_id gets serialized as: &lt;customer\_id&gt;

- oxml.customer\_\_\_id gets serialized as: &lt;customer\_:id&gt;

**OPTIONAL PARAMETERS**  
xpathExp: you can pass any xPath Expression for nfXMLRead to return only
the desired node without parsing the entire document; useful for big xml files.


**ERROR MANAGEMENT**  
program will throw error if you supply invalid xml; manage accordingly.
