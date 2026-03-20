const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");

const DailyLog = sequelize.define(
  "DailyLog",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, field: "user_id" },
    date: { type: DataTypes.DATEONLY, allowNull: false },
    problemsSolved: { type: DataTypes.INTEGER, allowNull: false, field: "problems_solved", defaultValue: 0 },
    revisionsDone: { type: DataTypes.INTEGER, allowNull: false, field: "revisions_done", defaultValue: 0 },
    notes: { type: DataTypes.TEXT, allowNull: true }
  },
  {
    tableName: "daily_logs",
    underscored: true,
    indexes: [{ unique: true, fields: ["user_id", "date"] }]
  }
);

module.exports = DailyLog;
