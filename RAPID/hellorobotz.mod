MODULE Module1

    !PERS tooldata MyTool:=[TRUE,[[0.0000000000,0.0000000000,127.0000000000],[1.0000000000,0.0000000000,0.0000000000,0.0000000000]],[1,[0,0,1],[1,0,0,0],0,0,0]];
    !CONST robtarget Target_Home:=[[616.276853239657,1.29490244455989E-12,615.999957933775],[0.499999890452526,0,0.866025467031693,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
    VAR pos location:=[1758.41,-300,1752.13];
    VAR orient orientation:=[0.5471,-0.6908,0.1508,-0.448];
    VAR confdata configurationData:=[0,1,1,0];
    VAR extjoint externalJoints:=[0,9E9,9E9,9E9,9E9,9E9];
    VAR robtarget Target_Home;
    VAR robtarget Target_X;
    VAR robtarget Target_Y;
    VAR robtarget Target_Z;

    PROC MoveX()
        IF location.x<1900 THEN
            location.x:=location.x+100;
            Target_X:=[[location.x,location.y,location.z],orientation,configurationData,externalJoints];
            MoveL Target_X,vmax,fine,tool0\WObj:=wobj0;
        ENDIF
    ENDPROC

    PROC MoveXneg()
        IF location.x>1600 THEN
            location.x:=location.x-100;
            Target_X:=[[location.x,location.y,location.z],orientation,configurationData,externalJoints];
            MoveL Target_X,vmax,fine,tool0\WObj:=wobj0;
        ENDIF
    ENDPROC

    PROC MoveY()
        IF location.y<950 THEN
            location.y:=location.y+100;
            Target_Y:=[[location.x,location.y,location.z],orientation,configurationData,externalJoints];
            MoveL Target_Y,vmax,fine,tool0\WObj:=wobj0;
        ENDIF
    ENDPROC

    PROC MoveYneg()
        IF location.y>800 THEN
            location.y:=location.y-100;
            Target_Y:=[[location.x,location.y,location.z],orientation,configurationData,externalJoints];
            MoveL Target_Y,vmax,fine,tool0\WObj:=wobj0;
        ENDIF
    ENDPROC

    PROC MoveZ()
        IF location.z<1900 THEN
            location.z:=location.z+100;
            Target_Z:=[[location.x,location.y,location.z],orientation,configurationData,externalJoints];
            MoveL Target_Z,vmax,fine,tool0\WObj:=wobj0;
        ENDIF
    ENDPROC

    PROC MoveZneg()
        IF location.z>1600 THEN
            location.z:=location.z-100;
            Target_Z:=[[location.x,location.y,location.z],orientation,configurationData,externalJoints];
            MoveL Target_Z,vmax,fine,tool0\WObj:=wobj0;
        ENDIF
    ENDPROC

    PROC main()
        Target_Home:=[location,orientation,configurationData,externalJoints];
        MoveJ Target_Home,vmax,fine,tool0\WObj:=wobj0;

        FOR i FROM 1 TO 5 DO
            IF D651_10_DI1=0 THEN
                MoveX;
                !WaitTime 1;
            ENDIF
        ENDFOR

        FOR i FROM 1 TO 5 DO
            IF D651_10_DI1=0 THEN
                MoveZ;
                !WaitTime 1;
            ENDIF
        ENDFOR

        FOR i FROM 1 TO 5 DO
            IF D651_10_DI1=0 THEN
                MoveXneg;
                !WaitTime 1;
            ENDIF
        ENDFOR

        FOR i FROM 1 TO 5 DO
            IF D651_10_DI1=0 THEN
                MoveZneg;
                !WaitTime 1;
            ENDIF
        ENDFOR

    ENDPROC
ENDMODULE