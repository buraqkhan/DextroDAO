pragma solidity ^0.8.1;

contract DAO{
    
    struct Request {
        string suggestion;
        address from;
        uint vote_yes;
        uint vote_no;
        mapping (address => bool) voted;
        uint elapsed_time;
        bool completed;
    }

    mapping (address => bool) stakeholders;
    uint stakeholder_num;
    Request[] requests;

    constructor()  {
    }

    function makeRequest() public returns(uint){
        return 0;
    }




}