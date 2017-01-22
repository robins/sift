
ROLLBACK;
BEGIN;

SET search_path = 'sift';


DROP FUNCTION IF EXISTS AddTask(TEXT);
CREATE FUNCTION AddTask(_Description TEXT) 
RETURNS BIGINT AS
$$
DECLARE TaskID BIGINT DEFAULT -1;
BEGIN
  INSERT INTO Task(Description)
  VALUES (_Description)
  RETURNING TaskID
    AS TaskID;
  
  RETURN TaskID;    
END;
$$ LANGUAGE PLPGSQL;


DROP FUNCTION IF EXISTS AddDependency (BIGINT);
CREATE FUNCTION AddDependency(_DependentTaskID BIGINT, _DependencyTaskID  BIGINT)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO Dependency(DependentTaskID, DependencyTaskID)
  VALUES (_DependentTaskID, _DependencyTaskID);
  
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;


DROP FUNCTION IF EXISTS AddTaskDuration(BIGINT, INTERVAL);
CREATE FUNCTION AddTaskDuration(_TaskID BIGINT, _Duration INTERVAL)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO Duration(TaskID, Duration)
  VALUES(_TaskID, _Duration)
  ON CONFLICT (TaskID)
    DO UPDATE SET Duration = _Duration;
  
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;

DROP FUNCTION IF EXISTS GetTaskDuration(BIGINT);
CREATE FUNCTION GetTaskDuration(_TaskID BIGINT) 
RETURNS INTERVAL AS
$$
  SELECT Duration 
  FROM Duration
  WHERE TaskID = _TaskID;
$$ LANGUAGE SQL;


DROP FUNCTION IF EXISTS AddTaskDeadline (BIGINT, INTERVAL, BIGINT);
CREATE FUNCTION AddTaskDeadline (TaskID BIGINT, Deadline INTERVAL, AlertID BIGINT)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO Deadline (TaskID, Deadline, AlertID)
  VALUES (_TaskID, _Deadline, _AlertID)
  ON CONFLICT (TaskID)
    DO UPDATE SET 
        Deadline = _Deadline,
        AlertID = _AlertID;
    
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;

/*
CREATE FUNCTION ActionableTimeInDay(
  TaskID      BIGINT        REFERENCES Task(TaskID),
  BeginTime   TIMESTAMPTZ,
  EndTime     TIMESTAMPTZ,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, BeginTime)
); 

CREATE FUNCTION ActinableTimeInWeek(
  TaskID      BIGINT        REFERENCES Task(TaskID),
  DayOfWeek   SMALLINT,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, DayOfWeek)
);

CREATE FUNCTION Place(
  PlaceID     BIGSERIAL     PRIMARY KEY,
  Name        TEXT,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ
);

CREATE FUNCTION ActionablePlace(
  TaskID      BIGINT        REFERENCES Task(TaskID),
  PlaceID     BIGSERIAL,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, PlaceID)
);

CREATE FUNCTION Alert (_AlertID BIGINT, _Name TEXT)
RETURNS BOOLEAN AS 
$$
BEGIN
  INSERT INTO Alert(AlertID, Name)
  VALUES (_AlertID, _Name);
  
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;


*/
COMMIT;

