
/* This code was adapted from the sample files provided in the Emotient SDK
and it is meant to work within the toolbox fex-metrica.
fexfacet_face output the following variables: 

(1) File information (filename; file_width; file_hight)
(2) Landmarks locations (TopLeft_X; TopLeft_Y; Width; Height;
    left_eye_lateral_X; left_eye_lateral_Y; left_eye_pupil_X; left_eye_pupil_Y;
    left_eye_medial_X; left_eye_medial_Y; right_eye_medial_X;right_eye_medial_Y;
    right_eye_pupil_X; right_eye_pupil_Yl; right_eye_lateral_X; right_eye_lateral_Y
    nose_tip_X; nose_tip_Y
(3) Pose information (Roll; Pitch; Yaw).

-- version 06/01/2014

Code adapted by 
Filippo Rossi, Institute for Neural Computation,
University of California San Diego.
Contact info: frossi@ucsd.edu */


#include <opencv2/opencv.hpp>
#include <iostream>
#include "config.hpp"
#include "tools.hpp"
#include "emotient.hpp"


int main ()
{
    using namespace EMOTIENT;

    int retVal;
    //Initialize the frame analysis engine
    FacetSDK::FrameAnalyzer frameAnalyzer;
    frameAnalyzer.SetMaxThreads(4);
    retVal = frameAnalyzer.Initialize(FACETSDIR, "FrameAnalyzerConfig.json");
    if (retVal != FacetSDK::SUCCESS) {
        std::cout << "Could not initialize the FrameAnalyzer" << std::endl;
        std::cout << "Check that FACETSDIR is pointing to the correct location relative to the working directory." << std::endl;
        std::cout << "Error code = " << FacetSDK::DefineErrorCode(retVal) << std::endl;
        exit(retVal);
    }
    // Note that the header of the file is added in Matlab  using fex_fhead.m, and it is not provided by the cpp code.

    while (std::cin.good()) {
        std::string filename;
        std::cin >> filename;
        // OpenCV code for reading image
        cv::Mat frame = cv::imread(filename);
        if(frame.rows== 0 || frame.cols == 0){
            std::cout << "file " << filename << " could not be opened as an image." << std::endl;
        }
        else {
            // Convert the image to grayscale (required)
            cv::Mat grayFrame;
            cvtColorSafe(frame, grayFrame);
            // add filename, file width and file hight to the output
            std::cout << filename << "\t" << grayFrame.rows << "\t" << grayFrame.cols << "\t";
            FacetSDK::FrameAnalysis frameAnalysis;
            frameAnalyzer.Analyze(grayFrame.data, grayFrame.rows, grayFrame.cols, frameAnalysis);
            if (frameAnalysis.NumFaces() > 0) {
                // Analyze the largest face
                FacetSDK::Face face;
                frameAnalysis.LargestFace(face);
                FacetSDK::Rectangle faceLocation;
                face.FaceLocation(faceLocation);
                // Print out detected face box coordinates for largest face
                std::cout << faceLocation.x << "\t" << faceLocation.y <<
                         "\t" << faceLocation.width << "\t" << faceLocation.height << "\t";
                         
            if (frameAnalyzer.IsChannelAvailable(FacetSDK::LANDMARKS)) {
            // Print landmarks location
                    std::vector<FacetSDK::LandmarkName> lmnames = FacetSDK::AllLandmarkNames();
                    for (size_t i = 0; i < lmnames.size(); i++) {
                        std::cout << face.LandmarkLocation(lmnames[i]).x <<"\t";
                        std::cout << face.LandmarkLocation(lmnames[i]).y <<"\t";
                    }
                }
            if (frameAnalyzer.IsChannelAvailable(FacetSDK::POSE)) {
            // Print pose information
                    std::cout << face.PoseValue(FacetSDK::ROLL) <<"\t";
                    std::cout << face.PoseValue(FacetSDK::PITCH) <<"\t";
                    std::cout << face.PoseValue(FacetSDK::YAW);
                }
            std::cout << std::endl;
            }
            else {
            std::cout << nan << std::endl;
        }
        }
    }
}
