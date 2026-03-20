const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");

const RevisionHistory = sequelize.define(
  "RevisionHistory",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    problemId: { type: DataTypes.INTEGER, allowNull: false, field: "problem_id" },
    stage: { type: DataTypes.STRING, allowNull: false },
    action: { type: DataTypes.STRING, allowNull: false },
    result: { type: DataTypes.STRING, allowNull: false },
    performedAt: { type: DataTypes.DATE, allowNull: false, field: "performed_at", defaultValue: DataTypes.NOW },
    notes: { type: DataTypes.TEXT, allowNull: true }
  },
  {
    tableName: "revision_history",
    underscored: true,
    createdAt: false,
    updatedAt: false
  }
);

module.exports = RevisionHistory;
