# MOSAIC-LIFE-Revision
ToDoリストとウィッシュリストをポイントを通して一元管理するiPhone向けアプリです。  
シンプルにフォルダ管理と任意の並べ替えが出来る一行メモとしても使えます。  
ストアに登録していない為、配布が出来ないので機能について以下で説明します。

## 使用の流れ
1. Task画面で達成したい/すべき事と、達成で得られるポイントを設定する  
2. Shop画面で欲しいもの/やりたい事と、実行によって消費するポイントを設定する  
3. Taskを実行する  
4. Taskを実行したらTask画面で実行したタスクをタップしてポイントを獲得する  
5. ポイントが貯まったらShop画面で欲しい物をタップしてポイントを消費  
6. 実際に買う/遊ぶ  
7. 1に戻る  

Shop画面でのポイント設定は単にかかる金額等をそのまま入力すれば良いと思いますが、  
Task画面での適切なポイント設定は使用する当人の持つリソース等によって変わる為一概に提案するのは難しいです。    
自分の場合30分=500pt=500円相当の相場感覚で設定しています。  
好きに使える時間,金/ToDoによって自身を拘束すべき時間、を軸に相場を決めていくとモチベーションが持続しやすいです。

## メイン画面
起動時に表示されます。

<img src="https://github.com/frontalice/MOSAIC-LIFE-Rev2/blob/manage-images/MOSAIC%20LIFE%20Rev2/Assets.xcassets/ScreenShots.imageset/main.jpeg" width="180" height="320">

### ①所持ポイント
現在のポイント数を確認出来ます。

### ②画面遷移ボタン
各Shop, Task画面に飛びます。

### ③アクティビティログ
Shop画面でのポイント消費やTask画面でのポイント獲得などの各アクション毎に逐次記録されます。  
タップする事で直接編集する事も出来ます。  
日付変更時(毎日午前4時に変更)に前日のログが保存され、30日間アーカイブされます。  
過去のログは「ファイル」アプリ内の「このiPhone内」->「MOSAIC LIFE Rev2」フォルダに保存されています。

### ④Shop倍率管理
金銭管理を念頭に、1日のポイント消費を抑制する為の機能です。  
add...欄に数値を入力すると中央ボックスの値に足されていきます。  
総消費額に応じてShop画面での必要ポイントが自動的に2倍、3倍...と増加し、日数が経過すると段々倍率が1倍に戻っていきます。  
現在の倍率は左側の通貨マーク横で確認出来ます。  
通貨マークを直接タップする事で現在倍率を弄る事が出来ますが、現状デバッグ機能扱いになっています。  
倍率の反映はShop画面のチェックボックスボタンでON/OFFの切り替えが出来ます。  
<details>
<summary>詳細ルールについて</summary>
Shop画面の倍率は中央欄の数値によって以下のテーブルを元に決定されます。

Point|Rate|初期ポイント
---|---|---
0~2999|x1.0|0
3000~5999|x1.5|3000
6000~8999|x2.0|6000
9000~11999|x3.0|9000
12000~14999|x4.0|12000
15000~|x5.0|15000

午前4時を跨ぐ度に、数値欄はテーブル上の初期ポイントに初期化されます。  
倍率は2日経過(午前4時を2回跨ぐ)事により一つ下の倍率に下がりますが、  
倍率が再び上がった時点で残り日数は2日にリセットされます。  
想定する使用例としては、「1日に使う金額が3000円超える毎にそれ以上の浪費を抑制したいが、ToDoの頑張り次第では買えるようにしたい」といった感じです。  
</details>

### ⑤所持アイテム管理
各ボタンを押すとダイアログが表示され、各アイテムの所持数を編集できます。  
所持数の変化は③アクティビティログに反映されます。  
所持ポイント等の他のパラメータには互いに影響しないので、  
独自のルールを追加したい場合に適宜使う事を想定しています。

## Task画面

<img src="https://github.com/frontalice/MOSAIC-LIFE-Rev2/blob/manage-images/MOSAIC%20LIFE%20Rev2/Assets.xcassets/ScreenShots.imageset/task.jpeg" width="180" height="320">

+ボタンでタスクの追加、Editボタンでタスクの編集・削除が出来ます。  
その際にタスク毎にカテゴリを設定して整理が出来ます。  
右下のスイッチで獲得倍率を1倍/2倍に切り替え出来ます。  
- 「早起きして済ませたタスクは2倍」等の設定に利用できます。

## Shop画面

<img src="https://github.com/frontalice/MOSAIC-LIFE-Rev2/blob/manage-images/MOSAIC%20LIFE%20Rev2/Assets.xcassets/ScreenShots.imageset/shop.jpeg" width="180" height="320">

使い方はTask画面とほぼ同じです。  
メイン画面の④ショップ倍率管理を使用している場合は現在の倍率がポイントに反映されます。  
右下のチェックボックスの切り替えで倍率反映(黒字)/未反映(水字)の切り替えが出来ます。

## 対応端末
- iPhone SE2
（他端末でのAutoLayoutの動作確認は未実施です。）
- iOS 14以上
（こちらも旧バージョンでのシミュレータ動作確認は未実施です。）

## 開発環境
- XCode 13.4.1
- データベースはCoreDataを使用しています。

## Revisionという呼称について
Revision(改訂)の名の通り、[初版となるアプリ](https://github.com/frontalice/MOSAIC-LIFE)を2021年に制作、機能追加を行っていました。  
機能が増えていく中で、以下の課題がありました。
- 機能が増える事で、各画面のControllerが肥大化していた（いわゆる「FatViewController問題」）
- データ保存はメモリ上にデータを展開するUserDefaultsのみを使っていたので、将来的に画像等の大きなデータを管理するのを想定してデータベースを用いる必要があった
- 実装したものの使っていない機能が各コードに紛れ込んでいたので切り分ける必要があった

以上の課題を解決すべく2022年5月に一から作り直したものがこのアプリになります。  

フォルダ構成は形だけMVCモデルに即したものになっていますが、
- ViewフォルダにController機能が紛れている
- Modelフォルダが単なるCoreData関連ファイル置き場になっていたりORマッパーを活用できていない

と設計上課題が多いです。

## 今後追加したい機能/改善したい機能
- SE2/iOS14以外の端末での動作確認
- 実行し終わったタスクを「実行済み」カテゴリに自動で移動する機能(移動させないタスクを別途設定できる機能も併せて)
- Shop画面でポイント残高が不足しているものをグレーアウトする機能(初版では実装していました)
- カテゴリの任意の並べ替えを容易にする
- デフォルトのカテゴリを設定してカテゴリ設定を強制させないようにする
