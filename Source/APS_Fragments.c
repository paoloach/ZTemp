#include "string.h"
#include "OSAL_Memory.h"
#include "APS.h"
#include "aps_frag.h"
#include "APS_Fragments.h"


struct AsduFragmented {
	struct AsduFragmented * next;
	APSDE_DataReq_t dataReq;
	uint8   maxCount;
	uint8   blockCount;
	uint8 * asdu;
	uint16  txOptions;
	uint16  asduLen;
	uint8   mtu;
	uint8   apsCount;
	uint8   extBlockConfirm;
};

struct AsduFragmented * fragmentList;

static struct AsduFragmented * newAsduFragmented(void);
static struct AsduFragmented * getFromList(uint16 transID);
static struct AsduFragmented * getFromFrame(aps_FrameFormat_t *aff, uint16 srcAddr);
static void freeFromList(struct AsduFragmented *asduFragment);

static void ProcessAck(aps_FrameFormat_t *aff, uint16 srcAddr, uint8 status);

afStatus_t SendFragmented(APSDE_DataReq_t *pReq) {
	APSDE_DataReqMTU_t mtuReq;
	struct AsduFragmented * asduFragmented;
	afStatus_t result;
	
	asduFragmented = newAsduFragmented();
	memcpy(&(asduFragmented->dataReq), pReq, sizeof(APSDE_DataReq_t));
	
	asduFragmented->asdu = pReq->asdu;
	asduFragmented->maxCount =  pReq->asduLen / asduFragmented->mtu;
	asduFragmented->mtu = APSDE_DataReqMTU(&mtuReq)-2;
	if ( ( pReq->asduLen % asduFragmented->mtu) != 0)
		asduFragmented->maxCount ++;
	asduFragmented->blockCount=0;
	asduFragmented->asduLen =  pReq->asduLen-asduFragmented->mtu;
	asduFragmented->txOptions = pReq->txOptions;
	
	asduFragmented->dataReq.asduLen = asduFragmented->mtu;
	asduFragmented->dataReq.txOptions =asduFragmented->txOptions  | APS_TX_OPTIONS_FIRST_FRAGMENT | APS_TX_OPTIONS_ACK | APS_TX_OPTIONS_PERMIT_FRAGMENT;
	asduFragmented->dataReq.blkCount = asduFragmented->maxCount;
	asduFragmented->extBlockConfirm=0;
	asduFragmented->apsCount = APS_Counter;
	//asduFragmented->dataReq.apsCount = asduFragmented->apsCount;
	apsfProcessAck = ProcessAck;
	result = APSDE_DataReq(&(asduFragmented->dataReq) );
	return result;
}

void APS_FragmenHandleDataConfirm(afDataConfirm_t * dataConfirm) {
	struct AsduFragmented * fragment = getFromList(dataConfirm->transID);
	if (fragment != NULL){
		if (fragment->blockCount >= fragment->maxCount-1){
			freeFromList(fragment);
		} else {
			fragment->dataReq.asdu += fragment->dataReq.asduLen ;
			if (fragment->asduLen < fragment->mtu)
				fragment->dataReq.asduLen = fragment->asduLen;
			else
				fragment->asduLen -= fragment->mtu;
			fragment->dataReq.txOptions = fragment->txOptions  | APS_TX_OPTIONS_ACK;
			fragment->blockCount++;
			fragment->dataReq.blkCount = fragment->blockCount;
			APS_Counter = fragment->apsCount;
			APSDE_DataReq(&(fragment->dataReq) );
		}
	}
}


void ProcessAck(aps_FrameFormat_t *aff, uint16 srcAddr, uint8 status) {
	struct AsduFragmented * fragment = getFromFrame(aff, srcAddr);
	if (fragment != NULL){
		if (fragment->blockCount >= fragment->maxCount){
			freeFromList(fragment);
		} else {
			fragment->dataReq.asdu += fragment->dataReq.asduLen ;
			if (fragment->asduLen < fragment->mtu)
				fragment->dataReq.asduLen = fragment->asduLen;
			else
				fragment->asduLen -= fragment->mtu;
			fragment->dataReq.txOptions = fragment->txOptions  | APS_TX_OPTIONS_ACK | APS_TX_OPTIONS_PERMIT_FRAGMENT;
			fragment->blockCount++;
			fragment->dataReq.blkCount = fragment->blockCount;
			APS_Counter = fragment->apsCount;
			APSDE_DataReq(&(fragment->dataReq) );
		}
	}
}

struct AsduFragmented * getFromFrame(aps_FrameFormat_t *aff, uint16 srcAddr) {
	struct AsduFragmented * list = fragmentList;
	while (list != NULL){
		if (list->dataReq.dstAddr.addr.shortAddr == srcAddr &&
			list->dataReq.dstEP == aff->SrcEndPoint &&
			list->dataReq.srcEP == aff->DstEndPoint &&
			list->extBlockConfirm == aff->BlkCount){
				return list;
		}
		list = list->next;
	}
	return NULL;
}

static void freeFromList(struct AsduFragmented *asduFragment) {
	struct AsduFragmented * list = fragmentList;
	while(list != NULL){
		if (list == asduFragment){
			list->next = asduFragment->next;
			osal_mem_free(asduFragment);
			return;
		}
	}
}

static struct AsduFragmented * getFromList(uint16 transID) {
	struct AsduFragmented * list = fragmentList;
	while (list != NULL){
		if (transID == list->dataReq.transID){
			return list;
		}
		list = list->next;
	}
	return NULL;
}
	
	
static struct AsduFragmented * newAsduFragmented(void) {
	 struct AsduFragmented * asduFragmented = (struct AsduFragmented *)osal_mem_alloc(sizeof(struct AsduFragmented ));
	 if (fragmentList == NULL){
		 fragmentList = asduFragmented;
		 asduFragmented->next = NULL;
	 } else {
		 asduFragmented->next = fragmentList;
		 fragmentList = asduFragmented;
	 }
	 return asduFragmented;
}