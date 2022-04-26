/*************************************/
/*BURALARI BEN DE ANLAMIYORUM BAKMAYIN/
/**************************************/
@Override 
  void onActivityResult(int requestCode, int resultCode, Intent data) { 
  super.onActivityResult(requestCode, resultCode, data); 
  if (requestCode == 1) { 
    if (resultCode == activity.RESULT_OK) { 
      if (data != null) {
        Uri image_uri = data.getData(); 
        String[] filePathColumn = { MediaStore.Images.Media.DATA };
        Cursor cursor = context.getContentResolver().query(image_uri, filePathColumn, null, null, null); 
        cursor.moveToFirst(); 
        int columnIndex = cursor.getColumnIndex(filePathColumn[0]); 
        String imgDecodableString = cursor.getString(columnIndex); 
        cursor.close();
        println(imgDecodableString); 
        if (Build.VERSION.SDK_INT >= 28) {
          try { 
            InputStream ips = context.getContentResolver().openInputStream(image_uri); 
            Bitmap bitmap = BitmapFactory.decodeStream(ips);
            img = new PImage(bitmap.getWidth(), bitmap.getHeight(), PConstants.ARGB);
            bitmap.getPixels(img.pixels, 0, img.width, 0, 0, img.width, img.height);
            img.updatePixels();
            image_loaded = true;
          }
          catch (Exception e) { 
            e.printStackTrace();
          }
        } else { 
          img = loadImage(imgDecodableString); 
          image_loaded = true;
        }
      } else {
        println("No data");
      }
    }
  }
} 

private static String[] PERMISSIONS_STORAGE = { Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE }; 
private void requestParticularPermission() { 
  activity.requestPermissions(PERMISSIONS_STORAGE, 2020);
}

public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) { 
  switch (requestCode) { 
  case 2020: 
    if (grantResults[0] == PackageManager.PERMISSION_GRANTED) { 
      println("permissions granted");
    } else { 
      println("permissions not granted");
    } 
    break; 
  default: 
    activity.onRequestPermissionsResult(requestCode, permissions, grantResults);
  }
}

void openImageExplorer() {
  Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI); 
  intent.setType("image/*"); 
  activity.startActivityForResult(intent, 1);
}
