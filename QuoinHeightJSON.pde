class QuoinHeightJSON
{
    // responsible for handling saving key information to quoin_heights.json in main directory
    boolean okFlag;
    JSONObject json;
    JSONArray values;
    int numberReadInEntries;
    
    // constructor/initialise fields
    public QuoinHeightJSON()
    {
        okFlag = true;
        numberReadInEntries = 0;
        
        File file = new File(sketchPath("/quoin_heights.json"));
        if (!file.exists())
        {  
            // File does not exist - so create
            println("quoin_heights.json does not exist");
            values = new JSONArray();
            json = new JSONObject();
            json.setJSONArray("heights", values);
            saveJSONObject(json, sketchPath("/quoin_heights.json"));
        }
        else
        {
            try
            {
                // Read in stuff from the existing file
                json = loadJSONObject(sketchPath("/quoin_heights.json"));
            }
            catch(Exception e)
            {
                println(e);
                println("Failed to open quoin_heights.json file");
                okFlag = false;
                return;
            }
            values = json.getJSONArray("heights");  
            
            // save length of this structure - so don't inadvertenly wipe out if encounter an error
            numberReadInEntries = values.size();
            printDebugToFile.printLine("Read in " + numberReadInEntries + " from quoin_heights.json", 2);
        }
    }
    
    public int saveHeightInfo(String classTSID, String info, int offsetY)
    {
        // This function saves the min/max offsetY values for quoins - returns the corrected value to save in sample json file
        // which is calculated from the min/max values
        
        // Need to see if the item already exists - if so overwrite the value
        boolean itemFound = false;
        JSONObject sample = null;
        int adjustedOffsetY = offsetY;
               
        for (int i = 0; i < values.size(); i++) 
        {
    
            sample = values.getJSONObject(i);
            
            if ((sample.getString("class_tsid").equals(classTSID)) && (sample.getString("info").equals(info)))
            {
                // Remember that 'high' means more negative in value
                int lowY = sample.getInt("lowest_y");
                int highY = sample.getInt("highest_y");
                if (offsetY > lowY)
                {
                    printDebugToFile.printLine("Adjusting saved heights for " + classTSID + " (" + info + "): lowestY from " + lowY + " to " + offsetY, 2);
                    sample.setInt("lowest_y", offsetY);
                    lowY = offsetY;
                }
                else if (offsetY < highY)
                {
                    printDebugToFile.printLine("Adjusting saved heights for " + classTSID + " (" + info + "): highestY from " + highY + " to " + offsetY, 2);
                    sample.setInt("highest_y", offsetY);
                    highY = offsetY;
                }
                else
                {
                    printDebugToFile.printLine("No changes to saved heights for " + classTSID + " (" + info + "): with offset " + offsetY + "(lowY=" + lowY + ", highY=" + highY + ")", 1);
                }
                // As a first guess - set the offset to midway between low/highY
                adjustedOffsetY = lowY + ((highY - lowY)/2);
                
                values.setJSONObject(i, sample);
                // Now need to write the file back 
                json.setJSONArray("heights", values);
                saveJSONObject(json, sketchPath("/quoin_heights.json"));
                return adjustedOffsetY;
            }
        }
        
        if (!itemFound)
        {
            // insert new item
            sample = new JSONObject();
            sample.setString("class_tsid", classTSID);
            sample.setString("info", info);
            sample.setInt("highest_y", offsetY);
            sample.setInt("lowest_y", offsetY);
            values.setJSONObject(values.size(), sample);
        }
        
        // Now need to write the file back 
        json.setJSONArray("heights", values);
        saveJSONObject(json, sketchPath("/quoin_heights.json"));
        return adjustedOffsetY;

    }
    
    public boolean readOkFlag()
    {
        return okFlag;
    }
        
    class QuoinEntry
    {
        String TSIDInfo;
        String infoStr;
        int highestY;
        int lowestY;
    }
}