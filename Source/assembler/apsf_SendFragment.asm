typedef struct {
  uint8 frameDelay; // +0
  uint8 windowSize; // +1
} afAPSF_Config_t;

typedef struct
{
  union
  {
    uint16      shortAddr;
    ZLongAddr_t extAddr;
  } addr;
  byte addrMode;  8
} zAddrType_t;

typedef struct
{
  zAddrType_t dstAddr;
  uint8       srcEP; // +09
  uint8       dstEP; // +0A
  uint16      dstPanId; // +0B
  uint16      clusterID; // +0D
  uint16      profileID; // +0F
  uint16      asduLen;  // +11
  uint8*      asdu;     // +13
  uint16      txOptions; // +14
  uint8       transID;	 // +16
  uint8       discoverRoute; // +17
  uint8       radiusCounter; // +18
  uint8       apsCount; // +19
  uint8       blkCount; // +1A
} APSDE_DataReq_t;


PUSH_XSTACK_I_THREE:
// Allocate 3 bytes and fill it with the value at R0
0821	MOV		A,#3
		SJMP	PUSH_XSTACK_I
PUSH_XSTACK_I_TWO:
0825	MOV		A,#2
		SJMP	PUSH_XSTACK_I		
PUSH_XSTACK_I_ONE:
0829	MOV		A,#3
PUSH_XSTACK_I:
82B		PUSH	A
		CPL		A
		INC		A
		LCALL	ADD_XSTACK_DISP0_8
		POP		A
		LCALL	MOVE_LONG8_XDATA_IDATA
837		RET
// add the value to A to stack and put DPTR to stack address
ADD_XSTACK_DISP0_8:
838		ADD		A,XSP(L)
		MOV		DPL,A
		JBC		IEN0,EA,0x847
		MOV		XSP(L),A
		JC		84F
843		DEC		XSP(H)
		SJMP	84F
847		MOV		XSP(L),A
		JC		84D
84B		DEC		XSP(H)
84D		SETB	IEN0,EA
84F		MOV		DPH,XSP(H)
852		RET


// Put in R3:R2 the stack pointer + A
XSTACK_DISP101_8:
08A9	ADD		A,XSPL
		MOV		R2,A
		CLR		A
		ADDC	A,XSP(H)
		MOV		R3,A
		RET
	
S_SHL:	
098B	JNZ		0991
098D	RET
S_SHL_REW:
098E	JZ		099D
0990	DEC 	R0
0991	XCH		A,@R0
		CLR		C
		RLC		A
		XCH		A,@R0
		INC		R0
0996	XCH		A,@R0
		RLC		A
0999	DJNZ	A,0990
		DEC		R0
099D	RET		
		

// MOV A bytes from @R0 to DPTR
MOVE_LONG8_XDATA_IDATA:
0A9E	XCH		A,R2
		PUSH	A
0AA1	MOV		A,@R0
		MOVX	@DPTR,A
		INC		DPTR
		INC		R0
		DJNZ	R2,0AA1
		POP		A
		MOV		R2,A
		RET

// Put in DPTR the stack pointer + A
0ADA	XSTACK_DISP0_2
		ADD		A,XSP(L)
		MOV		DPL,A
		CLR		A
		ADD		A,XSP(H)
		MOV		DPH,A
0AE3		RET

// Put at @DPTR, @DPTR+1 the value R0:R1
37DF	MOV		A,R0
		MOVX	@DPTR,A
		INC		DPTR
		MOV		A,R1
		MOVX	@DPTR,A
37E4	RET
// APSDE_DataReqMTU
37E5	MOV		A,#0xF7

// Set V0:V1 to R6:R7 + some value
3E9C	MOV		R0,A
		CLR		A
		ADDC	A,R7
		MOV		R1,A
		MOV		V0,R0
		MOV		V1,R1
		RET
		


 // PUT into R0:R1 the value at DPTR and set DPTR with V1:V0
4118	LCALL	5CCE
		MOV		DPL,V0
		MOV		DPH,V1
4121	RET

// PUT into R0:R1 the value at DPTR A = R0	
436D	LCALL	5CCE
		MOV		A,R0
4371	RET		

// Put into R0:A the value at DPTR
4528	MOVX	A,@DPTR
		MOV		R0,A
		INC		DPTR
		MOVX	A,@DPTR
		RET

// Piece for 16 sum
4649	MOV		R2,A
		INC		DPTR,
		MOVX	A,@DPTR
		ADDC	A,0
		MOV		R3,A
464F	RET

// Put @DPTR the value of A and set DPTR at R7,R6+4
48F3	MOVX	@DPTR,A
		MOV		DPL,R6
		MOV		DPH,R7
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
48FC	RET
APSDE_FrameSend
48FD	MOV		A,#F6

// set a with the content at DPTR and set DPTR with R7,R6+1
49AD	MOVX	A,@DPTR
		MOV		DPL,R6
		MOV		DPL,R7
		INC		DPTR
		RET

// inc DPTR of 2 and put into r5:r4 the value
49D5	INC		DPTR
		INC		DPTR
		LCALL	49DB
49DA	RET
// put into r5:r4 the value at DPTR
49DB	MOVX	A,@DPTR
		MOV		R4,A
		INC		DPTR
		MOVX	A,@DPTR
		MOV		R5,A
49E0	RET	

	   // Put in R2:R3 the value at DPTR
4A2D	LCALL	4DE8
		RET

4A5F	MOV		R7,1
		LJMP	BANKED_LEAVE_XDATA
APSDE_DataCnf:
4A64	PUSH	DPL

// finish to add R7:R6 and put the result into R1:R0 and put R1:R0 into the location address by R3:R4
4C01	MOV	R0,A
		CLR		A
		ADDC	A,R7
		MOV		R1,A
		MOV		DPL,R2
		MOV		DPH,R3
4C09	LCALL	37DF
		MOV		A,V0
4C0E	RET


APSF_AddObj:
// R1 -->
// R3:R2 address allocated object
4D89	MOV		A,#F7
		LCALL	BANKED_ENTER_DATA
		MOV		A,R2
		MOV		R6,A
		MOV		A,R3
		MOV		R7,A
		// R7:R6 the address of the object
		MOV		V0,R1
		MOV		A,R6
		ORL		A,R7
		JNZ		4D9B
		CALL	HalAssertHandler // the pointer can't be null
4D9B	MOV		DPTR,#32e
		LCALL	52F1 // Check if null the value pointer at 32e
		JNZ		4DAB
4DA3	MOV		DPTR,#032e
		SJMP	4DCA
4DA8	LCALL	5CC6
4DAB	MOV		DPL,R0
		MOV		DPH,R1
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		LCALL	4DDC
4DBB	MOV		DPL,R0
		MOV		DPH,R1
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
4DC8	JNZ		4DA8
// Put at DPTR the value of R7:R6
4DCA	MOV		A,R6	
		MOV		@DPTR,R6
		MOV		A,R7
		MOV		@DPTR,R7
		LCALL	4DF9 // // set DPTR at R7,R6+9
		CLR		A
		MOVX	@DPTR,A
		LJMP	4A5F		
4DDC	LCALL	4DE8
		MOV		A,R2
		ORL		A,R3
4DE1	RET
4DE2	INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
// Put in R2:R3 the value at DPTR
4DE8	MOVX	A,@DPTR
		MOV		R2,A
		INC		DPTR
		MOVX	A,@DPTR
		MOV		R3,A
		RET
// Put @DPTR the value of A and set DPTR at R7,R6+7		
4DF9	LCALL	4DFD
4DFC	RET
// Put @DPTR the value of A and set DPTR at R7,R6+9
4DFD	LCALL	5316
		INC 	DPTR
		INC		DPTR
4E02	RET
APSF_FindObj
4E03	MOV		A,#F7


// Put at @DPTR, @DPTR+1 the value R0:R1		
4EDF	LCALL	37DF
4EE2	RET
APSF_SendFragment(APSDE_DataReq_t * req)
4EE3	MOV A,#0xF0
		LCALL BANKED_ENTER_XDATA
		MOV	A,@0xFA
		LCALL ALLOC_XSTACK8
		// Stack is
		// SPX+0 -> afDataReqMTU_t (2 bytes)
		// SPX+2,3  (1FA)--> afAPSF_Config_t (2 bytes)
		// SPX+4, 5  (1FC)--> network address
		// SPX+6  (1FE)-->
		//R3:R2 --> req)
		MOV	  V0,R2
		MOV	  V1,R3
		
		
		//  --------------  load in SPX[4] the network address, getting it in the case a extend address is used
		//(V0:V1 -> req)
		MOV		DPL,R2
		MOV		DPL,R3
		INC		DPTR	
		INC		DPTR
		INC		DPTR
		INC		DPTR		
		INC		DPTR				
		INC		DPTR
		INC		DPTR
		INC		DPTR		
		MOVX	A,@DPTR (Load A dstAddr.addrMode)
4EFE	JZ	    0x4F33 (0 = AddrNotPresent)
		XRL		A,#1
		JZ		0x4F33
		MOV		DPL,R2
		MOV		DPL,R3
4F08	LCALL	0x4A2D
4F0B	LCALL	NLME_IsAddressBroadcast
4F0E	MOV		A,R1
		JNZ		4F33
		MOV		DPL,V0 //Load DPTR with address of req)
		MOV		DPH,V1
		INC		DPTR	
		INC		DPTR
		INC		DPTR
		INC		DPTR		
		INC		DPTR				
		INC		DPTR
		INC		DPTR
		INC		DPTR	
		MOVX	A,@DPOTR  //Load A req->dstAddr.addrMode
4F20	XLR		A,#3 (3 = Addr64Bit)
		JNZ		4F38 *
		MOV		A,4 
		LCALL	XSTACK_DIST102_8 // Load DPTR with SPX+4
		MOV		R2,V0 // R3:R2 extend address
		MOV		R3,V1
		LCALL	APSME_LookNwkAddr
4F30	MOV		A,R1
4F31	JNZ		4F49
4F33	MOV		R1,2		 
4F35	LJMP	50D7
// req->dstAddr.addrMode = Addr16Bit
4F38	MOV		DPL,V0 // Load DPOTR with req address that is network address
		MOV		DPH,V1
4f3E	LCALL	5CC6	 // PUT into R0:R1 the networkaddress
		MOV		A,4
		LCALL	XSTACK_DISP0_8  // set DPTR with SPX+4
4F46	LCALL	4EDF	// Put at SPX +4 the value of the network address
		// ------------------ now SPX[4] contains the network address


		// Allocate the buffer. 
		// The size is adsulen + 0x32 byte
		// The address is mantained into R7:R6
		// 0x00:0x01 -> system clock
		// 0x02:0x03-> clock remain ?
		// 0x07 -> number of packet to send
		// 0x0B - 0x26 -> APSDE_DataReq_t
		// 0x27 = afDataReqMTU - 2
		// 0x28 = frame send without ack
		// 0x29 = 0xFF shift to left for many bit as windows size
		// 0x2A = 0xFF shift to left for many bit as windows size
		// 0x2B -> retry count
		// 0x2C  -> windows 
		// 0x2D -> frame delay
		// 0x2e:0x2F -> ADSU_LEN
		// 0x30:0x31 -> adsu pointer
		// 0x32 --> adsu
		// Load into A req.asduLen
		//------------ start
4F49	MOV		A,V0
		ADD		A,#0x11
4F4D	LCALL	64e8
		// --
		
4f50	ADD		A,#32
		LCALL	4649
		// Now R3:R2 is adsulen + 0x32
		LCALL	osal_mem_alloc
		// V3:V2 the address of allocated buffer
		MOV		V2,R2
		MOV		V3,R3
		// R7:R6 the address of allocated buffer
		MOV		R6,V2
		MOV		R7,V3
		MOV		A,R6
		ORL		A,R7
		JNZ		4F67
		LJMP	50D7	// Unable to allocate the request buffer. END
		// -------------- end
		
		
		// clear the data
		// --- start
4F67	MOV		R4,#32
		MOV		R5,0
		MOV		R1,0
		// Clean the header that is from 0 to 32-th byte of allocated buffer
		LCALL	osal_Memset
		// --- send
		
		
		// Allocate the space for afAPSF_Config_t structure (pCfg)
		MOV		A,#2
		LCALL	XSTACK_DISP101_8
		
		MOV		DPL,V0 // V1:V0 point to argument (APSDE_DataReq_t *)
		MOV		DPL,V1
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		MOVX	A,@DPTR		// A = req->srcEP
4F85	MOV		R1,A
		LCALL	adAPSF_ConfigGet // void afAPSF_ConfigGet(uint8 endPoint, afAPSF_Config_t *pCfg)
		
		
		MOV		A,#2
		LCALL	XSTACK_DISP0_8  // Put into DPTR the address of pCfg
		MOVX	A,@DPTR		    // put in A the frameDelay value
		PUSH	A
4F91	LCALL	52B2  // Load in DPTR the pointer to allocated address + 0x2D
		POP		A
		MOVX	@DPTR,A  // put in allocatedValue[0x2D] = frameDelay 
		MOV		A,R6
		ADD		A,#2C
		MOV		V2,A
		CLR		A
		ADDC	A,R7
		MOV		V3,A // V3:V2 -> allocatedValud + 0x2C
		MOV		A,#3
		LCALL	XSTACK_DISP0_8 // Put into DPTR the address pCfg.windowSize
4FA5	MOVX	A,@DPTR
		MOV		DPL,V2
		MOV		DPH,V3
		MOVX	@DPTR,A	 // put allocatedValud[0x2C] = pCfg.windowSize
		
		
		// ------ add allocatedValud in the list of object
4FAD	MOV		R1,#1
		MOV		A,R6
		MOV		R2,A
		MOV		A,R7
		MOV		R3,A // Put in R3:R2 the addres of the allocated buffer
		LCALL	APSF_AddObj
		// ---- end
		
		// ------------ copy the 0x1C byte of the argument to allocatedBuffer + 0x0B
		MOV		v4,v0  // V1:V0 point to argument (APSDE_DataReq_t *)
		mov     v5,v1
		MOV		V6,0
		MOV		R0,#C		// source to copy in V5:V4
		// 00 00 F4 0F 1F 00 A9 14 02 0d 0d 02 40 00 00 04 01 5b 00 4b 15 00 00 00 01 1e 14 1b
4FC1	LCALL	PUSH_XSTACK_I_THREE // Allocate 3 byte and fill it using data at 0x0C
		MOV		R4,#1C // Len do copy
		MOV		R5,#0
4FC8	LCALL	50E6	// R3:R2 = allocatedBuffer + 0x0B
		LCALL	osal_memcpy //(dst=allocatedBuffer+0x0B, src=req, len=28)
		MOV		A,#3
		LCALL	DEALLOC_XSTACK
		// ------------ end
		
		
		MOV		A,R6
		ADD		A,#30
4FD6	LCALL	0x50EE	// r3:r2 = allocatedBuffer+0x30 and A=R6
		ADD		A,#32
		// put allocatedBuffer[0x30] = (allocated_buffer + 0x32) as int16
4FDB	LCALL	4C01	// A = v0 (v1:v0 --> address of req)
		ADD		A,0x11
		MOV		R0,A
		CLR		A
		ADDC	A,V1
		MOV		R1,A  // R1:R0 -> req->adsuLen
		MOV		A,R0
		MOV		R4,A
		MOV		A,R1
		MOV		R5,A
		MOV		DPL,R4
		MOV		DPH,R5 // R5:R4, DPTR -> req->adsulen
4FED	LCALL	57A7 // PUT into R0:R1 the value at DPTR and A=r6
		LCALL	52BC // Set DPTR = allocatedBuffer+ 0x2E
		LCALL	4C09 // Put at @DPTR, @DPTR+1 the value R0:R1 and A= V0
		LCALL	54F9 // put in DPTR the address of req->adsu
		LCALL	6FED // Set v5:V4 the address of ADSU
		LCALL	PUSH_XSTACK_I_THREE // push into stack the address of ADSU
		MOV		DPL,R4
		MOV		DPH,R5
		CALL	50FF	// put into r5:r4 the adsulen and load DPTR with allocatedBuffer+0x30
5006	CALL 	4A2D	// Put in R2:R3 the value at allocatedBuffer+0x30	
		CALL	OSAL_MEMCPY // copy ADSU at allocatedBuffer+0x32
		MOV		A,#3
		LCALL	DEALLOC_X_STACK
		MOV		A,#4
		LCALL	XSTACK_DISP0_8 // set DTPR a stack+4
5016	LCALL	5113 //PUT into R0:R1 the value at DPTR, DPTR allocatedBuffer+4
		LCALL	4EDF //  Put at @DPTR, @DPTR+1 the value R0:R1
		MOV		DPTR,APS_Counter
		LCALL	50F8 set a with the value of  and set DPTR with allocatedBuffer+4
		INC		DPTR
		INC		DPTR
		INC		DPTR
		MOV		@DPTR,A // allocatedBuffer[7] = APS_Counter
		// Increment APS_COUNTER
5026	MOV		DPTR,APS_Counter		
		MOV		A,@DPTR
		INC		A
		MOV		@DPTR,A

502C	LCALL	osal_GetSystemClock	 // Put the value into R5:R4:R3:R2
		LCALL	6407 // save allocatedBuffer[0] = R3:R2
		MOV		A,R6
		MOV		ADD, 0x2A
5035	LCALL	5A74 // R0:R1 = R3:R2 = allocatedBuffer+0x2A, set V4=FF
		MOV		V5,#0
		MOV		DPL,V2
		MOV		DPH,V3		// DPH = allocatedBuffer+0x2C = window
		MOVX	A,@DPTR		// set A as windows size
		MOV		R0, #0C		// V4 address
		LCALL	S_SHL		// Shift to left V5:V4 for as many bit as windows size
		MOV		DPL,R2
		MOV		DPH,R3
		MOV		A,V4
504d	MOVX	@DPTR,A
		LCALL	50DC  // set DPTR = allocatedBuffer + 0x29
		MOV		A,V4
		LCALL	5123 // // save A into the address at @DPTR and set DPTR = XSP
		CLR		A
		MOVX	@DPTR,A
		MOV		A,V0	// V0:V1 -> address of req
		ADD		A,#15  // req->txOptions 
		LCALL	0x64E8  // A <=  req->txOptions 
505F	MOV		C,A 0
		MOV		A,#1
		JNC		506C
5065	LCALL	STACK_DISP0_8
5068	MOV		A,#1
506A	SJMP	5070
506C	LCALL	STACK_DISP0_8
		CLR		A
5070	MOVX	@DPTR,A		// Set SPX[1] depending req->txOptions
		MOV		A,R6
		ADD		A,0x27
		LCALL	3E9C // Set V0:V1 to allocatedBufer+0x27
		MOV		R2,XSP(L)
		MOV		R3,XSP(H)
		LCALL	afDataReqMTU // result in R1 (value = 0x51)
		MOV		A,R1
		ADD		A,#FE
		MOV		DPL,V0
		MOV		DPH,V1
5087	MOV		#DPTR,A

5088	MOV		A,R6
		ADD		A,#2E
		MOV		R0,A
		CLR		A
		ADDC	A,R7
		MOV		R1,A
		MOV		A,R0
		MOV		R4,A
		MOV		A,R1
		MOV		R5,A // now R1:R0 == R5:R4 == allocatedBuffer + 2E (Adsu_Len)
5093	LCALL	5107 // PUT into R0:R1 the value of adsu_len and  R3:R2 with the value at allocatedBufer+27 (afDataReqMTU)
		LCALL	US_DIV_MOD
		MOV		A,R0
		MOV		DPL,R6
		MOV		DPH,R7
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
50A5	INC		DPTR		
		MOVX	@DPTR,A // Put into allocatedBuffer+8 the number of packet to send
		// if the module is not zero, then increment the number of packet to send of 1
		LCALL	5107 // PUT into R0:R1 the value of adsu_len and  R3:R2 with the value at allocatedBufer+27 (afDataReqMTU)
		LCALL	US_DIV_MOD
		MOV		V1,R3
		MOV		A,R2
		ORL		A,V1
		JZ		50C3
50B4	MOV		DPL,R6
		MOV		DPH,R7
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
50BF	INC		DPTR	
		MOVX	A,@DPTR	// Set A with the number of packet to send
		INC		A
		MOVX	@DPTR,A
		
50C3	MOV		A,R6		
		ADD		A,#20
		LCALL	5A65	// Load A with allocatedBuffer + 0x20
		ORL		A,#8
		LCALL	5AD0  // // Save A at allocatedBuffer + 0x20, set R3:R2 = 0x0001 (flaag) and set R1 at the value at APSF_taskID
		LCALL	osal_event_set
		MOV		R1,#0
50D3	SJMP	50D7
50D5	MOV		R1,#10
50D7	MOV		A,#6
50D9	LJMP	0x3FFF		// END

// set DPTR = R7:R6+0x29		
50DC	MOV		A,R6
		ADD		A,#29
		MOV		DPL,A
		CLR		A
		ADDC	A,R7
		MOV		DPH,A
50E5	RET
// Add 0x0B to R7:R6 and put the result into R3:R2	
50E6	MOV		A,R6
		ADD		A,#0B
		MOV		R2,A
		CLR		A6
		ADDC	A,R7
		MOV		R3,A
50ED	RET
// finish to add r7 and put the result into r3:r2
50EE	MOV		R0,A
		CLR		A
		ADDC	A,R7
		MOV		R1,A
		MOV		A,R0
		MOV		R2,A
		MOV		A,R1
		MOV		R3,A
		MOV		A,R6
50F7	RET
// set a with the content at DPTR and set DPTR with R7,R6+4
50F8	LCALL 49AD
		INC		DPTR
		INC		DPTR
		INC		DPTR
50FE	RET
// Put into r5:r4 the value at DPTR and load DPTR with r3:R2	
50FF	LCALL	49DB
		MOV		DPL,R2,
		MOV		DPH,R3
5106	RET

// PUT into R0:R1 the value at R5:R4 and set R3:R2 with the value at V1:V0
5107	MOV		DPL,R4
		MOV		DPH,R5
		LCALL	4118
		MOVX	A,@DPTR
		MOV		R2,A
		MOV		R3,#0
5112	RET		
// PUT into R0:R1 the value at DPTR, DPTR R7:R6+4
5113	LCALL	5117
5116     RET
// PUT into R0:R1 the value at DPTR, DPTR R7:R6+4
5117	LCALL	5CCE
		MOV		DPL,R6
		MOV		DPH,R7
		INC		DPTR
		INC		DPTR
		INC		DPTR
		INC		DPTR
5122	RET		
// save A into the address at @DPTR and set DPTR = XSP
5123	MOVX	@DPTR,A
		MOV		DPL,XSP(L)
		MOV		DPH,XSP(H)
512A	RET

APSF_TxNextFrame:
// R3:R2 -> Address object to send
512B	MOV		A,#F4
    	LCALL	BANKED_ENTER_XDATA // Allocate 12 byte
		// SPX(0)
		// SPX(1)
		// SPX(2)
		// SPX(3)
		// SPX(4)
		// SPX(5)
		// SPX(7)
		// SPX(9)
		// SPX(9)
		// SPX(10)
		// SPX(11)
		MOV		A,R2
		MOV		R6,A
		MOV		A,R3
		MOV		R6,A	// R7:R6 the address of the object to send
		LCALL	osal_GetSystemClock
		LCALL	6407 // save int R7:R6 the actual clock value
		MOV		DPTR,zgApscMaxFrameRetries
		MOVX	A,@DPTR
		MOV		R0,A	// R0 containt zgApscMaxFrameRetries
		
		MOV		A,R6
		ADD		A,#2B
		LCALL	5A65  // Load A with R7:R6 + 0x2B
		CLR		C
		SUBB	A,R0
		JC		514C // Jump if it didn't get the MaxFrameRetry
		LJMP	5296
514C	LCALL	5A80	// Load A with R7:R6 + 29 (windows bit) and it complements it
		JNZ		5163
5151	MOV		A,R6
		ADD		A,#2B
		LCALL	5A65
		INC		A
		LCALL	5305
		PUSH	A
		LCALL	50DC
		POP		A
		MOVX	@DPTR,A
5163	MOV		A,R6
		ADD		A,#28
		LCALL	5A65	// Load A with R7:R6 + 0x28 (frame send without ack)
		MOV		R4,A	// Load R4 with R7:R6 + 0x28 (frame send without ack)
		MOV		R1,#0
		SJMP	516F
516E	INC		R1
516F	MOV		A,R6
		ADD		A,#2C
		LCALL	5A65  // Load A with R7:R6 + 2C (windows)
		MOV		R0,A  // Load R0 with R7:R6 + 2C (windows)
		MOV		A,R1
		CLR		C
		SUBB	A,R0
		JNC		51A1	// Jump if are sent all the possible frame without ack
		// It is possible send another frame 
		MOV		V0,#1
		MOV		V1,#0
		MOV		A,R1
		MOV		R0,#8
		LCALL	S_SHL
		LCALL	5A80  // Load A with R7:R6 + 29 (windows bit) and it complements it
		ANL		A,V0
		JZ		516E	// No more frame to send
518E	MOV		A,R1		
		ADD		A,R4
		MOV		R4,A
		MOV		V0,#1
		MOV		V1,#0
		MOV		A,R1
		MOV		R0,#8
		LCALL	S_SHL
		// -------- start Update the windows bit
		MOVX	A,@DPTR		
		ORL		A,V0
		MOV		@DPTR,A
		// ------- end
		MOV		A,R6
		ADD		A,#27
51A4	LCALL	52CD // set R2 with R7:R6 + 0x27 (data to send per frame)
		MOV		A,R6
		LCALL	52BC // set DPTR = R7:R6
		MOV		A,R4 // R4 contains index data to send
		MOV		V0,R2 // V0 contains the data to send per frame
		MOV		B,R2
		MUL		AB
		MOV		R0,A
		MOV		R3,B
		CLR		A
51B5	ADD		A,R3
		MOV		R1,A  // R1:R0 contains the data sent until now
		MOVX	A,@DPTR	// A contains the adsu len (low byte)
		SUBB	A,R0
		MOV		R0,A  // R0 contains the adsu len (low byte)
		INC		DPTR
		MOVX	A,@DPTR // A contains the adsu len (HI byte)
		SUBB	A,R1
		MOV		R1,A
		CLR		C
		MOV		A,R0
		SUBB	A,V0
		MOV		A,R1
		SUBB	A,00
		MOV		A,R6
		JC		51FD // Jump of the data remains to send are lower that a maximum frame 
		// Fill all the frame
51C8	ADD		A,#27		
		LCALL	5A65 // Load A with frame size
		MOV		R0,A // Load R0 with frame size
		
		
		
		
		
		
		
// Load into DPTR the value of R7:R6+ 0x2D	
52B2	MOV		A,R6
		ADD		A,#2D
		MOV		DPL,A
		CLR		A
		ADDC	A,R7
		MOV		DPH,A
52BB	RET
// set DPTR = R7:A
52BC	LCALL	52C3
		ADD		A,R7
		MOV		DPH,A
52C2	RET
// Add at A,0x2e and put the result into DPL
52C3	ADD		A,#2E
		MOV		DPL,A
		CLR		A
52C8	RET		

// Set R2 with the value in R7:R6
52CD	LCALL	5A6C
		MOV		R2,A
52D1	RET			
// PUT into R0:R1 the value at DPTR AND R0 | R1
52F1	LCALL	436D
		ORL		A,R1
52F5	RET

// Put @DPTR the value of A and set DPTR at R7,R6+7
5316	LCALL	48F3
		INC		DPTR
		INC		DPTR
		INC		DPTR
531C	RET
APSF_Schedule
531D	MOV		A,#F4
    	LCALL	BANKED_ENTER_XDATA // Allocate 12 byte
		// SPX(0)
		// SPX(1)
		// SPX(2)
		// SPX(3)
		// SPX(4)
		// SPX(5)
		// SPX(7)
		// SPX(9)
		// SPX(9)
		// SPX(10)
		// SPX(11)
		MOV		DPTR,#032E // first list of object
5325	LCALL	53F6 // Set r7:R6 with the value at 032e
		LCALL	osal_GetSystemClock  // Put the value into R5:R4:R3:R2
		MOV		V2,R2
		MOV		V3,R3	// V3:V2 -> the system clock
		MOV		R0,#FF
		MOV		R1,#FF
5333	JSMP	5355
5335	MOVX	A,@DPTR
		CLR		C
		SUBB	A,R2
		MOV		R4,A
		INC		DPTR
533A	MOVX	A,@DPTR
		SUBB	A,R3
		MOV		R5,A
		CLR		C
		MOV		A,R4
		SUBB	A,R0
		MOV		A,R5
		SUBB	A,R1
5342	JNC		5352
		MOV		DPL,R6
		MOV		DPH,R7
		INC		DPTR
		INC		DPOTR
534A	MOVX	A,@DPTR
		CLR		C
		SUBB	A,R2
		MOV		R0,A
		INC		DPTR
5350	SUBB	A,R3
5351	MOV		R1,A
5352	LCALL	53e9
		
5355	MOV		A,R6
		ORL		A,R7
		JZ		53B5 // Se non ci sono più elementi
		
		// --- Subtract the actual time with the time of  the object
5359	MOV		DPL,R6
		MOV		DPH,R7
		LCALL	4A2D // Set R3:R2 with the value of DPTR
		MOV		A,V2  // V3:V2 system clock
		CLR		C
		SUBB	A,R2
		MOV		R2,A
		MOV		A,V3
		SUBB	A,R3
5368	MOV		R3,A
		// ----------- end 
		MOV		DPL,R6
		MOV		DPH,R7
		LCALL	49D5  // // r5:r4 the value r7:r6 +2 
5370	CLR		C		
		MOV		A,R2
		SUBB	A,R4
		MOV		A,R3
		SUBB	A,R5
		MOV		DPL,R6
		MOV		DPH,R7
		INC		DPTR
		INC		DPTR
		JC		5335 // next
		INC     DPTR
		INC     DPTR
		INC     DPTR
		INC     DPTR
5381	MOVX    A,@DPTR
		XRL		A,#2
		JNZ		53A0
5386	MOV		A,R6
		ADD		A,#0B
		CALL	5A83
		JZ		5397
538E	LCALL	53E1
		LCALL	4A2D
		LCALL	osal_msg_deallocate
5397	MOV		A,R6
		MOV		R2,A
		MOV		A,R7
		MOV		R3,A
		LCALL	APSF_FreeObj
		SJMP	53A7
53A0	MOV		A,R6		
		MOV		R2,A
		MOV		A,R7
		MOV		R3,A
		LCALL	APSF_TxNextFrame






		

// set R7:R6 with the value at dptr
53F6	MOVX	A,@DPTR
		MOV		R6,A
		INC		DPTR
		MOVX	A,@DPTR
		MOV		R7,A
53FB	RET

// Put in DPL:DPH the value of A:V2 + 0x013
54F9	ADD		A,#13
		LCALL	5781
54FF	RET		
		
		
// Put in DPL:DPH the value A:V1		
5781	MOV		DPL,A
		CLR		A
		ADDC	A,V1
		MOV		DPH,A
		RET
		
		
// PUT into R0:R1 the value at DPTR and A=r6		
57A7	LCALL	5CCA
		MOV		A,R6
57AB	RET		

// Load A with the value A:R7
5A65	LCALL	%5A6C
5A68	RET
5A69	MOV		A,R6
		ADD		A,#0F
5A6C	MOV		DPL,A
		CLR		A
		ADDC	A,R7
		MOV		DPH,A
		MOVX	A,#DPTR
5A73	RET		
// finish to add R7:A and put the result into R0:R1 and R3:R2, set V4=FF
5A74	MOV		R0,A
		CLR		A
		ADDC	A,R7
		MOV		R1,A
		MOV		A,R0
		MOV		R2,A
		MOV		A,R1
		MOV		R3,A
		MOV		V4,#0xFF
5A7F	RET		

// Load A with R7:R6 + 29 (windows bit) and it complements it
5A80	MOV		A,R6
		ADD		A,#29
		LCALL	5A6C // Load A with R7:R6 + 29 (windows bit)
		CPL		A
5A87	RET

		
// Save A at @DPTR, set R3:R2 = 0x0001 and set R1 at the value at APSF_taskID		
5AD0	MOVX	@DPTR,A
		MOV		R2,#1
		MOV		R3,#0
		MOV		DPTR,#0x0F00
		MOVX	A,@DPTR
		MOV		R1,A
5ADA	RET


APSF_SendOsalMsg:
// Send the message to APSF_taskID. The data in DPTR
5AE3	PUSH	DPL
		PUSH	DPH
		
		MOV		DPTR,@0F00 //APSF_taskID
		MOVX	A,@DPTR
		MOV		R1,A
		LCALL	osal_msg_send
		LJMP	46EB
// UINT16 APSF_ProcessEvent( uint8 task_id, UINT16 events );		
APSF_ProcessEvent:		
5AF2	MOV		A,#F4
		LCALL	BANKED_ENTER_XDATA // Allocate 12 byte
		// SPX(0)
		// SPX(1)
		// SPX(2)
		// SPX(3)
		// SPX(4)
		// SPX(5)
		// SPX(7)
		// SPX(9)
		// SPX(9)
		// SPX(10)
		// SPX(11)
		MOV		V0,R2
		MOV		V1,R3		
		MOV		A,R3
		ANL		A,#80
5AFE 	JNZ		5B3B
		MOV		A,R2
		MOV		C,A.0
5B03	JNC		5B58
		LCALL	ASPF_Schedule
		MOV		A,V0
		XRL		A,#1
		





		
// PUT into R0:R1 the value at DPTR		
5CC6	LCALL	5CCA
		RET
// PUT into R0:R1 the value at DPTR
5CCA	LCALL	5CCE
		RET
// PUT into R0:R1 the value at DPTR		
5CCE	LCALL	4528
		MOV		R1,A
		RET
		
// save R3:R2 into the address pointer by R7:R6
6407	MOV		DPL,R6
		MOV		DPH,R7
		MOV		A,R2
		MOV		@DPTR,A
		INC		DPTR
		MOV		A,R3
		MOVX	@DPTR,A
6410	RET
		
		
		
		
// Put in DPL:DPH the value A:V1 and get the value at DPTR		
64e8	LCALL	5781
		MOVX	A,@DPTR
64EC	RET
// SSP_BuildAuxHdr2
64eD	MOV		A,#F2