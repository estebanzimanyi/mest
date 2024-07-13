-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION mgist_mobilitydb" to load this file. \quit

/******************************************************************************
 * Utility functions
 ******************************************************************************/

CREATE FUNCTION stbox_collect(stbox[])
  RETURNS geometry
  AS $$ SELECT ST_Collect(b::geometry) FROM unnest($1) AS b  $$
  LANGUAGE SQL;

/******************************************************************************
 * Multi Entry R-Tree for spanset types using ME-GiST
 ******************************************************************************/

CREATE FUNCTION span_mgist_consistent(internal, intspanset, smallint, oid, internal)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Span_gist_consistent'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION span_mgist_consistent(internal, bigintspanset, smallint, oid, internal)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Span_gist_consistent'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION span_mgist_consistent(internal, floatspanset, smallint, oid, internal)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Span_gist_consistent'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION span_mgist_consistent(internal, datespanset, smallint, oid, internal)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Span_gist_consistent'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION span_mgist_consistent(internal, tstzspanset, smallint, oid, internal)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Span_gist_consistent'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION spanset_mgist_compress(internal)
  RETURNS internal
  AS 'MODULE_PATHNAME', 'Spanset_mgist_compress'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION spanset_mgist_extract(internal, internal, internal)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Spanset_mgist_extract'
  LANGUAGE C IMMUTABLE STRICT;

/******************************************************************************/

CREATE OPERATOR CLASS intspanset_mgist_ops
  DEFAULT FOR TYPE intspanset USING mgist AS
  STORAGE intspan,
  -- strictly left
  OPERATOR  1     << (intspanset, integer),
  OPERATOR  1     << (intspanset, intspan),
  OPERATOR  1     << (intspanset, intspanset),
  -- overlaps or left
  OPERATOR  2     &< (intspanset, integer),
  OPERATOR  2     &< (intspanset, intspan),
  OPERATOR  2     &< (intspanset, intspanset),
  -- overlaps
  OPERATOR  3     && (intspanset, intspan),
  OPERATOR  3     && (intspanset, intspanset),
  -- overlaps or right
  OPERATOR  4     &> (intspanset, integer),
  OPERATOR  4     &> (intspanset, intspan),
  OPERATOR  4     &> (intspanset, intspanset),
  -- strictly right
  OPERATOR  5     >> (intspanset, integer),
  OPERATOR  5     >> (intspanset, intspan),
  OPERATOR  5     >> (intspanset, intspanset),
  -- contains
  OPERATOR  7     @> (intspanset, integer),
  OPERATOR  7     @> (intspanset, intspan),
  OPERATOR  7     @> (intspanset, intspanset),
  -- contained by
  OPERATOR  8     <@ (intspanset, intspan),
  OPERATOR  8     <@ (intspanset, intspanset),
  -- adjacent
  OPERATOR  17    -|- (intspanset, intspan),
  OPERATOR  17    -|- (intspanset, intspanset),
  -- equals
  OPERATOR  18    = (intspanset, intspanset),
  -- nearest approach distance
  OPERATOR  25    <-> (intspanset, integer) FOR ORDER BY pg_catalog.integer_ops,
  OPERATOR  25    <-> (intspanset, intspan) FOR ORDER BY pg_catalog.integer_ops,
  OPERATOR  25    <-> (intspanset, intspanset) FOR ORDER BY pg_catalog.integer_ops,
  -- functions
  FUNCTION  1  span_mgist_consistent(internal, intspanset, smallint, oid, internal),
  FUNCTION  2  span_gist_union(internal, internal),
  FUNCTION  3  spanset_mgist_compress(internal),
  FUNCTION  5  span_gist_penalty(internal, internal, internal),
  FUNCTION  6  span_gist_picksplit(internal, internal),
  FUNCTION  7  span_gist_same(intspan, intspan, internal),
  FUNCTION  8  span_gist_distance(internal, intspan, smallint, oid, internal),
  FUNCTION  12 spanset_mgist_extract(internal, internal, internal);

/******************************************************************************/

CREATE OPERATOR CLASS bigintspanset_mgist_ops
  DEFAULT FOR TYPE bigintspanset USING mgist AS
  STORAGE bigintspan,
  -- strictly left
  OPERATOR  1     << (bigintspanset, bigint),
  OPERATOR  1     << (bigintspanset, bigintspan),
  OPERATOR  1     << (bigintspanset, bigintspanset),
  -- overlaps or left
  OPERATOR  2     &< (bigintspanset, bigint),
  OPERATOR  2     &< (bigintspanset, bigintspan),
  OPERATOR  2     &< (bigintspanset, bigintspanset),
  -- overlaps
  OPERATOR  3     && (bigintspanset, bigintspan),
  OPERATOR  3     && (bigintspanset, bigintspanset),
  -- overlaps or right
  OPERATOR  4     &> (bigintspanset, bigint),
  OPERATOR  4     &> (bigintspanset, bigintspan),
  OPERATOR  4     &> (bigintspanset, bigintspanset),
  -- strictly right
  OPERATOR  5     >> (bigintspanset, bigint),
  OPERATOR  5     >> (bigintspanset, bigintspan),
  OPERATOR  5     >> (bigintspanset, bigintspanset),
  -- contains
  OPERATOR  7     @> (bigintspanset, bigint),
  OPERATOR  7     @> (bigintspanset, bigintspan),
  OPERATOR  7     @> (bigintspanset, bigintspanset),
  -- contained by
  OPERATOR  8     <@ (bigintspanset, bigintspan),
  OPERATOR  8     <@ (bigintspanset, bigintspanset),
  -- adjacent
  OPERATOR  17    -|- (bigintspanset, bigintspan),
  OPERATOR  17    -|- (bigintspanset, bigintspanset),
  -- equals
  OPERATOR  18    = (bigintspanset, bigintspanset),
  -- nearest approach distance
  OPERATOR  25    <-> (bigintspanset, bigint) FOR ORDER BY pg_catalog.integer_ops,
  OPERATOR  25    <-> (bigintspanset, bigintspan) FOR ORDER BY pg_catalog.integer_ops,
  OPERATOR  25    <-> (bigintspanset, bigintspanset) FOR ORDER BY pg_catalog.integer_ops,
  -- functions
  FUNCTION  1  span_mgist_consistent(internal, bigintspanset, smallint, oid, internal),
  FUNCTION  2  span_gist_union(internal, internal),
  FUNCTION  3  spanset_mgist_compress(internal),
  FUNCTION  5  span_gist_penalty(internal, internal, internal),
  FUNCTION  6  span_gist_picksplit(internal, internal),
  FUNCTION  7  span_gist_same(bigintspan, bigintspan, internal),
  FUNCTION  8  span_gist_distance(internal, bigintspan, smallint, oid, internal),
  FUNCTION  12 spanset_mgist_extract(internal, internal, internal);

/******************************************************************************/

CREATE OPERATOR CLASS floatspanset_mgist_ops
  DEFAULT FOR TYPE floatspanset USING mgist AS
  STORAGE floatspan,
  -- strictly left
  OPERATOR  1     << (floatspanset, float),
  OPERATOR  1     << (floatspanset, floatspan),
  OPERATOR  1     << (floatspanset, floatspanset),
  -- overlaps or left
  OPERATOR  2     &< (floatspanset, float),
  OPERATOR  2     &< (floatspanset, floatspan),
  OPERATOR  2     &< (floatspanset, floatspanset),
  -- overlaps
  OPERATOR  3     && (floatspanset, floatspan),
  OPERATOR  3     && (floatspanset, floatspanset),
  -- overlaps or right
  OPERATOR  4     &> (floatspanset, float),
  OPERATOR  4     &> (floatspanset, floatspan),
  OPERATOR  4     &> (floatspanset, floatspanset),
  -- strictly right
  OPERATOR  5     >> (floatspanset, float),
  OPERATOR  5     >> (floatspanset, floatspan),
  OPERATOR  5     >> (floatspanset, floatspanset),
  -- contains
  OPERATOR  7     @> (floatspanset, float),
  OPERATOR  7     @> (floatspanset, floatspan),
  OPERATOR  7     @> (floatspanset, floatspanset),
  -- contained by
  OPERATOR  8     <@ (floatspanset, floatspan),
  OPERATOR  8     <@ (floatspanset, floatspanset),
  -- adjacent
  OPERATOR  17    -|- (floatspanset, floatspan),
  OPERATOR  17    -|- (floatspanset, floatspanset),
  -- equals
  OPERATOR  18    = (floatspanset, floatspanset),
  -- nearest approach distance
  OPERATOR  25    <-> (floatspanset, float) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    <-> (floatspanset, floatspan) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    <-> (floatspanset, floatspanset) FOR ORDER BY pg_catalog.float_ops,
  -- functions
  FUNCTION  1  span_mgist_consistent(internal, floatspanset, smallint, oid, internal),
  FUNCTION  2  span_gist_union(internal, internal),
  FUNCTION  3  spanset_mgist_compress(internal),
  FUNCTION  5  span_gist_penalty(internal, internal, internal),
  FUNCTION  6  span_gist_picksplit(internal, internal),
  FUNCTION  7  span_gist_same(floatspan, floatspan, internal),
  FUNCTION  8  span_gist_distance(internal, floatspan, smallint, oid, internal),
  FUNCTION  12 spanset_mgist_extract(internal, internal, internal);

/******************************************************************************/

CREATE OPERATOR CLASS datespanset_mgist_ops
  DEFAULT FOR TYPE datespanset USING mgist AS
  STORAGE datespan,
  -- overlaps
  OPERATOR  3    && (datespanset, datespan),
  OPERATOR  3    && (datespanset, datespanset),
  -- contains
  OPERATOR  7    @> (datespanset, date),
  OPERATOR  7    @> (datespanset, datespan),
  OPERATOR  7    @> (datespanset, datespanset),
  -- contained by
  OPERATOR  8    <@ (datespanset, datespan),
  OPERATOR  8    <@ (datespanset, datespanset),
  -- adjacent
  OPERATOR  17    -|- (datespanset, datespan),
  OPERATOR  17    -|- (datespanset, datespanset),
  -- equals
  OPERATOR  18    = (datespanset, datespanset),
  -- nearest approach distance
  OPERATOR  25    <-> (datespanset, date) FOR ORDER BY pg_catalog.integer_ops,
  OPERATOR  25    <-> (datespanset, datespan) FOR ORDER BY pg_catalog.integer_ops,
  OPERATOR  25    <-> (datespanset, datespanset) FOR ORDER BY pg_catalog.integer_ops,
  -- overlaps or before
  OPERATOR  28    &<# (datespanset, date),
  OPERATOR  28    &<# (datespanset, datespan),
  OPERATOR  28    &<# (datespanset, datespanset),
  -- strictly before
  OPERATOR  29    <<# (datespanset, date),
  OPERATOR  29    <<# (datespanset, datespan),
  OPERATOR  29    <<# (datespanset, datespanset),
  -- strictly after
  OPERATOR  30    #>> (datespanset, date),
  OPERATOR  30    #>> (datespanset, datespan),
  OPERATOR  30    #>> (datespanset, datespanset),
  -- overlaps or after
  OPERATOR  31    #&> (datespanset, date),
  OPERATOR  31    #&> (datespanset, datespan),
  OPERATOR  31    #&> (datespanset, datespanset),
  -- functions
  FUNCTION  1  span_mgist_consistent(internal, datespanset, smallint, oid, internal),
  FUNCTION  2  span_gist_union(internal, internal),
  FUNCTION  3  spanset_mgist_compress(internal),
  FUNCTION  5  span_gist_penalty(internal, internal, internal),
  FUNCTION  6  span_gist_picksplit(internal, internal),
  FUNCTION  7  span_gist_same(datespan, datespan, internal),
  FUNCTION  12 spanset_mgist_extract(internal, internal, internal);

/******************************************************************************/

CREATE OPERATOR CLASS tstzspanset_mgist_ops
  DEFAULT FOR TYPE tstzspanset USING mgist AS
  STORAGE tstzspan,
  -- overlaps
  OPERATOR  3    && (tstzspanset, tstzspan),
  OPERATOR  3    && (tstzspanset, tstzspanset),
  -- contains
  OPERATOR  7    @> (tstzspanset, timestamptz),
  OPERATOR  7    @> (tstzspanset, tstzspan),
  OPERATOR  7    @> (tstzspanset, tstzspanset),
  -- contained by
  OPERATOR  8    <@ (tstzspanset, tstzspan),
  OPERATOR  8    <@ (tstzspanset, tstzspanset),
  -- adjacent
  OPERATOR  17    -|- (tstzspanset, tstzspan),
  OPERATOR  17    -|- (tstzspanset, tstzspanset),
  -- equals
  OPERATOR  18    = (tstzspanset, tstzspanset),
  -- nearest approach distance
  OPERATOR  25    <-> (tstzspanset, timestamptz) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    <-> (tstzspanset, tstzspan) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    <-> (tstzspanset, tstzspanset) FOR ORDER BY pg_catalog.float_ops,
  -- overlaps or before
  OPERATOR  28    &<# (tstzspanset, timestamptz),
  OPERATOR  28    &<# (tstzspanset, tstzspan),
  OPERATOR  28    &<# (tstzspanset, tstzspanset),
  -- strictly before
  OPERATOR  29    <<# (tstzspanset, timestamptz),
  OPERATOR  29    <<# (tstzspanset, tstzspan),
  OPERATOR  29    <<# (tstzspanset, tstzspanset),
  -- strictly after
  OPERATOR  30    #>> (tstzspanset, timestamptz),
  OPERATOR  30    #>> (tstzspanset, tstzspan),
  OPERATOR  30    #>> (tstzspanset, tstzspanset),
  -- overlaps or after
  OPERATOR  31    #&> (tstzspanset, timestamptz),
  OPERATOR  31    #&> (tstzspanset, tstzspan),
  OPERATOR  31    #&> (tstzspanset, tstzspanset),
  -- functions
  FUNCTION  1  span_mgist_consistent(internal, tstzspanset, smallint, oid, internal),
  FUNCTION  2  span_gist_union(internal, internal),
  FUNCTION  3  spanset_mgist_compress(internal),
  FUNCTION  5  span_gist_penalty(internal, internal, internal),
  FUNCTION  6  span_gist_picksplit(internal, internal),
  FUNCTION  7  span_gist_same(tstzspan, tstzspan, internal),
  FUNCTION  12 spanset_mgist_extract(internal, internal, internal);

/******************************************************************************
 * Multi Entry R-Tree for tgeompoint using ME-GiST
 ******************************************************************************/

CREATE FUNCTION tpoint_mgist_compress(internal)
  RETURNS internal
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_compress'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tpoint_mgist_box_options(internal)
  RETURNS void
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_box_options'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tpoint_mgist_query_options(internal)
  RETURNS void
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_query_options'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************/

/* Equisplit */

CREATE FUNCTION tpoint_equisplit(tgeompoint, integer)
  RETURNS geometry
  AS $$ SELECT stbox_collect(_tpoint_equisplit($1, $2)) $$
  LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION _tpoint_equisplit(tgeompoint, integer)
  RETURNS stbox[]
  AS 'MODULE_PATHNAME', 'Tpoint_static_equisplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tpoint_mgist_equisplit(internal, internal, internal)
  RETURNS internal
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_equisplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS mgist_tpoint_equisplit_ops
  FOR TYPE tgeompoint USING mgist AS
  STORAGE stbox,
  -- overlaps
  OPERATOR  3    && (tgeompoint, tstzspan),
  OPERATOR  3    && (tgeompoint, stbox),
  OPERATOR  3    && (tgeompoint, tgeompoint),
  -- nearest approach distance
  OPERATOR  25    |=| (tgeompoint, stbox) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    |=| (tgeompoint, tgeompoint) FOR ORDER BY pg_catalog.float_ops,
  -- functions
  FUNCTION  1  gist_tgeompoint_consistent(internal, tgeompoint, smallint, oid, internal),
  FUNCTION  2  stbox_gist_union(internal, internal),
  FUNCTION  3  tpoint_mgist_compress(internal),
  FUNCTION  5  stbox_gist_penalty(internal, internal, internal),
  FUNCTION  6  stbox_gist_picksplit(internal, internal),
  FUNCTION  7  stbox_gist_same(stbox, stbox, internal),
  FUNCTION  8  stbox_gist_distance(internal, stbox, smallint, oid, internal),
  FUNCTION  10 tpoint_mgist_box_options(internal),
  FUNCTION  12 tpoint_mgist_equisplit(internal, internal, internal);

/******************************************************************************/

/* Mergesplit */

CREATE FUNCTION tpoint_mergesplit(tgeompoint, integer)
  RETURNS geometry
  AS $$ SELECT stbox_collect(_tpoint_mergesplit($1, $2)) $$
  LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION _tpoint_mergesplit(tgeompoint, integer)
  RETURNS stbox[]
  AS 'MODULE_PATHNAME', 'Tpoint_static_mergesplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tpoint_mgist_mergesplit(internal, internal, internal)
  RETURNS internal
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_mergesplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS mgist_tpoint_mergesplit_ops
  FOR TYPE tgeompoint USING mgist AS
  STORAGE stbox,
  -- overlaps
  OPERATOR  3    && (tgeompoint, tstzspan),
  OPERATOR  3    && (tgeompoint, stbox),
  OPERATOR  3    && (tgeompoint, tgeompoint),
  -- nearest approach distance
  OPERATOR  25    |=| (tgeompoint, stbox) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    |=| (tgeompoint, tgeompoint) FOR ORDER BY pg_catalog.float_ops,
  -- functions
  FUNCTION  1  gist_tgeompoint_consistent(internal, tgeompoint, smallint, oid, internal),
  FUNCTION  2  stbox_gist_union(internal, internal),
  FUNCTION  3  tpoint_mgist_compress(internal),
  FUNCTION  5  stbox_gist_penalty(internal, internal, internal),
  FUNCTION  6  stbox_gist_picksplit(internal, internal),
  FUNCTION  7  stbox_gist_same(stbox, stbox, internal),
  FUNCTION  8  stbox_gist_distance(internal, stbox, smallint, oid, internal),
  FUNCTION  10 tpoint_mgist_box_options(internal),
  FUNCTION  12 tpoint_mgist_mergesplit(internal, internal, internal);

/******************************************************************************/

/* Linearsplit */

CREATE FUNCTION tpoint_linearsplit(tgeompoint, float8, float8, float8)
  RETURNS geometry
  AS $$ SELECT stbox_collect(_tpoint_linearsplit($1, $2, $3, $4)) $$
  LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION _tpoint_linearsplit(tgeompoint, float8, float8, float8)
  RETURNS stbox[]
  AS 'MODULE_PATHNAME', 'Tpoint_static_linearsplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tpoint_mgist_linearsplit(internal, internal, internal)
  RETURNS internal
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_linearsplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS mgist_tpoint_linearsplit_ops
  DEFAULT FOR TYPE tgeompoint USING mgist AS
  STORAGE stbox,
  -- overlaps
  OPERATOR  3    && (tgeompoint, tstzspan),
  OPERATOR  3    && (tgeompoint, stbox),
  OPERATOR  3    && (tgeompoint, tgeompoint),
  -- nearest approach distance
  OPERATOR  25    |=| (tgeompoint, stbox) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    |=| (tgeompoint, tgeompoint) FOR ORDER BY pg_catalog.float_ops,
  -- functions
  FUNCTION  1  gist_tgeompoint_consistent(internal, tgeompoint, smallint, oid, internal),
  FUNCTION  2  stbox_gist_union(internal, internal),
  FUNCTION  3  tpoint_mgist_compress(internal),
  FUNCTION  5  stbox_gist_penalty(internal, internal, internal),
  FUNCTION  6  stbox_gist_picksplit(internal, internal),
  FUNCTION  7  stbox_gist_same(stbox, stbox, internal),
  FUNCTION  8  stbox_gist_distance(internal, stbox, smallint, oid, internal),
  FUNCTION  10 tpoint_mgist_query_options(internal),
  FUNCTION  12 tpoint_mgist_linearsplit(internal, internal, internal);

/******************************************************************************/

/* Manualsplit */

CREATE FUNCTION tpoint_manualsplit(tgeompoint, integer)
  RETURNS geometry
  AS $$ SELECT stbox_collect(_tpoint_manualsplit($1, $2)) $$
  LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION _tpoint_manualsplit(tgeompoint, integer)
  RETURNS stbox[]
  AS 'MODULE_PATHNAME', 'Tpoint_static_manualsplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tpoint_mgist_manualsplit(internal, internal, internal)
  RETURNS internal
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_manualsplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS mgist_tpoint_manualsplit_ops
  FOR TYPE tgeompoint USING mgist AS
  STORAGE stbox,
  -- overlaps
  OPERATOR  3    && (tgeompoint, tstzspan),
  OPERATOR  3    && (tgeompoint, stbox),
  OPERATOR  3    && (tgeompoint, tgeompoint),
  -- nearest approach distance
  OPERATOR  25    |=| (tgeompoint, stbox) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    |=| (tgeompoint, tgeompoint) FOR ORDER BY pg_catalog.float_ops,
  -- functions
  FUNCTION  1  gist_tgeompoint_consistent(internal, tgeompoint, smallint, oid, internal),
  FUNCTION  2  stbox_gist_union(internal, internal),
  FUNCTION  3  tpoint_mgist_compress(internal),
  FUNCTION  5  stbox_gist_penalty(internal, internal, internal),
  FUNCTION  6  stbox_gist_picksplit(internal, internal),
  FUNCTION  7  stbox_gist_same(stbox, stbox, internal),
  FUNCTION  8  stbox_gist_distance(internal, stbox, smallint, oid, internal),
  FUNCTION  10 tpoint_mgist_box_options(internal),
  FUNCTION  12 tpoint_mgist_manualsplit(internal, internal, internal);

/******************************************************************************/


/* Adaptive Mergesplit */

CREATE FUNCTION tpoint_adaptivemergesplit(tgeompoint, integer)
  RETURNS geometry
  AS $$ SELECT stbox_collect(_tpoint_adaptivemergesplit($1, $2)) $$
  LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION _tpoint_adaptivemergesplit(tgeompoint, integer)
  RETURNS stbox[]
  AS 'MODULE_PATHNAME', 'Tpoint_static_adaptivemergesplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tpoint_mgist_adaptivemergesplit(internal, internal, internal)
  RETURNS internal
  AS 'MODULE_PATHNAME', 'Tpoint_mgist_adaptivemergesplit'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS mgist_tpoint_adaptivemergesplit_ops
  FOR TYPE tgeompoint USING mgist AS
  STORAGE stbox,
  -- overlaps
  OPERATOR  3    && (tgeompoint, tstzspan),
  OPERATOR  3    && (tgeompoint, stbox),
  OPERATOR  3    && (tgeompoint, tgeompoint),
  -- nearest approach distance
  OPERATOR  25    |=| (tgeompoint, stbox) FOR ORDER BY pg_catalog.float_ops,
  OPERATOR  25    |=| (tgeompoint, tgeompoint) FOR ORDER BY pg_catalog.float_ops,
  -- functions
  FUNCTION  1  gist_tgeompoint_consistent(internal, tgeompoint, smallint, oid, internal),
  FUNCTION  2  stbox_gist_union(internal, internal),
  FUNCTION  3  tpoint_mgist_compress(internal),
  FUNCTION  5  stbox_gist_penalty(internal, internal, internal),
  FUNCTION  6  stbox_gist_picksplit(internal, internal),
  FUNCTION  7  stbox_gist_same(stbox, stbox, internal),
  FUNCTION  8  stbox_gist_distance(internal, stbox, smallint, oid, internal),
  FUNCTION  10 tpoint_mgist_box_options(internal),
  FUNCTION  12 tpoint_mgist_adaptivemergesplit(internal, internal, internal);

/******************************************************************************/