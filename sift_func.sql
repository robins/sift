BEGIN;

SET search_path = 'sift';

-- XXX: If we're moving duration to another table, doesn't make sense to have deadline clubbed to Task

CREATE FUNCTION AddTask(_Name TEXT, _Deadline TIMESTAMPTZ)
RETURNS BIGINT AS
$$
DECLARE _TaskID BIGINT := -1;
BEGIN
  INSERT INTO Task(Name, Deadline)
  VALUES (_Name, _Deadline)
  RETURNING TaskID
    INTO _TaskID;
  
  RETURN _TaskID;    
END;
$$ LANGUAGE PLPGSQL;


DROP FUNCTION IF EXISTS UpdateTaskName(BIGINT, TEXT);
CREATE FUNCTION UpdateTaskName(_TaskID BIGINT, _TaskName TEXT) RETURNS BOOLEAN AS
$$
BEGIN

  UPDATE Task
  SET Name = _TaskName
  WHERE TaskID = _TaskID;
  
  IF FOUND THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE PLPGSQL;


-- Remove an existing Task 
-- SELECT RemoveTask(1);
-- SELECT RemoveTask(GetRandomTaskID());
DROP FUNCTION IF EXISTS RemoveTask(BIGINT);
CREATE FUNCTION RemoveTask(_TaskID BIGINT) RETURNS BOOLEAN AS
$$
BEGIN

  DELETE FROM ActionablePlace
  WHERE TaskID = _TaskID;

  IF FOUND THEN
    DELETE FROM Duration
    WHERE TaskID = _TaskID;

    IF FOUND THEN
      DELETE FROM Task
      WHERE TaskID = _TaskID;

      IF FOUND THEN
        RETURN TRUE;
      END IF;
    END IF;
  END IF;

  RETURN FALSE;
END;
$$ LANGUAGE PLPGSQL;

-- Update Deadline
-- SELECT UpdateDeadline(1, '2017/12/1');
DROP FUNCTION IF EXISTS UpdateTaskDeadline(BIGINT);
CREATE OR REPLACE FUNCTION UpdateTaskDeadline(_TaskID BIGINT, _Deadline TIMESTAMPTZ) RETURNS BOOLEAN AS
$$
BEGIN
  UPDATE Task
  SET Deadline = _Deadline
  WHERE TaskID = _TaskID;
  
  IF FOUND THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;    
END;
$$ LANGUAGE PLPGSQL;



-- Single function to add a Task (with TaskName, Deadline, Duration, Place(bucket), Alert Mechanism)
-- SELECT AddTask1Stop('BookTickets', '2017/7/31', '1 hour', 'home');
-- SELECT AddTask1Stop('testing4', GetAnyFutureDate(), GetRandomInterval(), GetRandomPlace(), NULL);
-- SELECT AddTask1Stop('testing4');
DROP FUNCTION AddTask1Stop(TEXT, TIMESTAMPTZ, INTERVAL, TEXT, TEXT);
CREATE FUNCTION AddTask1Stop(
  _TaskName TEXT,
  _Deadline TIMESTAMPTZ DEFAULT NOW() + '1 day'::INTERVAL,
  _Duration INTERVAL    DEFAULT '1 hour'::INTERVAL,
  _Place    TEXT        DEFAULT 'home',
  _Alert    TEXT        DEFAULT NULL
)
RETURNS BIGINT AS
$$
DECLARE _TaskID  BIGINT := -1;
DECLARE _AlertID BIGINT := -1;
DECLARE _PlaceID BIGINT := -1;
BEGIN
  SELECT AddTask(_TaskName, _Deadline)
    INTO _TaskID;
  
  IF _TaskID IS NOT DISTINCT FROM -1 THEN
    RAISE 'Unable to create Task';
  END IF;
  
  SELECT AddAlert(_Alert)
    INTO _AlertID;
  
  PERFORM AddTaskDuration(
    _TaskID,
    _Duration
  );

  SELECT AddPlace(_Place)
    INTO _PlaceID;
    
  PERFORM AddTaskActionablePlace(
    _TaskID,
    _PlaceID
  );

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
    DO UPDATE SET 
      Duration  = _Duration,
      UpdatedTS = NOW();
  
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


CREATE FUNCTION AddPlace(_Name TEXT)
RETURNS BIGINT AS
$$
DECLARE _PlaceID BIGINT := -1;
BEGIN
  INSERT INTO Place(Name)
  VALUES (_Name)
  ON CONFLICT (Name)
  DO UPDATE SET
    UpdatedTS = NOW()
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
    PlaceID   = _PlaceID,
    UpdatedTS = NOW();
  
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

CREATE FUNCTION AddTaskDeadline (_TaskID BIGINT, _Deadline INTERVAL, _AlertID BIGINT)
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO Deadline (TaskID, Deadline, AlertID)
  VALUES (_TaskID, _Deadline, _AlertID)
  ON CONFLICT (TaskID)
    DO UPDATE SET 
        Deadline  = _Deadline,
        AlertID   = _AlertID,
        UpdatedTS = NOW();
    
  RETURN FOUND;
END;
$$ LANGUAGE PLPGSQL;



*/
COMMIT;

