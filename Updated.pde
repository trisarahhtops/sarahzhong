import ddf.minim.*;
Minim minim;
AudioPlayer soundEffectCircle;
AudioPlayer soundEffectStar;

PImage backgroundImage;
Table xy;
Table rainfallData; // Table for rainfall data
Table windSpeedData; // Table for wind speed data
int index = 0;
int numShapes = 50; // Number of circles and stars
Circle[] circles = new Circle[numShapes];
Star[] stars = new Star[numShapes];
String textBoxContent = "";
boolean displayTextBox = false;
float textBoxX = -1000; 
float textBoxY = -1000;




boolean showCircles = true;

void setup() {
  size(1400, 775);

  minim = new Minim(this);
  soundEffectCircle = minim.loadFile("Mario-coin-sound.wav");
  soundEffectStar = minim.loadFile("decide.mp3");
  
  // Load background image
  backgroundImage = loadImage("background.jpeg");
  if (backgroundImage != null) {
    backgroundImage.resize(width, height);
    println("Background image loaded and resized.");
  } else {
    println("Error loading background image.");
  }

  // Load CSV data
  xy = loadTable("http://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2020-08-15T19%3A06%3A09&rToDate=2020-08-17T19%3A06%3A09&rFamily=wasp&rSensor=ES_B_06_418_7BED&rSubSensor=HUMA", "csv");
  
  // Load rainfall data
  rainfallData = loadTable("rainfall_data.csv", "header");
  
  // Load wind speed data
  windSpeedData = loadTable("windspeed_data.csv", "header");

  for (int i = 0; i < numShapes; i++) {
    float x = random(width);
    float y = random(height);
    float diameter = random(20, 100);
    float speedX = random(-2, 2);
    float speedY = random(-2, 2);
    color c = color(random(255), random(255), random(255), 150);
    
    // Assign a unique animation speed to each shape
    float shapeAnimationSpeed = random(0.005, 0.02);

    circles[i] = new Circle(x, y, diameter, speedX, speedY, c, shapeAnimationSpeed);
    stars[i] = new Star(x, y, diameter, windSpeedData.getFloat(i, "Windspeed"), c); // Pass the index to identify the star
  }
}

void draw() {
  fill(255);
  textSize(18);
  textAlign(RIGHT);
  text("Press 'C' to show Circles, 'S' to show Stars", width - 20, 40);

  if (backgroundImage != null) {
    image(backgroundImage, 0, 0);
  } else {
    background(0);
  }

  for (int i = 0; i < numShapes; i++) {
    boolean isMouseOverShape = dist(mouseX, mouseY, circles[i].x, circles[i].y) < circles[i].diameter / 2;

    if (isMouseOverShape) {
      circles[i].enlarge();
      stars[i].enlarge();
    } else {
      circles[i].shrink();
      stars[i].shrink();
    }

    // Move the shape
    circles[i].move();
    stars[i].move();

    float circleRotationAmount = map(circles[i].x, 0, width, circles[i].minRotationSpeed, circles[i].maxRotationSpeed);
    float starRotationAmount = map(stars[i].x, 0, width, stars[i].minRotationSpeed, stars[i].maxRotationSpeed);

    circles[i].updateRotation(circleRotationAmount);
    stars[i].updateRotation(starRotationAmount);

    circles[i].display();
    stars[i].display();
  }
  
 if (index < xy.getRowCount()) {
    int yValue = xy.getInt(index, 1);
    fill(255);
    
    float textX = 100;
    float textY = 30;
    
    text("Humidity: " + yValue, textX, textY);
    index++;
}




  if (showCircles) {
  // Display circles
  for (int i = 0; i < numShapes; i++) {
    boolean isMouseOverShape = dist(mouseX, mouseY, circles[i].x, circles[i].y) < circles[i].diameter / 2;

    if (isMouseOverShape) {
      circles[i].enlarge();
    } else {
      circles[i].shrink();
    }

    // Move the circle
    circles[i].move();

    float circleRotationAmount = map(circles[i].x, 0, width, circles[i].minRotationSpeed, circles[i].maxRotationSpeed);

    circles[i].updateRotation(circleRotationAmount);
    circles[i].display();
  }
} else {
  // Display stars
  for (int i = 0; i < numShapes; i++) {
    boolean isMouseOverShape = dist(mouseX, mouseY, stars[i].x, stars[i].y) < stars[i].size / 2;

    if (isMouseOverShape) {
      stars[i].enlarge();
    } else {
      stars[i].shrink();
    }

    // Move the star
    stars[i].move();

    float starRotationAmount = map(stars[i].x, 0, width, stars[i].minRotationSpeed, stars[i].maxRotationSpeed);

    stars[i].updateRotation(starRotationAmount);
    stars[i].display();
  }
}


  for (int i = 0; i < numShapes; i++) {
    if (circles[i].isClicked()) {
      Circle selectedCircle = circles[i];
      fill(0);
      ellipse(selectedCircle.x, selectedCircle.y, selectedCircle.diameter, selectedCircle.diameter);
      textSize(16);
       textBoxContent = "Time: " + rainfallData.getString(i, "Time") + "\nRainfall: " + rainfallData.getFloat(i, "Rainfall");
      textBoxX = selectedCircle.x; // 更新文本框的位置为圆圈的位置
      textBoxY = selectedCircle.y + selectedCircle.diameter / 2 + 20;
      displayTextBox = true;
    }
     if (displayTextBox) {
    displayTextBox();
  }
  
  
  

      if (stars[i].isClicked()) {
      Star selectedStar = stars[i];
      fill(0);
      textSize(16);
      
     textBoxContent = "Time: " + windSpeedData.getString(i, "Time") + "\nWind Speed: " + windSpeedData.getFloat(i, "Windspeed");
      textBoxX = selectedStar.x; // 更新文本框的位置为星星的位置
      textBoxY = selectedStar.y + selectedStar.size / 2 + 20;
      displayTextBox = true;
      
      if (displayTextBox) {
    displayTextBox();
  }
      }
  }
}
   

void displayTextBox() {
  fill(255); // 背景颜色
  rect(textBoxX, textBoxY, 180, 70); // 文本框位置和大小

  fill(0); // 文本颜色
  textSize(14);
  textAlign(LEFT);
  text(textBoxContent, textBoxX + 10, textBoxY + 20, 280, 80); // 文本位置和大小
}



void mouseClicked() {
  // 遍历所有的圆圈
  for (int i = 0; i < numShapes; i++) {
    if (circles[i].isMouseOver()) {
      // 取消其他圆圈的点击状态
      for (int j = 0; j < numShapes; j++) {
        if (j != i) {
          circles[j].cancelClick();
        }
      }
      // 点击当前圆圈
      circles[i].applyEffect();
      soundEffectCircle.rewind(); // 重置音频播放
      soundEffectCircle.play();
      displayTextBox = false;
    }
  }
  
  // 遍历所有的星星
  for (int i = 0; i < numShapes; i++) {
    if (stars[i].isMouseOver()) {
      // 取消其他星星的点击状态
      for (int j = 0; j < numShapes; j++) {
        if (j != i) {
          stars[j].cancelClick();
        }
      }
      // 点击当前星星
      stars[i].applyEffect();
      soundEffectStar.rewind(); // 重置音频播放
      soundEffectStar.play();
      displayTextBox = false;
    }
  }
}

class Circle {
  float x, y;
  float diameter;
  float speedX, speedY;
  color c;
  float hoverDiameter; // Diameter when hovered over
  float animationSpeed; // Animation speed for the circle
  float minRotationSpeed;
  float maxRotationSpeed;
  boolean clicked = false;
  float angle = 0;
  
  PVector targetPosition;
  float movementSpeed = 1.0;

  Circle(float x, float y, float diameter, float speedX, float speedY, color c, float animationSpeed) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;
    this.speedX = speedX;
    this.speedY = speedY;
    this.c = c;
    this.hoverDiameter = diameter * 1.2; // Increase diameter when hovered
    this.animationSpeed = animationSpeed; // Assign animation speed
    this.minRotationSpeed = -0.01;
    this.maxRotationSpeed = 0.01;
    
    targetPosition = new PVector(x,y);
  }

  void move() {
    if (!clicked) {
      PVector direction = PVector.sub(targetPosition, new PVector(x, y));
      direction.normalize();
      direction.mult(movementSpeed);
      x += direction.x;
      y += direction.y;

      float proximity = 2.0;
      if (PVector.dist(targetPosition, new PVector(x, y)) < proximity) {
        targetPosition.x = random(width);
        targetPosition.y = random(height);
      }
    }
  }
  
  void cancelClick() {
    clicked = false;
  }

  boolean isMouseOver() {
    return dist(mouseX, mouseY, x, y) < diameter / 2;
  }

  void display() {
    fill(c);
    ellipse(x, y, diameter, diameter);
  }

  void updateRotation(float angleChange) {
    // Update the angle of rotation
    angle += angleChange;
    angle %= TWO_PI; // Keep the angle within the range [0, 2*PI]
  }

  void rotate(float angleChange) {
    // Apply rotation to the circle
    this.angle += angleChange;
    this.angle %= TWO_PI; // Keep the angle within the range [0, 2*PI]
  }

  void enlarge() {
    float targetDiameter = hoverDiameter;
    if (diameter < targetDiameter) {
      diameter += animationSpeed;
      diameter = min(diameter, targetDiameter);
    }
  }

  void shrink() {
    float targetDiameter = hoverDiameter;
    if (diameter > targetDiameter) {
      diameter -= animationSpeed;
      diameter = max(diameter, targetDiameter);
    }
  }
  
  void applyEffect() {
    clicked = !clicked;
  }
  
  boolean isClicked() {
    return clicked;
  }
}

import processing.core.PVector;
class Star {
  float x, y;
  float size;
  float windSpeed; // Wind speed data
  color c;
  color starColor;
  color clickedColor = color(0);
  boolean clicked = false;
  float angle = 0;
  float minRotationSpeed;
  float maxRotationSpeed;
  
  PVector targetPosition;
  float movementSpeed = 1.0;

  Star(float x, float y, float size, float windSpeed, color c) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.windSpeed = windSpeed;
    this.c = c;
    this.minRotationSpeed = -0.01;
    this.maxRotationSpeed = 0.01;
    starColor =c;
    
    targetPosition = new PVector(x,y);
  }
  
  void cancelClick() {
    clicked = false;
  }

  void move() {
    // Implement movement logic for stars if needed
    if (!clicked) {
      // Continue moving
       if (!clicked) {
      // 计算星星朝目标位置移动的增量
      PVector direction = PVector.sub(targetPosition, new PVector(x, y));
      direction.normalize();
      direction.mult(movementSpeed);

      // 更新星星的位置
      x += direction.x;
      y += direction.y;

      // 如果星星接近目标位置，更新目标位置
      float proximity = 2.0; // 你可以根据需要调整这个值
      if (PVector.dist(targetPosition, new PVector(x, y)) < proximity) {
        targetPosition.x = random(width);
        targetPosition.y = random(height);
      }
    }
  }
  }
  boolean isMouseOver() {
    return dist(mouseX, mouseY, x, y) < size / 2;
  }

  void display() {
    if (clicked) {
      fill(clickedColor);// 如果星星被点击，使用黑色
    } else {
      fill(starColor); // 否则使用原始颜色
    }
    noStroke();
    drawStar(x, y, size / 2, size / 4, 5);
  }


  void updateRotation(float angleChange) {
    // Update the angle of rotation
    angle += angleChange;
    angle %= TWO_PI; // Keep the angle within the range [0, 2*PI]
  }

  void rotate(float angleChange) {
    // Apply rotation to the star
    this.angle += angleChange;
    this.angle %= TWO_PI; // Keep the angle within the range [0, 2*PI]
  }

  void enlarge() {
    // Implement enlargement logic for stars if needed
  }

  void shrink() {
    // Implement shrinkage logic for stars if needed
  }

  void applyEffect() {
    clicked = !clicked;
  }

  boolean isClicked() {
    return clicked;
  }

  void drawStar(float x, float y, float radius1, float radius2, int npoints) {
    float angle = TWO_PI / npoints;
    float halfAngle = angle / 2.0;
    beginShape();
    for (float a = -PI/2; a < TWO_PI-PI/2; a += angle) {
      float sx = x + cos(a) * radius2;
      float sy = y + sin(a) * radius2;
      vertex(sx, sy);
      sx = x + cos(a + halfAngle) * radius1;
      sy = y + sin(a + halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
}

void keyPressed() {
  if (key == 'C' || key == 'c') {
    showCircles = true;
  } else if (key == 'S' || key == 's') {
    showCircles = false;
  }
}
