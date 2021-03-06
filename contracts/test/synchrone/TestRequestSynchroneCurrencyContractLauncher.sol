pragma solidity 0.4.18;

import '../../core/RequestCore.sol';
import '../../synchrone/extensions/RequestSynchroneInterface.sol';
import '../../base/math/SafeMath.sol';

contract TestRequestSynchroneCurrencyContractLauncher {
    using SafeMath for uint256;

    uint constant_id;
    mapping(bytes32 => address) extensionAddress;

    // RequestCore object
    RequestCore public requestCore;

    bool createRequestReturn;
    bool acceptReturn;
    bool cancelReturn;
    bool fundOrderReturn;
    bool paymentReturn;
    bool refundReturn;
    bool updateExpectedAmountReturn;


    function TestRequestSynchroneCurrencyContractLauncher (uint _id, uint _requestCoreAddress, bool _createRequest,bool _accept,bool _cancel,bool _fundOrder,bool _payment,bool _refund,bool _updateExpectedAmount) 
        public
    {
        constant_id = _id;

        createRequestReturn = _createRequest;
        acceptReturn = _accept;
        cancelReturn = _cancel;
        fundOrderReturn = _fundOrder;
        paymentReturn = _payment;
        refundReturn = _refund;
        updateExpectedAmountReturn = _updateExpectedAmount;

        requestCore=RequestCore(_requestCoreAddress);
    }

    // Launcher -------------------------------------------------
    function launchCancel(bytes32 _requestId)
        public
    {
        RequestSynchroneInterface extension = RequestSynchroneInterface(extensionAddress[_requestId]);
        extension.cancel(_requestId);
    } 

    function launchAccept(bytes32 _requestId)
        public
    {
        RequestSynchroneInterface extension = RequestSynchroneInterface(extensionAddress[_requestId]);
        extension.accept(_requestId);
    } 

   function launchPayment(bytes32 _requestId, uint _amount)
        public
    {
        RequestSynchroneInterface extension = RequestSynchroneInterface(extensionAddress[_requestId]);
        extension.payment(_requestId,_amount);
    } 

    function launchRefund(bytes32 _requestId, uint _amount)
        public
    {
        RequestSynchroneInterface extension = RequestSynchroneInterface(extensionAddress[_requestId]);
        extension.refund(_requestId,_amount);
    } 

    function launchUpdateExpectedAmount(bytes32 _requestId, int _amount)
        public
    {
        RequestSynchroneInterface extension = RequestSynchroneInterface(extensionAddress[_requestId]);
        extension.updateExpectedAmount(_requestId,_amount);
    } 
    // --------------------------------------------------------

    function createRequest(address _payer, int256 _expectedAmount, address _extension, bytes32[9] _extensionParams, string _data)
        public
        returns(bytes32 requestId)
    {
        requestId= requestCore.createRequest(msg.sender, msg.sender, _payer, _expectedAmount, _extension, _data);

        if(_extension!=0) {
            RequestSynchroneInterface extension0 = RequestSynchroneInterface(_extension);
            extension0.createRequest(requestId, _extensionParams);
            extensionAddress[requestId] = _extension;
        }

        return requestId;
    }

    event LogTestAccept(bytes32 requestId, uint id);
    function accept(bytes32 _requestId) 
        public
        returns(bool)
    {
        LogTestAccept(_requestId, constant_id);
        requestCore.accept(_requestId);
        return acceptReturn;
    } 

    event LogTestCancel(bytes32 requestId, uint id);
    function cancel(bytes32 _requestId)
        public
        returns(bool)
    {
        LogTestCancel(_requestId, constant_id);
        requestCore.cancel(_requestId);
        return cancelReturn;
    } 
 
    event LogTestFundOrder(bytes32 requestId, uint id, address _recipient, uint _amount);
    function fundOrder(bytes32 _requestId, address _recipient, uint _amount) 
        public
        returns(bool)
    {
        LogTestFundOrder(_requestId, constant_id, _recipient, _amount);
        return fundOrderReturn;
    } 

    event LogTestPayment(bytes32 requestId, uint id, uint _amount);
    function payment(bytes32 _requestId, uint _amount) 
        public
        returns(bool)
    {
        LogTestPayment(_requestId, constant_id, _amount);
        requestCore.updateBalance(_requestId,_amount.toInt256Safe());
        return paymentReturn;
    } 

    event LogTestRefund(bytes32 requestId, uint id, uint _amount);
    function refund(bytes32 _requestId, uint _amount) 
        public
        returns(bool)
    {
        LogTestRefund(_requestId, constant_id, _amount);
        requestCore.updateBalance(_requestId,-_amount.toInt256Safe());
        return refundReturn;
    } 

    event LogTestUpdateExpectedAmount(bytes32 requestId, uint id, int _amount);
    function updateExpectedAmount(bytes32 _requestId, int _amount) public returns(bool)
    {
        LogTestUpdateExpectedAmount(_requestId, constant_id, _amount);
        return updateExpectedAmountReturn;
    } 
}

