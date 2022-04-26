public 
class KalmanFilter {

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
