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
           nop          .B1     0x1                 
           vmov         .E1     0x0,                VR61                
   |       bcast        .C1     R62,                VR53                
           vmov         .E1     0x0,                VR55                
   |       vmov         .E2     0x0,                VR60                
   |       load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR51                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR52                
   |       vmov         .E1     VR55,               VR58                
   |       vmov         .E2     VR55,               VR59                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR51                
   |       vmov         .E1     VR55,               VR56                
   |       vmov         .E2     VR55,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       vmul         .E1     VR62,               VR53,               VR52                
   |       vmul         .E2     VR63,               VR53,               VR49                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           mov          .C1     R14,                R6                  
   |       vmul         .E1     VR62,               VR51,               VR50                
   |       vmul         .E2     VR63,               VR51,               VR53                
           bcast        .C1     R62,                VR53                
   |       vmul         .E1     VR62,               VR52,               VR49                
   |       vmul         .E2     VR63,               VR52,               VR48                
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR51                
   |       vmul         .E1     VR62,               VR51,               VR52                
   |       vmul         .E2     VR63,               VR51,               VR50                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR52                
   |       vmov         .E1     VR55,               VR54                
   |       vmov         .E2     VR55,               VR55                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR51                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  sub          .C2     0xC,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR53,               VR52                
   |       vmul         .E2     VR63,               VR53,               VR49                
   |       vadd         .E3     VR52,               VR61,               VR61                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
     [R6]  sub          .C1     0x4,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR51,               VR50                
   |       vmul         .E2     VR63,               VR51,               VR53                
   |       vadd         .E3     VR49,               VR60,               VR60                
     [R6]  br           .B1     $0_1_3              
   |       bcast        .C1     R62,                VR53                
   |       vmul         .E1     VR62,               VR52,               VR49                
   |       vmul         .E2     VR63,               VR52,               VR48                
   |       vadd         .E3     VR50,               VR59,               VR59                
$0_1_3: ;_LOOP_K EIMS(FIX)
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR51                
   |       vmul         .E1     VR62,               VR51,               VR52                
   |       vmul         .E2     VR63,               VR51,               VR50                
   |       vadd         .E3     VR53,               VR56,               VR56                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR52                
   |       vadd         .E1     VR49,               VR58,               VR58                
   |       vadd         .E2     VR48,               VR55,               VR55                
   |       vadd         .E3     VR52,               VR57,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR51                
   |       vadd         .E3     VR50,               VR54,               VR54                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       vmul         .E1     VR62,               VR53,               VR52                
   |       vmul         .E2     VR63,               VR53,               VR49                
   |       vadd         .E3     VR52,               VR61,               VR61                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
     [R6]  sub          .C1     0x4,                R6,                 R6                  
   |       vmul         .E1     VR62,               VR51,               VR50                
   |       vmul         .E2     VR63,               VR51,               VR53                
   |       vadd         .E3     VR49,               VR60,               VR60                
     [R6]  br           .B1     $0_1_3              
   |       bcast        .C1     R62,                VR53                
   |       vmul         .E1     VR62,               VR52,               VR49                
   |       vmul         .E2     VR63,               VR52,               VR48                
   |       vadd         .E3     VR50,               VR59,               VR59                

           bcast        .C1     R62,                VR51                
   |       vmul         .E1     VR62,               VR51,               VR52                
   |       vmul         .E2     VR63,               VR51,               VR50                
   |       vadd         .E3     VR53,               VR56,               VR56                
           bcast        .C1     R62,                VR52                
   |       vadd         .E1     VR49,               VR58,               VR58                
   |       vadd         .E2     VR48,               VR55,               VR55                
   |       vadd         .E3     VR52,               VR57,               VR57                
           bcast        .C1     R62,                VR51                
   |       vadd         .E3     VR50,               VR54,               VR54                
           vmul         .E1     VR62,               VR53,               VR52                
   |       vmul         .E2     VR63,               VR53,               VR49                
   |       vadd         .E3     VR52,               VR61,               VR61                
           vmul         .E1     VR62,               VR51,               VR50                
   |       vmul         .E2     VR63,               VR51,               VR53                
   |       vadd         .E3     VR49,               VR60,               VR60                
           vmul         .E1     VR62,               VR52,               VR49                
   |       vmul         .E2     VR63,               VR52,               VR48                
   |       vadd         .E3     VR50,               VR59,               VR59                
           vmul         .E1     VR62,               VR51,               VR52                
   |       vmul         .E2     VR63,               VR51,               VR50                
   |       vadd         .E3     VR53,               VR56,               VR56                
           vadd         .E1     VR49,               VR58,               VR58                
   |       vadd         .E2     VR48,               VR55,               VR55                
   |       vadd         .E3     VR52,               VR57,               VR57                
           vadd         .E3     VR50,               VR54,               VR54                
           vadd         .E3     VR52,               VR61,               VR61                
           vadd         .E3     VR49,               VR60,               VR60                
           vadd         .E3     VR50,               VR59,               VR59                
           vadd         .E1     VR61,               VR59,               VR61                
   |       vadd         .E3     VR53,               VR56,               VR56                
           vadd         .E1     VR49,               VR58,               VR58                
   |       vadd         .E2     VR48,               VR55,               VR55                
   |       vadd         .E3     VR52,               VR57,               VR57                
           vadd         .E1     VR58,               VR57,               VR58                
   |       vadd         .E2     VR60,               VR56,               VR60                
   |       vadd         .E3     VR50,               VR54,               VR54                
           vadd         .E1     VR61,               VR58,               VR61                
   |       vadd         .E2     VR55,               VR54,               VR55                
           vadd         .E1     VR60,               VR55,               VR60                
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