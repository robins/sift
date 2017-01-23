
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
CREATE FUNCTION GetPrioritizedTaskList(
  IN  _PlaceID  BIGINT,
  OUT RowID     BIGINT,
  OUT TimeSpare FLOAT,
  OUT TaskID    BIGINT,
  OUT TaskName  TEXT,
  OUT Deadline  TIMESTAMPTZ,
  OUT Duration  INTERVAL,
  OUT PlaceName TEXT
) RETURNS SETOF RECORD AS 
$$
  WITH Config AS (
    SELECT 
      1 AS HoursPerDay
  )
  SELECT 
    ROW_NUMBER() OVER () AS RowID,
    
    -- =======================================
    -- XXX: We need a better way to account for the fact that time available to do a task, has to take into account other tasks before *and* after it.
    -- =======================================
    
    --    GREATEST(
      (EXTRACT(EPOCH FROM Deadline) 
        - EXTRACT(EPOCH FROM NOW())
        - EXTRACT(EPOCH FROM (SELECT SUM(D.Duration) FROM Task T2 JOIN Duration D USING (TaskID) WHERE T2.Deadline BETWEEN NOW() AND T1.Deadline)))/3600 
  --    ,0)
    AS TimeSpare,
    TaskID, 
    T1.Name AS TaskName, 
    Deadline, 
    Duration,
    Place.Name
  FROM Config, Task T1
    JOIN ActionablePlace  USING (TaskID)
    JOIN Duration         USING (TaskID)
    JOIN Place            USING (PlaceID)
  WHERE PlaceID IS NOT DISTINCT FROM _PlaceID
  ORDER BY TimeSpare, Deadline ASC;
$$ LANGUAGE SQL;

CREATE FUNCTION GetAnyFutureDate()
RETURNS TIMESTAMPTZ AS
$$
  SELECT (NOW() + ((random() * 10) || ' hours')::INTERVAL)::TIMESTAMPTZ
$$ LANGUAGE SQL;




COMMIT;
