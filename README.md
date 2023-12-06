# Detect readonly transaction!

request spec で実行された SQL を元に、db に対して readonly なコードがないか検知します。  

その example （テストケース）に対して全ての SQL が readonly な場合は `[All readonly]`,  
一部の transaction が readonly な場合は、`[Partial readonly]` の prefix を付けて PR にコメントするようになっています。  
