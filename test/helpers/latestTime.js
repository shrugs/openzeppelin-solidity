// Returns the time of the last mined block in seconds
async function latestTime () {
  const block = await pweb3.eth.getBlock('latest');
  return block.timestamp;
}

module.exports = {
  latestTime,
};
