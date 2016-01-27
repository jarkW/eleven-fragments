import java.io.File;
import java.io.FilenameFilter;

class UniqueFragmentCheck
{
    
    // Can we move these to local? Where used?
    PImage QAFragment; 
    PImage targetImage;
    //ArrayList<PImage> itemReferenceImageArray = new ArrayList<PImage>();
    boolean okFlag;
    String itemName;
    String itemClassTSID;
    String itemInfo;
    String itemRootName;
    int perfectMatchCount;
    int OKMatchCount;
    float lowest_total_rgb_diff;
    int lowest_total_rgb_diff_x;
    int lowest_total_rgb_diff_y;
    int perfectMatchX;
    int perfectMatchY;
    int OKMatchX;
    int OKMatchY;
    
    boolean debugInfo = true;
    
    int uniqueReferenceX = 0;
    int uniqueReferenceY = 0;
    String uniqueReferenceFile = "";
    
   
    StringList completeItemImagePaths = new StringList();
    
    // Handles searching the full images for the small fragment
    // Might want to pass the class_tsid/info fields from item so that can
    // easily construct the file name. Unless it is easy for me to access
    // using the read functions.
    
    public UniqueFragmentCheck(String classTsid, String info)
    {
        okFlag = true;
        itemClassTSID = classTsid;
        itemInfo = info;
        itemRootName = "";
        perfectMatchCount = 0;
        OKMatchCount = 0;
        lowest_total_rgb_diff_x = 0;
        lowest_total_rgb_diff_y = 0;
        lowest_total_rgb_diff = 0;
        perfectMatchX = 0;
        perfectMatchY= 0;
        OKMatchX = 0;
        OKMatchY = 0;
        uniqueReferenceX = 0;
        uniqueReferenceY = 0;
        uniqueReferenceFile = "";
    
    }
    
    boolean loadFragmentAndComparisonFiles()
    {
        String fileName = "";
        String baseName = "";
        if (itemInfo.length() > 0)
        {
            baseName = itemClassTSID + "_" + itemInfo;
        }
        else
        {
            baseName = itemClassTSID;
        }

        fileName = configInfo.readPngPath() + "/" + baseName + ".png";
        
        // Check can open all the appropriate files
        File file = new File(fileName);
        if (!file.exists())
        { 
            println("Failed to open fragment file - ", fileName);
            return false;
        }
        QAFragment = loadImage(fileName, "png");
        QAFragment.loadPixels();
        
        // This function loads up all the paths of reference files that have the 
        // item class TSID as the root e.g. quoin*.png.
        
        // Need to set up the itemRootName variable before searching the directory
        // Is usually equal to the itemClassTSID, but not always, when want to check
        // e.g. all sorts of metal rock
        switch (itemClassTSID)
        {
            case "trant*":  
                itemRootName = "trant";
                break;
            case "rock_b*":
                itemRootName = "rock_beryl";
                break;
            case "rock_d*":
                itemRootName = "rock_dullite";
                break;                
            case "rock_m*":
                itemRootName = "rock_metal";
                break;            
            case "rock_s*":
                itemRootName = "rock_sparkly";
                break; 
            case "peat*":
                itemRootName = "peat";
                break;
            default:
                itemRootName = itemClassTSID;
                break;
        }

        // NB This function also handles the special cases for trees where items 
        // have to be manually added in
        if (!readListReferenceFileNames(configInfo.readCompleteItemPngPath()))
        {
            println("Failed to load up the reference images for the item ", itemClassTSID);
            return false;
        }
        
        println("Final number of reference image snaps is ", completeItemImagePaths.size());
        
        for (int i = 0; i < completeItemImagePaths.size(); i++)
        {
            println("Reference snap ", i, " is ", completeItemImagePaths.get(i));
        }
        
        return true;
                
    }
    
    
       // Loads up a list of png files with the right street name 
    String[] loadFilenames(String path) 
    {
        File folder = new File(path);
 
        FilenameFilter filenameFilter = new FilenameFilter() 
        {
            public boolean accept(File dir, String name) 
            {
                //if (name.startsWith(streetName) && name.toLowerCase().endsWith("ark2).png"))
                if (name.startsWith(itemRootName))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        };
  
        return folder.list(filenameFilter);
    }

    boolean readListReferenceFileNames(String pathName)
    {      
        String [] itemImagePaths = loadFilenames(pathName);

        if (itemImagePaths.length == 0)
        {
            println("No reference image files found  for item starting ", itemRootName);
            return false;
        }

        println("Number of intitial item reference images is ", itemImagePaths.length);
        
        // Now need to handle the special cases
        // First copy across these images to our global copy of the paths
        for (int i = 0; i < itemImagePaths.length; i++)
        {
            completeItemImagePaths.append(itemImagePaths[i]);
        }

       // Need to do special stuff for trees - as need to check that fragment not in any tree
        // because trees can be replanted in different varieties
        // So need to add in additional reference snaps manually to check
        switch (itemClassTSID)
        {
            case "trant*":
                completeItemImagePaths.append(pathName + "/wood_tree.png");
                completeItemImagePaths.append(pathName + "/paper_tree.png");
                break;
                
            case "wood_tree":
            case "paper_tree":
                completeItemImagePaths.append(pathName + "/trant_spice.png");
                completeItemImagePaths.append(pathName + "/trant_bean.png");
                completeItemImagePaths.append(pathName + "/trant_egg.png");
                completeItemImagePaths.append(pathName + "/trant_bubble.png");
                completeItemImagePaths.append(pathName + "/trant_fruit.png");
                completeItemImagePaths.append(pathName + "/trant_gas.png");
                break;
                
            default:
                break;
        }
        
            
        return true;
    }
    
    //boolean check_fragments_match(PImage sampleImage, PImage referenceImage)
    void check_fragments_match(PImage sampleImage, PImage referenceImage)
    {
            
        float good_enough_total_rgb = 5000;
        //float good_enough_total_rgb = 1000;

        //float good_enough_QQ_total_rgb = 3 * good_enough_total_rgb;
        //float good_enough_QQ_total_rgb = 5 * good_enough_total_rgb;
        float good_enough_QQ_total_rgb = good_enough_total_rgb;
        
        
        
        float total_rgb_diff = 0;
        float rgb_diff = 0;
        float sum_total_rgb_diff = 0;
        int locSample;
        int locReference;
        
        float rSample;
        float gSample;
        float bSample;
        float rReference;
        float gReference;
        float bReference;
        
        int pixelYPosReference;
        int pixelXPosReference;
        int pixelYPosition;
        int pixelXPosition;
        
        boolean debugInfo = true;
        String outputStr;
        PrintToFile printToFile = new PrintToFile();
        
        if (debugInfo)
        {
            
            // Read in existing output file to an array 
            if (!printToFile.ReadExistingOutputFile())
            {
                 failNow = true;
                 return;
            }
        }
        
        for (pixelYPosReference = 0; pixelYPosReference < (referenceImage.height - sampleImage.height); pixelYPosReference++)
        {
            for (pixelXPosReference = 0; pixelXPosReference < (referenceImage.width - sampleImage.width); pixelXPosReference++)
            {
               // Now need to compare the sample with a same-size fragment 
               for (pixelYPosition = 0; pixelYPosition < sampleImage.height; pixelYPosition++) 
                {
                    for (pixelXPosition = 0; pixelXPosition < sampleImage.width; pixelXPosition++) 
                    {
       
                        //int loc = pixelXPosition + (pixelYPosition * streetItemInfo[streetItemCount].sampleWidth);
                        
                        // For reference snap
                        locReference = (pixelXPosReference + pixelXPosition) + ((pixelYPosReference + pixelYPosition) * referenceImage.width);
                        rReference = red(referenceImage.pixels[locReference]);
                        gReference = green(referenceImage.pixels[locReference]);
                        bReference = blue(referenceImage.pixels[locReference]);
            
                        // for sample snap
                        locSample = pixelXPosition + (pixelYPosition * sampleImage.width);
                        rSample = red(sampleImage.pixels[locSample]);
                        gSample = green(sampleImage.pixels[locSample]);
                        bSample = blue(sampleImage.pixels[locSample]);
     
                        rgb_diff = abs(rReference-rSample) + abs (bReference-bSample) + abs(gReference-gSample);
                        total_rgb_diff += abs(rReference-rSample) + abs (bReference-bSample) + abs(gReference-gSample);
            
                        /*
                        if (debugInfo)
                        {
                            outputStr = "Frag Xpos,YPos = " + pixelXPosition + "," + pixelYPosition;
                            outputStr = outputStr + "    RGB reference = " + rReference + ":"  + gReference + ":"  + bReference; 
                            outputStr = outputStr + "    RGB sample = " + rSample + ":"  + gSample + ":"  + bSample; 
                            println(outputStr);
       
                           // print line to file
                           printToFile.printLine(outputStr);
                        }
                        */
                    } // end for pixelXPosition
                } // end for pixelYPosition
                
                if (debugInfo)
                {
                    //outputStr = "Reference snap - total_rgb_diff for " + pixelXPosReference + "," + pixelYPosReference + ": " +  int(total_rgb_diff);
                    //println(outputStr);
 
                    // print line to file
                    //printToFile.printLine(outputStr);
                }
             
                //  finished checking this sample sized piece of reference. So check to see if we have a match
                if (total_rgb_diff == 0)
                {
                    // perfect match
                    perfectMatchX = pixelXPosReference;
                    perfectMatchY= pixelYPosReference;
                    perfectMatchCount++;
                    println("Perfect match found for item at x,y=", perfectMatchX, ",", perfectMatchY, "(perfectMatchCount = ", perfectMatchCount, ")");
                    if (debugInfo)
                    {
                         outputStr = "Perfect match found for item at x,y=" + perfectMatchX + "," + perfectMatchY + "(perfectMatchCount = " + perfectMatchCount + ")";
                         printToFile.printLine(outputStr);
                    }
                }
                else if  (total_rgb_diff < good_enough_total_rgb)
                {
                    // good enough (but need looser check for QQ next)
                    OKMatchX = pixelXPosReference;
                    OKMatchY= pixelYPosReference;
                    OKMatchCount++;
                    sum_total_rgb_diff += total_rgb_diff;
                    println("OK match found for item at x,y=", OKMatchX, ",", OKMatchY, "(total_rgb_diff = ", int(total_rgb_diff), " (OKMatchCount = ", OKMatchCount, ")");
                    if (debugInfo)
                    {
                        outputStr = "OK match found for item at x,y=" + OKMatchX + "," + OKMatchY + "(OKMatchCount = " + OKMatchCount + ")";
                        printToFile.printLine(outputStr);
                    }
                }
                else if (itemClassTSID.equals("marker_qurazy") && (total_rgb_diff < good_enough_QQ_total_rgb))
                {
                    // good enough match
                    OKMatchX = pixelXPosReference;
                    OKMatchY= pixelYPosReference;
                    OKMatchCount++;
                    sum_total_rgb_diff += total_rgb_diff;
                    println("OK match found for QQ item at x,y=", OKMatchX, ",", OKMatchY, "(total_rgb_diff = ", int(total_rgb_diff), " (OKMatchCount = ", OKMatchCount, ")");
                    if (debugInfo)
                    {
                        outputStr = "OK match found for QQ item at x,y=" + OKMatchX + "," + OKMatchY + "(total_rgb_diff = " + str(int(total_rgb_diff)) + "(OKMatchCount = " + OKMatchCount + ")";
                        printToFile.printLine(outputStr);
                    }
                }
                else
                {
                    // Not found a match - but save this value in case the lowest
                    if ((pixelXPosReference == 0) && (pixelYPosReference == 0))
                    {
                        // Save this one always - so overwrite initilised value
                        lowest_total_rgb_diff = total_rgb_diff;
                        lowest_total_rgb_diff_x = pixelXPosReference;
                        lowest_total_rgb_diff_y = pixelYPosReference;
                        //println("No match, but saved x,y=", lowest_total_rgb_diff_x, ",", lowest_total_rgb_diff_y, "(lowest_total_rgb_diff = ", int(lowest_total_rgb_diff));
                        if (debugInfo)
                        {
                            outputStr = "No match, but saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff));
                            //printToFile.printLine(outputStr);
                        }
                    }
                    else if (total_rgb_diff < lowest_total_rgb_diff)
                    {
                        // save this if the lowest one so far
                        lowest_total_rgb_diff = total_rgb_diff;
                        lowest_total_rgb_diff_x = pixelXPosReference;
                        lowest_total_rgb_diff_y = pixelYPosReference;
                         //println("No match, but saved x,y=", lowest_total_rgb_diff_x, ",", lowest_total_rgb_diff_y, "(lowest_total_rgb_diff = ", int(lowest_total_rgb_diff));
                        if (debugInfo)
                        {
                            outputStr = "No match, but saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff));
                            //printToFile.printLine(outputStr);
                        }
                    }        
                    sum_total_rgb_diff += total_rgb_diff;
                }
                
                // reset the counts ready for the next pass
                total_rgb_diff = 0;
                
            } // end for pixelXPosReference
        } // end for pixelYPosReference
        
        if (debugInfo)
        {
            // close stream
            printToFile.flushOutputFile();
            printToFile.closeOutputFile();
        }
    }
    
    
    
    
    public boolean fragmentIsUnique()
    {
        // Now need to check each of the reference snaps against the one to be saved. 
        // Should be 1 unique hit for the expected reference snap
        //PImage targetImage;
        
        for (int i = 0; i < completeItemImagePaths.size(); i++)
        {
            targetImage = loadImage(configInfo.readCompleteItemPngPath()+"/"+completeItemImagePaths.get(i), "png");
            println("Using reference file ",configInfo.readCompleteItemPngPath()+"/"+completeItemImagePaths.get(i));
            targetImage.loadPixels();
            
            // Search for item image in this larger file
            check_fragments_match(QAFragment, targetImage);
            
            println("Reference ", completeItemImagePaths.get(i), " has perfectMatchCount=", perfectMatchCount, " at x,y=", perfectMatchX, ",", perfectMatchY, " OKMatchCount= ", OKMatchCount, " at x,y=", OKMatchX, ",", OKMatchY);
            if (perfectMatchCount > 0)
            {
                uniqueReferenceX = perfectMatchX;
                uniqueReferenceY = perfectMatchY;
                uniqueReferenceFile = configInfo.readCompleteItemPngPath()+"/"+completeItemImagePaths.get(i);
            }
            else if (OKMatchCount > 0)
            {
                uniqueReferenceX = OKMatchX;
                uniqueReferenceY = OKMatchY;
                uniqueReferenceFile = configInfo.readCompleteItemPngPath()+"/"+completeItemImagePaths.get(i);
            }
        }
       
        
        
        if ((OKMatchCount + perfectMatchCount) == 1)
        {
            println ("Found single matching point in this reference snap");
            return true;
        }
        else
        {
            return false;
        }
    }

    
    public boolean readOkFlag()
    {
        return okFlag;
    }
}