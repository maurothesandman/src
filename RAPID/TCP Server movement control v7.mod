MODULE TCP_MOVEMENT_CONTROL
    !2013-11-21
    !Added extra variable in received message for speed control
    !Added orientation change but initial testing does not seem to work, need to figure out right way to send quaternions!

    !CONST jointtarget homePose:=[[0,0,0,0,0,0],[0,0,0,0,0,0]];
    VAR pos home_location;!:=[5000,-1000,1700];
    ![1758.41,-300,1752.13];
    VAR orient home_orientation;!:=[0.45,0.53,0.47,0.53];
    ![0.5471,-0.6908,0.1508,-0.448];
    CONST confdata home_configurationData:=[-1,1,0,0];
    CONST extjoint home_externalJoints:=[4000,9E9,9E9,9E9,9E9,9E9];
    VAR robtarget homeTarget;!:=[home_location,home_orientation,home_configurationData,home_externalJoints];

    CONST byte msgOK{1}:=[1];
    CONST byte msgERR{1}:=[2];
    CONST byte msgDIS{1}:=[3];
    VAR byte msgVAR{1}:=[0];

    VAR pos currentPosition:=[0,0,0];

    VAR robtarget nextTarget;!:=homeTarget;
    VAR orient orientation;!:=home_orientation;

    VAR num stringToVal{5}:=[0,0,0,0,0];

    VAR num answer;
    VAR zonedata zone:=z50;

    VAR num max_x:=5500;
    VAR num min_x:=4500;

    VAR num max_y:=-500;
    VAR num min_y:=-1500;

    VAR num max_z:=2200;
    VAR num min_z:=1200;

    VAR bool hit_limit:=FALSE;

    ! Setup communication variables
    VAR socketdev temp_socket;
    VAR socketdev client_socket;
    VAR string received_string;
    VAR bool keep_listening:=TRUE;

    PROC ChangePosition()
        currentPosition:=CPos(\Tool:=tool0\WObj:=wobj0);
        hit_limit:=FALSE;

!        IF currentPosition.x+stringToVal{2}>=max_x THEN
!            stringToVal{2}:=max_x-currentPosition.x;
!            hit_limit:=TRUE;
!        ENDIF
!
!        IF currentPosition.x+stringToVal{2}<=min_x THEN
!            stringToVal{2}:=min_x-currentPosition.x;
!            hit_limit:=TRUE;
!        ENDIF
!
!        IF currentPosition.y+stringToVal{3}>=max_y THEN
!            stringToVal{3}:=max_y-currentPosition.y;
!            hit_limit:=TRUE;
!        ENDIF
!
!        IF currentPosition.y+stringToVal{3}<=min_y THEN
!            stringToVal{3}:=min_y-currentPosition.y;
!            hit_limit:=TRUE;
!        ENDIF
!
!        IF currentPosition.z+stringToVal{4}>=max_z THEN
!            stringToVal{4}:=max_z-currentPosition.z;
!            hit_limit:=TRUE;
!        ENDIF
!
!        IF currentPosition.z+stringToVal{4}<=min_z THEN
!            stringToVal{4}:=min_z-currentPosition.z;
!            hit_limit:=TRUE;
!        ENDIF

        MoveJ Offs(CRobT(\Tool:=tool0\WObj:=wobj0),stringToVal{2},stringToVal{3},stringToVal{4}),[stringToVal{5},500,5000,1000],zone,tool0\WObj:=wobj0;

        IF hit_limit THEN
            msgVAR{1}:=5;
        ELSE
            msgVAR{1}:=4;
        ENDIF
        
        hit_limit:=FALSE;

        !The client needs to receive a byte before sending more data.
        SocketSend client_socket\Data:=msgVAR\NoOfBytes:=1;
    ENDPROC

    PROC ChangeOrientation()
        orientation:=[stringToVal{2},stringToVal{3},stringToVal{4},stringToVal{5}];
        nextTarget:=[CPos(\Tool:=tool0\WObj:=wobj0),orientation,home_configurationData,home_externalJoints];
        MoveJ nextTarget,vmax,zone,tool0\WObj:=wobj0;
    ENDPROC


    PROC main()
        !msgOK{1}:=[1];
        !msgERR{1}:=[2];
        !msgDIS{1}:=[3];
        
        ConfL\Off;
        ConfJ\Off;
        
        home_location:=[4000,-1000,2200];
        home_orientation:=OrientZYX(0, 0, 0);
        homeTarget:=[home_location,home_orientation,home_configurationData,home_externalJoints];

        !move home considering configuration data, then turn off the checking
        MoveJ homeTarget,vmax,fine,tool0\WObj:=wobj0;

!        TPReadFK answer,"Select Zone","fine","z50","z100","z150","z200";
!        IF answer=1 THEN
!            zone:=fine;
!        ELSEIF answer=2 THEN
!            zone:=z50;
!        ELSEIF answer=3 THEN
!            zone:=z100;
!        ELSEIF answer=4 THEN
!            zone:=z150;
!        ELSEIF answer=5 THEN
!            zone:=z200;
!        ENDIF

        SocketCreate temp_socket;
        SocketBind temp_socket,"128.2.109.20",1025;
        SocketListen temp_socket;
        ! Waiting for a connection request
        SocketAccept temp_socket,client_socket;

        !Say OK to let the client know I'm alive
        SocketSend client_socket\Data:=msgOK\NoOfBytes:=1;

        WHILE keep_listening DO
            ! Communication
            SocketReceive client_socket\Str:=received_string;
            TPWrite "Client wrote: "+received_string;

            !Understand message
            IF received_string="Disconnect" THEN
                ! Shutdown the connection
                TPWrite "Shutdown acknowledged";
                keep_listening:=FALSE;
                !SocketSend client_socket\Data:=msgDIS\NoOfBytes:=1;
                !SocketSend client_socket\Str:="Shutdown acknowledged";
                SocketClose client_socket;
                !NEED TO BREAK OUT OF THE WHILE HERE
                !SocketSend socket1\Data:=msg_dc\NoOfBytes:=1;
            ELSE
                IF StrToVal(received_string,stringToVal) THEN
                    !look at parsing
                    TPWrite received_string+" Step parsed into "+NumToStr(stringToVal{1},0)+","+NumToStr(stringToVal{2},2)+","+NumToStr(stringToVal{3},2)+","+NumToStr(stringToVal{4},2)+","+NumToStr(stringToVal{5},2);
                    !SocketSend client_socket\Data:=msgOK\NoOfBytes:=1;
                ELSE
                    TPWrite "StrToVal("+received_string+") returned false";
                    !SocketSend client_socket\Data:=msgERR\NoOfBytes:=1;
                ENDIF

                IF stringToVal{1}=1 THEN
                    ChangePosition;
                ELSEIF stringToVal{1}=2 THEN
                    ChangeOrientation;
                ENDIF

                stringToVal:=[0,0,0,0,0];
            ENDIF

            received_string:="";
        ENDWHILE

        SocketClose temp_socket;
        TPWrite "Have a good one!";
    ENDPROC
ENDMODULE