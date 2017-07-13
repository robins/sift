
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


DROP FUNCTION IF EXISTS GetRandomPlace();
CREATE FUNCTION GetRandomPlace() RETURNS TEXT AS
$$
  WITH x AS (
    SELECT Name
    FROM Place
    ORDER BY RANDOM()
    LIMIT 1
  )
  SELECT x.Name
  FROM x
    
UNION ALL

  SELECT NULL
  WHERE (SELECT COUNT(*) FROM x) = 0
$$ LANGUAGE SQL;


DROP FUNCTION IF EXISTS GetRandomInterval();
CREATE FUNCTION GetRandomInterval() 
RETURNS INTERVAL AS
$$
  SELECT (a || ' hour')::INTERVAL 
  FROM generate_series(1, 24) as e(a)
  ORDER BY RANDOM()
  LIMIT 1;
$$ LANGUAGE SQL;


-- Get Prioritized list of tasks
-- SELECT * FROM GetPrioritizedTaskListWithDetail(GetPlaceID('home'));
DROP FUNCTION IF EXISTS GetPrioritizedTaskListWithDetail(BIGINT);
CREATE OR REPLACE FUNCTION GetPrioritizedTaskListWithDetail(
  IN  _PlaceID  BIGINT,
  --OUT RowID     BIGINT,
  OUT TimeSpare TEXT,
  --OUT TaskID    BIGINT,
  OUT TaskName  TEXT,
  OUT Deadline  TEXT,
  OUT Duration  TEXT,
  OUT PlaceName TEXT
) RETURNS SETOF RECORD AS 
$$
  WITH Config AS (
    SELECT 
      1 AS HoursPerDay
  ),
  Calc AS (
    SELECT 
  --    ROW_NUMBER() OVER () AS RowID,
      
      -- =======================================
      -- XXX: We need a better way to account for the fact that time available to do a task, has to take into account other tasks before *and* after it.
      -- =======================================
      
      --    GREATEST(
        ROUND((EXTRACT(EPOCH FROM Deadline) 
          - EXTRACT(EPOCH FROM NOW())
          - EXTRACT(EPOCH FROM (
              SELECT SUM(D.Duration) 
              FROM Task T2 
                JOIN Duration D USING (TaskID) 
              WHERE T2.Deadline BETWEEN NOW() AND T1.Deadline)))/3600) 
    --    ,0)
      AS TimeSpare,
      --TaskID, 
      T1.Name || ' (' || TaskID || ')' AS TaskName, 
      Deadline, 
      Duration,
      Place.Name AS PlaceName
    FROM Config, Task T1
      JOIN ActionablePlace  USING (TaskID)
      JOIN Duration         USING (TaskID)
      JOIN Place            USING (PlaceID)
    WHERE PlaceID IS NOT DISTINCT FROM _PlaceID
  )
  SELECT 
    Timespare || ' hrs',
    TaskName,
    to_char(Deadline, 'Day DD Mon'),
    date_part('hour', Duration) || ' hrs',
    PlaceName
  FROM Calc
  ORDER BY TimeSpare, Deadline, Duration DESC;
$$ LANGUAGE SQL;

CREATE FUNCTION GetAnyFutureDate()
RETURNS TIMESTAMPTZ AS
$$
  SELECT (NOW() + ((random() * 10) || ' hours')::INTERVAL)::TIMESTAMPTZ
$$ LANGUAGE SQL;




COMMIT;
