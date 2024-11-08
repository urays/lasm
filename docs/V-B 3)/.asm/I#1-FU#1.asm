;[power by lasm version 3.2.5.0.windows SAMPLE]
    .global $0_sgemm_64_mul_and_add
    .section .text.0
    .align 1, 0
    .type $0_sgemm_64_mul_and_add, @function
$0_sgemm_64_mul_and_add:
           mov          .C1     R13,                R5                  
           mov          .C1     R10,                AR15                
           mov          .C1     R12,                AR6                 
           nop          .B1     0x1                 
$0_0: ;_LOOP_M
           mov          .C1     R11,                AR7                 
           nop          .B1     0x1                 
           load         .A1     *AR15++[0x1],       R62                 
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           nop          .B1     0x3                 
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR55                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           nop          .B1     0x2                 
           mov          .C1     R14,                R6                  
   |       vmul         .E1     VR62,               VR57,               VR57                
   |       vmul         .E2     VR63,               VR57,               VR56                
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR57                
   |       vmul         .E1     VR62,               VR55,               VR63                
   |       vmul         .E2     VR63,               VR55,               VR62                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           vmov         .E1     0x0,                VR61                
   |       load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR55                
   | [R6]  sub          .C2     0x6,                R6,                 R6                  
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           vmov         .E1     0x0,                VR63                
   |       vmov         .E2     0x0,                VR60                
   | [R6]  sub          .C1     0x2,                R6,                 R6                  
     [R6]  br           .B1     $0_1_1              
   |       vmov         .E1     VR63,               VR58                
   |       vmov         .E2     VR63,               VR59                
           vmul         .E1     VR62,               VR57,               VR57                
   |       vmul         .E2     VR63,               VR57,               VR56                
$0_1_1: ;_LOOP_K EIMS(FIX)
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR57                
   |       vmul         .E1     VR62,               VR55,               VR63                
   |       vmul         .E2     VR63,               VR55,               VR62                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR55                
   |       vadd         .E1     VR57,               VR61,               VR61                
   |       vadd         .E2     VR56,               VR60,               VR60                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
     [R6]  sub          .C1     0x2,                R6,                 R6                  
   |       vadd         .E1     VR63,               VR59,               VR59                
   |       vadd         .E2     VR62,               VR58,               VR58                
     [R6]  br           .B1     $0_1_1              
           vmul         .E1     VR62,               VR57,               VR57                
   |       vmul         .E2     VR63,               VR57,               VR56                

           bcast        .C1     R62,                VR57                
   |       vmul         .E1     VR62,               VR55,               VR63                
   |       vmul         .E2     VR63,               VR55,               VR62                
           bcast        .C1     R62,                VR55                
   |       vadd         .E1     VR57,               VR61,               VR61                
   |       vadd         .E2     VR56,               VR60,               VR60                
           vadd         .E1     VR63,               VR59,               VR59                
   |       vadd         .E2     VR62,               VR58,               VR58                
           nop          .B1     0x1                 
           vmul         .E1     VR62,               VR57,               VR57                
   |       vmul         .E2     VR63,               VR57,               VR56                
           vmul         .E1     VR62,               VR55,               VR63                
   |       vmul         .E2     VR63,               VR55,               VR62                
           vadd         .E1     VR57,               VR61,               VR61                
   |       vadd         .E2     VR56,               VR60,               VR60                
           vadd         .E1     VR63,               VR59,               VR59                
   |       vadd         .E2     VR62,               VR58,               VR58                
           nop          .B1     0x3                 
           vadd         .E1     VR57,               VR61,               VR61                
   |       vadd         .E2     VR56,               VR60,               VR60                
           vadd         .E1     VR63,               VR59,               VR59                
   |       vadd         .E2     VR62,               VR58,               VR58                
           vadd         .E1     VR61,               VR59,               VR61                
   |       vadd         .E2     VR60,               VR58,               VR60                
     [R5]  sub          .C1     0x1,                R5,                 R5                  
   |       vload        .D1     *+AR6[0x0],         VR63:VR62           
           nop          .B1     0x4                 
     [R5]  br           .B1     $0_0                
           nop          .B1     0x3                 
           vsub         .E1     VR60,               VR63,               VR63                
   |       vsub         .E2     VR61,               VR62,               VR62                
           vstor        .D1     VR63:VR62,          *AR6++[0x10]        
           nop          .B1     0x1                 

           br           .B1     R63                 
           nop          .B1     0x6                 
    .size $0_sgemm_64_mul_and_add, .-$0_sgemm_64_mul_and_add