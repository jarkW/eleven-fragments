
class ItemInfo {
    String itemTSID;
    String itemClassTSID;
    String itemInfo;  // additional info needed for some items
    String itemState; // Used for barnacles etc so can differentiate empty/used/full items
    int    itemX;
    int    itemY;
    // offset to use from given x,y which matches the sample to actually be matched (to avoid comparing background)
    int    offsetX; 
    int    offsetY; 
    int    sampleWidth; // contains the default size
    int    sampleHeight; // contains the default size
    boolean okFlag;
    
    PImage qaSnapFragment;
    PImage qaSnapLargeFragment;
    boolean fragmentIsUnique;
    String uniqueTestResultMsg;
    String uniqueReferenceFile;
    int uniqueReferenceX;
    int uniqueReferenceY;
    PImage savedFragment;

   
    // constructor/initialise fields
    public ItemInfo(JSONObject item)
    {
        // initialise values
        okFlag = true;
        itemInfo = "";
        itemState = "";
        offsetX = 0;
        offsetY = 0;
        sampleWidth = 10;
        sampleHeight = 10;
        fragmentIsUnique = false;
        uniqueTestResultMsg = "";
        uniqueReferenceFile = "";
        uniqueReferenceX = 0;
        uniqueReferenceY = 0;
        
        itemTSID = item.getString("tsid"); //<>//
        printDebugToFile.printLine("item tsid is " + itemTSID + "(" + item.getString("label") + ")", 2);        //<>//
    }
    
    public boolean initialiseItemInfo()
    {
        // Now open the relevant I* file from the same directory
        String itemFileName = configInfo.readJSONPath() + "/" + streetInfoArray.get(streetBeingProcessed).readStreetTSID() + "/" + itemTSID + ".json";   
        printDebugToFile.printLine("Item file name is " + itemFileName, 2);       
   
        // First check it exists        
        File file=new File(itemFileName);
        if (!file.exists())
        {
            printDebugToFile.printLine("Missing Item file " + itemFileName, 3);
            return false;
        }

        // Now read the item JSON file
        JSONObject itemJson = null;
        try
        {
            itemJson = loadJSONObject(itemFileName);
        }
        catch(Exception e)
        {
            println(e);
            printDebugToFile.printLine("Failed load the item json file " + itemFileName, 3);
            return false;
        }
        
        printDebugToFile.printLine("Loaded item JSON OK", 1);
        
        itemX = itemJson.getInt("x");
        itemY = itemJson.getInt("y");
        itemClassTSID = itemJson.getString("class_tsid");
        printDebugToFile.printLine("class_tsid " + itemClassTSID +" with x,y " + str(itemX) + "," + str(itemY), 2);              
              
        // Populate the info field for some items e.g. quoins, dirt etc
        if (!extractItemInfoFromJson(itemJson))
        {
            // Error populating info field
            return false;
        }
        
        // Now set up the offset/sample sizes if present - saves user resetting them if just using different background image
        if (!defaultFragmentSettings())
        {
            // Error opening JSON file
            failNow = true;
            return false;
        }        
        
        return true;
    }
    
    boolean defaultFragmentSettings()
    {
        // Now set up the offset/sample sizes if present - saves user resetting them if just using different background image
        SampleJSON sampleJSON = new SampleJSON();
        if (!sampleJSON.readOkFlag())
        {
            printDebugToFile.printLine("Error opening sampleJSON object", 3);
            failNow = true;
            return false;
        }
        if (sampleJSON.readFragmentInfo(itemClassTSID, itemInfo, itemState))
        {
            // Entry exists for this tsid/info - so read in values
            offsetX = sampleJSON.readSavedOffsetX();
            offsetY = sampleJSON.readSavedOffsetY();
            
            // Work out the sample sizes from any existing saved fragments
            String save_fname = itemClassTSID;
            if (itemInfo.length() > 0)
            {
               save_fname = save_fname+ "_" + itemInfo;
            }
            if (itemState.length() > 0)
            {
               save_fname = save_fname+ "_" + itemState;
            }
            String sample_fname = save_fname + ".png";
            File file = new File(configInfo.readPngPath() + "/" + sample_fname);
            if (file.exists())
            {  
                // Load up image file and use width/height
                PImage fragImage = loadImage(configInfo.readPngPath() + "/" + sample_fname, "png");
                sampleWidth = fragImage.width;
                sampleHeight = fragImage.height;
            }
           else
            {
                sampleWidth = 10;
                sampleHeight = 10;
            }
        }
        else
        {
            // Not found - so default
            offsetX = 0;
            offsetY = 0;
            sampleWidth = 10;
            sampleHeight = 10;
        }
        
        return true;
    }
    
    boolean extractItemInfoFromJson(JSONObject itemJson)
    {
        JSONObject instanceProps;
        boolean zeroInfoIsError = true;
        
        // Avoids entering all the shrine TSIDs separately
        if (itemClassTSID.startsWith("npc_shrine_"))
        {
      
            // Read in the dir field 
            try
            {
               itemInfo = itemJson.getString("dir");
            }
            catch(Exception e)
            {
                println(e);
                printDebugToFile.printLine("Failed to read dir field from item JSON file " + itemTSID, 3);
                return false;
             } 
        }
        else
        {
             switch (itemClassTSID)
            {
                case "quoin":
                case "wood_tree":
                case "wood_tree_enchanted":
                case "npc_mailbox":
                case "dirt_pile":
                case "mortar_barnacle":
                case "jellisac":
                case "ice_knob":
                case "dust_trap":
                //case "street_spirit_zutto":
                case "trant_bean":
                case "trant_fruit":
                case "trant_egg":
                case "trant_bubble":
                case "trant_spice":
                case "trant_gas":
                
                    // Read in the instanceProps array to get the quoin type
                    instanceProps = null;
                    try
                    {
                        instanceProps = itemJson.getJSONObject("instanceProps");
                    }
                    catch(Exception e)
                    {
                        println(e);
                        printDebugToFile.printLine("Failed to get instanceProps from item JSON file " + itemTSID, 3);
                        return false;
                    } 
                    if (itemClassTSID.equals("quoin"))
                    {
                        itemInfo = readJSONString(instanceProps, "type");
                    }
                    else if ((itemClassTSID.equals("npc_mailbox")) || (itemClassTSID.equals("dirt_pile")))
                    {
                        itemInfo = readJSONString(instanceProps, "variant");
                    }
                    else if (itemClassTSID.equals("mortar_barnacle"))
                    {
                        itemInfo = readJSONString(instanceProps, "blister");
                        itemState = str(instanceProps.getInt("scrape_state")); 
                    }
                    else if (itemClassTSID.equals("jellisac"))
                    {
                        itemInfo = readJSONString(instanceProps, "blister");
                        itemState = str(instanceProps.getInt("scoop_state")); 
                    }
                    else if (itemClassTSID.equals("ice_knob"))
                    {
                        itemInfo = readJSONString(instanceProps, "knob");
                        //itemState = str(instanceProps.getInt("scrape_state"));  NOT GOOD ENOUGH TO BE USEFUL 
                    }
                    else if (itemClassTSID.equals("dust_trap"))
                    {
                        itemInfo = readJSONString(instanceProps, "trap_class");
                    } 
                    else if (itemClassTSID.equals("street_spirit_zutto"))
                    {
                        itemInfo = readJSONString(instanceProps, "cap");
                    } 
                    else if (itemClassTSID.startsWith("trant_"))
                    {
                        // So we can differentiate different states of trees
                        itemState = str(instanceProps.getInt("maturity"));
                        // We don't expect an info field, so zero length info is valid in this case
                        zeroInfoIsError = false;
                    }
                    else if (itemClassTSID.equals("wood_tree") || itemClassTSID.equals("wood_tree_enchanted"))
                    {
                        itemInfo = readJSONString(instanceProps, "variant");
                        // So we can differentiate different states of trees
                        itemState = str(instanceProps.getInt("maturity"));
                    }
                    else
                    {
                        printDebugToFile.printLine("Trying to read unexpected field from instanceProps for item class " + itemClassTSID, 3);
                        return false;
                    }
                    if (zeroInfoIsError && itemInfo.length() == 0)
                    {
                        return false;
                    }
                    break;
   
                case "subway_gate":
                    // Read in the dir field 
                    try
                    {
                        itemInfo = itemJson.getString("dir");
                    }
                    catch(Exception e)
                    {
                        println(e);
                        printDebugToFile.printLine("Failed to read dir field from item JSON file " + itemTSID, 3);
                        return false;
                    } 
                    break;
                             
                case "npc_sloth":
                    // Read in the dir field 
                    String dir;
                    try
                    {
                        dir = itemJson.getString("dir");
                    }
                    catch(Exception e)
                    {
                        println(e);
                        printDebugToFile.printLine("Failed to read dir field from item JSON file " + itemTSID, 3);
                        return false;
                    } 
                    // Now read the second dir field from instanceProps - should be the same
                    instanceProps = null;
                    try
                    {
                        instanceProps = itemJson.getJSONObject("instanceProps");
                    }
                    catch(Exception e)
                    {
                        println(e);
                        printDebugToFile.printLine("Failed to get instanceProps from item JSON file " + itemTSID, 3);
                        return false;
                    } 
                    itemInfo = readJSONString(instanceProps, "dir");
                    
                    if (!dir.equals(itemInfo))
                    {
                        // should not happen
                        printDebugToFile.printLine("Sloth - inconsistent dir fields in " + itemTSID, 3);
                    }
                    break;
                
                case "visiting_stone":
                    // Read in the dir field 
                    dir = null;
                    try
                    {
                        itemInfo = itemJson.getString("dir");
                    }
                    catch(Exception e)
                    {
                        println(e);
                        printDebugToFile.printLine("Failed to read dir field from item JSON file " + itemTSID, 3);
                        return false;
                    } 
                    break;
                    
                case "street_spirit_zutto":
                    // manually set up the state field
                    itemState = "normal";
                    // We don't expect an info field, so zero length info is valid in this case
                    zeroInfoIsError = false;
                    break;
                    
                                    
                default:
                    // Nothing to extract
                    break;
             }
        }
        
        return true;
    }
    
    String readJSONString(JSONObject jsonObj, String key)
    {
        String readString = "";
        try
        {
            if (jsonObj.isNull(key) == true) 
            {
                printDebugToFile.printLine("Missing key " + key + " in json object; TSID file is " + itemTSID, 3);
                return "";
            }
            readString = jsonObj.getString(key, "");
        }
        catch(Exception e)
        {
            println(e);
            printDebugToFile.printLine("Failed to read string from item JSON file for key " + key + " TSID file is " + itemTSID, 3);
            return "";
        }
        if (readString.length() == 0)
        {
            printDebugToFile.printLine("Null field returned for key" + key + " TSID file is " + itemTSID, 3);
            return "";
        }
        return readString;
    }
    
    void showFragment()
    {
        loadPixels();
        qaSnap.loadPixels();
  
        // clear screen
        background(230);
   
        // convert snap x to processing x = snap x + snap width/2
        // convert snap y to processing y = snap y + snap height
        // Then need to alter x,y so can find sample size inside the object (i.e. no background)    
        int start_x = itemX + qaSnap.width/2 + offsetX;
        int start_y = itemY + qaSnap.height + offsetY;
 
        // Replaced with sampleWidth/Height in item field  
        qaSnapFragment = qaSnap.get(start_x, start_y, sampleWidth, sampleHeight);    
        image(qaSnapFragment, 50, 50); 
        String s = "Offset is " + str(offsetX) + ", " + str(offsetY) + " width " + str(sampleWidth) + " height " + str(sampleHeight); 
        fill(50);
        text(s, 50, 350, 400, 150);  // Text wraps within text box
        s = "Arrow keys to move fragment " + itemClassTSID;
        if (itemInfo.length() > 0)
        {
            s = s + " (" + itemInfo + ")";
        }
        if (itemState.length() > 0)
        {
            s = s + " (" + itemState + ")";
        }
        text(s, 50, 380, 400, 150);  // Text wraps within text box
        //s = "Change size: < narrower, > wider, ^ higher, -lower";
        //text(s, 50, 400, 200, 150);  // Text wraps within text box
        text("Change size:", 50, 400, 200, 150); 
        text("< narrower, > wider", 50, 420, 200, 150);
        text("^ higher, -lower", 50, 440, 200, 150);
        text("s to save, S to force save, ? to see matches, n to skip", 50, 460, 200, 150);
        
        // Display any error messages that might have come from the image validation
        text(uniqueTestResultMsg, 50, 500, 300, 150);
        
        // Also display a larger area of the snap - just for reference purposes
        int expansionHeight = 250;
        int expansionWidth = 150;
        int displacementWidth = (sampleWidth + expansionWidth) / 2;
        int displacementHeight = (sampleHeight + expansionHeight) / 2;
        qaSnapLargeFragment = qaSnap.get(start_x-displacementWidth , start_y-displacementHeight, sampleWidth+expansionWidth, sampleHeight+expansionHeight-50); 
        image(qaSnapLargeFragment, 400, 50);
        noFill();
        // draw rectangle which is centred on the stat_x/start_y
        rect(400 + displacementWidth, 50 + displacementHeight, sampleWidth, sampleHeight);
        
        // Also need to draw a line to show where pigs might obscure the item - for info only i.e. 55px above the y value
        float pigLine = 50 + displacementHeight - offsetY - 55;
        line(400, pigLine, 400 + displacementWidth*2, pigLine);
        
        // Display the last save results
        // Show the saved and reference images

        if (uniqueReferenceFile.length() > 0)
        {
            image(savedFragment, 400, 300); 
            text("Fragment", 400, 400, 100, 100);  // Text wraps within text box
            PImage referenceFile = loadImage(uniqueReferenceFile, "png");
            referenceFile.loadPixels(); 
            PImage referenceFragment = referenceFile.get(uniqueReferenceX, uniqueReferenceY, sampleWidth, sampleHeight);
            image(referenceFragment, 400, 350);
            text("Unique Reference fragment", 400, 550, 100, 100);  // Text wraps within text box

        }
        
        if (itemClassTSID.equals("wood_tree") || itemClassTSID.equals("wood_tree_enchanted"))
        {
            String s2;
            s2 = "Wood trees - remove from sample.json, use ? to test, S to save images for multiple same-variant trees all perfect (<10)) ";
            s2 = s2 + "in numerical order. Use same offset/size for 'matching' states - useful if next mature state includes extra branch. Overwrite less subsequent good matches with own unique match";
            text(s2, 50, 20, 850, 50);  // Text wraps within text box
        }
    }
    
    boolean saveImage()
    {
        String outputStr;
        SampleJSON sampleJSON;
        // Only enter this function if the item image is indeed unique to the complete/sister images
        
        // Clear error message
        uniqueTestResultMsg = "";
        
        // Save this so can be displayed next time around the draw loop
        savedFragment = qaSnapFragment;
        
       // For quoins need to save the y-offset so can keep track of min/max heights of these
       // moving items
       if (itemClassTSID.equals("quoin") || itemClassTSID.equals("marker_qurazy"))
       {
           QuoinHeightJSON quoinHeightsJSON = new QuoinHeightJSON();
           if (!quoinHeightsJSON.readOkFlag())
           {
               printDebugToFile.printLine("Error opening quoinHeightsJSON object", 3);
               failNow = true;
               return false;
           }
           int temp = quoinHeightsJSON.saveHeightInfo(itemClassTSID, itemInfo, offsetY);
           printDebugToFile.printLine(itemClassTSID + " (" + itemInfo + ") has y offset " + offsetY + " reset to " + temp + ")", 2);
           offsetY = temp;
       }
       
       if (configInfo.readQuoinHeightsOnly())
       {
           // Don't want to save anything to the samples.json file if this flag is set - or change any of the fragment samples
           return true;
       }
        
       // build file name manually
       
       // Change this to use configInfo.readPngPath instead of Datapath?  
       String save_fname = itemClassTSID;
       String sample_fname;

       if (itemInfo.length() > 0)
       {
           save_fname = save_fname+ "_" + itemInfo;
       }
       if (itemState.length() > 0)
       {
           save_fname = save_fname+ "_" + itemState;
       }
       sample_fname = save_fname + ".png";
       save_fname = save_fname + "_full.png";
       
       // write to file
       // Save image of screen to Work directory
       save(configInfo.readScreenCapturePath() + "/" + save_fname);
       // Save the actual png file to be used later in Work directory and QA tool directory
       qaSnapFragment.save(configInfo.readPngPath() + "/" + sample_fname);
       qaSnapFragment.save(configInfo.readQAToolPath() + "/" + sample_fname);
       
       // Manually save the flipped version of a zutto street vendor
       if (itemClassTSID.equals("street_spirit_zutto"))
       {     
           PImage sampleFlipped = flipImage(qaSnapFragment);  
           sampleFlipped.save(configInfo.readPngPath() + "/" + "street_spirit_zutto_flipped.png");
           sampleFlipped.save(configInfo.readQAToolPath() + "/" + "street_spirit_zutto_flipped.png");
       }

        // As want to update existing/append new data, just open/close print object here
       PrintDataToFile printDataToFile = new PrintDataToFile(); 
       if (!printDataToFile.readOkFlag())
       {
           printDebugToFile.printLine("Error opening PrintDataToFile object", 3);
           failNow = true;
           return false;
       }
    
       // Now open output file to append
       if (!printDataToFile.openFileToAppend())
       {
           printDebugToFile.printLine("Error opening file to save data to", 3);
           failNow = true;
           return false;
       }

       outputStr = "Saving to " + sample_fname + " " + itemTSID + " (" + itemClassTSID;
       if (itemInfo.length() > 0)
       {
           outputStr = outputStr + " (" + itemInfo + ") ";
       }
       outputStr = outputStr + ") x,y=" + str(itemX) + "," + str(itemY) + " has offset ";
       outputStr = outputStr + str(offsetX) + "," + str(offsetY) + " for sample width=";
       outputStr = outputStr + str(sampleWidth) + " for sample height=" + str(sampleHeight);
       printDataToFile.printLine(outputStr);
       printDebugToFile.printLine(outputStr, 2);
             
       // Also want to write to JSON file saving relevant info for QA tool to use
       sampleJSON = new SampleJSON();
       if (!sampleJSON.readOkFlag())
       {
           printDebugToFile.printLine("Error opening sampleJSON object", 3);
           failNow = true;
           return false;
       }
       sampleJSON.saveFragmentInfo(itemClassTSID, itemInfo, itemState, offsetX, offsetY, sampleHeight, sampleWidth);
       //sampleJSON.saveFragmentInfo(itemClassTSID, itemInfo, itemState, offsetX, offsetY);

       
       // Manually update the JSON file for the flipped zutto vendor
       if (itemClassTSID.equals("street_spirit_zutto"))
       {          
           // The new offsetX has to take account of the sample width as the offset refers to top LH corner
           int flippedOffsetX = -(offsetX + sampleWidth);
           outputStr = "Saving to " + "street_spirit_zutto_flipped.png" + " " + itemTSID + " (" + itemClassTSID;
           outputStr = outputStr + ") x,y=" + str(itemX) + "," + str(itemY) + " has offset ";
           outputStr = outputStr + str(flippedOffsetX) + "," + str(offsetY) + " for sample width=";
           outputStr = outputStr + str(sampleWidth) + " for sample height=" + str(sampleHeight);
           printDataToFile.printLine(outputStr);
           printDebugToFile.printLine(outputStr, 2);
                 
           // Also want to write to JSON file saving relevant info for QA tool to use
           sampleJSON = new SampleJSON();
           if (!sampleJSON.readOkFlag())
           {
               printDebugToFile.printLine("Error opening sampleJSON object", 3);
               failNow = true;
               return false;
           }
           sampleJSON.saveFragmentInfo(itemClassTSID, itemInfo, "flipped", flippedOffsetX, offsetY, sampleHeight, sampleWidth);
       }
       
       // flush/close stream
       printDataToFile.flushFile();
       printDataToFile.closeFile();
       
       return true;

    }
    
    PImage flipImage(PImage originalImage)
    {
        PImage flippedImage = createImage(originalImage.width, originalImage.height, ARGB);
        flippedImage.loadPixels();
        
        int locOriginal;
        int locFlipped;
        
        for (int pixelYPosition = 0; pixelYPosition < originalImage.height; pixelYPosition++) 
        {
            for (int pixelXPosition = 0; pixelXPosition < originalImage.width; pixelXPosition++) 
            {
                locOriginal = pixelXPosition + (pixelYPosition * originalImage.width);
                locFlipped = originalImage.width - pixelXPosition - 1 + (pixelYPosition * originalImage.width);
                flippedImage.pixels[locFlipped] = originalImage.pixels[locOriginal];
            }
        }
        
        return flippedImage;
    }
    
    void skipImage()
    {
        // Clear error message
        uniqueTestResultMsg = "";
        
        String outputStr = "Skipping " + itemTSID + " (" + itemClassTSID; //<>//
        if (itemInfo.length() > 0)
        {
            outputStr = outputStr + " (" + itemInfo + ") ";
        }
        outputStr = outputStr + ") x,y=" + str(itemX) + "," + str(itemY);
        printDebugToFile.printLine(outputStr, 2);
    }
      
    // public functions for reading stuff in from outside this class
    public boolean readOkFlag()
    {
        return (okFlag);
    }
    
    // Functions to set variables called from outside this class
    public void increaseOffsetX(boolean increase)
    {
        // Clear error message
        uniqueTestResultMsg = "";
        if (increase)
        {
            offsetX++;
        }
        else
        {
            offsetX--;
        }
        return;
    }
    public void increaseOffsetY(boolean increase)
    {
        // Clear error message
        uniqueTestResultMsg = "";
        if (increase)
        {
            offsetY++;
        }
        else
        {
            offsetY--;
        }
        return;
    }
    
    public void increaseSampleWidth(boolean increase)
    {
        // Clear error message
        uniqueTestResultMsg = "";
        if (increase)
        {
            sampleWidth++;
        }
        else
        {
            if (sampleWidth > 0)
            {
                sampleWidth--;
            }
        }
        return;
    }
    public void increaseSampleHeight(boolean increase)
    {
        // Clear error message
        uniqueTestResultMsg = "";
        if (increase)
        {
            sampleHeight++;
        }
        else
        {
            if (sampleHeight > 0)
            {
                sampleHeight--;
            }
        }
        return;
    }
    
    public void setUniqueTestResultMsg(String msgToUser)
    {       
        uniqueTestResultMsg = msgToUser;
    }
    public void setUniqueReferenceFile(String fileName)
    {       
        uniqueReferenceFile = fileName;
    }
    public void setUniqueReferenceXY(int x, int y)
    {       
        uniqueReferenceX = x;
        uniqueReferenceY = y;
    }
        
}