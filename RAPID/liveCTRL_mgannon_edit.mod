MODULE LiveCTRL01

  ! Feeding robtargets from java to robot

  ! Setup tool and home data
  PERS tooldata MyTool:=[TRUE,[[0.0,0.0,462.0],[1.0,0.0,0.0,0.0]],[1,[0,0,1],[1,0,0,0],0,0,0]];
  CONST jointtarget homePose := [[0,0,0,0,0,0],[0,0,0,0,0,0]];

  ! Setup communication variables
  VAR socketdev socket1;
  VAR string message;
  VAR bool listen;
  VAR num port;
  VAR string ip;
  VAR num count;
  VAR byte msg_dc{1};
  VAR byte msg_ack{1};
  
  
  !fixed it!
  FUNC robtarget parseTarget(String msg)
     VAR num x;
     VAR num y;
     VAR num z;
     VAR num rx;
     VAR num ry;
     VAR num rz;
     VAR num stringToVal{6};

     IF StrToVal(msg,stringToVal) THEN
        TPWrite "hoozah!";
     ENDIF
 
     x  := stringToVal{1};
     y  := stringToVal{2};
     z  := stringToVal{3};
     rx := stringToVal{4};
     ry := stringToVal{5};
     rz := stringToVal{6};
  
  RETURN getRobtarget(x, y, z, rx, ry, rz);
ENDFUNC

! Translates X,Y,Z,RX,RY,RZ into robtarget
FUNC robtarget getRobtarget(num x, num y, num z, num eulerX, num eulerY, num eulerZ)
  VAR robtarget targetToMoveTo:= [ [0,0,0], [1, 0, 0, 0], [0, 0, 0, 0], [ 9E9, 9E9, 9E9, 9E9, 9E9, 9E9] ];
  VAR jointtarget testJoint;
  VAR robtarget testTarget;
  targetToMoveTo.trans := [x,y,z];
  targetToMoveTo.rot := OrientZYX(eulerZ, eulerY, eulerX);

  testJoint  := CJointT();
  testTarget := CalcRobT(testJoint, MyTool);
  targetToMoveTo.robconf := testTarget.robconf;
  RETURN targetToMoveTo;
ENDFUNC

! Takes a rob


PROC main()
  ConfL\Off;
  ConfJ\Off;
  

  MoveAbsJ homePose, v20, z1, MyTool;

  ! Start Messaging variables
  listen:=TRUE;
  count:=0;
  msg_dc{1}:=5;
  msg_ack{1}:=1;

  startupConnection;

  WHILE listen DO
      SocketReceive socket1\Str:=message;
      TPWrite "Server: "+message;
      TPWrite "Client: The count is: "\Num:=count;

      IF SocketGetStatus(socket1)=SOCKET_LISTENING THEN
          TPWrite "Client: Listening";
      ENDIF

      IF message="Disconnect" THEN
          listen:=FALSE;
          SocketSend socket1\Data:=msg_dc\NoOfBytes:=1;
      ENDIF


      MoveJ parseTarget(message), v20, z1, MyTool;

      
      ! Acknowledge and reset message to empty
      TPWrite "Client: Sending acknowledge";
      SocketSend socket1\Data:=msg_ack\NoOfBytes:=1;
      message:="";
      
      count:=count+1;

  ENDWHILE

  TPWrite "Close Connection";

  SocketClose socket1;


  ENDPROC

  PROC startupConnection()
        !Connect
        SocketCreate socket1;

        !Add your computer's IP Address here
        SocketConnect socket1,"192.168.125.9",1025;

        !Wait for a welcome from the server
        SocketReceive socket1\Str:=message;        
        TPWrite "Server: "+message;

        !Acknowledge the Welcome
        TPWrite "Client: Sending connection acknowledge";
        SocketSend socket1\Data:=msg_ack\NoOfBytes:=1;
        message:="";

        !We should be good to go at this point
  ENDPROC

ENDMODULE