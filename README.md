# nfXml

**Provides two simple to use functions to convert complex XML into a VFP (empty-based) object and vice versa.**

Project Manager: Marco Plaza

Project includes:
* nfXmlRead.prg: standalone function, receives valid XML string or file name, returns VFP empty-based object.
* nfXmlCreate.prg: receives VFP object , returns XML string.
* test.prg: turns sample file test.xml into VFP object.
* test.xml: sample XML file

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


## Sample Test prgs
( run from Tests\ !)
* nfxmltest.prg: main functionallity shown using a excel xml file
* simpleRssReader.prg

## XML Sample Files
* AndroidPhone.xml
* XmlEncodeTest.xml
* excelfile.xml
* Inventory Hierarchy.xml
* invoices.xml
* JobCandidate.xml
* GetAirportInformationByCountry.xml
* RadioSure.xml
* UserExperienceManifest.xml

## Change Log
2016/08/01 v.1.000  
* Initial Release

2016/08/01: v.1.010  
* Minor bug in nfXmlRead 
* added xml sample file "AndroidPhone.xml"

2016/08/09: v.1.050  
* Included file nfXml.h
* Proper support for objects with attributes and no properties ; now identified as <objectName>.textnode
* Bug fix: proper error management for invalid xPath query
* Minor update for help file
* new samples: weather.prg / airportdata.prg
* updated rss.prg
* updated exceltest.prg

2017/01/15: 1.100  
* nfXMLCreate formatted xml option bug fix: supress crlf before/after open/close text node tags
* NEW nfXPaths: get all the Xpaths for the XML document
* deprecated: nfObjectMap
* nfXMLRead improvement: specify arrays using separated comma list of xpaths.

## IMPORTANT NOTES

oVfp = nfXMLRead( cXMLstring , cArraysList, @cXpath)

pass xml string, returns a vfp object. ( empty based, requires vfp9 )

**ARRAYS**  

Unlike Json, XML does not identify object arrays on the XML document itself, it does it on the XML Schema.

To gain simplicity and ease of use, nfXmlRead uses no XML Schema.

nfXmlRead identifies arrays by counting the child nodes with identical names; so any node with more than one child node with identical name is identified as array, as no object can contain more than 2 properties with the same name.

If you're sure your XML contains no arrays and any contained array will have at least more than one member, you don't need to worry.

For any other situation, you can pass a comma separated list of all the xpaths that must be treated as arrays; and should contain no spaces. For example,a excel workbook contains the following arrays:

"/Workbook/Styles/Style[],/Workbook/Worksheet[]/Table/Row[]/Cell[]"

( check the excelTest.prg / run from test folder! )

**NAME PROPERTIES WITH SPECIAL CHARACTERS OR SPACES**  

XML allows node names with spaces and special characters; nfXml safely converts them to valid vfp property names by replacing them on the following way:
* ':' by '\_'
* '(' by '\_l\_'
* ')' by '\_r\_'
* '-' by '\_h\_'
* '.' by '\_d\_'

**RESERVERD WORDS OR NON CHARACTER PROPERTY NAMES**  
will be prepended with '\_'
for example, you can't have an array called "row" since "row()" is a vfp function, then it gets renamed to _row also names starting with numbers and so on.

**NODE ATTRIBUTES**  
any node with attributes will be created as object, and will have a property called \_attr\_ wich will hold the node attributes

**NAMESPACES**  
Namespaces are prepended to node names, separated by "\_"
this way ss:Styles gets the vfp property name ss\_styles;

object properties with "\_" should be escaped with additional "\_" 

this way:

- oxml.customer\_id will serialize as: &lt;customer:id&gt;

- oxml.customer\_\_id will serialize as: &lt;customer\_id&gt;

- oxml.customer\_\_\_id will serialize as: &lt;customer\_:id&gt;

**OPTIONAL PARAMETERS**  
@xpathExp : you can pass any xPath Expression for nfXMLRead to return only
the desired node without parsing the entire document; useful for big xml files.


**ERROR MANAGEMENT**  
program will throw error if you supply invalid xml; manage accordingly.