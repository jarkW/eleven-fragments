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
    String itemState;
    String itemRootName2;
    float lowest_total_rgb_diff;
    float lowest_avg_rgb_diff;
    int lowest_total_rgb_diff_x;
    int lowest_total_rgb_diff_y;
        
    int uniqueReferenceX = 0;
    int uniqueReferenceY = 0;
    String uniqueReferenceFile = "";
    String errorMsg = "";
    
    String rootItemImagePath;
    
    ArrayList<FoundMatch> allFoundMatches;
    StringList completeItemImagePaths = new StringList();
    
    // Handles searching the full images for the small fragment
    // Might want to pass the class_tsid/info fields from item so that can
    // easily construct the file name. Unless it is easy for me to access
    // using the read functions.
    
    public UniqueFragmentCheck(String classTsid, String info, String state, PImage QASnapFragment)
    {
        okFlag = true;
        itemClassTSID = classTsid;
        itemInfo = info;
        itemState = state;
        itemRootName = "";
        itemRootName2 = "";
        lowest_total_rgb_diff_x = 0;
        lowest_total_rgb_diff_y = 0;
        lowest_total_rgb_diff = 0;
        lowest_avg_rgb_diff = 0;
        uniqueReferenceX = 0;
        uniqueReferenceY = 0;
        uniqueReferenceFile = "";
        QAFragment = QASnapFragment;
        
        if (configInfo.readQuoinHeightsOnly())
        {
            rootItemImagePath = configInfo.readPngPath();
        }
        else
        {
            rootItemImagePath = configInfo.readCompleteItemPngPath();
        }
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
            case "trant_spice_dead":
            case "trant_bean_dead":
            case "trant_egg_dead":
            case "trant_bubble_dead":
            case "trant_fruit_dead":
            case "trant_gas_dead":
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
        if (!readListReferenceFileNames(rootItemImagePath))
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
    
    boolean loadExistingQuoinFragmentFile()
    {
       
        // This function loads up the image of the quoin fragment that has already been saved - so can check it exactly matches the one
        // the user has chosen when doing y-offset only
        switch (itemClassTSID)
        {
            case "quoin":
                completeItemImagePaths.append(itemClassTSID + "_" + itemInfo + ".png");
                break;
                
            case "marker_qurazy":
                // Can't use these ones below - as then real use of this tool fails because the image doesn't match the street snap
                // Easier just to use a single image of a quoin
                completeItemImagePaths.append("marker_qurazy.png");
                //completeItemImagePaths.append("marker_qurazy_lge.png");
                //completeItemImagePaths.append("marker_qurazy_med.png");
                //completeItemImagePaths.append("marker_qurazy_sml.png");
                break;                

            default:
                printDebugToFile.printLine("Unexpected item passed to loadExistingQuoinFragmentFile " + itemClassTSID, 3);
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
    
    // Loads up a list of png files with the right street name - uses the secondary root name
    String[] loadFilenames2(String path) 
    {
        File folder = new File(path);
 
        FilenameFilter filenameFilter = new FilenameFilter() 
        {
            public boolean accept(File dir, String name) 
            {
                if (name.startsWith(itemRootName2))
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
        // Load up images for primary root
        String [] itemImageFiles = loadFilenames(pathName);
        int i;

        if (itemImageFiles.length == 0)
        {
            printDebugToFile.printLine("No reference image files found  for item starting "  + itemRootName, 3);
            return false;
        }
        
        printDebugToFile.printLine("Number of intitial item reference images for this root " + itemRootName + " is " + str(itemImageFiles.length), 1);
        
        // Now need to handle the special cases
        // First copy across these images to our global copy of the paths
        for (i = 0; i < itemImageFiles.length; i++)
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
            case "trant_spice_dead":
            case "trant_bean_dead":
            case "trant_egg_dead":
            case "trant_bubble_dead":
            case "trant_fruit_dead":
            case "trant_gas_dead":
                // Load up additional trees
                if (!loadUpAdditionalImages(pathName, "wood_tree"))
                {
                    return false;
                } 
                completeItemImagePaths.append("paper_tree_complete.png");
                break;
                
            case "wood_tree":
            case "paper_tree":
                 // Load up additional trees
                if (!loadUpAdditionalImages(pathName, "trant"))
                {
                    return false;
                }            
                break;
                
            case "npc_sloth":
                // NB These are images of trees taken from streets which are searched - to check we haven't accidentally matched up pixels on a background branch
                completeItemImagePaths.append("sloth_tree1_complete.png");
                completeItemImagePaths.append("sloth_tree2_complete.png");
                completeItemImagePaths.append("sloth_tree3_complete.png");
                break;
                
            case "sloth_knocker":
                completeItemImagePaths.append("sloth_tree1_complete.png");
                completeItemImagePaths.append("sloth_tree2_complete.png");
                completeItemImagePaths.append("sloth_tree3_complete.png");
                break;
           
            default:
                break;
        }
 
        for (i = 0; i < completeItemImagePaths.size(); i++)
        {
            printDebugToFile.printLine("Final list reference item " + str(i) + " is " + completeItemImagePaths.get(i), 1);
        }
            
        return true;
    }
    
    boolean loadUpAdditionalImages(String pathName, String itemRoot)
    {
        itemRootName2 = itemRoot;
        String [] itemImageFiles2 = loadFilenames2(pathName);
        
        if (itemImageFiles2.length == 0)
        {
            printDebugToFile.printLine("No reference image files found  for item starting "  + itemRootName2, 3);
            return false;
        }

        printDebugToFile.printLine("Number of intitial item reference images for this root " + itemRootName2 + " is " + str(itemImageFiles2.length), 1);

        // Now need to handle the special cases
        // First copy across these images to our global copy of the paths
        for (int i = 0; i < itemImageFiles2.length; i++)
        {
            completeItemImagePaths.append(itemImageFiles2[i]);
            printDebugToFile.printLine("Initial reference item " + str(i) + " is " + itemImageFiles2[i], 1);
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
        int numMatchesFound = 0;
        int locSample;
        int locReference;
               
        float rSample;
        float gSample;
        float bSample;
        float aSample;
        float rReference;
        float gReference;
        float bReference;
        float aReference;
        
        int pixelYPosReference;
        int pixelXPosReference;
        int pixelYPosition;
        int pixelXPosition;
        
        int numberTransparentPixels = 0;
                
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
                        aReference = alpha(referenceImage.pixels[locReference]);
            
                        // for sample snap
                        locSample = pixelXPosition + (pixelYPosition * sampleImage.width);
                        rSample = red(sampleImage.pixels[locSample]);
                        gSample = green(sampleImage.pixels[locSample]);
                        bSample = blue(sampleImage.pixels[locSample]);
                        aSample = alpha(sampleImage.pixels[locSample]);  
                        
                        if (aSample == 255)
                        {
                             // transparency is not present in in the fragment, so carry out a diff   
                            rgb_diff = abs(rReference-rSample) + abs (bReference-bSample) + abs(gReference-gSample) + abs(aReference-aSample);
                            total_rgb_diff += rgb_diff;
                        }
                        else
                        {
                            // Transparent pixel, so nothing to compare
                            numberTransparentPixels++;
                        }
                        
                        /*
                        if ((aSample == 255) && (aReference == 255))
                        {
                             // transparency is not present in either of the 2 pixels, so OK to do comparison       
                            rgb_diff = abs(rReference-rSample) + abs (bReference-bSample) + abs(gReference-gSample);
                            total_rgb_diff += rgb_diff;
                        }
                        else
                        {
                            rgb_diff = abs(rReference-rSample) + abs (bReference-bSample) + abs(gReference-gSample) + abs(aReference-aSample);
                            total_rgb_diff += rgb_diff;
                        }
                        */
                        /*
                        else if ((aSample != 255) && (aReference != 255))
                        {
                            // both pixels are transparent
                            numberTransparentPixels++;
                        }
                        else if (aSample != 255)
                        {
                            // sample has transparent pixel, street does not - so skip test
                            numberTransparentPixels++;
                        }
                        else if (aReference != 255)
                        {
                            // street image is transparent, sample is not
                            // Treat as mismatch
                            //rgb_diff = abs(rReference-rSample) + abs (bReference-bSample) + abs(gReference-gSample) + abs(aReference-aSample);
                            //total_rgb_diff += rgb_diff; 
                            numberTransparentPixels++;
                        }
                        */
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
                
                float avgRGBDiff = total_rgb_diff/((sampleImage.width*sampleImage.height) - numberTransparentPixels);
                //  finished checking this sample sized piece of reference. So check to see if we have a match
                if (total_rgb_diff == 0)
                {
                    // perfect match                  
                    // add to the array
                    snapFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, true, referenceFileName, total_rgb_diff, avgRGBDiff));
                    allFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, true, referenceFileName, total_rgb_diff, avgRGBDiff));
                    outputStr = "Perfect match found for item at x,y=" + pixelXPosReference + "," + pixelYPosReference;
                    printDebugToFile.printLine(outputStr, 1);
                }
                else if  (total_rgb_diff < good_enough_total_rgb)
                {
                    // good enough (but need looser check for QQ next)
                    // add to the array            
                    snapFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff, avgRGBDiff)); 
                    allFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff, avgRGBDiff));
                    outputStr = "OK match found for item at x,y="  + pixelXPosReference + "," + pixelYPosReference + " with rgb diff " + int(total_rgb_diff) + " avg rgb = " + int(avgRGBDiff);
                    printDebugToFile.printLine(outputStr, 1);
                 }
                else if (itemClassTSID.equals("marker_qurazy") && (total_rgb_diff < good_enough_QQ_total_rgb))
                {
                    // good enough match
                    // add to the array
                    snapFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff, avgRGBDiff)); 
                    allFoundMatches.add(new FoundMatch(pixelXPosReference, pixelYPosReference, false, referenceFileName, total_rgb_diff, avgRGBDiff));
                    outputStr = "OK match found for QQ item at x,y="  + pixelXPosReference + "," + pixelYPosReference + " with rgb diff " + int(total_rgb_diff) + " avg rgb = " + int(avgRGBDiff);
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
                        lowest_avg_rgb_diff = avgRGBDiff;
                        if (debugInfo)
                        {
                            outputStr = "No match, but first one, so saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff)) + " avg rgb = " + int(avgRGBDiff);
                            printDebugToFile.printLine(outputStr, 1);
                        }
                    }
                    else if (total_rgb_diff < lowest_total_rgb_diff)
                    {
                        // save this if the lowest one so far
                        lowest_total_rgb_diff = total_rgb_diff;
                        lowest_total_rgb_diff_x = pixelXPosReference;
                        lowest_total_rgb_diff_y = pixelYPosReference;
                        lowest_avg_rgb_diff = avgRGBDiff;
                        if (debugInfo)
                        {
                            outputStr = "No match, but lowest so far so saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff)) + " avg rgb = " + int(avgRGBDiff);
                            printDebugToFile.printLine(outputStr, 1);
                        }
                    }        
                }
                
                // reset the counts ready for the next pass
                total_rgb_diff = 0;
                numberTransparentPixels = 0;
                
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
    
    int checkQuoinFragmentsMatchExactly(PImage sampleImage, PImage referenceImage, String referenceFileName)
    {
            
        float good_enough_total_rgb = 5000;
        //float good_enough_total_rgb = 1000;

        //float good_enough_QQ_total_rgb = 3 * good_enough_total_rgb;
        //float good_enough_QQ_total_rgb = 5 * good_enough_total_rgb;
        float good_enough_QQ_total_rgb = good_enough_total_rgb;
        
        float total_rgb_diff = 0;
        float rgb_diff = 0;
        int numMatchesFound = 0;
        int loc;
               
        float rSample;
        float gSample;
        float bSample;
        float aSample;
        float rReference;
        float gReference;
        float bReference;
        float aReference;
        
        int pixelYPosition;
        int pixelXPosition;
        
        int numberTransparentPixels = 0;
                
        boolean debugInfo = true;
        String outputStr;
        
        ArrayList<FoundMatch> snapFoundMatches = new ArrayList<FoundMatch>();
        
        if ((referenceImage.height != sampleImage.height) || (referenceImage.width != sampleImage.width))
        {
            printDebugToFile.printLine("Mismatch in wxh - reference Image = " + referenceImage.width + "x" + referenceImage.height + " sample image = " + sampleImage.width + "x" + sampleImage.height, 3);
            return 0;
        }

        // Now need to compare the sample with a same-size fragment 
        for (pixelYPosition = 0; pixelYPosition < sampleImage.height; pixelYPosition++) 
        {
            for (pixelXPosition = 0; pixelXPosition < sampleImage.width; pixelXPosition++) 
            {
   
                //int loc = pixelXPosition + (pixelYPosition * streetItemInfo[streetItemCount].sampleWidth);
                
                // For reference snap
                loc = pixelXPosition + (pixelYPosition * sampleImage.width);
                rReference = red(referenceImage.pixels[loc]);
                gReference = green(referenceImage.pixels[loc]);
                bReference = blue(referenceImage.pixels[loc]);
                aReference = alpha(referenceImage.pixels[loc]);
    
                // for sample snap
                rSample = red(sampleImage.pixels[loc]);
                gSample = green(sampleImage.pixels[loc]);
                bSample = blue(sampleImage.pixels[loc]);
                aSample = alpha(sampleImage.pixels[loc]);  
                
                if (aSample == 255)
                {
                     // transparency is not present in in the fragment, so carry out a diff   
                    rgb_diff = abs(rReference-rSample) + abs (bReference-bSample) + abs(gReference-gSample) + abs(aReference-aSample);
                    total_rgb_diff += rgb_diff;
                }
                else
                {
                    // Transparent pixel, so nothing to compare
                    numberTransparentPixels++;
                }
 
            } // end for pixelXPosition
        } // end for pixelYPosition
                
        if (debugInfo)
        {
            outputStr = "Reference snap - total_rgb_diff for 0,0 : " +  int(total_rgb_diff);
            printDebugToFile.printLine(outputStr, 1);
        }
                
        float avgRGBDiff = total_rgb_diff/((sampleImage.width*sampleImage.height) - numberTransparentPixels);
        //  finished checking this sample sized piece of reference. So check to see if we have a match
        if (total_rgb_diff == 0)
        {
            // perfect match                  
            // add to the array
            snapFoundMatches.add(new FoundMatch(0, 0, true, referenceFileName, total_rgb_diff, avgRGBDiff));
            allFoundMatches.add(new FoundMatch(0, 0, true, referenceFileName, total_rgb_diff, avgRGBDiff));
            outputStr = "Perfect match found for item at x,y=" + 0 + "," + 0;
            printDebugToFile.printLine(outputStr, 1);
        }
        else if (itemClassTSID.equals("marker_qurazy"))
        {
            // Now that we can only use the single QQ image, this will need to be increased substantially as 1500 is unlikely to work unless just happen to 
            // have the same size central image. Might be nearer 5000 as before. 
            if (total_rgb_diff < 1500) //1500 for perfect match. Alter as necessary to get the additional y_offset data (find threshold from debug file)
            {
                // good enough match
                // add to the array
                snapFoundMatches.add(new FoundMatch(0, 0, false, referenceFileName, total_rgb_diff, avgRGBDiff)); 
                allFoundMatches.add(new FoundMatch(0, 0, false, referenceFileName, total_rgb_diff, avgRGBDiff));
                outputStr = "OK match found for QQ item at x,y="  + 0 + "," + 0 + " with rgb diff " + int(total_rgb_diff) + " avg rgb = " + int(avgRGBDiff);
            }
            else
            {
                outputStr = "IGNORED OK match found for QQ item at x,y="  + 0 + "," + 0 + " with rgb diff " + int(total_rgb_diff) + " avg rgb = " + int(avgRGBDiff);
            }
            printDebugToFile.printLine(outputStr, 2);
        }
        /*
        else if (itemClassTSID.equals("marker_qurazy") && (total_rgb_diff < good_enough_QQ_total_rgb))
        {
            // good enough match
            // add to the array
            snapFoundMatches.add(new FoundMatch(0, 0, false, referenceFileName, total_rgb_diff, avgRGBDiff)); 
            allFoundMatches.add(new FoundMatch(0, 0, false, referenceFileName, total_rgb_diff, avgRGBDiff));
            outputStr = "OK match found for QQ item at x,y="  + 0 + "," + 0 + " with rgb diff " + int(total_rgb_diff) + " avg rgb = " + int(avgRGBDiff);
            printDebugToFile.printLine(outputStr, 1);
        }
        */
        /*
                else
                {
                    // Not found a match - but save this value in case the lowest
                    if ((pixelXPosReference == 0) && (pixelYPosReference == 0))
                    {
                        // Save this one always - so overwrite initilised value
                        lowest_total_rgb_diff = total_rgb_diff;
                        lowest_total_rgb_diff_x = pixelXPosReference;
                        lowest_total_rgb_diff_y = pixelYPosReference;
                        lowest_avg_rgb_diff = avgRGBDiff;
                        if (debugInfo)
                        {
                            outputStr = "No match, but first one, so saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff)) + " avg rgb = " + int(avgRGBDiff);
                            printDebugToFile.printLine(outputStr, 1);
                        }
                    }
                    else if (total_rgb_diff < lowest_total_rgb_diff)
                    {
                        // save this if the lowest one so far
                        lowest_total_rgb_diff = total_rgb_diff;
                        lowest_total_rgb_diff_x = pixelXPosReference;
                        lowest_total_rgb_diff_y = pixelYPosReference;
                        lowest_avg_rgb_diff = avgRGBDiff;
                        if (debugInfo)
                        {
                            outputStr = "No match, but lowest so far so saved x,y=" + lowest_total_rgb_diff_x + "," + lowest_total_rgb_diff_y + "(lowest_total_rgb_diff = " + str(int(lowest_total_rgb_diff)) + " avg rgb = " + int(avgRGBDiff);
                            printDebugToFile.printLine(outputStr, 1);
                        }
                        
                    }        
                } */
  
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
           
        refImage = loadImage(rootItemImagePath+"/"+foundMatch.refFname, "png");
        refImage.loadPixels();
        matchImage = refImage.get(foundMatch.matchX, foundMatch.matchY, QAFragment.width, QAFragment.height); 
        image(matchImage, screenX, screenY); 
        fill(50);
                        
        if (foundMatch.isPerfect)
        {
            s = "Perfect at " + str(foundMatch.matchX) + "," + str(foundMatch.matchY);
            matchFname = foundMatch.refFname.replace(".png", "") + "_perfect_" + str(foundMatch.matchX) + "_" + str(foundMatch.matchY) + ".png";
            s = s + " " + foundMatch.refFname.replace(".png", "");
        }
        else
        {
            s = "OK at " + str(foundMatch.matchX) + "," + str(foundMatch.matchY)+ " total RGB diff =" + str(int(foundMatch.totalRGBDiff)) + " avgRGB diff = " + int(foundMatch.avgRGBDiff);
            matchFname = foundMatch.refFname.replace(".png", "") + "_OK_" + str(foundMatch.matchX) + "_" + str(foundMatch.matchY) + ".png";
            s = s + " " + foundMatch.refFname.replace(".png", "");
        }
        text(s, screenX, screenY + 30, screenX + 150, screenY + 30);  // Text wraps within text box
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
        int displayX = 350;
        int displayY = 400;    
        int numMatches = 0;     
        
        // First search to see if the fragment contains the default background - r = g = b = 128 i.e. #808080
        int i;
        int j;
        int locItem;
        
        int nosBackgroundPixels = 0;
                                    
        // Check each pixel in the fragment
        for (i = 0; i < QAFragment.height; i++) 
        {
            for (j = 0; j < QAFragment.width; j++)
            {
                //int loc = pixelXPosition + (pixelYPosition * streetItemInfo[streetItemCount].sampleWidth);
                locItem = j + (i * QAFragment.width);               
                if (QAFragment.pixels[locItem] == #808080)
                {
                    nosBackgroundPixels++;
                }
            }
        }
        if (nosBackgroundPixels > 0)
        {
            printDebugToFile.printLine("Found " + nosBackgroundPixels + " background pixels in this reference snap", 2);
            errorMsg = "Found " + nosBackgroundPixels + " background pixels in reference snap";
            return false;
        }
         
        for (i = 0; i < completeItemImagePaths.size(); i++)
        {
            targetImage = loadImage(rootItemImagePath+"/"+completeItemImagePaths.get(i), "png");
            printDebugToFile.printLine("Using reference file " + rootItemImagePath+"/"+completeItemImagePaths.get(i), 2);
            targetImage.loadPixels();
            
            // Search for item image in this larger file
            if (configInfo.readQuoinHeightsOnly())
            {
                numMatches = checkQuoinFragmentsMatchExactly(QAFragment, targetImage, completeItemImagePaths.get(i));
            }
            else
            {
                numMatches = checkFragmentsMatch(QAFragment, targetImage, completeItemImagePaths.get(i));
            }
            
            if (numMatches > 0)
            {
                outputStr = "Reference " + completeItemImagePaths.get(i) + " has size allFoundMatches " + allFoundMatches.size();
                printDebugToFile.printLine(outputStr, 2);
            }
        }
             
       // Now dump out contents of the array list to see how many exact/good enough matches found
       // Only print out the mismatches if a small number - otherwise might be listing 1000s!
       int maxCount = allFoundMatches.size();
       if (maxCount > 10)
       {
           maxCount = 10;
       }

       int x;
       int y;
       String fname;
       float rgbDiff;
       float avgRGBDiff;
       
       for (j = 0; j < maxCount; j++)
       {
           saveAndDisplayFoundMatch(allFoundMatches.get(j), displayX, displayY);
           displayY += QAFragment.height + 30;          
           
           // only need these vars to make string simpler
           x = allFoundMatches.get(j).matchX;
           y = allFoundMatches.get(j).matchY;
           fname = allFoundMatches.get(j).refFname;
           rgbDiff = allFoundMatches.get(j).totalRGBDiff;
           avgRGBDiff = allFoundMatches.get(j).avgRGBDiff;
           
           
           targetImage = loadImage(rootItemImagePath+"/"+fname, "png");
           targetImage.loadPixels();
                      
           // Now output the images found so can see them on the screen
           if (allFoundMatches.get(j).isPerfect)
           {
               printDebugToFile.printLine("Perfect match found for x,y " + str(x) + "," + str(y) + " (" + int(avgRGBDiff) + ") in file " + fname, 2);
           }
           else
           {
               printDebugToFile.printLine("OK match found (total RGB diff = " + str(int(rgbDiff)) + ", avg RGB Diff = " + int(avgRGBDiff) + ") for x,y " + str(x) + "," + str(y) + " in file " + fname, 2);
           }

       }
       
       // Need to adjust the count of matches for wood trees - as some of the tree is common to all forms of
       // i.e. for a wood tree image which is older than the tree being searched for
       // So need to remove these matches - work from bottom
       for (j = allFoundMatches.size(); j > 0; j--)
       {
           if (itemClassTSID.equals("wood_tree") || itemClassTSID.equals("wood_tree_enchanted"))
           {
               char imageVariant = allFoundMatches.get(j-1).refFname.charAt(itemClassTSID.length()+1);
               char imageState = allFoundMatches.get(j-1).refFname.charAt(itemClassTSID.length()+3);
               if ((itemInfo.charAt(0) == imageVariant) && (imageState > itemState.charAt(0)))
               {
                   // 'Remove this from the count
                   //printDebugToFile.printLine("Allowed match in wood tree of older state in " + allFoundMatches.get(j-1).refFname + " - older than Wood tree (variant " + itemInfo + ", state " + itemState + ") so removed from match list", 2);
                   //allFoundMatches.remove(j-1);
               }
           }       
                   
        }
        
        if (allFoundMatches.size() == 1)
        {
            printDebugToFile.printLine("Found single matching point in this reference snap in " + allFoundMatches.get(0).refFname, 2);
            uniqueReferenceX = allFoundMatches.get(0).matchX;
            uniqueReferenceY = allFoundMatches.get(0).matchY;
            uniqueReferenceFile = rootItemImagePath+"/"+allFoundMatches.get(0).refFname;
            return true;
        }
        else  
        {
            printDebugToFile.printLine("Found " + str(allFoundMatches.size()) + " multiple matching point in this reference snap", 2);
            errorMsg = "Fragment is NOT unique - ";
            for (j = 0; j < allFoundMatches.size(); j++)
            {
                errorMsg = errorMsg + " :" + allFoundMatches.get(j).refFname + " " + allFoundMatches.get(j).matchX + "," + allFoundMatches.get(j).matchY + " (" + int(allFoundMatches.get(j).avgRGBDiff) + ")";
            }
            //errorMsg = "Fragment is NOT unique - move it or resize it before re-saving";
            return false;
        }
    }
    
    public String readErrorMsg()
    {
        return errorMsg;
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
        float avgRGBDiff;
        
        FoundMatch(int x, int y, boolean perfectFlag, String referenceFile, float rgbDiff, float avgRGBDiffPerPixel)
        {
            matchX = x;
            matchY = y;
            isPerfect = perfectFlag;
            refFname = referenceFile;
            totalRGBDiff = rgbDiff;
            avgRGBDiff = avgRGBDiffPerPixel;
        }
    }
}