# impl list
## CampToken(CTK)
Transfer 可能な Token. 基本的に支払いはこれで行われる。
* ChainLink から ETH <-> JPY を取得する機能
* ETH をユーザーから取得して、レートを基に CTK を転送する機能
  * その際、手数料を取る
  * SC の保持している CTK が変換量以上の時、保有している CTK をユーザーに送信する
* CTK をユーザーから取得して、レートを基に ETH を転送する機能

## CampingGround
キャンプ場用の SC. CTK がここに集まる。Pool 的存在
* 支払はこの SC に集まる
* Check to Earn ユーザーへ報酬を支払う
* 預入金を管理する

## TrustToken(TTK)
Transfer 不可能な Token. 信頼スコアとして付与
* 綺麗に利用して帰る、良質なレビューを書く で付与
* 預入金を回収せず、一定期間 Pool に預けてくれると付与


# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
