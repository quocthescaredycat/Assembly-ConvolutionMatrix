#include <iostream>
#include <vector>
#include <iomanip>

int main() {
    // ─── 1) Hard‑coded parameters ─────────────────────────────────────────────
    const int N = 6;    // image size
    const int M = 4;    // kernel size
    const int p = 1;    // padding
    const int s = 3;    // stride

    // ─── 2) Hard‑coded image matrix (6×6) ────────────────────────────────────
    std::vector<std::vector<double>> image = {
        { -32.1,  65.4,  19.8, -47.2,  89.0, -63.5 },
        {  24.6, -78.1,  37.3,  -9.7,  56.8, -42.4 },
        {  71.9, -15.3,  83.2, -54.9,  21.7, -91.4 },
        {  36.5, -28.7,  68.2, -39.6,  49.0, -73.1 },
        {  25.4, -16.8,  81.3, -57.9,  32.6, -48.2 },
        {  74.3, -66.0,  41.5, -27.9,  53.7, -84.6 }
        
    };

    // ─── 3) Hard‑coded kernel matrix (4×4) ───────────────────────────────────
    std::vector<std::vector<double>> kernel = {
        {  -3.2, 4.1, -1.7, 2.9 },
        {0.6, -4.8, 3.3, -0.1},
        {1.2, -2.4, 4.6, -3.9},
         {2.0, -4.1, 1.5, -0.8}
        
    };

    // ─── 4) Build zero‐padded image ───────────────────────────────────────────
    int P = N + 2*p;
    std::vector<std::vector<double>> pad(P, std::vector<double>(P, 0.0));
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            pad[i + p][j + p] = image[i][j];

    // ─── 5) Compute output dimensions ─────────────────────────────────────────
    int outDim = (P - M) / s + 1;
    std::vector<std::vector<double>> output(outDim, std::vector<double>(outDim, 0.0));

    // ─── 6) Perform convolution ───────────────────────────────────────────────
    for (int i = 0; i < outDim; ++i) {
        for (int j = 0; j < outDim; ++j) {
            double sum = 0.0;
            for (int ki = 0; ki < M; ++ki) {
                for (int kj = 0; kj < M; ++kj) {
                    sum += pad[i*s + ki][j*s + kj] * kernel[ki][kj];
                }
            }
            output[i][j] = sum;
        }
    }

    // ─── 7) Print the result ──────────────────────────────────────────────────
    std::cout << "Output (" << outDim << "|" << outDim << "):\n"
              << std::fixed << std::setprecision(1);
    for (auto &row : output) {
        for (int j = 0; j < outDim; ++j) {
            std::cout << row[j]
                      << (j + 1 < outDim ? ' ' : '\n');
        }
    }

    return 0;
}
