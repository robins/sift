
BEGIN;

SET search_path = 'sift';

/*SELECT AddTaskDeadline(
  AddTask('testing1'),
  '1 hours',
  GetRandomAlertID()
);

SELECT AddTaskDeadline(
  AddTask('testing2'),
  '2 hours',
  GetRandomAlertID()
);

SELECT AddPlace('Home');
SELECT AddTaskActionablePlace(
  GetRandomTaskID(),
  GetRandomPlaceID()
);
*/

SELECT AddTask1Stop(
  'testing1', --_TaskName  TEXT,
  '2 hour'::INTERVAL,   --_Interval  INTERVAL,
  'home',      -- _Place    TEXT
  'SMS'        -- _Alert    TEXT,
);


SELECT AddTask1Stop('testing2', '3 hour'::INTERVAL, 'office', NULL);
SELECT AddTask1Stop('testing3', '2 hour'::INTERVAL, 'office', NULL);
SELECT AddTask1Stop('testing4', '7 hour'::INTERVAL, 'home', NULL);

WITH x AS (
  SELECT 
    ROW_NUMBER() OVER () AS RowID,
    GetPrioritizedTaskList(GetPlaceID('home')) AS TaskID
)
  SELECT TaskID, Task.Name AS TaskName, Deadline, Place.Name
  FROM x
    JOIN Task             USING (TaskID)
    JOIN Deadline         USING (TaskID)
    JOIN ActionablePlace  USING (TaskID)
    JOIN Place            USING (PlaceID)
  ORDER BY RowID
;

COMMIT;
