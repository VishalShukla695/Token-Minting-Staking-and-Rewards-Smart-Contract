pragma solidity ^0.8.0;

contract StakingContract {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) public rewards;

    uint256 public rewardRate = 100; // Adjust the reward rate as per your requirements

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        totalSupply = 0; // Set initial supply to 0
    }

    function mint(uint256 amount) external {
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function stake(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        if (stakingTime[msg.sender] == 0) {
            stakingTime[msg.sender] = block.timestamp;
        } else {
            rewards[msg.sender] += calculateRewards(msg.sender);
            stakingTime[msg.sender] = block.timestamp;
        }

        balanceOf[msg.sender] -= amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(stakingTime[msg.sender] > 0, "No staked amount");

        rewards[msg.sender] += calculateRewards(msg.sender);
        balanceOf[msg.sender] += amount;
        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external {
        require(stakingTime[msg.sender] > 0, "No staked amount");

        uint256 claimableRewards = calculateRewards(msg.sender);
        rewards[msg.sender] = 0;
        emit RewardClaimed(msg.sender, claimableRewards);
    }

    function calculateRewards(address user) internal view returns (uint256) {
        uint256 stakedTime = block.timestamp - stakingTime[user];
        return (balanceOf[user] * rewardRate * stakedTime) / (1 days);
    }
}
