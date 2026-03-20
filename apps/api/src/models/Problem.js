const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");

const Problem = sequelize.define(
  "Problem",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, field: "user_id" },
    title: { type: DataTypes.STRING, allowNull: false },
    platform: { type: DataTypes.STRING, allowNull: false },
    difficulty: { type: DataTypes.STRING, allowNull: false },
    pattern: { type: DataTypes.STRING, allowNull: false },
    initialStatus: { type: DataTypes.STRING, allowNull: false, field: "initial_status", defaultValue: "SOLVED" }
  },
  {
    tableName: "problems",
    underscored: true
  }
);

module.exports = Problem;
