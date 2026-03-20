const { Sequelize } = require("sequelize");
const { env } = require("./env");

const requiredPostgresVars = [
  "postgresHost",
  "postgresPort",
  "postgresDb",
  "postgresUser",
  "postgresPassword"
];

for (const key of requiredPostgresVars) {
  if (!env[key]) {
    throw new Error(`Missing required ${key} in .env`);
  }
}

const sequelize = new Sequelize(env.postgresDb, env.postgresUser, env.postgresPassword, {
  host: env.postgresHost,
  port: env.postgresPort,
  dialect: "postgres",
  logging: false
});

module.exports = { sequelize };