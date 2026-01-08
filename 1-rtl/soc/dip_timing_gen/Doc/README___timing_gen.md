# 圖片轉bmp步驟
用colab(miles的convert_png_to_bmp.ipynb)將png轉成bmp
用以上步驟產稱的bmp才能讓bmp2txt執行檔產出正確的txt檔
再將圖片放進image_in資料夾
在run_top中設定好要轉換的檔案並執行就可以了


## 單張測試方式
- Makefile: 設定
  CFG_SIM_PROJ  := sim_timing_gen
  CFG_SIM_TOP   := sim_timing_gen

- sim_timing_gen_defines.svh
  修改以下兩個參數
  PIC_INPUT_PATH_640X480        ----->輸入絕對路徑/檔名
  PIC_OUTPUT_PATH_640X480       ----->輸出絕對路徑/檔名
  這邊是直出

