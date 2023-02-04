//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";

contract FhwsInnovationsContract {
    
    struct Student {
        string kNumber;
        address studentAddress;
        bool voted;
        bytes32 votedInnovationHash;
    }
    struct Innovation {
        bytes32 uniqueInnovationHash;
        uint votingCount;
        Student creator;
        string title;
        string description;
    }

    //owner of smart contract
    address private owner;
    
    //check if innovation process is finished
    bool public innovationProcessFinished;

    //search with registred address for student
    mapping(address => Student) private students;

    //check if student is registred
    mapping(string => bool) private kNumberAlreadyRegistred;

    //get innovations of creator student address
    mapping(address => Innovation[]) private innovationsOfStudent;

    //all created innovations
    Innovation[] private innovations;
    
    string[] private kNumbers;
    address[] private addresses;
    Innovation[] private winner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyWithRegistredStudentAddress {
        require(studentUsesInitialRegistredAddress(), "You need to register yourself with your kNumber or select your registred Wallet!");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can end the innovaton process!");
        _;
    }

    modifier isInnovationProcessFinished {
        require(innovationProcessFinished, "The innovation process is not finished.");
        _;
    }

    function getWinnerOfInnovationProcess() public isInnovationProcessFinished view returns(Innovation[] memory) {
        return winner;
    }

    function getContractOwner() public view returns(address) {
        return owner;
    }

    function endInnovationProcess() public onlyOwner returns(Innovation[] memory)  {
        innovationProcessFinished = true;
        uint winningVoteCount = 0;
        for(uint i=0; i<innovations.length; i++){
            if(innovations[i].votingCount > winningVoteCount) {
                winningVoteCount = innovations[i].votingCount;
            }
        }
         for(uint i=0; i<innovations.length; i++){
            if(innovations[i].votingCount == winningVoteCount) {
                winner.push(innovations[i]);
            }
        }
        console.log("We have a winner!");
        return winner;
    }

    function restartInnovationProcess() public onlyOwner isInnovationProcessFinished {
        innovationProcessFinished = false;
        for(uint i = 0; i<kNumbers.length; i++) {
            delete kNumberAlreadyRegistred[kNumbers[i]];
        }
        for(uint i = 0; i<addresses.length; i++) {
            delete students[addresses[i]];
            delete innovationsOfStudent[addresses[i]];
        }
        delete innovations;
        delete kNumbers;
        delete addresses;
        delete winner;
        console.log("Innovation process restarted!");
    }

    //registration process
    function initialRegistrationOfStudent(string memory _kNumber) public {
        if(!studentAlreadyRegistred(_kNumber)){
            Student memory newStudent = Student ({kNumber: _kNumber, studentAddress: msg.sender, voted: false, votedInnovationHash: ''});
            students[msg.sender] = newStudent;
            kNumberAlreadyRegistred[_kNumber] = true;
            kNumbers.push(_kNumber);
            addresses.push(msg.sender);
            console.log("Student created");
        } else console.log("Student already exists");
    }

    function studentAlreadyRegistred(string memory _kNumber) public view returns(bool){
        return kNumberAlreadyRegistred[_kNumber];
    }

    function studentUsesInitialRegistredAddress() public view returns(bool){
        return students[msg.sender].studentAddress == msg.sender;
    }

    function getKNumberOfStudentAddress() public onlyWithRegistredStudentAddress view returns(string memory) {
        return students[msg.sender].kNumber;
    }

    function getStudent(address studentAddress) public onlyWithRegistredStudentAddress view returns(Student memory) {
        return students[studentAddress];
    }

    function getInnovationsOfStudent(address studentAddress) public onlyWithRegistredStudentAddress view returns(Innovation[] memory){
         return innovationsOfStudent[studentAddress];
    }

    function getAllInnovations() public onlyWithRegistredStudentAddress view returns(Innovation[] memory){
        return innovations;
    }

    //unique hash to identify innovation
     function genereateUniqueHashForInnovation(string memory _title, string memory _description) private onlyWithRegistredStudentAddress view returns(bytes32) {
        return keccak256(abi.encodePacked(block.timestamp, getKNumberOfStudentAddress(), _title, _description));
    }

    function giveStudentsVoteBack(bytes32 _uniqueInnovationHash, uint index) private onlyWithRegistredStudentAddress{
        for(uint z = 0; z< addresses.length; z++){
            if(students[addresses[index]].votedInnovationHash == _uniqueInnovationHash){
                students[addresses[index]].voted = false;
                delete students[addresses[index]].votedInnovationHash;
            } 
        }
    }

    function createInnovation(string memory _title, string memory _description) public onlyWithRegistredStudentAddress { 
        bytes32 _uniqueInnovationHash = genereateUniqueHashForInnovation(_title, _description);
        Innovation memory newInnovation = Innovation ({uniqueInnovationHash: _uniqueInnovationHash, votingCount: 0, creator: getStudent(msg.sender), title: _title, description: _description});
        innovations.push(newInnovation);
        innovationsOfStudent[msg.sender].push(newInnovation);
        console.log("Innovation created");
    }

    function deleteInnovation(bytes32 _uniqueInnovationHash) public onlyWithRegistredStudentAddress {
        uint check = 0;
        for(uint i = 0; i < innovations.length; i++) {
            if(innovations[i].uniqueInnovationHash ==_uniqueInnovationHash){
                giveStudentsVoteBack(_uniqueInnovationHash, i);
                innovations[i]=innovations[innovations.length-1];
                innovations.pop();
                check++;
            }
        }

        for(uint i = 0; i<innovationsOfStudent[msg.sender].length; i++){
            if(innovationsOfStudent[msg.sender][i].uniqueInnovationHash ==_uniqueInnovationHash){
                innovationsOfStudent[msg.sender][i]=innovationsOfStudent[msg.sender][innovationsOfStudent[msg.sender].length-1];
                innovationsOfStudent[msg.sender].pop();
                check++;
            }
        }
        if(check==2) console.log("Innovation deleted");
        else console.log("The innovation with the specified hash does not exist");
    }

    function editInnovation(bytes32 _uniqueInnovationHash, string memory _title, string memory _description) public onlyWithRegistredStudentAddress{
        uint check = 0;
        for(uint i = 0; i < innovations.length; i++) {
            if(innovations[i].uniqueInnovationHash ==_uniqueInnovationHash){
                innovations[i].title = _title;
                innovations[i].description = _description;
                check++;
            }
        }

         for(uint i = 0; i<innovationsOfStudent[msg.sender].length; i++){
            if(innovationsOfStudent[msg.sender][i].uniqueInnovationHash ==_uniqueInnovationHash){
                innovationsOfStudent[msg.sender][i].title = _title;
                innovationsOfStudent[msg.sender][i].description = _description;
                check++;
            }
        }
        if(check==2) console.log("Innovation edited");
        else console.log("The innovation with the specified hash does not exist");
    }

    function vote(bytes32 _uniqueInnovationHash) public onlyWithRegistredStudentAddress{
        if(!students[msg.sender].voted){
            uint check = 0;
            for(uint i = 0; i < innovations.length; i++) {
                if(innovations[i].uniqueInnovationHash ==_uniqueInnovationHash){
                    innovations[i].votingCount++;
                    check++;
                }
            }

            for(uint i = 0; i<innovationsOfStudent[msg.sender].length; i++){
                if(innovationsOfStudent[msg.sender][i].uniqueInnovationHash ==_uniqueInnovationHash){
                    innovationsOfStudent[msg.sender][i].votingCount++;
                    check++;
                }
            }
            students[msg.sender].voted = true;
            students[msg.sender].votedInnovationHash = _uniqueInnovationHash;
            
            if(check==2) console.log("Student voted");
            else console.log("The innovation with the specified hash does not exist");
        } else console.log("Student already voted");
    }

    function unvote(bytes32 _uniqueInnovationHash) public onlyWithRegistredStudentAddress{
        if(students[msg.sender].voted){    
            uint check = 0;
            for(uint i = 0; i < innovations.length; i++) {
                if(innovations[i].uniqueInnovationHash ==_uniqueInnovationHash){
                    innovations[i].votingCount--;
                    check++;
                }
            }
            for(uint i = 0; i<innovationsOfStudent[msg.sender].length; i++){
                if(innovationsOfStudent[msg.sender][i].uniqueInnovationHash ==_uniqueInnovationHash){
                    innovationsOfStudent[msg.sender][i].votingCount--;
                    check++;      
                }
            }
            students[msg.sender].voted = false;
            delete students[msg.sender].votedInnovationHash;
            if(check==2) console.log("Student unvoted");
            else console.log("The innovation with the specified hash does not exist");
        } else console.log("Student already unvoted");
    }
}
