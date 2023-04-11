/// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.9; // @audit-ok [low] use latest version dont use ^

// Uncomment this line to use console.log
// import "hardhat/console.sol"; // @audit-ok should be removed and comments should follow the same NatSpec pattern

/// @title RubiconMarket.sol
/// @notice Please see the repository for this code at https://github.com/RubiconDeFi/rubicon-protocol-v1;
/// @notice This contract is a derivative work, and spiritual continuation, of the open-source work from Oasis DEX: https://github.com/OasisDEX/oasis

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

/// @notice DSAuth events for authentication schema
contract DSAuthEvents {
    /// event LogSetAuthority(address indexed authority); /// TODO: this event is not used in the contract, remove?
    event LogSetOwner(address indexed owner); // @audit-info this event can be moved to DSAuth class? 
}

/// @notice DSAuth library for setting owner of the contract
/// @dev Provides the auth modifier for authenticated function calls
/*
    @audit-info 
    This Solidity smart contract is a basic authorization contract called DSAuth, 
    which defines a modifier called "auth" that can be applied to any function in the contract. 
    The "auth" modifier checks whether the caller of the function is authorized by calling the 
    "isAuthorized" function, which returns true if the caller is the owner of the contract, and false otherwise. 
    The contract also includes a function called "setOwner" that allows the owner of the 
    contract to set a new owner address.
*/
contract DSAuth is DSAuthEvents {
    address public owner;

    function setOwner(address owner_) external auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    // @audit-info do not use open zepplin ownable lib or change the name to onlyOwner standard 
    // pattern and delete isAutorazied internal function 
    modifier auth() { // @audit-info should be private ?
        require(isAuthorized(msg.sender), "ds-auth-unauthorized"); // @audit [gas] use error
        _;
    }

    function isAuthorized(address src) internal view returns (bool) {
        if (src == owner) { // @audit-info [gas] can use if ternary ?
            return true;
        } else {
            return false;
        }
    }
}

/// @notice DSMath library for safe math without integer overflow/underflow
/*
    @audit-info
    This Solidity smart contract is a library called DSMath, which provides various math functions 
    that can be used by other contracts in the same Ethereum ecosystem. The functions include basic 
    arithmetic operations like addition, subtraction, multiplication, min, and max. It also includes 
    functions for calculating the weighted and regular division of two uint256 values. The contract 
    also defines two constants WAD and RAY that represent 10^18 and 10^27 respectively, and are used 
    in the weighted arithmetic calculations.
*/
contract DSMath { // @audit-info why not use openzepplin safe math lib. The are the same functions ?
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow"); // @audit [gas] use error
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow"); // @audit [gas] use error
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow"); // @audit [gas] use error 
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y; // @audit [gas] use error
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y; // @audit [gas] use error
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y; // @audit [gas] use error
    } 

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y; // @audit [gas] use error
    }

    uint256 constant WAD = 10 ** 18; 
    uint256 constant RAY = 10 ** 27; // @audit-ok move to top of the contract

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD; // @audit-info can use module to divide by 2 ?
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY; // @audit-info can use module to divide by 2 ?
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y; // @audit-info can use module to divide by 2 ?
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y; // @audit-info can use module to divide by 2 ?
    }
}

/// @notice Events contract for logging trade activity on Rubicon Market
/// @dev Provides the key event logs that are used in all core functionality of exchanging on the Rubicon Market
/// @audit-info check if events can be deleted or included
contract EventfulMarket {
    event LogItemUpdate(uint256 id); 

    // @audit-ok should be removed
    /// TODO: double check it is sound logic to kill this event
    /// event LogTrade(
    ///     uint256 pay_amt,
    ///     address indexed pay_gem,
    ///     uint256 buy_amt,
    ///     address indexed buy_gem
    /// );

    // @audit-ok should be removed
    /// event LogMake(
    ///     bytes32 indexed id,
    ///     bytes32 indexed pair,
    ///     address indexed maker,
    ///     ERC20 pay_gem,
    ///     ERC20 buy_gem,
    ///     uint128 pay_amt,
    ///     uint128 buy_amt,
    ///     uint64 timestamp
    /// );

    event emitOffer(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    );

    // @audit-ok should be removed
    /// TODO: double check it is sound logic to kill this event
    /// event LogBump(
    ///     bytes32 indexed id,
    ///     bytes32 indexed pair,
    ///     address indexed maker,
    ///     ERC20 pay_gem,
    ///     ERC20 buy_gem,
    ///     uint128 pay_amt,
    ///     uint128 buy_amt,
    ///     uint64 timestamp
    /// );

    // @audit-ok should be removed
    /// event LogTake(
    ///     bytes32 id,
    ///     bytes32 indexed pair,
    ///     address indexed maker,
    ///     ERC20 pay_gem,
    ///     ERC20 buy_gem,
    ///     address indexed taker,
    ///     uint128 take_amt,
    ///     uint128 give_amt,
    ///     uint64 timestamp
    /// );

    event emitTake(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed taker,
        address maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 take_amt,
        uint128 give_amt
    );

    // @audit-ok should be removed
    /// event LogKill(
    ///     bytes32 indexed id,
    ///     bytes32 indexed pair,
    ///     address indexed maker,
    ///     ERC20 pay_gem,
    ///     ERC20 buy_gem,
    ///     uint128 pay_amt,
    ///     uint128 buy_amt,
    ///     uint64 timestamp
    /// );

    event emitCancel(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    );

    // @audit-ok should be removed
    /// TODO: double check it is sound logic to kill this event
    /// event LogInt(string lol, uint256 input);

    /// event FeeTake(
    ///     bytes32 indexed id,
    ///     bytes32 indexed pair,
    ///     ERC20 asset,
    ///     address indexed taker,
    ///     address feeTo,
    ///     uint256 feeAmt,
    ///     uint64 timestamp
    /// );

    /// TODO: we will need to make sure this emit is included in any taker pay maker scenario
    event emitFee(
        bytes32 indexed id,
        address indexed taker,
        address indexed feeTo,
        bytes32 pair,
        ERC20 asset,
        uint256 feeAmt
    );

    /// event OfferDeleted(bytes32 indexed id);

    event emitDelete(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker
    );
}

/// @notice Core trading logic for ERC-20 pairs, an orderbook, and transacting of tokens
/// @dev This contract holds the core ERC-20 / ERC-20 offer, buy, and cancel logic
/*
    @audit-info
    This is a smart contract called "SimpleMarket" which is used for creating a decentralized exchange (DEX) 
    in the Ethereum network. The contract holds an orderbook that consists of buy and sell offers for 
    different ERC20 tokens. It allows users to buy and sell these tokens by placing an offer in the orderbook,
    and then fulfilling an existing order that matches their needs. The contract has a feeBPS parameter 
    that represents the fees charged by the exchange, and a feeTo parameter that represents the address 
    where these fees are sent. 
    The contract has several functions for creating, canceling, and buying offers from the orderbook.
*/
contract SimpleMarket is EventfulMarket, DSMath {
    // @audit-info check if slots can be optimized
    uint256 public last_offer_id;

    /// @dev The mapping that makes up the core orderbook of the exchange
    mapping(uint256 => OfferInfo) public offers;

    bool locked;

    /// @dev This parameter is in basis points
    uint256 internal feeBPS;

    /// @dev This parameter provides the address to which fees are sent
    address internal feeTo;

    bytes32 internal constant MAKER_FEE_SLOT = keccak256("WOB_MAKER_FEE");

    // @audit-info can be gas optimized ?
    struct OfferInfo {
        uint256 pay_amt;
        ERC20 pay_gem;
        uint256 buy_amt;
        ERC20 buy_gem;
        address recipient;
        uint64 timestamp;
        address owner;
    }

    /// @notice Modifier that insures an order exists and is properly in the orderbook
    modifier can_buy(uint256 id) virtual {
        require(isActive(id)); // @audit-ok should have require description
        _; 
    }

    // /// @notice Modifier that checks the user to make sure they own the offer and its valid before they attempt to cancel it
    modifier can_cancel(uint256 id) virtual {
        require(isActive(id)); // @audit-ok  should have require description
        require( // @audit-ok  should have require description
            (msg.sender == getOwner(id)) || // @audit-ok should split requires
                (msg.sender == getRecipient(id) && getOwner(id) == address(0))
        );
        _;
    }

    modifier can_offer() virtual { // @audit-ok delete modifier there is no validation
        _;
    }

    // @audit-ok use open zepplin reentrancy guard instead 
    modifier synchronized() { 
        require(!locked);  // @audit-ok  should have require description
        locked = true;
        _;
        locked = false;
    }

    /// @notice get makerFee value
    function makerFee() public view returns (uint256) {
        return StorageSlot.getUint256Slot(MAKER_FEE_SLOT).value;
    }

    function isActive(uint256 id) public view returns (bool active) {
        return offers[id].timestamp > 0;
    }

    function getOwner(uint256 id) public view returns (address owner) {
        return offers[id].owner;
    }

    function getRecipient(uint256 id) public view returns (address owner) {
        return offers[id].recipient;
    }

    function getOffer(
        uint256 id
    ) public view returns (uint256, ERC20, uint256, ERC20) {
        OfferInfo memory _offer = offers[id];
        return (_offer.pay_amt, _offer.pay_gem, _offer.buy_amt, _offer.buy_gem);
    }

    /// @notice Below are the main public entrypoints

    // @audit-info function not used anywhere can be deleted
    function bump(bytes32 id_) external can_buy(uint256(id_)) { // @audit-info @why not be uint256 instead of bytes32 
        uint256 id = uint256(id_);
        /// TODO: double check it is sound logic to kill this event
        /// emit LogBump(
        ///     id_,
        ///     keccak256(abi.encodePacked(offers[id].pay_gem, offers[id].buy_gem)),
        ///     offers[id].owner,
        ///     offers[id].pay_gem,
        ///     offers[id].buy_gem,
        ///     uint128(offers[id].pay_amt),
        ///     uint128(offers[id].buy_amt),
        ///     offers[id].timestamp
        /// );
    }

    /// @notice Accept a given `quantity` of an offer. Transfers funds from caller/taker to offer maker, and from market to caller/taker.
    /// @notice The fee for taker trades is paid in this function.
    function buy(
        uint256 id,
        uint256 quantity
    ) public virtual can_buy(id) synchronized returns (bool) {
        OfferInfo memory _offer = offers[id];
        uint256 spend = mul(quantity, _offer.buy_amt) / _offer.pay_amt;

        require(uint128(spend) == spend, "spend is not an int");/// @audit [gas] use error instead of require
        require(uint128(quantity) == quantity, "quantity is not an int");

        ///@dev For backwards semantic compatibility.
        /// @audit [gas] split the ifs 
        if (
            quantity == 0 ||
            spend == 0 ||
            quantity > _offer.pay_amt ||
            spend > _offer.buy_amt
        ) {
            return false;
        }

        /// @audit [gas] copy storage variable to memory
        offers[id].pay_amt = sub(_offer.pay_amt, quantity);
        offers[id].buy_amt = sub(_offer.buy_amt, spend);

        /// @dev Fee logic added on taker trades
        uint256 fee = mul(spend, feeBPS) / 100_000;
        /// @audit [gas] use error
        require(
            _offer.buy_gem.transferFrom(msg.sender, feeTo, fee),
            "Insufficient funds to cover fee"
        );

        // taker pay maker 0_0
        if (makerFee() > 0) { /// @audit [gas] use != 0
            uint256 mFee = mul(spend, makerFee()) / 100_000;

            /// @dev Handle the v1 -> v2 migration case where if owner == address(0) we transfer this fee to _offer.recipient
            if (_offer.owner == address(0) && getRecipient(id) != address(0)) { /// @audit [gas] split ifs
                /// @audit [gas] use error
                require(
                    _offer.buy_gem.transferFrom(
                        msg.sender,
                        _offer.recipient,
                        mFee
                    ),
                    "Insufficient funds to cover fee"
                );
            } else {
                /// @audit [gas] use error
                require(
                    _offer.buy_gem.transferFrom(msg.sender, _offer.owner, mFee),
                    "Insufficient funds to cover fee"
                );
            }

            emit emitFee(
                bytes32(id),
                msg.sender,
                _offer.owner,
                keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
                _offer.buy_gem,
                mFee
            );
        }
        /// @audit [gas] use error
        require(
            _offer.buy_gem.transferFrom(msg.sender, _offer.recipient, spend),
            "_offer.buy_gem.transferFrom(msg.sender, _offer.recipient, spend) failed - check that you can pay the fee"
        );

        /// @audit [gas] use error
        require(
            _offer.pay_gem.transfer(msg.sender, quantity),
            "_offer.pay_gem.transfer(msg.sender, quantity) failed"
        );

        emit LogItemUpdate(id);

        // @audit-ok remove unused log
        /// emit LogTake(
        ///     bytes32(id),
        ///     keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
        ///     _offer.owner,
        ///     _offer.pay_gem,
        ///     _offer.buy_gem,
        ///     msg.sender,
        ///     uint128(quantity),
        ///     uint128(spend),
        ///     uint64(block.timestamp)
        /// );

        emit emitTake(
            bytes32(id),
            keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
            msg.sender,
            _offer.owner,
            _offer.pay_gem,
            _offer.buy_gem,
            uint128(quantity),
            uint128(spend)
        );

        // @audit-ok remove unused log
        /// emit FeeTake(
        ///     bytes32(id),
        ///     keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
        ///     _offer.buy_gem,
        ///     msg.sender,
        ///     feeTo,
        ///     fee,
        ///     uint64(block.timestamp)
        /// );

        emit emitFee(
            bytes32(id),
            msg.sender,
            feeTo,
            keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
            _offer.buy_gem,
            fee
        );

        // @audit-ok remove unused log
        /// TODO: double check it is sound logic to kill this event
        /// emit LogTrade(
        ///     quantity,
        ///     address(_offer.pay_gem),
        ///     spend,
        ///     address(_offer.buy_gem)
        /// );

        if (offers[id].pay_amt == 0) {
            delete offers[id]; /// @audit-info [gas] check if its better to delete or set as 0
            /// emit OfferDeleted(bytes32(id)); // @audit-ok remove unused log

            emit emitDelete(
                bytes32(id),
                keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
                _offer.owner
            );
        }

        return true;
    }

    /// @notice Allows the caller to cancel the offer if it is their own.
    /// @notice This function refunds the offer to the maker.
    function cancel(
        uint256 id
    ) public virtual can_cancel(id) synchronized returns (bool success) { // @audit-ok there is not check for reentrancy
        OfferInfo memory _offer = offers[id];
        delete offers[id]; // @audit-info [gas] delete or set offer to 0 ?

        /// @dev V1 orders after V2 upgrade will point to address(0) in owner
        /// @audit-ok move 
        _offer.owner == address(0) && msg.sender == _offer.recipient
            ? require(_offer.pay_gem.transfer(_offer.recipient, _offer.pay_amt))
            : require(_offer.pay_gem.transfer(_offer.owner, _offer.pay_amt));

        emit LogItemUpdate(id);
        // @audit-ok remove unused event
        /// emit LogKill(
        ///     bytes32(id),
        ///     keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
        ///     _offer.owner,
        ///     _offer.pay_gem,
        ///     _offer.buy_gem,
        ///     uint128(_offer.pay_amt),
        ///     uint128(_offer.buy_amt)
        /// );

        emit emitCancel(
            bytes32(id),
            keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
            _offer.owner,
            _offer.pay_gem,
            _offer.buy_gem,
            uint128(_offer.pay_amt),
            uint128(_offer.buy_amt)
        );

        success = true;
    }

    // @audit-ok missing NatSped description
    function kill(bytes32 id) external virtual { // @audit-info why not uint256 instead of bytes32
        require(cancel(uint256(id)));
    }

    // @audit-ok missing NatSped description
    function make(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    ) external virtual returns (bytes32 id) {
        return
            bytes32(
                offer(
                    pay_amt,
                    pay_gem,
                    buy_amt,
                    buy_gem,
                    msg.sender,
                    msg.sender
                )
            );
    }

    /// @notice Key function to make a new offer. Takes funds from the caller into market escrow.
    function offer(
        uint256 pay_amt,
        ERC20 pay_gem,
        uint256 buy_amt,
        ERC20 buy_gem,
        address owner,
        address recipient
    ) public virtual can_offer synchronized returns (uint256 id) {
        /// @audit [gas] use error
        // @audit-ok should have require description
        require(uint128(pay_amt) == pay_amt); 
        require(uint128(buy_amt) == buy_amt);
        require(pay_amt > 0);
        require(pay_gem != ERC20(address(0))); /// @dev Note, modified from: require(pay_gem != ERC20(0x0)) which compiles in 0.7.6
        require(buy_amt > 0);
        require(buy_gem != ERC20(address(0))); /// @dev Note, modified from: require(buy_gem != ERC20(0x0)) which compiles in 0.7.6
        require(pay_gem != buy_gem);

        OfferInfo memory info;
        info.pay_amt = pay_amt;
        info.pay_gem = pay_gem;
        info.buy_amt = buy_amt;
        info.buy_gem = buy_gem;
        info.recipient = recipient;
        info.owner = owner;
        info.timestamp = uint64(block.timestamp);
        id = _next_id();
        offers[id] = info;

        /// @audit [gas] use error
        require(pay_gem.transferFrom(msg.sender, address(this), pay_amt)); // @audit-ok shoudl have require description

        emit LogItemUpdate(id);

        // @audit-ok remove
        /// emit LogMake(
        ///     bytes32(id),
        ///     keccak256(abi.encodePacked(pay_gem, buy_gem)),
        ///     msg.sender,
        ///     pay_gem,
        ///     buy_gem,
        ///     uint128(pay_amt),
        ///     uint128(buy_amt),
        ///     uint64(block.timestamp)
        /// );

        emit emitOffer(
            bytes32(id),
            keccak256(abi.encodePacked(pay_gem, buy_gem)),
            msg.sender,
            pay_gem,
            buy_gem,
            uint128(pay_amt),
            uint128(buy_amt)
        );
    }

    function take(bytes32 id, uint128 maxTakeAmount) external virtual {
        require(buy(uint256(id), maxTakeAmount));
    }

    function _next_id() internal returns (uint256) {
        last_offer_id++; /// @audit-info [gas] can be unchecked ?
        return last_offer_id;
    }

    // Fee logic
    function getFeeBPS() public view returns (uint256) {
        return feeBPS;
    }

    function calcAmountAfterFee(
        uint256 amount
    ) public view returns (uint256 _amount) {
        require(amount > 0);
        _amount = amount;
        _amount -= mul(amount, feeBPS) / 100_000; /// @audit-ok [low] transform duplicated numberin constant ?

        if (makerFee() > 0) {
            _amount -= mul(amount, makerFee()) / 100_000;
        }
    }
}

/// @notice Expiring market is a Simple Market with a market lifetime.
/// @dev When the close_time has been reached, offers can only be cancelled (offer and buy will throw).
/*
    @audit-info 
    This is a Solidity smart contract called ExpiringMarket which extends from the SimpleMarket contract.
     It allows users to make offers and buy items until the close time is reached. After that, new offers 
     are not allowed and only offers can be canceled. The contract has three modifiers: can_offer, 
     can_buy, and can_cancel which control who can make offers, buy items, and cancel offers respectively. 
     There is also a function called stop which can be called by an authorized user to stop the contract.
 */
contract ExpiringMarket is DSAuth, SimpleMarket {
    bool public stopped;

    /// @dev After close_time has been reached, no new offers are allowed.
    modifier can_offer() override {
        require(!isClosed()); // @audit-ok should have require description 
        _;
    }

    /// @dev After close, no new buys are allowed.
    modifier can_buy(uint256 id) override { // @audit-info why override ?
        require(isActive(id));  // @audit-ok should have require description 
        require(!isClosed());  // @audit-ok should have require description 
        _;
    }

    /// @dev After close, anyone can cancel an offer.
    modifier can_cancel(uint256 id) virtual override { // @audit-info why override ?
        require(isActive(id));  // @audit-ok should have require description 
        // @audit-ok should have require description 
        // @audit-ok split all requires to be more readable
        require(
            (msg.sender == getOwner(id)) ||
                isClosed() ||
                (msg.sender == getRecipient(id) && getOwner(id) == address(0))
        );
        _;
    }

    function isClosed() public pure returns (bool closed) {
        return false;
    }

    function getTime() public view returns (uint64) {
        return uint64(block.timestamp); // @audit-log why use uint64 uint256 will save gas ?
    }

    function stop() external auth {
        stopped = true;
    }
}

contract DSNote {
    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 indexed bar,
        uint256 wad,
        bytes fax
    ) anonymous;

    modifier note() {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue()
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);

        _;
    }
}

contract MatchingEvents {
    // @audit-ok delete unused events
    // @audit-ok add indexed event
    /// event LogBuyEnabled(bool isEnabled); /// TODO: this event is not used in the contract, remove?
    event LogMinSell(address pay_gem, uint256 min_amount);
    /// event LogMatchingEnabled(bool isEnabled); /// TODO: this event is not used in the contract, remove?
    event LogUnsortedOffer(uint256 id);
    event LogSortedOffer(uint256 id);
    /// event LogInsert(address keeper, uint256 id); /// TODO: this event is not used in the contract, remove?
    event LogDelete(address keeper, uint256 id);
    event LogMatch(uint256 id, uint256 amount);
}

/// @notice The core Rubicon Market smart contract
/// @notice This contract is based on the original open-source work done by OasisDEX under the Apache License 2.0
/// @dev This contract inherits the key trading functionality from SimpleMarket
contract RubiconMarket is MatchingEvents, ExpiringMarket, DSNote {
    bool public buyEnabled = true; //buy enabled TODO: review this decision!
    bool public matchingEnabled = true; //true: enable matching,

    /// @dev Below is variable to allow for a proxy-friendly constructor
    bool public initialized;

    /// @dev unused deprecated variable for applying a token distribution on top of a trade
    bool public AqueductDistributionLive;
    /// @dev unused deprecated variable for applying a token distribution of this token on top of a trade
    address public AqueductAddress;

    struct sortInfo {
        uint256 next; //points to id of next higher offer
        uint256 prev; //points to id of previous lower offer
        uint256 delb; //the blocknumber where this entry was marked for delete
    }
    mapping(uint256 => sortInfo) public _rank; //doubly linked lists of sorted offer ids
    mapping(address => mapping(address => uint256)) public _best; //id of the highest offer for a token pair
    mapping(address => mapping(address => uint256)) public _span; //number of offers stored for token pair in sorted orderbook
    mapping(address => uint256) public _dust; //minimum sell amount for a token to avoid dust offers
    mapping(uint256 => uint256) public _near; //next unsorted offer id
    uint256 public _head; //first unsorted offer id
    uint256 public dustId; // id of the latest offer marked as dust

    /// @dev Proxy-safe initialization of storage
    function initialize(address _feeTo) public {
        require(!initialized, "contract is already initialized");
        require(_feeTo != address(0));

        /// @notice The market fee recipient
        feeTo = _feeTo;

        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        /// @notice The starting fee on taker trades in basis points
        feeBPS = 1;

        initialized = true;
        matchingEnabled = true;
        buyEnabled = true;
    }

    // // After close, anyone can cancel an offer
    modifier can_cancel(uint256 id) override {
        // @audit-ok there are multiple duplicated requirements how can be refactored? 
        require(isActive(id), "Offer was deleted or taken, or never existed.");
        require( // @audit-ok split in differents requires with error description
            isClosed() ||
                msg.sender == getOwner(id) ||
                id == dustId ||
                (msg.sender == getRecipient(id) && getOwner(id) == address(0)),
            "Offer can not be cancelled because user is not owner, and market is open, and offer sells required amount of tokens."
        );
        _;
    }

    // ---- Public entrypoints ---- //

    // @audit-info this func is used in 2 contracts can be refactored ?
    function make(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    ) public override returns (bytes32) {
        return
            bytes32(
                offer(
                    pay_amt,
                    pay_gem,
                    buy_amt,
                    buy_gem,
                    msg.sender,
                    msg.sender
                )
            );
    }

    function take(bytes32 id, uint128 maxTakeAmount) public override {
        require(buy(uint256(id), maxTakeAmount));
    }

    function kill(bytes32 id) external override {
        require(cancel(uint256(id)));
    }

    // simplest offer entry-point
    function offer(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //maker (ask) buy how much
        ERC20 buy_gem //maker (ask) buy which token
    ) external can_offer returns (uint256) {
        return
            offer(
                pay_amt,
                pay_gem,
                buy_amt,
                buy_gem,
                0,
                true,
                msg.sender,
                msg.sender
            );
    }

    function offer(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //maker (ask) buy how much
        ERC20 buy_gem, //maker (ask) buy which token
        uint pos, //position to insert offer, 0 should be used if unknown
        bool rounding
    ) external can_offer returns (uint256) {
        return
            offer(
                pay_amt,
                pay_gem,
                buy_amt,
                buy_gem,
                pos,
                rounding,
                msg.sender,
                msg.sender
            );
    }

    // Make a new offer. Takes funds from the caller into market escrow.
    function offer(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //maker (ask) buy how much
        ERC20 buy_gem, //maker (ask) buy which token
        uint256 pos, //position to insert offer, 0 should be used if unknown
        address owner,
        address recipient
    ) external can_offer returns (uint256) {
        return
            offer(
                pay_amt,
                pay_gem,
                buy_amt,
                buy_gem,
                pos,
                true,
                owner,
                recipient
            );
    }

    // @audit-ok functions whti same name
    function offer(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //maker (ask) buy how much
        ERC20 buy_gem, //maker (ask) buy which token
        uint256 pos, //position to insert offer, 0 should be used if unknown
        bool matching, //match "close enough" orders?
        address owner, // owner of the offer
        address recipient // recipient of the offer's fill
    ) public can_offer returns (uint256) {
        require(!locked, "Reentrancy attempt"); // @audit use error
        require(_dust[address(pay_gem)] <= pay_amt); // @audit use error

        /// @dev currently matching is perma-enabled
        // if (matchingEnabled) {
        return
            _matcho(
                pay_amt,
                pay_gem,
                buy_amt,
                buy_gem,
                pos,
                matching,
                owner,
                recipient
            );
        // }
        // return super.offer(pay_amt, pay_gem, buy_amt, buy_gem);
    }

    //Transfers funds from caller to offer maker, and from market to caller.
    function buy(
        uint256 id,
        uint256 amount
    ) public override can_buy(id) returns (bool) {
        require(!locked, "Reentrancy attempt");
        // deduct fee from the input amount here
        amount = calcAmountAfterFee(amount);

        function(uint256, uint256) returns (bool) fn = matchingEnabled
            ? _buys
            : super.buy;

        return fn(id, amount);
    }

    // Cancel an offer. Refunds offer maker.
    function cancel(
        uint256 id
    ) public override can_cancel(id) returns (bool success) {
        require(!locked, "Reentrancy attempt");  // @audit use error
        if (matchingEnabled) {
            if (isOfferSorted(id)) {
                require(_unsort(id));
            } else {
                require(_hide(id), "can't hide");
            }
        }
        return super.cancel(id); //delete the offer.
    }

    // *** Batch Functionality ***
    /// @notice Batch offer functionality - multuple offers in a single transaction
    function batchOffer(
        uint[] calldata payAmts,
        address[] calldata payGems,
        uint[] calldata buyAmts,
        address[] calldata buyGems
    ) external {
        // split in diferrent requires
        require(
            payAmts.length == payGems.length &&
                payAmts.length == buyAmts.length &&
                payAmts.length == buyGems.length,
            "Array lengths do not match"
        );
        // @audit-ok bad approach it can grow exponentialy
        for (uint i = 0; i < payAmts.length; i++) {
            this.offer(
                payAmts[i],
                ERC20(payGems[i]),
                buyAmts[i],
                ERC20(buyGems[i])
            );
        }
    }

    /// @notice Cancel multiple offers in a single transaction
    // @audit-ok bad approach it can grow exponentialy can do the forloop off-chain and then just call cancel ?
    function batchCancel(uint[] calldata ids) external {
        for (uint i = 0; i < ids.length; i++) {
            cancel(ids[i]);
        }
    }

    /// @notice Update outstanding offers to new offers, in a batch, in a single transaction
    // @audit-ok bad approach it can grow exponentialy can do the forloop off-chain and then just call cancel ?
    function batchRequote(
        uint[] calldata ids,
        uint[] calldata payAmts,
        address[] calldata payGems,
        uint[] calldata buyAmts,
        address[] calldata buyGems
    ) external {
        for (uint i = 0; i < ids.length; i++) {
            cancel(ids[i]);
            this.offer(
                payAmts[i],
                ERC20(payGems[i]),
                buyAmts[i],
                ERC20(buyGems[i])
            );
        }
    }

    //deletes _rank [id]
    //  Function should be called by keepers.
    function del_rank(uint256 id) external returns (bool) {
        // @audit-ok require description
        // @audit-ok error statmente
        require(!locked);

        // @audit-ok split the requires
        require(
            !isActive(id) &&
                _rank[id].delb != 0 &&
                _rank[id].delb < block.number - 10
        );
        delete _rank[id];
        emit LogDelete(msg.sender, id);
        return true;
    }

    //set the minimum sell amount for a token
    //    Function is used to avoid "dust offers" that have
    //    very small amount of tokens to sell, and it would
    //    cost more gas to accept the offer, than the value
    //    of tokens received.
    function setMinSell(
        ERC20 pay_gem, //token to assign minimum sell amount to
        uint256 dust //maker (ask) minimum sell amount
    ) external auth note returns (bool) {
        _dust[address(pay_gem)] = dust;
        emit LogMinSell(address(pay_gem), dust);
        return true;
    }

    //returns the minimum sell amount for an offer
    function getMinSell(
        ERC20 pay_gem //token for which minimum sell amount is queried
    ) external view returns (uint256) {
        return _dust[address(pay_gem)];
    }

    //return the best offer for a token pair
    //      the best offer is the lowest one if it's an ask,
    //      and highest one if it's a bid offer
    function getBestOffer(
        ERC20 sell_gem,
        ERC20 buy_gem
    ) public view returns (uint256) {
        return _best[address(sell_gem)][address(buy_gem)];
    }

    //return the next worse offer in the sorted list
    //      the worse offer is the higher one if its an ask,
    //      a lower one if its a bid offer,
    //      and in both cases the newer one if they're equal.
    function getWorseOffer(uint256 id) public view returns (uint256) {
        return _rank[id].prev;
    }

    //return the next better offer in the sorted list
    //      the better offer is in the lower priced one if its an ask,
    //      the next higher priced one if its a bid offer
    //      and in both cases the older one if they're equal.
    function getBetterOffer(uint256 id) external view returns (uint256) {
        return _rank[id].next;
    }

    //return the amount of better offers for a token pair
    function getOfferCount(
        ERC20 sell_gem,
        ERC20 buy_gem
    ) public view returns (uint256) {
        return _span[address(sell_gem)][address(buy_gem)];
    }

    //get the first unsorted offer that was inserted by a contract
    //      Contracts can't calculate the insertion position of their offer because it is not an O(1) operation.
    //      Their offers get put in the unsorted list of offers.
    //      Keepers can calculate the insertion position offchain and pass it to the insert() function to insert
    //      the unsorted offer into the sorted list. Unsorted offers will not be matched, but can be bought with buy().
    function getFirstUnsortedOffer() public view returns (uint256) {
        return _head;
    }

    //get the next unsorted offer
    //      Can be used to cycle through all the unsorted offers.
    function getNextUnsortedOffer(uint256 id) public view returns (uint256) {
        return _near[id];
    }

    function isOfferSorted(uint256 id) public view returns (bool) {
        return
            _rank[id].next != 0 ||
            _rank[id].prev != 0 ||
            _best[address(offers[id].pay_gem)][address(offers[id].buy_gem)] ==
            id;
    }

    function sellAllAmount(
        ERC20 pay_gem,
        uint256 pay_amt,
        ERC20 buy_gem,
        uint256 min_fill_amount
    ) external returns (uint256 fill_amt) {
        require(!locked);

        uint256 offerId;
        // @audit-info to hard to read while its a bad approach ?
        while (pay_amt > 0) {
            //while there is amount to sell
            offerId = getBestOffer(buy_gem, pay_gem); //Get the best offer for the token pair
            require(offerId != 0, "0 offerId"); //Fails if there are not more offers

            // There is a chance that pay_amt is smaller than 1 wei of the other token
            if (
                mul(pay_amt, 1 ether) <
                wdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
            ) {
                break; //We consider that all amount is sold
            }
            if (pay_amt >= offers[offerId].buy_amt) {
                //If amount to sell is higher or equal than current offer amount to buy
                fill_amt = add(fill_amt, offers[offerId].pay_amt); //Add amount bought to acumulator
                pay_amt = sub(pay_amt, offers[offerId].buy_amt); //Decrease amount to sell
                take(bytes32(offerId), uint128(offers[offerId].pay_amt)); //We take the whole offer
            } else {
                // if lower
                uint256 baux = rmul(
                    mul(pay_amt, 10 ** 9),
                    rdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
                ) / 10 ** 9;
                fill_amt = add(fill_amt, baux); //Add amount bought to acumulator
                take(bytes32(offerId), uint128(baux)); //We take the portion of the offer that we need
                pay_amt = 0; //All amount is sold
            }
        }
        require(fill_amt >= min_fill_amount, "min_fill_amount isn't filled");
        fill_amt = calcAmountAfterFee(fill_amt);
    }

    function buyAllAmount(
        ERC20 buy_gem,
        uint256 buy_amt,
        ERC20 pay_gem,
        uint256 max_fill_amount
    ) external returns (uint256 fill_amt) {
        require(!locked);
        uint256 offerId;
        while (buy_amt > 0) { // @audit-info while its a bad appraoch ?
            //Meanwhile there is amount to buy
            offerId = getBestOffer(buy_gem, pay_gem); //Get the best offer for the token pair
            require(offerId != 0, "offerId == 0");

            // There is a chance that buy_amt is smaller than 1 wei of the other token
            if (
                mul(buy_amt, 1 ether) <
                wdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
            ) {
                break; //We consider that all amount is sold // @audit-info what is break ?
            }
            if (buy_amt >= offers[offerId].pay_amt) {
                //If amount to buy is higher or equal than current offer amount to sell
                fill_amt = add(fill_amt, offers[offerId].buy_amt); //Add amount sold to acumulator
                buy_amt = sub(buy_amt, offers[offerId].pay_amt); //Decrease amount to buy
                take(bytes32(offerId), uint128(offers[offerId].pay_amt)); //We take the whole offer
            } else {
                //if lower
                fill_amt = add(
                    fill_amt,
                    rmul(
                        mul(buy_amt, 10 ** 9),
                        rdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
                    ) / 10 ** 9
                ); //Add amount sold to acumulator
                take(bytes32(offerId), uint128(buy_amt)); //We take the portion of the offer that we need
                buy_amt = 0; //All amount is bought
            }
        }
        require(
            fill_amt <= max_fill_amount,
            "fill_amt exceeds max_fill_amount"
        ); // @audit use error statment
        fill_amt = calcAmountAfterFee(fill_amt);
    }

    /// @return fill_amt - fill with fee deducted
    function getBuyAmountWithFee(
        ERC20 buy_gem,
        ERC20 pay_gem,
        uint256 pay_amt
    ) external view returns (uint256 fill_amt) {
        fill_amt = calcAmountAfterFee(getBuyAmount(buy_gem, pay_gem, pay_amt));
    }

    /// @return fill_amt - fill amount without fee!
    function getBuyAmount(
        ERC20 buy_gem,
        ERC20 pay_gem,
        uint256 pay_amt
    ) public view returns (uint256 fill_amt) {
        uint256 offerId = getBestOffer(buy_gem, pay_gem); //Get best offer for the token pair
        while (pay_amt > offers[offerId].buy_amt) { // @audit-info while is a bad approach ?
            fill_amt = add(fill_amt, offers[offerId].pay_amt); //Add amount to buy accumulator
            pay_amt = sub(pay_amt, offers[offerId].buy_amt); //Decrease amount to pay
            if (pay_amt > 0) {
                //If we still need more offers
                offerId = getWorseOffer(offerId); //We look for the next best offer
                require(offerId != 0); //Fails if there are not enough offers to complete
            }
        }
        fill_amt = add(
            fill_amt,
            rmul(
                mul(pay_amt, 10 ** 9),
                rdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
            ) / 10 ** 9
        ); //Add proportional amount of last offer to buy accumulator
    }

    /// @return fill_amt - fill with fee deducted
    function getPayAmountWithFee(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint256 buy_amt
    ) public view returns (uint256 fill_amt) {
        fill_amt = calcAmountAfterFee(getPayAmount(pay_gem, buy_gem, buy_amt));
    }

    function getPayAmount(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint256 buy_amt
    ) public view returns (uint256 fill_amt) {
        uint256 offerId = getBestOffer(buy_gem, pay_gem); //Get best offer for the token pair
        while (buy_amt > offers[offerId].pay_amt) {  // @audit-info while is a bad approach ?
            fill_amt = add(fill_amt, offers[offerId].buy_amt); //Add amount to pay accumulator
            buy_amt = sub(buy_amt, offers[offerId].pay_amt); //Decrease amount to buy
            if (buy_amt > 0) {
                //If we still need more offers
                offerId = getWorseOffer(offerId); //We look for the next best offer
                require(offerId != 0); //Fails if there are not enough offers to complete
            }
        }
        fill_amt = add(
            fill_amt,
            rmul(
                mul(buy_amt, 10 ** 9),
                rdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
            ) / 10 ** 9
        ); //Add proportional amount of last offer to pay accumulator
    }

    // ---- Internal Functions ---- //

    function _buys(uint256 id, uint256 amount) internal returns (bool) {
        require(buyEnabled); // @audit-ok require description and use error statment
        if (amount == offers[id].pay_amt) {
            if (isOfferSorted(id)) {
                //offers[id] must be removed from sorted list because all of it is bought
                _unsort(id);
            } else {
                _hide(id);
            }
        }

        require(super.buy(id, amount)); // @audit-ok require description and use error statment

        // If offer has become dust during buy, we cancel it // @audit [gas] split the ifs
        if (
            isActive(id) &&
            offers[id].pay_amt < _dust[address(offers[id].pay_gem)]
        ) {
            dustId = id; //enable current msg.sender to call cancel(id)
            cancel(id);
        }
        return true;
    }

    //find the id of the next higher offer after offers[id]
    function _find(uint256 id) internal view returns (uint256) {
        require(id > 0);

        address buy_gem = address(offers[id].buy_gem);
        address pay_gem = address(offers[id].pay_gem);
        uint256 top = _best[pay_gem][buy_gem];
        uint256 old_top = 0;

        // Find the larger-than-id order whose successor is less-than-id.
        while (top != 0 && _isPricedLtOrEq(id, top)) { // @audit-info while its a a bad approach ?
            old_top = top;
            top = _rank[top].prev;
        }
        return old_top;
    }

    //find the id of the next higher offer after offers[id]
    function _findpos(uint256 id, uint256 pos) internal view returns (uint256) {
        require(id > 0);

        // Look for an active order.
        while (pos != 0 && !isActive(pos)) {  // @audit-info while its a a bad approach ?
            pos = _rank[pos].prev;
        }

        if (pos == 0) {
            //if we got to the end of list without a single active offer
            return _find(id);
        } else {
            // if we did find a nearby active offer
            // Walk the order book down from there...
            if (_isPricedLtOrEq(id, pos)) {
                uint256 old_pos;

                // Guaranteed to run at least once because of
                // the prior if statements.
                while (pos != 0 && _isPricedLtOrEq(id, pos)) {
                    old_pos = pos;
                    pos = _rank[pos].prev;
                }
                return old_pos;

                // ...or walk it up.
            } else {
                while (pos != 0 && !_isPricedLtOrEq(id, pos)) {
                    pos = _rank[pos].next;
                }
                return pos;
            }
        }
    }

    //return true if offers[low] priced less than or equal to offers[high]
    function _isPricedLtOrEq(
        uint256 low, //lower priced offer's id
        uint256 high //higher priced offer's id
    ) internal view returns (bool) {
        return
            mul(offers[low].buy_amt, offers[high].pay_amt) >=
            mul(offers[high].buy_amt, offers[low].pay_amt);
    }

    //these variables are global only because of solidity local variable limit

    //match offers with taker offer, and execute token transactions
    function _matcho(
        uint256 t_pay_amt, //taker sell how much
        ERC20 t_pay_gem, //taker sell which token
        uint256 t_buy_amt, //taker buy how much
        ERC20 t_buy_gem, //taker buy which token
        uint256 pos, //position id
        bool rounding, //match "close enough" orders?
        address owner,
        address recipient
    ) internal returns (uint256 id) {
        uint256 best_maker_id; //highest maker id
        uint256 t_buy_amt_old; //taker buy how much saved
        uint256 m_buy_amt; //maker offer wants to buy this much token
        uint256 m_pay_amt; //maker offer wants to sell this much token

        // there is at least one offer stored for token pair
        while (_best[address(t_buy_gem)][address(t_pay_gem)] > 0) { // @audit-info while its a a bad approach ?
            best_maker_id = _best[address(t_buy_gem)][address(t_pay_gem)];
            m_buy_amt = offers[best_maker_id].buy_amt;
            m_pay_amt = offers[best_maker_id].pay_amt;

            // Ugly hack to work around rounding errors. Based on the idea that
            // the furthest the amounts can stray from their "true" values is 1.
            // Ergo the worst case has t_pay_amt and m_pay_amt at +1 away from
            // their "correct" values and m_buy_amt and t_buy_amt at -1.
            // Since (c - 1) * (d - 1) > (a + 1) * (b + 1) is equivalent to
            // c * d > a * b + a + b + c + d, we write...
            if (
                mul(m_buy_amt, t_buy_amt) >
                mul(t_pay_amt, m_pay_amt) +
                    (
                        rounding
                            ? m_buy_amt + t_buy_amt + t_pay_amt + m_pay_amt
                            : 0
                    )
            ) {
                break;
            }
            // ^ The `rounding` parameter is a compromise borne of a couple days
            // of discussion.
            buy(best_maker_id, min(m_pay_amt, t_buy_amt));
            emit LogMatch(id, min(m_pay_amt, t_buy_amt));
            t_buy_amt_old = t_buy_amt;
            t_buy_amt = sub(t_buy_amt, min(m_pay_amt, t_buy_amt));
            t_pay_amt = mul(t_buy_amt, t_pay_amt) / t_buy_amt_old;

            if (t_pay_amt == 0 || t_buy_amt == 0) {
                break;
            }
        }

        if (
            t_buy_amt > 0 &&
            t_pay_amt > 0 &&
            t_pay_amt >= _dust[address(t_pay_gem)]
        ) {
            //new offer should be created
            id = super.offer(
                t_pay_amt,
                t_pay_gem,
                t_buy_amt,
                t_buy_gem,
                owner,
                recipient
            );
            //insert offer into the sorted list
            _sort(id, pos);
        }
    }

    // // Make a new offer without putting it in the sorted list.
    // // Takes funds from the caller into market escrow.
    // // Keepers should call insert(id,pos) to put offer in the sorted list.
    // function _offeru(
    //     uint256 pay_amt, //maker (ask) sell how much
    //     ERC20 pay_gem, //maker (ask) sell which token
    //     uint256 buy_amt, //maker (ask) buy how much
    //     ERC20 buy_gem, //maker (ask) buy which token
    //     address owner,
    //     address recipient
    // ) internal returns (uint256 id) {
    //     require(_dust[address(pay_gem)] <= pay_amt);
    //     id = super.offer(pay_amt, pay_gem, buy_amt, buy_gem, owner, recipient);
    //     _near[id] = _head;
    //     _head = id;
    //     emit LogUnsortedOffer(id);
    // }

    //put offer into the sorted list
    function _sort(
        uint256 id, //maker (ask) id
        uint256 pos //position to insert into
    ) internal {
        require(isActive(id));

        ERC20 buy_gem = offers[id].buy_gem;
        ERC20 pay_gem = offers[id].pay_gem;
        uint256 prev_id; //maker (ask) id

        pos = pos == 0 ||
            offers[pos].pay_gem != pay_gem ||
            offers[pos].buy_gem != buy_gem ||
            !isOfferSorted(pos)
            ? _find(id)
            : _findpos(id, pos);

        if (pos != 0) {
            //offers[id] is not the highest offer
            //requirement below is satisfied by statements above
            //require(_isPricedLtOrEq(id, pos));
            prev_id = _rank[pos].prev;
            _rank[pos].prev = id;
            _rank[id].next = pos;
        } else {
            //offers[id] is the highest offer
            prev_id = _best[address(pay_gem)][address(buy_gem)];
            _best[address(pay_gem)][address(buy_gem)] = id;
        }

        if (prev_id != 0) {
            //if lower offer does exist
            //requirement below is satisfied by statements above
            //require(!_isPricedLtOrEq(id, prev_id));
            _rank[prev_id].next = id;
            _rank[id].prev = prev_id;
        }

        _span[address(pay_gem)][address(buy_gem)]++;
        emit LogSortedOffer(id);
    }

    // Remove offer from the sorted list (does not cancel offer)
    function _unsort(
        uint256 id //id of maker (ask) offer to remove from sorted list
    ) internal returns (bool) {
        address buy_gem = address(offers[id].buy_gem);
        address pay_gem = address(offers[id].pay_gem);
        require(_span[pay_gem][buy_gem] > 0);

        require(
            _rank[id].delb == 0 && //assert id is in the sorted list
                isOfferSorted(id)
        );

        if (id != _best[pay_gem][buy_gem]) {
            // offers[id] is not the highest offer
            require(_rank[_rank[id].next].prev == id);
            _rank[_rank[id].next].prev = _rank[id].prev;
        } else {
            //offers[id] is the highest offer
            _best[pay_gem][buy_gem] = _rank[id].prev;
        }

        if (_rank[id].prev != 0) {
            //offers[id] is not the lowest offer
            require(_rank[_rank[id].prev].next == id);
            _rank[_rank[id].prev].next = _rank[id].next;
        }

        _span[pay_gem][buy_gem]--;
        _rank[id].delb = block.number; //mark _rank[id] for deletion
        return true;
    }

    //Hide offer from the unsorted order book (does not cancel offer)
    function _hide(
        uint256 id //id of maker offer to remove from unsorted list
    ) internal returns (bool) {
        uint256 uid = _head; //id of an offer in unsorted offers list
        uint256 pre = uid; //id of previous offer in unsorted offers list

        require(!isOfferSorted(id), "offer sorted"); //make sure offer id is not in sorted offers list

        if (_head == id) {
            //check if offer is first offer in unsorted offers list
            _head = _near[id]; //set head to new first unsorted offer
            _near[id] = 0; //delete order from unsorted order list
            return true;
        }
        while (uid > 0 && uid != id) {
            //find offer in unsorted order list
            pre = uid;
            uid = _near[uid];
        }
        if (uid != id) {
            //did not find offer id in unsorted offers list
            return false;
        }
        _near[pre] = _near[id]; //set previous unsorted offer to point to offer after offer id
        _near[id] = 0; //delete order from unsorted order list
        return true;
    }

    function setFeeBPS(uint256 _newFeeBPS) external auth returns (bool) {
        feeBPS = _newFeeBPS;
        return true;
    }

    function setMakerFee(uint256 _newMakerFee) external auth returns (bool) {
        StorageSlot.getUint256Slot(MAKER_FEE_SLOT).value = _newMakerFee;
        return true;
    }

    function setFeeTo(address newFeeTo) external auth returns (bool) {
        require(newFeeTo != address(0));
        feeTo = newFeeTo;
        return true;
    }

    function getFeeTo() external view returns (address) {
        return feeTo;
    }
}
