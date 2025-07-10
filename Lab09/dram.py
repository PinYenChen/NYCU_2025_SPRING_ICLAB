import numpy as np
from numba import jit
import random


def hexx(n):
    return hex(n)[2:]
# 假設你原本的 hexx(n) 會回傳不帶前導零的十六進位（例如 hexx(5) == "5"）
# 專門幫 day 補到兩碼：
def hexx2(n):
    s = hexx(n)
    return s.zfill(2)   # 如果只有 1 碼就前面補 '0'

fo = open("dram.dat", "w")

# Write dram
for i in range(256):
    date_false = 1
    while (date_false):
        date_false = 0
        month = random.randint(1, 12)
        day = random.randint(1, 31)
        if (month == 2 and day > 28):
            date_false = 1 
        if (month % 2 != 1 and month != 8):
            if (day == 31):
                date_false = 1


    

# 先用 hexx2() 處理 day，保證一定是兩位十六進位
    day_hex = hexx2(day)
    addr0 = "@" + hexx(65536 + 8 * i)
    data0 = (
        day_hex
        + " "
        + hexx(random.randint(0, 15))
        + hexx(random.randint(0, 15))
        + " "
        + hexx(random.randint(0, 15))
        + hexx(random.randint(0, 15))
        + " "
        + hexx(random.randint(0, 15))
        + hexx(random.randint(0, 15))
    )

    addr1 = "@" + hexx(65536 + 4 + 8 * i)
    data1 = (
        hexx(0)
        + hexx(month)
        + " "
        + hexx(random.randint(0, 15))
        + hexx(random.randint(0, 15))
        + " "
        + hexx(random.randint(0, 15))
        + hexx(random.randint(0, 15))
        + " "
        + hexx(random.randint(0, 15))
        + hexx(random.randint(0, 15))
    )
    fo.write(addr0)
    fo.write("\n")
    fo.write(data0)
    fo.write("\n")
    fo.write(addr1)
    fo.write("\n")
    fo.write(data1)
    fo.write("\n")
fo.close()