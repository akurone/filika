/*markdown
## nedir
- "tavuk mu yumurtadan" polemiğine girmeden pragmatik davranalım: prosedürü [return](01_return.sql) konusunda tarif ettiğimiz gibi geriye değer dönmeyen bir fonksiyon olarak düşünelim (evet `out` gibi parametreleri modifiye edersek değer dönebiliriz. halamın da bıyıkları olsa mesela amcam olur muydu?).
- prosedürü çağırmak için adının başına `call` eklemen lazım ve bir avazda tüm parametre (`in`/`out`/`inout`) aranjmanlarını halletmelisin, taksit sevmeyen bir mizacı var kendisinin.
- bir tane de `do` ile başlayan anonim bloklardan bırakıyorum aşağıya, beğenen linke tıklayıp alabilir.
*/

/*markdown
## örnek:
*/

create or replace procedure ornek_prosedur(a int, out b int, inout c int)
language plpgsql
as $$
begin
if a = 1 then
  c := b;
else
  b := 1;--bu satır çalışmadığı sürece c null olacak, peki neden?
  --ayrıca bu çalışınca neden out bir parametrenin değerini artık okuyabiliyoruz?
end if;
  c := b + a;
end;
$$;
-------
create or replace function ornek_prosedur_cagir(a int)
returns int
language plpgsql
as $$
declare
b_5_olsun int := 5;
c int;
begin
  call ornek_prosedur(a, b_5_olsun, c);
  return c;
end;
$$;

/*markdown
#### bakalım:
- ilk prosedürümüzü oluşturduk, korkacak bi'şey yokmuş..
- 3 parametremiz var, ilkine bir _modifier_ gelmedi dolayısıyla kendisinin `in` olduğuna eminiz (neden ki?),
- ikincisine `out` dedik yani: çağıranın bu parametre için bize verdiği değişkenin değerini okuyamayacağız ama bu değeri değiştirebileceğiz,
- üçüncüsüne `inout` dedik: hem çağıranın verdiği değeri görebileceğiz hem de değeri değiştirebileceğiz.
- `out` ve `inout` arasındaki farkı görelim diye bir [if](0301_cond_if.sql) uydurdum: eğer a=1 ise `out` olan bir parametreye <u>değer atamadan</u> okumaya çalışıyoruz, değilse değer atadıktan sonra <u>okuyoruz</u>, sonuca etkisini takip edebiliyor musun?
- işin felsefesine girmeyelim ama _composite type_ geri dönebilen bir ortamda `out` kullanmak için bayaa iyi nedenlerin olmalı (yani: out, out, out... yapacağına `table` dön).
- yukarıda prosedürü fonksiyon içinde çağırmaya bir örnek yaptık; görüldüğü gibi olağanüstü bir durum yok,
- aşağıda ise bir `do` bloğu oluşturup aynı işi yaptık. detayını [göreceğiz](../03_hata/01_raise.sql) ama _SQL Notebook_ eklentisi desteklemediği için `notice` _level_'i kullanamadık, onun yerine hata varmış gibi bir mesaj yayınlıyoruz.
*/

select ornek_prosedur_cagir(1) c_1, ornek_prosedur_cagir(2) c_2;

do $$
declare
  b_5_olsun int := 5;
  c_1 int := 0;
  c_2 int := 0;
begin
  call ornek_prosedur(1, b_5_olsun, c_1);
  call ornek_prosedur(2, b_5_olsun, c_2);
  raise 'c_1=% c_2=%', c_1, c_2;
end;
$$;

/*markdown
## etrafı temizleyelim:
*/

drop procedure if exists ornek_prosedur;
drop function if exists ornek_prosedur_cagir;