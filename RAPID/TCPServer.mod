MODULE TCP_SERVER

    VAR socketdev temp_socket;
    VAR socketdev client_socket;
    VAR string received_string;
    VAR bool keep_listening:=TRUE;

    PROC main()
        SocketCreate temp_socket;
        SocketBind temp_socket,"192.168.0.2",1025;
        SocketListen temp_socket;
        WHILE keep_listening DO
            ! Waiting for a connection request
            SocketAccept temp_socket,client_socket;
            ! Communication
            SocketReceive client_socket\Str:=received_string;
            TPWrite "Client wrote - "+received_string;
            received_string:="";
            SocketSend client_socket\Str:="Message acknowledged";
            ! Shutdown the connection
            SocketReceive client_socket\Str:=received_string;
            TPWrite "Client wrote - "+received_string;
            SocketSend client_socket\Str:="Shutdown acknowledged";
            SocketClose client_socket;
        ENDWHILE
        SocketClose temp_socket;
    ENDPROC

ENDMODULE