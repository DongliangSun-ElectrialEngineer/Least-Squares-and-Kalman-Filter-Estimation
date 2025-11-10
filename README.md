# Least Squares (LS) and Kalman Filter (KF) Estimation of a Moving Object

## 🎯 Overview

This project implements and analyzes **Least Squares (LS)** and **Kalman Filter (KF)** algorithms to estimate the state of a **one-dimensional moving object with constant acceleration**.  

![](images/moving_object.png)

The state vector:
\[
x = [p(0),\ v(0),\ a]^T
\]
represents the **initial position**, **initial velocity**, and **acceleration** of the object.  

Two estimation methods are compared:
- **Least Squares (LS):** Batch estimation minimizing total residual error  
- **Kalman Filter (KF):** Iterative estimation refining predictions using measurement updates  

The project evaluates both approaches on noisy position measurements and investigates their **accuracy**, **robustness**, and **computational efficiency**.

---

## 📘 Project Description

Given the dataset `data_LS.txt`, which includes:
- Noisy position measurements `y`
- Corresponding time vector `t`

---

## 🧩 Task 1 – Least Squares (LS) Estimation

### Objective
Estimate the state vector \( x = [p(0), v(0), a]^T \) using noisy position measurements \( y \).

### System Model
\[
y(t) = p(0) + v(0)t + \frac{1}{2}at^2
\]
Matrix form:
\[
\mathbf{y} = \mathbf{H}\mathbf{x}
\]
where  
\[
\mathbf{H} =
\begin{bmatrix}
1 & t_1 & 0.5t_1^2 \\
1 & t_2 & 0.5t_2^2 \\
\vdots & \vdots & \vdots \\
1 & t_n & 0.5t_n^2
\end{bmatrix}
\]

### LS Solution
\[
\mathbf{x}^+ = (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T\mathbf{y}
\]

### Key Results
| Parameter | Estimated | Ground Truth | Unit |
|------------|------------|---------------|------|
| p(0) | 5.6976 | 7.4507 | m |
| v(0) | 40.3467 | 39.1441 | m/s |
| a | -9.9717 | -9.7340 | m/s² |

![](images/smoothed_measurement.png)

**RMSE (state vector):** 1.2351  

### Noise Sensitivity
Monte Carlo simulations (200 runs) were used to analyze the relationship between measurement noise variance and estimation RMSE.

📈 **Figure:** Measurement noise variance vs RMSE  
Shows that LS accuracy degrades as measurement noise increases.

### Performance
- Matrix size: \( \mathbf{H} \in \mathbb{R}^{101×3} \)
- Average runtime: **13 μs**

---

## 🔁 Task 2 – Kalman Filter (KF) Estimation

### Objective
Implement an iterative Kalman Filter to estimate the same state vector \( x = [p(0), v(0), a]^T \) using sequential measurements.

### System Model
\[
x_k = Φ_{k-1}x_{k-1} + w_{k-1}, \quad
y_k = H_kx_k + v_k
\]
with:
- \( Φ_{k-1} = I + FΔt \)
- \( Q \): process noise covariance  
- \( R \): measurement noise covariance  
- \( H_k = [1, t_k, 0.5t_k^2] \)

### Filter Initialization
\[
x_0 = [0,\ 0,\ 0]^T,\quad
P_0 = diag([50,\ 50,\ 50]),\quad
Q = diag([0.001,\ 0.001,\ 0.001]),\quad
R = 10
\]

### Equations

**Prediction Step**
\[
\hat{x}_k^- = Φ_{k-1}\hat{x}_{k-1}, \quad
P_k^- = Φ_{k-1}P_{k-1}Φ_{k-1}^T + Q
\]

**Update Step**
\[
K_k = P_k^-H_k^T(H_kP_k^-H_k^T + R)^{-1}
\]
\[
\hat{x}_k^+ = \hat{x}_k^- + K_k(y_k - H_k\hat{x}_k^-)
\]
\[
P_k^+ = (I - K_kH_k)P_k^-
\]

### Results
- KF estimates start from zero and converge to ground truth.  
- Final **RMSE = 0.4573**  

📊 **Figure:** Kalman Filter Estimates vs Ground Truth  
Demonstrates rapid convergence and smooth performance.
![](images/KF.png)
---

## ⚖️ Comparison: LS vs KF

| Feature | Least Squares (LS) | Kalman Filter (KF) |
|----------|-------------------|-------------------|
| **Computation** | Batch (one-time) | Recursive (sequential) |
| **Noise Handling** | Measurement noise only | Process + measurement noise |
| **Data Type** | Offline | Real-time capable |
| **Complexity** | Simple matrix inversion | Requires tuning & recursion |
| **Robustness** | Sensitive to high noise | Robust and smooth under noise |
| **Best Use** | Static parameter estimation | Dynamic tracking / sensor fusion |








