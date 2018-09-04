load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;Pasta do repositorio
repofolder	= "~/fontes/graficos_ncl/"

;Pasta com os ncs
ncsfolder		= repofolder + "yearly/"

;Prefixo dos ncs
ncpref			= "drainage" 

;Nome da variavel no nc
ncvarname		= "drainage"

;Pasta com os shapes
shpfolder		= repofolder + "shapes/"

;Shape das bacias
shpbacia		= shpfolder + "Bacias_AIBA.shp"

;Shape do aquifero
shpaquif		= shpfolder + "aquifero_urucuia.shp"

;Arquivo de saida
outpdfname		= repofolder + "painel"

;Anos
syear			= 1990
eyear			= 2015
nyears			= eyear-syear+1

;Dimensoes do painel
paneldims		= (/4,7/)

;Abre a orkstation grafica
wks=gsn_open_wks("pdf",outpdfname)

;Abre o shapefile
;shpbacia = addfile(shpbaciafname,"r")

;Recursos do shape das bacias
resbacia = True
resbacia@gsLineColor = "black"
resbacia@gsLineThicknessF = 3

;Recursos do shape do aquifero
resaquif = True
resaquif@gsLineColor = "blue"
resaquif@gsLineThicknessF = 2

;Recursos de todos os graficos raster
res =True

;Nao desenha a nao avanca o frame automatico, so criar o objeto pro gsn_panel desenhar depois
res@gsnDraw = False
res@gsnFrame = False

;Preenchimento sem contorno
res@cnFillOn = True
res@cnLinesOn = False

;Niveis explicitos
res@cnLevelSelectionMode = "ExplicitLevels"
;res@cnLevels = (/0.0001, 20, 40, 80, 160, 260/)
res@cnLevels = (/ 20, 40, 80, 160, 260/)

;Cores explicitas (de 0 a 1)
;res@cnFillColors = (/ (/255,255,255/),(/140,81,10/),(/216,179,101/),(/246,232,195/),(/199,234,229/),(/90,180,172/),(/1,102,94/) /) /255.
res@cnFillColors = (/(/140,81,10/),(/216,179,101/),(/246,232,195/),(/199,234,229/),(/90,180,172/),(/1,102,94/) /) /255.

;Cor do missing
res@cnMissingValFillColor = 0

;Desliga a labelbar de cada um
res@lbLabelBarOn = False

;Remove as descricoes individuais
res@gsnLeftString = ""
res@gsnRightString = ""

;Remove os tickmarks com lat e lon pra economizar espaco
res@tmXBOn = False
res@tmXTOn = False
res@tmYLOn = False
res@tmYROn = False

;Zoom no oeste da bahia
res@mpMinLonF = -47. 
res@mpMaxLonF = -44.
res@mpMinLatF = -15.
res@mpMaxLatF = -10.

;Colocar isso pro NCL nao esperar um mapa global
res@gsnAddCyclic = False

;Array com todos os objetos graficos que vao ser criados
plots = new(nyears,graphic)

;Arrays com os shapefiles adicionados
baciaids = new(nyears,graphic)
aquifids = new(nyears,graphic)

;Loop dos anos
;year = 1990
i = 0 ;Contador pro array
do year = syear,eyear
	;Abre o arquivo do ano e le a variavel, so o primeiro time
	arqin = addfile(ncsfolder + ncpref + year + ".nc","r")
	varin = arqin->$ncvarname$(0,:,:)

	varin = where(varin.eq.0,varin@_FillValue,varin)

	;Plota em um elemento do array, nao vai ser desenhado ainda	
	plots(i) = gsn_csm_contour_map_ce(wks,varin,res)

	;Adiciona os shapes, usa polylines ao inves de polygons pra nao ter que desenhar um fill transparente. Pra fazer com fill é so trocar a funcao
	;baciaids(i) = gsn_add_shapefile_polygons(wks,plots(i),shpbacia,resbacia)
	baciaids(i) = gsn_add_shapefile_polylines(wks,plots(i),shpbacia,resbacia)
	aquifids(i) = gsn_add_shapefile_polylines(wks,plots(i),shpaquif,resaquif)

	i = i+1 ;Soma o contador
end do ;year

;Recursos do painel
respanel = True

;Labelbar comum
respanel@gsnPanelLabelBar=True
;Titulo dela
respanel@lbTitleString = "Drainage (mm/year)"
respanel@lbTitlePosition = "Bottom"
respanel@lbTitleFontHeightF = 0.02 ;tamanho da fonte do titulo
;Justifica a labelbar pelo topo pra ter certeza de que nao vai sobrepor
respanel@lbJustification = "TopCenter"
;Deixa 10% sobrando de espaço embaixo pra legenda nao cortar
respanel@gsnPanelBottom = 0.1

;Adiciona labels com os anos
respanel@gsnPanelFigureStrings = ispan(syear,eyear,1) ;ispan gera um array
respanel@gsnPanelFigureStringsFontHeightF =0.015 ;Tamanho da fonte 
respanel@amJust= "TopRight" ;Posicao das labels

;Desenha o painel
gsn_panel(wks,plots,paneldims,respanel)
end
