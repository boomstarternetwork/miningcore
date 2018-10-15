﻿-- TODO: rework indexes

SET role miningcore;

CREATE TABLE projects
(
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE admins
(
  id BIGSERIAL NOT NULL PRIMARY KEY,
  login TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

CREATE INDEX IDX_ADMINS_LOGIN ON admins(login);

CREATE TABLE users
(
  id BIGSERIAL NOT NULL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL DEFAULT '',
  name TEXT NOT NULL
);

CREATE INDEX IDX_USERS_EMAIL ON users(email);

CREATE TABLE user_addresses
(
  userid BIGSERIAL NOT NULL REFERENCES users (id),
  coin TEXT NOT NULL,
  address TEXT NOT NULL,

  CONSTRAINT USER_ADDRESSES_UNIQUENESS UNIQUE (userid, coin, address)
);

CREATE TABLE shares
(
  projectid TEXT NOT NULL REFERENCES projects (id),
  poolid TEXT NOT NULL,
  blockheight BIGINT NOT NULL,
  difficulty DOUBLE PRECISION NOT NULL,
  networkdifficulty DOUBLE PRECISION NOT NULL,
  payoutinfo TEXT NULL,
  miner TEXT NOT NULL,
  worker TEXT NULL,
  useragent TEXT NULL,
  ipaddress TEXT NOT NULL,
  source TEXT NULL,
  created TIMESTAMP NOT NULL
);

CREATE INDEX IDX_SHARES_POOL_MINER ON shares(projectid, poolid, miner);
CREATE INDEX IDX_SHARES_POOL_CREATED ON shares(projectid, poolid, created);
CREATE INDEX IDX_SHARES_POOL_MINER_DIFFICULTY ON shares(projectid, poolid, miner, difficulty);

CREATE TABLE blocks
(
  id BIGSERIAL NOT NULL PRIMARY KEY,
  projectid TEXT NOT NULL REFERENCES projects (id),
  poolid TEXT NOT NULL,
  blockheight BIGINT NOT NULL,
  networkdifficulty DOUBLE PRECISION NOT NULL,
  status TEXT NOT NULL,
  type TEXT NULL,
  confirmationprogress FLOAT NOT NULL DEFAULT 0,
  effort FLOAT NULL,
  transactionconfirmationdata TEXT NOT NULL,
  miner TEXT NULL,
  reward decimal(28,12) NULL,
  source TEXT NULL,
  hash TEXT NULL,
  created TIMESTAMP NOT NULL,

  CONSTRAINT BLOCKS_POOL_HEIGHT UNIQUE (projectid, poolid, blockheight, type) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX IDX_BLOCKS_POOL_BLOCK_STATUS ON blocks(poolid, blockheight, status);

CREATE TABLE balances
(
  projectid TEXT NOT NULL REFERENCES projects (id),
  poolid TEXT NOT NULL,
  coin TEXT NOT NULL,
  address TEXT NOT NULL,
  amount decimal(28,12) NOT NULL DEFAULT 0,
  created TIMESTAMP NOT NULL,
  updated TIMESTAMP NOT NULL,

  PRIMARY KEY(projectid, poolid, address, coin)
);

CREATE TABLE balance_changes
(
  id BIGSERIAL NOT NULL PRIMARY KEY,
  projectid TEXT NOT NULL REFERENCES projects (id),
  poolid TEXT NOT NULL,
  coin TEXT NOT NULL,
  address TEXT NOT NULL,
  amount decimal(28,12) NOT NULL DEFAULT 0,
  usage TEXT NULL,
  created TIMESTAMP NOT NULL
);

CREATE INDEX IDX_BALANCE_CHANGES_POOL_ADDRESS_CREATED ON balance_changes(projectid, poolid, address, created desc);

CREATE TABLE payments
(
  id BIGSERIAL NOT NULL PRIMARY KEY,
  projectid TEXT NOT NULL REFERENCES projects (id),
  poolid TEXT NOT NULL,
  coin TEXT NOT NULL,
  address TEXT NOT NULL,
  amount decimal(28,12) NOT NULL,
  transactionconfirmationdata TEXT NOT NULL,
  created TIMESTAMP NOT NULL
);

CREATE INDEX IDX_PAYMENTS_POOL_COIN_WALLET ON payments(projectid, poolid, coin, address);

CREATE TABLE poolstats
(
  id BIGSERIAL NOT NULL PRIMARY KEY,
  poolid TEXT NOT NULL,
  connectedminers INT NOT NULL DEFAULT 0,
  poolhashrate DOUBLE PRECISION NOT NULL DEFAULT 0,
  sharespersecond DOUBLE PRECISION NOT NULL DEFAULT 0,
  networkhashrate DOUBLE PRECISION NOT NULL DEFAULT 0,
  networkdifficulty DOUBLE PRECISION NOT NULL DEFAULT 0,
  lastnetworkblocktime TIMESTAMP NULL,
  blockheight BIGINT NOT NULL DEFAULT 0,
  connectedpeers INT NOT NULL DEFAULT 0,
  created TIMESTAMP NOT NULL
);

CREATE INDEX IDX_POOLSTATS_POOL_CREATED ON poolstats(poolid, created);
CREATE INDEX IDX_POOLSTATS_POOL_CREATED_HOUR ON poolstats(poolid, date_trunc('hour',created));

CREATE TABLE minerstats
(
  id BIGSERIAL NOT NULL PRIMARY KEY,
  poolid TEXT NOT NULL,
  miner TEXT NOT NULL,
  worker TEXT NOT NULL,
  hashrate DOUBLE PRECISION NOT NULL DEFAULT 0,
  sharespersecond DOUBLE PRECISION NOT NULL DEFAULT 0,
  created TIMESTAMP NOT NULL
);

CREATE INDEX IDX_MINERSTATS_POOL_CREATED ON minerstats(poolid, created);
CREATE INDEX IDX_MINERSTATS_POOL_MINER_CREATED ON minerstats(poolid, miner, created);
CREATE INDEX IDX_MINERSTATS_POOL_MINER_CREATED_HOUR ON minerstats(poolid, miner, date_trunc('hour',created));
CREATE INDEX IDX_MINERSTATS_POOL_MINER_CREATED_DAY ON minerstats(poolid, miner, date_trunc('day',created));
