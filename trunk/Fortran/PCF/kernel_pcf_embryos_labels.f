Content-Type: text/plain

C
C     E. Gabriel, August 2012
C
C     This function provides an edge corrected estimate
C     of the space-time pair correlation function.
C

      subroutine kernel_pcf_embryos_labels(x,y,txy,n,xp,yp,np,s,ns,t,nt,
     + bsupt,binft,lambda,ks,kt,edg,hs,ht,embryoID,label,counts,pcfhat)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     x,y,txy: coordinates and times of the point process of length n
c     xp,yp: coordinates of the np points defining the polygonal
c            region
c     s: vector of the ns distances at which to calculate the K
c        function,
c     t: vector of the nt times at which to calculate the K function,
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      implicit real*8(a-h,o-z)
      
      integer n,ns,nt,np,edg,is,it,iu,iv,nv,ks,kt,counts
      double precision pcfhat(ns,nt),two,hs,ht,lambda(n)
      dimension x(n),y(n),txy(n),xp(np+1),yp(np+1),s(ns),t(nt),embryoID(n)
      logical label(n)
      double precision binf,binft,bsup,bsupt,ti,tij
      double precision vij,wij,vji,wji,nev(nt)
      double precision kern,kerns,kernt
      
      two = 2d0
      counts = 0

      do iu = 1,ns
      	do iv = 1,nt
      		do i = 1,n
      
      			if (label(i)) then

      				xi = x(i)
      				yi = y(i)
      				ti = txy(i)
      
      				do j = 1,n
      				
      					if ((i.ne.j).and.(embryoID(i).eq.embryoID(j))) then

							counts = counts + 1;

      						hij = dsqrt( (xi-x(j))*(xi-x(j)) + (yi-y(j))*(yi-y(j)) )
      						tij = dabs(ti-txy(j))
      
      						if (ks.eq.1) then
      							kerns = boxkernel((s(iu)-hij)/hs,hs)
      						else if (ks.eq.2) then
      							kerns = ekernel((s(iu)-hij)/hs,hs)
      						else if (ks.eq.2) then
      							kerns = gausskernel((s(iu)-hij)/hs,hs)
      						else if (ks.eq.4) then
      							kerns = qkernel((s(iu)-hij)/hs,hs)
      						end if
      
      						if (kt.eq.1) then
      							kernt = boxkernel((t(iv)-tij)/ht,ht)
      						else if (kt.eq.2) then
      							kernt = ekernel((t(iv)-tij)/ht,ht)
      						else if (kt.eq.3) then
      							kernt = gausskernel((t(iv)-tij)/ht,ht)
      						else if (kt.eq.4) then
      							kernt = qkernel((t(iv)-tij)/ht,ht)
      						end if
      
      						kern = kerns*kernt
      
      						if (kern.ne.0) then
      							if (edg.eq.1) then
      								bsup = ti+tij
      								binf = ti-tij
      								if ((bsup.le.bsupt).and.(binf.ge.binft)) then
      									vij = 1d0
      								else
      									vij = two
      								end if
      						
      								wij = weight(xi,yi,hij,xp,yp,np)
      								wij = kern*vij*wij/(lambda(i)*lambda(j))
      								pcfhat(iu,iv) = pcfhat(iu,iv) + wij
      					
      							else if (edg.eq.0) then
      								wij = kern/(lambda(i)*lambda(j))
      								pcfhat(iu,iv) = pcfhat(iu,iv) + wij
      							end if
      						end if
      
      					end if
      
      				end do
      
      			end if
      
      		end do
      	end do
      end do

      return
      
      end

c--------------------------------------------------------------------
c
c     boxkernel
c
c--------------------------------------------------------------------

       function boxkernel(x,h)

       implicit real*8 (a-h,o-z)

       double precision x, h

       if (dabs(x).le.1) then
           boxkernel=1d0/2d0
       else
           boxkernel=0d0
       end if
       boxkernel=boxkernel/h

       return
       end

c--------------------------------------------------------------------
c
c     Epanechnikov kernel
c
c--------------------------------------------------------------------

       function ekernel(x,h)

       implicit real*8 (a-h,o-z)

       double precision x

       if (dabs(x).le.1) then
           ekernel=(3d0/4d0)*(1-x**2)
       else
           ekernel=0d0
       end if
       ekernel=ekernel/h

       return
       end

c--------------------------------------------------------------------
c
c     Gaussian kernel
c
c--------------------------------------------------------------------

       function gausskernel(x,h)

       implicit real*8 (a-h,o-z)

       double precision x

       gausskernel=exp(-(x**2)/2d0)/sqrt(pi*2d0)
       gausskernel=gausskernel/h

       return
       end


c--------------------------------------------------------------------
c
c     quartic (biweight) kernel
c
c--------------------------------------------------------------------

       function qkernel(x,h)

       implicit real*8 (a-h,o-z)

       double precision x, h

       if (dabs(x).le.1) then
           qkernel=(15d0/16d0)*(1-x**2)**2
       else
           qkernel=0d0
       end if
       qkernel=qkernel/h

       return
       end


c--------------------------------------------------------------------
c
c     weight
c
c--------------------------------------------------------------------

      function weight(x,y,r,xp,yp,np)
c
c find the weight for the point at x,y, radius r
c
      implicit real*8 (a-h,o-z)

c      include 'bounds.cmn'

      dimension xp(np+1),yp(np+1)

      weight=cncvwt(x,y,r,xp,yp,np)

      return
      end

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     function called by weight:
c     --------------------------
c
c     * cncvwt
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c--------------------------------------------------------------------
c
c     cncvwt
c
c--------------------------------------------------------------------

      function cncvwt(x,y,r,xp,yp,np)
c
c     compute the weight given to a point at x,y according to how much
c     of a circle of radius r is inside the bounding polygon
c
c
      implicit real*8 (a-h,o-z)
c      include 'bounds.cmn'
      dimension xp(np+1),yp(np+1)
      parameter(pi=3.141592654d0)
c     store circle/poly intersections here
      parameter(maxcrs=40)
      dimension cross(maxcrs+1)
      parameter(tiny=1.0e-7)
c     set count of crossing points to zero
      ncross = 0

c     first loop over the boundary and find the crossing points
      do ic=1,np
c     work with the trial point at origin
         x1=xp(ic)-x
         y1=yp(ic)-y
         x2=xp(ic+1)-x
         y2=yp(ic+1)-y

         cx=x2-x1
         cy=y2-y1

c     these are the coefficients of the quadratic giving the
c     intercept of line and circle.
         a=cx*cx+cy*cy
         b=2*(x1*cx+y1*cy)
         c=x1*x1+y1*y1-r*r

c     find out if real solutions exist...
         b2m4ac=b*b-4*a*c

c     ... and if they do, find them.
         if (b2m4ac.ge.0) then
            t1=(-b+sqrt(b2m4ac))/(2*a)
            t2=(-b-sqrt(b2m4ac))/(2*a)

c     see if the solutions lie in the line segments
            if ((t1.gt.tiny).and.(t1-1.0.le.tiny)) then
               ncross=ncross+1
c     find the angle to this point on the circle
               ctemp=atan2(y1+t1*cy,x1+t1*cx)
               if(ctemp.lt.0)ctemp=2*pi+ctemp
               cross(ncross)=ctemp
c     check crossing of circle with vertex
            else if (abs(t1).le.tiny) then
c     compare this polygon segment's direction with that of the
c     previous one
               nprev = (mod((ic+ (np-2)),np)+1)
               x0 = xp(nprev) - x
               y0 = yp(nprev) - y
               idp1 = isig8((x2-x1)*x1+ (y2-y1)*y1,tiny)
               idp2 = isig8((x1-x0)*x1+ (y1-y0)*y1,tiny)
c     see if the polygon passes through the circle here
               if ((idp1-idp2).ne.1 .and.
     +              abs(idp1+idp2).ne.2) then
                  ncross = ncross + 1
                  ctemp = atan2(y1+t1*cy,x1+t1*cx)
                  if (ctemp.lt.0.0) ctemp = 2*pi + ctemp
                  cross(ncross) = ctemp
               end if
            end if

            if ((t2.gt.tiny).and.(t2-1.0.lt.tiny)) then
               ncross=ncross+1
               ctemp=atan2(y1+t2*cy,x1+t2*cx)
               if(ctemp.lt.0)ctemp=2*pi+ctemp
               cross(ncross)=ctemp
c     check crossing of circle with vertex
            else if (abs(t2).le.tiny)then
c     compare this polygon segment's direction with that of the
c     previous one
               nprev = (mod((ic+ (np-2)),np)+1)
               x0 = xp(nprev) - x
               y0 = yp(nprev) - y
               idp1 = isig8((x2-x1)*x1+ (y2-y1)*y1,tiny)
               idp2 = isig8((x1-x0)*x1+ (y1-y0)*y1,tiny)
c     see if the polygon passes through the circle here
               if ((idp1-idp2).ne.1 .and.
     +              abs(idp1+idp2).ne.2) then
                  ncross = ncross + 1
                  ctemp = atan2(y1+t2*cy,x1+t2*cx)
                  if (ctemp.lt.0.0) ctemp = 2*pi + ctemp
                  cross(ncross) = ctemp
               end if
            end if
         end if
      end do

c     now we have all the crossing point angles stored in
c     cross(1:ncross)

c     if ncross = 0 then the total angle within the poly is 2*pi
c     unless the circle is large and spans the polygon. this should
c     be checked beforehand so it's okay to assume 2*pi here.

      if (ncross.eq.0) then
         totang=2*pi
      else

c     sort into ascending order
         call sort2(cross,ncross)

c     fix the ncross+1'th element to be the first plus 2pi so that
c     the list is circular...
         cross(ncross+1)=cross(1)+2*pi

c     check that the number of crossings is even - if not then error.
         if (mod(ncross,2).ne.0) then
            cncvwt=-1
            return
         end if
c     now find a nice spot to do the point-in-poly search
         sepmax=0.0
         icm=0

         do ic=1,ncross
            if (cross(ic+1)-cross(ic).gt.sepmax) then
               sepmax=cross(ic+1)-cross(ic)
               icm=ic
            end if
         end do

c     icm is now the index of the crossing with the largest gap
c     between it and the next crossing point

c     test for point in poly of the point on the circle between these
c     points angtes=(cross(icm)+cross(icm+1))/2.

         xtest=x+r*cos(angtes)
         ytest=y+r*sin(angtes)

c     find out if test point is in the polygon boundary
         linpol=ipippa(xtest,ytest,xp,yp,np)

c     find the total angle between (odd-even) crossings
c     (i.e. 1-2 + 3-4 + ...)
        totang = 0.
        do ic=1,ncross-1,2
           totang = totang + (cross(ic+1)-cross(ic))
        end do

c     If the point we tested for p-i-p was on an odd-even
c     section and was in the poly, then totang is the amount of circle
c     inside the polygon. if the point was outside the polygon, then
c     we need to subtract totang from 2*pi radians to get the angle
c     inside the polygon. conversely, if the point tested was between
c     even-odd crossings and outside the polygon, then totang is the
c     angle we want, and if inside the polygon then again we have to
c     do 2*pi-totang

        if ( (((mod(icm,2).eq.1).and.(linpol.eq.0))  .or.
     &       ((mod(icm,2).eq.0).and.(linpol.eq.1)) ) ) then
           totang = 2*pi-totang
        end if

      end if
c     now totang is the angle contained in the polygon

c     weight is proportion of total angle in the poly
      cncvwt = (2*pi)/(totang)
      return
      end

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     functions called by cncvwt:
c     ---------------------------
c
c     * isig8
c     * sort2
c     * ipippa
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c--------------------------------------------------------------------
c
c     isig8
c
c--------------------------------------------------------------------

      integer function isig8(value,tiny)

c     return the sign (+1,0,-1) of a value

      real*8 tiny,value
      if (value.gt.tiny) then
         isig8 = 1
      else if (value.lt.-tiny) then
         isig8 = -1
      else
         isig8 = 0
      end if
      return
      end

c--------------------------------------------------------------------
c
c     sort2
c
c--------------------------------------------------------------------

      subroutine sort2(x,n)
c
c     shellsort algorithm
c     n     : number of elements to be sorted
c     x     : on enter an array of dimension at least n containing
c             real numbers
c             on output first n elements of x are sorted from smallest
c             to largest
c
      implicit real*8 (a-h,o-z)
      dimension x(n)
      i=1
    1 i=i+1
      if (i.le.n) goto 1
      m=i-1
    2 m=m/2
      if (m.eq.0) return
      k=n-m
      do 4 j=1,k
      kk=j
    3 if (kk.lt.1) goto 4
      if (x(kk+m).ge.x(kk)) goto 4
      w=x(kk+m)
      x(kk+m)=x(kk)
      x(kk)=w
      kk=kk-m
      goto 3
    4 continue
      goto 2
      end


c--------------------------------------------------------------------
c
c     ipippa
c
c--------------------------------------------------------------------

       function ipippa(x,y,xc,yc,nc)
c
c point in polygon routine.
c
c returns 0 if point x,y not in the bound polygon defined by xc,yc
c
c fortran version of C routine by Ken McElvain
c

      implicit real*8 (a-h,o-z)
c      include 'bounds.cmn'


      dimension xc(nc+1),yc(nc+1)

        iwind = 0
        xlastp = xc(nc)
        ylastp = yc(nc)
        ioldq = iquad(xlastp,ylastp,x,y)
        do i=1,nc
c for each point in the polygon
                xthisp=xc(i)
                ythisp=yc(i)
                inewq = iquad(xthisp,ythisp,x,y)
                if(ioldq.ne.inewq) then
                        if(mod(ioldq+1,4).eq.inewq) then
                          iwind=iwind+1
                        else if(mod(inewq+1,4).eq.ioldq) then
                          iwind = iwind - 1
                        else
                          a = (ylastp-ythisp)*(x-xlastp)
                          b = xlastp-xthisp
                          a = a + ylastp * b
                          b=b*y
                             if (a.gt.b) then
                               iwind=iwind+2
                             else
                               iwind=iwind-2
                             end if
                        end if
                end if
                xlastp=xthisp
                ylastp=ythisp
                ioldq=inewq
      end do
c
c quadrant winding is either -4,0,+4 so divide down and take abs.
c
      ipippa = abs(iwind/4)

      end

      function iquad(xp,yp,xo,yo)
c
c determine which quadrant xp,yp is in relative to xo,yo as origin
c
      implicit real*8 (a-h,o-z)

        if(xp.lt.xo)then
                if(yp.lt.yo) then
                   iquad=2
                else
                   iquad=1
                end if
        else
                if(yp.lt.yo)then
                   iquad = 3
                else
                   iquad = 0
                end if
        end if

      return
      end
