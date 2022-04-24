

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
boolean showKF = false;
/* Constant Acceleration Kalman Filter Parametreleri */

float[] position_estimate_KF = {5.0, 5.0}; // Initial random guess for KF (5,5)

/* x ve y icin kalman filtreleri */
KalmanFilter filter = new KalmanFilter();
KalmanFilter filter2 = new KalmanFilter();

/* Slider eklemek icin */

void setup()
{
    fullScreen();
    /*
    filter.R = 0.00001;
    filter2.R = 0.00001;
    */
    filter.R = kalman_var;
    filter2.R = kalman_var;
    
    filter.Q = kalman_var*kalman_var/2;
    filter2.Q = kalman_var*kalman_var/2;
}

void draw()
{
    /* Arka planin cizimi */
    background(240);
    strokeWeight(16);
    stroke(0, 0, 0);
    point(mouseX, mouseY);
    metrekare(11, 6);

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
    if(showKF){
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
        fill(255);
    }

    /* Tahmin dairesinin hareketini yumusatmak */
    float targetX = (position_estimate_KF[0]) * meterToPixel;
    float dx = targetX - x_smooth;
    x_smooth += dx * easing;

    float targetY = (position_estimate_KF[1]) * meterToPixel;
    float dy = targetY - y_smooth;
    y_smooth += dy * easing;


    ellipse(x_smooth + 10, y_smooth + 10, 0.2 * meterToPixel, 0.2 * meterToPixel);
    display();
}
void display()
{

    // delay(100);
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

public
class Anchor
{
    int x_smooth;
    int y_smooth;
    float r, r_rand;
    String name;

    Anchor(int tempX, int tempY, String tempName)
    {
        x_smooth = tempX;
        y_smooth = tempY;
        name = tempName;

        x_smooth = (int)(x_smooth * meterToPixel + 10);
        y_smooth = (int)(y_smooth * meterToPixel + 10);
        r = dist(mouseX, mouseY, x_smooth, y_smooth);
        r_rand = r + ((randomGaussian() - 0.5f) * stddev_pixel) + mean_pixel;

        strokeWeight(2);
        //line(mouseX,mouseY,x_smooth,y_smooth);
        stroke(125, 10, 188);
        strokeWeight(16);
        point(x_smooth, y_smooth);
        textSize(16);
        stroke(132, 58, 92);
        fill(0, 408, 612, 204);
        text(name, x_smooth + 15, y_smooth + 15);
        text(r / meterToPixel, x_smooth + 15, y_smooth + 35);
        noFill();
    }
    float measure_distance()
    {
        return r_rand / meterToPixel;
    }
}

float[] LMS_EstimatePoint(float[] distance, int[] x_anchor, int[] y_anchor, int anchorCount)
{
    int N = 200;
    float mu = 0.1f;

    float[] tag_estim = {4.0, 4.0};
    float[] distance_estim = new float[anchorCount];

    for (int t = 0; t < N; t++)
    {
        diff_Ex = 0;
        diff_Ey = 0;

        for (int n = 0; n < anchorCount; n++)
        {
            distance_estim[n] = sqrt((x_anchor[n] - tag_estim[0]) * (x_anchor[n] - tag_estim[0]) + (y_anchor[n] - tag_estim[1]) * (y_anchor[n] - tag_estim[1]));
        }

        for (int k = 0; k < anchorCount; k++)
        {
            diff_Ex = diff_Ex + (-2f / 3f) * ((1 - distance[k] / distance_estim[k]) * (x_Anchor[k] - tag_estim[0]));
            diff_Ey = diff_Ey + (-2f / 3f) * ((1 - distance[k] / distance_estim[k]) * (y_Anchor[k] - tag_estim[1]));
        }

        tag_estim[0] = tag_estim[0] - mu * diff_Ex;
        tag_estim[1] = tag_estim[1] - mu * diff_Ey;
    }
    return tag_estim;
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

/* 
    filter.R = 0.00001;
    filter2.R = 0.00001;
 */
/*     filter.Q = process_covariance;
    filter2.Q = process_covariance; */

    position_estimate_KF[0] = filter.update(position_estimate_LMS[0]);
    position_estimate_KF[1] = filter2.update(position_estimate_LMS[1]);
}
public class KalmanFilter {

  float Q = 0.000001;
  float R = 0.0001;
  float P = 10, X = 0, K;

  private void measurementUpdate() {
    K = (P + Q) / (P + Q + R);
    P = R * (P + Q) / (R + P + Q);
  }

  public float update(float measurement) {
    measurementUpdate();
    float result = X + (measurement - X) * K;
    X = result;
    return result;
  }

}
