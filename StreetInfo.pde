class StreetInfo {
    boolean errFlag;
    JSONArray streetItems;
    String streetName;
    String streetTSID;
    int itemBeingProcessed;
    ArrayList<ItemInfo> streetItemInfoArray = new ArrayList<ItemInfo>();
    
    // constructor/initialise fields
    public StreetInfo(String tsid)
    {
        errFlag = false;
        streetTSID = tsid;
        itemBeingProcessed = 0;
       
        // Read in street data - list of item TSID and then read in item data
        if (readStreetData())
        {
            println("Error in readStreetData");
            errFlag = true;
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
            println("Missing file - ", locFileName);
            return(true);
        } 
        
        JSONObject json;
        try
        {
            // Read in stuff from the config file
            json = loadJSONObject(locFileName);
        }
        catch(Exception e)
        {
            System.out.println(e);
            return(true);
        } 
        println("Reading location file ", locFileName);
    
            
        // Read in street name
        streetName = "";
        try
        {
            streetName = json.getString("label");
        }
        catch(Exception e)
        {
            System.out.println(e);
            return(true);
        } 
        println("Street name is ", streetName);
    
        // Read in the list of street items
        streetItems = null;
        try
        {
            streetItems = json.getJSONArray("items");
        }
        catch(Exception e)
        {
            System.out.println(e);
            return(true);
        } 
 
        println("Read item TSID from street L file");   
        // Now read in data for each item
        for (int i = 0; i < streetItems.size(); i++) 
        {
            streetItemInfoArray.add(new ItemInfo(streetItems.getJSONObject(i), streetTSID));
            
            // Now read the error flag for the last street item array added
            int total = streetItemInfoArray.size();
            ItemInfo itemData = streetItemInfoArray.get(total-1);
                       
            if (itemData.readErrFlag())
            {
                println ("Error parsing item information");
                return(true);
            }
        }
 
        // Everything OK
        println(" Initialised street: errFlag = ", errFlag, " streetName=", streetName, " street TSID = ", streetTSID, "with item count ", streetItemInfoArray.size());     
        return(false);
    }


    public void processFragment()
    {
        // Pass control onto the item level funtion
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        itemData.showFragment();
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
    
    public boolean saveItemImage()
    {
        ItemInfo itemData = streetItemInfoArray.get(itemBeingProcessed);
        itemData.saveImage();
        
        // move to next item
        itemBeingProcessed++;
        if (itemBeingProcessed >= streetItemInfoArray.size())
        {
            // Done all items on street
            // Move on to next street
            return(true);
        }
        else
        {
            return(false);
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
            return(true);
        }
        else
        {
            return(false);
        }
    }

    public boolean readErrFlag()
    {
        return (errFlag);
    }
    
    public String readStreetName()
    {
        return (streetName);
    }
    
    public String readStreetTSID()
    {
        println("XXXXXReturning street TSID ", streetTSID);
        return (streetTSID);
    }
 
}