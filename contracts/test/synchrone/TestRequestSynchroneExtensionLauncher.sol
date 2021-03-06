pragma solidity 0.4.18;

import '../../synchrone/extensions/RequestSynchroneInterface.sol';

contract TestRequestSynchroneExtensionLauncher is RequestSynchroneInterface {
    
    uint constant_id;
    mapping(bytes32 => address) contractLaunchedAddress;

    bool createRequestReturn;
    bool acceptReturn;
    bool cancelReturn;
    bool fundOrderReturn;
    bool paymentReturn;
    bool refundReturn;
    bool updateExpectedAmountReturn;


    function TestRequestSynchroneExtensionLauncher (uint _id, bool _createRequest,bool _accept,bool _cancel,bool _fundOrder,bool _payment,bool _refund, bool _addUpdateExpectedAmount) 
        public
    {
        constant_id = _id;

        createRequestReturn = _createRequest;
        acceptReturn = _accept;
        cancelReturn = _cancel;
        fundOrderReturn = _fundOrder;
        paymentReturn = _payment;
        refundReturn = _refund;
        updateExpectedAmountReturn = _addUpdateExpectedAmount;
    }

    // Launcher -------------------------------------------------
    function launchCancel(bytes32 _requestId)
        public
    {
        RequestSynchroneInterface currencyContract = RequestSynchroneInterface(contractLaunchedAddress[_requestId]);
        currencyContract.cancel(_requestId);
    } 

    function launchAccept(bytes32 _requestId)
        public
    {
        RequestSynchroneInterface currencyContract = RequestSynchroneInterface(contractLaunchedAddress[_requestId]);
        currencyContract.accept(_requestId);
    } 

    function launchPayment(bytes32 _requestId, uint _amount)
        public
    {
        RequestSynchroneInterface currencyContract = RequestSynchroneInterface(contractLaunchedAddress[_requestId]);
        currencyContract.payment(_requestId,_amount);
    } 

    function launchRefund(bytes32 _requestId, uint _amount)
        public
    {
        RequestSynchroneInterface currencyContract = RequestSynchroneInterface(contractLaunchedAddress[_requestId]);
        currencyContract.refund(_requestId,_amount);
    } 
    
    function launchUpdateExpectedAmount(bytes32 _requestId, int _amount)
        public
    {
        RequestSynchroneInterface currencyContract = RequestSynchroneInterface(contractLaunchedAddress[_requestId]);
        currencyContract.updateExpectedAmount(_requestId,_amount);
    } 
    // --------------------------------------------------------

    event LogTestCreateRequest(bytes32 requestId, uint id, bytes32[9] _params);
    function createRequest(bytes32 _requestId, bytes32[9] _params) public returns(bool) 
    {
        contractLaunchedAddress[_requestId] = msg.sender;
        LogTestCreateRequest(_requestId, constant_id, _params);
        return createRequestReturn;
    }

    event LogTestAccept(bytes32 requestId, uint id);
    function accept(bytes32 _requestId) public returns(bool)
    {
        LogTestAccept(_requestId, constant_id);
        return acceptReturn;
    } 

    event LogTestCancel(bytes32 requestId, uint id);
    function cancel(bytes32 _requestId) public returns(bool)
    {
        LogTestCancel(_requestId, constant_id);
        return cancelReturn;
    } 
 
    event LogTestFundOrder(bytes32 requestId, uint id, address _recipient, uint _amount);
    function fundOrder(bytes32 _requestId, address _recipient, uint _amount) public returns(bool)
    {
        LogTestFundOrder(_requestId, constant_id, _recipient, _amount);
        return fundOrderReturn;
    } 

    event LogTestPayment(bytes32 requestId, uint id, uint _amount);
    function payment(bytes32 _requestId, uint _amount) public returns(bool)
    {
        LogTestPayment(_requestId, constant_id, _amount);
        return paymentReturn;
    } 

    event LogTestRefund(bytes32 requestId, uint id, uint _amount);
    function refund(bytes32 _requestId, uint _amount) public returns(bool)
    {
        LogTestRefund(_requestId, constant_id, _amount);
        return refundReturn;
    } 

    event LogTestUpdateExpectedAmount(bytes32 requestId, uint id, int _amount);
    function updateExpectedAmount(bytes32 _requestId, int _amount) public returns(bool)
    {
        LogTestUpdateExpectedAmount(_requestId, constant_id, _amount);
        return updateExpectedAmountReturn;
    }  
}

