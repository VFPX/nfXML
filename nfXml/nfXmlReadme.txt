************************************************************************************
* nfXMLread ( VFP XML PARSER  )
* Program created by Marco Plaza , 2013-2016  @vfp2nofox
* distributed under VFPX license terms
**************************************************************************************
*
* oVfp = nfXMLRead( [cXMLstring|fileName] [, cArraysList, @cXpath ])
* 
* will return a vfp object. ( empty based, requires vfp9 ) and optionally populate cXpath with all the document xPaths
*------------------------------------------------------------------------------------
* ARRAYS:
*------------------------------------------------------------------------------------
* Unlike Json, XML does not identify object arrays on the XML document itself,
* it does it on the XML Schema.
*
* To gain simplicity and ease of use, nfXmlRead uses no XML Schema.
*
* nfXmlRead identifies arrays by counting the child nodes with identical names;
* so any node with more than one child node with identical name is identified as array,
* as no object can contain more than 2 properties with the same name.
*
* If you're sure your XML contains no arrays and any contained array will have at least
* more than one member, you don't need to worry.
*
* For any other situation, you can pass a comma separated list of all the xpaths that must be treated as arrays; 
* and should contain no spaces. For example,a excel workbook contains the next arrays:
*
* '/Workbook/Styles/Style[],/Workbook/Worksheet[]/Table/Row[]/Cell[]'
*
* ( check the excelTest.prg / run from test folder! )
*
*-----------------------------------------------------------------------------
* PROPERTIES WITH SPECIAL CHARACTERS OR SPACES
*-----------------------------------------------------------------------------
* XML allows node names with spaces and special characters; nfXml safely
* converts them to valid vfp property names by replacing them on the following way:
* ':' by '_'
* '(' by '_l_'
* ')' by '_r_'
* '-' by '_h_'
* '.' by '_d_'
*
*--------------------------------------------------------------------
* INVALID PROPERTY NAMES will be prepended with '_'
* for example, you can't have an array called "row" since
* "row()" is a vfp function, then it gets renamed to _row
* also names starting with numbers and so on.
*--------------------------------------------------------------------
* NODE ATTRIBUTES:
* any node with attributes will be created as object and will have a
* object property  called _attr_ wich will hold the node attributes
*---------------------------------------------------------------------
* NAMESPACES:
* Namespaces are prepended to node names, separated by "_"
* this way ss:Styles gets the vfp property name ss_styles;
*---------------------------------------------------------------------
* object properties with "_" should be escaped with additional "_"
*
* this way:
* oxml.customer_id   => <customer:id>
* oxml.customer__id =>  <customer_id>
*----------------------------------------------------------------------
* OPTIONAL PARAMETERS:
* xpathExp : you can pass any xPath Expression for nfXMLRead to return only
* the desired node without parsing the entire document; useful for big xml files.
*----------------------------------------------------------------------
* ERRORS:
* program will throw error if you supply invalid xml; manage accordingly.
*
************************************************************************************
