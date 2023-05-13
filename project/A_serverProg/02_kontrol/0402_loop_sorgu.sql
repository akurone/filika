/*markdown
## basit başlayalım:
- nedense _actor_ tablosundaki tüm satırlar için ad ve soyad uzunluklarını toplamak istiyoruz.
- istediğimiz sütunlar için birer tane veri tipi uygun değişken tanımladık.
- `for` ve `loop` arasında tesisatı nasıl hazırladığımızı görebilirsin.
*/

create or replace function ornek_loop_statik()
returns integer
language plpgsql
as $$
declare
  ad varchar;
  soyad varchar;
  sonuc int := 0;
begin
  for ad, soyad in select t.first_name, t.last_name from public.actor t
  loop
    sonuc := sonuc + length(ad) + length(soyad);
  end loop;
  return sonuc;
end;
$$;

select sum(length(t.first_name) + length(t.last_name)) "bu varken" from public.actor t;
select ornek_loop_statik() "neden bunu kullanasın?";

/*markdown
## hadi biraz uçalım:
- ad, soyad gibi değişkenler kullanmak istemiyorum, onun için `aktor_satiri public.actor%rowtype` şeklinde _actor_ tablosunun bir satırını temsil edebilen bir **tek** değişken tanımlayabilirim,
- ama onu da istemiyorum `select` arkasında hangi sütunların sorguda çalışacağına çağıran karar versin (neden olmasın) istiyorum, dolayısıyla şekli belirli bir satır yok elimde; o zaman ne yapıyoruz? `record` tipine aşina oluyoruz (bu arkadaş anonim bir `rowtype` gibi davranıyor).
sırf örnek zengin olsun diye uydurduğum bu histerik isteri evde yalnız başına uygulamayacak kadar aklı selimsen, biri söylemeden aşağıdaki hususlara da dikkat edersin:
  - _string_ `format`'lama ve bu iş için _token_ kullanımı (`%1$s`) 
  - _string_ olarak verilen komutu çalıştıran `execute` ve bu komut içindeki parametrelere `using` ile değer atama
*/

create or replace function ornek_loop_dinamik(sutunlar varchar, kacSatir int = 500)
returns int
language plpgsql
as $$
declare
  satir record;
  --örnek zengin olsun diye yaptığımız bu gösterinin 
  --neden goto'dan daha tehlikeli olduğunu aranızda yüksek sesle tartışabilirsiniz!
  sorgu text := format('select %1$s from public.actor t limit $1', sutunlar);
  sonuc int := 0;
begin
  for satir in execute sorgu using kacSatir
  loop
    sonuc := sonuc + length(satir.last_name) + length(satir.first_name);
  end loop;
  return sonuc;
end;
$$;

select 
  ornek_loop_dinamik('t.first_name, t.last_name') tabloda_zaten_200_satir_olmasi_lazim
, ornek_loop_dinamik('t.first_name, t.last_name', 3) sadece_3_satir_icin;

/*markdown
## etrafı temizleyelim:
*/

drop function if exists ornek_loop_statik;
drop function if exists ornek_loop_dinamik;