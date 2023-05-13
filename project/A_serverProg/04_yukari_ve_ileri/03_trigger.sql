/*markdown
## nedir
- bir DML (`insert`/`update`/`delete`) ya da `truncate` işleminden önce/sonra/o işlem yerine tetiklenebilecek bir fonksiyonu erketeye yatırabiliriz.
- burada bir veri değişikliğinden bahsettiğimize göre bu organizasyonu "veri tutabilen" (tablo/view) şeyler üzerinde yapacağımız da sanırım aşikardır.
- benim muhatap olduğum diğer DBMS'lerde görmediğim güzel bir durum daha var: PG sadece satır bazında değil _statement_ bazında da tetikleme yapabiliyor.
- benden bu kadar :) şaka bi' yana, eğer gerçekten bir uygulama (_dba_ ya da _audit_ işlerini kastetmiyorum) bağlamında `trigger`'a ihtiyacın olduysa benim gibi henüz ihtiyacı olmamış birinden medet umma derim, direkt [kaynağına](https://www.postgresql.org/docs/current/plpgsql-trigger.html) gitmek en mantıklısı. ileride belki bu konuda da atıp tutarım!
*/