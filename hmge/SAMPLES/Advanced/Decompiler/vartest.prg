
FUNCTION test1 (a,b)

   LOCAL a1:=0, a2:=1, a3:=127, a4:=-127, a5:=1114556 , a6:=-1114556
   LOCAL a7:=1234567.890123, a8:=-1234567.890123

   LOCAL a9:={},a10:={0,1,127,-127,1114556,-1114556,1234567.890123,-1234567.890123}
   LOCAL a11:=1, a12:=10,j:=0, a13:=.t.,a14:=.f.
   LOCAL i:=0,k:=4

   FOR j:=a11 to a12
      FOR k:= 3 to a3
         FOR i= 1 to 10
            a1:=a1+1
         NEXT i
      NEXT k
   NEXT j

   RETURN NIL
