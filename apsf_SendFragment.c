typedef struct
{
  union
  {
    uint16      shortAddr;
    ZLongAddr_t extAddr;
  } addr;
  byte addrMode;
} zAddrType_t;

typedef struct
{
  zAddrType_t dstAddr;
  uint8       srcEP;
  uint8       dstEP;
  uint16      dstPanId;
  uint16      clusterID;
  uint16      profileID;
  uint16      asduLen;
  uint8*      asdu;
  uint16      txOptions;
  uint8       transID;
  uint8       discoverRoute;
  uint8       radiusCounter;
  uint8       apsCount;
  uint8       blkCount;
} APSDE_DataReq_t;


APSF_SendFragment(APSDE_DataReq_t * req)
	
	MOV A,#0xF0
	LCALL BANKED_ENTER_XDATA
	MOV	A,@0xFA
	LCALL ALLOC_XSTACK8
	(R3:R2 --> req)
	MOV	  V0,R2
	MOV	  V1,R3
	(V0:V1 -> req)
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
	MOVX	A,@DPTR