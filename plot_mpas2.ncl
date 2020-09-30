a=addfile("latlon.nc","r")
b=addfile("latlon_hgt.nc","r")
u=a->uReconstructZonal
; printVarSummary(u)
v=a->uReconstructMeridional
u10=a->u10
v10=a->v10
pres = a->pressure
rh = a->relhum
t2m = a->t2m
latitude0=a->latitude
latitude = latitude0(214:263)
latitude0@units = "degrees_north"

longitude0=a->longitude
longitude0@units = "degrees_east"
longitude = longitude0(132:190)
print(latitude)
print(longitude)
; print(a)
; print(b)
zgrid = b->zgrid(1:,:,:)  ;[levels | 56] x [lat | 321] x [lon | 321]
; printVarSummary(rh)
; printVarSummary(u10)
; printVarSummary(zgrid)
;output plot 
;; output plot spd
    uu_plane = u(0,0,:,:)   ;[Time | 1] x [levels | 55] x [lat | 321] x [lon | 321]
    vv_plane = v(0,0,:,:)
    spd_plane=sqrt(uu_plane*uu_plane+vv_plane*vv_plane)
    spd_plane!0 = "latitude"
    spd_plane!1 = "longitude"
    spd_plane&latitude = latitude0
    spd_plane&longitude = longitude0

    ; printVarSummary(spd_plane)
    filename="scripts/plot/speed"
    wks = gsn_open_wks("png",filename)
    res = True
    res@cnFillOn = True
    res@gsnDraw  = False
    res@gsnFrame = False
    res@gsnMaximize = True
    res@gsnAddCyclic = False
    res@mpLimitMode = "LatLon"
    res@mpMinLatF = 36.8
    res@mpMaxLatF = 38.0
    res@mpMinLonF = 94.1
    res@mpMaxLonF = 96.1
    ;todo tickmarks

    contour_spd = gsn_csm_contour_map(wks,spd_plane, res)
    draw(contour_spd)
    frame(wks)
    delete(res)
;; plot vertical 
_zgrid = zgrid(:,214:263,132:190)
metuu = u(0,:,214:263,132:190)
metvv = v(0,:,214:263,132:190)
; print(metvv)
; metvv@_FillValue = 0.001
printVarSummary(metvv)
printVarSummary(_zgrid)

; horizonal
; uu_plane_h = wrf_user_intrp3d(metvv,metzgrid,"h",200,0,False)	;3d	time * 2d
; vertical
filename="scripts/plot/speed_vert"
wks = gsn_open_wks("png",filename)
plane = (/ 37.4, 95.2 /)
uu_plane_v = wrf_user_intrp3d(metuu,_zgrid,"v",plane,0,False)	
vv_plane_v = wrf_user_intrp3d(metvv,_zgrid,"v",plane,0,False)	

spd_plane_v = sqrt(uu_plane_v*uu_plane_v + vv_plane_v* vv_plane_v)
spd_plane_v@description = "Wind Speed"
spd_plane_v@units = "m/s"
res = True
res@gsnMaximize = True
res@cnFillOn = True
res@gsnDraw  = False
res@gsnFrame = False
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot_spd = gsn_csm_contour(wks,spd_plane_v, res)
delete(res)

; overlay(plot_spd, plot_spd)
draw(plot_spd)
frame(wks)


;; output plot t2m
    ;todo
;; output plot spd10
    ;todo
;; output plot pres
    ;todo
;; output plot rh
    ;todo

;output csv
    ;todo