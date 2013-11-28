MODULE TCP_MOVEMENT_CONTROL

    ! Setup tool and home data
    PERS tooldata MyTool:=[TRUE,[[0.0,0.0,462.0],[1.0,0.0,0.0,0.0]],[1,[0,0,1],[1,0,0,0],0,0,0]];

    CONST jointtarget homePose:=[[0,0,0,0,0,0],[0,0,0,0,0,0]];
    VAR pos location:=[1758.41,-300,1752.13];
    VAR orient orientation:=[0.5471,-0.6908,0.1508,-0.448];
    VAR confdata configurationData:=[0,1,1,0];
    VAR extjoint externalJoints:=[0,9E9,9E9,9E9,9E9,9E9];
    VAR robtarget homeTarget;
    VAR robtarget Target_X;
    VAR robtarget Target_Y;
    VAR robtarget Target_Z;

    ! Setup communication variables
    VAR socketdev temp_socket;
    VAR socketdev client_socket;
    VAR string received_string;
    VAR bool keep_listening:=TRUE;

    FUNC void MoveStep() !should intake a value array!
        IF location.x<1900 THEN
            location.x:=location.x+100;
            Target_X:=[[location.x,location.y,location.z],orientation,configurationData,externalJoints];
            MoveL Target_X,vmax,fine,tool0\WObj:=wobj0;
        ENDIF
    ENDPROC

    FUNC void parseStep(String msg)
        VAR num dx;
        VAR num dy;
        VAR num dz;
        VAR num stringToVal{3};

        !VAR string str15 := "[600, 500, 225.3]";

        IF StrToVal(msg,stringToVal) THEN
            !look at parsing
            TPWrite msg+"Step parsed into "+stringToVal{1}+","+stringToVal{2}+","+stringToVal{3};
        ENDIF

        dx:=stringToVal{1};
        dy:=stringToVal{2};
        dz:=stringToVal{3};

        !RETURN getRobtarget(x,y,z,rx,ry,rz);
        !Should return a value array!!!
    ENDFUNC

    PROC main()
        ConfL\Off;
        ConfJ\Off;

        homeTarget:=[location,orientation,configurationData,externalJoints];
        MoveJ Target_Home,vmax,fine,tool0\WObj:=wobj0;

        SocketCreate temp_socket;
        SocketBind temp_socket,"192.168.0.2",1025;
        SocketListen temp_socket;

        WHILE keep_listening DO
            ! Waiting for a connection request
            SocketAccept temp_socket,client_socket;
            ! Communication
            SocketReceive client_socket\Str:=received_string;
            TPWrite "Client wrote - "+received_string;

            !Understand message

            IF received_string="Disconnect" THEN

                ! Shutdown the connection
                TPWrite "Closing Connection";
                keep_listening:=FALSE;
                SocketSend client_socket\Str:="Shutdown acknowledged";
                SocketClose client_socket;
                SocketClose temp_socket;
                !NEED TO BREAK OUT OF THE WHILE HERE
                !SocketSend socket1\Data:=msg_dc\NoOfBytes:=1;

            ELSE
                !MoveJ parseStep(received_string),v20,z1,MyTool;
                TPWrite "random debug statement";
            ENDIF

            received_string:="";
        ENDWHILE

        TPWrite "Have a good one!";
    ENDPROC
ENDMODULE