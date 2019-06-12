************************************************************************************
* Marco Plaza , 2013-2017
* @nfTools
************************************************************************************
parameters ovfp,nofmt
#include nfxml.h

if vartype(m.ovfp) # 'O' or vartype(m.nofmt) # 'L'
	error "Invalid parameter type"
	return
endif

private all
m.crlf = iif(!m.nofmt,chr(13)+chr(10),'')

cxml=''
=o2xml(m.ovfp,'','',m.crlf)

if amembers(aa,m.ovfp,0,'U') > 1
	cxml = '<xml>'+m.cxml+m.crlf+'</xml>'
endif

cxml = '<?xml version="1.0" encoding="utf-8"?>'+m.cxml

return strconv(m.cxml,9)

*-----------------------------------------------------------
function o2xml(esteo,oname,nivel,m.crlf,atributos,atclosetag)
*-----------------------------------------------------------

oname = lower(m.oname)

private all except cxml

closetag = ''

otag = xtag(m.oname)

np = amembers(aprop,m.esteo,0,'U')


do case

case atributos

	closetag = m.atclosetag

case !empty(m.otag)

	cxml = m.cxml+m.crlf+m.nivel+'<'+m.otag

	if type('esteo.'+attributetag) # 'O'
		cxml = m.cxml+'>'
	endif

	if type('esteo.'+attributetag) # 'O' or m.np > 1
		closetag = crlf+m.nivel+'</'+m.otag+'>'
	endif

endcase

if '' # m.crlf
	nivel = m.nivel+space(3)
endif

if m.np > 0

* colocar atributos de 1ero:

	npa = ascan(aprop,attributetag,1,-1,1,1)

	if npa > 0
		=acopy(aprop,tempa)
		aprop(1) = tempa(npa)
		aprop(npa) = tempa(1)
	endif

	for each vari in m.aprop

		esarray  = type('esteo.&vari',1) = 'A'
		esobjeto = type('esteo.&vari') = 'O'

		do case

		case lower(m.vari) = attributetag

			=o2xml(esteo.&vari,m.vari,m.nivel,m.crlf, .t. , iif(m.np > 1,'>','/>') )


		case esarray

			for x = 1 to alen(esteo.&vari)

				m.ele = esteo.&vari(m.x)

				if vartype(m.ele) = 'O'

					=o2xml(m.ele,m.vari,m.nivel,m.crlf)

				else

					valoraxml( m.vari, m.ele , m.atributos , m.nivel )

				endif


			endfor

		case esobjeto

			=o2xml(esteo.&vari,m.vari,m.nivel,m.crlf)

		otherwise
			valoraxml( m.vari, esteo.&vari , m.atributos , m.nivel , @closetag )

		endcase

	endfor

endif


cxml = m.cxml+m.closetag




*------------------------
function xtag(kk)
*------------------------

if lower(m.kk) == attributetag or lower(M.kk) == nodetexttag
	return m.kk
endif

private all

tr = sys(3)
kk = strtran(m.kk,'__',m.tr)
kk = ltrim( m.kk,1,'_')

for n = 2 to escapecount*2 step 2
	m.kk =	strtran(m.kk,getwordnum(escapelist,m.n,','), getwordnum(escapelist,m.n-1,',') )
endfor

kk = strtran(m.kk,m.tr,'_')

return m.kk


*-------------------------------
function escapar(valor)
*-------------------------------
if len(chrtran(m.valor,["'<>&],'')) # len(m.valor)
	valor = strtran(m.valor,[&],[&amp;])
	valor = strtran(m.valor,['],[&apos;])
	valor = strtran(m.valor,[<],[&lt;])
	valor = strtran(m.valor,[>],[&gt;])
	valor = strtran(m.valor,["],[&quot;])
endif

return m.valor

*-------------------------------------------------------------------
procedure valoraxml( vari, valor , atributos , nivel , closetag )
*-------------------------------------------------------------------

m.xtag = lower(xtag(m.vari))

do case
case lower(m.vari) == nodetexttag
	m.cxml = m.cxml+escapar(transform(m.valor))
	closetag = ltrim(m.closetag,1,crlf)

case !atributos
	if !empty(m.valor)
		m.cxml = m.cxml+m.crlf+m.nivel+'<'+m.xtag+'>'+escapar(transform(m.valor))+'</'+m.xtag+'>'
	else
		m.cxml = m.cxml+m.crlf+m.nivel+'<'+m.xtag+'/>'
	endif

otherwise
	m.cxml = m.cxml+' '+m.xtag+'="'+escapar(transform(m.valor))+'"'
endcase

