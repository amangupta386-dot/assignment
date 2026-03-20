const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");
const { dayTypes } = require("../constants/enums");

const DailyPlan = sequelize.define(
  "DailyPlan",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, field: "user_id" },
    date: { type: DataTypes.DATEONLY, allowNull: false },
    dayType: { type: DataTypes.ENUM(...Object.values(dayTypes)), allowNull: false, field: "day_type" },
    tasks: { type: DataTypes.JSONB, allowNull: false, defaultValue: {} },
    status: { type: DataTypes.STRING, allowNull: false, defaultValue: "PENDING" }
  },
  {
    tableName: "daily_plans",
    underscored: true,
    indexes: [{ unique: true, fields: ["user_id", "date"] }]
  }
);

module.exports = DailyPlan;
