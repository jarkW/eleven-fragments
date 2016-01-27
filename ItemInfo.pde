
class ItemInfo {
    String itemTSID;
    String itemClassTSID;
    String itemInfo;  // additional info needed for some items
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
        println("item tsid is ", itemTSID, "(", item.getString("label"), ")");        //<>//
    }
    
    public boolean initialiseItemInfo()
    {
        // Now open the relevant I* file from the same directory
        String itemFileName = configInfo.readJSONPath() + "/" + streetInfoArray.get(streetBeingProcessed).readStreetTSID() + "/" + itemTSID + ".json";      
        println("Item file name is ", itemFileName);       
   
        // First check it exists        
        File file=new File(itemFileName);
        if (!file.exists())
        {
            println("Missing Item file ", itemFileName);
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
            println("Failed load the item json file ", itemFileName);
            return false;
        }
        
        println("Loaded item JSON OK");
        
        itemX = itemJson.getInt("x");
        itemY = itemJson.getInt("y");
        itemClassTSID = itemJson.getString("class_tsid");
        println("class_tsid ", itemClassTSID," with x,y ", itemX, ",", itemY);              
              
        // Populate the info field for some items e.g. quoins, dirt etc
        if (!extractItemInfoFromJson(itemJson))
        {
            // Error populating info field
            return false;
        }
        
        return true;
    }
    
    boolean extractItemInfoFromJson(JSONObject itemJson)
    {
        
        switch (itemClassTSID)
        {
            //case "quoin":
            case "quoin":
            case "wood_tree":
            case "npc_mailbox":
            case "dirt_pile":
                // Read in the instanceProps array to get the quoin type
                JSONObject instanceProps = null;
                try
                {
                    instanceProps = itemJson.getJSONObject("instanceProps");
                }
                catch(Exception e)
                {
                    println(e);
                    println("Failed to get instanceProps from item JSON file ", itemTSID);
                    return false;
                } 
                if (itemClassTSID.equals("quoin"))
                {
                    itemInfo = readJSONString(instanceProps, "type");
                }
                else if ((itemClassTSID.equals("wood_tree")) || (itemClassTSID.equals("npc_mailbox")) || (itemClassTSID.equals("dirt_pile")))
                {
                    itemInfo = readJSONString(instanceProps, "variant");
                }
                else if ((itemClassTSID.equals("mortar_barnacle")) || (itemClassTSID.equals("jellisac")))
                {
                    itemInfo = readJSONString(instanceProps, "blister");
                }
                else if (itemClassTSID.equals("ice_knob"))
                {
                    itemInfo = readJSONString(instanceProps, "knob");
                }
                else if (itemClassTSID.equals("dust_trap"))
                {
                    itemInfo = readJSONString(instanceProps, "trap_class");
                }               
                else
                {
                    println("Trying to read unexpected field from instanceProps for item class ", itemClassTSID);
                    return false;
                }
                if (itemInfo.length() == 0)
                {
                    return false;
                }
                break;
                
            case "npc_shrine_*":
            case "wall_button":
                // Read in the dir field 
                JSONObject dir = null;
                try
                {
                    itemInfo = itemJson.getString("dir");
                }
                catch(Exception e)
                {
                    println(e);
                    println("Failed to read dir field from item JSON file ", itemTSID);
                    return false;
                } 
                break;
                             
            case "npc_sloth":
                println("Not sure about sloth - check to see if both dir and instanceProps.dir are set to be the same ", itemTSID);
                return false;
                
            case "visiting_stone":
                println("not sure about stone - not set by def - cam check if 'state' = 1 and 'dir' = left/right. Can default these depending on end of street RHS=left, LHS=right ", itemTSID);
                return false;
                
            default:
                // Nothing to extract
                break;
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
                println("Missing key ", key, " in json object", " TSID file is ", itemTSID);
                return "";
            }
            readString = jsonObj.getString(key, "");
        }
        catch(Exception e)
        {
            println(e);
            println("Failed to read string from item JSON file for key ", key, " TSID file is ", itemTSID);
            return "";
        }
        if (readString.length() == 0)
        {
            println("Null field returned for key", key, " TSID file is ", itemTSID);
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
        text(s, 50, 350, 200, 150);  // Text wraps within text box
        s = "Arrow keys to move fragment";
        text(s, 50, 380, 200, 150);  // Text wraps within text box
        //s = "Change size: < narrower, > wider, ^ higher, -lower";
        //text(s, 50, 400, 200, 150);  // Text wraps within text box
        text("Change size:", 50, 400, 200, 150); 
        text("< narrower, > wider", 50, 420, 200, 150);
        text("^ higher, -lower", 50, 440, 200, 150);
        
        // Display any error messages that might have come from the image validation
        text(uniqueTestResultMsg, 50, 500, 300, 150);
        
        // Also display a larger area of the snap - just for reference purposes
        int displacement = (sampleWidth + 100) / 2;      
        qaSnapLargeFragment = qaSnap.get(start_x-displacement , start_y-displacement, sampleWidth+100, sampleHeight+100); 
        image(qaSnapLargeFragment, 400 + displacement, 0 + displacement); 
        
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
    }
    
    void saveImage()
    {
        // Clear error message
        uniqueTestResultMsg = "";
        
        // Save this so can be displayed next time around the draw loop
        savedFragment = qaSnapFragment;
        
       // build file name manually
       
       // Change this to use configInfo.readPngPath instead of Datapath?  
       String save_fname = itemClassTSID;
       if (itemInfo.length() > 0)
       {
           save_fname = save_fname+ "_" + itemInfo;
       }
       String sample_fname = save_fname + ".png";
       save_fname = save_fname + "_full.png";
       
       // Before saving, need to check that this fragment is indeed a unique fragment
       
       
       
       

       // write to file
       // Save image of screen to Data directory under Processing
       save(dataPath(save_fname));
       // Save the actual png file to be used later in Work directory
       qaSnapFragment.save(configInfo.readPngPath() + "/" + sample_fname);

        // Now need to search this fragment against the full images which 
        // have been manually generated.
        // For trees - check all trees, including 4 wood trees, check all variants
        // of items
        // If this check shows 1 unique match, then log to file
        // otherwise start again
        
        // Create new class
        // when created loads up all the images, and displays the first.
        // Then on next loop iteration, does the search, and displays the next image
        // if present. (Set flag somewhere to show this is the action we're doing?
        // Once done all the searches, checks match_count = 1. Sets flag in itemInfo
        // to show if unique or not, and clears the flag set above.
        // If ItemInfo.is_unique is true, then can go ahead and save the file
        // else returns to handling that item
            

       //println("Saving ", save_fname, " at offsetX=", offsetX, ", offsetY=", offsetY);
      
       String outputStr = "Saving to " + save_fname + " " + itemTSID + " (" + itemClassTSID;
       if (itemInfo.length() > 0)
       {
           outputStr = outputStr + " (" + itemInfo + ") ";
       }
       outputStr = outputStr + ") x,y=" + str(itemX) + "," + str(itemY) + " has offset ";
       outputStr = outputStr + str(offsetX) + "," + str(offsetY) + " for sample width=";
       outputStr = outputStr + str(sampleWidth) + " for sample height=" + str(sampleHeight);
       println(outputStr);
       
       // Now print to file - create print object first
       PrintToFile printToFile = new PrintToFile();
       // Read in existing output file to an array 
       if (!printToFile.ReadExistingOutputFile())
       {
            failNow = true;
            return;
       }
       // print line to file
       printToFile.printLine(outputStr);
       
       // close stream
       printToFile.flushOutputFile();
       printToFile.closeOutputFile();
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
        println(outputStr);
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
            sampleWidth--;
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
            sampleHeight--;
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