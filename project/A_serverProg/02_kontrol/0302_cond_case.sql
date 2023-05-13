/*markdown
## varyant 1
`when` arkasında verilen değerlerle (ifade verilirse çalışma anındaki değeri dikkate alınır) karşılaştırılacak ifade peşin olarak `case` arkasına yazılır ve **_case_'deki ifadenin değeri = _when_'deki ifadenin değeri** durumunu sağlayan kısım çalıştırılır; eşitlik sağlanmazsa (varsa) `else` çalışır.
*/

create or replace function ornek_case_a(a int)
returns character varying
language plpgsql
as $$
begin
  case sign(a * 10)--gördüğün gibi burası herhangi bir ifade olabilir
    when sign(10 * 0), 1, 2 then--burası da öyle, 
      --birden fazla değer yakalamak istersen de seni tutan yok (burada 0, 1 ve 2 değerlerini "yakaladık").
      --ama sıraya dikkat etmemenin bir bedeli var!
      return 'noluyo burda?';
    when 0 then
      return 'sıfır';
    when 1 then
      return 'pozitif';
    when -1 then
      return 'negatif';
    else
      return 'yok artık';
  end case;
end;
$$;

/*markdown
## varyant 2
`case` arkasında ifade verilmeden her koşul bir `when` içine yazılır, ilk `true` olan kısım ya da (varsa) `else` çalışır. 
***
yeri gelmişken `if` örneğindeki hatayı da düzeltelim:
*/

create or replace function ornek_case_b()
returns int
language plpgsql
as $$
declare
  adet int;
  degisken int := -1;
  sonuc int;
begin
  select count(*) into adet from public.actor;
  case 
    when adet = degisken then
      sonuc := adet;
    when adet < degisken then
      sonuc := degisken;
    when adet = (adet * 5) then
      sonuc := -adet;
    else
      adet := degisken;
  end case;
  return sonuc;
end;
$$;

/*markdown
## ikisini de çalıştıralım:
*/

select 
  ornek_case_a(-3) negatif_olmali
, ornek_case_a(1*0) sifir_olmali
, ornek_case_a(10*10) pozitif_olmali
, ornek_case_b() sonuc_yok_ama_olsun_hata_da_yok

/*markdown
## etrafı temizleyelim:
*/

drop function if exists ornek_case_a;
drop function if exists ornek_case_b;