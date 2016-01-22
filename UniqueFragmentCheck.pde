class UniqueFragmentCheck
{
    PImage QAFragment; 
    ArrayList<PImage> itemImages = new ArrayList<PImage>();
    boolean errFlag;
    String itemName;
    String itemClassTsid;
    String itemInfo;
    
    // Handles searching the full images for the small fragment
    // Might want to pass the class_tsid/info fields from item so that can
    // easily construct the file name. Unless it is easy for me to access
    // using the read functions.
    
    public UniqueFragmentCheck(String classTsid, String info)
    {
        errFlag = false;
        itemClassTsid = classTsid;
        itemInfo = info;
    }
    
    boolean loadFragmentAndComparisonFiles()
    {
        if (itempInfo.length() > 0)
        {
            String fileName = configInfo.readPngPath() + "/" + itemClassTsid + "_" + itemInfo + ".png";
        }
        else
        {
            String fileName = configInfo.readPngPath() + "/" + itemClassTsid + ".png";
        }

        // Check can open all the appropriate files
        File file = new File(fileName);
        if (!file.exists())
        { 
            return false;
        }
        QAFragment = loadImage(fileName, "png");
        QAFragment.loadPixels();
        
        //Now need to load the other images it will compared against - depends on the item
        switch (class_tsid)
        {
        case "quoin":
            break;
        
        default:
           println("Unexpected class_tsid ", class_tsid);
           return false;
           break;
        }
        
        return true;
                
    }
    
    public boolean readErrFlag()
    {
        return errFlag;
    }
}