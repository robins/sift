BEGIN;

SET search_path = 'sift';

CREATE FUNCTION AddTask(_Description TEXT) 
RETURNS BIGINT AS
$$
DECLARE _TaskID BIGINT DEFAULT -1;
BEGIN
  INSERT INTO Task(Description)
  VALUES (_Description)
  RETURNING TaskID
    INTO _TaskID;
  
  RETURN _TaskID;    
END;
$$ LANGUAGE PLPGSQL;


CREATE FUNCTION AddDependency(_DependentTaskID BIGINT, _DependencyTaskID  BIGINT)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO Dependency(DependentTaskID, DependencyTaskID)
  VALUES (_DependentTaskID, _DependencyTaskID);
  
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;


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


CREATE FUNCTION GetTaskDuration(_TaskID BIGINT) 
RETURNS INTERVAL AS
$$
  SELECT Duration 
  FROM Duration
  WHERE TaskID = _TaskID;
$$ LANGUAGE SQL;


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


CREATE FUNCTION AddPlace(_Name TEXT)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO Place(Name)
  VALUES (_Name);
  
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;


CREATE FUNCTION AddTaskActionablePlace(_TaskID BIGINT, _PlaceID BIGINT)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO ActionablePlace(TaskID, PlaceID)
  VALUES (_TaskID, _PlaceID)
  ON CONFLICT (TaskID)
  DO UPDATE SET PlaceID = _PlaceID;
  
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

