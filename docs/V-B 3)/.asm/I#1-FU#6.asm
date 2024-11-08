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
           load         .A1     *AR15++[0x1],       R62                 
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       mov          .C1     R14,                R6                  
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR59                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0xF,                R6,                 R6                  
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR59                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           vmov         .E1     0x0,                VR60                
   |       vmov         .E2     0x0,                VR61                
   |       load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_0              
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_0              
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_0              
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_0              
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_0              
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_0              
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
$0_1_0: ;_LOOP_K EIMS(FIX)
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_0              
   |       bcast        .C1     R62,                VR59                
   | [R6]  sub          .C2     0x1,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           

           bcast        .C1     R62,                VR59                
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
   |       vload        .D1     *+AR6[0x0],         VR63:VR62           
           bcast        .C1     R62,                VR59                
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           bcast        .C1     R62,                VR59                
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           bcast        .C1     R62,                VR59                
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           bcast        .C1     R62,                VR59                
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
     [R5]  sub          .C1     0x1,                R5,                 R5                  
   |       vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vmul         .E1     VR62,               VR59,               VR58                
   |       vmul         .E2     VR63,               VR59,               VR57                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
     [R5]  br           .B1     $0_0                
   |       vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vadd         .E3     VR58,               VR61,               VR61                
   |       vadd         .E4     VR57,               VR60,               VR60                
           vsub         .E1     VR61,               VR62,               VR62                
   |       vsub         .E2     VR60,               VR63,               VR63                
           vstor        .D1     VR63:VR62,          *AR6++[0x10]        
           nop          .B1     0x1                 

           br           .B1     R63                 
           nop          .B1     0x6                 
    .size $0_sgemm_64_mul_and_add, .-$0_sgemm_64_mul_and_add