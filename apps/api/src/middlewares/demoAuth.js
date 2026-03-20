const { User } = require("../models");

let cachedUserId = null;

const demoUser = async (req, _res, next) => {
  try {
    if (!cachedUserId) {
      const [user] = await User.findOrCreate({
        where: { email: "demo@prepflow.dev" },
        defaults: { name: "Demo User", email: "demo@prepflow.dev", timezone: "Asia/Kolkata" }
      });
      cachedUserId = user.id;
    }

    req.user = { id: cachedUserId };
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = { demoUser };
