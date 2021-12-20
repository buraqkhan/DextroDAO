//SPDX-License-Identifier: <SPDX-License> 
pragma solidity ^0.8.1;

interface TokenInterface {
    function checkStakeholder(address addr) external returns (bool);
    function stakeholderCount() external returns (uint256);
}

contract DAO{
    
    event concludeVoting(bool decision, string proposal_desc);

    struct Proposal {
        string desc;
        address from;
        uint vote_yes;
        uint vote_no;
        uint total_votes;
        uint inception_time;
        bool completed;
    }

    TokenInterface DexToken;
    address owner_address;
    uint vote_duration = 3 days;
    uint proposal_cd = 7 days;
    mapping (address => bool) voted;
    address[] public voters;
    Proposal public proposal;

    constructor(address addr)  {
        owner_address = msg.sender;
        setTokenInterface(addr);
        proposal.completed = true;
    }

    modifier checkVoted() {
        require(voted[msg.sender] == false,
                "You have already cast a vote");
        _;
    }

    modifier checkRequirements() {
        require(msg.sender == proposal.from,
            "Can only be approved by proposal maker");
        require(block.timestamp > (proposal.inception_time + vote_duration) || proposal.total_votes == DexToken.stakeholderCount(),
                "3 days haven't passed and everyone hasn't voted yet");
        _;
    }

    function setTokenInterface(address addr) public {
        require(msg.sender == owner_address);
        DexToken = TokenInterface(addr);
    }

    function reset() private{
        for(uint i = 0; i < voters.length; i++){
            voted[voters[i]]  = false;
        }
        delete voters;
    }


    function makeProposal(string memory desc) public {
        require(DexToken.checkStakeholder(msg.sender) == true,
                 "Not a member");
        require(proposal.completed == true,
                "Cannot make new proposal when voting ongoing");
        Proposal memory new_prop = Proposal({
            desc: desc,
            from: msg.sender,
            vote_yes: 0,
            vote_no: 0,
            total_votes: 0,
            inception_time: block.timestamp,
            completed: false
        });
        proposal = new_prop;
    }

    function voteYes() external checkVoted{
        require(DexToken.checkStakeholder(msg.sender) == true,
                 "Not a member");
        proposal.vote_yes++;
        proposal.total_votes++;
        voted[msg.sender] = true;
        voters.push(msg.sender);
    }

    function voteNo() external checkVoted{
        require(DexToken.checkStakeholder(msg.sender) == true,
                "Not a member");
        proposal.vote_no++;
        proposal.total_votes++;
        voted[msg.sender] = true;
        voters.push(msg.sender);
    }

    function finalizeProposal() external checkRequirements returns(bool){
        proposal.completed = true;
        uint vote_percentage = (proposal.vote_yes / proposal.total_votes) * 100;
        reset();
        if ( vote_percentage > 50){
            // emit concludeVoting(true, proposal.desc);
            return true;
        }    
        // emit concludeVoting(false, proposal.desc);
        return false;
    }

}