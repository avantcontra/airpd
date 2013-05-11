////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2013 Contra.
// More information see the file "LICENSE.txt".
//
////////////////////////////////////////////////////////////////////////////////
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include "LibpdExtension.h"
#include <sstream>
#include <iostream>


using namespace std;
using namespace pd;


FREContext m_ctx;

void testEventPolling(PdBase& pd);

FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    int32_t numInChannels, numOutChannels, sampleRate;
    FREGetObjectAsInt32(argv[0], &numInChannels);
    FREGetObjectAsInt32(argv[1], &numOutChannels);
    FREGetObjectAsInt32(argv[2], &sampleRate);

    bool result = m_pd.init(numInChannels, numOutChannels, sampleRate);

    //TODO for test
    m_pd.computeAudio(true);
    
	if(!result)
    {
		cerr << "Could not init pd" << endl;
         FREDispatchStatusEventAsync(m_ctx,(const uint8_t *)"Could not init pd", (const uint8_t *)"DATA_FLOAT");
    }
    
    uint32_t res = result ? 1 : 0;
    FREObject retBool = new FREObject();
    FRENewObjectFromBool(res, &retBool);
    
    return retBool;
}

FREObject pollPdMessageQueue(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    testEventPolling(m_pd);
    
     return 0;
}

FREObject sendFloat(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    uint32_t string1Length;
    const uint8_t *dest;
    FREGetObjectAsUTF8(argv[0], &string1Length, &dest);

    double num;
    FREGetObjectAsDouble(argv[1], &num);
    
    //double to float here
    m_pd.sendFloat((char *)dest, num);
  
     
    testEventPolling(m_pd);
    
    return 0;
}

FREObject openPatch(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    
    uint32_t string1Length;
    const uint8_t *fileName;
    FREGetObjectAsUTF8(argv[0], &string1Length, &fileName);
    
    uint32_t string2Length;
    const uint8_t *path;
    FREGetObjectAsUTF8(argv[1], &string2Length, &path);

    Patch patch = m_pd.openPatch((char*)fileName, (char*)path);
    string fn = patch.filename();

    FREObject fo;
    FRENewObjectFromUTF8(strlen(fn.c_str())+1,(const uint8_t *)fn.c_str(), &fo);
    return fo;

}

string floatToString(float value)
{
    std::stringstream ss;
    std::string str;
    ss<<value;
    ss>>str;
    ss.clear();
    return str;
}

void printToFlash(string code, string level)
{
    FREDispatchStatusEventAsync(m_ctx,(const uint8_t *)code.c_str(), (const uint8_t *)level.c_str());
}

// process the message queue manually using pd::Message objects
void testEventPolling(PdBase& pd)
{
    cout << "Number of waiting messages: " << pd.numMessages() << endl;
	while(pd.numMessages() > 0)
    {
		Message& msg = pd.nextMessage();
        switch(msg.type)
        {
                
			case PRINT:
				cout << "CPP: " << msg.symbol << endl;
                printToFlash(msg.symbol, "PRINT msg.symbol");
				break;
                
                // events
			case BANG:
				cout << "CPP: bang " << msg.dest << endl;
                printToFlash(msg.dest, "BANG msg.dest");
				break;
			case FLOAT:
				cout << "CPP: float " << msg.dest << ": " << msg.num << endl;
                printToFlash(msg.dest, "FLOAT msg.dest");
                printToFlash(floatToString(msg.num), "FLOAT msg.num");
				break;
			case SYMBOL:
				cout << "CPP: symbol " << msg.dest << ": " << msg.symbol << endl;
                printToFlash(msg.dest, "SYMBOL msg.dest");
                printToFlash(msg.symbol, "SYMBOL msg.symbol");
				break;
			case LIST:
				cout << "CPP: list " << msg.list << msg.list.types() << endl;
                printToFlash(msg.list.toString(), "LIST msg.list");
				break;
			case MESSAGE:
				cout << "CPP: message " << msg.dest << ": " << msg.symbol << " "
                << msg.list << msg.list.types() << endl;
                printToFlash(msg.symbol, "MESSAGE msg.symbol");
                printToFlash(msg.list.toString(), "MESSAGE msg.list");
				break;
                
                // midi
			case NOTE_ON:
				cout << "CPP MIDI: note on: " << msg.channel << " "
                << msg.pitch << " " << msg.velocity << endl;
				break;
			case CONTROL_CHANGE:
				cout << "CPP MIDI: control change: " << msg.channel
                << " " << msg.controller << " " << msg.value << endl;
                printToFlash(msg.symbol, "CONTROL_CHANGE");
				break;
			case PROGRAM_CHANGE:
				cout << "CPP MIDI: program change: " << msg.channel << " "
                << msg.value << endl;
                printToFlash(msg.symbol, "PROGRAM_CHANGE");
				break;
			case PITCH_BEND:
				cout << "CPP MIDI: pitch bend: " << msg.channel << " "
                << msg.value << endl;
                printToFlash(msg.symbol, "PITCH_BEND");
				break;
			case AFTERTOUCH:
				cout << "CPP MIDI: aftertouch: " << msg.channel << " "
                << msg.value << endl;
                printToFlash(msg.symbol, "AFTERTOUCH");
				break;
			case POLY_AFTERTOUCH:
				cout << "CPP MIDI: poly aftertouch: " << msg.channel << " "
                << msg.pitch << " " << msg.value << endl;
                printToFlash(msg.symbol, "POLY_AFTERTOUCH");
                
				break;
			case BYTE:
				cout << "CPP MIDI: midi byte: " << msg.port << " 0x"
                << hex << (int) msg.byte << dec << endl;
                printToFlash(msg.symbol, "BYTE");
				break;
                
			case NONE:
				cout << "CPP: NONE ... empty message" << endl;
                printToFlash(msg.symbol, "NONE");
				break;
		}
	}
}
    
FRENamedFunction methods[] =
{
    { (const uint8_t*) "init", 0, init },
    { (const uint8_t*) "openPatch", 0, openPatch },
    { (const uint8_t*) "sendFloat", 0, sendFloat },
    { (const uint8_t*) "pollPdMessageQueue", 0, pollPdMessageQueue },
};

void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
{
    m_ctx = ctx;
        
    *numFunctions = sizeof(methods) / sizeof(FRENamedFunction);
    *functions = methods;
}
    
void contextFinalizer(FREContext ctx)
{
    return;
}

void AIRPDInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
{
    *ctxInitializer = &contextInitializer;
    *ctxFinalizer = &contextFinalizer;
}

void AIRPDFinalizer(void* extData)
{
    return;
}



