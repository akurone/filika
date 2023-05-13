/*markdown
## mesafeyi korumakta fayda var
`cursor` bir sorguyu <u>tekten</u> değil <u>satır satır</u> işleme imkânı vermekle çok kullanışlı bi'şey ama ben (evet, kişisel tercihimi dikte etmeye çalışıyorum) <u>küme</u> olarak yapılabilecek işlerin küme olarak kalmasını tercih ediyorum. iki neden sayabilirim hemen:
- zaten küme operasyonlarını yapmak üzere donatılmış deli gibi bir _optimizer_ var, kullan onu!
- zihin kümeden uzaklaşıp satıra yaklaştıkça DB'de yapılmaması gereken işleri DB'de yapmaya meyyal oluyor: satır satır yapılması gereken işlem muhtemelen bir üst (uygulama) katmandan sekerek gelmiş olabilir. tabi bunun makul ve mantıklı istisnaları da olabilir de; sırf yapabiliyoruz diye DB'den web servis çağırmayın be arkadaş!
neyse, propagandaya son verip tarife başlayalım:
- değişkendir kendisi, deklare edilir:
```sql
declare
  c1 refcursor;
  c2 no scroll cursor for select * from public.actor;
  c3 scroll cursor (id int) for select * from public.actor where actor_id = id;
```
- yukarıdaki tüm örnek değişkenlerin tipi `refcursor`; c1 herhangi (illa ve sadece) **bir** sorgu (`select` olmak zorunda değil) ile çalışabilir (_unbound_). diğerlerinin sorguları var yani _bound_, ayrıca c3 parametrik.
- c2 sadece ileri doğru hareket ederken c3 ileri/geri hareket edebilir (`scroll` ve [_for update/share_](https://www.postgresql.org/docs/current/plpgsql-cursors.html) opsiyonları birlikte kullanılamıyor), gerçekten ihtiyaç yoksa zaten `scroll` etme derim ama, "alıcam fıstığı, vurucam kırbacı" diyorsan dükkan senin...
- ahanda [burada](../02_kontrol/0402_loop_sorgu.sql) biraz antrenman yapmıştık, dolayısıyla burada genel _syntax_ talimi yapacağız.
### `open`: _unbound_
yukarıdaki c1 kursörü _unbound_ demiştik, açalım onu hadi:
```sql
open c1 no scroll for select * from public.actor; --illa scroll edeceksek scroll dememize gerek var mı?
```
elimizdeki sql de dinamik oluşacak diyelim, -kaçıranlar ve yeniden izlemek isteyenler için- [ahanda buradaki](../02_kontrol/0402_loop_sorgu.sql) uçuk örnekten:
```sql
open c1 no scroll for execute 'select t.first_name, t.last_name from public.actor t limit $1' using 3;
```
oradaki kullanımla bunun arasında biraz fark var (format kullanımından bahsetmiyorum: orada bir kursör deklare etmedik nasıl oluyor da ikisini karşılaştırabiliyoruz?); hangisini tercih etsek bize ne faydası olur aranızda tartışın bakalım!
### `open`: _bound_
fantastik bi'şey yok zaten deklerasyon anında çoğu şeyi hallettik, sadece açması kaldı:
```sql
open c2;
open c3(5); --ya da open c3(id := 5);
```
### `fetch`
- açtığımız kursörleri vitrine koymayacaksak kullanmamız lazım ki [buradaki](https://www.postgresql.org/docs/current/plpgsql-cursors.html) bahsi pareto pragmatizmiyle güdük edip sadece `fetch`'e bakacağız:
```SQL
fetch c2 into degisken_2;
fetch relative -3 from c3 into degisken_3;
```
- burada `degisken_2` ve `degisken_3` için gerekli tip nedir güzel bir antrenman olabilir.
- gördüğünüz gibi `c3`'ü tanımda verdiğimiz `scroll` edebilme özelliğini kullanarak _vahşi_ bir şekilde `fetch` ettik. pratikte pek bir karşılığı olmasa da "adam illa kendi tercihini satıyo'" denmesin diye ekledim:). bir veri kümesine satır satır erişmek istiyorsak zaten orada bir `loop`'a ihtiyacımız olacak; `loop` içinde de mehter gösterisi yapmıyorsak 1 ileri 2 geri gitmenin değerini bulabilirseniz bana da anlatın.
- bu arada böyle bir ihtiyaç yok demiyorum; bu ihtiyacı _küme_ yetenekleri içinde kalarak muhtemelen çözebilirsin diyorum (mesela [analitik(/_window_)](https://www.postgresql.org/docs/15/tutorial-window.html) fonksiyonlar dünyamızı daha güzel bir yer yapabilir!).
### `close`
efendi gibi açtığımız kursörleri kapatmadan çıkmıyoruz:
```sql
close c2;
close c3;
```
sen kapatmasan da `transaction` (`transaction` dışında kullanırsam n'olcak diyebilirsin; güzel bi' soru araştır bakalım derim) bitmeden açık kursörler kapatılır, yani imkanın varsa, kursörü dışarı bir yere göndermiyorsan efendi gibi kapat işte.
### diğer meseleler
#### `for`
yukarıda bahsettik: temel kullanım senaryosu bir döngü ile olduğu için `for` ifadesinin özel bir varyantı ile 3ü1arada yapabiliyorsun, [ahanda](../02_kontrol/0402_loop_sorgu.sql).
#### `return`
[burada](../02_kontrol/01_return.sql) bahsetmedik ama bir fonksiyondan geriye kursör dönebilirsin. geriye `refcursor` tipinde bir _scalar_ değer dönüyorsun, sihirli bi'şey yok yani.
*/