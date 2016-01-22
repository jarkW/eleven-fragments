class ConfigInfo {
    
    boolean errFlag;
    
    String jsonPath;
    String snapPath;
    String pngPath;
    String streetTSID;
    int totalStreetCount;
    ArrayList<String> streetTSIDArray = new ArrayList<String>();
    String outputFile;
    
    // constructor/initialise fields
    public ConfigInfo()
    {
        errFlag = false;
        totalStreetCount = 0;
    
        // Read in config info from JSON file
        if (readConfigData())
        {
            println("Error in readConfigData");
            errFlag = true;
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
            return true;
        }
   
        // Now read in the different fields
        jsonPath = readJSONString(json, "json_path");   
        snapPath = readJSONString(json, "snap_path");
        pngPath = readJSONString(json, "png_path");
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
                    return true;
                }
                streetTSIDArray.add(new String(tsid));        
            }
            totalStreetCount = streetTSIDArray.size();
        }
        catch(Exception e)
        {
            println(e);
           return true;
        }  
        
            
        // Everything OK
        return false;
    }
       
    String readJSONString(JSONObject jsonFile, String key)
    {
        String readString = "";
        try
        {
            if (jsonFile.isNull(key) == true) 
            {
                println("Missing key ", key, " in json file");
                errFlag = true;
                return "";
            }
            readString = jsonFile.getString(key, "");
        }
        catch(Exception e)
        {
            println(e);
            errFlag = true;
            return "";
        }
        if (readString.length() == 0)
        {
            println("Null field returned for key", key);
            errFlag = true;
            return "";
        }
        return readString;
    }
    
    public boolean readErrFlag()
    {
        return errFlag;
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