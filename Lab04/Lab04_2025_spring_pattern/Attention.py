import struct
import numpy as np
rng = np.random.default_rng(42)  # 設定 SEED 為 42
def hex_to_float32(hex_str):
    """ 轉換 IEEE754 32-bit hex 為 float32，不做四捨五入 """
    return np.float32(struct.unpack('!f', bytes.fromhex(hex_str))[0])

def float32_to_hex(value):
    """ 轉換 float32 為 IEEE754 32-bit hex 格式 """
    return struct.pack('!f', np.float32(value)).hex()
def softmax(x):
    """ 計算標準 softmax (不減去最大值) """
    exp_x = np.exp(x)  # 直接計算 e^x
    return exp_x / np.sum(exp_x, axis=1, keepdims=True)
def read_matrices(filename, rows, cols):
    """ 讀取 IEEE754 32-bit floating point hex 格式的矩陣，轉換為 float32 """
    with open(filename, 'r') as f_in:
        lines = [line.strip() for line in f_in.readlines()]

    N = int(lines[0])  # 讀取第一行的矩陣數量
    index = 1
    matrices = []

    for i in range(N):
        matrix = []
        for r in range(rows):
            line = lines[index]
            index += 1
            hex_tokens = line.split()
            if len(hex_tokens) != cols:
                raise ValueError(f"檔案 {filename}，矩陣 {i+1}，第 {r+1} 行，預期 {cols} 個數字，但讀到 {len(hex_tokens)} 個。")
            float_row = [hex_to_float32(token) for token in hex_tokens]
            matrix.append(float_row)
        
        matrices.append(np.array(matrix, dtype=np.float32))  # 保持 float32 精度
        
        # 跳過矩陣間的空白行
        if index < len(lines) and lines[index] == "":
            index += 1

    return N, matrices
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
def save_matrices(filename, matrices):
    """ 
    儲存計算結果的矩陣到檔案，每筆矩陣間保留一行空白，格式為 IEEE754 32-bit hex 
    """
    with open(filename, 'w') as f_out:
        f_out.write(f"{len(matrices)}\n")
        for matrix in matrices:
            for row in matrix:
                f_out.write(' '.join(str(num) for num in row) + "\n")
            f_out.write("\n")  # 保留矩陣間的空白行

# 讀取輸入矩陣（使用 float32 以保持 IEEE 754 32-bit 精度）
N, in_str_matrices = read_matrices("in_str_hex.txt", 5, 4)
_, k_weight_matrices = read_matrices("k_weight_hex.txt", 4, 4)
_, q_weight_matrices = read_matrices("q_weight_hex.txt", 4, 4)
_, v_weight_matrices = read_matrices("v_weight_hex.txt", 4, 4)
_, out_weight_matrices = read_matrices("out_weight_hex.txt", 4, 4)
# 計算 K = in_str × k_weight^T, Q = in_str × q_weight^T, V = in_str × v_weight^T
K_matrices = []
Q_matrices = []
V_matrices = []

for i in range(N):
    in_str = in_str_matrices[i]
    k_weight = k_weight_matrices[i]
    q_weight = q_weight_matrices[i]
    v_weight = v_weight_matrices[i]

    # 轉置權重矩陣
    k_weight_T = k_weight.T
    q_weight_T = q_weight.T
    v_weight_T = v_weight.T

    # 使用 float32 進行高精度矩陣運算，確保不升級到 float64
    K = np.matmul(in_str.astype(np.float32), k_weight_T.astype(np.float32))
    Q = np.matmul(in_str.astype(np.float32), q_weight_T.astype(np.float32))
    V = np.matmul(in_str.astype(np.float32), v_weight_T.astype(np.float32))

    # 存入結果
    K_matrices.append(K)
    Q_matrices.append(Q)
    V_matrices.append(V)

# ** 將 K、Q、V 分割成兩個 head (5×2) **
K1_matrices = [K[:, :2] for K in K_matrices]  # K 的前 2 列
K2_matrices = [K[:, 2:] for K in K_matrices]  # K 的後 2 列
Q1_matrices = [Q[:, :2] for Q in Q_matrices]  # Q 的前 2 列
Q2_matrices = [Q[:, 2:] for Q in Q_matrices]  # Q 的後 2 列
V1_matrices = [V[:, :2] for V in V_matrices]  # V 的前 2 列
V2_matrices = [V[:, 2:] for V in V_matrices]  # V 的後 2 列

# ** 輸出 K, Q, V **
save_matrices("K.txt", K_matrices)
save_matrices("Q.txt", Q_matrices)
save_matrices("V.txt", V_matrices)

# ** 輸出 K1, K2, Q1, Q2, V1, V2 **
save_matrices("K1.txt", K1_matrices)
save_matrices("K2.txt", K2_matrices)
save_matrices("Q1.txt", Q1_matrices)
save_matrices("Q2.txt", Q2_matrices)
save_matrices("V1.txt", V1_matrices)
save_matrices("V2.txt", V2_matrices)

# 初始化儲存結果的矩陣列表
Score1_matrices = []
Score2_matrices = []
Score1_soft_matrices = []
Score2_soft_matrices = []
Head1_out_matrices = []
Head2_out_matrices = []
Head_out_matrices = []

sqrt_2 = np.sqrt(2).astype(np.float32)  # 確保為 float32 運算

for i in range(N):
    Q1 = Q1_matrices[i]
    Q2 = Q2_matrices[i]
    K1 = K1_matrices[i]
    K2 = K2_matrices[i]
    V1 = V1_matrices[i]
    V2 = V2_matrices[i]

    # 計算 Score1 和 Score2，並除以 sqrt(2)
    Score1 = np.matmul(Q1, K1.T) / sqrt_2  # 5x5
    Score2 = np.matmul(Q2, K2.T) / sqrt_2  # 5x5

    # 計算 Softmax
    Score1_soft = softmax(Score1)
    Score2_soft = softmax(Score2)

    # 計算 Head1_out 和 Head2_out
    Head1_out = np.matmul(Score1_soft, V1)  # 5x2
    Head2_out = np.matmul(Score2_soft, V2)  # 5x2

    # 拼接 Head1_out 和 Head2_out 形成 Head_out (5×4)
    Head_out = np.concatenate((Head1_out, Head2_out), axis=1)

    # 存入結果
    Score1_matrices.append(Score1)
    Score2_matrices.append(Score2)
    Score1_soft_matrices.append(Score1_soft)
    Score2_soft_matrices.append(Score2_soft)
    Head1_out_matrices.append(Head1_out)
    Head2_out_matrices.append(Head2_out)
    Head_out_matrices.append(Head_out)

# 輸出 Score1、Score2
save_matrices("Score1.txt", Score1_matrices)
save_matrices("Score2.txt", Score2_matrices)

# 輸出 Score1_soft、Score2_soft
save_matrices("Score1_soft.txt", Score1_soft_matrices)
save_matrices("Score2_soft.txt", Score2_soft_matrices)

# 輸出 Head1_out、Head2_out
save_matrices("Head1_out.txt", Head1_out_matrices)
save_matrices("Head2_out.txt", Head2_out_matrices)

# 輸出最終 Head_out (5×4)
save_matrices("Head_out.txt", Head_out_matrices)


# 儲存 output 矩陣 (5×4)
Output_matrices = []

for i in range(N):
    Head_out = Head_out_matrices[i]      # 5x4 矩陣
    out_weight = out_weight_matrices[i]  # 4x4 矩陣

    # 計算 Output = Head_out × out_weight
    Output = np.matmul(Head_out, out_weight.T)  # 結果是 5x4

    # 存入結果
    Output_matrices.append(Output)

# 輸出最終結果到 output.txt
save_matrices("output.txt", Output_matrices)
save_matrices_hex("output_hex.txt", Output_matrices, "5x4")