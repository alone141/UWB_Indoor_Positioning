
final float mean = 0, stddev = 0.2; //Mean and standard deviation
float meterToPixel,mean_pixel,stddev_pixel; //Pixel ve metre degerlerini cevirebilmek icin sabit sayılar 

/* Anchor ve uzaklik degerleri */
Anchor anchor1,anchor2,anchor3,anchor4,anchor5;
int[] x_Anchor = {0,11,0,5,11}, y_Anchor = {0,0,6,3,6}; //Anchor x y koordinatlari
float[] distance_measured = {0,0,0,0,0}; //Olculen uzakliklar

/* Least Mean Square Parametreleri */
float[] position_estimate_LMS = {4.0,4.0}; // Initial random guess for LMS (4,4)
float diff_Ex = 0, diff_Ey = 0; // (measured_distance-estimated_distance)^2 fonksiyonunun gradienti

/* Kalman Filter Parametreleri */
float[] expected_Kalman_estimate_error = {10,10}; // Kalman inital guessin beklenen hata degeri +-10metre
float[] expected_LMS_measurement_error = {1,1}; // LMS fonksiyonundan beklenen hata degeri +-1metre
float[] kalman_gain = {0,0}; 
float[] position_estimate_KF = {5.0,5.0}; // Initial random guess for KF (5,5)
float kalman_reset_distance = stddev*2; // Hareket algilamak icin

void setup(){
    fullScreen();
}

void draw(){
    /* Arka planin cizimi */
    background(255);
    strokeWeight(16);
    stroke(0,0,0);
    point(mouseX,mouseY);
    metrekare(11,6);

    /*Mean ve stddev degerlerinin pixele cevrilmesi*/
    mean_pixel = mean*meterToPixel;
    stddev_pixel = stddev*meterToPixel;

    /* Anchorlarin yerlestirilmesi */
    anchor1 = new Anchor(x_Anchor[0],y_Anchor[0], "0,0");
    anchor2 = new Anchor(x_Anchor[1],y_Anchor[1], "11,0");
    anchor3 = new Anchor(x_Anchor[2],y_Anchor[2], "0,6");
    anchor4 = new Anchor(x_Anchor[3],y_Anchor[3], "5,3");
    anchor5 = new Anchor(x_Anchor[4],y_Anchor[4], "11,6");

    /* Her anchordan olculen uzaklik degeri */
    distance_measured[0] =  anchor1.measure_distance();
    distance_measured[1] =  anchor2.measure_distance();
    distance_measured[2] =  anchor3.measure_distance();
    distance_measured[3] =  anchor4.measure_distance();
    distance_measured[4] =  anchor5.measure_distance();

    /* Least mean square fonksiyonu 200 iterasyon - 0.1 step size */
    position_estimate_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor,5);


    /* Kalman filter  */

    for (int n = 0; n < 2; n++) {
        //Kalman gain guncelleme
        kalman_gain[n] = expected_Kalman_estimate_error[n]/(expected_Kalman_estimate_error[n] + expected_LMS_measurement_error[n]);
        //Position estimate guncelleme
        position_estimate_KF[n] = position_estimate_KF[n] + kalman_gain[n]*(position_estimate_LMS[n]-position_estimate_KF[n]);
        //Expected kalman error guncelleme
        expected_Kalman_estimate_error[n] = (1-kalman_gain[n])*expected_Kalman_estimate_error[n];
    }

    if(dist(position_estimate_LMS[0],position_estimate_LMS[1],position_estimate_KF[0],position_estimate_KF[1]) > kalman_reset_distance){
        //Hareket edersek filtreyi sifirliyoruz
        kalman_gain[0] = 0;
        kalman_gain[1] = 0;
        expected_Kalman_estimate_error[0] =10;
        expected_Kalman_estimate_error[1] =10;
    }


    stroke( 51, 107, 255 );
    point(position_estimate_KF[0]*meterToPixel+10,position_estimate_KF[1]*meterToPixel+10);
    textSize(50);
    fill( 51, 107, 255);
    text("Kalman", 1500, 1100);

    stroke(255, 87, 51);
    point(position_estimate_LMS[0]*meterToPixel+10,position_estimate_LMS[1]*meterToPixel+10);
    textSize(50);
    fill(255, 87, 51);
    text("Least Mean Square", 1500, 1200);  

    textSize(50);
    fill(0,0,0);
    text("Real Position", 1500, 1300);  


    fill(0, 408, 612, 204);
    textSize(12);
    text((float)mouseX/(float)meterToPixel, mouseX+15, mouseY+25);
    text((float)mouseY/(float)meterToPixel, mouseX+15, mouseY+45);
    text(dist(position_estimate_LMS[0]*meterToPixel,position_estimate_LMS[1]*meterToPixel,mouseX,mouseY)/meterToPixel, mouseX+15, mouseY+65);
    text(dist(position_estimate_KF[0]*meterToPixel,position_estimate_KF[1]*meterToPixel,mouseX,mouseY)/meterToPixel, mouseX+15, mouseY+85);
    noFill();
    
    display();
}
void display(){ 

    delay(100);
}



void metrekare(int x, int y){
    stroke(132,58,92); 
    float rectSize;
    strokeWeight(1);
    if((990/x)*y > (1835/y)*x){
        rectSize = (1825/x);
        meterToPixel = 1825/x;
        for (int i = 0; i < x; i++) {
            for (int k = 0; k < y; k++) {
                rect(10 + i * (rectSize), 10 + k *(rectSize), rectSize, rectSize);
            }
        }
    }
    else{
        rectSize = (990/y);
        meterToPixel = 990/y;
        for (int i = 0; i < x; i++) {
            for (int k = 0; k < y; k++) {
                rect(10 + i * (rectSize), 10 + k *(rectSize), rectSize, rectSize);
            }
        }
    }
}    
public class Anchor {
    int x;
    int y;
    float r, r_rand;
    String name;

    Anchor(int tempX, int tempY , String tempName) {
        x = tempX;
        y = tempY;
        name = tempName;

        x = (int)(x*meterToPixel + 10);
        y = (int)(y*meterToPixel + 10);
        r = dist(mouseX,mouseY,x,y);
        r_rand = r + ((randomGaussian()-0.5f)*stddev_pixel) + mean_pixel;

        strokeWeight(2);
        //line(mouseX,mouseY,x,y);
        stroke(125,10,188);
        strokeWeight(16);
        point(x,y);
        textSize(16);
        stroke(132,58,92);
        fill(0, 408, 612, 204);
        text(name, x+15, y+15);
        text(r/meterToPixel, x+15, y+35);
        noFill();
    }
    float measure_distance(){
        return r_rand/meterToPixel;
    }
}

float[] LMS_EstimatePoint(float[] distance, int[] x_anchor,int[] y_anchor , int anchorCount){
    int N = 200;
    float mu = 0.1f;

    float[] tag_estim = {4.0,4.0};
    float[] distance_estim = new float[anchorCount];

    for (int t = 0; t < N; t++) {
        diff_Ex = 0;
        diff_Ey = 0;   

        for (int n= 0; n < anchorCount; n++) {
            distance_estim[n] = sqrt((x_anchor[n]-tag_estim[0])*(x_anchor[n]-tag_estim[0]) + (y_anchor[n]-tag_estim[1])*(y_anchor[n]-tag_estim[1]));
        }

        for (int k = 0; k < anchorCount; k++) {
            diff_Ex = diff_Ex + (-2f/3f)*((1-distance[k]/distance_estim[k])*(x_Anchor[k]-tag_estim[0]));
            diff_Ey = diff_Ey + (-2f/3f)*((1-distance[k]/distance_estim[k])*(y_Anchor[k]-tag_estim[1]));
        }

        tag_estim[0] = tag_estim[0] - mu*diff_Ex;
        tag_estim[1] = tag_estim[1] - mu*diff_Ey;

    }
    return tag_estim;   
}

