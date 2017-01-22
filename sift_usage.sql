
ROLLBACK;
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


SELECT AddTaskDeadline(
  GetRandomTaskID(),
  GetRandomInterval(),
  GetRandomAlertID()
);

COMMIT;
