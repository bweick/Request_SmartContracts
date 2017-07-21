pragma solidity ^0.4.11;

import './Administrable.sol';

// many pattern from http://solidity.readthedocs.io/en/develop/types.html#structs
contract RequestCore is Administrable{

    // state of an RequestgetSystemState
    enum State { Created, Accepted, Rejected, Paid, Completed, Canceled }

    // What is an Request
    struct Request {
        address seller;
        address buyer;
        uint amountExpected;
        address UntrustedSubContract;
        uint amountPaid;
        uint amountRefunded;
        State state;
    }
    // index of the Request in the mapping
    uint public numRequests; //should be replaced by something else (hash?)

    // mapping of all the Requests
    mapping(uint => Request) public requests;

    // events of request
    event LogRequestCreated(uint requestID, address seller, address buyer);
    event LogRequestAccepted(uint requestID);
    event LogRequestRejected(uint requestID);
    event LogRequestCanceled(uint requestID);
    event LogRequestPayment(uint requestID, uint amountPaid);
    event LogRequestPaid(uint requestID);
    event LogRequestRefunded(uint requestID, uint amountRefunded);
    event LogRequestCompleted(uint requestID);


    // contract constructor
    function RequestCore() Administrable() {
        numRequests = 0;
    }

    // create an Request
    function createRequest(address _sender, address _buyer, uint _amountExpected, address _untrustedSubContract) 
        systemIsWorking 
        returns (uint) 
    {
        uint requestID = numRequests++; // get the current num as ID and increment it
        requests[requestID] = Request(_sender, _buyer, _amountExpected, _untrustedSubContract==0?address(this):_untrustedSubContract, 0, 0, State.Created); // create Request
        LogRequestCreated(requestID, _sender, _buyer); // we "publish" this Request - should we let _buyer here?
        return requestID;
    }

    // the buyer can accept an Request 
    function accept(uint _requestID) 
        systemIsWorking
    {
        Request storage c = requests[_requestID];
        require(c.state==State.Created); // state must be created only
        require(c.UntrustedSubContract==msg.sender); // only subContract can accept
        c.state = State.Accepted;
        LogRequestAccepted(_requestID);
    }
   
    // the buyer can reject an Request
    function reject(uint _requestID)
        systemIsWorking
    {
        Request storage c = requests[_requestID];
        require(c.state==State.Created); // state must be created only
        require(c.UntrustedSubContract==msg.sender); // only subContract can reject
        c.state = State.Rejected;
        LogRequestRejected(_requestID);
    }


    // the seller can Cancel an Request if just creted
    function cancel(uint _requestID)
        systemIsWorking
    {
        Request storage c = requests[_requestID];
        require(c.state==State.Created); // state must be created only
        require(c.UntrustedSubContract==msg.sender); // only subContract can cancel
        c.state = State.Canceled;
        LogRequestCanceled(_requestID);
    }   

    // declare a payment
    function payment(uint _requestID, uint _amount)
        systemIsWorking
    {   
        Request storage c = requests[_requestID];
        require(c.UntrustedSubContract==msg.sender); // only subContract can declare payment
        require(c.state==State.Accepted); // state must be accepted only
        require(_amount > 0 && _amount+c.amountPaid > c.amountPaid && _amount+c.amountPaid <= c.amountExpected); // value must be greater than 0 and all the payments should not overpass the amountExpected

        c.amountPaid += _amount;
        LogRequestPayment(_requestID, _amount);

        if(c.amountPaid == c.amountExpected) {
            c.state = State.Paid;
            LogRequestPaid(_requestID);
        }
    }

    // declare a refund
    function refund(uint _requestID, uint _amount)
        systemIsWorking
    {   
        Request storage c = requests[_requestID];
        require(c.UntrustedSubContract==msg.sender); // only subContract can declare refund
        require(c.state==State.Paid); // state must be paid only
        require(_amount > 0 && _amount+c.amountRefunded > c.amountRefunded && _amount+c.amountRefunded <= c.amountPaid); // value must be greater than 0 and all the payments should not overpass the amountPaid

        c.amountRefunded += _amount;
        LogRequestRefunded(_requestID, _amount);
    }

    function complete(uint _requestID) 
        systemIsWorking
    {
        Request storage c = requests[_requestID];
        require(c.UntrustedSubContract==msg.sender); // only subContract can manage this
        require(c.state==State.Paid); // state must be paid only
        c.state=State.Completed;
        LogRequestCompleted(_requestID);
    }
 
    // request getters
    function getSeller(uint _requestID)
        systemIsWorking
        returns(address)
    {
        return requests[_requestID].seller;
    }
    
    function getBuyer(uint _requestID)
        systemIsWorking
        returns(address)
    {
        return requests[_requestID].buyer;
    }
    
    function getAmountExpected(uint _requestID)
        systemIsWorking
        returns(uint)
    {
        return requests[_requestID].amountExpected;
    }
    
    function getSubContract(uint _requestID)
        systemIsWorking
        returns(address)
    {
        return requests[_requestID].UntrustedSubContract;
    }
    
    function getAmountPaid(uint _requestID)
        systemIsWorking
        returns(uint)
    {
        return requests[_requestID].amountPaid;
    }
      
    function getAmountRefunded(uint _requestID)
        systemIsWorking
        returns(uint)
    {
        return requests[_requestID].amountRefunded;
    }

    function getState(uint _requestID)
        systemIsWorking
        returns(State)
    {
        return requests[_requestID].state;
    }
    
}

