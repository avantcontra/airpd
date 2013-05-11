////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2013 Contra.
// More information see the file "LICENSE.txt".
//
////////////////////////////////////////////////////////////////////////////////
#include "ExtensionConfig.h"
#include "PdBase.hpp"

#ifdef AIRPD_OS_WINDOWS
    #ifdef PDEXTENSION_EXPORTS
        #define PDEXTENSION_API __declspec(dllexport)
    #else
        #define PDEXTENSION_API __declspec(dllimport)
    #endif
    #include "FlashRuntimeExtensions.h"
#else
    #define PDEXTENSION_API __attribute__((visibility("default")))
    #include "FlashRuntimeExtensions.h"
#endif

extern "C"
{
    
    //methods 
    FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    FREObject openPatch(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    FREObject sendFloat(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    FREObject pollPdMessageQueue(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    
    //initializer / finalizer
    PDEXTENSION_API void AIRPDInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	PDEXTENSION_API void AIRPDFinalizer(void* extData);
    void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
    void contextFinalizer(FREContext ctx);
    
    pd::PdBase m_pd;
}