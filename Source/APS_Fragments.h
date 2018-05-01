#ifndef __APS_FRAGMENTS_H__
#define __APS_FRAGMENTS_H__

#include "AF.h"
#include "APSMEDE.h"

afStatus_t SendFragmented(APSDE_DataReq_t *pReq);
void APS_FragmenHandleDataConfirm(afDataConfirm_t * dataConfirm);

#endif