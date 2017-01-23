
psql.exe -U postgres -h localhost -c "DROP SCHEMA IF EXISTS sift CASCADE" sift && psql.exe -U postgres -h localhost -f sift_schema.sql sift && psql.exe -U postgres -h localhost -f sift_func.sql sift && psql.exe -U postgres -h localhost -f sift_usage.sql sift && psql.exe -U postgres -h localhost -f sift_test.sql sift
