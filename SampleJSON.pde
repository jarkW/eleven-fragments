class SampleJSON
{
    // responsible for handling saving key information to sample.json in Data directory
    boolean okFlag;
    JSONObject json;
    JSONArray values;
    int numberReadInEntries;
    SampleEntry savedEntry = new SampleEntry();
    
    // constructor/initialise fields
    public SampleJSON()
    {
        okFlag = true;
        numberReadInEntries = 0;
        
        File file = new File(configInfo.readPngPath() + "/samples.json");
        if (!file.exists())
        {  
            // File does not exist - so create
            println("sample.json does not exist");
            values = new JSONArray();
            json = new JSONObject();
            json.setJSONArray("fragments", values);
            saveJSONObject(json, configInfo.readPngPath() + "/samples.json");
            
            // Also need to check that file exists in QA tool directory
            file = new File(configInfo.readQAToolPath() + "/samples.json");
            if (!file.exists())
            {  
                // File does not exist - so create
                println("sample.json does not exist");
                values = new JSONArray();
                json = new JSONObject();
                json.setJSONArray("fragments", values);
                saveJSONObject(json, configInfo.readQAToolPath() + "/samples.json");
            }
        }
        else
        {
            try
            {
                // Read in stuff from the existing file
                json = loadJSONObject(configInfo.readPngPath() + "/samples.json");
            }
            catch(Exception e)
            {
                println(e);
                println("Failed to open samples.json file");
                okFlag = false;
                return;
            }
            values = json.getJSONArray("fragments");  
            
            // save length of this structure - so don't inadvertenly wipe out if encounter an error
            numberReadInEntries = values.size();
            printDebugToFile.printLine("Read in " + numberReadInEntries + " from samples.json", 2);
        }
    }
    
    public void saveFragmentInfo(String classTSID, String info, String state, int offsetX, int offsetY, int fragHeight, int fragWidth)
    //public void saveFragmentInfo(String classTSID, String info, String state, int offsetX, int offsetY)
    {
        // Need to see if the item already exists - if so overwrite the value
        boolean itemFound = false;
        JSONObject sample = null;
               
        for (int i = 0; i < values.size(); i++) 
        {
    
            sample = values.getJSONObject(i);
            
            if ((sample.getString("class_tsid").equals(classTSID)) && (sample.getString("info").equals(info)) && (sample.getString("state", "").equals(state)))
            {
                // Found sample item - so overwrite
                sample.setInt("offset_x", offsetX);
                sample.setInt("offset_y", offsetY);
                sample.setInt("width", fragWidth);
                sample.setInt("height", fragHeight);
                values.setJSONObject(i, sample);
                // Now need to write the file back to both places
                json.setJSONArray("fragments", values);
                saveJSONObject(json, configInfo.readPngPath() + "/samples.json");
                saveJSONObject(json, configInfo.readQAToolPath() + "/samples.json");
                return;
            }
        }
        
        if (!itemFound)
        {
            // insert new item
            sample = new JSONObject();
            sample.setString("class_tsid", classTSID);
            sample.setString("info", info);
            sample.setInt("offset_x", offsetX);
            sample.setInt("offset_y", offsetY);
            sample.setString("state", state);
            sample.setInt("width", fragWidth);
            sample.setInt("height", fragHeight);
            values.setJSONObject(values.size(), sample);
        }
        
        // Now need to write the file back to both places - Work and QA tool
        json.setJSONArray("fragments", values);
        saveJSONObject(json, configInfo.readPngPath() + "/samples.json");
        saveJSONObject(json, configInfo.readQAToolPath() + "/samples.json");

    }
    
    // Returns the value if item found in sample.json
    public boolean readFragmentInfo(String classTSID, String info, String state)
    {
        // Need to see if the item already exists 
        JSONObject sample = null;
               
        for (int i = 0; i < values.size(); i++) 
        {
    
            sample = values.getJSONObject(i);
            
            if ((sample.getString("class_tsid").equals(classTSID)) && (sample.getString("info").equals(info)) && (sample.getString("state", "").equals(state)))
            {
                // Found sample item - so populate the saved sample entry structure
                savedEntry.TSIDInfo = classTSID;
                savedEntry.infoStr = info;
                savedEntry.stateStr = state;
                savedEntry.offsetX = sample.getInt("offset_x");
                savedEntry.offsetY = sample.getInt("offset_y");
                savedEntry.fragWidth = sample.getInt("height", 0);
                savedEntry.fragWidth = sample.getInt("width", 0);            
                return true;
            }
        }
        
        // If reach here, then item not found
        savedEntry.TSIDInfo = classTSID;
        savedEntry.infoStr = info;
        savedEntry.offsetX = 0;
        savedEntry.offsetY = 0;
        savedEntry.stateStr = state;
        savedEntry.fragWidth = 0;
        savedEntry.fragWidth = 0;         
        return false;
    }

    public boolean readOkFlag()
    {
        return okFlag;
    }
    
    public int readSavedOffsetX()
    {
        return savedEntry.offsetX;
    }
    
    public int readSavedOffsetY()
    {
        return savedEntry.offsetY;
    }
    
    class SampleEntry
    {
        String TSIDInfo;
        String infoStr;
        int offsetX;
        int offsetY;
        int fragHeight;
        int fragWidth;
        String stateStr;
    }
}