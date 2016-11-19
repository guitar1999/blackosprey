CREATE TABLE prediction (
    permanent TEXT,
    prediction TEXT,
    probablity_poor NUMERIC,
    probability_fair NUMERIC,
    probability_good NUMERIC,
    ts TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX prediction_permanent_idx ON prediction USING BTREE (permanent);
