-- This file and its contents are licensed under the Apache License 2.0.
-- Please see the included NOTICE for copyright information and
-- LICENSE-APACHE for a copy of the license.

-- Test support for setting table access method on hypertables
\c :TEST_DBNAME :ROLE_SUPERUSER
-- create a new access method that reuses the heap handler
CREATE ACCESS METHOD testam TYPE TABLE HANDLER heap_tableam_handler;
SET ROLE :ROLE_DEFAULT_PERM_USER;

CREATE TABLE testam (time timestamptz, device int, temp float) USING testam;
SELECT create_hypertable('testam', 'time', 'device', 2);

-- show that the hypertable is using the 'testam' table access method
SELECT amname AS hypertable_amname
FROM pg_class cl, pg_am am
WHERE cl.oid = 'testam'::regclass
AND cl.relam = am.oid;

-- insert data to create a chunk
INSERT INTO testam VALUES('2020-01-22:11:30', 1, 29.3);

-- make sure the table access method for a chunk is the same as the
-- hypertable root
SELECT amname AS chunk_amname
FROM pg_class cl, pg_am am, show_chunks('testam') ch
WHERE cl.oid = ch
AND cl.relam = am.oid;
