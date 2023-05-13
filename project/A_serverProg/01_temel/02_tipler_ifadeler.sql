/*markdown
## anlat
- detayına burada girmeyeceğimiz bi' sürü SQL veri tipini (veya bunların _alias_'larını) kullanabilirsin, [detaylar](https://www.postgresql.org/docs/current/datatype.html).
- yine detayına girmeyeceğiz ama bilsen (yani araştırsan) fena olmaz: kendi veri tipini tanımlayıp kullanabilirsin. o ile başlayıp kıl ile biten bir DBMS sayesinde bu konuda yeteri kadar nahoş anı biriktirdiğim için hiç bakasım yok.
- `record` ve `rowtype` gibi programlama için işimize yarayacak şeyleri sırası geldiğinde örnek içinde kullanacağız: mesela [burada](../02_kontrol/01_return.sql) ve [burada](../02_kontrol/0402_loop_sorgu.sql).
- tüm değişkenleri `declare` altında "deklare" etmen lazım, istisnası `for` içinde [tanımlananlar](../02_kontrol/0401_loop_genel.sql).
- tipler arası geçişi (özellikle sayılarda) bilmek (ve lazımsa kullanmak) faydalı; PG _polymorphism_ konusunda yetenekli.
- `alias` ile parametrelere (ve/veya değişkenlere) farklı isim verebilirsin, ssüüprriiz seven bir ortamda değilsen yapma!
- `%type` ile tip tanımını araklayabilirsin; mesela `soyad public.actor.last_name%type` ile tanımladığın değişkenin uzunluğu ilgili sütunla aynı olacağı için `%type` kullanımının ruh sağlığına acayip faydası var(mış) (. ile nasıl gezinebildiğini fark ettin umarım: `public` şema, `actor` tablo ve `last_name` de sütun adı).
- `constant` ile tanımlanan değişken(!) sabit ;) olur: sadece deklare (_init_) anında değer atanır; sonra değişemez. 
- `default` ya da `:=` (çok istersen `=` de olur) ile atama yapılabilir.
- `expression` konusuna burada girmeyeceğiz ama `plpgsql` içinde ifadelerin [ne ifade ettiğine](https://www.postgresql.org/docs/current/plpgsql-expressions.html) bakmak ufuk açabilir.
- `perform` bir sorgu/ifadeyi çalıştırmak isteyip sonucu istemediğimizde kullanacağımız bir şey. 
- obje içinde (_body_'de) sorgu (`select` ya da mesela DML + `returning` olabilir) sonuçları ile 2 durum var:
  - tek satır: `into` ile kendi başına iken tek satır gelmese de sesi çıkmaz. `strict` ile kullanıldığında tek satır olmazsa yıkar ortalığı.
  - çok satır: `execute` ile, [burada](../02_kontrol/0402_loop_sorgu.sql) `for loop` içinde kullandık.
- obje içindeki sorguya dair bir sürü _diagnostic_ değeri alınabilir, [detaylar](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS).
- boş yapmanın PG'deki karşılığı `null;` (biraz erken oldu ama sayesinde _exception_ işine de girdik).
*/

/*markdown
## örnek declare:
*/

create or replace function ornek_declare(s1 anycompatible, s2 anycompatible, s3 anycompatible)
returns anycompatible 
language plpgsql
as $$
declare
  sonuc alias for $0;
  bir_sayi public.actor.actor_id%type default 43;
  bir_url varchar := 'http://example.com';
  bu_bir_sabit constant timestamp with time zone = now();
  buna_atanacak_deger_kalmadi varchar;
begin
  bir_sayi := s1 + s2;
  -- ya da böyle de atayabiliriz:
  select s1 + s2 into bir_sayi;
  sonuc := (s1 + s2) / s3;
  return sonuc;
exception when division_by_zero then
  null;
end;
$$;

/*markdown
### hemen bakalım:
- `anycompatible` tipine dikkat: bu tip ile değer alıp bu tiple değer dönüyoruz; PG [burada](https://www.postgresql.org/docs/current/typeconv.html) anlatılan şekilde dönüşümleri hallediyor.
- `%type` ile bir değişken tanımladık ve bunun değerini programın akışı içinde değiştirdik. yalnız bu yaptığımız tehlikeli bir karışım oldu: gelen tip polimorfik (çağıran ne gönderirse onu kabul edeceğiz), değişkenin tipi konusunda da dışa bağlıyız; (diyelim ki buradaki gibi sayı tipleri üzerinde tepiniyoruz) boyut (iki 8 byte'lık sayıyı toplayıp 4 byte'a yazmak) ya da ondalık (iki `float` toplayıp `int`'e yazmak gibi) uyuşmazlığından kendi kalemize gol atabiliriz. (PG bu konuda nasıl davranıyor bakmadım ama) PG ister durdursun ister değerleri yakın yaklaşık alıp durumu kurtarmaya çalışsın yazdığımız kodun doğru/yanlış çalışma özelliği (gelen parametre ya da tablodaki tipin durumuna göre) şık bir şekilde indeterministik oldu :(.
- `$0`'a `alias` verip `sonuc` adıyla kullandık.
- bir sürü değişken deklare edip hemen ardından değerlerini atadık, atayamadığımız da oldu. ben olsam `bu_bir_sabit` isimli değişkene `begin`/`end;` arasında atama yapmayı bir denerdim.
- "sayıyı sıfıra bölmeyin ağlarım bak" hatasını "yakaladık" (hata jimnastiği konusu ileride) ve PG'ye bu durumda boş yapmasını söyledik ve böylece yeni bir hata ürettik: detayı [burada](../02_kontrol/0301_cond_if.sql).
*/

select ornek_declare(4.3, 2, 1);


select ornek_declare(3.2, 1, 0);

/*markdown
## örnek perform / select into:
*/

create or replace function ornek_into(satir_adet int)
returns int
language plpgsql
as $$
declare
sonuc int;
begin
  --bu fonksiyon (mesela) bir satır insert edip geriye bu satıra dair bir bilgi dönebilirdi
  --ve biz sadece insert edip o bilgiyi dikkate almak istemiyorsak perform yapabilirdik, ki yapıyoruz:
  perform (select ornek_declare(1,2,3));
  --satir_adet 1 gelirse sorun yok ama > 1 gelirse STRICT nedeniyle hata verecek.
  select t.actor_id into strict sonuc
  from public.actor t
  limit satir_adet;
  return sonuc;
end;
$$;

/*markdown
### buna da hemen bakalım:
- `perform` kullandık ve sorumlu davranıp niye böyle yaptığımızı _comment_'ledik.
- `into strict` kullandığımız için 1 satır istendiğinde sorun yok ama fazlası için sandalyeler havada uçuşacak.
- `limit` ifadesiyle ne yaptığımız aşikardır sanırım. bunu `order by` ile birleştirirsek ne olur onu merak ediyorum ben; sence n'olur? (tablonun doğal bir sırası var mıdır, order by limit'ten önce çalışırsa n'olur, sonra çalışırsa n'olur gibi egzersizlerle ilişkisel veri tabanı kaslarınızı güçlendirin!)
*/

select ornek_into(1);

select ornek_into(2);

/*markdown
## etrafı temizleyelim:
*/

drop function if exists ornek_declare;
drop function if exists ornek_into;