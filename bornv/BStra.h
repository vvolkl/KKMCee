*//////////////////////////////////////////////////////////////////////////////////////
*//                                                                                  //
*//          Pseudoclass BStra                                                       //
*//                                                                                  //
*//                                                                                  //
*//                                                                                  //
*//////////////////////////////////////////////////////////////////////////////////////

      DOUBLE PRECISION   m_XCrude, m_Nev, m_SWT, m_SSWT
      INTEGER            m_out,     m_Nevgen,  m_KeyWgt
      INTEGER            m_ModeA,   m_ModeB,   m_ModeC,  m_NevCru

      COMMON /c_BStra/   
     $    m_XCrude,                         ! crude xsection
     $    m_Nev,                            ! no. of events
     $    m_SWT,                            ! sum of WT
     $    m_SSWT,                           ! sum of WT**2
     $    m_Nevgen,                         ! serial no of event
     $    m_ModeA,                          ! operational mode for Initialization
     $    m_ModeB,                          ! operational mode for Initialization
     $    m_ModeC,                          ! operational mode for Initialization
     $    m_KeyWgt,                         ! weighted or wt=1 events
     $    m_NevCru,                         ! normalization for wted events
     $    m_out                             ! output unit
      SAVE /c_BStra/   
*//////////////////////////////////////////////////////////////////////////////////////
*//                                                                                  //
*//          END of Pseudoclass BStra                                                //
*//                                                                                  //
*//////////////////////////////////////////////////////////////////////////////////////
