# Convolution Matrix in MIPS Assembly

## 📖 Description
This project implements a 2D convolution operation in MIPS assembly (for the MARS simulator).  
Given an **N×N** “image” matrix and an **M×M** “kernel” matrix, plus symmetric padding **p** and stride **s**, your assembly program reads from `input_matrix.txt`, performs padding, applies the convolution, rounds each result to one decimal, and writes the resulting feature‑map to `output_matrix.txt`. 

---

## 📝 Requirements
- **MARS MIPS simulator** 

---
## ⚙️ Assembly Program Details

1. **Input** (`input_matrix.txt`):  
   - First row: four floats `N M p s`  
     - **N** = image size (3 ≤ N ≤ 7)  
     - **M** = kernel size (2 ≤ M ≤ 4)  
     - **p** = padding (0 ≤ p ≤ 4)  
     - **s** = stride (1 ≤ s ≤ 3)  
   - Second row: N×N floats (the image)  
   - Third row: M×M floats (the kernel) 

2. **Output** (`output_matrix.txt`):  
   - The convolved matrix (each entry rounded to one decimal), space‑separated.  
   - **Error case**: if even after padding the kernel is too large to “slide” once, output exactly:  
     ```
     Error: size not match
     ```
  ---

## 🛠️ Building & Running

### 1. Assembly
1. Open **`main.asm`** in MARS.  
2. Assemble & run, making sure `input_matrix.txt` is in MARS’s working directory.  
3. The program creates `output_matrix.txt` as output.

### 2. C++ program Test 
I include a simple C++ program that mirrors the padding + convolution logic for quick verification
