public float[] decode_Hex(String hexStr){
    
  int An0_distance=0;
  int An1_distance=0;
  int An2_distance=0;
  int An3_distance=0;
  String An0_hex="0";
  String An1_hex="0";
  String An2_hex="0";
  String An3_hex="0";
  float An0distance = 0;
  float An1distance = 0;
  float An2distance = 0;
  float An3distance = 0;
  float[] distance_array = {0,0,0,0};
  int length = hexStr.length();
  
  
  // stringi ikili karekterler halinde ayırıyor çünkü her iki karekter bir değeri ifade ediyor
  String[] twocharacters=hexStr.split("(?<=\\G.{2})");
  
  // karekter uzunluğum yarı yarı indi. o yüzden stringin uzunluğunun yarısı kadar for döngüsüne sokuyorum ve değerleri ayırıp en son bunları uzunluk olarak gösteriyorum
  for (int i = 0; i < length/2; i++) {
    if(twocharacters[i].equals("E7")){
      if(twocharacters[i+1].equals("04")){
       An0_hex=twocharacters[i+5]+twocharacters[i+4]+twocharacters[i+3]+twocharacters[i+2]; 
       An0_distance=Integer.parseInt(An0_hex,16);  
      
  }  
    }
      if(twocharacters[i].equals("56")){
      if(twocharacters[i+1].equals("17")){
       An1_hex=twocharacters[i+5]+twocharacters[i+4]+twocharacters[i+3]+twocharacters[i+2]; 
       An1_distance=Integer.parseInt(An1_hex,16);  
  
  }  
    }
      if(twocharacters[i].equals("5B")){
      if(twocharacters[i+1].equals("1E")){
       An2_hex=twocharacters[i+5]+twocharacters[i+4]+twocharacters[i+3]+twocharacters[i+2]; 
       An2_distance=Integer.parseInt(An2_hex,16);  
       
  }  
    }
      if(twocharacters[i].equals("37")){
      if(twocharacters[i+1].equals("11")){
       An3_hex=twocharacters[i+5]+twocharacters[i+4]+twocharacters[i+3]+twocharacters[i+2]; 
       An3_distance=Integer.parseInt(An3_hex,16);  
  }  
    }
  }
  // değerleri floata çevirip metre cinsinden verileri ekrana yazdırma
   An0distance = (float) An0_distance / 1000;
   An1distance = (float) An1_distance / 1000;
   An2distance = (float) An2_distance / 1000;
   An3distance = (float) An3_distance / 1000;    
   
   distance_array[0] = An0distance;
   distance_array[1] = An1distance;
   distance_array[2] = An2distance;
   distance_array[3] = An3distance;
   
   return distance_array;
    
  
}
