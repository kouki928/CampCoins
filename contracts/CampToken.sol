// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CampToken is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    // 利用する変数
    AggregatorV3Interface internal ETH_USD;
    AggregatorV3Interface internal USD_JPY;
    mapping(address => uint256) internal token_balances;

    constructor() {
        _disableInitializers();

        /** -----------------------------------------------------------------
    ETH/USD : https://data.chain.link/feeds/ethereum/mainnet/eth-usd
    USD/JPY : https://data.chain.link/feeds/ethereum/mainnet/jpy-usd
    ------------------------------------------------------------------ */
        ETH_USD = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        USD_JPY = AggregatorV3Interface(
            0x8A6af2B75F23831ADc973ce6288e5329F63D86c6
        );
    }

    function initialize(address initialOwner) public initializer {
        __ERC20_init("CampToken", "CTK");
        __ERC20Burnable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // SCの説明を返す
    function description() external view virtual returns (string memory) {
        return
            "CampToken <-> ETH. CampToken is StableCoin that relating ETH <-> JPY";
    }

    // Version を返す
    function version() external view virtual returns (uint256) {
        return 1;
    }

    // todo --impl ETHをCTKに変換
    function Exchange_ETH_to_CTK() public payable {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 amount = (ETH_JPY() * msg.value) / 10 ** 18;
        _mint(msg.sender, amount);
        token_balances[msg.sender] += amount;
    }

    function getReward() external {
        uint256 amount = 500 * 10 ** 18;
        _mint(msg.sender, amount);
        token_balances[msg.sender] += amount;
    }

    function withdraw(uint amount) external virtual {
        require(
            token_balances[msg.sender] >= amount,
            "Amount must always be less than the number of possessions"
        );
        token_balances[msg.sender] -= amount;
        Burn_CTK(msg.sender, amount);
        uint transfer_amount = (JPY_ETH() * amount) / 10 ** 18;
        payable(msg.sender).transfer(transfer_amount);
    }

    // todo --impl 手数料を減らした鋳造量を返す
    function Get_mint_quantity(uint256 deposit) private {}

    // todo --impl 送信された CTK を burnする
    function Burn_CTK(address _sender, uint256 quantity) public {
        _burn(_sender, quantity);
    }

    // 1ETH = 何USD?
    function get_Latest_EU_Price() public pure returns (int) {
        (
            /*uint80 roundID*/, // roundのid、roundidは毎回記録される
            int price, // 最新の価格をint型のpriceに代入
            /*uint startedAt*/, // roundスタートしたタイムスタンプ
            /*uint timeStamp*/, // data更新のタイムスタンプ
            /*uint80 answeredInRound*/ // どのroundで更新されたか
        ) = ETH_USD.latestRoundData();
        return price;
    }

    // 1JPY = 何USD？
    function get_Latest_JU_Price() public pure returns (int) {
        (
            /*uint80 roundID*/, // roundのid、roundidは毎回記録される
            int price, // 最新の価格をint型のpriceに代入
            /*uint startedAt*/, // roundスタートしたタイムスタンプ
            /*uint timeStamp*/, // data更新のタイムスタンプ
            /*uint80 answeredInRound*/ // どのroundで更新されたか
        ) = USD_JPY.latestRoundData();
        return price;
    }

    // 1ETH は何円？
    function ETH_JPY() public pure returns (uint256) {
        int USD_ETH_price = get_Latest_EU_Price();
        int USD_JPY_price = 10 ** 8 / get_Latest_JU_Price();

        uint result = uint(USD_ETH_price) * uint(USD_JPY_price) * 10 ** 10;
        return result;
    }

    function JPY_ETH() public pure returns (uint256) {
        uint ETH_JPY_price = ETH_JPY() / 10 ** 18;
        uint result = 10 ** 18 / ETH_JPY_price;
        return result;
    }
}