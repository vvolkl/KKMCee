*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  KarLud                                 //
*//                                                                          //
*//   Purpose:                                                               //
*//   Top level  Monte-Carlo event generator for ISR radiadion.              //
*//   Administrates directly generation of v=1-s'/s                          //
*//   and optionaly of beamstrahlung variables x1 and x2.                    //
*//                                                                          //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////


      SUBROUTINE KarLud_Initialize(xpar_input,XCrude)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INCLUDE 'BXformat.h'
      DOUBLE PRECISION   xpar_input(*)
      DOUBLE PRECISION   XCrude, prec, Mathlib_Gauss
      INTEGER            ke, KFbeam, n, KeyGrid, KeyRes
      DOUBLE PRECISION   a,b,result,error
      DOUBLE PRECISION   BornV_Crude
      DOUBLE PRECISION   xborn,xdel
      DOUBLE PRECISION   IRCroots
      INTEGER            IRCacc,   IRCver,   IRCdate,   IRCxchat
      DOUBLE PRECISION   BornV_RhoVesko1
      EXTERNAL           BornV_RhoVesko1
C (M.B.) some variables
      INTEGER            Npeaks
      DOUBLE PRECISION   Xpeaks(100)
C end (M.B.)
* debug
      DOUBLE PRECISION   dbg_xsec,dbg_err,dbg_AveWt,dbg_RatWt,dbg_XCrude
*--------------------------------------------------------------------------------
      m_nevgen =  0
      m_nmax   =  xpar_input(19)/2
      m_idyfs  =  xpar_input(8)
*
      m_CMSene = xpar_input( 1)  ! initial value, to be preserved
      m_XXXene = m_CMSene        ! initial value, to be variable
      m_DelEne = xpar_input( 2)
      m_exe    = 1d0             ! no z-boost for default exe=1 
      m_out    = xpar_input( 4)
      m_vvmin  = xpar_input(16)
      m_vvmax  = xpar_input(17)
      m_KeyZet = xpar_input(501)
      m_KeyISR = xpar_input(20)
      m_MltISR = xpar_input(23)
      m_KeyFix = xpar_input(25)
      m_KeyWtm = xpar_input(26)
      m_alfinv = xpar_input(30)

      CALL KK2f_GetXenph(m_Xenph)

      m_WtMass = 1d0
*
      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) 'KarLud_Initialize START'
      WRITE(m_out,bxl1f) m_CMSene,   'CMS energy average','CMSene','=='
      WRITE(m_out,bxl1f) m_DelEne,   'Beam energy spread','DelEne','=='
      WRITE(m_out,bxl1i) m_KeyISR,   'ISR on/off switch ','KeyISR','=='
      WRITE(m_out,bxl1i) m_KeyFix,   'Type of ISR       ','KeyFix','=='
      WRITE(m_out,bxl1i) m_KeyZet,   'Elect_weak switch ','KeyZet','=='
      WRITE(m_out,bxl1i) m_MltISR,   'Fixed nphot mult. ','MltISR','=='
      WRITE(m_out,bxl1i) m_nmax,     'Max. photon mult. ','nmax  ','=='
      WRITE(m_out,bxclo)
*//////////////////////////////////////////////////////////////////////////////////////
*//     Check on validity of input                                                   //
*//////////////////////////////////////////////////////////////////////////////////////
      IF(m_DelEne.GT.2d0) THEN
         WRITE(m_out,*) ' ### STOP in KarLud_Initialize: DelEne too big ', m_DelEne
         STOP
      ENDIF
      IF( (m_DelEne.NE.0d0) .AND. (m_KeyFix.EQ.2) ) THEN
         WRITE(m_out,*) ' ### STOP in KarLud_Initialize:'
         WRITE(m_out,*) ' Beamsstrahlung and Beam energy spread together not safe, not tested'
         STOP
      ENDIF
*//////////////////////////////////////////////////////////////////////////////////////
      KFbeam = 11           ! KF=11 is electron
      ke = 500+10*KFbeam
      m_amel   = xpar_input(ke+6)
*
      IF(m_KeyISR .EQ. 2) THEN
*        YFSini2 is only for very special tests, no harm if deleted
         CALL YFSini2_Initialize(m_amel, m_alfinv, m_vvmin, m_nmax, m_out, m_KeyWtm, m_MltISR)
      ENDIF
*
      xborn  = BornV_Crude(0d0)
      IF(m_KeyISR .EQ. 1) THEN
         IF(m_KeyFix .EQ. 0) THEN
*//////////////////////////////////////////////////////////////////////////////////////
*//   This is normal ISR with help of Vesko1 routine, initialization                 //
*//   R-ratio is included, M.B., sept.2001                                           //
*//////////////////////////////////////////////////////////////////////////////////////
            CALL BornV_GetKeyRes(KeyRes)
            Npeaks=0
            IF(KeyRes.EQ.1) THEN
               CALL RRes_GetPeaks(m_CMSene,Npeaks,Xpeaks)
               CALL BornV_BinPeaks(Npeaks,Xpeaks)
            ENDIF
            CALL Vesk1_Initialize(BornV_RhoVesko1,Npeaks,Xpeaks,m_XCrude)
            XCrude    = m_XCrude
         ELSEIF(m_KeyFix .EQ. 2) THEN
*//////////////////////////////////////////////////////////////////////////////////////
*//   Initialization of Circe package of Thorsten Ohl                                //
*//   and of the beamstrahlung module Bstra                                          //
*//////////////////////////////////////////////////////////////////////////////////////
            IRCroots = xpar_input(71)
            IRCacc   = xpar_input(72)
            IRCver   = xpar_input(73)
            IRCdate  = xpar_input(74)
            IRCxchat = xpar_input(75)
            CALL IRC_circes(0d0, 0d0, IRCroots, IRCacc, IRCver, IRCdate, IRCxchat)
            KeyGrid  = xpar_input(76)
            CALL BStra_Initialize(KeyGrid,m_XCrude)         ! beamstrahlung initialization
         ELSEIF(m_KeyFix .EQ. -1) THEN
*//////////////////////////////////////////////////////////////////////////////////////
*//  The case of ISR swithed off, Born process                                       //
*//////////////////////////////////////////////////////////////////////////////////////
            m_XCrude = BornV_RhoVesko1(2d0)
            XCrude   = m_XCrude
            m_xcgaus = m_XCrude
            WRITE(m_out,bxl1f) m_XCrude,'xs_crude  BornV_Rho','xcvesk','  '
         ELSE
            WRITE(m_out,*) ' +++++ STOP in KarLud_Initialize, KeyFix = ', m_KeyFix
            STOP
         ENDIF
*     Miscelaneous x-check on x-section from vesko1
         IF(m_KeyFix .GE. 0 ) THEN
            a = 0d0
            b = 1d0
            prec = 1d-5
            m_xcgaus = Mathlib_Gauss(BornV_RhoVesko1,a,b, prec)
***         CALL Mathlib_GausJad(BornV_RhoVesko1,a,b, -prec, m_xcgaus) ! rather slow
            m_ErGaus   = m_xcgaus*prec
            xdel = m_XCrude/m_xcgaus-1
            WRITE(m_out,bxl1f) m_XCrude,'xs_crude  vesko    ','xcvesk','  '
            WRITE(m_out,bxl1f) m_xcgaus,'xs_crude  gauss    ','xcgaus','  '
            WRITE(m_out,bxl1f) xdel  ,  'xcvesk/xcgaus-1    ','      ','  '
         ENDIF
      ELSEIF( (m_KeyISR .EQ. 0) .OR. (m_KeyISR .EQ. 2) ) THEN
         XCrude    = xborn
         m_XCrude  = xborn
         WRITE(m_out,bxl1f) m_XCrude,'xs_crude  Born     ','xborn ','  '
      ELSE
         WRITE(*,*) ' ++++ KarLud: wrong KeyISR=',m_KeyISR
         STOP
      ENDIF
*
      CALL GLK_Mbook(m_idyfs+58,'KarLud, wtvesk  $', 100, 1.20d0)
      CALL GLK_Mbook(m_idyfs+59,'KarLud, wt_ISR  $', 1, 2.d0)
*
      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) 'KarLud_Initialize END '
      WRITE(m_out,bxclo)
      END                       ! KarLud_Initialize


      SUBROUTINE KarLud_SmearBeams
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//    Beam spread is implemented here                                              //
*//    This is correct only for very small spread < 2GeV                            //
*//    Should not be used together with beamstrahlung, lack of tests.               //
*//                                                                                 //
*//    Distribution is Gauss(X)=N*EXP( (X-CMSene/2)**2/(2*DelEne**2) )              //
*//    that is DelEne is proper dispersion in  Ebeam (not in CMSene).               //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION   pi
      PARAMETER(         pi=3.1415926535897932d0)
      DOUBLE PRECISION   EBeam1,EBeam2
      DOUBLE PRECISION   R
      REAL               rvec(10)
*------------------------------------------------------------------------------------
      IF( m_DelEne.EQ.0d0 ) RETURN
      CALL PseuMar_MakeVec(rvec,2)
      R  = m_DelEne*SQRT(-2d0*LOG(rvec(1)))
      EBeam1 = m_CMSene/2 + R*cos(2*pi*rvec(2))
      EBeam2 = m_CMSene/2 + R*sin(2*pi*rvec(2))
      EBeam1 = MAX(EBeam1,0d0)
      EBeam2 = MAX(EBeam2,0d0)
* Redefine CMS energy after smearing of the beam energies!
      m_XXXene = 2*SQRT(EBeam1*EBeam2)
      m_exe    = m_exe*SQRT(EBeam1/EBeam2)
      END                       ! KarLud_SmearBeams

      SUBROUTINE KarLud_Make(PX,wt_ISR)
*/////////////////////////////////////////////////////////////////////////////////
*//                                                                             //
*// OUTPUT:                                                                     //
*//     PX       4-momentum left after photon emission (PX=q1+q2)               //
*//     m_p1,2   beams 4-momenta                                                //
*//     m_q1,2   final state 4-momenta                                          //
*//     m_nphot   photon multiplicity                                           //
*//     m_sphot   photon 4-momenta                                              //
*//     m_sphum   sum of photon 4-momenta                                       //
*//     m_yini,zini Sudakov variables from low level MC generator               //
*//                                                                             //
*/////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INCLUDE 'BXformat.h'
      DOUBLE PRECISION    PX(4)
*---------------------
      DOUBLE PRECISION    BornV_GetMass
      DOUBLE PRECISION    BornV_RhoVesko1
      EXTERNAL            BornV_RhoVesko1
      DOUBLE PRECISION    et1,et2
      DOUBLE PRECISION    amfi1,amfi2, x,y, bt1, dummy
      DOUBLE PRECISION    wtt, wt_ISR
      DOUBLE PRECISION    ph(4)
      DOUBLE PRECISION    EBeam1,EBeam2
      INTEGER             k,j 
*
      m_NevGen =  m_NevGen+1
      m_exe    = 1d0
      m_XXXene = m_CMSene
      IF(m_KeyISR .EQ. 1) THEN
*///////////////////////////////////////////////////////////////////////////////////
*//    Machine Gaussian Beam Spread  << 1GeV                                      //
*// Weight from Vesko/Vegas has Z peak at wrong v, at rescaled prosition          //
*// However, rho of Bornv is called once again by Vesko/Vegas for modified XXXene //
*// and Z position will be at the correct position in vv.                         //
*// The weight in model is not modifying Z position any more, see KK2f.           //
*///////////////////////////////////////////////////////////////////////////////////
      CALL KarLud_SmearBeams
      CALL BornV_SetCMSene(m_XXXene)
*-------------------------------------------------------------
*     Generate vv = 1-s'/s
         IF(    m_KeyFix .EQ. 0 ) THEN
            CALL Vesk1_Make( BornV_RhoVesko1, x,y, m_WtBasic)
         ELSEIF(m_KeyFix .EQ. 2) THEN
            CALL BStra_Make(m_vv, m_x1, m_x2, m_WtBasic)
*           Redefine CMS energy and boost
            m_XXXene = m_XXXene*SQRT((1d0-m_x1)*(1d0-m_x2))
            m_exe    = m_exe   *SQRT((1d0-m_x1)/(1d0-m_x2))
         ELSEIF(m_KeyFix .EQ.-1) THEN
            m_WtBasic=1d0
            dummy = BornV_RhoVesko1(2d0)
         ELSE          
            WRITE(*,*) ' ++++ KarLud: wrong KeyFix=',m_KeyFix
            STOP
         ENDIF
         CALL BornV_GetVV(m_vv)
*        Low-level multiphoton generator
         CALL KarLud_YFSini(m_XXXene, m_vv, PX, m_WtIni)
         wt_ISR = m_WtBasic*m_WtIni
*-------------------------------------------------------------
      ELSEIF(m_KeyISR .EQ. 2) THEN
*     This is for special tests with flat x-section
         CALL YFSini2_Make(m_XXXene, m_vv, m_p1,m_p2,
     $        m_nphot,m_sphot,m_sphum,m_yini,m_zini,PX,m_WtIni)
         wt_ISR = m_WtIni
*-------------------------------------------------------------
      ELSEIF(m_KeyISR .EQ. 0) THEN
         CALL KinLib_givpair(m_XXXene,m_amel,m_amel,m_p1,m_p2,bt1,et1,et2)
         DO k=1,4
            PX(k) = m_p1(k)+m_p2(k)
         ENDDO
         m_nphot   = 0
         wt_ISR  = 1d0
      ELSE
         WRITE(*,*) ' ++++ KarLud: wrong KeyISR=',m_KeyISR
         STOP
      ENDIF
*-------------------------------------------------------------
* Generate flavour KF and set exclusive mode
* Note that GenKF uses table of xsections m_Xborn defined in 
* the Vesk1_Make( BornV_RhoVesko1,...) or predefined during Initialization
      IF(wt_ISR .NE. 0d0)  THEN
         CALL MBrA_GenKF(m_KFfin,m_Wt_KF)
         wt_ISR = wt_ISR *m_Wt_KF
      ENDIF
      CALL KK2f_SetOneY(255,m_Wt_KF) ! Pure debug
*-------------------------------------------------------------
      IF(wt_ISR .EQ. 0d0 ) THEN
*     Set momenta to zero for WT=0 events
         DO k=1,4
            m_q1(k) =0d0
            m_q2(k) =0d0
            m_sphum(k)=0d0
         ENDDO
         m_nphot=0
         DO j=1,m_npmx
            DO k=1,4
               m_sphot(j,k)=0d0
            ENDDO
         ENDDO
         m_KFfin = 0
      ELSE
*     Define final fermion momenta (NOT used in case of FSR)
*     PX is the four-momentum of final state fermion pair in CMS
         amfi1  =BornV_GetMass(m_KFfin)
         amfi2  =BornV_GetMass(m_KFfin)
         CALL KinLib_phspc2( PX,amfi1,amfi2,m_q1,m_q2,wtt)
      ENDIF
*-------------------------------------------------------------
*     Final weight administration
      CALL GLK_Mfill(m_idyfs+58, m_WtBasic,  1d0)
      CALL GLK_Mfill(m_idyfs+59, wt_ISR, 1d0)
* store PX for further use through getter
      DO k=1,4
         m_PX(k) = PX(k)
      ENDDO
*-------------------------------------------------------------
      CALL KK2f_SetOneY(203,Wt_ISR)    ! Pure temporary debug
      CALL KK2f_SetOneY(250,m_WtBasic) ! Pure temporary debug
      CALL KK2f_SetOneY(251,m_WtIni)   ! Pure temporary debug
      END

      SUBROUTINE KarLud_Finalize(mode, XKarlud, KError)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Calculates crude xsection  XKarlud  and prints out final statistics     //
*//                                                                           //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'BXformat.h'
      INCLUDE 'KarLud.h'
      INTEGER  mode
      DOUBLE PRECISION    XKarlud,  KError
      DOUBLE PRECISION    ISRcru,  ISRerr, ISRbest
      DOUBLE PRECISION    averwt,  evtot,  evacc,  evneg, evove
      DOUBLE PRECISION    wt_ISR,  erkrl,  ErRela
      DOUBLE PRECISION    ddr,     ddv,    erkr,   xskr
      DOUBLE PRECISION    WTsup, AvUnd, AvOve, ROverf
      INTEGER  Nevtot,Nevacc,Nevneg,Nevove,Nevzer
*///////////////////////////////////////////////////////////////////////////////
*//   Normal case, ISR is ON                                                  //
*///////////////////////////////////////////////////////////////////////////////
      IF(m_KeyISR .EQ. 1) THEN
* Important part for NORMALIZATION in KK2f
         IF(     m_KeyFix .EQ. 0 ) THEN
            CALL Vesk1_Finalize(ISRbest,ErRela,ISRcru)
            ISRerr   = ISRbest*ErRela
            XKarlud  = ISRcru                      ! true crude
            KError   = 0d0
         ELSEIF( m_KeyFix .EQ. 2 ) THEN
            CALL BStra_GetXCrude(ISRcru)
            CALL BStra_Finalize(ISRbest,ErRela)
            ISRerr   = ISRbest*ErRela
            XKarlud  = ISRbest                     ! crude from internal loop
            KError   = ISRerr                      ! and its error
         ELSEIF( m_KeyFix .EQ. -1 ) THEN
            ISRcru   = m_XCrude
            ISRbest  = m_XCrude
            ISRerr   = 0d0
            XKarlud  = ISRcru                     ! artificial crude
            KError   = 0d0
         ELSE
            WRITE(*,*) ' ++++ KarLud_Finalize: wrong KeyFix=',m_KeyFix
            STOP
         ENDIF
*---------------------------------------------------------------
* The rest is miscelaneous information
* no printout for mode = 1
         IF(mode .EQ. 2) THEN
            WRITE(m_out,bxope)
            WRITE(m_out,bxtxt) '     KarLud  final  report     '
            WRITE(m_out,bxl1i) m_NevGen,         'total no of events','nevtot ','=='
            WRITE(m_out,bxl1f) ISRcru,           'ISRcru  [R]       ','ISRcru ','=='
            WRITE(m_out,bxl2f) ISRbest,ISRerr,   'ISRbest [R],ISRerr','ISRbest','=='
            WRITE(m_out,bxl1g) XKarlud,          'XKarlud [R]       ','XKarlud','=='
            WRITE(m_out,bxl1g) KError,           'KError  [R]       ','KError ','=='
            WRITE(m_out,bxclo)
*     Principal weight
            CALL GLK_MgetAll(m_idyfs+59, wt_ISR,erkrl, WtSup, AvUnd, AvOve,
     $                                Nevtot,Nevacc,Nevneg,Nevove,Nevzer)
            WRITE(m_out,bxope)
            WRITE(m_out,bxtxt) '  Report on wt_ISR of KarLud   '
            WRITE(m_out,bxl1i) nevtot,          'total no of events ','nevtot ','=='
            WRITE(m_out,bxl1i) nevneg,          'wt<0        events ','nevneg ','=='
            WRITE(m_out,bxl2f) wt_ISR,erkrl,    '<wt>               ','wt_ISR ','=='
            xskr   = XKarlud*wt_ISR
            erkr   = xskr*erkrl
            WRITE(m_out,bxl2f) xskr,erkr,       'sigma of KarLud [R]','xskarl ','=='
            WRITE(m_out,bxclo)
*     Vesko weight (miscelaneous)
            IF(     m_KeyFix .EQ. 0 ) THEN
               CALL GLK_MgetAve(m_idyfs+58,AverWt,ErRela,WtSup)
               WRITE(m_out,bxope)
               WRITE(m_out,bxl2f) averwt,errela,    'Average WT of Vesk1','AVesk1','=='
               WRITE(m_out,bxl2f) m_xcgaus,m_ErGaus,'xs_est gauss    [R]','xcgaus','=='
               ddv    = ISRbest/m_xcgaus-1d0
               ddr    = ErRela + 1d-6
               WRITE(m_out,bxl2f) ddv,ddr,          'xcve/xcgs-1        ','      ','=='
               WRITE(m_out,bxclo)
               CALL  GLK_Mprint(m_idyfs+58)
            ENDIF
         ENDIF
*///////////////////////////////////////////////////////////////////////////////
*//   Normal case, ISR is OFF, Born only                                      //
*///////////////////////////////////////////////////////////////////////////////
      ELSEIF( (m_KeyISR .EQ. 0) .OR. (m_KeyISR .EQ. 2) ) THEN
         XKarlud    = m_XCrude
         KError     = 0d0   
         IF(mode .EQ. 2) THEN
            WRITE(m_out,bxope)
            WRITE(m_out,bxl1i) m_NevGen,   'total no of events','nevtot ','a0'
            WRITE(m_out,bxl1f) XKarlud,    'xs_crude  Born     ','xborn ','  '
            WRITE(m_out,bxclo)
         ENDIF
      ELSE
         WRITE(*,*) ' ++++ KarLud: wrong KeyISR=',m_KeyISR
         STOP
      ENDIF
      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) '     KarLud_Finalize END  <<<     '
      WRITE(m_out,bxclo)
      END  ! KarLud_Finalize


      SUBROUTINE KarLud_YFSini(XXXene,vv, PX,WtIni)
*////////////////////////////////////////////////////////////////////////////////////
*//                                                                                //
*//  ======================================================================        //
*//  ======================= Y F S G E N ==================================        //
*//  ======================================================================        //
*//  The algorithm in this subprogram was described in:                            //
*//  ``Yennie-Frautschi-Suura soft photons in Monte Carlo event generators''       //
*//             Unpublished report by S. Jadach,                                   //
*//          MPI-Munchen, MPI-PAE/PTh 6/87, Jan. 1987.                             //
*//                                                                                //
*//  Later on used in YFS1,YFS2,YFS3, YFSWW, KORALZ, KORALW Monte Carlo programs   //
*//                                                                                //
*//  Purpose:  ISR photon emission, photon multiplicity and momenta                //
*//                                                                                //
*////////////////////////////////////////////////////////////////////////////////////
*//   INPUT:    XXXene,vv                                                          //
*//   OUTPUT:   PX,WtIni                                                           //
*//                                                                                //
*//   XXXene  = total cms energy                                                   //
*//   amel    = beam mass                                                          //
*//   MltISR  = flag normaly set to zero, for SPECIAL tests enforces               //
*//             photon multiplicity to be exactly equal MltISR                     //
*//   vv      = v=1-s'/s variable                                                  //
*//   vmin    = minimum v variable (infrared cutoff)                               //
*//   nmax    = maximum photon multiplicity                                        //
*//   alfinv  = 1/apha_QED                                                         //
*//   p1,2    = initial fermion momenta (along z-axix)                             //
*//   nphot   = photon multiplicity                                                //
*//   sphot   = photon four-momenta                                                //
*//   sphum   = total photon four-momentum                                         //
*//   ygr,zet = Sudakov variables                                                  //
*//   PX      = 4-mmentum left after photon emission                               //
*//   WtIni   = total weight from this sub-generator                               //
*////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
*
      DOUBLE PRECISION  pi
      PARAMETER( pi=3.1415926535897932d0)
*
      DOUBLE PRECISION    XXXene,vv
*
      DOUBLE PRECISION    xphot(100,4)    ! photon momenta before rescaling
      DOUBLE PRECISION    PX(4),xph(100),rr(100)
      DOUBLE PRECISION    pp(4),pk(4)
*
      INTEGER  i,j,k
      DOUBLE PRECISION    phi,cg,sg,xk
      DOUBLE PRECISION    dist0,dist1
      DOUBLE PRECISION    beta,eta1,eta2
      DOUBLE PRECISION    Ene,ppdpp,ppdpk,pkdpk,DilFac,DilFac0,AA
      DOUBLE PRECISION    del1,del2,am2
      DOUBLE PRECISION    DilJac0,DilJac,AvMult,WtIni
      DOUBLE PRECISION    WtDil0,WtCut0
      REAL                rvec(10)
*---------------------------------------
      Ene  = XXXene/2d0
* Define 4-momenta of the initial charged particles (emitters)
      CALL KinLib_givpair(XXXene,m_amel,m_amel,m_p1,m_p2,beta,eta1,eta2)
      DO i=1,m_nmax
         xph(i)=0d0
         m_yini(i)=0d0
         m_zini(i)=0d0
         DO j=1,4
            xphot(i,j)=0d0
            m_sphot(i,j)=0d0
         ENDDO
      ENDDO
      IF(vv .LE. m_vvmin) THEN
*///////////////////////////////////////////////////
*//    no photon above detectability threshold    //
*///////////////////////////////////////////////////
         m_WtMass  = 1d0
         m_WtDil  = 1d0
         m_WtCut  = 1d0
         WtDil0 = 1d0          !test
         WtCut0 = 1d0          !test
         m_nphot=0
      ELSE
*/////////////////////////////////////////////////////////
*// one or more photons, generate photon multiplicity   //
*// nphot = poisson(AvMult) + 1                         //
*/////////////////////////////////////////////////////////
         CALL BornV_GetAvMult(AvMult)
 100     CONTINUE
         CALL KarLud_PoissGen(AvMult,m_nmax,m_nphot,rr)
         m_nphot = m_nphot+1
* For special tests of program at fixed multiplicity (for advc. users)
         IF((m_MltISR .NE. 0) .AND. (m_nphot .NE. m_MltISR)) GOTO 100
         IF(m_nphot .EQ. 1) THEN
            xph(1)=vv
         ELSE
            xph(1)=vv
            DO i=2,m_nphot
               xph(i)=vv*(m_vvmin/vv)**rr(i-1)
            ENDDO
         ENDIF ! nphot
         m_WtMass=1d0
         DO i=1,m_nphot
            xk=xph(i)
            am2  = (m_amel/Ene)**2
            CALL KarLud_AngBre(am2,del1,del2,cg,sg,dist0,dist1)
            dist0 = dist0 *m_Xenph
            m_WtMass    =m_WtMass *(dist1/dist0)
            CALL PseuMar_MakeVec(rvec,1)
            phi=2d0*pi*rvec(1)
            xphot(i,1)=xk*sg*cos(phi)
            xphot(i,2)=xk*sg*sin(phi)
            xphot(i,3)=xk*cg
            xphot(i,4)=xk
            m_yini(i)    =xk*del1/2d0
            m_zini(i)    =xk*del2/2d0
         ENDDO
*///////////////////////////////////////////////////////////////////////////
*// Here we determine dilatation factor for rescaling 4-momenta           //
*// of all photons such that total 4-momentum is conserved (for fixed v)  //
*///////////////////////////////////////////////////////////////////////////
         IF(m_nphot .EQ. 1) THEN
            DilFac0 = 1d0
            DilFac  = 1d0
            DilJac  = 1d0
         ELSE
            DO k=1,4
               pk(k)=0d0
               pp(k)=0d0
            ENDDO
            pp(4)=2d0           ! total energy in units of ene
            DO i=1,m_nphot
               DO k=1,4
                  pk(k)=pk(k)+xphot(i,k)
               ENDDO
            ENDDO
            ppdpp = pp(4)**2-pp(3)**2-pp(2)**2-pp(1)**2
            pkdpk = pk(4)**2-pk(3)**2-pk(2)**2-pk(1)**2
            ppdpk = pp(4)*pk(4)-pp(3)*pk(3)-pp(2)*pk(2)-pp(1)*pk(1)
            AA    = ppdpp*pkdpk/(ppdpk)**2
*     Dilatation factor
            DilFac0 = 2d0*ppdpk/ppdpp/vv
            DilFac  = DilFac0*.5d0*(1d0+sqrt(1d0-vv*AA))
*     and the corresponding jacobian factor
            DilJac  = (1d0+1d0/sqrt(1d0-vv*AA))/2d0
         ENDIF
         DilJac0 = (1d0+1d0/sqrt(1d0-vv))/2d0  !!! as in crude v-dist. in BornV_RhoVesko1
         m_WtDil  = DilJac/DilJac0
         m_WtCut  = 1d0
         WtDil0   = 1d0 /DilJac0   ! test
         WtCut0   = 1d0            ! test
*     scale down photon energies and momenta
         DO i=1,m_nphot
            m_yini(i) =m_yini(i)/DilFac
            m_zini(i) =m_zini(i)/DilFac
            DO k=1,4
               m_sphot(i,k)=xphot(i,k)/DilFac
            ENDDO
         ENDDO
*     Check on lower energy cut-off
         IF(m_sphot(m_nphot,4) .LT. m_vvmin)      m_WtCut = 0d0
         IF(xphot(m_nphot,4)/DilFac0 .LT. m_vvmin ) WtCut0 =0d0 !!! test
      ENDIF ! vv
*     Photon momenta rescaled into GEV units
      DO j=1,4
         m_sphum(j)=0d0
      ENDDO
      DO  i=1,m_nphot
         DO  j=1,4
            m_sphot(i,j) = m_sphot(i,j)*Ene
            m_sphum(j)   = m_sphum(j) +m_sphot(i,j)
         ENDDO
      ENDDO
* 4-momentum left after photon emission
      DO k=1,4
         PX(k)= -m_sphum(k)
      ENDDO
      PX(4)=PX(4)+XXXene
* Total ISR weight
      IF(m_KeyWtm .EQ. 1) m_WtMass=1d0
*
      WtIni = m_WtMass *m_WtDil *m_WtCut
*     ==============================
*((((((((((((((((((((((((((((
* Testing/debug part, some variables exported up to KK2f class
* NO HARM IF OMITTED !!!!
      CALL KK2f_SetOneY(252,m_WtMass)
      CALL KK2f_SetOneY(253,m_WtDil)
      CALL KK2f_SetOneY(254,m_WtCut)
* Auxiliary weights for tests of crude v-distr.
      CALL KK2f_SetOneY(263,WtDil0)
      CALL KK2f_SetOneY(264,WtCut0)
*))))))))))))))))))))))))))))
*----------------------------
      END

      SUBROUTINE KarLud_AngBre(am2,del1,del2,costhg,sinthg,dist0,dist1)
*//////////////////////////////////////////////////////////////////////////////
*// This routine generates photon angular distribution                       //
*// in the rest frame of the fermion pair.                                   //
*// The distribution is the S-factor without mass term,                      //
*// i.e. without terms 2p_1p_2/(kp_1)(kp_2)                                  //
*// Fermion mass is treated exactly!                                         //
*// INPUT:                                                                   //
*//     am2 = 4*massf**2/s where massf is fermion mass                       //
*//     and s is effective mass squared of the parent fermion-pair.          //
*// OUTPUT:                                                                  //
*//     del1= 1-beta*cos(theta)                                              //
*//     del2= 1+beta*cos(theta)                                              //
*//     costhg, sinthg, cos and sin of the photon                            //
*//     angle with respect to fermions direction                             //
*//     dist0 = distribution generated, without m**2/(kp)**2 terms           //
*//     dist1 = distribution with m**2/(kp)**2 terms                         //
*//////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      DOUBLE PRECISION  am2,del1,del2,costhg,sinthg,dist0,dist1
* locals
      DOUBLE PRECISION  a,eps,beta
      REAL              rn(10)
*------------------------------------------------------------------------------
      CALL PseuMar_MakeVec(rn,2)
      beta =sqrt(1.d0-am2)
      eps  =am2/(1.d0+beta)                     != 1-beta
      del1 =(2.d0-eps)*(eps/(2.d0-eps))**rn(1)  != 1-beta*costhg
      del2 =2.d0-del1                           != 1+beta*costhg
* calculation of sin and cos theta from internal variables
      costhg=(del2-del1)/(2*beta)               ! exact
      sinthg=sqrt(del1*del2-am2*costhg**2)      ! exact
* symmetrization
      IF(rn(2) .LE. 0.5d0) THEN
        a=del1
        del1=del2
        del2=a
        costhg= -costhg
      ENDIF
      dist0=1d0/(del1*del2)*(1d0 -am2/2d0)
      dist1=1d0/(del1*del2) 
     $     *(1d0 -am2/2d0 -am2/4d0*(del1/del2+del2/del1))
* totaly equivalent formula is the following
*     dist1=1d0/(del1*del2)   *beta*sinthg**2/(del1*del2)
      END

      SUBROUTINE KarLud_PoissGen(average,nmax,mult,rr)
*//////////////////////////////////////////////////////////////////////////////
*// Last corr. nov. 91                                                       //
*// This generates photon multipl. nphot according to poisson distr.         //
*// Input:  average = average multiplicity                                   //
*//         nmax  = maximum multiplicity                                     //
*// Output: mult = generated multiplicity                                    //
*//         rr(1:100) list of ordered uniform random numbers,                //
*//         a byproduct result, to be eventually used for some further       //
*//         purpose (i.e.  generation of photon energies).                   //
*//////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INTEGER           nmax,mult
      DOUBLE PRECISION  rr(*),average
* locals
      DOUBLE PRECISION  sum,y
      INTEGER           it,nfail,nn
      REAL              rvec(10)
      DATA nfail/0/
*------------------------------------------------------------------------------
 50   nn=0
      sum=0d0
      DO it=1,nmax
         CALL PseuMar_MakeVec(rvec,1)
         y= log(rvec(1))
         sum=sum+y
         nn=nn+1
         rr(nn)=sum/(-average)
         IF(sum .LT. -average) GOTO 130
      ENDDO
      nfail=nfail+1
      IF(nfail .GT. 100) GOTO 900
      GOTO 50
 130  mult=nn-1
      RETURN
 900  WRITE(*,*) ' poissg: to small nmax ',nmax
      STOP
      END


      SUBROUTINE KarLud_ZBoostAll(exe)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   performs z-boost on all momenta of the event                            //
*//   this z-boost corresponds to beamstrahlung or beamspread                 //
*//   and is done at the very end of generation, after m.el. calculation      //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION  exe
      INTEGER           j,k
      DOUBLE PRECISION  ph(4)
*
      IF( exe.EQ. 1d0) RETURN
      CALL KinLib_Boost(3,exe,m_p1,m_p1)
      CALL KinLib_Boost(3,exe,m_p2,m_p2)
      CALL KinLib_Boost(3,exe,m_q1,m_q1)
      CALL KinLib_Boost(3,exe,m_q2,m_q2)
      CALL KinLib_Boost(3,exe,m_sphum,m_sphum)
      CALL KinLib_Boost(3,exe,m_PX,m_PX)
      DO j=1,m_nphot
         DO k=1,4
            ph(k) = m_sphot(j,k)
         ENDDO
         CALL KinLib_Boost(3,exe,ph,ph)
         DO k=1,4
            m_sphot(j,k) = ph(k)
         ENDDO
      ENDDO
      END


      SUBROUTINE KarLud_GetXXXene(XXXene)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION  XXXene
*
      XXXene = m_XXXene
      END

      SUBROUTINE KarLud_GetExe(Exe)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION  Exe
*
      Exe = m_Exe
      END

      SUBROUTINE KarLud_Getvvmax(vvmax)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION  vvmax
*
      vvmax = m_vvmax
      END

      SUBROUTINE KarLud_GetVVxx(vv,x1,x2)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION  vv,x1,x2
*
      vv = m_vv
      x1 = m_x1
      x2 = m_x2
      END


      SUBROUTINE KarLud_GetSudakov1(iphot,y,z)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Get sudakovs of i-th photon                                             //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER iphot
      DOUBLE PRECISION   y,z
*
      y = m_yini(iphot)
      z = m_zini(iphot)
      END

      SUBROUTINE KarLud_GetNphot(nphot)     
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Get photon multiplicity                                                 //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER nphot
*
      nphot = m_nphot
      END

      SUBROUTINE KarLud_GetKFfin(KFfin)     
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Get photon multiplicity                                                 //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER KFfin
*
      KFfin = m_KFfin
      END

      SUBROUTINE KarLud_GetSudakov(nphot,yini,zini)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Get all Sudakovs                                                        //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER nphot
      DOUBLE PRECISION   yini(*),zini(*)
      INTEGER i
*
      nphot = m_nphot
      DO i=1,m_nphot
         yini(i) = m_yini(i)
         zini(i) = m_zini(i)
      ENDDO
      END

      SUBROUTINE KarLud_GetPhoton1(iphot,phot)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   get i-th photon momentum                                                //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER iphot
      DOUBLE PRECISION   phot(4)
      INTEGER k
*
      DO k=1,4
         phot(k) = m_sphot(iphot,k)
      ENDDO
      END


      SUBROUTINE KarLud_GetPhotons(nphot,sphot)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Get all photons                                                         //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER nphot
      DOUBLE PRECISION   sphot(m_npmx,4)
      INTEGER j,k
*
      nphot = m_nphot
      DO j=1,m_nphot
         DO k=1,4
            sphot(j,k) = m_sphot(j,k)
         ENDDO
      ENDDO
      END

      SUBROUTINE KarLud_GetBeams(p1,p2)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   In the case of beamstrahlung these are beams AFTER beamstrahlung        //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION   p1(4),p2(4)
      INTEGER k
*
      DO k=1,4
         p1(k) = m_p1(k)
         p2(k) = m_p2(k)
      ENDDO
      END

      SUBROUTINE KarLud_GetFermions(q1,q2)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Get final fermios after ISR, replaced after FSR                         //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION   q1(4),q2(4)
      INTEGER k
*
      DO k=1,4
         q1(k) = m_q1(k)
         q2(k) = m_q2(k)
      ENDDO
      END

      SUBROUTINE KarLud_GetBeasts(p1,p2)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   In the case of beamstrahlung these are photons of the  beamstrahlung    //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION   p1(*),p2(*)
      INTEGER k
*-----------------------------------------
      DO k=1,4
         p1(k) = 0d0
         p2(k) = 0d0
      ENDDO
      p1(4) =  0.5d0*m_CMSene*m_x1
      p1(3) =  p1(4)
      p2(4) =  0.5d0*m_CMSene*m_x2
      p2(3) = -p2(4)
      END

      SUBROUTINE KarLud_GetPX(PX)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION   PX(4)
      INTEGER k
*
      DO k=1,4
         PX(k) = m_PX(k)
      ENDDO
      END

      SUBROUTINE KarLud_WtMass(WtMass)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      DOUBLE PRECISION   WtMass
*
      WtMass = m_WtMass
      END


      SUBROUTINE KarLud_Print(iev,ie1,ie2)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//  Prints out four momenta of INITIAL state                                 //
*//  and the serial number of event iev on unit m_out                         //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER  iev,ie1,ie2
      CHARACTER*8 txt
      DOUBLE PRECISION    sum(4),ams,amph,amf1,amf2
      INTEGER  i,k
*--------------------------------------------------------
      IF( (iev .GE. ie1) .AND. (iev .LE. ie2) ) THEN
         txt = '  KarLud '
         WRITE(m_out,*) 
     $        '=========== ',txt,' ======================>',iev
         amf1 = m_p1(4)**2-m_p1(3)**2-m_p1(2)**2-m_p1(1)**2
         amf1 = sqrt(abs(amf1))
         amf2 = m_p2(4)**2-m_p2(3)**2-m_p2(2)**2-m_p2(1)**2
         amf2 = sqrt(abs(amf2))
         WRITE(m_out,3100) 'p1',(  m_p1(  k),k=1,4),amf1
         WRITE(m_out,3100) 'p2',(  m_p2(  k),k=1,4),amf2
         DO i=1,m_nphot
            amph = m_sphot(i,4)**2-m_sphot(i,3)**2
     $            -m_sphot(i,2)**2-m_sphot(i,1)**2
            amph = sqrt(abs(amph))
            WRITE(m_out,3100) 'pho',(m_sphot(i,k),k=1,4),amph
         ENDDO
         DO k=1,4
            sum(k)=m_p1(k)+m_p2(k)
         ENDDO
         DO i=1,m_nphot
            DO k=1,4
               sum(k)=sum(k)-m_sphot(i,k)
            ENDDO
         ENDDO
         ams = sum(4)**2-sum(3)**2-sum(2)**2-sum(1)**2
         ams = sqrt(abs(ams))
         WRITE(m_out,3100) 'sum',(  sum(  k),k=1,4),ams
      ENDIF
 3100 FORMAT(1x,a3,1x,5f20.14)
      END

      SUBROUTINE KarLud_Print1(nout)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//  Prints out four momenta of INITIAL state                                 //
*//  and the serial number of event iev on unit m_out                         //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER  nout
      CHARACTER*8 txt
      DOUBLE PRECISION    sum(4),ams,amph,amf1,amf2
      INTEGER  i,k
*--------------------------------------------------------
      txt = '  KarLud '
      WRITE(nout,*) '=========== ',txt,' ======================',m_NevGen
      amf1 = m_p1(4)**2-m_p1(3)**2-m_p1(2)**2-m_p1(1)**2
      amf1 = sqrt(abs(amf1))
      amf2 = m_p2(4)**2-m_p2(3)**2-m_p2(2)**2-m_p2(1)**2
      amf2 = sqrt(abs(amf2))
      WRITE(nout,3100) 'p1',(  m_p1(  k),k=1,4),amf1
      WRITE(nout,3100) 'p2',(  m_p2(  k),k=1,4),amf2
      DO i=1,m_nphot
         amph = m_sphot(i,4)**2-m_sphot(i,3)**2
     $        -m_sphot(i,2)**2-m_sphot(i,1)**2
         amph = sqrt(abs(amph))
         WRITE(nout,3100) 'pho',(m_sphot(i,k),k=1,4),amph
      ENDDO
      DO k=1,4
         sum(k)=m_p1(k)+m_p2(k)
      ENDDO
      DO i=1,m_nphot
         DO k=1,4
            sum(k)=sum(k)-m_sphot(i,k)
         ENDDO
      ENDDO
      ams = sum(4)**2-sum(3)**2-sum(2)**2-sum(1)**2
      ams = sqrt(abs(ams))
      WRITE(nout,3100) 'sum',(  sum(  k),k=1,4),ams
 3100 FORMAT(1x,a3,1x,5f20.14)
      END

      SUBROUTINE KarLud_GetKeyFix(KeyFix)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KarLud.h'
      INTEGER KeyFix
*
      KeyFix = m_KeyFix
      END

*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//                       End of CLASS  KarLud                                //
*///////////////////////////////////////////////////////////////////////////////


