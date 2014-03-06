//
//  CTXAudioFilePlayerUnitPlugIn.h
//  CTXAudioFilePlayerUnit
//
//  Created by Benedikt Eickhoff on 06.03.14.
//  Copyright (c) 2014 Benedikt Eickhoff. All rights reserved.
//

#import <Quartz/Quartz.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>


#pragma mark user-data struct
// Insert Listing 7.2 here

typedef struct MyAUGraphPlayer
{
    //figure out format of audio files contents
    AudioStreamBasicDescription inputFormat;
    //keep track of input file by id
    AudioFileID inputFile;
    //prepare for AUGraph allocation
    AUGraph graph;
    //prepare for and name AUUnit allocation
    AudioUnit fileAU;
    
} MyAUGraphPlayer;



@interface CTXAudioFilePlayerUnitPlugIn : QCPlugIn {


}


// Declare here the properties to be used as input and output ports for the plug-in e.g.
//@property double inputFoo;
//@property (copy) NSString* outputBar;


#pragma mark utility functions
// Insert Listing 4.2 here
// generic error handler - if err is nonzero, prints error message and exits program.
static void CheckError(OSStatus error, const char *operation)
{
	if (error == noErr) return;
	
	char str[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
	if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
		str[0] = str[5] = '\'';
		str[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(str, "%d", (int)error);
	
	fprintf(stderr, "Error: %s (%s)\n", operation, str);
	
	exit(1);
}



//set up the audio unit graph and the file-playing audio unit. These are big jobs, so let’s set them aside for a minute and write them in convenience functions called CreateMyAUGraph() and PrepareFileAU()

//Creating and Audio Unit Graph
// 1. Create the AUGraph
// 2. Create Nodes
// 3. Open the Graph
// 4. Optional: Get audio units from nodes if you need to access any of the units directly.
// 5. Connect nodes
// 6. Initialize the AUGraph
// 7. Start the AUGraph

void CreateMyAUGraph(MyAUGraphPlayer *player){
    //Create a new AUGraph
    CheckError(NewAUGraph(&player->graph),
               "NewAUGraph failed");
    
    //Create the node of the graph ...in this case
    //... generate description the matches the output device (speakers - or whatever hijacked the default output)
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //Adds a node with above output device description
    AUNode outputNode;
    CheckError(AUGraphAddNode(player->graph, &outputcd, &outputNode),
               "[kAudioUnitSubType_DefaultOutput] failed");
    
    //Generate description that matches a generator AU of type:
    // audio file player
    AudioComponentDescription fileplayercd = {0};
    fileplayercd.componentType = kAudioUnitType_Generator;
    fileplayercd.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    fileplayercd.componentSubType  = kAudioUnitManufacturer_Apple;
    //Adds a node with the above description
    AUNode fileNode;
    CheckError(AUGraphAddNode(player->graph, &fileplayercd, &fileNode),
               "AUGraphAddNode[kAudioUnitSubtype_AudioFilePlayer] failed");
    
    //Opening the graph opens all contained audio units but does not allocate any resources yet
    CheckError(AUGraphOpen(player->graph),
               "AuGraphOpen failed");
    
    //Nodes act like a wrapper around audio units. If you need to work directly with a unit, you can get the unit from its containing node via AUGGraphNodeInfo(), which takes a graph and a node as its first two parameters and uses its third and fourth parameters to provide pointers  to a component description and  the audio unit (you can NULL out either of these parameters if you don't want them).
    
    //Get the reference to the AudioUnit object for the
    //file player graph node
    
    CheckError(AUGraphNodeInfo(player->graph, fileNode, NULL, &player->fileAU),
               "AUGraphNodeInfo failed");
    
    //Connect the output source of the file player AU to
    //the input source of the output node
    
    
    
 

}




@end
