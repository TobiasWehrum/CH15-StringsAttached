import ddf.minim.*;
import java.io.*;

Minim minim;
HashMap<String, ArrayList<AudioPlayer>> audioFilesByPlayerAndCategory;

int playerCount = 2;
int connectionCount = 6;
int categoryCount = connectionCount;

AudioPlayer currentFile;

int currentPlayer = 1;

void setup()
{
  minim = new Minim(this);

  loadSoundFiles();
}

void draw()
{
  if (currentFile == null)
  {
    playerMove((int)random(1, connectionCount + 1), random(1) < 0.5);
  }
  else
  {
    if (!currentFile.isPlaying())
    {
      currentFile = null;
    }
  }
}

void startGame()
{
  currentPlayer = 1;
  if (currentFile != null)
  {
    currentFile.pause();
    currentFile = null;
  }
}

void playerMove(int categoryNumber, boolean connected)
{
  playRandomFile(currentPlayer, categoryNumber, connected);
  currentPlayer = 3 - currentPlayer; // Switch between 1 and 2
}

void playRandomFile(int playerNumber, int categoryNumber, boolean connected)
{
  String key = makeKey(playerNumber, categoryNumber, connected);
  ArrayList<AudioPlayer> audioFiles = audioFilesByPlayerAndCategory.get(key);

  int Number = (int) random(audioFiles.size());
  AudioPlayer audioFile = audioFiles.get(Number);

  audioFile.rewind();
  audioFile.play();

  currentFile = audioFile;
}

void loadSoundFiles()
{
  audioFilesByPlayerAndCategory = new HashMap<String, ArrayList<AudioPlayer>>(); 
  for (int playerNumber = 1; playerNumber <= playerCount; playerNumber++)
  {
    for (int categoryNumber = 1; categoryNumber <= categoryCount; categoryNumber++)
    {
      loadFilesWithPrefix(makeKey(playerNumber, categoryNumber, true));
      loadFilesWithPrefix(makeKey(playerNumber, categoryNumber, false));
    }
  }
}

void loadFilesWithPrefix(String prefix)
{
  ArrayList<AudioPlayer> audioFilesForPrefix = new ArrayList<AudioPlayer>();
  audioFilesByPlayerAndCategory.put(prefix, audioFilesForPrefix);

  String filenamePrefix = dataPath(prefix) + " ";
  int Number = 1;
  while (true)
  {
    File file = new File(filenamePrefix + Number + ".mp3");
    if (!file.exists())
    {
      println(prefix + ": Loaded " + (Number - 1) + " files.");
      return;
    }

    audioFilesForPrefix.add(minim.loadFile(prefix + " " + Number + ".mp3"));

    //println("Loaded: " + prefix + " #" + Number);

    Number++;
  }
}

String makeKey(int playerNumber, int categoryNumber, boolean connected)
{
  return "P" + playerNumber
    + " C" + categoryNumber
    + (connected ? "+" : "-");
}

