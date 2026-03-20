const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");

const User = sequelize.define(
  "User",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    timezone: { type: DataTypes.STRING, allowNull: false, defaultValue: "Asia/Kolkata" }
  },
  {
    tableName: "users",
    underscored: true
  }
);

module.exports = User;
