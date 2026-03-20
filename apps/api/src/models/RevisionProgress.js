const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");
const { revisionStages } = require("../constants/enums");

const RevisionProgress = sequelize.define(
  "RevisionProgress",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    problemId: { type: DataTypes.INTEGER, allowNull: false, field: "problem_id", unique: true },
    currentStage: {
      type: DataTypes.ENUM(...Object.values(revisionStages)),
      allowNull: false,
      field: "current_stage",
      defaultValue: revisionStages.REVISE
    },
    nextReviewDate: { type: DataTypes.DATEONLY, allowNull: false, field: "next_review_date" },
    lastCompletedAt: { type: DataTypes.DATE, allowNull: true, field: "last_completed_at" }
  },
  {
    tableName: "revision_progress",
    underscored: true
  }
);

module.exports = RevisionProgress;
