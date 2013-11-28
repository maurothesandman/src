MODULE TestLimit
    CONST pos home_location:=[5520,520,343];
    CONST orient home_orientation:=[0.03029,-0.11448,0.99177,0.04863];
    CONST confdata home_configurationData:=[-1,1,0,0];
    CONST extjoint home_externalJoints:=[4000,9E9,9E9,9E9,9E9,9E9];
    CONST robtarget homeTarget:=[home_location,home_orientation,home_configurationData,home_externalJoints];

    VAR num max_x:=500;
    VAR num min_x:=300;

    VAR num dx:=20;

    VAR pos current_position;

    PROC main()
        ConfL\Off;
        ConfJ\Off;
        
        MoveJ homeTarget,vmax,fine,tool0\WObj:=wobj0;

        WHILE TRUE DO
            FOR i FROM 0 TO 20 DO
                current_position:=CPos(\Tool:=tool0\WObj:=wobj0);
                IF current_position.x+dx>=max_x THEN
                    dx:=max_x-current_position.x;
                ELSE
                    dx:=20;
                ENDIF
                MoveL Offs(CRobT(\Tool:=tool0\WObj:=wobj0),0,0,dx),vmax,fine,tool0\WObj:=wobj0;
            ENDFOR

            FOR i FROM 0 TO 20 DO
                current_position:=CPos(\Tool:=tool0\WObj:=wobj0);
                IF current_position.x+dx<=min_x THEN
                    dx:=min_x-current_position.x;
                ELSE
                    dx:=-20;
                ENDIF
                MoveL Offs(CRobT(\Tool:=tool0\WObj:=wobj0),0,0,dx),vmax,fine,tool0\WObj:=wobj0;
            ENDFOR
        ENDWHILE
    ENDPROC
ENDMODULE