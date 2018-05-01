#ifndef __ZCL_READ_ATTRIBUTE_FN__H__
#define __ZCL_READ_ATTRIBUTE_FN__H__

#include "hal_types.h"
#include "zcl.h"

#ifdef __cplusplus
extern "C"
{
#endif

// Read Attribute Response Status record

typedef void (*AttributeWriteCB)(void);



typedef void  (*ReadAttributeFn)(zclAttrRec_t *);

struct ReadAttributeFnList  {
	uint8 endpoint;
	uint16 clusterId;
	ReadAttributeFn callback;
	struct ReadAttributeFnList * next;
};

ReadAttributeFn findReadAttributeFn(uint8 endpoint, uint16 clusterId);
void addReadAttributeFn(uint8 endpoint, uint16 cluster, ReadAttributeFn callback);

#ifdef __cplusplus
}
#endif
#endif