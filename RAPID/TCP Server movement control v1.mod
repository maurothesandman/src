MODULE TCP_MOVEMENT_CONTROL

    ! Setup tool and home data

    !CONST jointtarget homePose:=[[0,0,0,0,0,0],[0,0,0,0,0,0]];
    CONST pos location:=[6000,0,1800];![1758.41,-300,1752.13];
    CONST orient orientation:=[0.68,-0.16,0.69,-0.16];![0.5471,-0.6908,0.1508,-0.448];
    CONST confdata configurationData:=[0,1,1,0];
    CONST extjoint externalJoints:=[4000,9E9,9E9,9E9,9E9,9E9];
    CONST robtarget homeTarget:=[location,orientation,configurationData,externalJoints];
    CONST num stepSize:=50;
    
    CONST byte msgOK{1}:=[1];
    CONST byte msgERR{1}:=[2];
    CONST byte msgDIS{1}:=[3];

    VAR robtarget nextTarget:=[location,orientation,configurationData,externalJoints];
    
    VAR robtarget currentPosition;
    VAR num dx:=0;
    VAR num dy:=0;
    VAR num dz:=0;

    VAR num stringToVal{3}:=[0,0,0];

    ! Setup communication variables
    VAR socketdev temp_socket;
    VAR socketdev client_socket;
    VAR string received_string;
    VAR bool keep_listening:=TRUE;

    PROC parseStepAndMove()
        !VAR string str15 := "[600, 500, 225.3]";

        IF StrToVal(received_string,stringToVal) THEN
            !look at parsing
            TPWrite received_string+" Step parsed into "+NumToStr(stringToVal{1},0)+","+NumToStr(stringToVal{2},0)+","+NumToStr(stringToVal{3},0);
            SocketSend client_socket\Data:=msgOK\NoOfBytes:=1;
        ELSE
            TPWrite "StrToVal("+received_string+") returned false";
            SocketSend client_socket\Data:=msgERR\NoOfBytes:=1;
        ENDIF

        MoveL Offs(CRobT(\Tool:=tool0 \WObj:=wobj0), stringToVal{1} * stepSize, stringToVal{2} * stepSize, stringToVal{3} * stepSize),vmax,fine,tool0\WObj:=wobj0;
        stringToVal:=[0,0,0];
    ENDPROC

    PROC main()
        ConfL\Off;
        ConfJ\Off;

        !msgOK{1}:=[1];
        !msgERR{1}:=[2];
        !msgDIS{1}:=[3];

        !homeTarget:=[location,orientation,configurationData,externalJoints];
        MoveJ homeTarget,vmax,fine,tool0\WObj:=wobj0;

        SocketCreate temp_socket;
        SocketBind temp_socket,"128.2.109.20",1025;
        SocketListen temp_socket;
        ! Waiting for a connection request
        SocketAccept temp_socket,client_socket;

        WHILE keep_listening DO    
            ! Communication
            SocketReceive client_socket\Str:=received_string;
            TPWrite "Client wrote - "+received_string;

            !Understand message
            IF received_string="Disconnect" THEN
                ! Shutdown the connection
                TPWrite "Shutdown acknowledged";
                keep_listening:=FALSE;
                SocketSend client_socket\Data:=msgDIS\NoOfBytes:=1;
                !SocketSend client_socket\Str:="Shutdown acknowledged";
                SocketClose client_socket;
                !NEED TO BREAK OUT OF THE WHILE HERE
                !SocketSend socket1\Data:=msg_dc\NoOfBytes:=1;
            ELSE
                parseStepAndMove;
                !MoveJ parseStep(received_string),v20,z1,MyTool;
                !TPWrite "random debug statement";
            ENDIF

            received_string:="";
        ENDWHILE

        SocketClose temp_socket;
        TPWrite "Have a good one!";
    ENDPROC
ENDMODULE