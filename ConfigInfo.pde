class ConfigInfo {
    
    boolean okFlag;
    
    String jsonPath;
    String snapPath;
    String pngPath;
    String completeItemPngPath;
    String streetTSID;
    int totalStreetCount;  
    StringList streetTSIDArray = new StringList();
    String outputFile;
    
    // constructor/initialise fields
    public ConfigInfo()
    {
        okFlag = true;
        totalStreetCount = 0;
    
        // Read in config info from JSON file
        if (!readConfigData())
        {
            println("Error in readConfigData");
            okFlag = false;
            return;
        }
    }
    
    boolean readConfigData()
    {
        JSONObject json;
        // Open the config file
        try
        {
        // Read in stuff from the config file
            json = loadJSONObject("config.json");
        }
        catch(Exception e)
        {
            println(e);
            println("Failed to load config.json file");
            return false;
        }
   
        // Now read in the different fields
        jsonPath = readJSONString(json, "json_path");   
        snapPath = readJSONString(json, "snap_path");
        pngPath = readJSONString(json, "png_path");
        completeItemPngPath = readJSONString(json, "complete_item_png_path");
        outputFile = readJSONString(json, "output_file");
        
        
        // Read in array of street TSID
        try
        {
            JSONArray TSIDArray = null;
            TSIDArray = json.getJSONArray("streets");
            for (int i = 0; i < TSIDArray.size(); i++)
            {    
                // extract the TSID
                JSONObject tsidObject = TSIDArray.getJSONObject(i);
                String tsid = tsidObject.getString("tsid", null);
                
                if (tsid.length() == 0)
                {
                    println("Missing value for street tsid");
                    return false;
                }
                //streetTSIDArray.add(new String(tsid)); 
                streetTSIDArray.append(tsid);
            }
            totalStreetCount = streetTSIDArray.size();
        }
        catch(Exception e)
        {
            println(e);
            println("Failed to read in street array from config.json");
            return false;
        }  
        
            
        // Everything OK
        return true;
    }
       
    String readJSONString(JSONObject jsonFile, String key)
    {
        String readString = "";
        try
        {
            if (jsonFile.isNull(key) == true) 
            {
                println("Missing key ", key, " in json file");
                okFlag = false;
                return "";
            }
            readString = jsonFile.getString(key, "");
        }
        catch(Exception e)
        {
            println(e);
            println("Failed to read string from json file with key ", key);
            okFlag = false;
            return "";
        }
        if (readString.length() == 0)
        {
            println("Null field returned for key", key);
            okFlag = false;
            return "";
        }
        return readString;
    }
    
    public boolean readOkFlag()
    {
        return okFlag;
    }
    
    public String readJSONPath()
    {
        return jsonPath;
    }
    
    public String readSnapPath()
    {
        return snapPath;
    }
     
    public String readPngPath()
    {
        return pngPath;
    }
    
    public String readCompleteItemPngPath()
    {
        return completeItemPngPath;
    }
    
    public String readStreetTSID(int n)
    {
        if (n < totalStreetCount)
        {
            return streetTSIDArray.get(n);
        }
        else
        {
            // error condition
            return "";
        }
    }
    
    public int readTotalStreetCount()
    {
        return totalStreetCount;
    }
    
    public String readOutputFilename()
    {
        return outputFile;
    } 
}