class SampleJSON
{
    // responsible for handling saving key information to sample.json in Data directory
    boolean okFlag;
    JSONObject json;
    JSONArray values;
    
    // constructor/initialise fields
    public SampleJSON()
    {
        okFlag = true;
        
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
        }
    }
    
    public void saveFragmentInfo(String classTSID, String info, int offsetX, int offsetY, int fragHeight, int fragWidth)
    {
        // Need to see if the item already exists - if so overwrite the value
        boolean itemFound = false;
        JSONObject sample = null;
               
        for (int i = 0; i < values.size(); i++) 
        {
    
            sample = values.getJSONObject(i);
            
            if ((sample.getString("class_tsid").equals(classTSID)) && (sample.getString("info").equals(info)))
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
            sample.setInt("width", fragWidth);
            sample.setInt("height", fragHeight);
            values.setJSONObject(values.size(), sample);
        }
        
        // Now need to write the file back to both places - Work and QA tool
        json.setJSONArray("fragments", values);
        saveJSONObject(json, configInfo.readPngPath() + "/samples.json");
        saveJSONObject(json, configInfo.readQAToolPath() + "/samples.json");

    }
    
    public boolean readOkFlag()
    {
        return okFlag;
    }
}