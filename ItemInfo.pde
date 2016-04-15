
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
        
        return true;
    }
    
    boolean extractItemInfoFromJson(JSONObject itemJson)
    {
        JSONObject instanceProps;
        
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
                    else if ((itemClassTSID.equals("wood_tree")) || (itemClassTSID.equals("wood_tree_enchanted")) || (itemClassTSID.equals("npc_mailbox")) || (itemClassTSID.equals("dirt_pile")))
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
                        printDebugToFile.printLine("Trying to read unexpected field from instanceProps for item class " + itemClassTSID, 3);
                        return false;
                    }
                    if (itemInfo.length() == 0)
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
        text(s, 50, 350, 200, 150);  // Text wraps within text box
        s = "Arrow keys to move fragment " + itemClassTSID;
        if (itemInfo.length() > 0)
        {
            s = s + " (" + itemInfo + ")";
        }
        text(s, 50, 380, 400, 150);  // Text wraps within text box
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
    
    boolean saveImage()
    {
        
        // Only enter this function if the item image is indeed unique to the complete/sister images
        
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
       
       // write to file
       // Save image of screen to Data directory under Processing
       save(dataPath(save_fname));
       // Save the actual png file to be used later in Work directory and QA tool directory
       qaSnapFragment.save(configInfo.readPngPath() + "/" + sample_fname);
       qaSnapFragment.save(configInfo.readQAToolPath() + "/" + sample_fname);

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

       String outputStr = "Saving to " + sample_fname + " " + itemTSID + " (" + itemClassTSID;
       if (itemInfo.length() > 0)
       {
           outputStr = outputStr + " (" + itemInfo + ") ";
       }
       outputStr = outputStr + ") x,y=" + str(itemX) + "," + str(itemY) + " has offset ";
       outputStr = outputStr + str(offsetX) + "," + str(offsetY) + " for sample width=";
       outputStr = outputStr + str(sampleWidth) + " for sample height=" + str(sampleHeight);
       printDataToFile.printLine(outputStr);
       
       // flush/close stream
       printDataToFile.flushFile();
       printDataToFile.closeFile();
       
       // Also want to write to JSON file saving relevant info for QA tool to use
       SampleJSON sampleJSON = new SampleJSON();
       if (!sampleJSON.readOkFlag())
       {
           printDebugToFile.printLine("Error opening sampleJSON object", 3);
           failNow = true;
           return false;
       }
       //sampleJSON.saveFragmentInfo(itemClassTSID, itemInfo, offsetX, offsetY, sampleHeight, sampleWidth);
       sampleJSON.saveFragmentInfo(itemClassTSID, itemInfo, offsetX, offsetY);
       
       // Also log
       printDebugToFile.printLine(outputStr, 2);
       
       return true;

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