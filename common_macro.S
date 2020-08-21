// This file includes common MACROS

#define WRITE_TEST_ITEM(ITEM, SUB_ITEM_LO, SUB_ITEM_HI) \
        li      t0,     0xFF601FFF00    ; \
        li      t1,     ITEM            ; \
        sw      t1,     0x0(t0)         ; \
        li      t1,     SUB_ITEM_LO     ; \
        sw      t1,     0x4(t0)         ; \
        li      t1,     SUB_ITEM_HI     ; \
        sw      t1,     0x8(t0)         ;

#define WRITE_TEST_STATUS(CORE_ID, STATUS) \
        li      t1,     CORE_ID         ; \
        slli    t1,     t1,   2         ; \
        li      t0,     0xFF601FFF10    ; \
        add     t0,     t0,   t1        ; \
        li      t1,     STATUS          ; \
        sw      t1,     0x0(t0)         ;
        
#define TEST_FINISH(CORE_ID)              \
        li      t0,     0xFF601FFF00    ; \
        li      t1,     1               ; \
        slli    t1,     t1,  CORE_ID    ; \
        sw      t1,     0xC(t0)         ;

#define PRINT(LABEL)                      \
        la      s1,     LABEL           ; \
        or      s1,     s1,     s10     ; \
        la      s0,     print           ; \
        or      s0,     s0,     s10     ; \
        jalr    s0                      ;

