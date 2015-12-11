# pony-pubsub

ponyでpub subっぽい何かを作る奴

http://www.piotrbuda.me/2015/05/implementing-chat-application-with-pony-lang.html
を写経ついでに少し違う内容に書き換えたもの。上記内容が終わったものとしてすすめる。

ponyでちょっとした何かを作るのが初めてなので勘違いが含まれるかもしれないのと、必ずしも最適でない書き方などをしている可能性が在るのに注意。

## 構成

mainでpub, subを作成。serverに登録してpublisherがpublishしたメッセージをsubscriberが受け取ってコンソールに出力する。

## コンストラクタ

始めのうちは`val`を表現するために以下のように、recoverを使っていた。

```
let p1: Publisher val = recover Publisher("niconare", server) end
let p2: Publisher val = recover Publisher("nicolun", server) end
```

これでもよいが2つめのコミットのように`new val create`とすると、
refの代わりにvalが返ってくるので以下のように書くことが出来る。

```
let p1 = Publisher("niconare", server)
let p2 = Publisher("nicolun", server)
```

型アノテーションも消してしまったが、とりあえずrecoverは不要になる。
ここまでで2つめのコミットの内容になった。

## subscriber

Serverで`subscriber.receive(message)`を直接呼ぶと、
Subscriberがクラスなのでブロックする。これは動作が遅いSubscriberが居る場合に致命的なパフォーマンス悪化を招く。
この問題に対処するために、
3つめのコミットのように各々のSubscriberにreceiveさせるためのWorker Actorを作る。
workerはsubscriberにreceiveをdelegateするだけだが、
こうするとServerはSubscriberの受け取る処理の重さにかかわらず速やかに待機状態に戻れる

## publisher

publisher一覧はときどき更新があるが、アプリケーションを止めずにリロードをかけたいことがある。
そこでpublisherのリロード機能をつけるために以下の関数を定義したい。

```
be reload(pubs': List[Publisher val])
```

しかし、actorのbehaviorにはiso, val, tagしか渡すことができない。
なので以下のようにメンバー変数の型修飾子とreloadのシグネチャを変更することで対応したくなる。

```
var pubs: List[Publisher val] val
be reload(pubs': List[Publisher val] val)
```

しかしこうすると以下の`push`操作がうまく行かなくなる。

`be register_publisher(pub: Publisher val) => pubs.push(pub)`

これは`pubs`がmutableな参照であることを要求しているからだ。

このようなvarではあるが安全にmutableなデータを渡したいという際に役立つのが`iso`
のようなmutableを安全に扱うことができる型修飾子だ。
これが4つめのコミットになる。

ここまで来てpublisherがserverに登録されていても何も意味がないことが判明した。
しかたがないので登録されていないpublisherからのpublishは無視する仕様を追加する。
今回はpublishの時点でpublisherリストに載っていない場合はpublishせずに無視するという単純な仕組みにした。

ここで調子に乗ってメンバー変数を`iso`にしてしまったので困ったことになった。

```
var isRegistered = false
for pub in pubs.values() do
  isRegistered = isRegistered or (sender == pub)
end
```

のようなfor文が回せなくなってしまったのだ。

これは`List[A].values()`のreceiverの指定が`box`だからだ。
しかし前述のように`register_publisher`メソッドで、`pubs`を書きかえたいので
valやboxにはできない。

`register_publisher`で受け取るメッセージ`iso`のままにしておき、
メンバー変数を`trn`にすると、この問題は解決できる。
つまり以下の様なコードにすればよい

```
var pubs: List[Publisher val] trn

...

be reload(pubs': List[Publisher val] iso) =>
  pubs = consume pubs'
```

`trn`はwrite uniqueのみを保証するので`iso`と同じ問題は発生しない。
また`trn`ならwriteできるので、`register_publisher`で値を書き換えることも出来る。

ここで、`val`で受け取ってListをまるまるcopyして`ref`にする。という戦略は取らないことに注意したい。
ponyのreference capabilityはこのようなメッセージのコピーをどうやったら安全になくすことができるか？という問題への解決策なので、コピーしてしまうと少しもったいない。

ここまでで5個目のコミットの内容になった。

さて、未登録publisherを弾く機能は出来たが、publishのたびに毎回Listを一巡するのは少々効率が悪い。 そこでSetを使った実装に変更したいと思う。

ponylangのSetの実装を見ると`Set`は`HashSet`の型パラメータをいくつか指定したものになっているようだ。EqutableとHashableな`A`を渡せばSetにしてくれる。 はじめは`Set`でやっていたが、上手く動かなかったので一旦`SetIs`に逃げることにした。これはHashIsという`is` (pointerによる比較)ベースで`hash()`と`eq`を実装してくれている物を使っているらしい。実装はhashfun.ponyにある。

`Set.contains()`的なメソッドが見つからなかったので`Set[A].set(target) < That`のような実装でごまかしている。そこまで悪く無いような気もする。
ここまでで6個目のコミットの内容になる。

いくつか変更してSetIsが出来たのでSetの実装に再チャレンジ。`hash()`は実装しているので`interface Hashable`の要求は答えているのに何故だろうと思ったら`Equitable`は`eq`と共に`ne`も要求するらしい。このくらいは自動で実装してくれても良い気がするが、他にもつっこみどころはたくさんあるので見逃す。
これで7個目のコミットの内容になった。


## ToDo?

debug print packageを使う => masterにはあったけどpony 0.2.1には無かった。
