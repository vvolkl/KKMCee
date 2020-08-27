************************************************************************************
*                                                                                  *
*                         Pseudo Class RRes                                        *
*                                                                                  *
************************************************************************************

 
************************************************************************
* This part contains the functions representing the 1-- resonating
* structure needed to build up the R-ratio.
*
* All contributions are given in units of the mu+mu- cross-section.
*
* Maarten Boonekamp, sept. 2001

      DOUBLE PRECISION FUNCTION RRes_CorQQ(roots,i,xmi)
************************************************************************
* Old name: R_QQ
*
* Part of R attributed to given quark flavour, for use inside 2/4-fermion
* generators : - charge/colour factors are divided out
*              - threshold factors are divided out
*
* Arguments : roots = c.o.m. energy
*             i     = quark index, d,u,s,c,b <=> 1,2,3,4,5
*             xmi   = corresponding mass
*
* Maarten Boonekamp, sept. 2001
************************************************************************

C Declarations
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
*
      DOUBLE PRECISION R_QQ
      INCLUDE 'RRes.h'

C Start
      s = roots**2
      R_QQ = 1d0

C Contribution from QQ
      IF(i.EQ.1.OR.i.EQ.2) THEN
        R_QQ = RRes_UD(s) * 3d0/5d0
        IF(s.GT.xmphi**2) THEN
          R_QQ = R_QQ + 2d0/(1d0+DEXP(-3d0*(s-1d0)))-1d0
          R_QQ = R_QQ / ( beta(xmi,s)*(3d0-beta(xmi,s)**2)/2d0 )
        ENDIF
      ELSEIF(i.EQ.3) THEN
        R_QQ = RRes_SS(s) * 3d0
        IF(s.GT.xmphi**2) THEN
          R_QQ = R_QQ + 2d0/(1d0+DEXP(-3d0*(s-1d0)))-1d0
          R_QQ = R_QQ / ( beta(xmi,s)*(3d0-beta(xmi,s)**2)/2d0 )
        ENDIF
      ELSEIF(i.EQ.4) THEN
        R_QQ = RRes_CC(s) * 3d0/4d0
        IF(s.GT.xmps4**2) THEN
          R_QQ = R_QQ + 1d0
          R_QQ = R_QQ / ( beta(xmi,s)*(3d0-beta(xmi,s)**2)/2d0 )
        ENDIF
      ELSEIF(i.EQ.5) THEN
        R_QQ = RRes_BB(s) * 3d0
        IF(s.GT.xmup4**2) THEN
          R_QQ = R_QQ + 1d0
          R_QQ = R_QQ / ( beta(xmi,s)*(3d0-beta(xmi,s)**2)/2d0 )
        ENDIF
      ENDIF
      RRes_CorQQ = R_QQ
      END

      SUBROUTINE RRes_GetPeaks(rsmax,Npeaks,Xpeaks)
************************************************************************
*
* Sets the number of peaks and their position first in units of c.o.m.
* energy, the positions are then converted according to BornV_BinBack1.
*
* Arguments : rsmax     = c.o.m. energy (GeV)        (input)
*             Npeaks    = nb of peaks                (output)
*             Xpeaks(i) = position of peak / rsmax   (output)
*
* Maarten Boonekamp, sept. 2001
************************************************************************

C Declarations
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Xpeaks(*)
      INCLUDE 'RRes.h'

C Peak positions
      Xpeaks( 1) = xmrho / rsmax
      Xpeaks( 2) = xmome / rsmax
      Xpeaks( 3) = xmphi / rsmax
      Xpeaks( 4) = xmpsi / rsmax
      Xpeaks( 5) = xmps2 / rsmax
      Xpeaks( 6) = xmps3 / rsmax
      Xpeaks( 7) = xmps4 / rsmax
      Xpeaks( 8) = xmps5 / rsmax
      Xpeaks( 9) = xmps6 / rsmax
      Xpeaks(10) = xmups / rsmax
      Xpeaks(11) = xmup2 / rsmax
      Xpeaks(12) = xmup3 / rsmax
      Xpeaks(13) = xmup4 / rsmax
      Xpeaks(14) = xmup5 / rsmax
      Xpeaks(15) = xmup6 / rsmax
      Xpeaks(16) = xmz   / rsmax

C How many are open?
      Npeaks = 0
      DO I = 1, 16
        IF(Xpeaks(I).LT.1d0) Npeaks = Npeaks + 1
      ENDDO

C end
      RETURN
      END


      DOUBLE PRECISION FUNCTION RRes_F_PI_SQ(s)
************************************************************************
*
* The pion form factor, according to a LHS parametrization
* Fit from CMD-2 collaboration : hep-ex/9904027
*
* Arguments : s = c.o.m. energy squared
*
* Maarten Boonekamp, sept. 2001
************************************************************************

C Declarations
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
c ... physical constants and fit parameters
      PARAMETER ( a_LHS=2.381d0 )    ! LHS parameter
      PARAMETER ( delta=1.6d-3 )     ! rho-omega mixing
      DOUBLE COMPLEX F_pi
      INCLUDE 'RRes.h'

C pion form factor
      F_pi = -a_LHS / 2d0 + 1d0 + a_LHS / 2d0 * BrWig(xwrho,xmrho,s)
     &                            * (1d0 + delta * BrWig(xwome,xmome,s))
     &                            / (1d0 + delta)
      RRes_F_PI_SQ = F_pi * CONJG(F_pi)

C end
      RETURN
      END

      DOUBLE PRECISION FUNCTION RRes_UD(s)
************************************************************************
*
* Resonating contribution from uu and dd pairs (rho and omega families).
* Data from PDG'2000
* 
* Arguments : s = c.o.m. energy squared
* 
* Maarten Boonekamp, sept. 2001
************************************************************************
C Declarations
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'RRes.h'
C Resonating contribution
      RRes_UD = 0d0
c ... exit below threshold
      IF(s.lt.4d0*xmpic**2) RETURN
c ... rho(770), including interf. with omega(782), 2pi channel only
      IF(s.gt.4d0*xmpic**2.and.s.lt.2d0**2) THEN
        BetaPiC = DSQRT(1d0-4d0*xmpic**2/s)
********RRes_UD =RRes_UD +pi*alQED**2/3d0*beta(xmpic,s)**3 *RRes_F_PI_SQ(s)         ! CMD2 99
********RRes_UD =RRes_UD +pi/3d0*alQED**2*BetaPiC**3       *RRes_F_PI_SQ(s)         ! CMD2 99, mb
********RRes_UD =RRes_UD +pi/3d0*alQED**2*beta(xmpic,s)**3 *RRes_F_Pi_Kuehn90_SQ(s) ! vOLD 90
********RRes_UD =RRes_UD +pi/3d0*alQED**2*beta(xmpic,s)**3 *RRes_F_Pi_Kuehn02_SQ(s) ! KLOE 02
        RRes_UD =RRes_UD +pi/3d0*alQED**2*beta(xmpic,s)**3 *RRes_FPi_Phk_SQ(s)   ! Phokara 03
      ENDIF
c ... omega(782), all channels, mainly 3pi
      IF(s.GT.(xmome - 100d0*xwome)**2.AND.
     &   s.LT.(xmome + 100d0*xwome)**2) THEN
        RRes_UD = RRes_UD + 3*pi*omeee*BW_sq(xwome,xmome,s)
      ENDIF
c ... normalize
      RRes_UD = RRes_UD / xsmu
      END

      DOUBLE PRECISION FUNCTION RRes_SS(s)
************************************************************************
*
* Resonating contribution from ss pairs (phi family).
* Data from PDG'2000
*
* Arguments : s = c.o.m. energy squared
*
* Maarten Boonekamp, sept. 2001
************************************************************************

C Declarations
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'RRes.h'

C Resonating contribution
      RRes_SS = 0d0
c ... exit below threshold
      IF(s.lt.4d0*xmkac**2) RETURN
c ... phi(1020)
      IF(s.gt.(xmphi - 100d0*xwphi)**2.and.
     &   s.lt.(xmphi + 100d0*xwphi)**2) THEN
        RRes_SS = RRes_SS + 3*pi*phiee*BW_sq(xwphi,xmphi,s)
      ENDIF
c ... normalize
      RRes_SS = RRes_SS / xsmu
      
C end
      RETURN
      END

      DOUBLE PRECISION FUNCTION RRes_CC(s)
************************************************************************
*
* Resonating contribution from ss pairs (psi family).
* Data from PDG'2000
*
* Maarten Boonekamp, sept. 2001
************************************************************************

C Declarations
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'RRes.h'

C Resonating contribution
      RRes_CC = 0d0
c ... exit below threshold
      IF(s.lt.(xmpsi - 100d0*xwpsi)**2) RETURN
c ... psi's
      IF(s.gt.(xmpsi - 100d0*xwpsi)**2.and.
     &   s.lt.(xmpsi + 100d0*xwpsi)**2) THEN
        RRes_CC = RRes_CC + 3*pi*psiee*BW_sq(xwpsi,xmpsi,s)
      ENDIF
      IF(s.gt.(xmps2 - 100d0*xwps2)**2.and.
     &   s.lt.(xmps2 + 100d0*xwps2)**2) THEN
        RRes_CC = RRes_CC + 3*pi*ps2ee*BW_sq(xwps2,xmps2,s)
      ENDIF
      IF(s.gt.(xmps3 - 100d0*xwps3)**2.and.
     &   s.lt.(xmps3 + 100d0*xwps3)**2) THEN
        RRes_CC = RRes_CC + 3*pi*ps3ee*BW_sq(xwps3,xmps3,s)
      ENDIF
      IF(s.gt.(xmps4 - 100d0*xwps4)**2.and.
     &   s.lt.(xmps4 + 100d0*xwps4)**2) THEN
        RRes_CC = RRes_CC + 3*pi*ps4ee*BW_sq(xwps4,xmps4,s)
      ENDIF
      IF(s.gt.(xmps5 - 100d0*xwps5)**2.and.
     &   s.lt.(xmps5 + 100d0*xwps5)**2) THEN
        RRes_CC = RRes_CC + 3*pi*ps5ee*BW_sq(xwps5,xmps5,s)
      ENDIF
      IF(s.gt.(xmps6 - 100d0*xwps6)**2.and.
     &   s.lt.(xmps6 + 100d0*xwps6)**2) THEN
        RRes_CC = RRes_CC + 3*pi*ps6ee*BW_sq(xwps6,xmps6,s)
      ENDIF
c ... normalize
      RRes_CC = RRes_CC / xsmu
     
C end
      RETURN
      END

      DOUBLE PRECISION FUNCTION RRes_BB(s)
************************************************************************
*
* Resonating contribution from ss pairs (upsilon family).
* Data from PDG'2000
*
* Arguments : s = c.o.m. energy squared
*
* Maarten Boonekamp, sept. 2001
************************************************************************

C Declarations
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'RRes.h'

C Resonating contribution
      RRes_BB = 0d0
c ... exit below threshold
      IF(s.lt.(xmups - 100d0*xwups)**2) RETURN
c ... upsilons
      IF(s.gt.(xmups - 100d0*xwups)**2.and.
     &   s.lt.(xmups + 100d0*xwups)**2) THEN
        RRes_BB = RRes_BB + 3*pi*upsee*BW_sq(xwups,xmups,s)
      ENDIF
      IF(s.gt.(xmup2 - 100d0*xwup2)**2.and.
     &   s.lt.(xmup2 + 100d0*xwup2)**2) THEN
        RRes_BB = RRes_BB + 3*pi*up2ee*BW_sq(xwup2,xmup2,s)
      ENDIF
      IF(s.gt.(xmup3 - 100d0*xwup3)**2.and.
     &   s.lt.(xmup3 + 100d0*xwup3)**2) THEN
        RRes_BB = RRes_BB + 3*pi*up3ee*BW_sq(xwup3,xmup3,s)
      ENDIF
      IF(s.gt.(xmup4 - 100d0*xwup4)**2.and.
     &   s.lt.(xmup4 + 100d0*xwup4)**2) THEN
        RRes_BB = RRes_BB + 3*pi*up4ee*BW_sq(xwup4,xmup4,s)
      ENDIF
      IF(s.gt.(xmup5 - 100d0*xwup5)**2.and.
     &   s.lt.(xmup5 + 100d0*xwup5)**2) THEN
        RRes_BB = RRes_BB + 3*pi*up5ee*BW_sq(xwup5,xmup5,s)
      ENDIF
      IF(s.gt.(xmup6 - 100d0*xwup6)**2.and.
     &   s.lt.(xmup6 + 100d0*xwup6)**2) THEN
        RRes_BB = RRes_BB + 3*pi*up6ee*BW_sq(xwup6,xmup6,s)
      ENDIF
c ... normalize
      RRes_BB = RRes_BB / xsmu
      
C end
      RETURN
      END

      DOUBLE PRECISION FUNCTION RRes_R_TOT(roots)
************************************************************************
*
* Total R-ratio, including resonances and continuum.
* The continuum is simply taken partonic (to be improved?)
*
* Arguments : roots = c.o.m. energy
*
* Maarten Boonekamp, sept. 2001
************************************************************************
      IMPLICIT NONE
      DOUBLE PRECISION roots
      DOUBLE PRECISION RRes_UD, RRes_SS, RRes_CC, RRes_BB, s
      INCLUDE 'RRes.h'
C Normalize
      s = roots**2
C Total contribution
      RRes_R_TOT = 0d0
      RRes_R_TOT = RRes_R_TOT + RRes_UD(s)
      RRes_R_TOT = RRes_R_TOT + RRes_SS(s)
      IF(s.GT.xmphi**2) THEN   ! accounts for the dip in R just after the Phi
         RRes_R_TOT = RRes_R_TOT + 4d0/(1d0+DEXP(-3d0*(s-1d0)))-2d0
      ENDIF
      RRes_R_TOT = RRes_R_TOT + RRes_CC(s)
      IF(s.GT.xmps4**2) THEN   ! udsc partonic R-ratio
         RRes_R_TOT = RRes_R_TOT + 4d0/3d0
      ENDIF
      RRes_R_TOT = RRes_R_TOT + RRes_BB(s)
      IF(s.GT.xmup4**2) THEN   ! udscb partonic R-ratio
         RRes_R_TOT = RRes_R_TOT + 1d0/3d0
      ENDIF
      END

      DOUBLE PRECISION FUNCTION RRes_Rqq(kf,roots)
************************************************************************
*     this function is for plotting components
*     kf=1,2,3,4,5  is  d,u,s,c,b;     kf=12 is u+d
************************************************************************
      IMPLICIT NONE
      INTEGER          kf
      DOUBLE PRECISION roots
      DOUBLE PRECISION RRes_UD, RRes_SS, RRes_CC, RRes_BB, s, Rone
      INCLUDE 'RRes.h'
      s = roots**2
      RRes_Rqq =0d0
      Rone = 2d0/(1d0+DEXP(-3d0*(s-1d0)))-1d0   !  <--  one for large s
      IF(     kf.EQ.1 )  THEN   ! d
        IF(s.GT.xmphi**2)  RRes_Rqq = RRes_Rqq +(1d0/3d0)*Rone
         RRes_Rqq = RRes_Rqq +(1d0/5d0)*RRes_UD(s)
      ELSEIF( kf.EQ.2 )  THEN   ! u
         IF(s.GT.xmphi**2) RRes_Rqq = RRes_Rqq +(4d0/3d0)*Rone
         RRes_Rqq = RRes_Rqq +(4d0/5d0)*RRes_UD(s)
      ELSEIF( kf.EQ.3 )  THEN   ! s
         IF(s.GT.xmphi**2) RRes_Rqq = RRes_Rqq +(1d0/3d0)*Rone
         RRes_Rqq = RRes_Rqq +RRes_SS(s)
      ELSEIF( kf.EQ.4 )  THEN   ! c
         IF(s.GT.xmps4**2) RRes_Rqq = RRes_Rqq +4d0/3d0
         RRes_Rqq = RRes_Rqq +RRes_CC(s)
      ELSEIF( kf.EQ.5 )  THEN   ! b
         IF(s.GT.xmup4**2) RRes_Rqq = RRes_Rqq +1d0/3d0
         RRes_Rqq = RRes_Rqq +RRes_BB(s)
      ELSE
         WRITE(*,*) '+++ STOP in RRes_Rqq: wrong kf = ',kf
         STOP
      ENDIF
      END

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C     This routine performs hadronization for low mass qq systems,
C     using experimental exclusive cross-sections.
C     It is useful in the mass range 2*m_pi -> 2 GeV.
C
C     Maarten Boonekamp          feb. 2000
C
C     COSTUMIZED FOR KK2f        sept. 2001
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

C----------------------------------------------------------------------
      SUBROUTINE RRes_HADGEN(QQMOM,IQ1,IQ2,IDEBUG)
C this is to be called once per quark pair and does the whole treatment
C (generation and filling of JETSET commons).
C     -> input:    QQMOM    lab-frame 4-vector of the qq system
C                           (1,...,4) = px, py, pz, E
C                  IQ1,IQ2  positions in LUND of the quarks
C                           we want to hadronize
C                  IDEBUG   =1 for some prints

      IMPLICIT NONE
C pion mass
      DOUBLE PRECISION XMPIC
      PARAMETER ( XMPIC = 0.13957d0 )
C Jetset limit
      DOUBLE PRECISION RSLIM
      PARAMETER ( RSLIM= 2.d0 )
C argumentS
      DOUBLE PRECISION QQMOM(4)
      INTEGER IQ1, IQ2, IDEBUG
C internal variables
      INTEGER I, J, IQ, IRES, NP, NPMAX, IPASS, Npos   ! <--###-
      PARAMETER ( NPMAX = 10 )
      DOUBLE PRECISION PIMOM(4,NPMAX), ROOTS
      INTEGER KCODE(NPMAX)
      INTEGER nhep1,nhep2
      DATA IPASS / 1 /
C external functions
      INTEGER RRes_PYFLAV
      INTEGER KeyRes

C initialise
      DO I = 1, 4
        DO J = 1, NPMAX
          PIMOM(I,J) = 0.d0
        ENDDO
      ENDDO
      DO I = 1, NPMAX
        KCODE(I) = 0
      ENDDO

C compute center-of-mass energy
      ROOTS = QQMOM(4)**2d0-QQMOM(1)**2d0-QQMOM(2)**2d0-QQMOM(3)**2d0
      ROOTS = DSQRT(ROOTS)

C if we are below 2*m_pi, stop
      IF(ROOTS.LT.2*XMPIC) THEN
        PRINT*, 'ROOT(S)=',ROOTS,' BELOW THRESHOLD ; EXIT'
        STOP
      ENDIF

C find flavour of quark pair
      IQ = RRes_PYFLAV(IQ1)

C check if we are on a resonance : rho, omega, phi, J/Psi, Upsilon
      IF(RRes_PYFLAV(IQ1).EQ.RRes_PYFLAV(IQ2)) THEN
        CALL RRes_RESGEN(ROOTS,IQ,IRES,IDEBUG)    ! <--###-
        IF(IRES.NE.0) THEN
C       -> fill PYJETS
          CALL RRes_PYRESO(IQ1,IQ2,QQMOM,IRES,IDEBUG,  Npos)
*       -> rho decayed using dedicated program (Pythia com.block!)
          IF(IRES.EQ.1) THEN
             CALL RRes_RhoDecay(Npos)    !  rho0 --> pi+pi-  simulation
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* PHOTOS used for rho0 decay for KeyRes=2
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
             CALL BornV_GetKeyRes(KeyRes)   ! Use PHOTOS for KeyRes=2
             IF(KeyRes.EQ.2) THEN
                CALL BornV_GetKeyRes(KeyRes)
                CALL PHOINI     ! should be shifted to initilization part
                CALL pyhepc(1)  ! Pythia-->HepEvt
                CALL HepEvt_SetPhotosFlagTrue(Npos)
                CALL HepEvt_GetNhep( nhep1 ) ! get no. of entries in HepEvt
                CALL PHOTOS(Npos) ! Photos works on HepEvt
                !write(16,*) " >>>>>>>>>>> Npos= ", Npos
                !write( *,*) " >>>>>>>>>>> Npos= ", Npos
                !CALL PHODMP
                CALL HepEvt_GetNhep( nhep2 ) ! get no. of entries in HepEvt
                CALL pyhepc(2)  ! HepEvt-->Pythia
                IF(nhep1.NE.nhep2) THEN
                   WRITE(*,*) "888888888888888888888888888888888888" !
                   CALL PyList(2)
                ENDIF
             ENDIF
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          ENDIF
          GOTO 999
        ENDIF
      ENDIF

C if not, we are in continuum
C if roots large enough, execute Jetset
      IF(ROOTS.GT.RSLIM.OR.RRes_PYFLAV(IQ1).NE.RRes_PYFLAV(IQ2)) THEN
        CALL RRes_PYFRAG(ROOTS,IQ1,IQ2)
C else use low-energy cross-sections
      ELSE
C       -> draw a final state
        CALL RRes_MULGEN(ROOTS,IQ,NP,KCODE,IDEBUG)
C       -> draw the particle momenta
        CALL RRes_MOMGEN(QQMOM,NP,KCODE,PIMOM)
C       -> fill PYJETS
        CALL RRes_PYCONT(IQ1,IQ2,QQMOM,NP,KCODE,PIMOM)
      ENDIF

C.........debug
      IF(IDEBUG.EQ.1) THEN
*        CALL PYLIST(1)
      ENDIF
C.........end debug

 999  RETURN
      END

      SUBROUTINE RRes_RhoDecay(Npos)
*/////////////////////////////////////////////////////////////////////////
*//
*//   Dedicated routine for rho deday. 
*//   It is assumed that we are in LAB system.
*//   Decay product appended in the PYTHIA common block!!!
*//   Npos is pointer of the rho resonance in the PYTHIA common-block
*//
*/////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'RRes.h'
      INTEGER Npos
*//----------------------------------------------------------------
      INTEGER             N, NPAD, K
      DOUBLE PRECISION    P, V
      COMMON /PYJETS/     N, NPAD, K(4000,5), P(4000,5), V(4000,5)
*//----------------------------------------------------------------
      INTEGER           i,j,ib1,ib2,irh
      DOUBLE PRECISION  pb1(4),pb2(4),pb(4),pr(4),ph(4)
      DOUBLE PRECISION  Mpair,Mpi,pi1(4),pi2(4),bbet,eta1,eta2
      DOUBLE PRECISION  cth,the,phi,cths,chi1,chi2
      REAL              rvec(10)
      INTEGER icont
      DATA    icont /0/
*----------------------------------
      icont=icont+1
      ib1=1
      ib2=2
      irh=Npos
      DO j=1,4
         pb1(j) = P(ib1,j)
         pb2(j) = P(ib2,j)
         pb(j)  = pb1(j)+pb2(j)
         pr(j)  = P(irh,j)
         ph(j)  = pb(j)-pr(j)
      ENDDO
      chi1=   ( ph(1)*pb1(1) +ph(2)*pb1(2) +ph(3)*pb1(3))
     $       /(pb2(1)*pb1(1)+pb2(2)*pb1(2)+pb2(3)*pb1(3))
      chi2=   (pb2(1)*ph(1) +pb2(2)*ph(2) +pb2(3)*ph(3))
     $       /(pb2(1)*pb1(1)+pb2(2)*pb1(2)+pb2(3)*pb1(3))
* Boost beams to rho frame (needed for Kleiss prescription)
      CALL KinLib_BostQ( 1,pr, pb1,pb1)
      CALL KinLib_BostQ( 1,pr, pb2,pb2)
* generate pion momenta in rho frame
 222  Mpi = xmpic
      Mpair= sqrt(pr(4)**2-pr(3)**2-pr(2)**2-pr(1)**2)
      CALL KinLib_givpair(Mpair,Mpi,Mpi,pi1,pi2,bbet,eta1,eta2) ! pions along z-axis
* Angles for Euler rotation
      CALL PseuMar_MakeVec(rvec,4)
      cth= 1.d0 -2.d0*rvec(1)
      the= acos(cth)
      phi= 2.d0*pi*rvec(2)
      CALL KinLib_Rotor(2,3,the,pi1,pi1) ! Rotation y-z
      CALL KinLib_Rotor(1,2,phi,pi1,pi1) ! Rotation x-y
      CALL KinLib_Rotor(2,3,the,pi2,pi2) ! Rotation y-z
      CALL KinLib_Rotor(1,2,phi,pi2,pi2) ! Rotation x-y
* Impose 1-cos(the)**2 distribution for pi+
      IF(rvec(3) .LT. chi1/(chi1+chi2)) THEN
         cths= (pi1(1)*pb1(1)+pi1(2)*pb1(2)+pi1(3)*pb1(3))
     $         /SQRT((pi1(1)**2+pi1(2)**2+pi1(3)**2)
     $              *(pb1(1)**2+pb1(2)**2+pb1(3)**2))
         IF( ABS(cths).GT.1d0) GOTO 900
         IF( (1-cths**2) .LT. rvec(4) ) GOTO 222
      ELSE
         cths=-(pi1(1)*pb2(1)+pi1(2)*pb2(2)+pi1(3)*pb2(3))
     $        /SQRT((pi1(1)**2+pi1(2)**2+pi1(3)**2)
     $             *(pb2(1)**2+pb2(2)**2+pb2(3)**2))
         IF( ABS(cths).GT.1d0) GOTO 900
         IF( (1-cths**2) .LT. rvec(4) ) GOTO 222
      ENDIF
* Boost pions to LAB system
      CALL KinLib_BostQ( -1,pr, pi1,pi1) ! Boost to CMS
      CALL KinLib_BostQ( -1,pr, pi2,pi2) ! Boost to CMS
* Change status of rho
      K(Npos,1) = 11             ! status decayed
* Writing pion+ into recors
      N = N + 1
      K(N,1) = 1                 ! status stable
      K(N,2) = 211               ! KF code pi+
      K(N,3) = Npos              ! parent
      K(N,4) = 0                 ! first daughter
      K(N,5) = 0                 ! last daughter
      DO I = 1, 4
        P(N,I) = pi1(I)
        V(N,I) = 0
      ENDDO
      P(N,5) = DSQRT(ABS( pi1(4)**2-pi1(1)**2-pi1(2)**2-pi1(3)**2 ))
* Change in rho
      K(Npos,4) = N              ! first daughter
* Writing pion- into recors
      N = N + 1
      K(N,1) = 1                 ! status stable
      K(N,2) = -211              ! KF code pi-
      K(N,3) = Npos              ! parent
      K(N,4) = 0                 ! first daughter
      K(N,5) = 0                 ! last daughter
      DO I = 1, 4
        P(N,I) = pi2(I)
        V(N,I) = 0
      ENDDO
      P(N,5) = DSQRT(ABS( pi2(4)**2-pi2(1)**2-pi2(2)**2-pi2(3)**2 ))
* Change in rho
      K(Npos,5) = N              ! second daughter
*-----------------------------------------------------------------------------
      IF(icont.LE.20) THEN
      WRITE(*,*) ' ###################### DEBUG DEBUG  DEBUG ############################ '
      WRITE(*,*) '                 Here we are! Rho generated  '
      WRITE(*,*) ' Npos= ', Npos, ' cths= ', cths
      WRITE(*,*) ' KFcode= ', K(Npos,2)
      CALL KinLib_VecPrint(6,'  pb1    ',pb1)
      CALL KinLib_VecPrint(6,'  pb2    ',pb2)
      CALL KinLib_VecPrint(6,'  pb     ',pb)
      CALL KinLib_VecPrint(6,'  pr     ',pr)
      CALL KinLib_VecPrint(6,'  ph     ',ph)
      CALL KinLib_VecPrint(6,'  pi1    ',pi1)
      CALL KinLib_VecPrint(6,'  pi2    ',pi2)
      CALL pylist(2)
      ENDIF
      RETURN
*     -----------------------------------
 900  WRITE(*,*) ' wrong cths =',cths
      STOP
      END

C----------------------------------------------------------------------
      SUBROUTINE RRes_RESGEN(ROOTS,IQ,IRES,IDEBUG)
C this routine looks if we are on a resonance, by comparing the
C corresponding BW amplitude to the total value of the R ratio.
C     -> inputs:    ROOTS   qq mass
C                      IQ   quark flavour
C     -> output:     IRES   0 = continuum
C                           1 = rho
C                           2 = omega
C                           3 = phi
C                           4 = J/Psi
C                           5 = Upsilon(1S)
      IMPLICIT NONE
      INCLUDE 'RRes.h'

c      DOUBLE PRECISION  X, BETA
C arguments
      DOUBLE PRECISION ROOTS
      INTEGER IQ, IRES, IDEBUG
C R ratio, pion form factor
      DOUBLE PRECISION RRes_F_PI_SQ, RRes_FPi_Phk_SQ
      DOUBLE PRECISION RRes_CorQQ, BETAr
      DOUBLE PRECISION R_Rho_OmegaInt, P_RhoOmega, R_Ome
      DOUBLE PRECISION BornV_GetMass
C resonance parameters
      DOUBLE PRECISION XMRES, XWTOT, XWEE, XMIQ
C vector for PseuMar ; other internals
      REAL   RVEC(5)
      DOUBLE PRECISION R, S, FAC, FPI
      DOUBLE PRECISION RPHI, RPSI, RUPS
C external functions
      DOUBLE PRECISION RRes_BETAPS, RRes_BRWIGN, RRes_CSMUMU, PYMASS

C initialise
      IRES = 0
      S = ROOTS**2.d0
      CALL PseuMar_MakeVec(RVEC,1)
      X = RVEC(1)

C total ratio
C threshold factors should be 1 here, so:
*      XMIQ = BornV_GetMass(IQ)
      XMIQ = 1d-6
      R = RRes_CorQQ(ROOTS,IQ,XMIQ)

C.........debug
      IF(IDEBUG.EQ.1) THEN
        PRINT*, ' '
        PRINT*, 'IN RRes_RESGEN   S = ', S
        PRINT*, '                 X = ', X
        PRINT*, '                IQ = ', IQ
        PRINT*, '           R ratio = ', R
      ENDIF
C.........end debug

C RESONATING CONTRIBUTIONS
C  -> pion form factor (rho+omega)
      IF(IQ.EQ.1.OR.IQ.EQ.2) THEN
        FAC = 3.d0/5.d0
***     FPI = RRes_F_PI_SQ(S)       ! Rho+OmegaInterf, 2pi channel only, see RRes_UD(s)
        FPI = RRes_FPi_Phk_SQ(s)    ! Rho+OmegaInterf, 2pi channel only, see RRes_UD(s)
        BETAr = RRes_BETAPS(roots,xmpic)
        R_Rho_OmegaInt = FAC*FPI*BETAr**3d0/4.d0
        R_Ome = FAC * RRes_BRWIGN(roots,xmome,xwome,omeee)/RRes_CSMUMU(roots) ! omega alone
        IF( ABS(roots-xmome) .GT. 100d0*xwome) R_Ome =0d0                     ! See RRes_UD
        P_RhoOmega = (R_Rho_OmegaInt+R_Ome)/R ! R includes resonaces and continuum
        IF(X .LT. P_RhoOmega) THEN
           X= X/P_RhoOmega
           IF(X .LT. R_Ome/(R_Rho_OmegaInt+R_Ome) ) THEN
              IRES = 2     ! omega
           ELSE
              IRES = 1     ! rho including Omega Interf.
           ENDIF
        ELSE
           GOTO 999 ! no resonance, continuum
        ENDIF
      ENDIF
C     -> omega
C      IF(IQ.EQ.1.OR.IQ.EQ.2) THEN
C        FAC = 3.d0/5.d0
C        ROME = FAC * RRes_BRWIGN(ROOTS,XMOME,XWOME,OMEEE)/RRes_CSMUMU(ROOTS)
C        IF(X.LE.(RRHO+ROME)/R) THEN
C          IRES = 2
C          GOTO 999
C        ENDIF
C      ENDIF
C     -> phi
      IF(IQ.EQ.3) THEN
        FAC = 3.d0
        RPHI = FAC * RRes_BRWIGN(ROOTS,XMPHI,XWPHI,PHIEE)/RRes_CSMUMU(ROOTS)
        IF(X.LE.RPHI/R) THEN
          IRES = 3
          GOTO 999
        ENDIF
      ENDIF
C     -> J/Psi
      IF(IQ.EQ.4) THEN
        FAC = 3.d0/4.d0
        RPSI = FAC * RRes_BRWIGN(ROOTS,XMPSI,XWPSI,PSIEE)/RRes_CSMUMU(ROOTS)
        IF(X.LE.RPSI/R.OR.ROOTS.LT.2d0*PYMASS(421)) THEN
          IRES = 4
          GOTO 999
        ENDIF
      ENDIF
C     -> Upsilon
      IF(IQ.EQ.5) THEN
        FAC = 3.d0
        RUPS = FAC * RRes_BRWIGN(ROOTS,XMUPS,XWUPS,UPSEE)/RRes_CSMUMU(ROOTS)
        IF(X.LE.RUPS/R.OR.ROOTS.LT.2d0*PYMASS(511)) THEN
          IRES = 5
          GOTO 999
        ENDIF
      ENDIF

C.........debug
 999  IF(IDEBUG.EQ.1) THEN
        PRINT*, 'IN RRes_RESGEN RRHO = ', R_Rho_OmegaInt
        PRINT*, '              R_Ome = ', R_Ome
        PRINT*, '               RPHI = ', RPHI
        PRINT*, '               RPSI = ', RPSI
        PRINT*, '               RUPS = ', RUPS
        PRINT*, '               IRES = ', IRES
      ENDIF

      RETURN
      END

C----------------------------------------------------------------------
      SUBROUTINE RRes_MULGEN(ROOTS,IQ,NP,KCODE,IDEBUG)
C this generates the final state multiplicity, from non-resonant 
C cross-sections.
C     -> input:     ROOTS   qq mass
C                      IQ   quark flavour
C     -> output:       NP   final state multiplicity
C                   KCODE   array of particle codes (Jetset)    
C

      IMPLICIT NONE
C arguments
      DOUBLE PRECISION ROOTS
      INTEGER IQ, NP, KCODE(*), IDEBUG
C internals
      INTEGER I, J, IMIN, IMAX, IPROC, NPROC
      PARAMETER ( NPROC = 10 )
      DOUBLE PRECISION XSEC(NPROC), XTOPO
      REAL   RVEC(5)
C external functions
      REAL*8 RRes_CSHADR

C initialise
      NP = 0
      DO I = 1, NPROC
        XSEC(I) = 0.d0
      ENDDO

C attribute processes with/without kaons to s/ud flavours
      IF(IQ.LE.2) THEN
        IMIN = 1
        IMAX = 6
      ELSEIF(IQ.EQ.3) THEN
        IMIN = 7
        IMAX = 10
      ENDIF

C exclusive cumulative cross-sections
      J = 1
      XSEC(J) = DBLE(RRes_CSHADR(ROOTS,IMIN))
      DO I = IMIN+1, IMAX
        J = J + 1
        XSEC(J) = DBLE(RRes_CSHADR(ROOTS,I)) + XSEC(J-1)
      ENDDO
      
C draw one topology
      CALL PseuMar_MakeVec(RVEC,1)
      XTOPO = RVEC(1) * XSEC(J)

C define final states
      IF(IQ.LE.2) THEN ! u, d quarks
        IF(XTOPO.LT.XSEC(1)) THEN      ! pi+ pi- pi0
          IPROC = 1
          NP = 3
          KCODE(1) =  211
          KCODE(2) = -211
          KCODE(3) =  111
        ELSEIF(XTOPO.LT.XSEC(2)) THEN  ! pi+ pi- pi+ pi-
          IPROC = 2
          NP = 4
          KCODE(1) =  211
          KCODE(2) = -211
          KCODE(3) =  211
          KCODE(4) = -211
        ELSEIF(XTOPO.LT.XSEC(3)) THEN  ! pi+ pi- pi0 pi0
          IPROC = 3
          NP = 4
          KCODE(1) =  211
          KCODE(2) = -211
          KCODE(3) =  111
          KCODE(4) =  111
        ELSEIF(XTOPO.LT.XSEC(4)) THEN  ! pi+ pi- pi+ pi- pi0
          IPROC = 4
          NP = 5
          KCODE(1) =  211
          KCODE(2) = -211
          KCODE(3) =  211
          KCODE(4) = -211
          KCODE(5) =  111
        ELSEIF(XTOPO.LT.XSEC(5)) THEN  ! pi+ pi- pi+ pi- pi+ pi-
          IPROC = 5
          NP = 6
          KCODE(1) =  211
          KCODE(2) = -211
          KCODE(3) =  211
          KCODE(4) = -211
          KCODE(5) =  211
          KCODE(6) = -211
        ELSEIF(XTOPO.LT.XSEC(6)) THEN  ! pi+ pi- pi+ pi- pi0 pi0
          IPROC = 6
          NP = 6
          KCODE(1) =  211
          KCODE(2) = -211
          KCODE(3) =  211
          KCODE(4) = -211
          KCODE(5) =  111
          KCODE(6) =  111
        ENDIF
      ELSEIF(IQ.EQ.3) THEN ! s quarks
        IF(XTOPO.LT.XSEC(1)) THEN  ! K+ K-
          IPROC = 7
          NP = 2
          KCODE(1) =  321
          KCODE(2) = -321
        ELSEIF(XTOPO.LT.XSEC(2)) THEN  ! K0S K0L
          IPROC = 8
          NP = 2
          KCODE(1) =  130
          KCODE(2) =  310
        ELSEIF(XTOPO.LT.XSEC(3)) THEN  ! pi+ K0 K-  or  pi- K0 K+
          IPROC = 9
          NP = 3
          CALL PseuMar_MakeVec(RVEC,1)
          IF(RVEC(1).LT.0.5d0) THEN
            KCODE(1) =  211
            KCODE(2) = -321
          ELSE
            KCODE(1) = -211
            KCODE(2) =  321
          ENDIF
          CALL PseuMar_MakeVec(RVEC,1)
          IF(RVEC(1).LT.0.5d0) THEN
            KCODE(3) =  310
          ELSE
            KCODE(3) =  130
          ENDIF
        ELSEIF(XTOPO.LT.XSEC(4)) THEN  ! pi+ pi- K+ K-
          IPROC = 10
          NP = 4
          KCODE(1) =  211
          KCODE(2) = -211
          KCODE(3) =  321
          KCODE(4) = -321
        ENDIF                                                           
      ENDIF

C.........debug
      IF(IDEBUG.EQ.1) THEN
        PRINT*, 'IN RRes_MULGEN   XTOPO = ', XTOPO
        PRINT*, '                 IPROC = ', IPROC
        PRINT*, '                     K = ', (KCODE(I),I=1,NP)
        PRINT*, '                    NP = ', NP
      ENDIF
C.........end debug

      RETURN
      END

C----------------------------------------------------------------------
      SUBROUTINE RRes_MOMGEN(QQMOM,NPAR,KCODE,PIMOM)
C this generates 4-momenta of the particles, and boosts to the lab frame.
C Called by RRes_HADGEN
C     -> inputs:    QQMOM   lab-frame 4-vector of the qq system
C                    NPAR   final state multiplicity
C                   KCODE   array of particle codes (Jetset)
C     -> output:    PIMOM   2-dim vector (N x 4-vectors)

      IMPLICIT NONE
C GENBOD commons : DOUBLE PRECISION
      INTEGER NP, KGENEV
      DOUBLE PRECISION TECM, AMASS, PCM, WT
      COMMON / GENIN / AMASS(18), TECM, KGENEV, NP
      COMMON / GENOUT / PCM(5,18), WT
C arguments : DOUBLE PRECISION
      DOUBLE PRECISION QQMOM(*), PIMOM(4,*)
      INTEGER NPAR, KCODE(*)
C internals
      INTEGER I, J, KF
      DOUBLE PRECISION XMOM(4), YMOM(4), ZMOM(4)
C external functions
      DOUBLE PRECISION PYMASS

C fill GENBOD variables
      NP = NPAR
      TECM = DSQRT( QQMOM(4)**2d0-QQMOM(1)**2d0
     &             -QQMOM(2)**2d0-QQMOM(3)**2d0 )
      DO I = 1, 18
        AMASS(I) = 0d0
        IF(I.LE.NPAR) THEN
          KF = ABS(KCODE(I))
          AMASS(I) = PYMASS(KF)
        ENDIF
      ENDDO
      KGENEV = 1

C generate
      CALL RRes_GENBOD

C boost back (XMOM -> qq_lab, YMOM -> pion_qq, ZMOM -> pion_lab)
      DO I = 1, 4
        XMOM(I) = QQMOM(I)
      ENDDO
      DO I = 1, NP
        DO J = 1, 4
          YMOM(J) = PCM(J,I)
        ENDDO
        CALL RRes_LORENB(TECM,XMOM,YMOM,ZMOM)
        DO J = 1, 4
          PIMOM(J,I) = ZMOM(J)
        ENDDO
      ENDDO

      RETURN
      END

C----------------------------------------------------------------------
      INTEGER FUNCTION RRes_PYFLAV(INDEX)
C determines the flavour of the quark system
C     -> input :       INDEX   position of the particle
C     -> output :     LUFLAV   flavour:
C                              = 1,2,3,4,5 for d,u,s,c,b
      IMPLICIT NONE
      INTEGER N, NPAD, K
      DOUBLE PRECISION P, V
      COMMON /PYJETS/ N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      INTEGER INDEX

      RRes_PYFLAV = ABS(K(INDEX,2))

 999  RETURN
      END

C----------------------------------------------------------------------
      SUBROUTINE RRes_PYRESO(IQ1,IQ2,QQMOM,IRES,IDEBUG, Npos)   ! <--###-
C this routine fills PYJETS in the resonance case.
C Called by RRes_HADGEN
C     -> inputs :     IQ1   position of first quark of the pair
C                      QQMOM   quark pair 4-momentum
C                       IRES   resonance type
C
      IMPLICIT NONE
C arguments
      INTEGER IQ1, IQ2, IRES, Npos, IDEBUG   ! <--###-
      INTEGER N, NPAD, K
      DOUBLE PRECISION P, V
      COMMON /PYJETS/ N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      DOUBLE PRECISION QQMOM(*)
C resonances codes (rho, omega, phi, J/Psi, Upsilon)
      INTEGER ICODE(5)
      DATA ICODE  / 113,  223,  333,  443,    553   /
C internals
      INTEGER I

C the parents
      K(IQ1,1) = 12
      K(IQ2,1) = 11
      K(IQ1,4) = N + 1
      K(IQ2,4) = N + 1
      K(IQ1,5) = N + 1
      K(IQ2,5) = N + 1

C the "cluster"
      N = N + 1
      K(N,1) = 11
      K(N,2) = 91                  ! "cluster"
      K(N,3) = IQ1                 ! parent
      K(N,4) = N+1                 ! first daughter
      K(N,5) = N+1                 ! last daughter
      DO I = 1, 4
        P(N,I) = QQMOM(I)
      ENDDO
      P(N,5) = QQMOM(4)**2d0-QQMOM(1)**2d0-QQMOM(2)**2d0-QQMOM(3)**2d0
      P(N,5) = DSQRT(P(N,5))
C the resonance
      N = N + 1
      Npos = N   ! Resonance pointer <--###-
      K(N,1) = 1                 ! status
      K(N,2) = ICODE(IRES)       ! KF code
      K(N,3) = N-1               ! parent
      K(N,4) = 0                 ! first daughter
      K(N,5) = 0                 ! last daughter
      DO I = 1, 4
        P(N,I) = QQMOM(I)
      ENDDO
      P(N,5) = QQMOM(4)**2d0-QQMOM(1)**2d0-QQMOM(2)**2d0-QQMOM(3)**2d0
      P(N,5) = DSQRT(P(N,5))

C.........debug
        IF(IDEBUG.EQ.1) THEN
          PRINT*, 'IN LURESO IRES = ', IRES
*          CALL PYLIST(1)
        ENDIF
C.........end debug

 999  RETURN
      END

C----------------------------------------------------------------------
      SUBROUTINE RRes_PYFRAG(ROOTS,IQ1,IQ2)
C this routine does standard fragmentation
C     -> inputs :     ROOTS     center of mass energy
C                     IQ1,IQ2   positions in LUND of the quarks
C
      IMPLICIT NONE
C arguments
      DOUBLE PRECISION ROOTS
      INTEGER IQ1, IQ2
C internals
      INTEGER IJOIN(2), NJOIN

      IJOIN(1) = IQ1                                              
      IJOIN(2) = IQ2                                              
      NJOIN = 2                                                             
      CALL PYJOIN(NJOIN,IJOIN)                                              
      CALL PYSHOW(IJOIN(1),IJOIN(2),ROOTS)                                  
      
      RETURN
      END

C----------------------------------------------------------------------
      SUBROUTINE RRes_PYCONT(IQ1,IQ2,QQMOM,NP,KCODE,PIMOM)
C this routine fills PYJETS in the continuum case.
C Called by RRes_HADGEN
C     -> inputs :     IQ1   position of first quark of the pair
C                     QQMOM    quark pair 4-momentum
C                        NP    final state multiplicity
C                     KCODE    array of particle codes (Jetset)
C                     PIMOM    pion 4-momenta
C
      IMPLICIT NONE
      INTEGER N, NPAD, K
      DOUBLE PRECISION P, V
      COMMON /PYJETS/ N,NPAD,K(4000,5),P(4000,5),V(4000,5)
C arguments
      DOUBLE PRECISION QQMOM(*),PIMOM(4,*)
      INTEGER IQ1, IQ2, NP, KCODE(*)
C internals
      INTEGER I, J, IFREE
C external functions
      DOUBLE PRECISION PYMASS

C first free slot ; this assumes the partons are already in PYJETS,
C so that namely N is known here
      IFREE = N + 1

C the parents
      K(IQ1,1) = 12
      K(IQ2,1) = 11
      K(IQ1,4) = N + 1
      K(IQ2,4) = N + 1
      K(IQ1,5) = N + 1
      K(IQ2,5) = N + 1

C the "cluster"
      N = N + 1
      K(IFREE,1) = 11
      K(IFREE,2) = 91                  ! "cluster"
      K(IFREE,3) = IQ1                 ! parent
      K(IFREE,4) = IFREE+1             ! first daughter
      K(IFREE,5) = IFREE+NP            ! last daughter
      DO I = 1, 4
        P(IFREE,I) = QQMOM(I)
      ENDDO
      P(IFREE,5)=QQMOM(4)**2d0-QQMOM(1)**2d0-QQMOM(2)**2d0-QQMOM(3)**2d0
      P(IFREE,5)=DSQRT(P(IFREE,5))

C final state
      DO I = 1, NP
        N = N + 1
        K(IFREE+I,1) = 1
        K(IFREE+I,2) = KCODE(I)
        K(IFREE+I,3) = IFREE
        K(IFREE+I,4) = 0
        K(IFREE+I,5) = 0
        DO J = 1, 4
          P(IFREE+I,J) = PIMOM(J,I)
        ENDDO
        P(IFREE+I,5) = PYMASS(KCODE(I))
      ENDDO
      
      RETURN
      END

C----------------------------------------------------------------------
      DOUBLE PRECISION FUNCTION RRes_CSHADR(ROOTS,IPROC)
C this gives the cross-section for an n-pion final state.
C     -> inputs:    ROOTS   qq mass
C                   IPROC   final state label:
C                            1 - pi+ pi- pi0
C                            2 - pi+ pi- pi+ pi-
C                            3 - pi+ pi- pi0 pi0
C                            4 - pi+ pi- pi+ pi- pi0
C                            5 - pi+ pi- pi+ pi- pi+ pi-
C                            6 - pi+ pi- pi+ pi- pi0 pi0
C                            7 - K+ K-
C                            8 - Ks Kl
C                            9 - Ks K+/- pi-/+
C                           10 - K+ K- pi+ pi-
C     -> output:   CSHADR   cross-section (in nb)
C

C arguments
      DOUBLE PRECISION ROOTS
      INTEGER IPROC
C number of final states included so far
      PARAMETER ( NPROC = 10 )
C particle masses and thresholds
      PARAMETER ( XMPIC = 0.13957 )
      PARAMETER ( XMPIN = 0.13498 )
      PARAMETER ( XMKAC = 0.49368 )
      PARAMETER ( XMKAN = 0.49767 )
      PARAMETER ( THR1  = (2*XMPIC + XMPIN)**2 )
      PARAMETER ( THR2  = (2*XMPIC + 2*XMPIN)**2 )
      PARAMETER ( THR4  = (4*XMPIC + XMPIN)**2 )
      PARAMETER ( THR5  = (6*XMPIC)**2 )
      PARAMETER ( THR6  = (4*XMPIC + 2*XMPIN)**2 )
      PARAMETER ( THR7  = (2*XMKAC)**2 )
      PARAMETER ( THR8  = (2*XMKAN)**2 )
      PARAMETER ( THR9  = (XMKAN + XMKAC + XMPIC)**2 )
      PARAMETER ( THR10 = (2*XMPIC + 2*XMKAC)**2 )
C 3 pions
C     -> c.o.m energy squared
      PARAMETER ( N3PI = 35 )
      REAL S3PI(N3PI)
      DATA S3PI / THR1,
     &            0.44, 0.45, 0.46, 0.48, 0.49, 0.51, 
!     &      0.53, 0.54, 0.56,
!     &      0.57, 0.59, 0.65, 0.66, 0.68, 0.69, 0.71, 0.72, 0.74,
!     &      0.76, 0.78, 0.79, 0.81, 0.83, 0.85, 0.89, 0.91, 0.93,
!     &      0.95, 0.97, 0.99, 1.01, 1.07, 
     &            1.12, 1.21, 1.30, 1.39,
     &            1.49, 1.59, 1.69, 1.79, 1.90, ! ND PhysRep 202(91)99
     &            1.95, 2.03, 2.18, 2.33, 2.48, 2.64, 2.81, 2.98, 3.15,
     &            3.33, 3.52, 3.71, 3.90, 4.10, 4.31, 4.52, 4.73, 4.95,
     &            5.76 / ! DM2 ZeitPhys C56(92)15
C     -> cross-section
      REAL CS3PI(N3PI)
      DATA CS3PI / 00.0,
     &             00.0, 00.0, 01.5, 01.4, 01.6, 01.1, 
!     &      04.3, 06.7, 14.1,
!     &      23.4, 63.9, 74.9, 41.7, 28.2, 24.8, 18.9, 13.5, 09.8,
!     &      12.0, 11.9, 08.8, 06.6, 09.2, 11.6, 04.2, 08.1, 07.7,
!     &      11.3, 10.1, 13.8, 25.6, 05.0, 
     &             01.4, 03.2, 02.2, 02.3,
     &             03.4, 02.2, 03.3, 04.3, 03.8, ! ND PhysRep 202(91)99
     &             03.4, 01.6, 02.2, 01.3, 01.9, 02.2, 01.3, 00.6, 00.7,
     &             00.4, 00.5, 00.4, 00.5, 00.2, 00.3, 00.3, 00.2, 00.0,
     &             00.2 / ! DM2 ZeitPhys C56(92)15

C 4 pions ---> more precise numbers should come soon
C     -> c.o.m energy squared
      PARAMETER ( N4PI = 16 )
      REAL S4PI(N4PI)
      DATA S4PI / THR2,
     &            0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0,
     &            2.2, 2.4, 2.6, 2.8, 3.0, 3.2, 3.4, 4.0 /
C     -> pi+ pi- pi+ pi- ! A. Hoecker (thesis), read from figure...
      REAL CS4C0N(N4PI)
      DATA CS4C0N / 0.0, 
     &              0.5, 1.5, 3.5, 7.5, 14., 21., 28.,
     &              31., 30., 25., 19., 16., 12., 7.0, 4.0 /
C     -> pi+ pi- pi0 pi0 ! A. Hoecker (thesis), read from figure...
      REAL CS2C2N(N4PI)
      DATA CS2C2N / 0.0,
     &              0.0, 7.0, 11., 20., 25., 27., 27.,
     &              29., 27., 23., 27., 22., 15., 13., 10. /

C 5 pions
C - 2pi+ 2pi- pi0 ! ND PhysRep 202(91)99 , Adone NuclPhys B31(81)445
      PARAMETER ( N5PI41 = 13 ) ! + 1 pt extrapolated to roots = 2 GeV
C     -> c.o.m energy squared
      REAL S5PI41(N5PI41)
      DATA S5PI41 / THR4,
     &              1.19, 1.46, 1.61, 1.82, 
     &              2.14, 2.26, 2.49, 2.73, 2.88, 3.06, 3.20, 
     &              4.00 /
C     -> cross-section
      REAL C5PI41(N5PI41)
      DATA C5PI41 / 00.0,
     &              00.0, 00.3, 00.6, 01.0, 
     &              02.0, 04.0, 04.0, 04.0, 04.0, 04.0, 03.9, 
     &              03.3 /

C 6 pions
C - 3pi+ 3pi- ! DM1 PhysLett B107(81)145
      PARAMETER ( N6PI60 = 9 )
C     -> c.o.m energy squared
      REAL S6PI60(N6PI60)
      DATA S6PI60 / THR5,
     &              2.10, 2.40, 2.72, 3.06, 3.42, 3.80, 4.12, 4.60 /
C     -> cross-section
      REAL C6PI60(N6PI60)
      DATA C6PI60 / 0.00,
     &              0.00, 0.00, 0.52, 1.40, 1.16, 1.28, 1.88, 2.33 /
C - 2pi+ 2pi- 2pi0 ! Adone NuclPhys B31(81)445
      PARAMETER ( N6PI42 = 9 ) ! + 1 pt extrapolated to roots = 2 GeV
C     -> c.o.m energy squared
      REAL S6PI42(N6PI42)
      DATA S6PI42 / THR6,
     &              2.14, 2.26, 2.49, 2.73, 2.88, 3.06, 3.20,
     &              4.00 /
C     -> cross-section
      REAL C6PI42(N6PI42)
      DATA C6PI42 / 00.0,
     &              04.1, 09.0, 09.0, 08.0, 10.0, 10.0, 06.9,
     &              03.1 /

C 2 kaons
C - K+ K- ! OLYA PhysLett B107(81)297 , DM2 ZeitPhys C39(88)13
      PARAMETER ( N2KC = 31 )
C     -> c.o.m energy squared
      REAL S2KC(N2KC)
      DATA S2KC / THR7,
     &            1.28, 1.32, 1.37, 1.42, 1.46, 1.51, 1.56, 1.61, 1.66, 
     &            1.72, 1.77, 
     &            1.82, 1.96, 2.09, 2.25, 2.43, 2.53, 2.59, 2.66, 2.72, 
     &            2.79, 2.94, 3.08, 3.26, 3.42, 3.59, 3.74, 3.84, 3.96, 
     &            4.10 /
C     -> cross-section
      REAL C2KC(N2KC)
      DATA C2KC / 0.00,
     &            9.95, 8.56, 7.98, 8.14, 5.16, 6.39, 5.94, 6.94, 5.77, 
     &            6.58, 5.80, 
     &            4.36, 4.01, 3.14, 2.27, 2.16, 2.23, 2.18, 1.87, 1.64, 
     &            1.02, 0.81, 0.64, 0.10, 0.16, 0.17, 0.23, 0.20, 0.15, 
     &            0.20 /
C - Ks Kl ! DM1 PhysLett B99(81)261
      PARAMETER ( N2K0 = 11 )
C     -> c.o.m energy squared
      REAL S2K0(N2K0)
      DATA S2K0 / THR8,
     &            2.08, 2.33, 2.48, 2.60, 2.68, 2.81, 3.06, 3.53, 4.03, 
     &            4.58 /
C     -> cross-section
      REAL C2K0(N2K0)
      DATA C2K0 / 0.00,
     &            0.24, 0.38, 0.61, 0.70, 0.74, 0.32, 0.18, 0.01, 0.19, 
     &            0.07 /

C 2 kaons + 1 pion
C - Ks K+ pi- + Ks K- pi+ ! DM1 PhysLett B112(82)178
      PARAMETER ( N2K1PI = 16 )
C     -> c.o.m energy squared
      REAL S2K1PI(N2K1PI)
      DATA S2K1PI / THR9,
     &              2.08, 2.33, 2.48, 2.60, 2.66, 2.70, 2.76, 2.85, 
     &              2.98, 3.15, 3.31, 3.54, 3.85, 4.12, 4.58 /
C     -> cross-section
      REAL C2K1PI(N2K1PI)
      DATA C2K1PI / 0.00,
     &              1.27, 2.21, 3.61, 3.86, 4.77, 4.19, 4.69, 5.87, 
     &              1.34, 1.81, 1.97, 1.08, 0.40, 1.01, 0.76 /

C 2 kaons + 2 pions
C - K+ K- pi+ pi- ! DM1 PhysLett B110(82)335
      PARAMETER ( N2K2PI = 11 )
C     -> c.o.m energy squared
      REAL S2K2PI(N2K2PI)
      DATA S2K2PI / THR10,
     &              2.40, 2.64, 2.81, 2.98, 3.15, 3.33, 3.52, 3.80, 
     &              4.12, 4.58 /
C     -> cross-section
      REAL C2K2PI(N2K2PI)
      DATA C2K2PI / 0.00,
     &              0.00, 0.99, 1.73, 2.80, 3.31, 4.48, 5.92, 4.86, 
     &              5.33, 4.16 /
 
C initalize
      S = SNGL(ROOTS)**2.
      RRes_CSHADR = 0.

C which process ?
      IF(IPROC.LT.1.OR.IPROC.GT.NPROC) GOTO 999
      GOTO (111,112,113,114,115,116,117,118,119,120) IPROC

C pi+ pi- pi0
 111  DO I = 1, N3PI-1
        IF(S3PI(I).LT.S.AND.S3PI(I+1).GE.S) THEN
          SRAT = ( S - S3PI(I) ) / ( S3PI(I+1) - S3PI(I) )
          RRes_CSHADR = SRAT*( CS3PI(I+1) - CS3PI(I) ) + CS3PI(I)
        ENDIF
      ENDDO
      GOTO 999

C pi+ pi- pi+ pi-
 112  DO I = 1, N4PI-1
        IF(S4PI(I).LT.S.AND.S4PI(I+1).GE.S) THEN
          SRAT = ( S - S4PI(I) ) / ( S4PI(I+1) - S4PI(I) )
          RRes_CSHADR = SRAT*( CS4C0N(I+1) - CS4C0N(I) ) + CS4C0N(I)
        ENDIF
      ENDDO
      GOTO 999

C pi+ pi- pi0 pi0
 113  DO I = 1, N4PI-1
        IF(S4PI(I).LT.S.AND.S4PI(I+1).GE.S) THEN
          SRAT = ( S - S4PI(I) ) / ( S4PI(I+1) - S4PI(I) )
          RRes_CSHADR = SRAT*( CS2C2N(I+1) - CS2C2N(I) ) + CS2C2N(I)
        ENDIF
      ENDDO
      GOTO 999

C pi+ pi- pi+ pi- pi0
 114  DO I = 1, N5PI41-1
        IF(S5PI41(I).LT.S.AND.S5PI41(I+1).GE.S) THEN
          SRAT = ( S - S5PI41(I) ) / ( S5PI41(I+1) - S5PI41(I) )
          RRes_CSHADR = SRAT*( C5PI41(I+1) - C5PI41(I) ) + C5PI41(I)
        ENDIF
      ENDDO
      GOTO 999

C pi+ pi- pi+ pi- pi+ pi-
 115  DO I = 1, N6PI60-1
        IF(S6PI60(I).LT.S.AND.S6PI60(I+1).GE.S) THEN
          SRAT = ( S - S6PI60(I) ) / ( S6PI60(I+1) - S6PI60(I) )
          RRes_CSHADR = SRAT*( C6PI60(I+1) - C6PI60(I) ) + C6PI60(I)
        ENDIF
      ENDDO
      GOTO 999

C pi+ pi- pi+ pi- pi0 pi0
 116  DO I = 1, N6PI42-1
        IF(S6PI42(I).LT.S.AND.S6PI42(I+1).GE.S) THEN
          SRAT = ( S - S6PI42(I) ) / ( S6PI42(I+1) - S6PI42(I) )
          RRes_CSHADR = SRAT*( C6PI42(I+1) - C6PI42(I) ) + C6PI42(I)
        ENDIF
      ENDDO
      GOTO 999

C K+ K-
 117  DO I = 1, N2KC-1
        IF(S2KC(I).LT.S.AND.S2KC(I+1).GE.S) THEN
          SRAT = ( S - S2KC(I) ) / ( S2KC(I+1) - S2KC(I) )
          RRes_CSHADR = SRAT*( C2KC(I+1) - C2KC(I) ) + C2KC(I)
        ENDIF
      ENDDO
      GOTO 999

C Ks Kl
 118  DO I = 1, N2K0-1
        IF(S2K0(I).LT.S.AND.S2K0(I+1).GE.S) THEN
          SRAT = ( S - S2K0(I) ) / ( S2K0(I+1) - S2K0(I) )
          RRes_CSHADR = SRAT*( C2K0(I+1) - C2K0(I) ) + C2K0(I)
        ENDIF
      ENDDO
      GOTO 999

C K0S K+- pi-+ +CC ; add a factor 2 to include K0L
 119  DO I = 1, N2K1PI-1
        IF(S2K1PI(I).LT.S.AND.S2K1PI(I+1).GE.S) THEN
          SRAT = ( S - S2K1PI(I) ) / ( S2K1PI(I+1) - S2K1PI(I) )
          RRes_CSHADR = 2.*( SRAT*( C2K1PI(I+1) - C2K1PI(I) ) + C2K1PI(I) )
        ENDIF
      ENDDO
      GOTO 999

C K+ K- pi+ pi-
 120  DO I = 1, N2K2PI-1
        IF(S2K2PI(I).LT.S.AND.S2K2PI(I+1).GE.S) THEN
          SRAT = ( S - S2K2PI(I) ) / ( S2K2PI(I+1) - S2K2PI(I) )
          RRes_CSHADR = SRAT*( C2K2PI(I+1) - C2K2PI(I) ) + C2K2PI(I)
        ENDIF
      ENDDO
      GOTO 999

 999  RETURN
      END

C----------------------------------------------------------------------
      DOUBLE PRECISION FUNCTION RRes_BETAPS(ROOTS,XM)
C kinematic suppression factor
C     -> inputs:    ROOTS c.o.m energy
C                      XM particle mass
C
      IMPLICIT NONE
C arguments
      DOUBLE PRECISION ROOTS, XM

      RRes_BETAPS = SQRT(1.d0 - 4.d0*XM**2d0/ROOTS**2d0)

      RETURN
      END

C----------------------------------------------------------------------
      DOUBLE PRECISION FUNCTION RRes_BRWIGN(ROOTS,XMASS,XWTOT,XWEE)
C resonating cross-section, in nb
C     -> inputs:    ROOTS c.o.m energy
C                   XMASS resonance mass
C                   XWTOT     "     width
C                   XWEE      "     width in electrons
C

      IMPLICIT NONE
C constants
      DOUBLE PRECISION H2C2, PI
      PARAMETER ( H2C2 = 389379.66D0 ) ! GeV**2 nb
      PARAMETER ( PI = 3.1415926353D0 )
C arguments
      DOUBLE PRECISION ROOTS, XMASS, XWTOT, XWEE
C internals
      DOUBLE PRECISION S, XNUM, XDEN

C if we are far from the pole, set to 0
      IF(DABS(ROOTS-XMASS).GT.100.d0*XWTOT) THEN
        RRes_BRWIGN = 0.D0
        GOTO 999
      ENDIF

C cross-section
      S = ROOTS**2.D0
      XNUM = XWTOT * XWEE
      XDEN = (ROOTS - XMASS)**2d0 + (XWTOT/2d0)**2d0
      RRes_BRWIGN = 3d0*PI/S * XNUM / XDEN * H2C2
      
 999  RETURN
      END

C----------------------------------------------------------------------
      DOUBLE PRECISION FUNCTION RRes_CSMUMU(ROOTS)
C ee -> mumu cross-section, in nb

      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C constants
      DOUBLE PRECISION H2C2, PI, QED
      PARAMETER ( H2C2 = 389379.66D0 ) ! GeV**2 nb
      PARAMETER ( PI = 3.1415926353d0 )
      PARAMETER ( QED = 1.d0/137.d0 )                                            
C arguments
      DOUBLE PRECISION ROOTS
C internals
      DOUBLE PRECISION S

C cross-section
      S = ROOTS**2d0
      RRes_CSMUMU = 4.d0*PI*QED**2d0 / (3d0*S) * H2C2

      RETURN
      END
      

************************************************************************
* 
* This file contains some routines copied from CERNLIB,
* and moved to DOUBLE PRECISION
*
* Maarten Boonekamp, sept. 2001
************************************************************************



C (M.B.) taken from CERNLIB/PHTOOLS
C        some cleaning done (zero all non-equivalenced vectors, realign commons)
C        Double precision used, Pseumar random generator used
      SUBROUTINE RRes_GENBOD
C   SUBROUTINE TO GENERATE N-BODY EVENT
C   ACCORDING TO FERMI LORENTZ-INVARIANT PHASE SPACE
C   ADAPTED FROM FOWL (CERN W505) SEPT. 1974 BY F. JAMES
C   EVENTS ARE GENERATED IN THEIR OWN CENTER-OF-MASS,
C   BUT MAY BE TRANSFORMED TO ANY FRAME USING LOREN4
C
C   INPUT TO SUBROUTINE IS THRU COMMON BLOCK GENIN
C             NP=NUMBER OF OUTGOING PARTICLES (.LT. 19)
C             TECM=TOTAL ENERGY IN CENTER-OF-MASS
C             AMASS(I)=MASS OF ITH OUTGOING PARTICLE
C             KGENEV=1 FOR CONSTANT CROSS SECTION
C                      2 FOR FERMI ENERGY-DEPENDANCE
C
C   OUTPUT FROM SUBROUTINE IS THRU COMMON BLOCK GENOUT
C             PCM(1,I)=X-MOMENTUM IF ITH PARTICLE
C             PCM(2,I)=Y-MOMENTUM IF ITH PARTICLE
C             PCM(3,I)=Z-MOMENTUM IF ITH PARTICLE
C             PCM(4,I)=ENERGY OF ITH PARTICLE
C             PCM(5,I)=MOMENTUM OF ITH PARTICLE
C             WT=WEIGHT OF EVENT
      IMPLICIT DOUBLE PRECISION(a-h,o-z)
      COMMON/GENIN / AMASS(18), TECM, KGENEV, NP
      COMMON/GENOUT/ PCM(5,18) , WT
      DIMENSION EMM(18)
      DIMENSION RNO(50)
C--       PCM1 IS LINEAR EQUIV. OF PCM TO AVOID DOUBLE INDICES
      DIMENSION EM(18),PD(18),EMS(18),SM(18),FFQ(18),PCM1(90)
      EQUIVALENCE (NT,NP),(AMASS(1),EM(1)),(PCM1(1),PCM(1,1))
C FFQ(N)=PI * (TWOPI)**(N-2) / (N-2)FACTORIAL
      DATA FFQ/0.,3.141592, 19.73921, 62.01255, 129.8788, 204.0131,
     2                       256.3704, 268.4705, 240.9780, 189.2637,
     3                       132.1308,  83.0202,  47.4210,  24.8295,
     4                        12.0006,   5.3858,   2.2560,   0.8859/
      DATA KNT,TWOPI/0,6.2831853073/
      DATA KGENEV/ 2 /
C (M.B.) array for PseuMar
      REAL*4 RVEC(50)
C end (M.B.)
C (M.B.) zero all vectors
      DO I = 1, 50
         RVEC(I) = 0.
         RNO(I)  = 0d0
         IF(I.LE.18) THEN
            EMM(I) = 0d0
            PD(I)  = 0d0
            EMS(I) = 0d0
            SM(I)  = 0d0
         ENDIF
      ENDDO
C end (M.B.)
C        INITIALIZATION
      KNT=KNT + 1
      IF(KNT.GT.1) GOTO 100
      WRITE(6,1160)
      WRITE(6,1200) NP,TECM,(AMASS(JK),JK=1,NP)
  100 CONTINUE
      IF(NT.LT.2) GOTO 1001
      IF(NT.GT.18) GOTO 1002
      NTM1=NT-1
      NTM2=NT-2
      NTP1=NT+1
      NTNM4=3*NT - 4
      EMM(1)=EM(1)
      TM=0.0d0
      DO 200 I=1,NT
      EMS(I)=EM(I)**2
      TM=TM+EM(I)
 200  SM(I)=TM
C        CONSTANTS DEPENDING ON TECM
      TECMTM=TECM-TM
      IF(TECMTM.LE.0.0d0) GOTO 1000
      EMM(NT)=TECM
      IF(KGENEV.GT.1) GOTO 400
C        CONSTANT CROSS SECTION AS FUNCTION OF TECM
      EMMAX=TECMTM+EM(1)
      EMMIN=0.0d0
      WTMAX=1.0d0
      DO 350 I=2,NT
      EMMIN=EMMIN+EM(I-1)
      EMMAX=EMMAX+EM(I)
  350 WTMAX=WTMAX*RRes_PDK(EMMAX,EMMIN,EM(I))
      WTMAXQ=1.0d0/WTMAX
      GOTO 455
C--      FERMI ENERGY DEPENDENCE FOR CROSS SECTION
  400 WTMAXQ=TECMTM**NTM2*FFQ(NT) / TECM
C        CALCULATION OF WT BASED ON EFFECTIVE MASSES EMM
  455 CONTINUE
C--               FILL RNO WITH 3*NT-4 RANDOM NUMBERS,
C--            OF WHICH THE FIRST NT-2 ARE ORDERED.
C (M.B.) RNDM replaced by a call to PseuMar
      CALL PseuMar_MakeVec(RVEC,NTNM4)
      DO 457 I= 1, NTNM4
 457  RNO(I) = RVEC(I)
*  457 RNO(I)=RNDM(I)
C end(M.B.)
      IF(NTM2) 900,509,460
  460 CONTINUE
      CALL RRes_FLPSOR(RNO,NTM2)
      DO 508 J=2,NTM1
  508 EMM(J)=RNO(J-1)*(TECMTM)+SM(J)
  509 WT=WTMAXQ
      IR=NTM2
      DO 530 I=1,NTM1
      PD(I)=RRes_PDK(EMM(I+1),EMM(I),EM(I+1))
  530 WT=WT*PD(I)
C--       COMPLETE SPECIFICATION OF EVENT (RAUBOLD-LYNCH METHOD)
      PCM(1,1)=0.0d0
      PCM(2,1)=PD(1)
      PCM(3,1)=0.0d0
      DO 570 I=2,NT
      PCM(1,I)=0.0d0
      PCM(2,I)=-PD(I-1)
      PCM(3,I)=0.0d0
      IR=IR+1
      BANG=TWOPI*RNO(IR)
      CB=COS(BANG)
      SB=SIN(BANG)
      IR=IR+1
      C=2.0d0*RNO(IR)-1.0d0
      S=SQRT(1.0d0-C*C)
      IF(I.EQ.NT) GOTO 1567
      ESYS=SQRT(PD(I)**2+EMM(I)**2)
      BETA=PD(I)/ESYS
      GAMA=ESYS/EMM(I)
      DO 568 J=1,I
      NDX=5*J - 5
      AA= PCM1(NDX+1)**2 + PCM1(NDX+2)**2 + PCM1(NDX+3)**2
      PCM1(NDX+5)=SQRT(AA)
      PCM1(NDX+4)=SQRT(AA+EMS(J))
      CALL RRes_ROTES2(C,S,CB,SB,PCM,J)
      PSAVE=GAMA*(PCM(2,J)+BETA*PCM(4,J))
  568 PCM(2,J)=PSAVE
      GOTO 570
 1567 DO 1568 J=1,I
      AA=PCM(1,J)**2 + PCM(2,J)**2 + PCM(3,J)**2
      PCM(5,J)=SQRT(AA)
      PCM(4,J)=SQRT(AA+EMS(J))
      CALL RRes_ROTES2(C,S,CB,SB,PCM,J)
 1568 CONTINUE
  570 CONTINUE
  900 CONTINUE
      RETURN
C          ERROR RETURNS
 1000 WRITE(6,1100)
      GOTO 1050
 1001 WRITE(6,1101)
      GOTO 1050
 1002 WRITE(6,1102)
 1050 WRITE(6,1150) KNT
      WRITE(6,1200) NP,TECM,(AMASS(JK),JK=1,NP)
      STOP
 1100 FORMAT(28H0 AVAILABLE ENERGY NEGATIVE )
 1101 FORMAT(33H0 LESS THAN 2 OUTGOING PARTICLES )
 1102 FORMAT(34H0 MORE THAN 18 OUTGOING PARTICLES )
 1150 FORMAT(47H0 ABOVE ERROR DETECTED IN GENBOD AT CALL NUMBER,I7)
 1160 FORMAT(34H0 FIRST CALL TO SUBROUTINE GENBOD )
 1200 FORMAT(36H  INPUT DATA TO GENBOD.         NP=   ,I6/
     +  ,8H   TECM=,E16.7,18H  PARTICLE MASSES=,5E15.5/(42X,5E15.5)
     +)
      END


C (M.B.) taken from CERNLIB/KERNLIB
C        moved to DOUBLE PRECISION
      SUBROUTINE RRes_LORENB (U,PS,PI,PF)
C
C CERN PROGLIB# U102    LORENB          .VERSION KERNFOR  4.04  821124
C ORIG. 20/08/75 L.PAPE
C
      DOUBLE PRECISION U, PS, PI, PF
      DOUBLE PRECISION PF4, FN
      DIMENSION      PS(4),PI(4),PF(4)

      IF (PS(4).EQ.U) GO TO 17
      PF4  = (PI(4)*PS(4)+PI(3)*PS(3)+PI(2)*PS(2)+PI(1)*PS(1)) / U
      FN   = (PF4+PI(4)) / (PS(4)+U)
      PF(1)= PI(1) + FN*PS(1)
      PF(2)= PI(2) + FN*PS(2)
      PF(3)= PI(3) + FN*PS(3)
      PF(4)= PF4
      GO TO 18
C
   17 PF(1)= PI(1)
      PF(2)= PI(2)
      PF(3)= PI(3)
      PF(4)= PI(4)
C
   18 CONTINUE
C
      RETURN
C
      END


C (M.B.) taken from CERNLIB/PHTOOLS
C        moved to DOUBLE PRECISION
      SUBROUTINE RRes_ROTES2(C,S,C2,S2,PR,I)
C--  CALLED FROM - GENEV
C         THIS SUBROUTINE NOW DOES TWO ROTATIONS (XY AND XZ)
      IMPLICIT DOUBLE PRECISION(a-h,o-z)
      DIMENSION PR(50)
      K1 = 5*I - 4
      K2 = K1 + 1
      SA = PR(K1)
      SB = PR(K2)
      A      = SA*C - SB*S
      PR(K2) = SA*S + SB*C
      K2 = K2 + 1
      B = PR(K2)
      PR(K1) = A*C2 - B*S2
      PR(K2) = A*S2 + B*C2
      RETURN
      END


C (M.B.) taken from CERNLIB/PHTOOLS
C        moved to DOUBLE PRECISION
      DOUBLE PRECISION FUNCTION RRes_PDK(A,B,C)
C=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
C--  CALLED FROM -  GENEV
C     PDK = SQRT(A*A+(B*B-C*C)**2/(A*A) - 2.0*(B*B+C*C))/2.0
      IMPLICIT DOUBLE PRECISION(a-h,o-z)
      A2 = A*A
      B2 = B*B
      C2 = C*C
      RRes_PDK = 0.5d0*SQRT(A2 + (B2-C2)**2/A2 - 2.0d0*(B2+C2))
      RETURN
      END

      SUBROUTINE RRes_FLPSOR(A,N)
C (M.B.) taken from CERNLIB/KERNLIB
C        moved to DOUBLE PRECISION
C
C CERN PROGLIB# M103    FLPSOR          .VERSION KERNFOR  3.15  820113
C ORIG. 29/04/78
C
C   SORT THE ONE-DIMENSIONAL FLOATING POINT ARRAY A(1),...,A(N) BY
C   INCREASING VALUES
C
C-    PROGRAM  M103  TAKEN FROM CERN PROGRAM LIBRARY,  29-APR-78
C
      IMPLICIT DOUBLE PRECISION(a-h,o-z)
      DOUBLE PRECISION A(N)
C (M.B.) this common is not needed
*      COMMON /SLATE/ LT(20),RT(20)
      INTEGER LT(20)
      INTEGER R,RT(20)
C end (M.B.)
C
      LEVEL=1
      LT(1)=1
      RT(1)=N
   10 L=LT(LEVEL)
      R=RT(LEVEL)
      LEVEL=LEVEL-1
   20 IF(R.GT.L) GO TO 200
      IF(LEVEL) 50,50,10
C
C   SUBDIVIDE THE INTERVAL L,R
C     L : LOWER LIMIT OF THE INTERVAL (INPUT)
C     R : UPPER LIMIT OF THE INTERVAL (INPUT)
C     J : UPPER LIMIT OF LOWER SUB-INTERVAL (OUTPUT)
C     I : LOWER LIMIT OF UPPER SUB-INTERVAL (OUTPUT)
C
  200 I=L
      J=R
      M=(L+R)/2
      X=A(M)
  220 IF(A(I).GE.X) GO TO 230
      I=I+1
      GO TO 220
  230 IF(A(J).LE.X) GO TO 231
      J=J-1
      GO TO 230
C
  231 IF(I.GT.J) GO TO 232
      W=A(I)
      A(I)=A(J)
      A(J)=W
      I=I+1
      J=J-1
      IF(I.LE.J) GO TO 220
C
  232 LEVEL=LEVEL+1
      IF((R-I).GE.(J-L)) GO TO 30
      LT(LEVEL)=L
      RT(LEVEL)=J
      L=I
      GO TO 20
   30 LT(LEVEL)=I
      RT(LEVEL)=R
      R=J
      GO TO 20
   50 RETURN
      END

************************************************************************************
*                   extra added by S.J.                                            *
************************************************************************************

      SUBROUTINE RRes_formkuehn90(s,FPI)
*-----------------------------------------------------------------------
* Here is the subroutine which returns the Kuehn-Santamaria-form-factor
* F_\pi(s) for a given \pi\pi invariant mass s (Z. Phys. C45 (1990) 445):
*-----------------------------------------------------------------------
      IMPLICIT NONE
      REAL*8 s
      REAL*8 alpha,beta,gamma,mrho,mrho1,mrho2,Gammarho,Gammarho1
      REAL*8 Gammarho2,momega,Gammaomega
      COMPLEX*16 BWrho,BWrho1,BWrho2,BWomega
      COMPLEX*16 FPI

      alpha = 1.85d-3
      beta  = -0.145d0
      gamma = 0.d0

      mrho  = 773.d-3
      mrho1 = 1370.d-3
      mrho2 = 1700.d-3

      Gammarho  = 145.d-3
      Gammarho1 = 510.d-3
      Gammarho2 = 235.d-3
 
      momega   = 0.78194d0
      Gammaomega = 8.43d-3

      BWrho  = mrho**2/(mrho**2-s-(0.d0,1.d0)*sqrt(s)*Gammarho)
      BWrho1 = mrho1**2/(mrho1**2-s-(0.d0,1.d0)*sqrt(s)*Gammarho1)
      BWrho2 = mrho2**2/(mrho2**2-s-(0.d0,1.d0)*sqrt(s)*Gammarho2)
      BWomega = momega**2/(momega**2-s
     &         - (0.d0,1.d0)*sqrt(s)*Gammaomega)

      FPI = (BWrho*(1.d0+alpha*BWomega)/(1.d0+alpha)
     &     + beta*BWrho1+gamma*BWrho2)/(1.d0+beta+gamma)
      END

      DOUBLE PRECISION  FUNCTION RRes_F_Pi_Kuehn90_SQ(s)
*     **************************************************
      IMPLICIT NONE
      REAL*8  s
      COMPLEX*16 F_pi
      CALL RRes_formkuehn90(s,F_pi)
      RRes_F_Pi_Kuehn90_SQ = F_pi * CONJG(F_pi)
      END

c not used yet, from axel
      FUNCTION RRes_fpi2_cmd2_02(s)
*     **************************************************
c CMD-2 parametrization December 2001, (Gounaris Sakurai???)
      IMPLICIT NONE
      COMPLEX*16 cI,cdels,cepdom,cbeta,cnorm,cfpis,
     &           cBWnu,cBWde,cBWGSr0,cBWGSr1,cBWom
      REAL *8 RRes_fpi2_cmd2_02,s,mp2,mp,mr2,mr,mo2,mo,e,xp,rats,beps,ppis,lgs,
     &        hs,pi,gr,mr4,ratm,bepm,ppim,lgm,hm,dhdsm,fs,d,grs,
     &        delta,beta,rBWnu,go,deltabs,deltarg
      REAL *8 mrho(2),grho(2)
      INTEGER i
      DATA pi /3.141592653589793d0/
c Constants, Parameters
      mp     =139.56995D0
      mrho(1)=776.09d0          ! +/- 0.64 +/- 0.50    ***************
      grho(1)=144.46d0          ! +/- 1.33 +/- 0.80    ***************
      mrho(2)=1465.0d0          ! +/-  25.0
      grho(2)= 310.0d0          ! +/-  60.0            
      beta   =-.0695d0          ! +/-  .0053           ***************
      deltabs=1.57d-3           ! +/- 0.15d-3 +/- 0.05d-3     modulus of delta **********
      deltarg=12.6d0            ! +/- 3.7d0 +/- 0.2d0          phase angle in degrees *******
      mo     =782.71d0          ! +/- 0.08
      go     =  8.68d0          ! +/- 0.24
      cI   =DCMPLX(0.D0,1.D0)
      mp2  =mp*mp
      mr2  =mr*mr
      mo2  =mo*mo
c Auxiliary variables
      e    =dsqrt(s)
      xp   =4.d0*mp2
      rats =xp/s
      beps =dsqrt(1.d0-rats)
      ppis =0.5d0*e *beps
      lgs  =dlog((e +2.d0*ppis)/(2.d0*mp))
      hs   =2.d0/pi*ppis/e *lgs
      do i=1,2 
        mr   =mrho(i)
        gr   =grho(i)
        mr2  =mr *mr
        mr4  =mr2*mr2
        ratm =xp/mr2
        bepm =dsqrt(1.d0-ratm)
        ppim =0.5d0*mr*bepm
        lgm  =dlog((mr+2.d0*ppim)/(2.d0*mp))
        hm   =2.d0/pi*ppim/mr*lgm
        dhdsm=hm*(0.125d0/ppim**2-0.5d0/mr2)+0.5d0/pi/mr2
        fs   =gr*mr2/ppim**3*(ppis**2*(hs-hm)+(mr2-s)*ppim**2*dhdsm)
        d    =3.d0/pi*mp2/ppim**2*lgm+mr/2.d0/pi/ppim-mp2*mr/pi/ppim**3
        if (i.eq.1) then
          grs=gr*(ppis/ppim)**3*(mr/e)
        else 
          grs=gr
        endif
        rBWnu=mr2*(1.d0+d*gr/mr)
        cBWnu=DCMPLX(rBWnu,0.D0)
        cBWde=DCMPLX(mr2-s+fs,-mr*grs)
        if (i.eq.1) then
          cBWGSr0=cBWnu/cBWde
        else 
          cBWGSr1=cBWnu/cBWde
        endif
      enddo  
c delta argument in radians       
      deltarg=deltarg*2.d0*pi/360.d0
      cdels =DCMPLX(dcos(deltarg),dsin(deltarg))*
     &       DCMPLX(deltabs*s/mo2,0.d0)
      cBWom =DCMPLX(mo2,0.d0)/DCMPLX(mo2-s,-mo*go)
      cepdom=DCMPLX(1.d0,0.0d0)+cdels*cBWom
      cbeta =DCMPLX(beta,0.D0)
      cnorm =DCMPLX(1.d0+beta,0.D0)
      cfpis =(cBWGSr0*cepdom+cbeta*cBWGSr1)/cnorm
      RRes_fpi2_cmd2_02=cfpis*DCONJG(cfpis)
      RRes_fpi2_cmd2_02=abs(RRes_fpi2_cmd2_02)
      END


      SUBROUTINE RRes_formkuehn02(s,FPI)
*--------------------------------------------------------------------------
* WARNING!!!! THIS IS UNOFFICIAL UNPUBLISHED, IT MAY CHANGE!!!!!
* complex pion form factor, Kloe 2002, best fit (G. Venanzoni), 
* Kuehn-Santamaria-parameterization
*--------------------------------------------------------------------------
      IMPLICIT NONE
      
      COMPLEX*16 FPI,i
      complex*16 BWrho,BWrho1,BWomega
      REAL*8 s 
      REAL*8 al,be,gamma,mrho,mrho1,gammarho,gammarho1,grho,grho1
      REAL*8 momega,gammaomega,gomega
      REAL*8 mpi  

      i = (0.d0,1.d0)

      mpi = 0.13956995d0

      al = 1.48d-3            ! alpha = (1.48 +- 0.12) * 10^-3
      be = -0.1473d0          ! beta =  -0.1473 +- 0.002
      mrho = 772.6d-3           ! mrho = 772.6 +- 0.5 MeV   
      mrho1 = 1460.d-3          ! mrho1 = 1.46 GeV
      gammarho = 143.7d-3       ! Gammarho = 143.7 +- 0.7 MeV 
      gammarho1 = 310.d-3       ! Gammarho1 = 0.31 GeV
      momega = 782.78d-3        ! momega = 0.78278 GeV
      gammaomega = 8.68d-3      ! Gammaomega = 8.68 * 10^-3 GeV 

      grho = gammarho*mrho**2/s*(s-4.d0*mpi**2)**(1.5d0)/
     &     (mrho**2-4.d0*mpi**2)**(1.5d0)

      BWrho = mrho**2/(mrho**2-s-i*sqrt(s)*grho)

      grho1 = gammarho1*mrho1**2/s*(s-4.d0*mpi**2)**(1.5d0)/
     &     (mrho1**2-4.d0*mpi**2)**(1.5d0)

      BWrho1 = mrho1**2/(mrho1**2-s-i*sqrt(s)*grho1)

      gomega = gammaomega 

      BWomega = momega**2/(momega**2-s-i*sqrt(s)*gomega)

      Fpi = (BWrho * (1.d0+al*BWomega)/(1.d0+al)
     &     + be * BWrho1 )/(1.d0+be)
      END


      DOUBLE PRECISION  FUNCTION RRes_F_Pi_Kuehn02_SQ(s)
      IMPLICIT NONE
      REAL*8  s
      COMPLEX*16 F_pi
      CALL RRes_formkuehn02(s,F_pi)
      RRes_F_Pi_Kuehn02_SQ = F_pi * CONJG(F_pi)
      END

c --------------------------------------------------------------------
c --------------------------------------------------------------------
c --------------------------------------------------------------------
      DOUBLE PRECISION  FUNCTION RRes_FPi_Phk_SQ(s)
      IMPLICIT NONE
      REAL*8  s
      COMPLEX*16 F_pi, RRes_Phk_PionFormFactor
      F_pi = RRes_Phk_PionFormFactor(s)
      RRes_FPi_Phk_SQ = F_pi * CONJG(F_pi)
      END

      COMPLEX*16 function RRes_Phk_PionFormFactor(a)
      IMPLICIT NONE
c      include 'phokhara_2.0.inc'       
      double precision a
      complex*16  RRes_Phk_BW

      double precision mrho,gammarho,al,momega,gomega,be,mrhol,grhol
      mrho = 0.7726d0           ! GeV ---------- Rho mass
      gammarho = 0.1437d0       ! GeV ---------- Total rho width 
      al = 1.48d-3              ! -------------- Pion form factor parameters a and b: 
      momega = 0.78278d0        ! GeV ---------- Omega mass
      gomega = 8.68d-3          ! GeV ---------- Omega width
      be = -0.1473d0            ! -------------- Kuehn, Santamaria, ZPC48(1990)445
      mrhol = 1.46d0            ! GeV ---------- Rho' mass
      grhol = 0.31d0            ! GeV ---------- Rho' width
      
      RRes_Phk_PionFormFactor = (RRes_Phk_BW(mrho,gammarho,a,1)
     &     *(1.D0+al*RRes_Phk_BW(momega,gomega,a,1))/(1.d0+al)
     &     +be*RRes_Phk_BW(mrhol,grhol,a,1))/(1.d0+be)
      return
      end
c --------------------------------------------------------------------
      COMPLEX*16 function RRes_Phk_BW(m,breite,x,k)
      IMPLICIT NONE
c      include 'phokhara_2.0.inc'       
      integer k
      double precision m,breite,x,g
      complex *16 i

      double precision gomega,mpi
      gomega = 8.68d-3          ! GeV ---------- Omega width
      mpi = 0.13956995d0        ! GeV ---------- Charged pion mass

      if(breite.eq.gomega)then 
         g=breite
      else
         g=breite*m*m/x*(x-4.d0*mpi*mpi)**(1.5d0)/
     &     (m*m-4.d0*mpi*mpi)**(1.5d0)
      endif
      i=(0.d0,1.d0)
      if(k.eq.1)then
         RRes_Phk_BW=m*m/(m*m-x-i*sqrt(x)*g)
      else
         RRes_Phk_BW=m*m/(m*m-x+i*sqrt(x)*g)
      endif
      end
c --------------------------------------------------------------------

************************************************************************************
*                                                                                  *
*                  End of Pseudo Class RRes                                        *
*                                                                                  *
************************************************************************************
