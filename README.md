This distribution contains code for running the adaboost algorithm as 
described in the Viola and Jones adaboost paper.  Everything is implemented
except for the cascade of classifiers.  

Thresholds for the classifiers are found using a weighted histogram
as opposed to fitting a Gaussian distribution.  There are two separate modes
for boosting the classifier.  



Notes on Running:

1)  The program includes external code for calculating a weighted histogram.
    This code need to be compiled before running the program.  This is a 
    simple process.  Go into the lib directory and compile the whistc mex 
    file.  To do this, just run the following command:

        mex whistc.c

2)  The script main.m in the base directory will run experiments.
    There are configuration paramters that
    can be set at the top of the file including things such as the size of
    the histogram bins, the number of iterations to train for and the 
    minimum size of the filters.  They are described in main.m.

3)  The source code of the functions are broken into three subdirectories 
    within the 'src' directory:
        - adaboost  : The core adaboost functions
        - util      : Utility functions such as creating a pyramid, normalizing
                        images or plotting tools
        - writeup   : Functions specifically used to create the graphs
                        for the writeup.

    These subdirectories need to be included in the source path.  This is done inside of
    main.m.  You can look there for how to do it if you would like to run your own script
    to run the adaboost code.

4) For efficiency, after the images are read in the first time using 
    loadImages, a .mat file called images.mat is saved into the data 
    directory.  When loadImages is called a second time, the images
    are loaded from the .mat file instead of from disk.  This is 
    significantly faster.  (It was quite useful to save time while 
    debugging.)  The same mechanism is in place for the filters.  A 
    .mat file is saved for each minimum size of filters.  (ie filters_3.mat
    filters_2.mat etc)

 5) A data directory needs to be created at the root of the project
    (along side lib, src and writeup).  Inside the data directory needs to be 
    placed two directories, "Face16" and "Nonface16".  Inside of these directories,
    you need to put all of the face and non face images as 16x16 pixel bmp files.
    Inside of the data directory also should be placed the testing image named "class_photo.jpg".
