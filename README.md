# bottle-quality-inspection-matlab

An automated visual inspection system using MATLAB and image processing techniques to detect manufacturing defects in bottled products.

---

### Key Features

The script processes bottle images from a directory and performs four main quality checks:

* **Fill Level Detection:** Determines if the liquid level is Empty, Underfilled, Normal, or Overfilled using Sobel edge detection.
* **Cap Inspection:** Checks whether the bottle cap is present or missing via color channel analysis.
* **Label Inspection:** Detects missing labels, misaligned (tilted) labels, and incorrect/blank label prints.
* **Deformation Check:** Analyzes body symmetry across multiple scanlines to detect dents and physical damages.

---

### How to Run

1. Open the script in MATLAB.
2. Update the folder path at the top of the script to your local image directory:
   ```matlab
   cd 'path_to_your_images_folder';

### Results 

Below is a sample run showcasing the full workspace.

<img width="1300" height="762" alt="Ekran Resmi 2026-08-21 11 33 40" src="https://github.com/user-attachments/assets/f73f0643-7eec-4e25-a310-966c06b52431" />

