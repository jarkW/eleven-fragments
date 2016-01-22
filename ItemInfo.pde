
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
    boolean errFlag;
    
    PImage qaSnapFragment;
    PImage qaSnapLargeFragment;

   
    // constructor/initialise fields
    //public ItemInfo(JSONObject item)
    public ItemInfo(JSONObject item)
    {
        // initialise values
        errFlag = false;
        itemInfo = "";
        offsetX = 0;
        offsetY = 0;
        
        itemTSID = item.getString("tsid"); //<>//
        println("item tsid is ", itemTSID, "(", item.getString("label"), ")"); //<>//

        // Now open the relevant I* file from the same directory
        String itemFileName = configInfo.readJSONPath() + "/" + streetInfoArray.get(streetBeingProcessed).readStreetTSID() + "/" + itemTSID + ".json";      
        println("Item file name is ", itemFileName);       
   
        // First check it exists        
        File file=new File(itemFileName);
        if (!file.exists())
        {
            println("Missing Item file ", itemFileName);
            errFlag = true;
            return;
        }

        // Now read the item JSON file
        JSONObject itemJson = null;
        try{
            itemJson = loadJSONObject(itemFileName);
        }
        catch(Exception e)
        {
            println(e);
            errFlag = true;
            return;
        }
        
        println("Loaded item JSON OK");
        
        itemX = itemJson.getInt("x");
        itemY = itemJson.getInt("y");
        itemClassTSID = itemJson.getString("class_tsid");
        println("class_tsid ", itemClassTSID," with x,y ", itemX, ",", itemY);              
                 
        switch (itemClassTSID)
        {
            case "rock_metal_1":
                sampleWidth = 50;
                sampleHeight = 50;
                break;
                
            case "rock_sparkly_1":
                sampleWidth = 50;
                sampleHeight = 50;
                break;
                
            case "trant_bubble":
                sampleWidth = 12;
                sampleHeight = 60;
                break;
                
            case "marker_qurazy":      
                sampleWidth = 15;
                sampleHeight = 15;
                break;
              
            case "quoin":
                // Read in the instanceProps array to get the quoin type
                JSONObject instanceProps = null;
                try
                {
                    instanceProps = itemJson.getJSONObject("instanceProps");
                }
                catch(Exception e)
                {
                    System.out.println(e);
                    errFlag = true;
                    return;
                } 
                itemInfo = instanceProps.getString("type");
                sampleWidth = 10;
                sampleHeight = 10;
                break;
                
            default:
                println("Unexpected class_tsid ", itemClassTSID);
                errFlag = true;
                return;
        }
        
        // Double check got the sampleWidth/height set
        if ((sampleHeight == 0) || (sampleWidth == 0))
        {
            println("Check sampleHeight/Width set in ItemInfo");
            errFlag = true;
            return;
        }
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
        
        // Also display a larger area of the snap - just for reference purposes
        int displacement = (sampleWidth + 100) / 2;      
        qaSnapLargeFragment = qaSnap.get(start_x-displacement , start_y-displacement, sampleWidth+100, sampleHeight+100); 
        image(qaSnapLargeFragment, 400 + displacement, 0 + displacement); 
    }
    
    void saveImage()
    {
            
       // build file name manually
       
       // Change this to use configInfo.readPngPath instead of Datapath?  
       String save_fname = itemClassTSID;
       if (itemInfo.length() > 0)
       {
           save_fname = save_fname+ "_" + itemInfo;
       }
       String sample_fname = save_fname + ".png";
       save_fname = save_fname + "_full.png";

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
       printToFile.closeOutputFile();
    }
    
    void skipImage()
    {
        String outputStr = "Skipping " + itemTSID + " (" + itemClassTSID; //<>//
        if (itemInfo.length() > 0)
        {
            outputStr = outputStr + " (" + itemInfo + ") ";
        }
        outputStr = outputStr + ") x,y=" + str(itemX) + "," + str(itemY);
        println(outputStr);
    }
      
    // public functions for reading stuff in from outside this class
    public boolean readErrFlag()
    {
        return (errFlag);
    }
    
    // Functions to set variables called from outside this class
    public void increaseOffsetX(boolean increase)
    {
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
        
}