class PrintDebugToFile {
   
   // Used for saving debug info
   PrintWriter output;
   boolean okFlag;
    
     // constructor/initialise fields
    public PrintDebugToFile()
    {
        okFlag = true;
        
        if (debugLevel > 0)
        {
            // Collecting debug info so open file
            try
            {
                output = createWriter(configInfo.readDebugOutputFilename());
            }
            catch(Exception e)
            {
                println(e);
                println("Failed to open debug file");
                okFlag = false;
            }
        }
        else
        {
            println("Debug file not opened as debugLevel is 0");
        }
    }
 
    
    public void printLine(String lineToWrite, int severity)
    {
       
        // Do nothing if not collecting debug info
        if (debugLevel == 0)
        {
            return;
        }
        
        if (severity >= debugLevel)
        {
            // Do we need to print this line to the console
            if (debugToConsole)
            {
                println(lineToWrite);
            }
        
            // Output line 
            output.println(lineToWrite);
            output.flush();
        }
        
    }
           
    public boolean readOkFlag()
    {
        return (okFlag);
    }
}