*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//                                                                                 //
*//  =======================================================================        //
*//  =======================================================================        //
*//  =====================FERMION PAIR PRODUCTION===========================        //
*//  ===========QED INITIAL AND FINAL STATE EXPONENTIATION==================        //
*//  =======================================================================        //
*//  ==This program is the descendant of the YFS3 and KORALZ Monte Carlos===        //
*//  ===================YFS1 September 1987 ================================        //
*//  ===================YFS2 September 1988 ================================        //
*//  ===================YFS3 February  1993 ================================        //
*//  =================YFS3ff September 1997 ================================        //
*//  ===================KK2f June      1998 ================================        //
*//  ===================KK  4.00  Nov. 1998 ================================        //
*//  ===================KK  4.01  Feb. 1999 ================================        //
*//  ===================KK  4.02  Apr. 1999 ================================        //
*//  ===================KK  4.11  Sep. 1999 ================================        //
*//  ===================KK  4.12  Oct. 1999 ================================        //
*//  ===================KK  4.13  Jan. 2000 ================================        //
*//  ===================KK  4.14  Jun. 2000 ================================        //
*//  ===================KK  4.15  May. 2001 ================================        //
*//  ===================KK  4.18  Feb. 2002 ================================        //
*//  =======================================================================        //
*//                                                                                 //
*//  AUTHORS:                                                                       //
*//                        S. Jadach                                                //
*//     Address: Institute of Nuclear Physics, Cracow, Poland                       //
*//                       B.F.L. Ward                                               //
*//     Address: University of Tennessee,  Knoxville, Tennessee                     //
*//                         Z. Was                                                  //
*//     Address: Institute of Nuclear Physics, Cracow, Poland                       //
*//                                                                                 //
*//            (C) 1998 by S. Jadach, BFL Ward, Z. Was                              //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////


*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//                                                                                 //
*//                       Pseudo-CLASS  KK2f                                        //
*//                                                                                 //
*//     Purpose:   KK 2-fermion generator, top level class                          //
*//                                                                                 //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
*

      SUBROUTINE KK2f_ReaDataX(DiskFile,iReset,imax,xpar)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   DiskFile  = input file to read                                                //
*//   imax   = maximum index in xpar                                                //
*//   iReset = 1, resets xpar to 0d0                                                //
*//   iTalk=1,     prints echo into standard input                                  //
*//                                                                                 //
*//   Single data card is:    (a1,i4,d15.0,a60)                                     //
*//   First data card: BeginX                                                       //
*//   Last  data card: EndX                                                         //
*//   First character * defines comment card!                                       //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      CHARACTER*(*)     DiskFile
      DOUBLE PRECISION  xpar(*)
      CHARACTER*6       beg6
      CHARACTER*4       end4
      CHARACTER*1       mark1
      CHARACTER*60      comm60
      CHARACTER*80      comm80
      INTEGER           imax,iReset,iTalk
      INTEGER           ninp,i,line,indeks
      DOUBLE PRECISION  value
      INTEGER           OFFSET1, OFFSET2
      CHARACTER*60      m_LHEF

*////////////////////////////////////////
*//  Clear xpar and read default Umask //
*////////////////////////////////////////
      iTalk = 1
      IF(iReset .EQ. 1 ) THEN
         iTalk = 0
         DO i=1,imax
            xpar(i)=0d0
         ENDDO
      ENDIF
      ninp = 13
      OPEN(ninp,file=DiskFile)
      IF(iTalk .EQ. 1) THEN
         WRITE(  *,*) '****************************'
         WRITE(  *,*) '*    KK2f_ReaDataX Starts  *'
         WRITE(  *,*) '****************************'
      ENDIF
* Search for 'BeginX'
      DO line =1,100000
         WRITE(*,*) '---------------'
         READ(ninp,'(a6,a)') beg6,comm60
         IF(beg6 .EQ. 'BeginX') THEN
            IF(iTalk .EQ. 1)   WRITE( *,'(a6,a)') beg6,comm60
            GOTO 200
         ENDIF
      ENDDO
 200  CONTINUE
* Read data, 'EndX' terminates data, '*' marks comment
      DO line =1,100000
         READ(ninp,'(a)') mark1
         IF(mark1 .EQ. ' ') THEN
            BACKSPACE(ninp)
            READ(ninp,'(a1,i4,d15.0,a60)') mark1,indeks,value,comm60
            IF(iTalk .EQ. 1) 
     $           WRITE( *,'(a1,i4,g15.6,a60)') mark1,indeks,value,comm60
            IF( (indeks .LE. 0) .OR. (indeks .GE. imax)) GOTO 990
            IF( indeks .EQ. 100 ) THEN
               OFFSET1 = INDEX(comm60,'(') + 1
               OFFSET2 = INDEX(comm60,')') - 1
               m_LHEF = comm60(OFFSET1:OFFSET2)
               IF( LEN_TRIM(m_LHEF) .EQ. 0 .OR. OFFSET1 .EQ. 1 .OR.
     &         OFFSET2 .EQ. -1) THEN
                  m_LHEF = 'KKMC_OUT.LHE'
               ENDIF
               WRITE(*,*) '---------------',OFFSET1 , OFFSET2, m_LHEF
               xpar(indeks) = value
               IF (value .EQ. 1) THEN
                   OPEN(77, file = m_LHEF)
               ENDIF
            ELSE   
               xpar(indeks) = value
            ENDIF   
         ELSEIF(mark1 .EQ. 'E') THEN
            BACKSPACE(ninp)
            READ(  ninp,'(a4,a)') end4,comm60
            IF(iTalk .EQ. 1)   WRITE( *,'(a4,a)') end4,comm60
            IF(end4 .EQ. 'EndX') GOTO 300
            GOTO 991
         ELSEIF(mark1 .EQ. '*') THEN
            BACKSPACE(ninp)
            READ(  ninp,'(a)') comm80
            IF(iTalk .EQ. 1)    WRITE( *,'(a)') comm80
         ENDIF
      ENDDO
 300  CONTINUE
      IF(iTalk .EQ. 1)  THEN
         WRITE(  *,*) '**************************'
         WRITE(  *,*) '*   KK2f_ReaDataX Ends   *'
         WRITE(  *,*) '**************************'
      ENDIF
      CLOSE(ninp)
      RETURN
*-----------
 990  WRITE(    *,*) '+++ KK2f_ReaDataX: wrong index= ',indeks
      STOP
      RETURN
 991  WRITE(    *,*) '+++ KK2f_ReaDataX: wrong end of data '
      STOP
      END

      SUBROUTINE KK2f_fort_open(nout,fname)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Interface used by c++ programs                                                //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      CHARACTER fname*(*)
      INTEGER nout,nout2
      nout2 = nout
      WRITE( *,*) 'KK2f_fort_open: nout = ',nout,'   fname= ',fname
      OPEN(nout2,file=fname)
      END

      SUBROUTINE KK2f_fort_close(nout)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Interface used by c++ programs                                                //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INTEGER nout,nout2
      CLOSE(nout2)
      END
      
      SUBROUTINE KK2f_Initialize(xpar)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   Initialize class KK2f_                                                        //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INCLUDE 'BXformat.h'
      DOUBLE PRECISION    xpar(*)
      INTEGER             IsGenerated, KF,j,kxp
      INTEGER             Nbranch, KFferm
      DOUBLE PRECISION    BornV_Integrated, BornV_Sig0nb
      DOUBLE PRECISION    BornV_GetMass, BornV_GetAuxPar, MinMas
      DOUBLE PRECISION    WtMax,  amferm, xcru_karl
      DOUBLE PRECISION    WMlist(200), Xborn(200)  ! 200 should be class parameter!!!
      INTEGER             NBbranch,   KFlist(200), Nbin, m_WriteLHE
      DOUBLE PRECISION    vvmin, pol1, pol2, PolBeam1(4), PolBeam2(4)
*--------------------------------------------------------------------------
*     Initialization of the internal histogramming package
      CALL GLK_Initialize

      
      DO j=1,m_jlim
         m_xpar(j)=xpar(j)
      ENDDO
*
      m_out = m_xpar(4)
*
      WRITE(m_out,'(10x,a)')
     $' ',
     $'  ****************************************************************************************',
     $'  *  ****   ****    ****  ****    ***       ***     ******                               *',
     $'  *  ****   ****    ****  ****    ****     ****   **********                             *',
     $'  *  ****   ****    ****  ****    *****   *****  *****   ***                             *',
     $'  *  **********     *********     *************  ****            ******       ******     *',
     $'  *  *******        ******        *************  ****          ***    ***   ***    ***   *',
     $'  *  **********     ********      **** *** ****  *****   ***   **********   **********   *',
     $'  *  ****  *****    ****  ****    ****  *  ****   **********   ***          ***          *',
     $'  *  ****   *****   ****   ****   ****     ****     *******      ******        ******    *',
     $'  ****************************************************************************************',
     $' '
*
      m_CMSene = m_xpar( 1)
      m_DelEne = m_xpar( 2)
      m_WTmax  = m_xpar( 9)
      m_KeyWgt = m_xpar(10)
      m_npmax  = m_xpar(19)
      m_Idyfs  = m_xpar(8)
      m_KeyISR = m_xpar(20)
      m_KeyFSR = m_xpar(21)
      m_KeyINT = m_xpar(27)
      m_KeyGPS = m_xpar(28)
      m_alfinv = m_xpar(30)
      m_vcut(1)= m_xpar(41)
      m_vcut(2)= m_xpar(42)
      m_vcut(3)= m_xpar(43)
      m_KeyHad = m_xpar(50)
      m_HadMin = m_xpar(51)
      m_KFini  = m_xpar(400)
      m_MasPhot= m_xpar(510)
      vvmin =xpar(16)
      m_WriteLHE = m_xpar(100)
*      BEAMENERGY=m_CMSene/2.
      IF(m_WriteLHE .EQ. 1) THEN

*        If needed the file is opend in KK2f_ReaDataX 
         WRITE(77, '(a)')'<LesHouchesEvents version="1.0">'
         WRITE(77, '(a)')'<!--'
         WRITE(77, '(a)')'   File Created with KKMC'
         WRITE(77, '(a)')'-->'
         WRITE(77, '(a)')'<init>'
         WRITE(77, '(A, es17.8, A, es17.8, A)' )'  11  -11  ', m_CMSene/2.,'  ', m_CMSene/2. , '  0  0  0  0  3  1'
         WRITE(77, '(a)')'  0.1  1.0e-06  1.000000e+00   9999'
         WRITE(77, '(a)')'</init>'
         WRITE(77, '(a)')'  '
         
      END IF



      m_Emin   = m_CMSene/2d0 * vvmin
      m_Xenph  = m_xpar(40)
      IF(m_KeyINT .EQ. 0)  m_Xenph  = 1D0
*
      DO j=1,3
         m_PolBeam1(j)=m_xpar(60+j)
         m_PolBeam2(j)=m_xpar(63+j)
      ENDDO
      m_PolBeam1(4)=1d0
      m_PolBeam2(4)=1d0

*
      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) '        KK Monte Carlo         '
      WRITE(m_out,bxl1v) 'Version ',      m_version,     m_date
      WRITE(m_out,bxl1f) m_CMSene,   'CMS energy average ','CMSene','a1'
      WRITE(m_out,bxl1f) m_DelEne,   'Beam energy spread ','DelEne','a2'
      WRITE(m_out,bxl1i) m_npmax,    'Max. photon mult.  ','npmax ','a3'
      WRITE(m_out,bxl1i) m_KeyWgt,   'wt-ed or wt=1 evts.','KeyWgt','a4'
      WRITE(m_out,bxl1i) m_KeyISR,   'ISR switch         ','KeyISR','a4'
      WRITE(m_out,bxl1i) m_KeyFSR,   'FSR switch         ','KeyFSR','a5'
      WRITE(m_out,bxl1i) m_KeyINT,   'ISR/FSR interferenc','KeyINT','a6'
      WRITE(m_out,bxl1i) m_KeyGPS,   'New exponentiation ','KeyGPS','a7'
      WRITE(m_out,bxl1i) m_KeyHad,   'Hadroniz.  switch  ','KeyHad','a7'
      WRITE(m_out,bxl1f) m_HadMin,   'Hadroniz. min. mass','HadMin','a9'
      WRITE(m_out,bxl1f) m_WTmax,    'Maximum weight     ','WTmax ','a10'
      WRITE(m_out,bxl1i) m_npmax,    'Max. photon mult.  ','npmax ','a11'
      WRITE(m_out,bxl1i) m_KFini,    'Beam ident         ','KFini ','a12'
      WRITE(m_out,bxl1f) m_Emin,     'Manimum phot. ener.','Ene   ','a13'
      WRITE(m_out,bxl1g) m_MasPhot,  'Phot.mass, IR regul','MasPho','a14'
      WRITE(m_out,bxl1g) m_Xenph  ,  'Phot. mult. enhanc.','Xenph ','a15'
      WRITE(m_out,bxl1g) m_Vcut(1),  'Vcut1              ','Vcut1 ','a16'
      WRITE(m_out,bxl1g) m_Vcut(2),  'Vcut2              ','Vcut2 ','a16'
      WRITE(m_out,bxl1g) m_Vcut(3),  'Vcut3              ','Vcut2 ','a16'
      WRITE(m_out,bxl1f) m_PolBeam1(1), 'PolBeam1(1)     ','Pol1x ','a17'
      WRITE(m_out,bxl1f) m_PolBeam1(2), 'PolBeam1(2)     ','Pol1y ','a18'
      WRITE(m_out,bxl1f) m_PolBeam1(3), 'PolBeam1(3)     ','Pol1z ','a19'
      WRITE(m_out,bxl1f) m_PolBeam2(1), 'PolBeam2(1)     ','Pol2x ','a20'
      WRITE(m_out,bxl1f) m_PolBeam2(2), 'PolBeam2(2)     ','Pol2y ','a21'
      WRITE(m_out,bxl1f) m_PolBeam2(3), 'PolBeam2(3)     ','Pol2z ','a22'
      WRITE(m_out,bxclo)

* Check on polarization vectors
      pol1 = SQRT( m_PolBeam1(1)**2+m_PolBeam1(2)**2+m_PolBeam1(3)**2 )
      pol2 = SQRT( m_PolBeam2(1)**2+m_PolBeam2(2)**2+m_PolBeam2(3)**2 )
      IF(       pol1 .GT. 1d0 .OR. pol2 .GT. 1d0 ) THEN
         WRITE(m_out,'(a)') ' ##### STOP in KK2f_Initialize: WRONG SPIN VECTORS '
         WRITE(    *,'(a)') ' ##### STOP in KK2f_Initialize: WRONG SPIN VECTORS '
         STOP
      ENDIF
* Note that getter KK2f_GetIsBeamPolarized exists!
      m_IsBeamPolarized = 1
      IF( (pol1+pol2) .LT. 1d-6 ) m_IsBeamPolarized = 0

      IF(m_KeyWgt.EQ.1 .AND. m_KeyHad.EQ.1 ) THEN
         WRITE(m_out,*) '+++WARNING: for WT=0 events NO hadronization!'
         WRITE(    *,*) '+++WARNING: for WT=0 events NO hadronization!'
      ENDIF
*
*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
* Identificator for this generator
      m_idgen = 6
* Important 'signature histo' which remembers crude total x-section
      CALL GLK_Mbook(m_idgen   ,'KK2f signature  $', 1,m_WTmax)
* Tests
      CALL GLK_Mbook(m_Idyfs+40, 'KK2f: Photon raw multiplicity $',10, 0.1d0*m_xpar(19))
*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
* Basic initialization of brancher, branches are defined in BornV_Initialize
      m_IdBra = m_Idyfs+100
      CALL MBrA_Initialize(m_out,m_IdBra,50,m_WTmax, 'MBrA: KK2f main weight$')
*     Add branch for each final fermion
      DO j=1,20
         IsGenerated = m_xpar(400+j)
         IF( IsGenerated .NE. 0) THEN
            kxp = 500+10*j
            KF    = m_xpar(kxp+1)
            WtMax = m_xpar(kxp+7)
            IF(m_KeyISR .EQ. 0) WtMax = 1d0
            Nbin = 5
            CALL MBrA_AddBranch(KF,Nbin,WTmax,'MBrA: next branch$')
         ENDIF
      ENDDO
*----------------------------------------------------------------------
      CALL  BornV_Initialize( m_xpar)
      CALL KarLud_Initialize(m_xpar,xcru_karl)
      CALL KarFin_Initialize(m_xpar)
      CALL   QED3_Initialize(m_xpar)
      IF(m_KeyGPS .NE. 0 ) THEN
         CALL GPS_Initialize
         CALL GPS_Setb2
         IF( m_IsBeamPolarized .EQ. 1) THEN
            CALL KK2f_WignerIni(m_KFini,m_CMSene,m_PolBeam1,m_PolBeam2, PolBeam1,PolBeam2) 
            WRITE(m_out,bxope)
            WRITE(m_out,bxtxt) 'KK2f: Beam polarizations Wigner rotated '
            WRITE(m_out,bxl1f) PolBeam1(1), 'PolBeam1(1)     ','Pol1x ','=='
            WRITE(m_out,bxl1f) PolBeam1(2), 'PolBeam1(2)     ','Pol1y ','=='
            WRITE(m_out,bxl1f) PolBeam1(3), 'PolBeam1(3)     ','Pol1z ','=='
            WRITE(m_out,bxl1f) PolBeam2(1), 'PolBeam2(1)     ','Pol2x ','=='
            WRITE(m_out,bxl1f) PolBeam2(2), 'PolBeam2(2)     ','Pol2y ','=='
            WRITE(m_out,bxl1f) PolBeam2(3), 'PolBeam2(3)     ','Pol2z ','=='
            WRITE(m_out,bxclo)
         ENDIF
         CALL GPS_SetPolBeams(PolBeam1,PolBeam2)
      ENDIF
*----------------------------------------------------------------------
      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) 'KK2f: Initialization '
* Primary normalization in nanobarns
      m_Xcrunb = xcru_karl * BornV_Sig0nb(m_CMSene)
      WRITE(m_out,bxl1g) m_Xcrunb,   'x-crude [nb]       ','Xcrunb','**'
* Note that m_Xborn initialized here is used for KF generation for KeyISR=0
*
* List of properties of generated channels, calculate Xborn list
      CALL MBrA_GetKFlist(Nbranch,KFList)
      CALL MBrA_GetWMList(Nbranch,WMList)
      WRITE(m_out,bxtxt) 'List of final fermions:                '
      DO j=1,Nbranch
         KF = KFList(j)
         Xborn(j)= BornV_Integrated(KF,m_CMSene**2)    !<-- Initialization for tests only
         amferm  = BornV_GetMass(KF)
         MinMas  = BornV_GetAuxPar(KF)
         WRITE(m_out,bxl1i) KF       ,'KF of final fermion','KFfin ','**'
         WRITE(m_out,bxl1g) amferm   ,'mass of final ferm.','amferm','**'
         WRITE(m_out,bxl1g) Xborn(j) ,'Xborn [R]          ','Xborn ','**'
         WRITE(m_out,bxl1g) WMlist(j),'WtMax sampling par.','WtMax ','**'
         WRITE(m_out,bxl1g) MinMas,   'Auxiliary Parameter','AuxPar','**'
      ENDDO
      WRITE(m_out,bxclo)

* set generation parameters
* This initialization is used in KeyISR=0 case !!!
      CALL MBrA_SetXSList(Xborn)
*----------------------------------------------------------------------
      CALL TauPair_Initialize(m_xpar)
*----------------------------------------------------------------------
      IF( m_KeyFSR .NE. 0) CALL pyGive("MSTJ(41)=1;")
      CALL PyGive("MSTU(21)=1;"); ! no stop due to errors !!!!
*----------------------------------------------------------------------
      m_nevgen=0
*----------------------------------------------------------------------
***** CALL GLK_ListPrint(6)     ! debug
*----------------------------------------------------------------------
      END                       !!! KK2f_Initialize !!!


      SUBROUTINE KK2f_WignerIni(KFbeam,CMSene,PolBeam1,PolBeam2, Polar1,Polar2) 
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   Purpose: Wigner rotation for spin polarizations vectors of beams.             //
*//                                                                                 //
*//   For the moment we assume that beam polarization vectors are defined           //
*//   in beam particle rest frames which are reached from CSM by simple             //
*//   z-boost without any rotation. Note that first beam is paralel to z-axis.      //
*//                                                                                 //
*//   Notes:                                                                        //
*//   - Initialization of class BornV and GPS required                              //
*//   - Externals from GPS and Kinlib classes                                       //
*//   - In order to facilitate external tests, KK2f.h is not included (temporarily) //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
*
*-------------------------------------------------------------------------------------
      INTEGER   KFbeam
      DOUBLE PRECISION     CMSene
      DOUBLE PRECISION     BornV_GetMass, Mbeam
      DOUBLE PRECISION     p1(4),p2(4)
      DOUBLE PRECISION     PolBeam1(4), PolBeam2(4), Polar1(4),Polar2(4)
      INTEGER   i,j,k
      DOUBLE PRECISION     pi,thet,phi,exe
*-------------------------------------------------------------------------------------
      WRITE(*,*) '=====================: KK2f_WignerIni: ============================'

      Mbeam   = BornV_GetMass(KFbeam)
      WRITE(*,*) 'Mbeam= ',Mbeam,CMSene

      CALL KinLib_DefPair(CMSene,Mbeam,Mbeam,p1,p2)

* Initialize GPS tralor
      CALL GPS_TralorPrepare(p1,1)
      CALL GPS_TralorPrepare(p2,2)

      WRITE(*,*) 'KK2f_WignerIni:================beam rest frame====================='
      CALL KinLib_VecPrint(6 ,'PolBeam1',PolBeam1)
      CALL KinLib_VecPrint(6 ,'PolBeam2',PolBeam2)

*/////////////////////////////////////////////////////////////////////////////////////
*//   These two transformations from beam particle frames to CMS define where       //
*//   'machine spin polarization vectors' are primarily defined.                    //
*//   In the present version the transformations are simple boosts along z-axis.    //
*//   To be changed apprioprietly, if we adopt another convention!!!!               //
*/////////////////////////////////////////////////////////////////////////////////////
      exe   = (p1(4)+p1(3))/Mbeam
      CALL KinLib_Boost(3,     exe,PolBeam1,PolBeam1) ! beam1_rest --> CMS
      CALL KinLib_Boost(3, 1d0/exe,PolBeam2,PolBeam2) ! beam2_rest --> CMS
*/////////////////////////////////////////////////////////////////////////////////////

      WRITE(*,*) 'KK2f_WignerIni:=================CMS================================='
      CALL KinLib_VecPrint(6 ,'PolBeam1',PolBeam1)
      CALL KinLib_VecPrint(6 ,'PolBeam2',PolBeam2)

*/////////////////////////////////////////////////////////////////////////////////////
*//   These transformations assures that for calculations with KS spinors we use    //
*//   beam spin polarization vectors in the proper GPS frames of the beam particles //
*/////////////////////////////////////////////////////////////////////////////////////
      CALL GPS_TralorUnDo(   1,PolBeam1,Polar1)     ! CMS --> beam1_rest GPS
      CALL GPS_TralorUnDo(   2,PolBeam2,Polar2)     ! CMS --> beam2_rest GPS

      WRITE(*,*) 'KK2f_WignerIni:=================GPS================================='
      CALL KinLib_VecPrint(6 ,'Polar1  ',Polar1)
      CALL KinLib_VecPrint(6 ,'Polar2  ',Polar2)

      Polar1(4)=1d0             ! in order to get rid of rounding errors
      Polar2(4)=1d0             ! in order to get rid of rounding errors
      END


      SUBROUTINE KK2f_Make
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//                                                                                 //
*//   Make one event ISR + FSR                                                      //
*//                                                                                 //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INCLUDE 'BXformat.h'
*
      DOUBLE PRECISION  xxf(4)
      REAL              rvec(10)
      INTEGER           i,j,k
      INTEGER           LevPri,Ie1Pri,Ie2Pri
      INTEGER           KFfin,NevCru
      INTEGER           TauIsInitialized
      INTEGER           m_WriteLHE
      DOUBLE PRECISION  wt_fsr,wt_isr,WtScaled,XCruNb
      DOUBLE PRECISION  CMSE, vv, svar1, Exe, SvarQ
      DOUBLE PRECISION  charg2,amfi1,amfi2
      DOUBLE PRECISION  BornV_GetMass,BornV_GetCharge,BornV_GetAuxPar
      DOUBLE PRECISION  BornV_Differential
      DOUBLE PRECISION  WtSetNew(200), WtBest, WtBest1, WtBest2
      DOUBLE PRECISION  rn
      DOUBLE PRECISION  MminCEEX, BornV_Sig0nb
*-----------------------------------------------------------
      m_nevgen   = m_nevgen +1
      m_ypar( 9) = m_nevgen
  100 CONTINUE
      m_WtCrud  = 1d0
      LevPri =m_xpar( 5)  !PrintOut Level 0,1,2,3
      Ie1Pri =m_xpar( 6)  !PrintOut Start point
      Ie2Pri =m_xpar( 7)  !PrintOut End   point
      m_WriteLHE = m_xpar(100)  
*     WtSet reseting to zero
      DO j=1,m_lenwt
         m_WtSet(j)  =0d0
         m_WtList(j) =0d0
      ENDDO
* =============================================
*                   ISR
* =============================================
* define p1,2, xxf, xf1,2 and photons
* note that xf1,xf2 are not used anymore
* Different Final state masses supported (for W pair production)
      CALL KarLud_Make(xxf,wt_ISR)
      m_WtCrud  = m_WtCrud*wt_ISR

* Actual KFcode of final fermion
      CALL MBrA_GetKF(KFfin)

*   Control printout
      IF(LevPri .GE. 2) CALL KarLud_Print(m_nevgen,Ie1Pri,Ie2Pri)
* =============================================
*                   FSR
* =============================================
* Generate FSR photons and final fermion momenta.
* xxf defines frame (Z-frame) of final fermions + FSR photons.
* (Fermion momenta from KarLud_Make are not used, even for pure ISR)
      IF(m_WtCrud .NE. 0d0) THEN
         charg2 =BornV_GetCharge(KFfin)**2
         amfi1  =BornV_GetMass(KFfin)
         amfi2  =BornV_GetMass(KFfin)
         CALL KarFin_Make(xxf,amfi1,amfi2,charg2,wt_FSR)
         m_WtCrud  = m_WtCrud*wt_FSR
      ENDIF
*   Control printout
      IF(LevPri .GE. 2) CALL KarFin_Print(m_nevgen,Ie1Pri,Ie2Pri)
* ==============================================================================
* Merging photons in CMS frame. The common list from merging
* is used in GPS package. It is not used in QED3. Merge is BEFORE ZBoostAll.
* ==============================================================================
      IF(m_WtCrud .NE. 0d0)  CALL KK2f_Merge
      IF(m_WtCrud .NE. 0d0)  CALL KK2f_MakePhelRand         !<-- Generate photon helicities
* Control printout ISR+FSR
      IF(LevPri .GE. 1) CALL KK2f_Print(Ie1Pri,Ie2Pri)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*// All four-momenta are constructed and recorded at this point.                    //
*//                                                                                 //
*// The generated distribution with the weight WtCrud represents the differential   //
*// distribution equal to phase space times all ISR S-factor times FSR S-factors    //
*// times 'Born(s*(1-v),cosheta)'                                                   //
*//                                                                                 //
*// The 'Born' angular distribution in xxf frame (in terms of Euler angles) is in   //
*// present version exactly flat (generated in KarFin).                             //
*// The distribution m_BornCru represents the above  'Born(s*(1-v),cosheta)'.       //
*// It is remodeled later on during calculation of the QED mat. elem. in QED3.      //
*//                                                                                 //
*// Memorizing m_BornCru makes sense because we  may freely manipulate in QED3      //
*// with input parameters like MZ, couplings etc. (recalculate weights for event)   //
*// This trick is not working for GPS where  BornCru is calculated internaly        //
*//                                                                                 //
*// The weight from QED3/GPS is not modifying Z position any more, see also KarLud  //
*/////////////////////////////////////////////////////////////////////////////////////
* =============================================================
*                    Model weight
* =============================================================
      m_WtMain  =m_WtCrud
      IF(m_WtCrud .NE. 0d0) THEN
         CALL BornV_GetVV(vv)
         CALL KarLud_GetXXXene(CMSE)            !<-- It is this realy OK, see above
         svar1     = CMSE**2*(1d0-vv)
         m_BornCru = 4d0/3d0*BornV_Differential(0,KFfin,svar1,0d0,0d0,0d0,0d0,0d0)
         CALL QED3_Make                         !<-- EEX
* WtSet from QED3 is filled in the range (1:200)
         CALL QED3_GetWtSet(WtBest,m_WtSet)     !<-- WtBest initialized
* New CEEX matrix element is now default for leptons and for quarks.
* Its use is controled by auxiliary parameter MinMassCEEX variable [GeV]
* CEEX is calculated twice, with ISR*FSR interference OFF and ON
         CALL  KarFin_GetSvarQ(SvarQ)
         MminCEEX = BornV_GetAuxPar(KFfin)
         IF( m_KeyGPS.NE.0 .AND. SvarQ.GT.MminCEEX**2 ) THEN
            CALL GPS_ZeroWtSet                 !<-- zeroing GPS weights
            CALL GPS_SetKeyINT( 0)             !<-- ISR*FSR interfer. OFF
            CALL GPS_Make                      !<-- CEEX    interfer. OFF
            IF( m_KeyINT .NE. 0 ) THEN
               CALL GPS_SetKeyINT( m_KeyINT)   !<-- ISR*FSR interfer. ON
               CALL GPS_Make                   !<-- CEEX    interfer. ON
            ENDIF
            CALL GPS_GetWtSet(WtBest,WtSetNew) !<-- WtBest redefined !!!
* m_WtSet appended with WtSetNew
            DO j=1,200
               m_WtSet(j+200) = WtSetNew(j)
            ENDDO
         ENDIF
         m_WtMain  = m_WtMain*WtBest
      ENDIF
*   Control printout
      IF(LevPri .GE. 2) THEN
         CALL  QED3_wtPrint(' KK2f ',m_out,m_nevgen,Ie1Pri,Ie2Pri,wt_ISR,wt_FSR,WtBest,m_WtSet) !
      ENDIF
*///////////////////////////////////////////////////////////////
*//                                                           //
*//     Optional rejection according to principal weight      //
*//                                                           //
*///////////////////////////////////////////////////////////////
      IF(m_KeyWgt .EQ. 0) THEN              !!! CONSTANT-WEIGHT events
         CALL PseuMar_MakeVec(rvec,1)
         rn = rvec(1)
         CALL KarLud_CrudeInfo(XCruNb,NevCru)
*        Emulation of the internal rejection loop in Bstra
         DO j=1,NevCru
            CALL GLK_Mfill(m_idgen, XCruNb*m_WTmax, rn)
         ENDDO
         CALL MBrA_Fill(m_WtMain   ,rn)
         WtScaled = m_WtMain/m_WTmax
         IF( WtScaled .GT. 1d0) THEN
            m_WtMain = WtScaled
         ELSE
            m_WtMain = 1.d0
         ENDIF
         IF(rn .GT. WtScaled) GOTO 100
         m_WtCrud=1d0
* collection of the weights for the advanced user
         DO j=1,m_lenwt
            m_WtList(j) = m_WtSet(j)/WtBest ! Division by zero impossible due to rejection
         ENDDO
      ELSE                                  !!! VARIABLE-WEIGHT events
         CALL KarLud_CrudeInfo(XCruNb,NevCru)
         CALL GLK_Mfill(m_idgen   , XCruNb, 0d0)
         CALL MBrA_Fill(m_WtMain,  0d0)
* collection of the weights for the advanced user
         DO j=1,m_lenwt
            m_WtList(j) = m_WtSet(j)*m_WtCrud
         ENDDO
      ENDIF
* =============================================================
* =============================================================
* Some test
      CALL GLK_Mfill(m_Idyfs+40, 1d0*m_nphot,   rn)
* =============================================================
      IF(m_KeyWgt .EQ. 0) THEN
* wt_ISR,2  weights are reset to one
         wt_ISR=1d0
         wt_FSR=1d0
      ENDIF
      m_ypar(1)=m_WtMain        ! Main Total Weight  ! debug
      m_ypar(2)=m_WtCrud        ! Total Crude weight ! debug
      m_ypar(3)=wt_ISR          ! reintroduction     ! debug
      m_ypar(4)=wt_FSR          !                      debug
*/////////////////////////////////////////////////////////////////////////////////////
*//         Fill standard HEP and/or LUND common blocks and HADRONIZE               //
*/////////////////////////////////////////////////////////////////////////////////////
      CALL KarLud_GetExe(Exe)
      CALL KK2f_ZBoostAll(  exe)
      CALL KarLud_ZBoostAll(exe)
      CALL KarFin_ZBoostAll(exe)
*
      IF( m_WtMain .NE. 0d0) CALL HepEvt_Fill
      IF( m_WtMain .NE. 0d0 .AND. m_KeyHad .EQ. 1 ) THEN
         CALL HepEvt_Hadronize(m_HadMin)   ! <-- PYexec and RRes (Photos)
      ENDIF
* =================================================================
* Tau decays using tauola, all spin effects implemented!
      IF(m_WtCrud .NE. 0d0) THEN
         IF( ABS(KFfin) .EQ. 15) THEN
            CALL TauPair_GetIsInitialized(TauIsInitialized)
            IF( TauIsInitialized .NE. 0) THEN
               IF(m_KeyGPS .EQ. 0 ) THEN
                  WRITE(m_out,*) ' #### STOP in KK2f_Make: for tau decays GPS not activated !!!'
                  WRITE(    *,*) ' #### STOP in KK2f_Make: for tau decays GPS not activated !!!'
                  STOP
               ENDIF
               CALL TauPair_Make1        ! tau decay generation
               CALL TauPair_ImprintSpin  ! introduction of spin effects by rejection
               CALL TauPair_Make2        ! book-keeping, Photos, and pyhepc(2) HepEvt-->Pythia
            ENDIF
         ENDIF
      ENDIF

      IF(m_WriteLHE .EQ. 1) THEN
         CALL LHEF_Fill(m_alfinv, m_CMSene)
      ENDIF
         
      END                       !!! end of KK2f_Make !!!
      
      
      SUBROUTINE KK2f_ZBoostAll(exe)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   performs z-boost on all momenta of the event                            //
*//   this z-boost corresponds to beamstrahlung or beamspread                 //
*//   and is done at the very end of generation, after m.el. calculation      //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION  exe
      INTEGER           j,k
      DOUBLE PRECISION  ph(4)
*
      IF( exe.EQ. 1d0) RETURN
      CALL KinLib_Boost(3,exe,m_p1,m_p1)
      CALL KinLib_Boost(3,exe,m_p2,m_p2)
      CALL KinLib_Boost(3,exe,m_q1,m_q1)
      CALL KinLib_Boost(3,exe,m_q2,m_q2)
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

      SUBROUTINE KK2f_Finalize
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   Final bookkeping and printouts                                                //
*//   Normalization available through getter KK2f_GetXsecMC(xSecPb, xErrPb)         //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'BXformat.h'
      INCLUDE 'KK2f.h'
*
      INTEGER     LevelPrint
      DOUBLE PRECISION       errela,averwt
      DOUBLE PRECISION       BornV_Integrated
      DOUBLE PRECISION       BornV_Sig0nb
      DOUBLE PRECISION       xkarl,error,erkarl,erabs
      DOUBLE PRECISION       xsmc,erel
      DOUBLE PRECISION       sig0pb,xBorPb
      DOUBLE PRECISION       avmlt,ermlt,upmlt
      DOUBLE PRECISION       WTsup, AvUnd, AvOve
      DOUBLE PRECISION       ROverf, RUnder
*-------------------------------------------------------------------
      LevelPrint=2
      sig0pb =  BornV_Sig0nb(m_CMSene)*1000

* Born xsec, just for orientation where we are...
      xBorPb =  BornV_Integrated(0,m_CMSene**2) * sig0pb

* Crude from karLud + printout
      CALL KarLud_Finalize(LevelPrint,xkarl,error)
      erkarl = 0d0

* Printout from Karfin
      CALL KarFin_Finalize(LevelPrint)

* Average of the main weight
      CALL GLK_MgetAve(m_idbra, AverWt, ErRela, WtSup)

* main X-section = crude * <WtMain>
      xsmc   =  xkarl*averwt
      erel   =  SQRT(erkarl**2+errela**2)
      erabs  =  xsmc*erel
*============================================================
* The final cross section exported to user
* through getter KK2f_GetXsecMC(xSecPb, xErrPb)
      m_xSecPb =  xsmc*sig0pb     ! MC xsection in picobarns
      m_xErrPb =  m_xSecPb*erel   ! Its error   in picobarns
*============================================================

* no printout for LevelPrint =1
      IF(LevelPrint .LE. 1) RETURN
*
* print photon multiplicity distribution
      CALL  GLK_Mprint(m_Idyfs+40)
*
      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) '  KK2f_Finalize  printouts '
      WRITE(m_out,bxl1f) m_cmsene,   'cms energy total   ','cmsene','a0'
      WRITE(m_out,bxl1i) m_nevgen,   'total no of events ','nevgen','a1'
      WRITE(m_out,bxtxt) '** principal info on x-section **'
      WRITE(m_out,bxl2f) xsmc,erabs, 'xs_tot MC R-units  ','xsmc  ','a1'
      WRITE(m_out,bxl1f) m_xSecPb,   'xs_tot    picob.   ','xSecPb','a3'
      WRITE(m_out,bxl1f) m_xErrPb,   'error     picob.   ','xErrPb','a4'
      WRITE(m_out,bxl1f) erel,       'relative error     ','erel  ','a5'
      WRITE(m_out,bxl1f) WTsup ,    'WTsup, largest WT  ','WTsup ','a10'
      WRITE(m_out,bxtxt) '** some auxiliary info **'
      WRITE(m_out,bxl1f) xBorPb,     'xs_born   picobarns','xborn','a11'
      WRITE(m_out,bxl1f) sig0pb,     'sig0 unit picobarns','sig0 ','a12'
      CALL GLK_MgetAve(m_Idyfs+40, avmlt, ermlt, upmlt)
      WRITE(m_out,bxl1f) avmlt,      'Raw phot. multipl. ','     ','==='
      WRITE(m_out,bxl1f) upmlt,      'Highest phot. mult.','     ','==='
      WRITE(m_out,bxtxt) '  End of KK2f  Finalize  '
      WRITE(m_out,bxclo)

* Print more on the main weight
      CALL MBrA_Print0
* Print even more on the weight in each branch!
      CALL MBrA_Print1
*--------------------------------------------------------------------------------
      WRITE(77,'(a)')  '</LesHouchesEvents>'
      CLOSE(77)
      
      CALL TauPair_Finalize
      END



      SUBROUTINE  KK2f_DsigOverDtau(mout,Rho)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   !!! This routine is only for documentation and testing purposes !!!           //
*//                                                                                 //
*//   The distribution DsigOverDtau corresponding to WtCrud                         //
*//   Normalized with respect to dTau = Lorenz invariant phase space                //
*//                                                                                 //
*//   Photons attributed to ISR or FSR as in MC and interference ISR/FSR absent.    //
*//                                                                                 //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION      Rho
      INTEGER    mout
*
      DOUBLE PRECISION     pi
      PARAMETER (pi =3.1415926535897932d0)
      INTEGER    i,j,k
      DOUBLE PRECISION      PP(4),PX(4),PQ(4),Pho(4)
      DOUBLE PRECISION      SfacIniProd, SfacIni
      DOUBLE PRECISION      SfacFinProd, SfacFin
      DOUBLE PRECISION      kp1, kp2, kq1, kq2
      DOUBLE PRECISION      alfQED, Jcur(4)
      DOUBLE PRECISION      svar, svarX, svarQ, Massf, Mas1, Mas2, Mbeam
      DOUBLE PRECISION      ChaIni, ChaFin, xBorn, betaf, fLLux
      DOUBLE PRECISION      vv, vx,vq
      INTEGER    KFfin
      DOUBLE PRECISION      BornV_GetMass, BornV_GetCharge, BornV_Simple
      DOUBLE PRECISION      YFSkonIni, YFS_IRini, YFSkonFin, YFS_IRfin, YFS_isr, YFS_fsr, Yisr, Yfsr
      DOUBLE PRECISION      BVR_SForFac
      DOUBLE PRECISION      alfpi, alfpini, alfpfin, e_QED
      DOUBLE PRECISION      SfaSpi
      DOUBLE COMPLEX  GPS_soft
      INTEGER    nout
*-----------------------------------------------
      INTEGER   Icont
      SAVE      Icont
      DATA      Icont /0/
*-----------------------------------------------
      IF(Icont .GE. 500 )  RETURN
      nout = mout
      alfQED  = 1d0/m_alfinv
      e_QED  = DSQRT( 4d0*pi*alfQED)
* Actual KFcode of final fermion
      CALL MBrA_GetKF(KFfin)
      Massf  = BornV_GetMass(KFfin)
      Mas1  = Massf
      Mas2  = Massf
      Mbeam = BornV_GetMass(m_KFini)
* Final/initial state charges, (-1 for electron)
      ChaFin = BornV_GetCharge(KFfin)
      ChaIni = BornV_GetCharge(m_KFini)
      alfpi   = alfQED/pi
      alfpini  = alfpi*ChaIni**2
      alfpfin  = alfpi*ChaFin**2
* Product of ISR factors
      DO k=1,4
         PP(k) = m_p1(k) +m_p2(k)
         PX(k) = m_p1(k) +m_p2(k)
         PQ(k) = m_q1(k) +m_q2(k)
      ENDDO
      svar  = PP(4)*PP(4) -PP(3)*PP(3) -PP(2)*PP(2) -PP(1)*PP(1)
      IF( svar .LE. (2*Massf)**2 ) GOTO 900
*   //////////////////////////////////////////
*   //            S-factors                 //
*   //////////////////////////////////////////
      SfacIniProd = 1d0
      DO i=1,m_nphot
         IF( m_isr(i) .EQ. 1 ) THEN   ! select ISR
            DO k=1,4
               Pho(k) = m_sphot(i,k)
               PX(k)  = PX(k) -Pho(k)
            ENDDO
            kp1 = m_p1(4)*Pho(4)-m_p1(3)*Pho(3)-m_p1(2)*Pho(2)-m_p1(1)*Pho(1)
            kp2 = m_p2(4)*Pho(4)-m_p2(3)*Pho(3)-m_p2(2)*Pho(2)-m_p2(1)*Pho(1)
            DO k=1,4
               Jcur(k)  = m_p1(k)/kp1 -m_p2(k)/kp2
            ENDDO
            SfacIni = -(ChaIni**2 *alfQED/(4*pi**2))*(Jcur(4)**2 -Jcur(3)**2-Jcur(2)**2-Jcur(1)**2)
            SfacIniProd = SfacIniProd *SfacIni
*///////////////////////////
***            SfaSpi = 1/2d0 *1d0/(2d0*pi)**3  *CDABS( e_QED *GPS_soft(1,Pho,m_p1,m_p2) )**2
***            SfaSpi = 2d0*SfaSpi       !! factor 2 for two +- photon helicities
***            WRITE(*,'(a,6e20.14)') '/// SfacIni,SfaSpi = ', SfacIni,SfaSpi/SfacIni
*///////////////////////////
         ENDIF
      ENDDO
* Product of FSR factors
      SfacFinProd = 1d0
      DO i=1,m_nphot
         IF( m_isr(i) .EQ. 0 ) THEN   ! select FSR
            DO k=1,4
               Pho(k) = m_sphot(i,k)
            ENDDO
            kq1 = m_q1(4)*Pho(4)-m_q1(3)*Pho(3)-m_q1(2)*Pho(2)-m_q1(1)*Pho(1)
            kq2 = m_q2(4)*Pho(4)-m_q2(3)*Pho(3)-m_q2(2)*Pho(2)-m_q2(1)*Pho(1)
            DO k=1,4
               Jcur(k)  = m_q1(k)/kq1 -m_q2(k)/kq2
            ENDDO
            SfacFin = -(ChaFin**2 *alfQED/(4*pi**2))*(Jcur(4)**2 -Jcur(3)**2-Jcur(2)**2-Jcur(1)**2)
            SfacFinProd = SfacFinProd *SfacFin
*///////////////////////////
***         SfaSpi =1/2d0 *1d0/(2d0*pi)**3 *(ChaFin*e_QED *CDABS(GPS_soft(1,Pho,m_q1,m_q2)))**2
***         SfaSpi = 2d0*SfaSpi        !! factor 2 for two +- photon helicities ?
***         WRITE(*,'(a,6e20.14)') '/// SfacFin,SfaSpi = ', SfacFin, SfaSpi/SfacFin
*///////////////////////////
         ENDIF
      ENDDO
      svarX = PX(4)*PX(4) -PX(3)*PX(3) -PX(2)*PX(2) -PX(1)*PX(1)
      svarQ = PQ(4)*PQ(4) -PQ(3)*PQ(3) -PQ(2)*PQ(2) -PQ(1)*PQ(1)
      CALL BornV_GetVV(vv)
      vx    = 1d0 -svarX/svar
      vq    = 1d0 -svarQ/svar
      IF( svarQ .LE. (2*Massf)**2 ) GOTO 900
*   //////////////////////////////////////////
*   //              Born                    //
*   //////////////////////////////////////////
      xBorn = BornV_Simple( m_KFini,KFfin,svarX, 0d0  ) *(svar/svarX) !!<- Born(svarX)*svar
      xBorn = xBorn/(4*pi)
*   //////////////////////////////////////////
*   //              FormFactors             //
*   //////////////////////////////////////////
* Finaly formfactors, provided common IR sphere in CMS
* Equivalent alternatives:  Yisr==YFS_isr  and  Yfsr==YFS_fsr
* YFSkon imported from BornV and KarFin(piatek), unused there, not included in WtCrude!
* YFS_IR is included in WtCrude (Karfin) and normalization (Karlud, BornV).
      CALL  BornV_GetYFS_IR( YFS_IRini )
      CALL  BornV_GetYFSkon( YFSkonIni )
      YFS_isr =  YFS_IRini*YFSkonIni
      CALL KarFin_GetYFS_IR( YFS_IRfin )
      CALL KarFin_GetYFSkon( YFSkonFin )
      YFS_fsr =  YFS_IRfin*YFSkonFin
      Yisr= BVR_SForFac(alfpini, m_p1,Mbeam, m_p2,Mbeam, m_Emin, m_MasPhot)
      Yfsr= BVR_SForFac(alfpfin, m_q1,Mas1,  m_q2,Mas2,  m_Emin, m_MasPhot)
*   //////////////////////////////////////////
*   //              Other                   //
*   //////////////////////////////////////////
      betaf = DSQRT( 1d0 - 4*Massf**2/svarQ )
      fLLux = (svarX/svarQ)
*   //////////////////////////////////////////
*   //              Total                   //
*   //////////////////////////////////////////
      Rho = SfacIniProd            !! product of ISR formfactors
     $     *SfacFinProd            !! product of FSR formfactors
     $     *xBorn                  !! Born x-section dependend on vv
     $     *2d0/betaf              !! 2-body phase space factor (inverse of it)
     $     *fLLux                  !! LL 'flux-factor'
     $     *Yisr                   !! YFS full formfactor, ISR part
     $     *Yfsr                   !! YFS full formfactor, FSR part
*/////////////////////////////////////////////////////////////////////////////////
*//                            X-Checks                                         //
*/////////////////////////////////////////////////////////////////////////////////
**      IF(vq  .LE. 0.3d0)  RETURN
**      IF(vq  .GE. 0.9d0)  RETURN
      WRITE(nout,'(a,5g20.12)') '////////////// KK2f_DsigOverDtau ///////////////'
      WRITE(nout,'(a,5g20.12)') '/// SfacIniProd*SfacFinProd  = ', SfacIniProd*SfacFinProd
      WRITE(nout,'(a,5g20.12)') '///   vx,vq = ',vx,vq, vv/vx, betaf
      WRITE(nout,'(a,5g20.12)') '///   Yisr  = ',Yisr,YFS_isr,Yisr/YFS_isr
      WRITE(nout,'(a,5g20.12)') '///   Yfsr  = ',Yfsr,YFS_fsr,Yfsr/YFS_fsr
      WRITE(nout,'(a,5g20.12)') '///   Rho   = ',Rho
      WRITE(nout,'(a,5g20.12)') '//////////////////////////////////////////////////'
*/////////////////////////////////////////////////////////////////////////////////
      Icont =Icont +1
      RETURN
 900  CONTINUE
      Rho = 0d0
      END                       !!! KK2f_DsigOverDtau !!!

      SUBROUTINE  KK2f_Merge
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//  Merging ISR and FSR photon momenta.                                            //
*//  Photons are ordered according to energy (in CMS)                               //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER nphox,nphoy
      DOUBLE PRECISION   xphot(m_phmax,4),yphot(m_phmax,4),enex,eney
      INTEGER i,k,i1,i2
*-----------------------------------------------------------------------
      CALL KarLud_GetBeams(    m_p1, m_p2)
      CALL KarFin_GetFermions( m_q1, m_q2)
*
      CALL KarLud_GetPhotons(nphox,xphot)
      CALL KarFin_GetPhotons(nphoy,yphot)
*
      m_nphot  = nphox +nphoy
      i1=1
      i2=1
      DO i=1,m_nphot
         enex = 0d0
         eney = 0d0
* saveguard against Alex Read and Tiziano Camporesi effect (bug in old BHLUMI)
         IF(i1 .LE. nphox) enex = xphot(i1,4)
         IF(i2 .LE. nphoy) eney = yphot(i2,4)
         IF(enex .GT. eney) THEN
            DO k=1,4
               m_sphot( i,k) = xphot(i1,k)
            ENDDO
            m_isr(i) = 1        ! ISR origin
            i1=i1+1    
         ELSE
            DO k=1,4
               m_sphot( i,k) = yphot(i2,k) ! FSR
            ENDDO
            m_isr(i) = 0        ! FSR origin
            i2=i2+1    
         ENDIF
      ENDDO
      END


      SUBROUTINE KK2f_MakePhelRand
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   Generate photon helicities randomly                                     //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER   i
      REAL                 rvec(m_phmax)
*
      IF(m_nphot .LE. 0) RETURN
      CALL PseuMar_MakeVec(rvec,m_nphot)
      DO i=1,m_nphot
         IF( rvec(i) .GT. 0.5d0 ) THEN
            m_Phel(i)=0
         ELSE
            m_Phel(i)=1
         ENDIF
      ENDDO
      END


      SUBROUTINE  KK2f_Print(ie1,ie2)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//  Prints out four momenta of Beams and Final state particles,                    //
*//  and the serial number of event m_nevgen on unit m_out                          //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION   p1(4),p2(4),q1(4),q2(4),sphum(4)
      CHARACTER*8 txt
      DOUBLE PRECISION    sum(4),amf1,amf2,ams,amph
      INTEGER  i,k,KFfin,ie1,ie2
*-----------------------------------------------------------------
* Actual KFcode of final fermion
      CALL MBrA_GetKF(KFfin)
* Fermion momenta
      CALL KarLud_GetBeams(p1,p2)
      CALL KarFin_GetFermions(q1,q2)
*
      txt = ' KK2f '
      IF( (m_nevgen .GE. ie1) .AND. (m_nevgen .LE. ie2) ) THEN
         CALL  KK2f_Print1(m_out)
      ENDIF
      END


      SUBROUTINE  KK2f_Print1(nout)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//  Prints out four momenta of Beams and Final state particles,                    //
*//  and the serial number of event m_nevgen on unit nout                           //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      INTEGER     nout
      CHARACTER*8 txt
      DOUBLE PRECISION    sum(4),amf1,amf2,ams,amph
      INTEGER  i,k,KFfin
*-----------------------------------------------------------------
* Actual KFcode of final fermion
      CALL MBrA_GetKF(KFfin)
*
      txt = ' KK2f '
      WRITE(nout,*) '================== ',txt,' ======================>',m_nevgen
*     
      amf1 = m_p1(4)**2-m_p1(3)**2-m_p1(2)**2-m_p1(1)**2
      amf1 = sqrt(abs(amf1))
      amf2 = m_p2(4)**2-m_p2(3)**2-m_p2(2)**2-m_p2(1)**2
      amf2 = sqrt(abs(amf2))
      WRITE(nout,3100) 'm_p1',(  m_p1(  k),k=1,4),amf1
      WRITE(nout,3100) 'm_p2',(  m_p2(  k),k=1,4),amf2
*     
      amf1 = m_q1(4)**2-m_q1(3)**2-m_q1(2)**2-m_q1(1)**2
      amf1 = sqrt(abs(amf1))
      amf2 = m_q2(4)**2-m_q2(3)**2-m_q2(2)**2-m_q2(1)**2
      amf2 = sqrt(abs(amf2))
      WRITE(nout,3100) 'm_q1',(  m_q1(  k),k=1,4),amf1,KFfin
      WRITE(nout,3100) 'm_q2',(  m_q2(  k),k=1,4),amf2,KFfin
*     
      DO i=1,m_nphot
         amph = m_sphot(i,4)**2-m_sphot(i,3)**2 -m_sphot(i,2)**2-m_sphot(i,1)**2
         amph = sqrt(abs(amph))
         WRITE(nout,3100) 'pho',(m_sphot(i,k),k=1,4),amph
      ENDDO
      DO k=1,4
         sum(k)=m_q1(k)+m_q2(k)
      ENDDO
      DO i=1,m_nphot
         DO k=1,4
            sum(k)=sum(k)+m_sphot(i,k)
         ENDDO
      ENDDO
      ams = sum(4)**2-sum(3)**2-sum(2)**2-sum(1)**2
      ams = sqrt(abs(ams))
      WRITE(nout,3100) 'sum',(  sum(  k),k=1,4),ams
 3100 FORMAT(1x,a3,1x,5f20.14,i5)
      END


      SUBROUTINE KK2f_GetOneX(j,x)
*/////////////////////////////////////////////////////////////////////////////////////
*//   obsolete                                                                      //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION  x
      INTEGER j
*---------------------------------------------------------------
      x = m_xpar(j)
      END   ! KK2f_GetOneX

      SUBROUTINE KK2f_GetOneY(j,y)
*/////////////////////////////////////////////////////////////////////////////////////
*//   obsolete                                                                      //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION  y
      INTEGER j
*---------------------------------------------------------------
      y = m_ypar(j)
      END   ! KK2f_GetOneY


      SUBROUTINE KK2f_SetOneY(j,y)
*/////////////////////////////////////////////////////////////////////////////////////
*//   obsolete                                                                      //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION  y
      INTEGER j
*---------------------------------------------------------------
      m_ypar(j) =y
      END   ! KK2f_GetOneY


      SUBROUTINE KK2f_GetWt(WtMain,WtCrud)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Main weights                                                                  //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION    WtMain,WtCrud
      WtMain = m_WtMain  ! the best total weight
      WtCrud = m_WtCrud  ! Crude weight (helps to avoid bad events)
      END ! KK2f_GetWt


      SUBROUTINE KK2f_GetWtCrud(WtCrud)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Main weights                                                                  //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION    WtCrud
      WtCrud = m_WtCrud  ! Crude weight (helps to avoid bad events)
      END ! KK2f_GetWtCrud


      SUBROUTINE KK2f_GetWtAll(WtMain,WtCrud,WtSet)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Weights ALL                                                                   //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      INTEGER  j
      DOUBLE PRECISION    WtMain,WtCrud,WtSet(*)
      DOUBLE PRECISION    WtBest
*--------------------------------------------------------------
      WtMain = m_WtMain  ! the best total weight
      WtCrud = m_WtCrud  ! Crude weight (helps to avoid bad events)
      DO j=1,m_lenwt
         WtSet(j) = m_WtSet(j)
      ENDDO
      END ! KK2f_GetWtAll

      SUBROUTINE KK2f_GetWtList(WtMain,WtList)
*/////////////////////////////////////////////////////////////////////////////////////
*//   ALL Weights, also works for weighted eevents!!!!                              //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      INTEGER  j
      DOUBLE PRECISION    WtMain,WtList(*)
*--------------------------------------------------------------
      WtMain = m_WtMain  ! the best total weight
      DO j=1,m_lenwt
         WtList(j) = m_WtList(j)
      ENDDO
      END ! KK2f_GetWtAll

      SUBROUTINE KK2f_GetWtAlter(j,WtAlter)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Get single alternative weight
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      INTEGER  j
      DOUBLE PRECISION   WtAlter
*--------------------------------------------------------------
      IF(j.GE.0 .AND. j.LE.m_lenwt) THEN
         WtAlter = m_WtList(j)
      ELSE
         WRITE(*,*) "++++  KK2f_GetWtAlter wrong j =",j
         STOP
      ENDIF
      END ! KK2f_GetWtAlter


      SUBROUTINE KK2f_GetPhoton1(iphot,phot)
*///////////////////////////////////////////////////////////////////////////////
*//                                                                           //
*//   get i-th photon momentum                                                //
*//                                                                           //
*///////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      SAVE
      INTEGER iphot
      DOUBLE PRECISION   phot(4)
      INTEGER k
*
      DO k=1,4
         phot(k) = m_sphot(iphot,k)
      ENDDO
      END

      SUBROUTINE KK2f_GetPhotAll(NphAll,PhoAll)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   Get all photons, note that they are ordered in energy                         //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      INTEGER  NphAll
      DOUBLE PRECISION    PhoAll(m_phmax,4) ! Now we have m_phmax=100
      INTEGER  j,k
*------------------
      NphAll = m_nphot
      DO j=1,m_nphot
         DO k=1,4
            PhoAll(j,k) = m_sphot(j,k)
         ENDDO
      ENDDO
      END                       !!! KK2f_GetPhotAll !!!

      SUBROUTINE KK2f_GetNphot(Nphot)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   Get total photon multiplicity                                                 //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      INTEGER  Nphot
*------------------
      Nphot = m_nphot
      END                       !!! KK2f_GetNphot !!!

      SUBROUTINE KK2f_GetIsr(isr)
*/////////////////////////////////////////////////////////////////////////////////////
*//   ISR/FSR markers of all photons                                                //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER  isr(*),j
*--------
      DO j=1,m_nphot
         isr(j) = m_isr(j)
      ENDDO
      END                       !!! KK2f_GetIsr !!!

      SUBROUTINE KK2f_GetPhel(Phel)
*/////////////////////////////////////////////////////////////////////////////////////
*//   ISR/FSR markers of all photons                                                //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER  Phel(*),j
*--------
      DO j=1,m_nphot
         Phel(j) = m_Phel(j)
      ENDDO
      END                       !!! KK2f_GetPhel !!!

      SUBROUTINE KK2f_GetIsBeamPolarized(IsBeamPolarized)
*/////////////////////////////////////////////////////////////////////////////////////
*//   ISR/FSR markers of all photons                                                //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER  IsBeamPolarized
*--------
      IsBeamPolarized = m_IsBeamPolarized
      END                       !!! KK2f_GetIsBeamPolarized !!!


      SUBROUTINE KK2f_GetBornCru(BornCru)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*// Memorizing m_BornCru makes sense because we  may freely manipulate in QED3      //
*// with input parameters like MZ, couplings etc. (recalculate weights for event)   //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION  BornCru
*------------------
      BornCru = m_BornCru
      END

      SUBROUTINE KK2f_GetKeyISR(KeyISR)
*/////////////////////////////////////////////////////////////////////////////////////
*//   ISR switch                                                                    //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER KeyISR
*
      KeyISR = m_KeyISR
      END

      SUBROUTINE KK2f_GetKeyFSR(KeyFSR)
*/////////////////////////////////////////////////////////////////////////////////////
*//   FSR switch                                                                    //
*//   called in BornV                                                               //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER KeyFSR
*
      KeyFSR = m_KeyFSR
      END

      SUBROUTINE KK2f_GetKeyINT(KeyINT)
*/////////////////////////////////////////////////////////////////////////////////////
*//   ISR*FSR interference switch                                                   //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER KeyINT
*
      KeyINT = m_KeyINT
      END

      SUBROUTINE KK2f_GetKeyGPS(KeyGPS)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Get CEEX level switch                                                         //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER KeyGPS
*
      KeyGPS = m_KeyGPS
      END


      SUBROUTINE KK2f_GetKeyWgt(KeyWgt)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Get CEEX level switch                                                         //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER KeyWgt
*
      KeyWgt = m_KeyWgt
      END

      SUBROUTINE KK2f_GetKFini(KFini)
*/////////////////////////////////////////////////////////////////////////////////////
*//   KF of beams                                                                   //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER KFini
*
      KFini = m_KFini
      END

      SUBROUTINE KK2f_GetIdyfs(Idyfs)
*/////////////////////////////////////////////////////////////////////////////////////
*//   pointer for histograms                                                        //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      INTEGER Idyfs
*
      Idyfs = m_Idyfs
      END

      SUBROUTINE KK2f_GetBeams(p1,p2)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Four-momenta of beams                                                         //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION   p1(4),p2(4)
      INTEGER k
*
      DO k=1,4
         p1(k) = m_p1(k)
         p2(k) = m_p2(k)
      ENDDO
      END

      SUBROUTINE KK2f_GetFermions(q1,q2)
*/////////////////////////////////////////////////////////////////////////////////////
*//   final state fermion four-momenta                                              //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION   q1(4),q2(4)
      INTEGER k
*
      DO k=1,4
         q1(k) = m_q1(k)
         q2(k) = m_q2(k)
      ENDDO
      END

      SUBROUTINE KK2f_GetVcut(Vcut)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Technical cuts for consecutive beta's                                         //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
*
      DOUBLE PRECISION   Vcut(3)
      INTEGER k
*
      DO k=1,3
         Vcut(k) = m_Vcut(k)
      ENDDO
      END

      SUBROUTINE KK2f_GetCMSene(CMSene)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Photon minimum energy in LAB system                                           //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   CMSene
*
      CMSene = m_CMSene
      END

      SUBROUTINE KK2f_GetEmin(Emin)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Photon minimum energy in LAB system                                           //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   Emin
*
      Emin = m_Emin
      END

      SUBROUTINE KK2f_SetEmin(Emin)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Photon minimum energy in LAB system                                           //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   Emin
*
      m_Emin = Emin
      END

      SUBROUTINE KK2f_GetMasPhot(MasPhot)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Photon mass for virtual corrections                                           //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   MasPhot
*
      MasPhot = m_MasPhot
      END

      SUBROUTINE KK2f_GetXenph(Xenph)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Enhancement factor in crude photon multiplicity                               //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   Xenph
*
      Xenph = m_Xenph
      END

      SUBROUTINE KK2f_GetPolBeam1(PolBeam1)
*/////////////////////////////////////////////////////////////////////////////////////
*//   FIRST beam spin polarization                                                  //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   PolBeam1(4)
      INTEGER j
*
      DO j=1,4
         PolBeam1(j) = m_PolBeam1(j)
      ENDDO
      END

      SUBROUTINE KK2f_GetPolBeam2(PolBeam2)
*/////////////////////////////////////////////////////////////////////////////////////
*//   SECOND beam spin polarization                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   PolBeam2(4)
      INTEGER j
*
      DO j=1,4
         PolBeam2(j) = m_PolBeam2(j)
      ENDDO
      END

      SUBROUTINE KK2f_GetXsecMC(xSecPb, xErrPb)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Photon minimum energy in LAB system                                           //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   xSecPb, xErrPb
*
      xSecPb = m_xSecPb
      xErrPb = m_xErrPb
      END

      SUBROUTINE KK2f_GetVersion(Version)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Get VERSION number of the program                                             //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   Version
*
      Version = m_Version
      END

      SUBROUTINE KK2f_GetDate(Date)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Get VERSION date of the program                                             //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      CHARACTER*14   Date
*
      Date = m_Date
      END

      SUBROUTINE KK2f_GetPrimaNorma(XsPrim,NevPrim)
*/////////////////////////////////////////////////////////////////////////////////////
*//   Get Primary Xsection for normalization NANOBARNS
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   XsPrim,ERela,WtSup
      INTEGER            NevPrim
*
      CALL GLK_MgetNtot(m_IdGen,NevPrim)
      CALL GLK_MgetAve( m_IdGen,XsPrim,ERela,WtSup)
      END


      SUBROUTINE KK2f_GetXsNormPb(XsNormPb,XsErroPb)
*/////////////////////////////////////////////////////////////////////////////////////
*//   UNIVERSAL Xsection normalization PICOBARNS for wt=1 and wted events
*//   To be called AFTER CALL KK2f_Finalize !!!!!!
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      INCLUDE 'KK2f.h'
      DOUBLE PRECISION   XsNormPb,XsErroPb
*
      IF(m_KeyWgt .EQ. 0) THEN  !!! CONSTANT-WEIGHT events
         XsNormPb = m_xSecPb    ! MC xsection in picobarns
         XsErroPb = m_xErrPb    ! Its error   in picobarns
      ELSE
         XsNormPb = m_Xcrunb*1000
         XsErroPb = 0d0
      ENDIF
      END

*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//                                                                                 //
*//                      End of Class  KK2f                                         //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
