    // |  # | valid_i | tmp_ready | tmp_valid | ready_i |||| | tmp_ready | tmp_valid |
    // | -: | :-----: | :-----  : | :-----:   | :-----: |||| | :-------: | :-------: |
XX  // |  0 |    0    |    0      |    0      |    0    |||| |     1     |     0     |
XX  // |  1 |    0    |    0      |    0      |    1    |||| |     1     |     0     |
V   // |  2 |    0    |    0      |    1      |    0    |||| |     0     |     1     |
V   // |  3 |    0    |    0      |    1      |    1    |||| |     1     |     0     |
V   // |  4 |    0    |    1      |    0      |    0    |||| |     1     |     0     |
V   // |  5 |    0    |    1      |    0      |    1    |||| |     1     |     0     |
XX  // |  6 |    0    |    1      |    1      |    0    |||| |     0     |     1     |
?   // |  7 |    0    |    1      |    1      |    1    |||| |     1     |     0     |
XX  // |  8 |    1    |    0      |    0      |    0    |||| |     1     |     0     |
XX  // |  9 |    1    |    0      |    0      |    1    |||| |     1     |     0     |
V   // | 10 |    1    |    0      |    1      |    0    |||| |     0     |     1     |
V   // | 11 |    1    |    0      |    1      |    1    |||| |     1     |     0     |
V   // | 12 |    1    |    1      |    0      |    0    |||| |     0     |     1     |
V   // | 13 |    1    |    1      |    0      |    1    |||| |     1->0  |     1     |
XX  // | 14 |    1    |    1      |    1      |    0    |||| |     0     |     1     |
V   // | 15 |    1    |    1      |    1      |    1    |||| |     1     |     1     |



    // |    | valid_i (t) | valid_reg (t) | ready_i (t) ||||  ready_comb (t) | valid_reg (t+1) |
    // |    | :-----:     | :-----:       | :-----:     |||| :----------:    | :-------:       |
    // |  . |    1        |    0          |    0        ||||     1           |     1  改變      |  ~
    // |  . |    1        |    0          |    1        ||||     1           |     1  改變      |  ~
    // |    |    0        |    0          |    0        ||||     1           |     0           |  
    // |    |    0        |    0          |    1        ||||     1           |     0           |  
    // |    |    0        |    1          |    0        ||||     0           |     1           |  
    // |    |    1        |    1          |    0        ||||     0           |     1           |  
    // |    |    1        |    1          |    1        ||||     1           |     1           |  
    // |    |    0        |    1          |    1        ||||     1           |     0  改變      |  ~



    // |    | valid_i (t) | valid_reg (t) | ready_i (t) ||||  ready_comb (t) | valid_reg (t+1) |
    // |    | :-----:     | :-----:       | :-----:     |||| :----------:    | :-------:       |
    // |  . |    1        |    0          |    0        ||||     1           |     1  改變      |  ~
    // |  . |    1        |    0          |    1        ||||     1           |     1  改變      |  ~
    // |    |    1        |    1          |    0        ||||     0           |     1           |  
    // |    |    1        |    1          |    1        ||||     1           |     1           |  
    // |    |    0        |    1          |    0        ||||     0           |     1           |  

只要 valid_reg(t) == 1'b0 就可以跟上游要資料
(1) 所以 ready_comb = 1'b1 if valid_reg(t) == 1'b0

只要 valid_reg(t) == 1'b1 就"不可以"跟上游要資料, 除非下游 "同時" 也跟我要資料
(2) 所以 ready_comb = 1'b0 if (valid_reg(t) == 1'b1 && ready_i (t) == 1'b0)
(3) 所以 ready_comb = 1'b1 if (valid_reg(t) == 1'b1 && ready_i (t) == 1'b1)

(1)+(2)+(3)
assign ready_comb = (valid_reg == 1'b0) || (valid_reg == 1'b1 && ready_i == 1'b1);  // 寫出 active 條件即可.





valid_reg(t) == 1'b0 && valid_i(t) == 1'b1, 就可以從上游得到資料,
valid_reg(t) == 1'b0 時, valid_reg(t＋1) 則跟下游無關

(A) valid_reg 改變: flipflop valid_reg <= 1'b1 if (valid_reg == 1'b0 && valid_i == 1'b1)
(B) valid_reg 不變: flipflop valid_reg <= 不變  if (valid_reg == 1'b0 && valid_i == 1'b0)

valid_reg(t) == 1'b1 && ready_i(t) == 1'b1, 資料被下游拿走, 除非上游同時有資料, 不然狀態將改變,
(C) valid_reg 改變: flipflop valid_reg <= 1'b0 if (valid_reg == 1'b1 && valid_i == 1'b0 && ready_i == 1'b1)

(A)+(B)+(C)

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    valid_reg <= 1'b0;
  end else begin
    這個我會覺得毛毛的, 因為不斷反相, 沒有給明確數值, 但應該不會有問題, 因為有 reset.
    if ((valid_reg == 1'b0 && valid_i == 1'b1) || (valid_reg == 1'b1 && valid_i == 1'b0 && ready_i == 1'b1))
      valid_reg <= ~valid_reg;
    end

    或是這個, 但他有 priority, 實際上不需要.
    if (valid_reg == 1'b0 && valid_i == 1'b1) begin
      valid_reg <= 1'b1;
    end if (valid_reg == 1'b1 && valid_i == 1'b0 && ready_i == 1'b1) begin
      valid_reg <= 1'b0;
    end

  end
end


