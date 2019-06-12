************************************************************************************
* nfXMLread ( VFP XML PARSER  )
* Marco Plaza , 2013-2018  @nfTools
* Last Update: 2018-11-08
**************************************************************************************
Parameters cxml,_arrayslist,xpathexp,_xpaths

#include nfxml.h
#Define crlf Chr(13)+Chr(10)

_arrayslist = Lower(','+Evl(m._arrayslist,'')+',')

Private All

stacklevels=Astackinfo(aerrs)

If m.stacklevels > 1
	calledfrom = 'called From '+aerrs(m.stacklevels-1,4)+' line '+Transform(aerrs(m.stacklevels-1,5))
Else
	calledfrom = ''
Endif

Do Case
Case Vartype(m.cxml) # 'C'
	Error 'Must supply a valid Xml string or file name'
Otherwise
	oxml = nfxmlread2( cxml,_arrayslist,xpathexp , @_xpaths )
Endcase

If Vartype(m.oxml) = 'O'
	If Type('m.oxml.xml') = 'O'
		m.oxml = m.oxml.XML
	Endif
	Return m.oxml
Else
	Return .Null.
Endif


*---------------------------------------------------------------
Procedure nfxmlread2( cxml,_arrayslist,xpathexp,_xpaths )
*---------------------------------------------------------------

omsxml = Createobject('msXml.domdocument')
cerror = ''

With omsxml As msxml.domdocument

	.Async = .F.

	If Len(m.cxml) < 200 And File(m.cxml)
		.Load( m.cxml )
	Else
		.LoadXML(m.cxml)
	Endif

	If !Empty(.parseerror.reason)

		cerror =  'msxml parseerror parsing XML line '+Transform(.parseerror.Line)+' : "'+Rtrim(.parseerror.reason)+'"'
		Lineno = 0

	Else

		If Vartype(m.xpathexp) = 'C'

			Try

				oxmlnodes = .selectnodes(m.xpathexp)

			Catch

				cerror =  ' invalid XPATH expression ('+m.xpathexp+')'
				Lineno = 0

			Endtry

		Else

			oxmlnodes = .childnodes()

		Endif

		If Vartype(m.oxmlnodes) = 'O' And Empty(m.cerror)

			Try
				ovfp = Createobject('empty')
				recnodo(m.oxmlnodes,m.ovfp,'',_arrayslist,@_xpaths)
			Catch To oerr
				cerror = oerr.Message+' '+Transform(oerr.Lineno)
				Lineno = oerr.Lineno
			Endtry

		Endif


	Endif

Endwith

If !Empty(m.cerror)
	Error 'nfXML '+m.calledfrom+': '+m.cerror
	Return .F.
Else
	Return m.ovfp
Endif


*---------------------------------------------------------------------------------
Procedure recnodo( onodos, esteo , _parentnode , _arrayslist , _xpaths )
*---------------------------------------------------------------------------------

Private All

isarray = .F.
lastnodename = ''

For Each nodo In onodos

	With nodo

		If ( .nodetype # 1 And .nodetype # 3  ) Or .nodename = '#text'
			Loop
		Endif

		estextnode = .nodetype = 3 Or ( .childnodes.Length = 1 And ( .firstchild.nodetype = 3 Or .firstchild.nodetype = 4 ) )
		emptynode = .childnodes.Length = 0

		Try
			tieneatributos = .Attributes.Length > 0
		Catch
			tieneatributos = .F.
		Endtry

		Do Case
		Case m.emptynode And !m.tieneatributos
			nuevovalor = ''
		Case m.estextnode And !m.tieneatributos
			nuevovalor = .firstchild.nodevalue
		Otherwise
			nuevovalor = Createobject('empty')
		Endcase

		If !m.isarray Or ! .nodename == m.lastnodename

			lastnodename = .nodename
			propertyname = conv2asc(.nodename)
			siblings = .selectnodes('../'+.nodename)

			dupElements = Vartype(m.siblings) = 'O' And m.siblings.Length >  1

			If  Lower(','+_parentnode+'/'+.nodename+'[]') $ m._arrayslist Or m.dupElements
			
				Try

					AddProperty(m.esteo,(m.propertyname+'(1)'))

				Catch

					propertyname = '_'+m.propertyname

					AddProperty(m.esteo,(m.propertyname+'(1)'))

				Endtry

				esteo.&propertyname(1) = m.nuevovalor
				elemproc = 'esteo.'+m.propertyname+'(1)'
				isarray = .T.
				arrayindicator = '[]'

			Else

				AddProperty(m.esteo,m.propertyname,m.nuevovalor)
				elemproc = 'esteo.'+m.propertyname
				isarray = .F.
				arrayindicator = ''

			Endif

		Else

			nvoelem = Alen(esteo.&propertyname)+1
			nelemx  = Alen(esteo.&propertyname)

			Dimension esteo.&propertyname( m.nvoelem )
			esteo.&propertyname( nvoelem ) = m.nuevovalor
			elemproc = 'esteo.'+m.propertyname+'('+Transform(m.nvoelem)+')'

		Endif

		If Vartype(m._xpaths) = 'C'

			currentxpath = m._parentnode+'/'+.nodename+m.arrayindicator

			If Not m.currentxpath $ m._xpaths
				_xpaths = m._xpaths+ m.currentxpath+crlf
			Endif

		Endif


		If m.tieneatributos

			If m.estextnode
				AddProperty(&elemproc,nodetexttag,.firstchild.nodevalue)

				If Vartype(m._xpaths) = 'C'
					currentxpath = m._parentnode
					If Not m.currentxpath $ m._xpaths
						_xpaths = m._xpaths+m.currentxpath+crlf
					Endif
				Endif


			Endif

			AddProperty(&elemproc,attributetag,Createobject('empty'))

			oa = m.elemproc+'.'+attributetag

			For Each atributo In .Attributes

				nombreatr = conv2asc(atributo.Name)

				Try
					AddProperty(&oa,m.nombreatr,atributo.Value)
				Catch
					m.nombreatr = '_'+m.nombreatr
					AddProperty(&oa,m.nombreatr,atributo.Value)
				Endtry

				If Vartype(m._xpaths) = 'C'
					currentxpath = m._parentnode+'/'+.nodename+m.arrayindicator+'/@'+m.atributo.Name
					If Not m.currentxpath $ m._xpaths
						_xpaths = m._xpaths+m.currentxpath+crlf
					Endif
				Endif

			Endfor

		Endif

		If !m.estextnode And .childnodes.Length > 0
			=recnodo( .childnodes(), &elemproc , _parentnode+'/'+.nodename+m.arrayindicator, _arrayslist , @_xpaths )
		Endif

	Endwith


Endfor


*------------------------------
Function conv2asc( ctag )
*------------------------------

Local N

ctag = Strtran(m.ctag,'_','__')

For N = 2 To escapecount*2 Step 2
	m.ctag = Strtran(m.ctag,Getwordnum(escapelist,m.n-1,','), Getwordnum(escapelist,m.n,',') )
Endfor

Return m.ctag



*************************************************************************
