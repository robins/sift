
BEGIN;

SET search_path = 'sift';

SELECT AddTask1Stop(
  'testing1',           -- TaskName
  GetAnyFutureDate(),   -- Deadline
  '4 hour'::INTERVAL,   -- Duration
  'home',               -- Place
  'SMS'                 -- Alert
);

SELECT AddTask1Stop('testing2', GetAnyFutureDate(), '2 hour'::INTERVAL, 'office', NULL);
SELECT AddTask1Stop('testing3', GetAnyFutureDate(), '1 hour'::INTERVAL, 'office', NULL);
SELECT AddTask1Stop('testing4', GetAnyFutureDate(), '4 hour'::INTERVAL, 'home', NULL);

WITH x AS (
  SELECT 
    ROW_NUMBER() OVER () AS RowID,
    GetPrioritizedTaskList(GetPlaceID('home')) AS TaskID
)
  SELECT 
    TaskID, 
    Task.Name AS TaskName, 
    Deadline, 
    Duration,
    Place.Name
  FROM x
    JOIN Task             USING (TaskID)
    JOIN ActionablePlace  USING (TaskID)
    JOIN Duration         USING (TaskID)
    JOIN Place            USING (PlaceID)
  ORDER BY RowID
;

COMMIT;
