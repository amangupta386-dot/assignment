const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");

const WeeklyGoal = sequelize.define(
  "WeeklyGoal",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, field: "user_id" },
    weekStart: { type: DataTypes.DATEONLY, allowNull: false, field: "week_start" },
    weekEnd: { type: DataTypes.DATEONLY, allowNull: false, field: "week_end" },
    targetProblems: { type: DataTypes.INTEGER, allowNull: false, field: "target_problems" },
    targetRevisions: { type: DataTypes.INTEGER, allowNull: false, field: "target_revisions" },
    focusPatterns: { type: DataTypes.JSONB, allowNull: false, field: "focus_patterns", defaultValue: [] }
  },
  {
    tableName: "weekly_goals",
    underscored: true
  }
);

module.exports = WeeklyGoal;
