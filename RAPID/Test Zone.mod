MODULE TEST_ZONE
    !2013-11-18

    CONST pos location:=[5000,-1200,1300];
    CONST orient orientation:=[0.5, 0.5, 0.5, 0.5];
    CONST confdata configurationData:=[-1,1,0,0];
    CONST extjoint externalJoints:=[3000,9E9,9E9,9E9,9E9,9E9];
    CONST robtarget homeTarget:=[location,orientation,configurationData,externalJoints];

    CONST robtarget target1:=[[5000,-1000,1500],orientation,configurationData,externalJoints];
    CONST robtarget target2:=[[5000,-800,1300],orientation,configurationData,externalJoints];
    CONST robtarget target3:=[[5000,-600,1500],orientation,configurationData,externalJoints];
    CONST robtarget target4:=[[5000,-400,1300],orientation,configurationData,externalJoints];

    CONST robtarget targets{4}:=[target1,target2,target3,target4];

    VAR num answer;
    VAR zonedata zone;

    PROC main()
        !ConfL\Off;
        !ConfJ\Off;
        
        !SingArea \Wrist;

        MoveJ homeTarget,vmax,fine,tool0\WObj:=wobj0;

        TPReadFK answer,"Select Zone","fine","z50","z100","z150","z200";
        IF answer=1 THEN
            zone:=fine;
        ELSEIF answer=2 THEN
            zone:=z50;
        ELSEIF answer=3 THEN
            zone:=z100;
        ELSEIF answer=4 THEN
            zone:=z150;
        ELSEIF answer=5 THEN
            zone:=z200;
        ENDIF

        FOR i FROM 1 TO 4 DO
            MoveL targets{i},vmax,zone,tool0\WObj:=wobj0;
        ENDFOR

        !MoveL Offs(CRobT(\Tool:=tool0\WObj:=wobj0),stringToVal{1},stringToVal{2},stringToVal{3}),vmax,fine,tool0\WObj:=wobj0;

        TPWrite "Have a good one!";
    ENDPROC
ENDMODULE