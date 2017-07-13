
psql -1 -v ON_ERROR_STOP=1 -U postgres -c "DROP SCHEMA IF EXISTS sift CASCADE" sift ^
	&& psql -1 -v ON_ERROR_STOP=1 -U postgres -f sift_schema.sql -f sift_func.sql -f sift_usage.sql -f sift_test.sql sift