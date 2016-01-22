class PrintToFile {
    
   PrintWriter output;
   StringList existingOutputText;
   boolean errFlag;
    
     // constructor/initialise fields
    public PrintToFile()
    {
        errFlag = false;
        existingOutputText = new StringList();
    }
    
    public boolean ReadExistingOutputFile()
    {

        // Cannot append to files easily in Processing
        // So if the file exists, open, and read into an array
        File file = new File(sketchPath(configInfo.readOutputFilename()));
        if (file.exists())
        {            
            // Read in contents of the file
            BufferedReader reader;
            String line;
            reader = createReader(configInfo.readOutputFilename());

            boolean eof = false;
            while (!eof)
            {
                try 
                {
                    line = reader.readLine();
                } 
                catch (IOException e) 
                {
                    e.printStackTrace();
                    line = null;
                }
                catch(Exception e)
                {
                    System.out.println(e);
                    return false;
                } 

                if (line == null) 
                {
                    // Stop reading because of an error or file is empty
                    eof = true;  
                } 
                else 
                {
                    existingOutputText.append(line);
                }
            }           
        } 
        
        return true;
    }
    
    public void printLine(String lineToWrite)
    {
        boolean lineWrittenFlag = false;
        
        // Read in the first part of the line which will be used to check if already present
        int pos = lineToWrite.indexOf("x,y=", 0);
        // This will be the string we search for - including the x,y= bit
        String strToFind = lineToWrite.substring(0, pos+4);
        
        // Copy back the output file array contents, overwriting the entry for
        // this item with the new values
        // This means we never lose any information, always keeps up today with the latest images saved
        for (int i = 0; i < existingOutputText.size(); i++)
        {
            if (existingOutputText.get(i).indexOf(strToFind, 0) == -1)
            {
                // Does not match the line being written, so use the original one read in earlier
                output.println(existingOutputText.get(i));
            }
            else
            {
                lineWrittenFlag = true;
                output.println(lineToWrite);
            }
        }
        
        // Now write the new line out, if not already done
        if (!lineWrittenFlag)
        {
            output.println(lineToWrite);
        }
        
        // now flush
       output.flush(); 
    }
    
    public void closeOutputFile()
    {
        output.close();
    }
    
    public boolean readErrFlag()
    {
        return (errFlag);
    }
}