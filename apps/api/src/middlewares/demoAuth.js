const demoUser = (req, _res, next) => {
  req.user = { id: 1 };
  next();
};

module.exports = { demoUser };
