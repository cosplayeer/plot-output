a=addfile("latlon.nc","r")
b=addfile("latlon_hgt.nc","r")
u=a->uReconstructZonal
printVarSummary(u)
v=a->uReconstructMeridional
u10=a->u10
v10=a->v10
pres = a->pressure
rh = a->relhum
t2m = a->t2m
latitude0=a->latitude
latitude = latitude0(27:32)
latitude0@units = "degrees_north"
printVarSummary(latitude0)
longitude0=a->longitude
longitude0@units = "degrees_east"
longitude = longitude0(17:22)

; print(a)
printVarSummary(rh)
printVarSummary(u10)

;output plot 
;; output plot spd
    filename="scripts/plot/speed"
    uu_plane = u(0,0,:,:)   ;[Time | 1] x [levels | 55] x [lat | 321] x [lon | 321]
    vv_plane = v(0,0,:,:)
    spd_plane=sqrt(uu_plane*uu_plane+vv_plane*vv_plane)
    spd_plane!0 = "latitude"
    spd_plane!1 = "longitude"
    spd_plane&latitude = latitude0
    spd_plane&longitude = longitude0

    printVarSummary(spd_plane)
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

    contour_spd = gsn_csm_contour_map(wks,spd_plane, res)
    draw(contour_spd)
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