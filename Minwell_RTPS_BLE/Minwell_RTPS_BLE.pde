import android.net.Uri; 
import android.database.Cursor; 
import android.content.Intent; 
import android.provider.MediaStore; 
import android.app.Activity; 
import android.content.Context; 
import android.graphics.Bitmap; 
import java.io.ByteArrayInputStream; 
import java.io.ByteArrayOutputStream; 
import java.io.File; 
import java.io.FileOutputStream; 
import android.os.Environment; 
import android.graphics.BitmapFactory; 
import android.Manifest; 
import android.content.pm.PackageManager; 
import android.os.Build; 
import android.os.Build.VERSION_CODES; 
import processing.core.PConstants;
import controlP5.*;


import android.widget.Toast;
static final String permissionCoarseLocation = "android.permission.ACCESS_COARSE_LOCATION";
BleUART bleUart;
String appText         = "";
String deviceListText  = "";
String messageSent     = "";
String messageReceived = "";
String hedefCihaz = "DW1756";

Activity activity; //Arkaplan secimi iv
Context context; 
PImage img; 
boolean image_loaded; 

ControlP5 cp5;
controlP5.Toggle dev_toggle, kalman_toggle, LMS_toggle;
controlP5.Button Arkaplan_buton;
boolean show_kalman,show_LMS;
PImage arkaplan;  // Declare variable "a" of type PImage


final float mean = 0, stddev = 0.2; // Mean and standard deviation
final float variance = stddev * stddev;
final float delta_time = 0.01;                // 10 hz = 1/0.01 seconds
final float kalman_stddev = 0.4;
float meterToPixel, mean_pixel, stddev_pixel; // Pixel ve metre degerlerini cevirebilmek icin sabit sayılar
float kalman_var = kalman_stddev*kalman_stddev;
/* Anchor ve uzaklik degerleri */
Anchor anchor1, anchor2, anchor3, anchor4, anchor5;
int[] x_Anchor = {0, 11, 0, 5, 11}, y_Anchor = {0, 0, 6, 3, 6}; // Anchor x y koordinatlari
float[] distance_measured = {0, 0, 0, 0, 0};                    // Olculen uzakliklar

/* Least Mean Square Parametreleri */
float[] position_estimate_LMS = {4.0, 4.0}; // Initialization
float diff_Ex = 0, diff_Ey = 0;             // (measured_distance-estimated_distance)^2 fonksiyonunun gradienti
float measurement_covariance = 0.00001;         // 0.01;
float x_smooth, y_smooth;
float easing = 0.1;
/* float process_covariance = 0.000001; */
boolean devMode = false;
/* Constant Acceleration Kalman Filter Parametreleri */

float[] position_estimate_KF = {5.0, 5.0}; // Initial random guess for KF (5,5)
float tempX,tempY;
/* x ve y icin kalman filtreleri */
KalmanFilter filter = new KalmanFilter();
KalmanFilter filter2 = new KalmanFilter();

void setup() { 
  bleUart = new BleUART(this);
    if (!hasPermission(permissionCoarseLocation)) {
    println("setup() requesting permission ACCESS_COARSE_LOCATION (for Bluetooth LE scanning)");
    requestPermission(permissionCoarseLocation, "onLocationPermission");
  }
  else {
    // skip the prompt, trigger the callback
    onLocationPermission(true);
  }
  activity = this.getActivity(); 
  context = activity.getApplicationContext(); 
  if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP_MR1) { 
    requestParticularPermission();
  }
  
  init_UI();
  
  init_Filters();
  
} 
void onLocationPermission(boolean permitted) {
  if (permitted) {
    bleUart.init();
  }
  else {
    println("You must grant the ACCESS_COARSE_LOCATION  permission, as this is required for Bluetooth LE scanning.");
  }
}
void draw() { 
   updateDeviceListText();

  if (image_loaded && !devMode) {
    image(img, 0, 0);
  }
  else{
    if(!devMode){
      background(arkaplan);
      metrekare(11, 6);
    }
  }
  /* Arka planin cizimi */
  //background(240);

  strokeWeight(16);
  stroke(0, 0, 0);
  strokeWeight(10);
  //point(mouseX, mouseY);
    line(mouseX, mouseY, pmouseX, pmouseY);


  /*Mean ve stddev degerlerinin pixele cevrilmesi*/
  mean_pixel = mean * meterToPixel;
  stddev_pixel = stddev * meterToPixel;

  /* Anchorlarin yerlestirilmesi */
  anchor1 = new Anchor(x_Anchor[0], y_Anchor[0], "0,0");
  anchor2 = new Anchor(x_Anchor[1], y_Anchor[1], "11,0");
  anchor3 = new Anchor(x_Anchor[2], y_Anchor[2], "0,6");
  anchor4 = new Anchor(x_Anchor[3], y_Anchor[3], "5,3");
  anchor5 = new Anchor(x_Anchor[4], y_Anchor[4], "11,6");
  
  /* 60 frames per second programda her 6 framede bir kere data aliyoruz = 10 hz */
  if (frameCount % 6 == 0)
  {
      thread("requestData");
  }
  
  if (frameCount % 300 == 0 && devMode)
  {
      if (image_loaded) {
        image(img, 0, 0);
      }
      else{
      background(arkaplan);
      }

  }
  if(devMode){
      stroke( 51, 107, 255 );
      if(show_kalman){
        strokeWeight(10);
        //point(position_estimate_KF[0]*meterToPixel+10,position_estimate_KF[1]*meterToPixel+10);
        line(position_estimate_KF[0]*meterToPixel+10, position_estimate_KF[1]*meterToPixel+10, tempX, tempY);
      }
      
      textSize(20);
      fill( 51, 107, 255);
      text("Kalman", 90*width/100, height/10 - 70);
      stroke(255, 87, 51);
      
      if(show_LMS){
          strokeWeight(10);
          point(position_estimate_LMS[0]*meterToPixel+10,position_estimate_LMS[1]*meterToPixel+10);
      }
      
      textSize(20);
      fill(255, 87, 51);
      text("Least Mean Square", 90*width/100, height/12 - 70);  
  }
        if (bleUart.isConnecting()) {
        appText = "BLE is connecting...";
      }
      else if (bleUart.isConnected()) {
        appText = "Connected to " + hedefCihaz;
        appText += "\n\nlast message received:";
        appText += "\n string [" + messageReceived + "]";
        appText += "\n hex [" + toHexString(messageReceived) + "]";
      }
      else if (bleUart.isScanning()) {
        appText = "BLE is scanning...";
      }
      else {
        appText = "BLE is disconnected";
      }
      
      if (bleUart.isConnected()) {
        appText += "\n\ntap to send a message";
      }
      else if (bleUart.getResultCount() > 0) {
        appText += "\n\ntap to connect to the first device with \"UART\" in the name";
        appText += "\n\n" + deviceListText;
      }
      else if (!bleUart.isScanning()) {
        appText += "\n\ntap to scan";
      }
      
      
            textSize(20);
      fill(255, 87, 51);
        text(appText, 90*width/100, height/12);
        noFill();



  /* Tahmin dairesinin hareketini yumusatmak */
  float targetX = (position_estimate_KF[0]) * meterToPixel;
  float dx = targetX - x_smooth;
  x_smooth += dx * easing;

  float targetY = (position_estimate_KF[1]) * meterToPixel;
  float dy = targetY - y_smooth;
  y_smooth += dy * easing;

  if(!devMode){
        kalman_toggle.hide();
        LMS_toggle.hide();
        Arkaplan_buton.hide();
        ellipse(x_smooth + 10, y_smooth + 10, 0.2 * meterToPixel, 0.2 * meterToPixel);
  }
  else{
    kalman_toggle.show();
    LMS_toggle.show();
    Arkaplan_buton.show();
  }
} 

void Arkaplan_Degis() { 
      if(devMode){
  openImageExplorer();
      }
} 

void mousePressed() {
  // if the UART is connected and ready, send a message with the mouse position
  /*
  if (bleUart.isConnected()) {
    messageSent = "mouse: (" + mouseX + ", " + mouseY + ")";
    println("Sending message <" + messageSent + ">");
    //bleUart.sendMessage(messageSent);
    return;
  }
  */
  
  // otherwise, check if the Ble knows a device with "UART" in the name
  // if there is one, connect to it
  ArrayList<BLEDeviceSimple> deviceList = bleUart.getDeviceList();
  for (BLEDeviceSimple device : deviceList) {
    if (device.getName().contains(hedefCihaz)) {
      println("Connecting to device <" + device.getName() + "> <" + device.getAddress() + ">"); 
      if (bleUart.isScanning) bleUart.stopScanning();
      bleUart.connectTo(device.getAddress());
      return;
    }
  }
  
  // otherwise start scanning
  bleUart.startScanning();
}
void metrekare(int x_smooth, int y_smooth)
{
    stroke(132, 58, 92);
    float rectSize;
    strokeWeight(1);
    if ((990 / x_smooth) * y_smooth > (1835 / y_smooth) * x_smooth)
    {
        rectSize = (1825 / x_smooth);
        meterToPixel = 1825 / x_smooth;
        for (int i = 0; i < x_smooth; i++)
        {
            for (int k = 0; k < y_smooth; k++)
            {
                rect(10 + i * (rectSize), 10 + k * (rectSize), rectSize, rectSize);
            }
        }
    }
    else
    {
        rectSize = (990 / y_smooth);
        meterToPixel = 990 / y_smooth;
        for (int i = 0; i < x_smooth; i++)
        {
            for (int k = 0; k < y_smooth; k++)
            {
                rect(10 + i * (rectSize), 10 + k * (rectSize), rectSize, rectSize);
            }
        }
    }
}



void requestData()
{
    /* Her anchordan olculen uzaklik degeri */
    distance_measured[0] = anchor1.measure_distance();
    distance_measured[1] = anchor2.measure_distance();
    distance_measured[2] = anchor3.measure_distance();
    distance_measured[3] = anchor4.measure_distance();
    distance_measured[4] = anchor5.measure_distance();

    /* Least mean square fonksiyonu 200 iterasyon - 0.1 step size */
    position_estimate_LMS = LMS_EstimatePoint(distance_measured, x_Anchor, y_Anchor, 5);

    tempX = position_estimate_KF[0]*meterToPixel+10;
    tempY = position_estimate_KF[1]*meterToPixel+10;
    position_estimate_KF[0] = filter.update(position_estimate_LMS[0]);
    position_estimate_KF[1] = filter2.update(position_estimate_LMS[1]);
}

void mouseClicked() {

  print("dsada");
}



void init_Filters(){
    filter.R = kalman_var;
    filter2.R = kalman_var;
    
    filter.Q = kalman_var*kalman_var/2;
    filter2.Q = kalman_var*kalman_var/2;
}

void updateDeviceListText() {
  deviceListText = "Device List --------";
  ArrayList<BLEDeviceSimple> deviceList = bleUart.getDeviceList();
  for (BLEDeviceSimple device : deviceList) {
    deviceListText += "\n  [" + device.getName() + "]\n  " + device.getAddress();
  }
}


// converts a string to hexadecimal format 
String toHexString(String str) {
  String hexStr = "";
  for (int i = 0; i < str.length(); i++) {
    hexStr += hex(str.charAt(i), 2);
  }
  return hexStr;
}


// tidy up
@Override
void stop() {
  if (bleUart != null) bleUart.dispose();
}


// Ble UART Callbacks -------------------------------------------------------------------------


// callback from the BleUART, when a device is discovered
void bleUARTDeviceDiscovered(String name, String address) {
  println("bleUARTDeviceDiscovered() <" + name + "> <" + address + ">");
  updateDeviceListText();
  
  // if you need the actual BluetoothDevice object, you can do:
  //   BluetoothDevice device = bleUart.getBluetoothDeviceByAddress(address);
  // addresses are unique whereas names are not, but you can also do:
  //   BluetoothDevice device = bleUart.getBluetoothDeviceByName(name);
}


// callback from the BleUART, when scanning has finished
void bleUARTScanningFinished() {
  println("bleUARTScanningFinished()");
  updateDeviceListText();
}


// callback from the BleUART, when the device is successfully connected 
// and configured (i.e. ready to transmit/receive) 
void bleUARTConnected() {
  println("bleUARTConnected()");
}


// callback from the BleUART, when the device is disconnected
void bleUARTDisconnected() {
  println("bleUARTDisconnected()");
}


// callback for when a message is received through the UART
// avoid doing heavy lifting here, just store the message and handle it during draw
void bleUARTMessageReceived(String message) {
  println("bleUARTMessageReceived() <" + message + ">");
  println("bleUARTMessageReceived() <" + toHexString(message)+ ">");
  messageReceived = message;
}
