/*markdown
## nedir?
koşul(lar)a (_predicate_) göre akışı yönlendirir, ata yadigarıdır:
```sql
if predicate1 then
 --predicate1 doğru öyleyse böyle yap dediğimiz yer burası
elsif predicate2 then
 --yok predicate2 ise böyle yap demek istersek orası burası
else
 --o da değil bu da değil o zaman böyle yeri burası
end if;
```
burada `if predicate then` ve `end if;` dışındaki kısımlar isteğe bağlı; sadece 1 adet _else_ olabilir, _elsif_ (istersen _els**e**if_) ihtiyaca göre çoklanabilir.
*/

/*markdown
## işte örnek:
*/

create or replace function ornek_if()
returns integer
language plpgsql
as $$
declare
  adet int;
  degisken int := -1;
begin
  select count(*) into adet from public.actor;
  if adet = degisken then
    return adet;
  elsif adet < degisken then
    return degisken;
  elseif adet = (adet * 5) then
    return -adet;
  else
    adet := degisken;
  end if;
end;
$$;

/*markdown
### çalıştıralım:
*/

select ornek_if()

/*markdown
### neden hata aldık?
yukarıdaki sorgu çalıştığında örnek fonksiyonda _else_ içindeki ifade bir değer dönmediği ve fonksiyonun kalan kısmında bir `return` ifadesi olmadığı için hata kaçınılmaz oluyor: 
> control reached end of function without RETURN
***
__yani__ daha derlemeden hatalarını yüzüne vuracak bir _compiler_ yok; onun için:
```sql
if ayak = yorgan then uzat(); end if;
```
*/

/*markdown
## etrafı temizleyelim:
*/

drop function if exists ornek_if;