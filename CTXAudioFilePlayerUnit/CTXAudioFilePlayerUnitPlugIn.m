//
//  CTXAudioFilePlayerUnitPlugIn.m
//  CTXAudioFilePlayerUnit
//
//  Created by Benedikt Eickhoff on 06.03.14.
//  Copyright (c) 2014 Benedikt Eickhoff. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "CTXAudioFilePlayerUnitPlugIn.h"



#define kInputFileLocation CFSTR("/Users/benedikt/Desktop/Chormusik_0001.aiff")
//TODO: make this define disappear and create a proper plugin path selection GUI within the QC plugin ...




//#pragma mark main function
//int    main(int argc, const char *argv[])
//{
//        // Open the input audio file
//        // Get the audio data format from the file
//        // Insert Listing 7.3 here
//    
//        // Build a basic fileplayer->speakers graph
//        // Configure the file player
//        // Insert Listing 7.4 here
//    
//        // Start playing
//        // Sleep until the file is finished
//        // Insert Listing 7.5 here
//    
//        // Cleanup
//        // Insert Listing 7.6 here
//}





#define	kQCPlugIn_Name				@"CTXAudioFilePlayerUnit"
#define	kQCPlugIn_Description		@"CTXAudioFilePlayerUnit description"

@implementation CTXAudioFilePlayerUnitPlugIn

// Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
//@dynamic inputFoo, outputBar;



+ (NSDictionary *)attributes
{
	// Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeNone;
}

- (id)init
{
	self = [super init];
	if (self) {
		// Allocate any permanent resource required by the plug-in.
	}
	
	return self;
}


@end

@implementation CTXAudioFilePlayerUnitPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
    
    
    //work on implementing listing 7.3
    
    
    
    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, kInputFileLocation, kCFURLPOSIXPathStyle, false);
    
    MyAUGraphPlayer player = {0};
    CheckError(AudioFileOpenURL(inputFileURL, kAudioFileReadPermission, 0, &player.inputFile), "AudioFileOpenURL failed");
    CFRelease(inputFileURL);
    
    
    //Get the audio data format from the file
    
    UInt32  propSize = sizeof(player.inputFormat);
    
    CheckError(AudioFileGetProperty(player.inputFile, kAudioFilePropertyDataFormat, &propSize, &player.inputFormat), "Could not get file's data format");
    
    
    
    // Build a basic fileplayer->speakers graph
    CreateMyAUGraph(&player);
    
    // Configure the file player
    Float64 fileDuration = PrepareFileAU(&player);
    
    //Start Playing
    CheckError(AUGraphStart(player.graph),
               "AUGraphStart failed");
    
    //Sleep until the file is finished
    usleep((int)(fileDuration * 1000.0 * 1000.0));
    
    //CleanUp
    
    AUGraphStop(player.graph);
    AUGraphUninitialize(player.graph);
    AUGraphClose(player.graph);
    AudioFileClose(player.inputFile);
    
    

    
    
	
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
