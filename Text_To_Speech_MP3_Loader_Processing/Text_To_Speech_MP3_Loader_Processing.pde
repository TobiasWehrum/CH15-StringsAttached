void setup()
{
  open(new String[] { "del", sketchPath("*.mp3") });

  loadFilesForPlayer(0);
  loadFilesForPlayer(1);
  
  exit();
}

void loadFilesForPlayer(int playerIndex)
{
  String[] lines = loadStrings("player" + (playerIndex + 1) + "-lines.txt");
  
  int categoryIndex = -1;
  int lineInCategoryNumber = 1;
  boolean connected = false; 
  
  for (String line : lines)
  {
    if (line.startsWith("#"))
    {
      if (!connected)
      {
        categoryIndex++;
      }
      connected = !connected;
      lineInCategoryNumber = 1;
      continue;
    }
    
    if (line.length() > 0)
    {
      int endOfLine = line.indexOf('\n');
      if (endOfLine != -1)
        line = line.substring(endOfLine);
      
      line = java.net.URLEncoder.encode(line);
      
      byte bytes[] = loadBytes("http://tts-api.com/tts.mp3?q=" + line);
      saveBytes(makeKey(playerIndex, categoryIndex, connected) + " " + lineInCategoryNumber + ".mp3", bytes);
      lineInCategoryNumber++;
    }
  }

  println("Done with player #" + (playerIndex + 1));
}

String makeKey(int playerIndex, int categoryIndex, boolean connected)
{
  return "P" + (playerIndex + 1)
       + " C" + (categoryIndex + 1)
       + (connected ? "+" : "-");
}

