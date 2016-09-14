% LOAD_IMAGES - load the images.  Assumes the images are bmp.
%
% [faceImages nonFaceImages] = load_images() load the images from
% `pwd`/data
%
% This also will save the loaded images to a matlab file and load them
% from that file if it exists.  This is a big time saver.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007

function [faceImages nonFaceImages testingImage] = loadImages(BASE_DIR)

FACE_DIR = sprintf('%s%s%s',BASE_DIR,'face16',filesep);
NON_FACE_DIR = sprintf('%s%s%s',BASE_DIR,'Nonface16',filesep);
OUTPUT_FILE = sprintf('%s%s',BASE_DIR,'images.mat');

fprintf('**************** Loading Data ****************\n');

if (exist(OUTPUT_FILE,'file')) 
    fprintf('Loading from %s.',OUTPUT_FILE);
    load(OUTPUT_FILE);
else
    files = dir(sprintf('%s%s',FACE_DIR,'*.bmp'));

    h = waitbar(0,sprintf('Loading face image [%d/%d]',1,length(files))); 
    faceImages = zeros(16,16,length(files));
    for i=1:length(files)
        
        if (mod(i,25) == 0)
            waitbar(i / length(files),h,sprintf('Loading face image [%d/%d]',i,length(files)));
        end
        
        faceImages(:,:,i) = double(imread(sprintf('%s%s',FACE_DIR,files(i).name)));
    end
    
    fprintf('\n');

    files = dir(sprintf('%s%s',NON_FACE_DIR,'*.bmp'));
    numFiles = length(files);
    nonFaceImages = zeros(16,16,numFiles);
    for i=1:numFiles
        if (mod(i,25) == 0)
            waitbar(i / length(files),h,sprintf('Loading non face Image [%d/%d]',i,length(files)));
        end
        nonFaceImages(:,:,i) = double(imread(sprintf('%s%s',NON_FACE_DIR,files(i).name)));
    end
    
    close(h);
    
    testingImage = double(rgb2gray(imread(sprintf('%s%s',BASE_DIR,'class_photo.jpg'))));
    
    fprintf('\nSaving testingImage, faceImages and nonFaceImages to %s.',OUTPUT_FILE);
    save(OUTPUT_FILE,'testingImage','faceImages','nonFaceImages');
end

fprintf('\n');
end