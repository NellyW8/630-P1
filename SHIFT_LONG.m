function y=SHIFT_LONG(x1,k)
   y=int64(bitshift(int64(x1),-k));