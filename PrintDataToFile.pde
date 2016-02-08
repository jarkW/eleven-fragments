class PrintDataToFile {
   
   // Used for saving output (rather than debug info which uses a global
   // output printfile which is reset each time the programme is run.
   
   
   PrintWriter output;
   StringList existingOutputText;
   boolean okFlag;
    
     // constructor/initialise fields
    public PrintDataToFile()
    {
        okFlag = true;
        existingOutputText = new StringList();       
    }
    
    public boolean openFileToAppend()
    {
        // Cannot append to files easily in Processing
        // So if the file exists, open, and read into an array
        File file = new File(sketchPath(configInfo.readDataOutputFilename()));
        if (file.exists())
        {            
            // Read in contents of the file
            BufferedReader reader;
            String line;
            reader = createReader(configInfo.readDataOutputFilename());

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
                    printDebugToFile.printLine("IO exception when reading in existing output file " + configInfo.readDataOutputFilename(), 3);
                    line = null;
                }
                catch(Exception e)
                {
                    println(e);
                    printDebugToFile.printLine("General exception when reading in existing output file " + configInfo.readDataOutputFilename(), 3);
                    return false;
                } 

                if (line == null) 
                {
                    // Stop reading because of an error or file is empty
                    printDebugToFile.printLine("outputfile is empty", 1);
                    eof = true;  
                } 
                else 
                {
                    existingOutputText.append(line);
                }
            }           
        } 
        
        // Is now safe to create the printer output
        try
        {
            output = createWriter(configInfo.readDataOutputFilename());
        }
        catch(Exception e)
        {
            println(e);
            printDebugToFile.printLine("Failed to open empty data file", 3);
            return false;
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
        if (existingOutputText.size() == 0)
        {
            // empty file - so just write our line
            println("Debug info written to empty file");
            lineWrittenFlag = true;
            output.println(lineToWrite);
        }
        else
        {
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
        }
        
        // Now write the new line out, if not already done
        if (!lineWrittenFlag)
        {
            output.println(lineToWrite);
        }
         
    }
    
    public void flushFile()
    {
        output.flush();
    }
    
    public void closeFile()
    {
        output.close();
    }
    
    public boolean readOkFlag()
    {
        return (okFlag);
    }
}