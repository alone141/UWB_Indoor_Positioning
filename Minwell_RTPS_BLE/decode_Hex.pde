public float[] decode_Hex(String hexStr){
    
// VERİLERİ İNİTİALİZE EDİYOR
int An0_distance=0;
int An1_distance=0;
int An2_distance=0;
int An3_distance=0;
float[] uzakliklar = {0,0,0,0};
String An0_hex="0";
String An1_hex="0";
String An2_hex="0";
String An3_hex="0";
int yarim_i = 0;

// blutoothdan aldığım değer bu array de kayıtlı. String im hexadecimal değerleri gösteriyor
//String hexStr = "0104FD0409020000640330FD0100006437111E030000645B1EFD02000064";
// stringin uzunluğu için
int uzun = hexStr.length();
char[] hex_array = hexStr.toCharArray();

// stringi ikili karekterler halinde ayırıyor çünkü her iki karekter bir değeri ifade ediyor
String[] twocharacters=hexStr.split("(?<=\\G.{2})");

// karekter uzunluğum yarı yarı indi. o yüzden stringin uzunluğunun yarısı kadar for döngüsüne sokuyorum ve değerleri ayırıp en son bunları uzunluk olarak gösteriyorum
for (int i = 0; i < (uzun)-5; i++) {
  if(hex_array[i] == 'F' && hex_array[i+1] == 'D' && hex_array[i+2] == '0' && hex_array[i+3] == '4'&& ((i>=4 && i<=7) | (i>=18 && i<=21) | (i>=32 && i<=35)| (i>=46 && i<=49))){
    An0_hex = hexStr.substring(i+4,i+12);
    print("FD04:  " + toLittleEndian(An0_hex)/1000.0);
  }
  else if(hex_array[i] == '0' && hex_array[i+1] == '3' && hex_array[i+2] == '3' && hex_array[i+3] == '0' && ((i>=4 && i<=7) | (i>=18 && i<=21) | (i>=32 && i<=35)| (i>=46 && i<=49))){
    An1_hex = hexStr.substring(i+4,i+12);
    print("3003:  " + toLittleEndian(An1_hex)/1000.0);
  }
  else if(hex_array[i] == '5' && hex_array[i+1] == 'B' && hex_array[i+2] == '1' && hex_array[i+3] == 'E' && ((i>=4 && i<=7) | (i>=18 && i<=21) | (i>=32 && i<=35)| (i>=46 && i<=49))){
    An2_hex = hexStr.substring(i+4,i+12);
    print("1E5B:  " + toLittleEndian(An2_hex)/1000.0);
  }
  else if(hex_array[i] == '3' && hex_array[i+1] == '7' && hex_array[i+2] == '1' && hex_array[i+3] == '1' && ((i>=4 && i<=7) | (i>=18 && i<=21) | (i>=32 && i<=35)| (i>=46 && i<=49))){
    An3_hex = hexStr.substring(i+4,i+12);
    print("1137:  " + toLittleEndian(An3_hex)/1000.0);
  }
}
// değerleri floata çevirip metre cinsinden verileri ekrana yazdırma
float An0distance = (float) toLittleEndian(An0_hex)/1000.0;
float An1distance = (float) toLittleEndian(An1_hex)/1000.0;
float An2distance = (float) toLittleEndian(An2_hex)/1000.0;
float An3distance = (float) toLittleEndian(An3_hex)/1000.0;

 System.out.println("04FD " + An0distance); 
 System.out.println("3003 " + An1distance); 
 System.out.println("1E5B " + An2distance);
 System.out.println("1137 " + An3distance); 
  uzakliklar[0] = An0distance;
  uzakliklar[1] = An1distance;
  uzakliklar[2] = An2distance;
  uzakliklar[3] = An3distance;
  
 return uzakliklar;
  
}


public static int toLittleEndian(final String hex) {
    int ret = 0;
    String hexLittleEndian = "";
    if (hex.length() % 2 != 0) return ret;
    for (int i = hex.length() - 2; i >= 0; i -= 2) {
        hexLittleEndian += hex.substring(i, i + 2);
    }
    ret = Integer.parseInt(hexLittleEndian, 16);
    return ret;
}
