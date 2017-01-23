
BEGIN;

SET search_path = 'sift';

DROP FUNCTION IF EXISTS GetRandomTaskID(BIGINT[]);
CREATE FUNCTION GetRandomTaskID(_ExceptTaskID BIGINT[] DEFAULT NULL) 
RETURNS BIGINT AS
$$
  SELECT TaskID 
  FROM Task
  WHERE _ExceptTaskID IS NULL 
    OR TaskID != ANY(_ExceptTaskID)
  LIMIT 1;
$$ LANGUAGE SQL;


DROP FUNCTION IF EXISTS GetRandomAlertID();
CREATE FUNCTION GetRandomAlertID() 
RETURNS BIGINT AS
$$
  SELECT AlertID 
  FROM Alert
  ORDER BY RANDOM()
  LIMIT 1;
$$ LANGUAGE SQL;


DROP FUNCTION IF EXISTS GetRandomPlaceID();
CREATE FUNCTION GetRandomPlaceID() 
RETURNS BIGINT AS
$$
DECLARE _PlaceID BIGINT DEFAULT -1;
BEGIN
  SELECT PlaceID
    INTO _PlaceID
  FROM Place
  ORDER BY RANDOM()
  LIMIT 1;
  
  IF FOUND THEN
    RETURN _PlaceID;
  ELSE
    RAISE 'Place Table empty';
  END IF;
END;
$$ LANGUAGE PLPGSQL;


DROP FUNCTION IF EXISTS GetRandomInterval();
CREATE FUNCTION GetRandomInterval() 
RETURNS INTERVAL AS
$$
  SELECT (a || ' hour')::INTERVAL 
  FROM generate_series(1, 24) as e(a)
  ORDER BY RANDOM()
  LIMIT 1;
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS GetPrioritizedTaskList(BIGINT);
CREATE FUNCTION GetPrioritizedTaskList(_PlaceID BIGINT)
RETURNS SETOF BIGINT AS 
$$
BEGIN
  RETURN QUERY 
    SELECT 
      TaskID
    FROM Task
      JOIN Deadline
        USING (TaskID)
      JOIN ActionablePlace
        USING (TaskID)
      JOIN Place
        USING (PlaceID)
    WHERE PlaceID IS NOT DISTINCT FROM _PlaceID
    ORDER BY Deadline DESC;
END;
$$ LANGUAGE PLPGSQL;


DROP FUNCTION IF EXISTS AddTask1Stop(TEXT,INTERVAL, TEXT, TEXT);
CREATE FUNCTION AddTask1Stop(
  _TaskName TEXT,
  _Interval INTERVAL DEFAULT NULL,
  _Place    TEXT DEFAULT NULL,
  _Alert    TEXT DEFAULT NULL
)
RETURNS BIGINT AS
$$
DECLARE _TaskID  BIGINT := -1;
DECLARE _AlertID BIGINT := -1;
DECLARE _PlaceID BIGINT := -1;
BEGIN
  SELECT AddTask(_TaskName)
    INTO _TaskID;
  
  IF _TaskID IS NOT DISTINCT FROM -1 THEN
    RAISE 'Unable to create Task';
  END IF;
  
  SELECT AddAlert(_Alert)
    INTO _AlertID;
  
  PERFORM AddTaskDeadline(
    _TaskID,
    _Interval,
    _AlertID
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

COMMIT;
