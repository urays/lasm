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
           vmov         .E1     0x0,                VR58                
   |       mov          .C1     R11,                AR7                 
           vmov         .E1     0x0,                VR63                
   |       vmov         .E2     0x0,                VR59                
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   |       vmov         .E1     VR63,               VR56                
   |       vmov         .E2     VR63,               VR55                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   |       vmov         .E1     VR63,               VR54                
   |       vmov         .E2     VR63,               VR57                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   |       mov          .C1     R14,                R6                  
   |       vmov         .E1     VR63,               VR52                
   |       vmov         .E2     VR63,               VR53                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   | [R6]  sub          .C2     0x8,                R6,                 R6                  
   |       vmov         .E1     VR63,               VR50                
   |       vmov         .E2     VR63,               VR51                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
     [R6]  sub          .C1     0x8,                R6,                 R6                  
   |       vmov         .E1     VR63,               VR48                
   |       vmov         .E2     VR63,               VR49                
           bcast        .C1     R61,                VR41                
   |       bcast        .C2     R62,                VR40                
   |       vmov         .E1     VR63,               VR46                
   |       vmov         .E2     VR63,               VR47                
           bcast        .C1     R61,                VR43                
   |       bcast        .C2     R62,                VR42                
   |       vmov         .E1     VR63,               VR44                
   |       vmov         .E2     VR63,               VR45                
           bcast        .C1     R61,                VR41                
   |       bcast        .C2     R62,                VR40                
$0_1_7: ;_LOOP_K EIMS(FIX)
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   |       bcast        .C1     R61,                VR42                
   |       bcast        .C2     R62,                VR43                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   | [R6]  br           .B1     $0_1_7              
   |       vmuladd      .E1     VR60,               VR41,               VR58,               VR58                
   |       vmuladd      .E2     VR61,               VR41,               VR59,               VR59                
   |       vmuladd      .E3     VR62,               VR40,               VR55,               VR55                
   |       vmuladd      .E4     VR63,               VR40,               VR50,               VR50                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   |       vmuladd      .E1     VR60,               VR43,               VR56,               VR56                
   |       vmuladd      .E2     VR61,               VR43,               VR49,               VR49                
   |       vmuladd      .E3     VR62,               VR42,               VR57,               VR57                
   |       vmuladd      .E4     VR63,               VR42,               VR48,               VR48                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
           load         .A1     *AR15++[0x2],       R61                 
   |       load         .A2     *+AR15[0x1],        R62                 
   |       vmuladd      .E1     VR60,               VR41,               VR54,               VR54                
   |       vmuladd      .E2     VR61,               VR41,               VR47,               VR47                
   |       vmuladd      .E3     VR62,               VR40,               VR53,               VR53                
   |       vmuladd      .E4     VR63,               VR40,               VR46,               VR46                
   |       vload        .D1     *AR7++[0x20],       VR61:VR60           
   |       vload        .D2     *+AR7[0x10],        VR63:VR62           
     [R6]  sub          .C1     0x8,                R6,                 R6                  
   |       vmuladd      .E1     VR60,               VR42,               VR52,               VR52                
   |       vmuladd      .E2     VR61,               VR42,               VR45,               VR45                
   |       vmuladd      .E3     VR62,               VR43,               VR51,               VR51                
   |       vmuladd      .E4     VR63,               VR43,               VR44,               VR44                
           bcast        .C1     R61,                VR41                
   |       bcast        .C2     R62,                VR40                
           bcast        .C1     R61,                VR43                
   |       bcast        .C2     R62,                VR42                
           bcast        .C1     R61,                VR41                
   |       bcast        .C2     R62,                VR40                

           bcast        .C1     R61,                VR42                
   |       bcast        .C2     R62,                VR43                
           vmuladd      .E1     VR60,               VR41,               VR58,               VR58                
   |       vmuladd      .E2     VR61,               VR41,               VR59,               VR59                
   |       vmuladd      .E3     VR62,               VR40,               VR55,               VR55                
   |       vmuladd      .E4     VR63,               VR40,               VR50,               VR50                
           vmuladd      .E1     VR60,               VR43,               VR56,               VR56                
   |       vmuladd      .E2     VR61,               VR43,               VR49,               VR49                
   |       vmuladd      .E3     VR62,               VR42,               VR57,               VR57                
   |       vmuladd      .E4     VR63,               VR42,               VR48,               VR48                
           vmuladd      .E1     VR60,               VR41,               VR54,               VR54                
   |       vmuladd      .E2     VR61,               VR41,               VR47,               VR47                
   |       vmuladd      .E3     VR62,               VR40,               VR53,               VR53                
   |       vmuladd      .E4     VR63,               VR40,               VR46,               VR46                
           vmuladd      .E1     VR60,               VR42,               VR52,               VR52                
   |       vmuladd      .E2     VR61,               VR42,               VR45,               VR45                
   |       vmuladd      .E3     VR62,               VR43,               VR51,               VR51                
   |       vmuladd      .E4     VR63,               VR43,               VR44,               VR44                
           nop          .B1     0x5                 
           vadd         .E1     VR58,               VR55,               VR58                
   |       vadd         .E2     VR54,               VR53,               VR54                
   |       vadd         .E3     VR47,               VR46,               VR47                
   |       vadd         .E4     VR49,               VR48,               VR49                
           vadd         .E1     VR45,               VR44,               VR45                
   |       vadd         .E2     VR59,               VR50,               VR59                
   |       vadd         .E3     VR52,               VR51,               VR52                
   |       vadd         .E4     VR56,               VR57,               VR56                
           vadd         .E1     VR47,               VR45,               VR47                
   |       vadd         .E2     VR59,               VR49,               VR59                
   |       vadd         .E3     VR54,               VR52,               VR54                
   |       vadd         .E4     VR58,               VR56,               VR58                
           vadd         .E1     VR59,               VR47,               VR59                
   |       vadd         .E2     VR58,               VR54,               VR58                
     [R5]  sub          .C1     0x1,                R5,                 R5                  
   |       vload        .D1     *+AR6[0x0],         VR63:VR62           
           nop          .B1     0x4                 
     [R5]  br           .B1     $0_0                
           nop          .B1     0x3                 
           vsub         .E1     VR59,               VR63,               VR63                
   |       vsub         .E2     VR58,               VR62,               VR62                
           vstor        .D1     VR63:VR62,          *AR6++[0x10]        
           nop          .B1     0x1                 

           br           .B1     R63                 
           nop          .B1     0x6                 
    .size $0_sgemm_64_muladd, .-$0_sgemm_64_muladd