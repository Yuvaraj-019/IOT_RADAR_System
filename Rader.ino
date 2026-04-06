/* 
 * Advanced IoT Radar System using ESP32 with Servo
 * Using ESP32Servo library
 */

#include <ESP32Servo.h>

// Pin definitions for ESP32
const int TRIG_PIN = 5;
const int ECHO_PIN = 18;  // GPIO 27
const int SERVO_PIN = 21;  // GPIO 9

// Radar configuration
const int MIN_ANGLE = 0;
const int MAX_ANGLE = 180;
const int SCAN_SPEED = 1;
const int MAX_DISTANCE = 400;
const int MIN_DISTANCE = 2;

Servo radarServo;
int currentDistance;
int currentAngle;
bool scanningDirection = true;

void setup() {
  // Initialize pins
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  // Initialize serial communication
  Serial.begin(115200);
  
  // Allow allocation of all timers for ESP32
  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  ESP32PWM::allocateTimer(2);
  ESP32PWM::allocateTimer(3);
  
  // Attach servo with ESP32 compatible settings
  radarServo.setPeriodHertz(50);    // Standard 50Hz servo
  radarServo.attach(SERVO_PIN, 500, 2400); // Min and max pulse width
  
  // Move to initial position
  radarServo.write(90);
  delay(1000);
  
  Serial.println("ESP32 Radar System with Servo Started");
  Serial.println("Angle,Distance");
}

void loop() {
  // Smooth scanning in one direction
  if (scanningDirection) {
    for (currentAngle = MIN_ANGLE; currentAngle <= MAX_ANGLE; currentAngle += SCAN_SPEED) {
      scanAndSendData();
    }
  } else {
    for (currentAngle = MAX_ANGLE; currentAngle >= MIN_ANGLE; currentAngle -= SCAN_SPEED) {
      scanAndSendData();
    }
  }
  
  // Reverse direction
  scanningDirection = !scanningDirection;
}

void scanAndSendData() {
  // Move servo to current angle
  radarServo.write(currentAngle);
  delay(15);
  
  // Get distance measurement
  currentDistance = getDistance();
  
  // Validate distance reading
  if (currentDistance > MAX_DISTANCE || currentDistance < MIN_DISTANCE) {
    currentDistance = 0; // Treat as no object detected
  }
  
  // Send data in format: "Angle,Distance"
  Serial.print(currentAngle);
  Serial.print(",");
  Serial.println(currentDistance);
  
  delay(20);
}

int getDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // Timeout after 30ms
  
  // Calculate distance in cm
  int distance = duration * 0.034 / 2;
  
  return distance;
}