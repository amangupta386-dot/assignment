const { sequelize } = require("../config/database");
const { User, Problem, RevisionProgress } = require("../models");
const { getInitialProgress } = require("../services/revisionEngine");

(async () => {
  try {
    await sequelize.sync();

    const [user] = await User.findOrCreate({
      where: { email: "demo@prepflow.dev" },
      defaults: { name: "Demo User", email: "demo@prepflow.dev", timezone: "Asia/Kolkata" }
    });

    const problem = await Problem.create({
      userId: user.id,
      title: "Majority Element",
      platform: "LEETCODE",
      difficulty: "EASY",
      pattern: "Voting",
      initialStatus: "SOLVED"
    });

    const progress = getInitialProgress(problem.createdAt);
    await RevisionProgress.create({ problemId: problem.id, ...progress });

    console.log("Demo seed inserted.");
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
})();
