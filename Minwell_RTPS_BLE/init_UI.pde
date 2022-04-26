public void init_UI(){
  cp5 = new ControlP5(this);
  //Engineering mode toggle
  dev_toggle = cp5.addToggle("devMode").setPosition(50,50).setSize(50,50)
     .setCaptionLabel("Dev Mode")
     .setColorLabel(0)
     .setColorBackground(color(255,0,0))
     .setColorForeground(color(0,0,255))
     .setColorActive(color(0,255,0));
     
  //Show kalman toggle
  kalman_toggle = cp5.addToggle("show_kalman").setPosition(50,150).setSize(50,50)
     .setCaptionLabel("Show Kalman")
     .setColorLabel(0)
     .setColorBackground(color(255,0,0))
     .setColorForeground(color(0,0,255))
     .setColorActive(color(0,255,0));
     
  //Show LMS toggle
  LMS_toggle = cp5.addToggle("show_LMS").setPosition(50,250).setSize(50,50)
     .setColorLabel(0)
     .setColorBackground(color(255,0,0))
     .setColorForeground(color(0,0,255))
     .setColorActive(color(0,255,0));
     
  //Arkaplan degistirme butonu
  Arkaplan_buton = cp5.addButton("Arkaplan_Degis")
   .setPosition(50,350)
   .setSize(50,50)
   .setValue(0)
   .activateBy(ControlP5.RELEASE);
     
  
  kalman_toggle.hide();
  LMS_toggle.hide();
  Arkaplan_buton.hide();
  
  arkaplan = loadImage("roomplan.png");  // Load the image into the program  
  arkaplan.resize(width, height);
  
  //orientation(LANDSCAPE);
}
