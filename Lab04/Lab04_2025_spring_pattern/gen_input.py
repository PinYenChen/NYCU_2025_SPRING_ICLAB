import numpy as np
import struct
rng = np.random.default_rng(42)  # 設定 SEED 為 42
def generate_matrices(N):
    # 生成 N 個 5x4 的矩陣
    matrices_5x4 = [np.random.uniform(-0.5, 0.5, size=(5, 4)) for _ in range(N)]
    # 生成 N*3 個 4x4 的矩陣
    matrices_4x4 = [np.random.uniform(-0.5, 0.5, size=(4, 4)) for _ in range(N * 4)]
    return matrices_5x4, matrices_4x4

def save_matrices(filename, matrices, matrix_type):
    """
    將矩陣列表以浮點數原始值存入指定檔案。
    """
    with open(filename, 'w') as f:
        for i, mat in enumerate(matrices):
            np.savetxt(f, mat, fmt='%.6f')
            f.write("\n")

def float_to_hex(num):
    """
    將數字轉換成 IEEE754 格式的 32 位元單精度浮點數的 16 進位表示。
    """
    return struct.pack('!f', np.float32(num)).hex()

def save_matrices_hex(filename, matrices, matrix_type):
    """
    將矩陣列表中的每個數字轉換成 IEEE754 16 進位表示，並存入指定檔案。
    """
    with open(filename, 'w') as f:
        f.write(f"{N}\n")
        for i, mat in enumerate(matrices):
            for row in mat:
                # 將每個數字轉換成 hex，並以空格分隔
                hex_row = ' '.join([float_to_hex(num) for num in row])
                f.write(hex_row + "\n")
            f.write("\n")

# 設定 N 的值，例如 N = 2（可依需求修改）
N = 100
matrices_5x4, matrices_4x4_all = generate_matrices(N)

# --- 匯出浮點數原始值的檔案 ---
# 第一個檔案：N 個 5x4 矩陣
save_matrices("in_str.txt", matrices_5x4, "5x4")
# 將 N*3 個 4x4 矩陣分為三組，每組各 N 個
group1 = matrices_4x4_all[0:N]
group2 = matrices_4x4_all[N:2*N]
group3 = matrices_4x4_all[2*N:3*N]
group4 = matrices_4x4_all[3*N:4*N]
save_matrices("q_weight.txt", group1, "4x4")
save_matrices("k_weight.txt", group2, "4x4")
save_matrices("v_weight.txt", group3, "4x4")
save_matrices("out_weight.txt", group4, "4x4")
# --- 匯出 IEEE754 16 進位格式的檔案 ---
save_matrices_hex("in_str_hex.txt", matrices_5x4, "5x4")
save_matrices_hex("q_weight_hex.txt", group1, "4x4")
save_matrices_hex("k_weight_hex.txt", group2, "4x4")
save_matrices_hex("v_weight_hex.txt", group3, "4x4")
save_matrices_hex("out_weight_hex.txt", group4, "4x4")