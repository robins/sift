BEGIN;

SET search_path = 'sift';

CREATE FUNCTION AddTask(_Name TEXT) 
RETURNS BIGINT AS
$$
DECLARE _TaskID BIGINT := -1;
BEGIN
  INSERT INTO Task(Name)
  VALUES (_Name)
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


CREATE FUNCTION AddTaskDeadline (_TaskID BIGINT, _Deadline INTERVAL, _AlertID BIGINT)
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
RETURNS BIGINT AS
$$
DECLARE _PlaceID BIGINT := -1;
BEGIN
  INSERT INTO Place(Name)
  VALUES (_Name)
  RETURNING PlaceID
    INTO _PlaceID;
  
  RETURN _PlaceID;
END;
$$ LANGUAGE PLPGSQL;


CREATE FUNCTION GetPlaceID(_PlaceName TEXT)
RETURNS BIGINT AS
$$
DECLARE _PlaceID BIGINT := -1;
BEGIN
  SELECT PlaceID
    INTO _PlaceID
  FROM Place
  WHERE Name = _PlaceName;
  
  RETURN _PlaceID;
END;
$$ LANGUAGE PLPGSQL;


CREATE FUNCTION AddTaskActionablePlace(_TaskID BIGINT, _PlaceID BIGINT)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO ActionablePlace(TaskID, PlaceID)
  VALUES (_TaskID, _PlaceID)
  ON CONFLICT (TaskID)
  DO UPDATE SET
    PlaceID = _PlaceID;
  
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;


CREATE FUNCTION AddAlert (_Name TEXT)
RETURNS BIGINT AS 
$$
DECLARE _AlertID BIGINT := -1;
BEGIN
  INSERT INTO Alert(Name)
  VALUES (_Name)
  RETURNING AlertID
    INTO _AlertID;
  
  RETURN _AlertID;
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


*/
COMMIT;

