
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

CREATE FUNCTION Duration(
  TaskID      BIGINT        PRIMARY KEY REFERENCES Task(TaskID),
  Duration    INTERVAL,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ
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

CREATE FUNCTION Deadline (
  TaskID      BIGINT        REFERENCES Task(TaskID),
  Deadline    INTERVAL,
  AlertID     BIGINT        REFERENCES Alert(AlertID),
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, Deadline)
);

*/
COMMIT;

