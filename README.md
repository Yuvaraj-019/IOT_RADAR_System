# IOT_RADAR_System
This is a real-time ultrasonic radar system that uses an ESP32 microcontroller, servo motor, and HC-SR04 ultrasonic sensor to detect objects and display them on a radar-like interface using Processing IDE.
📖 Table of Contents
Overview

Features

Hardware Requirements

Circuit Diagram

Installation

Usage

Project Structure

Customization

Troubleshooting

Contributing

License

🎯 Overview
This project creates a functional radar system that:

Scans 180° area using a servo-mounted ultrasonic sensor

Detects objects in real-time

Displays results on a radar-like interface

Provides both visual and numerical feedback

https://images/radar-demo.gif <!-- Add actual demo gif later -->

✨ Features
🔧 Hardware Features
180° Scanning Range - Full semicircular coverage

Real-time Detection - Up to 400cm range

Smooth Servo Control - ESP32-optimized servo library

Accurate Distance Measurement - HC-SR04 ultrasonic sensor

🖥 Software Features
Interactive Radar Display - Professional visualization

Real-time Data Plotting - Live object tracking

Connection Status - Automatic port detection

Customizable Parameters - Adjustable range and speed

🔌 Hardware Requirements
Components List
Component	Quantity	Notes
ESP32 Development Board	1	Any ESP32 variant
SG90 Servo Motor	1	Or similar micro servo
HC-SR04 Ultrasonic Sensor	1	
Breadboard	1	
Jumper Wires	10+	Male-to-male
External 5V Power Supply	1	For servo motor
USB Cable	1	For ESP32 programming
📊 Specifications
Operating Voltage: 3.3V (ESP32), 5V (Servo external)

Current Consumption: ~500mA (peak with servo)

Scanning Speed: Adjustable 1-10 levels

Detection Range: 2cm - 400cm

Communication: Serial @ 115200 baud

🔋 Circuit Diagram
Wiring Connections
text
ESP32 Pinout:
╔═══════════════════════════════╗
║          CONNECTIONS          ║
╠═══════════════╦═══════════════╣
║ COMPONENT     ║ ESP32 PIN     ║
╠═══════════════╬═══════════════╣
║ Ultrasonic    ║               ║
║   VCC         ║ 3.3V          ║
║   GND         ║ GND           ║
║   TRIG        ║ GPIO 5        ║
║   ECHO        ║ GPIO 18       ║
╠═══════════════╬═══════════════╣
║ Servo Motor   ║               ║
║   VCC         ║ External 5V   ║
║   GND         ║ External GND* ║
║   Signal      ║ GPIO 21       ║
╚═══════════════╩═══════════════╝

* Important: Connect external GND to ESP32 GND
Power Setup
text
External 5V Power Supply:
  [+] → Servo VCC (Red wire)
  [-] → Servo GND (Brown wire) + ESP32 GND (common ground)
🛠 Installation
Step 1: Software Requirements
Arduino IDE Setup
Install Arduino IDE from arduino.cc

Add ESP32 Board Support:

File → Preferences → Additional Board Manager URLs

Add: https://dl.espressif.com/dl/package_esp32_index.json

Tools → Board → Board Manager → Search "ESP32" → Install

Install Required Libraries:

arduino
Sketch → Include Library → Manage Libraries
Search and install:
- "ESP32Servo" by Kevin Harrington
Processing IDE Setup
Download Processing from processing.org

No additional libraries required - uses built-in Serial library

Step 2: Hardware Assembly
Connect Ultrasonic Sensor:

bash
HC-SR04      ESP32
-------      -----
VCC    →     3.3V
GND    →     GND
TRIG   →     GPIO 5
ECHO   →     GPIO 18
Connect Servo Motor:

bash
Servo        Connection
----         ----------
Red (VCC)  → External 5V+
Brown (GND) → External GND & ESP32 GND
Orange (SIG)→ GPIO 21
Power Connections:

Connect external 5V power supply to servo

Ensure common ground between all components

Step 3: Upload Code
ESP32 Code:

Open ESP32_Radar_System.ino in Arduino IDE

Select correct board: Tools → Board → ESP32 Dev Module

Select correct port: Tools → Port → /dev/ttyUSB0 (Linux) or COM3 (Windows)

Click Upload

Processing Visualization:

Open Radar_Visualization.pde in Processing IDE

Click Run

🚀 Usage
Initial Setup
Power Up: Connect ESP32 via USB and external servo power

Verify Connection: Open Serial Monitor in Arduino IDE (115200 baud)

Expected Output:

text
ESP32 Radar System with Servo Started
Angle,Distance
0,25
2,0
4,30
...
Running the System
Start Processing Sketch: The radar window will open automatically

Automatic Port Detection: Processing will find and connect to ESP32

Monitor Operation:

Green sweeping line shows current scan angle

Red dots indicate detected objects

Numerical display shows exact angle and distance

Expected Behavior
Servo: Smooth 0°-180° back-and-forth motion

Sensor: Distance measurements every 30ms

Display: Real-time updating radar interface

Detection: Objects within 40cm shown as red markers

📁 Project Structure
text
ESP32-Radar-System/
│
├── 📄 ESP32_Radar_System.ino    # ESP32 Arduino code
├── 📄 Radar_Visualization.pde    # Processing visualization code
├── 📁 docs/                     # Documentation
│   ├── wiring-diagram.png
│   └── component-specs.md
├── 📁 images/                   # Project images and demos
│   ├── radar-demo.gif
│   └── circuit-setup.jpg
└── 📄 README.md                 # This file
⚙️ Customization
ESP32 Code Modifications
cpp
// In ESP32_Radar_System.ino

// Change scanning range
const int MIN_ANGLE = 30;    // Default: 0
const int MAX_ANGLE = 150;   // Default: 180

// Adjust scanning speed (1-10, lower = faster)
const int SCAN_SPEED = 3;    // Default: 2

// Modify detection range
const int MAX_DISTANCE = 300; // Default: 400 (cm)
Processing Visual Modifications
java
// In Radar_Visualization.pde

// Change display range (affects red dots)
if (Distance > 0 && Distance < 50) {  // Default: 40

// Modify radar appearance
stroke(0, 255, 0);  // Change green color
stroke(255, 0, 0);  // Change red color
🔧 Troubleshooting
Common Issues & Solutions
Problem	Symptoms	Solution
Servo Not Moving	No rotation, jittery motion	Check external 5V power and common ground
No Data in Processing	Blank radar, "Disconnected" status	Verify COM port and 115200 baud rate
Inaccurate Readings	Wrong distances, false detections	Ensure sensor is unobstructed, check wiring
Servo Overheating	Hot servo, erratic movement	Reduce scanning speed or range
Debugging Steps
Check Serial Output:

bash
# Expected format:
Angle,Distance
90,25
92,0
94,30
Verify Connections:

Multimeter check: 5V at servo, 3.3V at sensor

Continuity test: All GND connections

Test Components Individually:

Servo test: Direct 5V with signal

Sensor test: Measure with ruler

🤝 Contributing
We welcome contributions! Please see our Contributing Guidelines for details.

How to Contribute
Fork the repository

Create a feature branch: git checkout -b feature/amazing-feature

Commit your changes: git commit -m 'Add amazing feature'

Push to the branch: git push origin feature/amazing-feature

Open a Pull Request

Development Setup
bash
git clone https://github.com/yourusername/ESP32-Radar-System.git
cd ESP32-Radar-System
# Follow installation steps above
📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments
ESP32Servo Library by Kevin Harrington

Processing Foundation for the visualization IDE

HC-SR04 ultrasonic sensor community

SriTu Tech for initial inspiration

📞 Support
If you encounter any problems:

Check the Troubleshooting section

Search Issues for similar problems

Create a new issue with detailed description

🚀 Future Enhancements
Web interface for remote monitoring

Data logging to SD card

Multiple sensor support

Mobile app companion

AI object classification

<div align="center">
⭐ Don't forget to star this repository if you find it helpful!

Built with ❤️ using ESP32 and Processing

</div>
