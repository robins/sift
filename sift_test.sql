
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


SELECT AddTask1Stop('testing2', '3 hour'::INTERVAL, NULL, 'office');

SELECT AddTask1Stop(
  'testing1', --_TaskName  TEXT,
  '2 hour'::INTERVAL,   --_Interval  INTERVAL,
  'SMS',      -- _Alert    TEXT,
  'home'      -- _Place    TEXT
);

WITH x AS (
  SELECT 
    ROW_NUMBER() OVER () AS RowID,
    GetPrioritizedTaskList(GetPlaceID('office')) AS TaskID
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
