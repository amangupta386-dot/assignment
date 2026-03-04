const { v4: uuidv4 } = require("uuid");

const getCorrelationId = (header) => header || uuidv4();

module.exports = { getCorrelationId };
