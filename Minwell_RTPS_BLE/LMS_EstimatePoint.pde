public float[] LMS_EstimatePoint(float[] distance, int[] x_anchor, int[] y_anchor, int anchorCount)
{
    int N = 200;
    float mu = 0.1f;
    float diff_Ex = 0, diff_Ey = 0;

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
