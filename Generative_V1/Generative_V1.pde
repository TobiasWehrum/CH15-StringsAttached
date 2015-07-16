float scale = 1;
float splitChance = 0.1;
float decaySpeedMin = 0.05;
float decaySpeedMax = 0.15;
float growthSpeedMin = 1;
float growthSpeedMax = 3;
float startSize = 10;
float borderWidthX = 100;
float borderWidthY = 50;

ArrayList<Growth> growths = new ArrayList<Growth>();

float areaWidth;
float areaHeight;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight, P2D);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  int originalWidth = 1024;
  int originalHeight = 400;

  scaledSize(originalWidth, originalHeight, originalWidth, originalHeight);
  //scaledSize(originalWidth, originalHeight, displayWidth, displayHeight);
  blendMode(ADD);
  frameRate(30);

  areaWidth = originalWidth * scale;
  areaHeight = originalHeight * scale;

  reset();
}

void reset()
{
  background(0);
  growths.clear();
  //growths.add(new Growth(0, 0));
  //for (int i = 0; i < 5; i++)
  //  growths.add(new Growth(random(-width/2, width/2), random(-height/2, height/2)));
}

void draw()
{
  /*
  fill(0, 0, 0, 4);
   noStroke();
   rect(0, 0, width, height);
   */

  translate(width / 2, height / 2);

  color c = color(255, 255, 255, 5);
  fill(c);
  stroke(c);

  blendMode(ADD);
  for (Growth growth : growths)
  {
    if (!growth.withering)
      growth.draw();
  }

  c = color(0, 0, 0, 255);
  fill(c);
  stroke(c);

  blendMode(BLEND);
  for (Growth growth : growths)
  {
    if (growth.withering)
      growth.draw();
  }
}

float randomX()
{
  return random(-areaWidth/2 + borderWidthX * scale, areaWidth/2 - borderWidthX * scale);
}

float randomY()
{
  return random(-areaHeight/2 + borderWidthY * scale, areaHeight/2 - borderWidthY * scale);
}

void addGrowth(int number)
{
  growths.add(new Growth(-areaWidth / 2 + areaWidth * (number/7f), randomY()));
}

void keyPressed()
{
  if (key == ' ')
  {
    reset();
  }

  if (key == 'a')
  {
    growths.add(new Growth(randomX(), randomY()));
  }

  if (key == '1')
  {
    addGrowth(1);
  }
  
  if (key == '2')
  {
    addGrowth(2);
  }
  
  if (key == '3')
  {
    addGrowth(3);
  }
  
  if (key == '4')
  {
    addGrowth(4);
  }
  
  if (key == '5')
  {
    addGrowth(5);
  }
  
  if (key == '6')
  {
    addGrowth(6);
  }
  
  if (key == 'd')
  {
    for (Growth growth : growths)
    {
      if (!growth.withering)
      {
        growth.withering = true;
        return;
      }
    }
  }
}

class Growth
{
  public float x;
  public float y;
  public ArrayList<Branch> branches = new ArrayList<Branch>();
  public ArrayList<Branch> newBranches = new ArrayList<Branch>();
  public boolean withering;
  public boolean withered;

  public Growth(float x, float y)
  {
    this.x = x;
    this.y = y;

    for (int i = 0; i < 4; i++)
    {
      branches.add(new Branch(this, x, y, startSize, random(0, PI * 2), 1));
    }
  }

  public void draw()
  {
    for (Branch branch : branches)
    {
      branch.draw();
    }

    for (Branch branch : newBranches)
    {
      branches.add(branch);
    }
    newBranches.clear();
  }
}

class Circle
{
  public Branch branch;
  public float x;
  public float y;
  public float size;

  public Circle(Branch branch)
  {
    this.branch = branch;
    x = branch.x;
    y = branch.y;
    size = branch.size;
  }

  public void draw()
  {
    float radius = size * scale;
    if (branch.growth.withering)
      radius += 2;
      
    ellipse(x, y, radius, radius);
  }
}

class Branch
{
  public Growth growth;
  public float directionAngle;
  public float size;
  public float x;
  public float y;
  public float randomValue;
  public float decaySpeed;
  public float growthSpeed;
  public float splitChanceMultiplier;
  public ArrayList<Circle> circles = new ArrayList<Circle>();

  public Branch(Growth growth, float x, float y, float size, float directionAngle, float splitChanceMultiplier)
  {
    this.growth = growth;
    this.x = x;
    this.y = y;
    this.size = size;
    this.directionAngle = directionAngle;
    this.randomValue = random(0f, 100000f);
    this.splitChanceMultiplier = splitChanceMultiplier;
    decaySpeed = random(decaySpeedMin, decaySpeedMax);
    growthSpeed = random(growthSpeedMin, growthSpeedMax);
  }

  public void draw()
  {
    if (growth.withering)
    {
      int length = circles.size();
      if (length > 0)
      {
        int index = 0;
        Circle circle = circles.get(index);
        circles.remove(index);
        circle.draw();
      }
      return;
    }

    if (size > 0)
    {
      Circle newCircle = new Circle(this);
      circles.add(newCircle);
      newCircle.draw();

      x += cos(directionAngle) * growthSpeed * scale;
      y += sin(directionAngle) * growthSpeed * scale;
      size -= decaySpeed * scale;

      directionAngle += (1 - noise(frameCount * 0.01, randomValue) * 2) * 0.1;

      if (random(0, 1) < splitChance * splitChanceMultiplier)
      {
        growth.newBranches.add(new Branch(growth, x, y, size, directionAngle, splitChanceMultiplier / 2));
      }
    }

    /*
    for (Circle circle : circles)
     {
     circle.draw();
     }
     */
  }
}

