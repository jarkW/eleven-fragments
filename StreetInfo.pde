class StreetInfo {
    boolean okFlag;
    JSONArray streetItems;
    String streetName;
    String streetTSID;
    int itemBeingProcessed;
    ArrayList<ItemInfo> streetItemInfoArray = new ArrayList<ItemInfo>();
    boolean showDupes;
    
    // constructor/initialise fields
    public StreetInfo(String tsid)
    {
        okFlag = true;
        streetTSID = tsid;
        itemBeingProcessed = 0;
        showDupes = false;
       
        // Read in street data - list of item TSID and then read in item data
        if (!readStreetData())
        {
            printDebugToFile.printLine("Error in readStreetData", 3);
            okFlag = false;
            return;
        }
    }
    


    boolean readStreetData()
    {
        // Now read in item list and street from L* file
        String locFileName = configInfo.readJSONPath() + "/" + streetTSID + "/" + streetTSID + ".json";
   
        // First check it exists
        File file = new File(locFileName);
        if (!file.exists())
        {
            printDebugToFile.printLine("Missing file - " + locFileName, 3);
            return false;
        } 
        
        JSONObject json;
        try
        {
            // Read in stuff from the config file
            json = loadJSONObject(locFileName);
        }
        catch(Exception e)
        {
            println(e);
            printDebugToFile.printLine("Fail to load street JSON file " + locFileName, 3);
            return false;
        } 
        printDebugToFile.printLine("Reading location file " + locFileName, 2);
    
            
        // Read in street name
        streetName = "";
        try
        {
            streetName = json.getString("label");
        }
        catch(Exception e)
        {
            println(e);
            printDebugToFile.printLine("Fail to read in street name from street JSON file " + locFileName, 3);
            return false;
        } 
        printDebugToFile.printLine("Street name is " + streetName, 2);
    
        // Read in the list of street items
        streetItems = null;
        try
        {
            streetItems = json.getJSONArray("items");
        }
        catch(Exception e)
        {
            println(e);
            printDebugToFile.printLine("Fail to read in item array in street JSON file " + locFileName, 3);
            return false;
        } 
 
         // Everything OK   
        return true;
    }
    
    
    public boolean  readStreetItemData()
    {
        println("Read item TSID from street L file");   
        // First set up basic information for each street
        for (int i = 0; i < streetItems.size(); i++) 
        {
            streetItemInfoArray.add(new ItemInfo(streetItems.getJSONObject(i)));
            
            // Now read the error flag for the last street item array added
            int total = streetItemInfoArray.size();
            ItemInfo itemData = streetItemInfoArray.get(total-1);
                       
            if (!itemData.readOkFlag())
            {
               printDebugToFile.printLine("Error parsing item basic information", 3);
               return false;
            }
            
        }
        
        // Now fill in the all the rest of the item information on this street
        for (int i = 0; i < streetItems.size(); i++) 
        {                                  
            if (!streetItemInfoArray.get(i).initialiseItemInfo())
            {
                printDebugToFile.printLine("Error reading in additional information for item", 3);
                return false;
            }
        }
 
        // Everything OK
        printDebugToFile.printLine(" Initialised street = " + streetName + " street TSID = " + streetTSID + " with item count " + str(streetItemInfoArray.size()), 2);  
        return true;
    }


    public void processFragment()
    {
        if (!showDupes)
        {
            // Pass control onto the item level funtion
            ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
            itemData.showFragment();
        }
    }
    
    public void increaseItemOffsetX(boolean increase)
    {
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        itemData.increaseOffsetX(increase);
    }
    
    public void increaseItemOffsetY(boolean increase)
    {
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        itemData.increaseOffsetY(increase);
    }
    
        public void increaseSampleWidth(boolean increase)
    {
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        itemData.increaseSampleWidth(increase);
    }
    
    public void increaseSampleHeight(boolean increase)
    {
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        itemData.increaseSampleHeight(increase);
    }
    
    
    
    
    public boolean saveItemImage()
    {
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        
        // Confirm that this is a unique fragment before we save it
        UniqueFragmentCheck uniqueFragmentCheck = new UniqueFragmentCheck(itemData.itemClassTSID, itemData.itemInfo, itemData.qaSnapFragment);       
        if (!uniqueFragmentCheck.readOkFlag())
        {
            printDebugToFile.printLine("Failed to create uniqueFragmentCheck object", 3);
            failNow = true;
            return false;
        }
        
        // Now populate the fields in this object
        if (!uniqueFragmentCheck.loadComparisonFiles())
        {
            printDebugToFile.printLine("Failed to populate fields in uniqueFragmentCheck object", 2);
            failNow = true;
            return false;
        }
        
        // Now check the fragment image against all the saved reference image.
        // Only save the image if this check passes
        // if the check fails, then continue processing this street item e.g. change the size, move fragment
        if (uniqueFragmentCheck.fragmentIsUnique())
        {
             showDupes = false;
             // print out the saved fragment - as have the file name and x,y
             itemData.setUniqueReferenceFile(uniqueFragmentCheck.uniqueReferenceFile);
             itemData.setUniqueReferenceXY(uniqueFragmentCheck.uniqueReferenceX, uniqueFragmentCheck.uniqueReferenceY);
       
            if (!itemData.saveImage())
            {
                failNow = true;
                return false;
            }
        
            // move to next item
            itemBeingProcessed++;
            if (itemBeingProcessed >= streetItemInfoArray.size())
            {
                // Done all items on street
                // Move on to next street
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            // Show warning message to user
            itemData.setUniqueTestResultMsg("Fragment is NOT unique - move it or resize it before re-saving");
            showDupes = true;
            return false;
        }
    }
    
    public boolean skipItemImage()
    {
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        itemData.skipImage();

        // move to next item
        itemBeingProcessed++;
        if (itemBeingProcessed >= streetItemInfoArray.size())
        {
            // Done all items on street
            // Move on to next street
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
    
    public String readStreetName()
    {
        return  streetName;
    }
    
    public String readStreetTSID()
    {
        return streetTSID;
    }
    
    public boolean readShowDupes()
    {
        return showDupes;
    }
    
    public void resetShowDupes()
    {
        showDupes = false;
    }
 
}