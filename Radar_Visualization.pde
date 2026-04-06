import processing.serial.*;

/* 
 * Radar System for ESP32
 * Green theme radar display with motion blur effect and targeting
 */

Serial myport;

PFont f, smallFont;
int Angle = 90, Distance = 0;
String data;
boolean connected = false;

// Radar configuration
final int MAX_DISPLAY_DISTANCE = 200;
final int RADAR_CENTER_X = 625;
final int RADAR_CENTER_Y = 680;
final int RADAR_RADIUS = 600;

// Object tracking
ArrayList<RadarObject> detectedObjects = new ArrayList<RadarObject>();
RadarObject currentDetection = null;

// Motion blur effect - store previous sweep positions
ArrayList<Float> sweepHistory = new ArrayList<Float>();
final int SWEEP_HISTORY_SIZE = 20;

// Radar colors
color RADAR_GREEN = color(0, 255, 0);
color BACKGROUND = color(0, 0, 0);

class RadarObject {
  float angle;
  float distance;
  int lifetime;
  boolean isCurrent;
  
  RadarObject(float a, float d, boolean current) {
    angle = a;
    distance = d;
    lifetime = 255;
    isCurrent = current;
  }
  
  void update() {
    if (!isCurrent) {
      lifetime -= 3;
    }
  }
  
  boolean isAlive() {
    return lifetime > 0;
  }
}

void setup() {
  size(1250, 700);
  smooth();
  
  // Load fonts
  f = createFont("Arial", 24);
  smallFont = createFont("Arial", 16);
  textFont(f);
 
  // Port selection for ESP32
  printArray(Serial.list());
  String portName = "";
  
  for (String port : Serial.list()) {
    if (port.contains("ttyUSB") || port.contains("COM") || port.contains("usb") || 
        port.contains("ESP") || port.contains("Serial")) {
      portName = port;
      println("Found ESP32 port: " + port);
      break;
    }
  }
  
  if (portName.equals("") && Serial.list().length > 0) {
    portName = Serial.list()[0];
    println("Using first available port: " + portName);
  }
  
  try {
    myport = new Serial(this, portName, 115200);
    myport.bufferUntil('\n');
    connected = true;
    println("Connected to ESP32: " + portName);
  } catch (Exception e) {
    println("Connection failed: " + e.getMessage());
  }
  
  // Initialize sweep history with current angle
  for (int i = 0; i < SWEEP_HISTORY_SIZE; i++) {
    sweepHistory.add(90.0);
  }
}
 
void draw() {
  // Semi-transparent black background for motion blur effect
  fill(0, 50);
  noStroke();
  rect(0, 0, width, height);
  
  drawRadarDisplay();
  drawSweepingLineWithMotionBlur();
  drawDetectedObjects();
  drawCurrentTarget();
  drawRadarInfo();
  
  updateObjects();
  updateSweepHistory();
}

void drawRadarDisplay() {
  pushMatrix();
  translate(RADAR_CENTER_X, RADAR_CENTER_Y);
  
  // Draw radar arcs (distance rings)
  stroke(RADAR_GREEN);
  strokeWeight(1);
  noFill();
  
  // Distance rings
  arc(0, 0, 1200, 1200, PI, TWO_PI);
  arc(0, 0, 900, 900, PI, TWO_PI);
  arc(0, 0, 600, 600, PI, TWO_PI);
  arc(0, 0, 300, 300, PI, TWO_PI);
  
  // Angle lines
  line(-600, 0, 600, 0);
  line(0, 0, -600*cos(radians(30)), -600*sin(radians(30)));
  line(0, 0, -600*cos(radians(60)), -600*sin(radians(60)));
  line(0, 0, -600*cos(radians(90)), -600*sin(radians(90)));
  line(0, 0, -600*cos(radians(120)), -600*sin(radians(120)));
  line(0, 0, -600*cos(radians(150)), -600*sin(radians(150)));
  
  // Angle labels
  fill(RADAR_GREEN);
  textAlign(CENTER, CENTER);
  textFont(smallFont);
  text("0°", 650, 10);
  text("30°", 560, -300);
  text("60°", 320, -520);
  text("90°", 0, -580);
  text("120°", -320, -520);
  text("150°", -560, -300);
  text("180°", -650, 10);
  
  // Distance labels
  text("50cm", 0, -140);
  text("100cm", 0, -290);
  text("150cm", 0, -440);
  text("200cm", 0, -590);
  
  popMatrix();
}

void drawSweepingLineWithMotionBlur() {
  pushMatrix();
  translate(RADAR_CENTER_X, RADAR_CENTER_Y);
  
  // Draw motion blur trail (fading previous positions)
  for (int i = 0; i < sweepHistory.size(); i++) {
    float historyAngle = sweepHistory.get(i);
    
    // Calculate alpha based on position in history
    float alpha = map(i, 0, sweepHistory.size(), 20, 100);
    
    // Calculate stroke weight based on position
    float strokeWeight = map(i, 0, sweepHistory.size(), 0.5, 2);
    
    stroke(RADAR_GREEN, alpha);
    strokeWeight(strokeWeight);
    
    // Draw the historical sweep line
    line(0, 0, RADAR_RADIUS * cos(radians(historyAngle)), -RADAR_RADIUS * sin(radians(historyAngle)));
  }
  
  // Draw current sweep line (brightest and thickest)
  stroke(RADAR_GREEN, 255);
  strokeWeight(3);
  line(0, 0, RADAR_RADIUS * cos(radians(Angle)), -RADAR_RADIUS * sin(radians(Angle)));
  
  // Draw sweep endpoint
  noStroke();
  fill(RADAR_GREEN);
  ellipse(RADAR_RADIUS * cos(radians(Angle)), -RADAR_RADIUS * sin(radians(Angle)), 8, 8);
  
  popMatrix();
}

void drawDetectedObjects() {
  // Draw fading object dots (previous detections)
  for (int i = detectedObjects.size() - 1; i >= 0; i--) {
    RadarObject obj = detectedObjects.get(i);
    
    if (obj.isAlive() && !obj.isCurrent) {
      pushMatrix();
      translate(RADAR_CENTER_X, RADAR_CENTER_Y);
      
      float displayDistance = map(obj.distance, 0, MAX_DISPLAY_DISTANCE, 0, RADAR_RADIUS);
      float x = displayDistance * cos(radians(obj.angle));
      float y = -displayDistance * sin(radians(obj.angle));
      
      // Fading object dot
      fill(RADAR_GREEN, obj.lifetime);
      noStroke();
      ellipse(x, y, 6, 6);
      
      popMatrix();
    }
  }
}

void drawCurrentTarget() {
  // Draw current detection with targeting symbol
  if (currentDetection != null && currentDetection.isAlive()) {
    pushMatrix();
    translate(RADAR_CENTER_X, RADAR_CENTER_Y);
    
    float displayDistance = map(currentDetection.distance, 0, MAX_DISPLAY_DISTANCE, 0, RADAR_RADIUS);
    float x = displayDistance * cos(radians(currentDetection.angle));
    float y = -displayDistance * sin(radians(currentDetection.angle));
    
    // Targeting symbol - small crosshair
    stroke(RADAR_GREEN, 200);
    strokeWeight(1.5);
    noFill();
    
    // Crosshair lines
    line(x - 8, y, x + 8, y);
    line(x, y - 8, x, y + 8);
    
    // Small circle around target
    ellipse(x, y, 12, 12);
    
    // Distance label above target
    fill(RADAR_GREEN, 200);
    noStroke();
    textAlign(CENTER, BOTTOM);
    textFont(smallFont);
    text(int(currentDetection.distance) + "cm", x, y - 15);
    
    popMatrix();
  }
}

void drawRadarInfo() {
  fill(RADAR_GREEN);
  textFont(f);
  textAlign(LEFT);
  
  // Radar title
  text("RADAR SYSTEM", 50, 40);
  
  // Real-time data display
  text("ANGLE: " + Angle + "°", 50, 80);
  text("DISTANCE: " + Distance + " cm", 50, 110);
  
  // Connection status
  if (connected) {
    text("STATUS: CONNECTED", 50, 140);
  } else {
    text("STATUS: DISCONNECTED", 50, 140);
  }
  
  // Object count
  int activeObjects = 0;
  for (RadarObject obj : detectedObjects) {
    if (obj.isAlive()) activeObjects++;
  }
  text("TARGETS: " + activeObjects, 50, 170);
  
  // Current target info
  if (currentDetection != null && currentDetection.isAlive()) {
    text("LOCKED: " + int(currentDetection.distance) + "cm", 50, 200);
  } else {
    text("LOCKED: ---", 50, 200);
  }
  
  // Range info at bottom
  textFont(smallFont);
  text("RANGE: 0-200cm", 50, height - 30);
  text("SCAN: 0-180°", 50, height - 10);
}

void updateObjects() {
  // Update current detection
  if (currentDetection != null) {
    currentDetection.update();
    if (!currentDetection.isAlive()) {
      currentDetection = null;
    }
  }
  
  // Remove dead objects from history
  for (int i = detectedObjects.size() - 1; i >= 0; i--) {
    RadarObject obj = detectedObjects.get(i);
    obj.update();
    if (!obj.isAlive()) {
      detectedObjects.remove(i);
    }
  }
}

void updateSweepHistory() {
  // Add current angle to history
  sweepHistory.add((float)Angle);
  
  // Remove oldest angle if history is too long
  if (sweepHistory.size() > SWEEP_HISTORY_SIZE) {
    sweepHistory.remove(0);
  }
}

void serialEvent(Serial myport) { 
  try {
    data = myport.readString().trim();
    
    if (data.length() > 0 && !data.startsWith("ESP32") && !data.startsWith("Angle")) {
      String[] parts = split(data, ',');
      if (parts.length == 2) {
        try {
          Angle = int(trim(parts[0]));
          Distance = int(trim(parts[1]));
          println("Angle: " + Angle + ", Distance: " + Distance);
          
          // Add object if detected within range
          if (Distance > 0 && Distance <= MAX_DISPLAY_DISTANCE) {
            // Create current detection
            currentDetection = new RadarObject(Angle, Distance, true);
            
            // Also add to fading objects history
            detectedObjects.add(new RadarObject(Angle, Distance, false));
          } else {
            // No current detection
            currentDetection = null;
          }
          
        } catch (Exception e) {
          println("Number format error: " + data);
        }
      }
    }
  } catch (Exception e) {
    println("Serial error: " + e.getMessage());
  }
}

void exit() {
  if (myport != null) {
    myport.stop();
  }
  super.exit();
}
