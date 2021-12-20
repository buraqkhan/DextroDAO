//SPDX-License-Identifier: <SPDX-License> 
pragma solidity ^0.8.1;

interface TokenInterface {
    function checkOwners(address addr) external returns (bool);
}

contract DAO{
    
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
    mapping (address => bool) stakeholders;
    address[] public voters;
    uint public stakeholder_num;
    Proposal public proposal;

    constructor(address addr)  {
        owner_address = msg.sender;
        setTokenInterface(addr);
    }

    modifier checkVoted() {
        require(voted[msg.sender] == false,
                "You have already cast a vote");
        _;
    }

    modifier checkRequirements() {
        require(msg.sender == proposal.from,
            "Can only be approved by proposal maker");
        require(block.timestamp > (proposal.inception_time + 3 days) || proposal.total_votes == stakeholder_num,
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
        // return voted[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4];
    }


    function makeProposal(string memory desc) public {
        require(DexToken.checkOwners(msg.sender) == true,
                 "Not a member");
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
        require(stakeholders[msg.sender] == true,
            "Not a member");
        proposal.vote_yes++;
        proposal.total_votes++;
        voted[msg.sender] = true;
        voters.push(msg.sender);
    }

    function voteNo() external checkVoted{
        require(stakeholders[msg.sender] == true,
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
            return true;
        }    
        return false;
        // else {
            // add event
        // }
        // add an event here

        // reset state
        
    }

    // function addvote() public{
        // voters.push(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    // }
}