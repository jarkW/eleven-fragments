// Allows for the saving of the Processing window and moving a smaple window over
// the snap image in order to place in the middle of the item - no landscape included.
// The image saved will contain the small fragment and the x,y offset needed to point 
// to that fragment.
//
// A config.json contains the street TSID and all items on that street are treated
// the same way. 's' to save the image on screen in a file 'class_tsid'_'info'_full.png
// in the data directory. e.g. rock_metal_1_full.png or quoin_currants_full.png. 
// Or do 'n' to skip saving an item and move on to the next street item.
// The results for an entire street are also recorded in an output file with the name
// specified in the config.json.  

ConfigInfo configInfo;
ArrayList<StreetInfo> streetInfoArray = new ArrayList<StreetInfo>();
int streetBeingProcessed;

boolean failNow = false;
PImage qaSnap;
 
public void setup() {
    
    // Set size of Processing window
    //size(250,250);
    size(750,550);
    
    // Set up config data
    configInfo = new ConfigInfo();
    if (!configInfo.readOkFlag())
    {
        failNow = true;
        return;
    }
    
    if (configInfo.readTotalStreetCount() < 1)
    {
        // No streets to process - exit
        println("No streets to process - exiting");
        failNow = true;
        return;
    }
    
    // Loop through list of street TSIDs, reading in the street info
    for (int i = 0; i < configInfo.readTotalStreetCount(); i++)
    {
        println("Read street data for TSID ", configInfo.readStreetTSID(i)); 
         
        // Now read in basic data for each street
        streetInfoArray.add(new StreetInfo(configInfo.readStreetTSID(i)));
            
        // Now read the error flag for the last street array added
        println("Total is ", streetInfoArray.size());
        StreetInfo streetData = streetInfoArray.get(streetInfoArray.size()-1);
                       
        if (!streetData.readOkFlag())
        {
            println ("Error parsing street information for ", configInfo.readStreetTSID(i));
            failNow = true;
            return;
        }
    }
   
    // Now loop through all streets again, loading up the items structures for each street
    for (int i = 0; i < configInfo.readTotalStreetCount(); i++)
    {
        println("Read street item data for TSID ", configInfo.readStreetTSID(i)); 
                           
        if (!streetInfoArray.get(i).readStreetItemData())
        {
            println ("Error parsing street item information for ", configInfo.readStreetTSID(i));
            failNow = true;
            return;
        }
    }
       
    // Load the first street snap
    streetBeingProcessed = 0;
           
    //and use street name to load snap image
    String imageFileName = configInfo.readSnapPath() + "/" + streetInfoArray.get(streetBeingProcessed).readStreetName() + ".png";
    qaSnap = loadImage(imageFileName, "png");
    println("Loading QA snap from ", imageFileName);

}
 
public void draw() {
    
    if (failNow)
    {
        println("failNow flag set - exiting");
        exit();
    }    
    else
    {
        streetInfoArray.get(streetBeingProcessed).processFragment();
    }

}

void keyPressed() {
    
    // Clear the warning message
    

    if (key == CODED && keyCode == LEFT)
    {
        streetInfoArray.get(streetBeingProcessed).increaseItemOffsetX(false);
    }
    if (key == CODED && keyCode == RIGHT)
    {
        streetInfoArray.get(streetBeingProcessed).increaseItemOffsetX(true);
    }
    if (key == CODED && keyCode == UP)
    {
         streetInfoArray.get(streetBeingProcessed).increaseItemOffsetY(false);
    }
    if (key == CODED && keyCode == DOWN)
    {
        streetInfoArray.get(streetBeingProcessed).increaseItemOffsetY(true);
    }
    if (key == '<')
    {
        streetInfoArray.get(streetBeingProcessed).increaseSampleWidth(false);
    }
    if (key == '>')
    {
        streetInfoArray.get(streetBeingProcessed).increaseSampleWidth(true);
    }
    if (key == '-')
    {
        streetInfoArray.get(streetBeingProcessed).increaseSampleHeight(false);
    }
    if (key == '^')
    {
        streetInfoArray.get(streetBeingProcessed).increaseSampleHeight(true);
    }
    
    
    if (key == 's') 
    {
        // save the image
        if (streetInfoArray.get(streetBeingProcessed).saveItemImage())
        {
            // Done all items on street, so move to next street
            streetBeingProcessed++;
           if (streetBeingProcessed >= streetInfoArray.size()) 
           {
               // Done all the streets so finish
               failNow = true;
           }
        }
    }       
    
    // skip this item - e.g. if just want to do particular item during testing
    if (key == 'n')
    {
        // move to next item
        if (streetInfoArray.get(streetBeingProcessed).skipItemImage())
        {
            // Done all items on street, so move to next street
            streetBeingProcessed++;
           if (streetBeingProcessed >= streetInfoArray.size()) 
           {
               // Done all the streets so finish
               failNow = true;
           }
        }
    }
}