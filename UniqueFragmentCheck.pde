import java.io.File;
import java.io.FilenameFilter;

class UniqueFragmentCheck
{
    PImage QAFragment; 
    //PImage targetImage;
    //ArrayList<PImage> itemReferenceImageArray = new ArrayList<PImage>();
    boolean okFlag;
    String itemName;
    String itemClassTSID;
    String itemInfo;
    String itemRootName;
    float lowest_total_rgb_diff;
    int lowest_total_rgb_diff_x;
    int lowest_total_rgb_diff_y;
        
    int uniqueReferenceX = 0;
    int uniqueReferenceY = 0;
    String uniqueReferenceFile = "";
    
    ArrayList<FoundMatch> allFoundMatches;
    StringList completeItemImagePaths = new StringList();
    
    // Handles searching the full images for the small fragment
    // Might want to pass the class_tsid/info fields from item so that can
    // easily construct the file name. Unless it is easy for me to access
    // using the read functions.
    
    public UniqueFragmentCheck(String classTsid, String info, PImage QASnapFragment)
    {
        okFlag = true;
        itemClassTSID = classTsid;
        itemInfo = info;
        itemRootName = "";
        lowest_total_rgb_diff_x = 0;
        lowest_total_rgb_diff_y = 0;
        lowest_total_rgb_diff = 0;
        uniqueReferenceX = 0;
        uniqueReferenceY = 0;
        uniqueReferenceFile = "";
        QAFragment = QASnapFragment;
        QAFragment.loadPixels();
        allFoundMatches = new ArrayList<FoundMatch>();    
    }
    
    boolean loadComparisonFiles()
    {
       
        // This function loads up all the paths of reference files that have the 
        // item class TSID as the root e.g. quoin*.png.
        
        // Need to set up the itemRootName variable before searching the directory
        // Is usually equal to the itemClassTSID, but not always, when want to check
        // e.g. all sorts of metal rock
        switch (itemClassTSID)
        {
            case "trant_spice":
            case "trant_bean":
            case "trant_egg":
            case "trant_bubble":
            case "trant_fruit":
            case "trant_gas":
                itemRootName = "trant";
                break;
            case "rock_beryl_1":
            case "rock_beryl_2":
            case "rock_beryl_3":
                itemRootName = "rock_beryl";
                break;
            case "rock_dullite_1":
            case "rock_dullite_2":
            case "rock_dullite_3":
                itemRootName = "rock_dullite";
                break;                
            case "rock_metal_1":
            case "rock_metal_2":
            case "rock_metal_3":
                itemRootName = "rock_metal";
                break;            
            case "rock_sparkly_1":
            case "rock_sparkly_2":
            case "rock_sparkly_3":
                itemRootName = "rock_sparkly";
                break; 
            case "peat_1":
            case "peat_2":
            case "peat_3":
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
            printDebugToFile.printLine("Failed to load up the reference images for the item " + itemClassTSID, 3);
            return false;
        }
        
        printDebugToFile.printLine("Final number of reference image snaps is " + str(completeItemImagePaths.size()), 2);
        
        for (int i = 0; i < completeItemImagePaths.size(); i++)
        {
            printDebugToFile.printLine("Reference snap " + str(i) + " is " + completeItemImagePaths.get(i), 1);
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
        String [] itemImageFiles = loadFilenames(pathName);

        if (itemImageFiles.length == 0)
        {
            printDebugToFile.printLine("No reference image files found  for item starting "  + itemRootName, 3);
            return false;
        }
        
        printDebugToFile.printLine("Number of intitial item reference images is " + str(itemImageFiles.length), 1);
        
        // Now need to handle the special cases
        // First copy across these images to our global copy of the paths
        for (int i = 0; i < itemImageFiles.length; i++)
        {
            completeItemImagePaths.append(itemImageFiles[i]);
            printDebugToFile.printLine("Initial reference item " + str(i) + " is " + itemImageFiles[i], 1);
        }

       // Need to do special stuff for trees - as need to check that fragment not in any tree
        // because trees can be replanted in different varieties
        // So need to add in additional reference snaps manually to check

        switch (itemClassTSID)
        {
            case "trant_spice":
            case "trant_bean":
            case "trant_egg":
            case "trant_bubble":
            case "trant_fruit":
            case "trant_gas":
                completeItemImagePaths.append("wood_tree_1_complete.png");
                completeItemImagePaths.append("wood_tree_2_complete.png");
                completeItemImagePaths.append("wood_tree_3_complete.png");
                completeItemImagePaths.append("wood_tree_4_complete.png");
                completeItemImagePaths.append("paper_tree_complete.png");
                break;
                
            case "wood_tree":
            case "paper_tree":
                completeItemImagePaths.append("trant_spice_complete.png");
                completeItemImagePaths.append("trant_bean_complete.png");
                completeItemImagePaths.append("trant_egg_complete.png");
                completeItemImagePaths.append("trant_bubble_complete.png");
                completeItemImagePaths.append("trant_fruit_complete.png");
                completeItemImagePaths.append("trant_gas_complete.png");
                break;
                
            default:
                break;
        }
 
        for (int i = 0; i < completeItemImagePaths.size(); i++)
        {
            printDebugToFile.printLine("Final list reference item " + str(i) + " is " + completeItemImagePaths.get(i), 1);
        }
            
        return true;
    }
    
    int checkFragmentsMatch(PImage sampleImage, PImage referenceImage, String referenceFileName)
    {
            
        float good_enough_total_rgb = 5000;
        //float good_enough_total_rgb = 1000;

        //float good_enough_QQ_total_rgb = 3 * good_enough_total_rgb;
        //float good_enough_QQ_total_rgb = 5 * good_enough_total_rgb;
        float good_enough_QQ_total_rgb = good_enough_total_rgb;
        
        float total_rgb_diff = 0;
        float rgb_diff = 0;
        float sum_total_rgb_diff = 0;
        int numMatchesFound = 0;
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
                
        boolean debugInfo = false;
        String outputStr;
        
        ArrayList<FoundMatch> snapFoundMatches = new ArrayList<FoundMatch>();

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
                            printDebugToFile.printLine(outputStr, 1); 
                        } */
  
                    } // end for pixelXPosition
                } // end for pixelYPosition
                
                if (debugInfo)
                {
                    outputStr = "Reference snap - total_rgb_diff for " + pixelXPosReference + "," + pixelYPosReference + ": " +  int(total_rgb_diff);
                    printDebugToFile.printLine(outputStr, 1);
                }
             
                //  finished checking this sample sized piece of reference. So check to see if we have a match
                if (total_rgb_diff == 0)
                {
                    // perfect match                  
                    // add to the array
                    snapFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, true, referenceFileName, total_rgb_diff));
                    allFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, true, referenceFileName, total_rgb_diff));
                    outputStr = "Perfect match found for item at x,y=" + pixelXPosReference + "," + pixelYPosReference;
                    printDebugToFile.printLine(outputStr, 1);
                }
                else if  (total_rgb_diff < good_enough_total_rgb)
                {
                    // good enough (but need looser check for QQ next)
                    // add to the array
                    snapFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff)); 
                    allFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff));
                    sum_total_rgb_diff += total_rgb_diff;
                    outputStr = "OK match found for item at x,y="  + pixelXPosReference + "," + pixelYPosReference + "with rgb diff " + int(total_rgb_diff);
                    printDebugToFile.printLine(outputStr, 1);
                 }
                else if (itemClassTSID.equals("marker_qurazy") && (total_rgb_diff < good_enough_QQ_total_rgb))
                {
                    // good enough match
                    // add to the array
                    snapFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff)); 
                    allFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff));
                    sum_total_rgb_diff += total_rgb_diff;
                    outputStr = "OK match found for QQ item at x,y="  + pixelXPosReference + "," + pixelYPosReference + "with rgb diff " + int(total_rgb_diff);
                    printDebugToFile.printLine(outputStr, 1);
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
                        if (debugInfo)
                        {
                            outputStr = "No match, but first one, so saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff));
                            printDebugToFile.printLine(outputStr, 1);
                        }
                    }
                    else if (total_rgb_diff < lowest_total_rgb_diff)
                    {
                        // save this if the lowest one so far
                        lowest_total_rgb_diff = total_rgb_diff;
                        lowest_total_rgb_diff_x = pixelXPosReference;
                        lowest_total_rgb_diff_y = pixelYPosReference;
                        if (debugInfo)
                        {
                            outputStr = "No match, but lowest so far so saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff));
                            printDebugToFile.printLine(outputStr, 1);
                        }
                    }        
                    sum_total_rgb_diff += total_rgb_diff;
                }
                
                // reset the counts ready for the next pass
                total_rgb_diff = 0;
                
            } // end for pixelXPosReference
        } // end for pixelYPosReference
  
       if (snapFoundMatches.size() > 0)
       {
           printDebugToFile.printLine("Number of OK/perfect matches found is " + snapFoundMatches.size() + " for this snap " + referenceFileName, 2);
       }
       else
       {
           printDebugToFile.printLine("No matches found for this snap " + referenceFileName, 2);
       }
       
       return(snapFoundMatches.size());
    }
            
    void saveAndDisplayFoundMatch (FoundMatch foundMatch, int screenX, int screenY)
    {
        PImage matchImage;
        String matchFname;
        String s;
        PImage refImage;          
           
        refImage = loadImage(configInfo.readCompleteItemPngPath()+"/"+foundMatch.refFname, "png");
        refImage.loadPixels();
        matchImage = refImage.get(foundMatch.matchX, foundMatch.matchY, QAFragment.width, QAFragment.height); 
        image(matchImage, screenX, screenY); 
        fill(50);
                        
        if (foundMatch.isPerfect)
        {
            s = "Perfect at " + str(foundMatch.matchX) + "," + str(foundMatch.matchY);
            matchFname = foundMatch.refFname.replace(".png", "") + "_perfect_" + str(foundMatch.matchX) + "_" + str(foundMatch.matchY) + ".png";
        }
        else
        {
            s = "OK at " + str(foundMatch.matchX) + "," + str(foundMatch.matchY)+ " total RGB diff =" + str(int(foundMatch.totalRGBDiff));
            matchFname = foundMatch.refFname.replace(".png", "") + "_OK_" + str(foundMatch.matchX) + "_" + str(foundMatch.matchY) + ".png";
        }
        text(s, screenX, screenY + 30, screenX + 50, screenY + 50);  // Text wraps within text box
        printDebugToFile.printLine(s, 2);
        
        // Also save image to file
        //matchImage.save(dataPath(matchFname));
    }
     
    public boolean fragmentIsUnique()
    {
        // Now need to check each of the reference snaps against the one to be saved. 
        // Should be 1 unique hit for the expected reference snap
        PImage targetImage;
        String outputStr;
        PImage matchImage;
        int displayX = 550;
        int displayY = 500;    
        int numMatches = 0;
        
        
        for (int i = 0; i < completeItemImagePaths.size(); i++)
        {
            targetImage = loadImage(configInfo.readCompleteItemPngPath()+"/"+completeItemImagePaths.get(i), "png");
            printDebugToFile.printLine("Using reference file " + configInfo.readCompleteItemPngPath()+"/"+completeItemImagePaths.get(i), 2);
            targetImage.loadPixels();
            
            // Search for item image in this larger file
            numMatches = checkFragmentsMatch(QAFragment, targetImage, completeItemImagePaths.get(i));
            
            if (numMatches > 0)
            {
                outputStr = "Reference " + completeItemImagePaths.get(i) + "has size allFoundMatches " + allFoundMatches.size();
                printDebugToFile.printLine(outputStr, 2);
            }
        }
             
       // Now dump out contents of the array list to see how many exact/good enough matches found
       for (int j = 0; j < allFoundMatches.size(); j++)
       {
           saveAndDisplayFoundMatch(allFoundMatches.get(j), displayX, displayY);
           displayY += QAFragment.height + 60;
           
           
           // only need these vars to make string simpler
           int x = allFoundMatches.get(j).matchX;
           int y = allFoundMatches.get(j).matchY;
           String fname = allFoundMatches.get(j).refFname;
           float rgbDiff = allFoundMatches.get(j).totalRGBDiff;
           
           
           targetImage = loadImage(configInfo.readCompleteItemPngPath()+"/"+fname, "png");
           targetImage.loadPixels();
                      
           // Now output the images found so can see them on the screen
           if (allFoundMatches.get(j).isPerfect)
           {
               printDebugToFile.printLine("Perfect match found for x,y " + str(x) + "," + str(y) + "in file " + fname, 2);
           }
           else
           {
               printDebugToFile.printLine("OK match found (total RGB diff = " + str(int(rgbDiff)) + ") for x,y " + str(x) + "," + str(y) + " in file " + fname, 2);
           }

       }
        
        if (allFoundMatches.size() == 1)
        {
            printDebugToFile.printLine("Found single matching point in this reference snap", 2);
            uniqueReferenceX = allFoundMatches.get(0).matchX;
            uniqueReferenceY = allFoundMatches.get(0).matchY;
            uniqueReferenceFile = configInfo.readCompleteItemPngPath()+"/"+allFoundMatches.get(0).refFname;
            return true;
        }
        else  
        {
            printDebugToFile.printLine("Found " + str(allFoundMatches.size()) + " multiple matching point in this reference snap", 2);
            return false;
        }
    }

    
    public boolean readOkFlag()
    {
        return okFlag;
    }
    
    class FoundMatch
    {
        int matchX;
        int matchY;
        boolean isPerfect;
        String refFname;
        float totalRGBDiff;
        
        FoundMatch(int x, int y, boolean perfectFlag, String referenceFile, float rgbDiff)
        {
            matchX = x;
            matchY = y;
            isPerfect = perfectFlag;
            refFname = referenceFile;
            totalRGBDiff = rgbDiff;
        }
    }
}