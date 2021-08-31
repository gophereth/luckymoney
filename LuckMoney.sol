pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title LuckyMoneyCreator
 * @dev Implements creating new lucky money envelope
 */
contract LuckyMoneyCreator {
    // storages
    // todo
    mapping(address => address[]) public lucky_money_contracts_by_creator;
    
    constructor(){
      // todo
    }
    
    /**
     * create an instance of lucky money contract and transfer all eth to it
     * @max_participants
     * 
     */
    function create(uint max_participants) external payable 
    returns(bool success) {
        // create the contract and push
        LuckyMoney luck_money = new LuckyMoney{value: msg.value}(max_participants, msg.sender);
        lucky_money_contracts_by_creator[msg.sender].push(address(luck_money));
        success = true;
    }
    
    /**
     * @dev return all LuckyMoney created by the given user
     * 
     */
    function query(address user) external view returns(address[] memory){
        return lucky_money_contracts_by_creator[user];
    }
}

/**
 * 
 * @dev 
 * 
 */
contract LuckyMoney {
    
    address public owner;
    uint public max_participant_addresses;
    address[] public participant_addresses;
    mapping(address => bool) public participated;

    constructor(uint max_participants, address creator) payable {
        max_participant_addresses = max_participants;
        owner = creator;
    }
    
    /**
     * @dev return all participants
     * 
     */
    function participants() external view returns(address[] memory){
        return participant_addresses;
    }
    
    /**
     * @dev anyone can roll and get rewarded a random amount of remnant eth from the contract
     * as long as doesn't exceed max_participants
     * each account can only roll once
     * 
     */
    function roll() external {
        // add participant user to the array
        require(!participated[msg.sender], "already participated in rolling");
        require(participant_addresses.length < max_participant_addresses, "already rolled more than maximum");
        participated[msg.sender] = true;
        participant_addresses.push(msg.sender);

    
        // send random eth to the address - allowed range
        uint256 amount_to_send = random();
        payable(msg.sender).transfer(amount_to_send);
    }
    
    /**
     * @dev generate a random uint
     * 
     */
    function random() private pure returns(uint256){
        // for now use pseudo random
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % address(this).balance;
    }
    
    /**
     * @dev only owner can call
     * refund remant eth and destroy itself
     * 
     */
    function refund() external {
        require(msg.sender == owner, "only owner is allowed for this action");
        selfdestruct(payable(msg.sender));
    }
    
    
}