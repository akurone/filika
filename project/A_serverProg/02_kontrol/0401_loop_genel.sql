/*markdown
## nedir?
-  `loop` ve `end loop` arasındaki blok  `exit`/`return` görmediği (ve blok içinde bir hata oluşmadığı) sürece **sonsuza** (ya da elektrik kesilene) kadar devam eder.
- sade kullanılabileceği gibi `while`, `for` ve `for each` gibi genel amaçlı dillerden hatırlayacağınız ifadelerle birlikte kullanımı mevcut, sadesi tatsız olduğu için pek tercih edilmez.
- tablo gibi bir veri kaynağına bağlı ya da buradaki örneklerde olduğu gibi genel amaçlı kullanılabilir.
- `continue` ile <u>o seferlik</u> erken çıkmayı sağlayabilirsin; döngü, varsa bir sonraki iterasyondan devam eder.
*/

/*markdown
## örnek:
- loop ile çarpınım (_factorial_) hesaplayalım illa _recursive_ olacak diye bir kanun mu var?
- `exit` ve `continue` için `when` ile kullanımı da görmek adına bu fonksiyonu sadece 5'e kadar düzgün hesap yapabilecek şekilde sakatlıyoruz.
- kullanıldıkları yerler de önemli, 6 için yanlış çalışıyor da 7 ve sonrası için neden daha yanlış çalışıyor?
- `while` örneğinde `i` değişkenine yapılan atamanın yeri ile oynarsak başımıza neler gelebilir?
*/

create or replace function ornek_loop_for(n int)
returns int4
language plpgsql
as $$
declare
  sonuc int := 1;
begin
  for i in 1..n --burada BY ile artış miktarını belirtebilirdik, 
  --bu çarpınım hesabımızı daha da fazla sakatlayacağı için yapmıyoruz.
  loop
    continue when i = 6;
    sonuc := sonuc * i;
    exit when i = 7;
  end loop;
  return sonuc;
end;
$$;

create or replace function ornek_loop_while(n int)
returns integer
language plpgsql
as $$
declare
  sonuc int := 1;
  i int := 1;
begin
  while i < n
  loop
    i := i + 1;
    continue when i = 6;
    sonuc := sonuc * i;
    exit when i = 7;
  end loop;
  return sonuc;
end;
$$;

/*markdown
### görelim:
*/

select 
  ornek_loop_for(5) bes_for
, ornek_loop_for(6) alti_for
, ornek_loop_for(777) yedi_ve_sonrasi_for;

select 
  ornek_loop_while(5) bes_while
, ornek_loop_while(6) alti_while
, ornek_loop_while(777) yedi_ve_sonrasi_while;

/*markdown
## etrafı temizleyelim:
*/

drop function if exists ornek_loop_for;
drop function if exists ornek_loop_while;