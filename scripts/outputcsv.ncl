a=addfile("latlon.nc","r")
b=addfile("latlon_hgt.nc","r")
u=a->uReconstructZonal
printVarSummary(u)
v=a->uReconstructMeridional
latitude0=a->latitude
latitude = latitude0(27:32)
;print(latitude0)
longitude0=a->longitude
longitude = longitude0(17:22)
t=a->time
_t = cd_calendar(t,0)
strs = (/tostring(tointeger(_t(0,0))), " ", tostring(tointeger(_t(0,1))), " ", tostring(tointeger(_t(0,2))), " ", tostring(tointeger(_t(0,3))), ":00:00"/)
ts = str_concat(strs)
;get z0
zgrid = b->zgrid
z1 = zgrid(1:,:,:)
printVarSummary(z1)
dim1 = dimsizes(z1(:,0,0))
dim2 = dimsizes(z1(0,:,0))
dim3 = dimsizes(z1(0,0,:))
z0 = new((/dim1, dim2, dim3/), float)
do i = 0, dim1 -1
    z0(i,:,:) = zgrid(0,:,:)
end do
printVarSummary(z0)
z_temp = z1
z_temp = z1 - z0
z = z_temp(:,27:32,17:22)
z@_FillValue = 20000
;print(z)

; version 1 _plane
;uu_plane = u(:,0,:,:)
;vv_plane = v(:,0,:,:)
;printVarSummary(uu_plane)

; version 2 _plane
;metuu = u(0,:,:,:)
metuu = u(0,:,27:32,17:22)
metuu@_FillValue = 0.001
printVarSummary(metuu)
printVarSummary(z)
;print(metuu)
;print(z)
;metvv = v(0,:,:,:)
metvv = v(0,:,27:32,17:22)
metvv@_FillValue = 0.001
;metvv_at_missing_value = metvv@_FillValue
;if(.not.ismissing(metuu)) then
uu_plane = wrf_user_intrp3d(metuu,z,"h",200,0,False)	;3d	time * 2d
;uu_plane_at_missing_value = uu_plane@_FillValue
;end if
;if(.not.ismissing(metvv)) then
vv_plane = wrf_user_intrp3d(metvv,z,"h",200,0,False)	;3d	time * 2d
;vv_plane_at_missing_value = vv_plane@_FillValue
;end if

lon = (/95.0658/)
lat = (/37.4369/)


u70_mx = linint2_points(longitude, latitude, uu_plane, True, lon, lat,  0)
v70_mx = linint2_points(longitude, latitude, vv_plane, True, lon, lat, 0)

wind = sqrt(u70_mx^2 + v70_mx^2)
winddir = wind_direction(u70_mx, v70_mx,0)


;print(winddir)

;--------------output csv-------------------
foutf = "output" + ".csv"
;bbb = systemfunc("/bin/rm -f "+ foutf )
;header = (/"timestamp, windspeed, winddir"/)
;hlist=[/header/]
;write_table(foutf,"w",hlist,"%s")

alist = [/ts, wind, winddir/]
write_table(foutf,"a",alist,"%s, %9.3f,%9.3f")
