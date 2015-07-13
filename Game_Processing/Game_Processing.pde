import ddf.minim.*;
import java.io.*;
import processing.serial.*;

Serial myPort;  // The serial port
String port = "COM15";

Minim minim;
HashMap<String, ArrayList<AudioPlayer>> audioFilesByPlayerAndCategory;

int playerCount = 2;
int connectionCount = 6;
int categoryCount = connectionCount;
float lockInDuration = 3.5;

AudioPlayer currentFile;

int currentPlayer = 1;
String previousInput;

String readingInput;

String lockingInInput;
float currentInputLockInCountdown;

long previousNanoTime;

void setup()
{
  minim = new Minim(this);

  myPort = new Serial(this, port, 9600);

  loadSoundFiles();
  startGame();
  
  /*
  currentPlayer = 1;
  previousInput = "040000";
  processInput(   "000000");
  */
}

void draw()
{
  long currentNanoTime = System.nanoTime();
  float elapsedTime = (currentNanoTime - previousNanoTime) / 1000000000.0; 
  previousNanoTime = currentNanoTime;
  
  if (elapsedTime == 0)
    elapsedTime = 0.001;
  
  if (currentFile == null)
  {
    if (lockingInInput.length() > 0)
    {
      currentInputLockInCountdown -= elapsedTime;
      if (currentInputLockInCountdown <= 0)
      {
        processInput(lockingInInput);
        lockingInInput = "";
      }
    }
    //playerMove((int)random(1, connectionCount + 1), random(1) < 0.5);
  }
  else
  {
    if (!currentFile.isPlaying())
    {
      currentFile = null;
    }
  }
  
  while (myPort.available() > 0) {
    lockingInInput = "";
    char c = myPort.readChar();
    if (c == '\r')
      continue;
      
    if (c == '\n')
    {
      if (readingInput.length() == 6)
      {
        if (currentFile == null)
        {
          println("[Bluetooth Reader] Locking in: " + readingInput);
          lockingInInput = readingInput;
          currentInputLockInCountdown = lockInDuration;
        }
        else
        {
          println("[Bluetooth Reader] Got valid input, but still playing a file; discarding the input. (" + readingInput + ")");
          
          // Save the state anyway
          previousInput = readingInput;
        }
      }
      else
      {
        println("[Bluetooth Reader] Unknown input: '" + readingInput + "' (" + readingInput.length() + ")");
      }
      readingInput = "";
    }
    else if (Character.isLetterOrDigit(c))
    {
      readingInput += c;
    }
    else
    {
      println("[Bluetooth Reader] Unrecognized character ASCII #" + (int) c);
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
  previousInput = "000000";
  
  readingInput = "";
  lockingInInput = "";
}

void processInput(String newInput)
{
  if (currentFile != null)
  {
    println("Input changed, but file was still playing");
    previousInput = newInput;
    return;
  }
  
  if (previousInput.equals(newInput))
  {
    println("Input didn't change");
    return;
  }
  
  for (int connectionIndex1 = 0; connectionIndex1 < connectionCount; connectionIndex1++)
  {
    if (newInput.charAt(connectionIndex1) != previousInput.charAt(connectionIndex1))
    {
      int connection1 = connectionIndex1 + 1;
      int connection2 = Character.getNumericValue(newInput.charAt(connectionIndex1));
      int previousConnection2 = Character.getNumericValue(previousInput.charAt(connectionIndex1));
      
      boolean connected = connection2 != 0;
      int categoryNumber = 0;
      if (connected)
      {
        categoryNumber = (currentPlayer == 1) ? connection1 : connection2;
      }
      else
      {
        categoryNumber = (currentPlayer == 1) ? connection1 : previousConnection2;
      }
      
      previousInput = newInput;
      playerMove(categoryNumber, connected);
      break;
    }
  }
}

void playerMove(int categoryNumber, boolean connected)
{
  println("Player " + currentPlayer + ": Category #" + categoryNumber + " " + (connected ? "connected" : "disconnected"));
  
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

