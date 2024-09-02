;[power by lasm version 3.2.5.0.windows SAMPLE]
    .global $0_sgemm_64_muladd
    .section .text.0
    .align 1, 0
    .type $0_sgemm_64_muladd, @function
$0_sgemm_64_muladd: 
           mov          .C1     R13,                R5                  
           mov          .C1     R10,                AR15                
           mov          .C1     R12,                AR6                 
           nop          .B1     0x1                 
$0_0: ;_LOOP_M
           mov          .C1     R11,                AR7                 
           nop          .B1     0x1                 
           vmov         .E1     0x0,                VR61                
   |       load         .A1     *AR15++[0x1],       R62                 
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           vmov         .E1     0x0,                VR63                
   |       vmov         .E2     0x0,                VR60                
   |       load         .A1     *AR15++[0x1],       R62                 
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       vmov         .E1     VR63,               VR58                
   |       vmov         .E2     VR63,               VR59                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       vmov         .E1     VR63,               VR56                
   |       vmov         .E2     VR63,               VR57                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       mov          .C1     R14,                R6                  
   |       vmov         .E1     VR63,               VR54                
   |       vmov         .E2     VR63,               VR55                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmov         .E1     VR63,               VR52                
   |       vmov         .E2     VR63,               VR53                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   |       vmov         .E1     VR63,               VR50                
   |       vmov         .E2     VR63,               VR51                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmov         .E1     VR63,               VR48                
   |       vmov         .E2     VR63,               VR49                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   |       vmov         .E1     VR63,               VR46                
   |       vmov         .E2     VR63,               VR47                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR61,               VR61                
   |       vmuladd      .E2     VR63,               VR44,               VR60,               VR60                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR59,               VR59                
   |       vmuladd      .E2     VR63,               VR45,               VR52,               VR52                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR58,               VR58                
   |       vmuladd      .E2     VR63,               VR44,               VR51,               VR51                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR57,               VR57                
   |       vmuladd      .E2     VR63,               VR45,               VR50,               VR50                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR56,               VR56                
   |       vmuladd      .E2     VR63,               VR44,               VR49,               VR49                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   | [R6]  sub          .C2     0x10,               R6,                 R6                  
   |       vmuladd      .E1     VR62,               VR45,               VR55,               VR55                
   |       vmuladd      .E2     VR63,               VR45,               VR48,               VR48                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR54,               VR54                
   |       vmuladd      .E2     VR63,               VR44,               VR47,               VR47                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
$0_1_7: ;_LOOP_K EIMS(FIX)
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   | [R6]  sub          .C2     0x8,                R6,                 R6                  
   |       vmuladd      .E1     VR62,               VR45,               VR53,               VR53                
   |       vmuladd      .E2     VR63,               VR45,               VR46,               VR46                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   | [R6]  br           .B1     $0_1_7              
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR61,               VR61                
   |       vmuladd      .E2     VR63,               VR44,               VR60,               VR60                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR59,               VR59                
   |       vmuladd      .E2     VR63,               VR45,               VR52,               VR52                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR58,               VR58                
   |       vmuladd      .E2     VR63,               VR44,               VR51,               VR51                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR57,               VR57                
   |       vmuladd      .E2     VR63,               VR45,               VR50,               VR50                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR56,               VR56                
   |       vmuladd      .E2     VR63,               VR44,               VR49,               VR49                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR55,               VR55                
   |       vmuladd      .E2     VR63,               VR45,               VR48,               VR48                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           
           load         .A1     *AR15++[0x1],       R62                 
   |       bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR54,               VR54                
   |       vmuladd      .E2     VR63,               VR44,               VR47,               VR47                
   |       vload        .D1     *AR7++[0x10],       VR63:VR62           

           bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR53,               VR53                
   |       vmuladd      .E2     VR63,               VR45,               VR46,               VR46                
           bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR61,               VR61                
   |       vmuladd      .E2     VR63,               VR44,               VR60,               VR60                
           bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR59,               VR59                
   |       vmuladd      .E2     VR63,               VR45,               VR52,               VR52                
           bcast        .C1     R62,                VR44                
   |       vmuladd      .E1     VR62,               VR44,               VR58,               VR58                
   |       vmuladd      .E2     VR63,               VR44,               VR51,               VR51                
           bcast        .C1     R62,                VR45                
   |       vmuladd      .E1     VR62,               VR45,               VR57,               VR57                
   |       vmuladd      .E2     VR63,               VR45,               VR50,               VR50                
           vmuladd      .E1     VR62,               VR44,               VR56,               VR56                
   |       vmuladd      .E2     VR63,               VR44,               VR49,               VR49                
           vmuladd      .E1     VR62,               VR45,               VR55,               VR55                
   |       vmuladd      .E2     VR63,               VR45,               VR48,               VR48                
           vmuladd      .E1     VR62,               VR44,               VR54,               VR54                
   |       vmuladd      .E2     VR63,               VR44,               VR47,               VR47                
           vmuladd      .E1     VR62,               VR45,               VR53,               VR53                
   |       vmuladd      .E2     VR63,               VR45,               VR46,               VR46                
           nop          .B1     0x5                 
           vadd         .E1     VR61,               VR59,               VR61                
   |       vadd         .E2     VR56,               VR55,               VR56                
           vadd         .E1     VR49,               VR48,               VR49                
   |       vadd         .E2     VR51,               VR50,               VR51                
           vadd         .E1     VR47,               VR46,               VR47                
   |       vadd         .E2     VR60,               VR52,               VR60                
           vadd         .E1     VR54,               VR53,               VR54                
   |       vadd         .E2     VR49,               VR47,               VR49                
           vadd         .E1     VR60,               VR51,               VR60                
   |       vadd         .E2     VR58,               VR57,               VR58                
           vadd         .E1     VR56,               VR54,               VR56                
   |       vadd         .E2     VR60,               VR49,               VR60                
           vadd         .E1     VR61,               VR58,               VR61                
           vadd         .E1     VR61,               VR56,               VR61                
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
    .size $0_sgemm_64_muladd, .-$0_sgemm_64_muladd