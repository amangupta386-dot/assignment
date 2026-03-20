const User = require('./User');
const Problem = require('./Problem');
const RevisionProgress = require('./RevisionProgress');
const RevisionHistory = require('./RevisionHistory');
const WeeklyGoal = require('./WeeklyGoal');
const DailyPlan = require('./DailyPlan');
const DailyLog = require('./DailyLog');

User.hasMany(Problem, { foreignKey: 'userId' });
Problem.belongsTo(User, { foreignKey: 'userId' });

Problem.hasOne(RevisionProgress, { foreignKey: 'problemId' });
RevisionProgress.belongsTo(Problem, { foreignKey: 'problemId' });

Problem.hasMany(RevisionHistory, { foreignKey: 'problemId' });
RevisionHistory.belongsTo(Problem, { foreignKey: 'problemId' });

User.hasMany(WeeklyGoal, { foreignKey: 'userId' });
WeeklyGoal.belongsTo(User, { foreignKey: 'userId' });

User.hasMany(DailyPlan, { foreignKey: 'userId' });
DailyPlan.belongsTo(User, { foreignKey: 'userId' });

User.hasMany(DailyLog, { foreignKey: 'userId' });
DailyLog.belongsTo(User, { foreignKey: 'userId' });

module.exports = {
  User,
  Problem,
  RevisionProgress,
  RevisionHistory,
  WeeklyGoal,
  DailyPlan,
  DailyLog
};
