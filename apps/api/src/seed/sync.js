const { sequelize } = require("../config/database");
require("../models");

(async () => {
  try {
    await sequelize.sync({ alter: true });
    console.log("Database synced successfully.");
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
})();
