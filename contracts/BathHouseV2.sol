// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./compound-v2-fork/InterestRateModel.sol";
import "./compound-v2-fork/CErc20Delegator.sol";
import "./compound-v2-fork/Comptroller.sol";
import "./compound-v2-fork/Unitroller.sol";
import "./periphery/BathBuddy.sol";

// G D Em A G/F C Cm Cm6 Am B G7 <- fortissimo
/* 
    @audit-ok incorrect use of NatSpec
    few functions without comments, wrong comments, missing parts of the comments
*/
contract BathHouseV2 {
    /// @notice unitroller's address
    Comptroller public comptroller;
    address public admin;
    // guy who manages BathTokens
    address public proxyAdmin;
    bool private initialized;

    mapping(address => address) private tokenToBathToken;
    mapping(address => address) private bathTokenToBuddy;

    // @audit-ok use indexes
    event BathTokenCreated(address bathToken, address underlying);
    event BuddySpawned(address bathToken, address bathBuddy);

    modifier onlyAdmin() { // @audit-ok use oppen zepplin ownable
        require(msg.sender == admin, "onlyAdmin: !admin"); // @audit [gas] use error
        _;
    }

    // proxy-constructor
    function initialize(address _comptroller, address _pAdmin) external {
        require(!initialized, "BathHouseV2 already initialized!"); // @audit [gas] use error
        comptroller = Comptroller(_comptroller);
        admin = msg.sender;
        proxyAdmin = _pAdmin;

        initialized = true;
    }

    //============================= VIEW =============================

    /// @notice returns the address of any bathToken in the
    /// system based on its corresponding underlying asset
    function getBathTokenFromAsset(
        address asset
    ) public view returns (address) { // @audit-ok can be changed to external since the function is not being used inside the contract
        return tokenToBathToken[asset];
    }

    function whoIsBuddy(
        address bathToken
    ) external view returns (address buddy) {
        buddy = bathTokenToBuddy[bathToken];
    }

    //============================= BATH TOKENS =============================

    /// @notice create new CErc20 based bathToken
    function createBathToken(
        address underlying,
        InterestRateModel interestRateModel,
        uint256 initialExchangeRateMantissa,
        address implementation,
        bytes memory becomeImplementationData
    ) external onlyAdmin {
        // underlying can be used only for one bathToken
        require(
            tokenToBathToken[underlying] == address(0),
            "createBathToken: BATHTOKEN WITH THIS ERC20 EXIST ALDREADY"  // @audit [gas] use error
        );
        require(
            underlying != address(0),
            "createBathToken: UNDERLYING == ADDRESS 0"  // @audit [gas] use error
        );
        require(
            implementation != address(0),
            "createBathToken: IMPLEMENTATION == ADDRESS 0"  // @audit [gas] use error
        );

        // get bathToken metadata that semantically reflects underlying ERC20
        (string memory name, string memory symbol, uint8 decimals) = _bathify(
            underlying
        );

        // BathTokenDelegator
        address bathToken = address(
            new CErc20Delegator(
                underlying,
                comptroller,
                interestRateModel,
                initialExchangeRateMantissa,
                name,
                symbol,
                decimals,
                payable(proxyAdmin),
                implementation,
                becomeImplementationData
            )
        );

        // spawn buddy
        BathBuddy buddy = new BathBuddy();
        buddy.spawnBuddy(admin, bathToken, address(this));

        tokenToBathToken[underlying] = bathToken;
        bathTokenToBuddy[bathToken] = address(buddy);

        emit BathTokenCreated(bathToken, underlying);
        emit BuddySpawned(bathToken, address(buddy));
    }

    /// @notice claim available rewards
    /// across all the pools
    function claimRewards(
        address[] memory buddies,
        address[] memory rewardsTokens
    ) external {
        // claim rewards from comptroller
        comptroller.claimComp(msg.sender);
        // get rewards from bathBuddy
        // @audit-info for its a bad approach ?
        for (uint256 i = 0; i < buddies.length; ++i) { // @audit use unchecked  
            IBathBuddy(buddies[i]).getReward(
                IERC20(rewardsTokens[i]),
                msg.sender
            );
        }
    }

    /// @notice claim rewards from only one BathBuddy
    function getReward(address buddy, address rewardsToken) external {
        IBathBuddy(buddy).getReward(IERC20(rewardsToken), msg.sender);
    }

    //============================= INTERNALS =============================
    // 🛀
    function _bathify(
        address _underlying
    )
        internal
        view
        returns (string memory _name, string memory _symbol, uint8 _decimals)
    {
        require(_underlying != address(0), "_bathify: ADDRESS ZERO");  // @audit [gas] use error

        _name = string.concat("bath", ERC20(_underlying).symbol());
        _symbol = string.concat(_name, "v2");
        _decimals = ERC20(_underlying).decimals();
    }
}
