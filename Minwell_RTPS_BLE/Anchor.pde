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
