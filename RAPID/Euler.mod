MODULE MainModule
    VAR num anglex;
    VAR num angley;
    VAR num anglez;
    VAR pose object;
    VAR robtarget current_position;

    PROC main()
        current_position:=CRobT(\Tool:=tool0\WObj:=wobj0);

        anglex:=EulerZYX(\X,current_position.orient);
        angley:=EulerZYX(\Y,current_position.orient);
        anglez:=EulerZYX(\Z,current_position.orient);

        TPWrite "angle x = "+anglex+", angle y = "+angley+", anglez = "+anglez;

    ENDPROC
ENDMODULE