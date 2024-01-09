Button countdownButton;
int record = 0;
int recordStartTime = 0;
int recordDuration = 1000; // 1 second
int countdown = 10; // Countdown from 10 seconds
int lastCountdownUpdateTime = 0; 
boolean countingDown = false;
boolean showCountdown = false;
boolean showButton = true;

import processing.video.*;
Capture cam;
int captureFrames = 100; // 100 frames is about 10 seconds
int currentCaptureFrame = 0;
int currentPlaybackFrame = 0;
PImage[] capturedFrames = new PImage[captureFrames];
boolean isCapturing = false;
int state = 0; // 0 is Countdown, 1 is Capture
float camScale = 0.7;
int pixelationFactor = 5; 

// Button between color and B&W
Button colorBWButton;
boolean isBWMode = false;
boolean showSlider = false; 
Slider pixelationSlider;

// Defining pixel mirror effect
Button mirrorButton; 
boolean isPixelMirror = false;
int cellSize = 15;
int cols, rows;
boolean showMirrorEffect = false;
int buttonX = 20; 
int buttonY = 20; 
int buttonWidth = 100; 
int buttonHeight = 50;

// Defining color slider
ColorSlider colourRange;
boolean showColorSlider = false;

//Button sound
import ddf.minim.*;
import ddf.minim.signals.*;
Minim minim;
AudioSample sound;

void setup() {
  size(800, 780);
  frameRate(10);
  
  cols = width / cellSize;
  rows = height / cellSize;

  countdownButton = new Button(width/2 - 200, height/2 - 25, 400, 50);
  countdownButton.setText("Hi! Click here to record your video");
  countdownButton.onClick(new ButtonClickHandler() {
    public void onClick() {
      state = 0;
      countingDown = true;
      record = 3;
      recordStartTime = millis();
      countdownButton.setVisible(false);
      showCountdown = true;
      showButton = false; 
    }
  });

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    cam = new Capture(this, width, height, cameras[0], 30);
  }

  cam.start();

  // Pixelation slider
  pixelationSlider = new Slider(100, 620, 90*2, 20, "Pixelation Factor", 2, 255);

  // ColorBWButton
  colorBWButton = new Button(20, height - 70, 150, 50);
  colorBWButton.setText("Color Mode");
  colorBWButton.onClick(new ButtonClickHandler() {
    public void onClick() {
      isBWMode = !isBWMode;
      if (isBWMode) {
        colorBWButton.setText("B&W Mode");
      } else {
        colorBWButton.setText("Color Mode");
      }
    }
  });
  
  mirrorButton = new Button(620, height - 70, 150, 50);
  mirrorButton.setText("Pixel Mirror");
  mirrorButton.onClick(new ButtonClickHandler() {
    public void onClick() {
      isPixelMirror = !isPixelMirror;
      if (isPixelMirror){
        mirrorButton.setText("Pixel Mirror Off");
      } else {
        mirrorButton.setText("Pixel Mirror On");
      }
    }
  });
  colourRange = new ColorSlider(460, 620, 127 * 2, 20, "Colour Palette");
  minim = new Minim(this);
  sound = minim.loadSample("pick-92276.mp3");
}

void draw() {
  background(220);

  if (state == 0) {
    countdownState();
  } else if (state == 1) {
    captureState();
    if (showMirrorEffect) {
      mirrorVideo();
    }
  }

  if (state == 1) {
    // Show the color/b&w button and slider after countdown
    colorBWButton.display();
    mirrorButton.display();
    colourRange.display();
    
    showSlider = true;
    //showColorSlider = true;
  } else {
    showSlider = false;
    //showColorSlider = false;
  }
  if (showSlider) {
    pixelationSlider.display();
    colourRange.display();
  }
  
  if (mirrorButton.isMouseOver() && state == 1) {
    if (mousePressed) {
      showMirrorEffect = !showMirrorEffect;
    }
  }
}

void countdownState() {
  if (countingDown && record > 0 && millis() - recordStartTime >= recordDuration) {
    record--;
    recordStartTime = millis();
  }

  if (showCountdown) {
    if (record > 0) {
      textSize(48);
      textAlign(CENTER, CENTER);
      text(record, width/2, height/2);
    } else {
      countingDown = false;
      showCountdown = false;
      isCapturing = true;
      state = 1;

      showButton = true;
    }
  }

  if (showButton) {
    countdownButton.autoSize();
    countdownButton.display();
  }
}

void captureState() {
  if (isCapturing) {
    if (cam.available() == true) {
      cam.read();
      if (currentCaptureFrame < captureFrames) {
        capturedFrames[currentCaptureFrame] = cam.get();
        currentCaptureFrame++;
      } else {
        isCapturing = false;
      }

      // Cam Scale and the positioning of the cam
      float camScale = 0.7;
      float camWidthScaled = cam.width * camScale;
      float camHeightScaled = cam.height * camScale;
      float xPosition = (width - camWidthScaled);
      float yPosition = (height - camHeightScaled);
      pushMatrix();
      scale(camScale);
      image(cam, xPosition, yPosition, camWidthScaled + 100, camHeightScaled);
      popMatrix();
    }

    fill(0);
    textSize(32);

    if (millis() - lastCountdownUpdateTime >= 1000 && countdown > 0) {
      countdown--;
      lastCountdownUpdateTime = millis();
    }

    float textX = width/2;
    float textY = 40;
    textAlign(CENTER, CENTER);
    text("Recording... " + countdown, textX, textY);
  } else {
    background(255);

    PImage pixelatedFrame = capturedFrames[currentPlaybackFrame].get();
    pixelatedFrame.filter(PImage.POSTERIZE, pixelationFactor);

    if (isBWMode) {
      pixelatedFrame.filter(PImage.GRAY); // Apply B&W effect
    }

    float playbackWidthScaled = pixelatedFrame.width * camScale;
    float playbackHeightScaled = pixelatedFrame.height * camScale;
    float xPosition = (width - playbackWidthScaled)/2;
    float yPosition = (height - playbackHeightScaled)/2;

    image(pixelatedFrame, xPosition + 20, yPosition -40, playbackWidthScaled, playbackHeightScaled-50);

    fill(34);
    stroke(0);
    strokeWeight(3);
    rect(0, height - 80, width, 100);

    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Click on each button to change the effects of your video", width/2, height-50);

    currentPlaybackFrame = (currentPlaybackFrame + 1) % captureFrames;
  }
}

void mirrorVideo() {
  if (state != 1) {
    return;
  }

  if (showMirrorEffect) {
    PImage currentFrame = capturedFrames[currentPlaybackFrame].get();
    
    colourRange.updateColor();
    
    float playbackWidthScaled = (currentFrame.width * camScale);
    float playbackHeightScaled = (currentFrame.height * camScale);
    float xPosition = (width - playbackWidthScaled)/2;
    float yPosition = (height - playbackHeightScaled)/2;

    // Pixel Mirror on playback frame (current frame)
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        int x = i * cellSize;
        int y = j * cellSize;
        int loc = (currentFrame.width - x - 1) + y * currentFrame.width;
        
        color c = currentFrame.pixels[loc];
        float sz = (brightness(c)/255.0) * cellSize;
        
        noStroke();
        rect((xPosition + x + (playbackWidthScaled - currentFrame.width)/2 + cellSize/2),
            (yPosition + y + (playbackHeightScaled - currentFrame.height)/2 + cellSize/2),
            sz, sz);
      }
    }
  }
}

class Button {
  float x, y, w, h;
  String label;
  ButtonClickHandler clickHandler;
  boolean visible = true;

  Button(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void setText(String label) {
    this.label = label;
  }

  // Button Size
  void autoSize() {
    textSize(16);
    float textWidth = textWidth(label) + 20;
    w = max(400, textWidth); //w is width
    h = 50; //h is height
  }

  void onClick(ButtonClickHandler handler) {
    this.clickHandler = handler;
  }

  void display() {
    if (visible) {
      fill(114, 133, 165);
      stroke(77, 81, 109);
      strokeWeight(3);
      rect(x, y, w, h);
      fill(0);
      textSize(16);
      textAlign(CENTER, CENTER);
      text(label, x + w/2, y + h/2);
      
    }
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void mousePressed() {
    if (isMouseOver() && clickHandler != null) {
      clickHandler.onClick();
    }
  }

  void setVisible(boolean isVisible) {
    visible = isVisible;
  }
}

interface ButtonClickHandler {
  void onClick();
}

//Slider for the pixelation factor
class Slider {
  float x, y; 
  float sliderWidth, sliderHeight, sliderValue; 
  boolean isDragging;
  String label;
  float minValue, maxValue; 

  Slider(float x, float y, float sliderWidth, float sliderHeight, String label, float minValue, float maxValue) {
    this.x = x;
    this.y = y;
    this.sliderWidth = sliderWidth;
    this.sliderHeight = sliderHeight;
    this.sliderValue = 5; // Default value
    this.isDragging = false;
    this.label = label;
    this.minValue = minValue;
    this.maxValue = maxValue;
  }

  void display() {
    fill(16);
    textSize(14);
    textAlign(LEFT, CENTER);
    text(label, x, y - 20);
    
    fill(200);
    rect(x, y, sliderWidth, sliderHeight);

//Dragging
    if (isDragging) {
      fill(50, 100, 150);
    } else {
      fill(100, 150, 200);
    }
    rect(x + sliderValue, y, 10, sliderHeight);


    fill(0);
    textAlign(LEFT, CENTER);
    text(minValue, x, y + sliderHeight + 10);
    textAlign(RIGHT, CENTER);
    text(maxValue, x + sliderWidth, y + sliderHeight + 10);
  }

  boolean isMouseOver() {
    return mouseX >= x + sliderValue && mouseX <= x + sliderValue + 10 && mouseY >= y && mouseY <= y + sliderHeight;
  }

  void mousePressed() {
    if (isMouseOver()) {
      isDragging = true;
    }
  }

  void mouseReleased() {
    isDragging = false;
  }

  void update() {
    if (isDragging) {
      sliderValue = constrain(mouseX - x, 0, sliderWidth - 10); //Slider can only go from 2 to 255
      pixelationFactor = int(map(sliderValue, 0, sliderWidth - 10, 2, 255));
    }
  }
}

class ColorSlider {
  float x, y;
  float sliderWidth, sliderHeight; 
  float rgbRed, rgbGreen, rgbBlue; 
  boolean isDragging; 
  String label;

  ColorSlider(float x, float y, float sliderWidth, float sliderHeight, String label) {
    this.x = x;
    this.y = y;
    this.sliderWidth = sliderWidth;
    this.sliderHeight = sliderHeight;
    this.rgbRed = 0; 
    this.rgbGreen = 127; 
    this.rgbBlue = 255; 
    this.isDragging = false;
    this.label = label;
  }

  void display() {
    fill(0);
    textSize(14);
    textAlign(LEFT, CENTER);
    text(label, x, y - 20);

    fill(rgbRed, rgbGreen, rgbBlue);
    rect(x, y, sliderWidth, sliderHeight);

    if (isDragging) {
      fill(50, 100, 150);
    } else {
      fill(10, 150, 200);
    }
    ellipse(x + (rgbRed/255.0) * sliderWidth, y + sliderHeight/2, 15, 15);

    fill(0);
    textAlign(CENTER, CENTER);
    text("R", x - 20, y + sliderHeight+10);
    text("G", x + sliderWidth/2, y + sliderHeight+10);
    text("B", x + sliderWidth+20, y + sliderHeight+10);
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + sliderWidth && mouseY >= y && mouseY <= y + sliderHeight;
  }

  void mousePressed() {
    if (isMouseOver()) {
      isDragging = true;
    }
  }

  void mouseReleased() {
    isDragging = false;
  }

  void updateColor() {
    fill(rgbRed, rgbGreen, rgbBlue);
  }
  
  void update() {
    if (isDragging) {
      rgbRed = constrain(mouseX - x, 0, sliderWidth);
      rgbGreen = constrain(mouseX - x - sliderWidth/2, 0, sliderWidth);
      rgbBlue = constrain(mouseX - x - sliderWidth, 0, sliderWidth);
      updateColor();
    }
  }
}

void mousePressed() {
  countdownButton.mousePressed();
  colorBWButton.mousePressed();
  pixelationSlider.mousePressed();
  colourRange.mousePressed();
  mirrorButton.mousePressed();
  
  if (colorBWButton.isMouseOver() || colourRange.isMouseOver() || mirrorButton.isMouseOver() || 
  pixelationSlider.isMouseOver() ) {
    sound.trigger();
  }
}

void mouseReleased() {
  pixelationSlider.mouseReleased();
  colourRange.mouseReleased();
}

void mouseDragged() {
  pixelationSlider.update();
  colourRange.update();
}

void mouseClicked() {
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth && mouseY >= buttonY && mouseY <= buttonY + buttonHeight){
    showMirrorEffect = !showMirrorEffect;
  }
}

void stop() {
  minim.stop();
  super.stop();
}
