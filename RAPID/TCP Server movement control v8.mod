    CONST num home_x:=5000;
    CONST num home_y:=-1500;
    CONST num home_z:=1000;

    CONST num box_size:=1000;

    CONST num max_x:=home_x+box_size/2;
    CONST num min_x:=home_x-box_size/2;

    CONST num max_y:=home_y+box_size/2;
    CONST num min_y:=home_y-box_size/2;

    CONST num max_z:=home_z+box_size/2;
    CONST num min_z:=home_z-box_size/2;

    CONST pos home_location:=[home_x,home_y,home_z];

    PROC ChangePosition()
        currentPosition:=CPos(\Tool:=tool0\WObj:=wobj0);
        hit_limit:=FALSE;

        IF currentPosition.x+stringToVal{2}>=max_x THEN
            stringToVal{2}:=max_x-currentPosition.x;
            hit_limit:=TRUE;
        ENDIF

        IF currentPosition.x+stringToVal{2}<=min_x THEN
            stringToVal{2}:=min_x-currentPosition.x;
            hit_limit:=TRUE;
        ENDIF

        IF currentPosition.y+stringToVal{3}>=max_y THEN
            stringToVal{3}:=max_y-currentPosition.y;
            hit_limit:=TRUE;
        ENDIF

        IF currentPosition.y+stringToVal{3}<=min_y THEN
            stringToVal{3}:=min_y-currentPosition.y;
            hit_limit:=TRUE;
        ENDIF

        IF currentPosition.z+stringToVal{4}>=max_z THEN
            stringToVal{4}:=max_z-currentPosition.z;
            hit_limit:=TRUE;
        ENDIF

        IF currentPosition.z+stringToVal{4}<=min_z THEN
            stringToVal{4}:=min_z-currentPosition.z;
            hit_limit:=TRUE;
        ENDIF

        MoveJ Offs(CRobT(\Tool:=tool0\WObj:=wobj0),stringToVal{2},stringToVal{3},stringToVal{4}),[stringToVal{5}*2,500,5000,1000],zone,tool0\WObj:=wobj0;
    ENDPROC