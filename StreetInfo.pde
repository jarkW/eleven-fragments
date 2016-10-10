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
        
        // Check in geo file that no tint/contrast etc present
        if (!readStreetGeoInfo())
        {
            printDebugToFile.printLine("Error in geo file for street", 3);
            okFlag = false;
            return;
        }
       
        // Read in street data - list of item TSID and then read in item data
        if (!readStreetData())
        {
            printDebugToFile.printLine("Error in readStreetData", 3);
            okFlag = false;
            return;
        }
    }
    

    boolean readStreetGeoInfo()
    {
        // Now read in information about contrast etc from the G* file if it exists
        // See if in JSON dir, or persdata or fixtures
        
        String geoFileName = configInfo.readJSONPath() + "/" + streetTSID + "/" + streetTSID.replaceFirst("L", "G") + ".json";
        // First check G* file exists
        File file = new File(geoFileName);
        if (!file.exists())
        {
            // Now try persdata
            geoFileName = configInfo.readElevenPath() + "/eleven-throwaway-server/persdata/" + streetTSID.replaceFirst("L", "G") + ".json";
            file = new File(geoFileName);
            if (!file.exists())
            {
                // Now try fixtures
                geoFileName = configInfo.readElevenPath() + "/eleven-fixtures/locations-json/" + streetTSID.replaceFirst("L", "G") + ".json";
                file = new File(geoFileName);
                if (!file.exists())
                {
                    printDebugToFile.printLine("Unable to find " + streetTSID.replaceFirst("L", "G") + ".json" + "(" + geoFileName + ")", 3);
                    return false;
                }
            }
        }
        
        JSONObject json;
        try
        {
            // load G* file
            json = loadJSONObject(geoFileName);
        }
        catch(Exception e)
        {
            println(e);
            printDebugToFile.printLine("Fail to load street geo JSON file " + geoFileName, 3);
            return false;
        } 
        printDebugToFile.printLine("Reading geo file " + geoFileName, 2);

        // Now chain down to get at the fields in the geo file
        int geoTintColor = 0;
        int geoContrast = 0;
        int geoTintAmount = 0;
        int geoSaturation = 0;
        int geoBrightness = 0;
        
        JSONObject dynamic = null;
        try
        {
            dynamic = json.getJSONObject("dynamic");
        }
        catch(Exception e)
        {
            // the dynamic level is sometimes missing ... so just set it to point at the original json object and continue on
            printDebugToFile.printLine("Reading geo file - failed to read dynamic " + geoFileName, 2);
            if (dynamic == null)
            {
                printDebugToFile.printLine("Reading geo file - dynamic 1 is null " + geoFileName, 2);
            }
            dynamic = json;
        } 

        JSONObject layers = dynamic.getJSONObject("layers");
        
        if (layers != null)
        {
            JSONObject middleground = layers.getJSONObject("middleground");
            if (middleground != null)
            {
                JSONObject filtersNEW;
                try
                {
                    filtersNEW = middleground.getJSONObject("filtersNEW");
                }
                catch(Exception e)
                {
                    // the filtersNEW level is sometimes missing ...so no tinting etc present
                    printDebugToFile.printLine("Reading geo file - failed to read filtersNEW - continuing on" + geoFileName, 3);
                    return true;
                } 
                if (filtersNEW != null)
                {
                    printDebugToFile.printLine("size of filtersNew is " + filtersNEW.size() + " in " + geoFileName, 2);
                    // extract the fields inside
                    JSONObject filtersNewObject = filtersNEW.getJSONObject("tintColor");
                    if (filtersNewObject != null)
                    {
                        geoTintColor = filtersNewObject.getInt("value", 0);
                    }
                    filtersNewObject = filtersNEW.getJSONObject("contrast");
                    if (filtersNewObject != null)
                    {
                        geoContrast = filtersNewObject.getInt("value", 0);
                    }
                    filtersNewObject = filtersNEW.getJSONObject("tintAmount");
                    if (filtersNewObject != null)
                    {
                        geoTintAmount = filtersNewObject.getInt("value", 0);
                    } 
                    filtersNewObject = filtersNEW.getJSONObject("saturation");
                    if (filtersNewObject != null)
                    {
                        geoSaturation = filtersNewObject.getInt("value", 0);
                    } 
                    filtersNewObject = filtersNEW.getJSONObject("brightness");
                    if (filtersNewObject != null)
                    {
                        geoBrightness = filtersNewObject.getInt("value", 0);
                    } 
                }
                else
                {
                    printDebugToFile.printLine("Reading geo file - failed to read filtersNEW " + geoFileName, 1);
                }
            }
            else
            {
                 printDebugToFile.printLine("Reading geo file - failed to read middleground " + geoFileName, 2);
            }
         }
         else
         {
             printDebugToFile.printLine("Reading geo file - failed to read layers " + geoFileName, 2);
         }
         printDebugToFile.printLine("After reading geo file  " + geoFileName + " TintColor = " + geoTintColor + " TintAmount = " + geoTintAmount +
                                         " geoContrast = " + geoContrast + " geoSaturation = " + geoSaturation + " Brightness = " + geoBrightness, 1);  
         
         if ((geoTintAmount != 0) || (geoContrast != 0) || (geoSaturation != 0) || (geoBrightness != 0))
         {
             printDebugToFile.printLine("Need to reset the layers in " + geoFileName + " so that tint amount/contrast/saturation/brightness are all 0", 3);
             return false;
         }
         
         // Everything OK   
        return true;
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
            itemData.setUniqueTestResultMsg(uniqueFragmentCheck.readErrorMsg());
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